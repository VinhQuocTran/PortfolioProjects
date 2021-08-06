--------------------------------------------------------------------------------------------------------------------------
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


# Load data from NashvilleHouse.csv file
LOAD DATA INFILE 'C:/Program Files/MySQL/tmp/NashvilleHouse.csv'
INTO TABLE nashvillehouse
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' # Use to import data that has comma inside
LINES TERMINATED BY '\n'
IGNORE 1 LINES # Ignore the header columns
(UniqueID,ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,LegalReference,
SoldAsVacant,OwnerName,OwnerAddress,Acreage,TaxDistrict,LandValue,BuildingValue,
TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath);

--------------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------------

# Splitting Address into Individual Columns: Address, City, State
select
SUBSTRING_INDEX( PropertyAddress, ',', 1 ) as Address,
SUBSTRING_INDEX( PropertyAddress, ',', -1 ) as City
From nashvillehouse;


# Create 2 new columns for splitting address and city
alter table nashvillehouse
Add PropertySplitAddress 	varchar(255),
Add PropertySplitCity  		varchar(255);


# Update records in 2 columns that we created
update nashvillehouse
SET PropertySplitAddress = SUBSTRING_INDEX( PropertyAddress, ',', 1 ),
PropertySplitCity = SUBSTRING_INDEX( PropertyAddress, ',', -1 );


# We will split again, but with Owner Address
# Create 3 columns and update records
ALTER TABLE nashvillehouse
ADD OwnerSplitAddress 	VARCHAR(255),
ADD OwnerSplitCity  	VARCHAR(255),
ADD OwnerSplitState  	VARCHAR(255);

UPDATE nashvillehouse
SET 
OwnerSplitAddress 	= SUBSTRING_INDEX( OwnerAddress, ',', 1 ),
OwnerSplitCity 		= SUBSTRING_INDEX( SUBSTRING_INDEX( OwnerAddress, ',', 2 ) ,',',-1),
OwnerSplitState 	= SUBSTRING_INDEX( OwnerAddress, ',', -1 );

--------------------------------------------------------------------------------------------------------------------------

# Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant) count
FROM
    nashvillehouse
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC;


UPDATE nashvillehouse
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Find duplicate values based on 4 columns: PropertyAddress, ParcelID, SaleDate,LegalReference

# First Method: use GROUP BY and HAVING
SELECT PropertyAddress, ParcelID, SaleDate,LegalReference, COUNT(*)
FROM nashvillehouse
GROUP BY PropertyAddress, ParcelID,SaleDate,LegalReference
HAVING COUNT(*)>1;

# Second Method: WITH and ROW_NUMBER
With 
rowNumCTE as (select ROW_NUMBER() OVER (PARTITION BY PropertyAddress,ParcelID,LegalReference,SaleDate) as row_num from nashvillehouse )
select *
FROM RowNumCTE
where row_num>1;


# keep the lowest record uniqueID and remove all duplicate values 
DELETE FROM nashvillehouse
WHERE UniqueID IN (
  SELECT calc_id FROM (
    SELECT MIN(UniqueID) AS calc_id
    FROM nashvillehouse
    GROUP BY PropertyAddress,ParcelID,LegalReference,SaleDate
    HAVING COUNT(UniqueID) > 1
  ) temp
);

---------------------------------------------------------------------------------------------------------

# Delete Unused Columns
 Select *
 From nashvillehouse;


 ALTER TABLE nashvillehouse
     DROP OwnerAddress,
     DROP TaxDistrict,
     DROP PropertyAddress,
     DROP SaleDate;

