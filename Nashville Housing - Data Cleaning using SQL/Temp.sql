# Create table for storing data
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
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' # Use to import data that has comma inside
LINES TERMINATED BY '\n'
IGNORE 1 LINES # Ignore the header columns
(UniqueID,ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,LegalReference,
SoldAsVacant,OwnerName,OwnerAddress,Acreage,TaxDistrict,LandValue,BuildingValue,
TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath);

# Populate Property Address data 
# We find all records that have the same parcelID and different uniqueID but missing Property Address then populating it
Select a.UniqueID,a.ParcelID, a.PropertyAddress,b.UniqueID,b.ParcelID,b.PropertyAddress
From nashvillehouse a
join nashvillehouse b on a.ParcelID=b.ParcelID
where a.PropertyAddress like '' and a.UniqueID<>b.UniqueID;


# Update records in the table
update nashvillehouse a
join nashvillehouse b on a.ParcelID=b.ParcelID
set a.PropertyAddress=b.PropertyAddress
where a.PropertyAddress like '' and a.UniqueID<>b.UniqueID;


# Remove double quotes from columns containing comma
UPDATE nashvillehouse SET 
PropertyAddress = REPLACE(PropertyAddress, '"', ''),
OwnerName = REPLACE(OwnerName, '"', ''),
OwnerAddress = REPLACE(OwnerAddress, '"', '');


# Splitting Address into Individual Columns: Address, City, State
SELECT
    REGEXP_SUBSTR(PropertyAddress, '[a-z"äöüß"\-\. ]+') AS street,
    REGEXP_SUBSTR(PropertyAddress, '[0-9]+') AS number
FROM
    nashvillehouse;
    
select * from nashvillehouse
where UniqueID=2045;

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From nashvillehouse
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

SET SQL_SAFE_UPDATES = 0;

select 	a.ParcelID,a.PropertyAddress,a.uniqueID,b.uniqueID from nashvillehouse a
join nashvillehouse b on a.uniqueID < b.uniqueID 
where 	a.PropertyAddress=b.PropertyAddress and
		a.ParcelID=b.ParcelID;

INSERT INTO tempTableName(PropertyAddress,ParcelID,SaleDate,LegalReference)
     SELECT DISTINCT PropertyAddress,ParcelID,SaleDate,LegalReference
     FROM nashvillehouse;

DELETE FROM nashvillehouse
    WHERE uniqueID NOT IN
    (
        SELECT min(uniqueID) AS minID
        FROM nashvillehouse
        GROUP BY PropertyAddress, 
				ParcelID, 
                 LegalReference
    );





