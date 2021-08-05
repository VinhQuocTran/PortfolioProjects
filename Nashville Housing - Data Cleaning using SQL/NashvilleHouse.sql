# Crate table for storing data
create table nashvillehouse
(
	UniqueID varchar(255),
    ParcelID varchar(255),
    LandUse varchar(255),
    PropertyAddress varchar(255),
    SaleDate date,
    SalePrice int,
    LegalReference varchar(255),
    SoldAsVacant varchar(255),
    OwnerName varchar(255),
    OwnerAddress varchar(255),
    Acreage float,
    TaxDistrict varchar(255),
    LandValue int,
    BuildingValue int,
    TotalValue int,
    YearBuilt year(4),
    Bedrooms smallint,
    FullBath smallint,
    HalfBath smallint
);


# Load data from Nashville.csv file
LOAD DATA INFILE 'C:/Program Files/MySQL/tmp/Nashville.csv'
INTO TABLE nashvillehouse
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(UniqueID,ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,LegalReference,
SoldAsVacant,OwnerName,OwnerAddress,Acreage,TaxDistrict,LandValue,BuildingValue,
TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath);

#
select * from nashvillehouse
where UniqueID=2045;




