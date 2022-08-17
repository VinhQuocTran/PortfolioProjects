from numpy import NaN
import scrapy
from scrapy_splash import SplashRequest
from scrapy.http.response.html import HtmlResponse
import pandas as pd
import re

def getNumber(string):
    string=str(string)
    return ''.join(re.findall(r'\d+', string))

class ShopeeSpider(scrapy.Spider):
    name = 'spider'

    render_script = '''
    function main(splash)
        assert(splash:go(splash.args.url))
        assert(splash:wait(10))

        assert(splash:runjs("document.querySelector('button.shopee-icon-button.shopee-icon-button--right').click()"))
        assert(splash:wait(2))
        
        return {
            html = splash:html(),
            url = splash:url(),
        }
    end
    '''

    def start_requests(self):
        start_urls = ["https://shopee.vn/coolmate.vn"]
        yield SplashRequest(url=start_urls[0],callback=self.parse,endpoint="render.html",
                args={'wait': 5,'headers': {}})
             
    def parse(self, response):
        product_names=[]
        product_selector=response.xpath('//div[@class = "shop-search-result-view__item col-xs-2-4"]')

        for product in product_selector:
            name=product.xpath('.//div[@class = "_3Gla5X _2j2K92 _3j20V6"]/text()').get()
            money=product.xpath('.//div[@class = "_3w3Slt _2aeaHz _1Rbwjx"]/text()').get()
            money_discount=product.xpath('.//span[@class = "_3TJGx5"]/text()').getall()
            total_sell=product.xpath('.//div[@class = "_2Tc7Qg _2R-Crv"]/text()').get()
            url=product.xpath('.//a[@data-sqe="link"]/@href').get()


            # Money
            if len(money_discount)>1:
                money_discount='-'.join([getNumber(x) for x in money_discount])
            else:
                money_discount=getNumber(money_discount)

            if(money==None):
                money=money_discount
            else:
                money=getNumber(money)

            url='https://shopee.vn'+url

            yield {
                'name':name,
                'price':money,
                'discount_price':money_discount,
                'sales':total_sell,
                'URL':url
            }

        current_page=response.xpath('.//span[@class = "shopee-mini-page-controller__current"]/text()').get()
        total_page=response.xpath('.//span[@class = "shopee-mini-page-controller__total"]/text()').get()
        print('Page:', current_page, '/', total_page)

        if(current_page<total_page):
            yield SplashRequest(url=response.url,callback=self.parse,meta={
                                    "splash": {
                                        "endpoint": "execute",
                                        "args": {
                                            'wait': 5,
                                            'url': response.url,
                                            "lua_source": self.render_script,
                                        }}},dont_filter=True)