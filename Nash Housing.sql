--Clean data

SELECT * FROM dbo.[Nash Housing]



--Standardize date format
SELECT SaleDate, CAST(SaleDate as date) 
FROM dbo.[Nash Housing]

UPDATE [Nash Housing]
SET SaleDate = CAST(SaleDate as date) 


--if it does not update
ALTER TABLE [Nash Housing]
Add Converted_SaleDate Date;

Update [Nash Housing]
SET Converted_SaleDate = CAST(SaleDate as date)

SELECT Converted_SaleDate
FROM dbo.[Nash Housing]


--*************************************************************************
--Populate Property Address
Select *
From [Nash Housing]
--Where PropertyAddress is null
order by ParcelID


Select has.ParcelID, has.PropertyAddress, doesnt.ParcelID, doesnt.PropertyAddress, ISNULL(has.PropertyAddress,doesnt.PropertyAddress)
From [Nash Housing] has
JOIN [Nash Housing] doesnt
	ON has.ParcelID = doesnt.ParcelID
	AND has.[UniqueID ] <> doesnt.[UniqueID ]
where has.PropertyAddress is null

UPDATE has
SET PropertyAddress = ISNULL(has.PropertyAddress,doesnt.PropertyAddress)
From [Nash Housing] has
JOIN [Nash Housing] doesnt
	ON has.ParcelID = doesnt.ParcelID
	AND has.[UniqueID ] <> doesnt.[UniqueID ]
where has.PropertyAddress is null

--********************************************************************************


----Break Address into individual columns (address, city, state)
--Select *
--From [Nash Housing]

--SELECT
--SUBSTRING(PropertyAddress, 1,CHARINDEX(',' , PropertyAddress) -1) as Address
--From [Nash Housing]

--********************************************************************************
--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Count
FROM [Nash Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE	WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM [Nash Housing]

UPDATE [Nash Housing]
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END 



--*****************************************************************************

--!!Remove Duplicates

WITH rowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UniqueID
	) row_num
FROM [Nash Housing]
)

--SELECT * FROM rowNumCTE 
--WHERE row_num>1
--ORDER BY PropertyAddress

DELETE 
FROM rowNumCTE 
WHERE row_num>1
--ORDER BY PropertyAddress



--*****************************************************************
--When creating views for cols you don't need
SELECT *
FROM [Nash Housing]

ALTER TABLE [Nash Housing]
DROP COLUMN SaleDate

ALTER TABLE [Nash Housing]
DROP COLUMN OwnerAddress, TaxDistrict
