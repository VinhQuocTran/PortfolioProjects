from numpy import NaN
import scrapy
from scrapy_splash import SplashRequest
from scrapy.http.response.html import HtmlResponse
import pandas as pd
import re

def getNumber(string):
    string=str(string)
    return ''.join(re.findall(r'\d+', string))

class LaptopSpider(scrapy.Spider):
    name = 'spider'


    render_script = '''
    function main(splash)
        assert(splash:go(splash.args.url))
        assert(splash:wait(2))


        assert(splash:wait(8))

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
        #start_urls = ["https://shopee.vn/%C3%81o-thun-nam-Cotton-Compact-phi%C3%AAn-b%E1%BA%A3n-Premium-ch%E1%BB%91ng-nh%C4%83n-Coolmate-i.24710134.7237568031?sp_atk=8e7fa0ff-40ee-49a4-8f0f-9f997c8e21b0&xptdk=8e7fa0ff-40ee-49a4-8f0f-9f997c8e21b0"]
        
        #url = to_native_str(url)
        yield SplashRequest(url=start_urls[0],callback=self.parse,endpoint="render.html",
                args={'wait': 5,'headers': {}})
             
    # def parse_item(self,response):
    #     comment_selector=response.xpath('//div[@class = "shopee-product-comment-list"]')
    #     print(comment_selector)
    #     comments=comment_selector.xpath('.//div[@class = "shopee-product-rating"]/text()').get()
    #     # print(comments)
        # print(len(comments))
        #total_reviews=comment_selector.xpath('.//div[@class = "MrYJVA"]/text()').get()
        #avg_rating=comment_selector.xpath('.//div[@class = "MrYJVA Ga-lTj"]/text()').get()
        # yield {
        #     'total_reviews':total_reviews,
        #     'avg_rating':avg_rating
        # }



    def parse(self, response):
        product_names=[]
        product_selector=response.xpath('//div[@class = "shop-search-result-view__item col-xs-2-4"]')

        for product in product_selector:
            name=product.xpath('.//div[@class = "_3Gla5X _2j2K92 _3j20V6"]/text()').get()
            money=product.xpath('.//div[@class = "_3w3Slt _2aeaHz _1Rbwjx"]/text()').get()
            money_discount=product.xpath('.//span[@class = "_3TJGx5"]/text()').getall()
            total_sell=product.xpath('.//div[@class = "_2Tc7Qg _2R-Crv"]/text()').get()
            link=product.xpath('.//a[@data-sqe="link"]/@href').get()


            # Money
            if len(money_discount)>1:
                money_discount='-'.join([getNumber(x) for x in money_discount])
            else:
                money_discount=getNumber(money_discount)
            # money_discount='₫'+money_discount


            if(money==None):
                money=money_discount
            else:
                money=getNumber(money)

            

            # Data preprocessing
            # Link
            link='https://shopee.vn/'+link

            # yield SplashRequest(url=link,callback=self.parse_item,endpoint="render.html",
            #     args={'wait': 5,'headers': {}})

            

            yield {
                'name':name,
                'money':money,
                'money_discount':money_discount,
                'total_sell':total_sell,
                'link':link
            }

        current_page=response.xpath('.//span[@class = "shopee-mini-page-controller__current"]/text()').get()
        total_page=response.xpath('.//span[@class = "shopee-mini-page-controller__total"]/text()').get()

        print('Page:', current_page, '/', total_page)

        # total_page=1
        # current_page=int(current_page)

        if(current_page<total_page):
            yield SplashRequest(url=response.url,callback=self.parse,meta={
                                    "splash": {
                                        "endpoint": "execute",
                                        "args": {
                                            'wait': 5,
                                            'url': response.url,
                                            "lua_source": self.render_script,
                                        }}},dont_filter=True)
                                    
                                


# scrapy crawl laptop