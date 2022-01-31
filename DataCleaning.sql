DROP TABLE IF EXISTS Housing;
CREATE TABLE Housing(
UniqueID NUMERIC PRIMARY KEY,
ParcelID VARCHAR(20),
LandUse VARCHAR(50),
PropertyAddress VARCHAR(80),
SaleDate DATE,
SalePrice VARCHAR(50),
LegalReference VARCHAR(80),
SoldAsVacant VARCHAR(10),
OwnerNam VARCHAR(80),
OwnerAddress VARCHAR(80),
Acreage	NUMERIC,
TaxDistrict	VARCHAR(50),
LandValue NUMERIC,
BuildingValue 	NUMERIC,
TotalValue	NUMERIC,
YearBuilt	NUMERIC,
Bedrooms	NUMERIC,
FullBath	NUMERIC,
HalfBath NUMERIC
);

-- Populate the column propertyaddress is NULl
UPDATE Housing a
SET propertyaddress=b.propertyaddress
FROM Housing b
WHERE a.ParcelID=b.ParcelID
  AND a.uniqueid!=b.uniqueid
  AND a.propertyaddress IS NULL;
 
-- Break out property address into individual columns (address, city)
ALTER TABLE Housing
ADD COLUMN PropertySplitAddress VARCHAR(250);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(propertyaddress,1,POSITION(',' IN propertyaddress)-1);

ALTER TABLE Housing
ADD COLUMN PropertySplitCity VARCHAR(100);

UPDATE Housing
SET PropertySplitCity = SUBSTRING(propertyaddress,POSITION(','IN propertyaddress)+1,LENGTH(propertyaddress)); 

-- Break out owner address into individual columns (address, city, state)
ALTER TABLE Housing
ADD COLUMN ownerSplitAddress VARCHAR(255),
ADD COLUMN ownerSplitCity VARCHAR(100),
ADD COLUMN ownerSplitState VARCHAR(20);

UPDATE Housing
SET ownerSplitAddress = SPLIT_PART(REPLACE(owneraddress,'.',','),',',1),
  ownerSplitCity = SPLIT_PART(REPLACE(owneraddress,'.',','),',',2),
  ownerSplitState = SPLIT_PART(REPLACE(owneraddress,'.',','),',',3);
 
-- Change Y and N to Yes and No in "Sold as Vacant"
SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
 	  WHEN SoldAsVacant ='N' THEN 'No'
	  ELSE SoldAsVacant
	  END 
FROM Housing;

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
 	  WHEN SoldAsVacant ='N' THEN 'No'
	  ELSE SoldAsVacant
	  END;
	 
-- Remove duplicate rows
WITH delete_cte AS(
	SELECT UniqueID,
	row_number() OVER(PARTITION BY ParcelId,
					  Propertyaddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
				 ORDER BY UniqueID) row_num
	FROM Housing)
DELETE FROM Housing 
WHERE UniqueID IN (SELECT UniqueID FROM delete_cte WHERE row_num>1);

-- Delete Unused Columns
ALTER TABLE Housing
DROP COLUMN PropertyAddress,
DROP COLUMN	OwnerAddress, 
DROP COLUMN	TaxDistrict,
DROP COLUMN SaleDate;

