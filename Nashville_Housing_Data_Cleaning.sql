/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Nashville_Housing].[dbo].[Nashville_Housing]
  ---------------------------------------------------------------------
  -- Standardize Date Format 

  SELECT SaleDateConverted, CONVERT(Date,SaleDate)
  FROM Nashville_Housing.dbo.Nashville_Housing

  UPDATE Nashville_Housing
  SET SaleDate = CONVERT(Date,SaleDate)

  ALTER TABLE Nashville_Housing
  ADD SaleDateConverted Date;

  UPDATE Nashville_Housing
  SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------
-- populate property address data 

SELECT *
FROM [Nashville_Housing].[dbo].[Nashville_Housing]
--WHERE PropertyAddress is null;
ORDER BY 
	ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville_Housing].[dbo].[Nashville_Housing] a
JOIN [Nashville_Housing].[dbo].[Nashville_Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville_Housing].[dbo].[Nashville_Housing] a
JOIN [Nashville_Housing].[dbo].[Nashville_Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;
------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM [Nashville_Housing].[dbo].[Nashville_Housing]


SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
FROM [Nashville_Housing].[dbo].[Nashville_Housing];

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1);

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress));

SELECT *
FROM [Nashville_Housing].[dbo].[Nashville_Housing];

SELECT OwnerAddress
FROM [Nashville_Housing].[dbo].[Nashville_Housing];

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Nashville_Housing].[dbo].[Nashville_Housing];

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);
--------------------------------------------------------------------------------------------------------------------------

-- Replace Y and N with Yes and No

SELECT DISTINCT SoldAsVacant,
				COUNT(SoldAsVacant)
FROM[Nashville_Housing].[dbo].[Nashville_Housing]
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	   CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END 
FROM [Nashville_Housing].[dbo].[Nashville_Housing];	

UPDATE Nashville_Housing
SET SoldAsVacant =  CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant 
					END ;
-----------------------------------------------------------------------------------------------		

-- Remove Duplicates 
WITH RowNumCTE AS(
SELECT  
		*,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID 
						)row_num
FROM [Nashville_Housing].[dbo].[Nashville_Housing]
--ORDER BY ParcelID;
)
SELECT* 
FROM 
	RowNumCTE
WHERE row_num >1;
--------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

SELECT * 
FROM [Nashville_Housing].[dbo].[Nashville_Housing];

ALTER TABLE [Nashville_Housing].[dbo].[Nashville_Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE [Nashville_Housing].[dbo].[Nashville_Housing]
DROP COLUMN SaleDate;