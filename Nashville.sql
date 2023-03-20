-- Standardize date Format
SELECT SaleDate
FROM NashvilleHousing;


SELECT DATE_FORMAT(SaleDate, '%Y-%m-%d') AS SaleDateConverted, DATE(SaleDate) AS SaleDate
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;


UPDATE NashvilleHousing
SET SaleDateConverted = DATE_FORMAT(SaleDate, '%Y-%m-%d');


-- Populate Property Address data


Select *
From NashvilleHousing
-- Where PropertyAddress is null
order by parcelID;

Select a.parcelid,
a.propertyaddress, b.parcelid, 
b.propertyaddress, 
ifnull(a.propertyaddress, b.propertyaddress)
From NashvilleHousing as a
join nashvillehousing as b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

update nashvillehousing as a
join nashvillehousing as b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
set a.propertyaddress = ifnull(a.propertyaddress, b.propertyaddress)
where a.propertyaddress is null;


-- Breaking out Address into Individual Columns (Address, City, State)

Select propertyaddress
From NashvilleHousing;


SELECT
SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address ,
SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1))+2) AS Address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress varchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);



ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1))+2);


SELECT PropertySplitAddress, PropertySplitCity
FROM nashvillehousing;


Select OwnerAddress
FROM nashvillehousing;


SELECT
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1) AS Address
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity varchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1);



ALTER TABLE NashvilleHousing
Add OwnerSplitState varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1);


Select  OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM nashvillehousing;



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;



Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       
       
       
       


-- Remove Duplicates

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

From NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



DELETE FROM NashvilleHousing
WHERE UniqueID NOT IN (
SELECT UniqueID FROM (
SELECT UniqueID,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID
) AS row_num
FROM NashvilleHousing
) AS RowNumCTE
WHERE row_num = 1
);



-- Delete Unused Columns

Select *
From NashvilleHousing;


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
