/*
Cleaning Data in SQL Queries
*/




Select *
From PortfolioProject..NashvilleHousingData







--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format





/*Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)*/

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update portfolioProject..NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)






 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data




Select *
From PortfolioProject..NashvilleHousingData
--Where PropertyAddress IS NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousingData a
Join PortfolioProject..NashvilleHousingData b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL


Update a
SET PropertyAddress =  ISNULL( a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousingData a
Join PortfolioProject..NashvilleHousingData b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL






--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)





Select PropertyAddress
From PortfolioProject..NashvilleHousingData

Select SUBSTRING(PropertyAddress,1,  CHARINDEX(',', PropertyAddress) -1) AS Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) AS City
From PortfolioProject..NashvilleHousingData



ALTER TABLE PortfolioProject..NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,  CHARINDEX(',', PropertyAddress) -1) 




Alter Table PortfolioProject..NashvilleHousingData
Add PropertySplitCity Nvarchar(255);


Update PortfolioProject..NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject..NashvilleHousingData


Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousingData


ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitAddress  NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)



ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitCity  NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitState  NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)







--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field





Select SoldAsVacant
From PortfolioProject..NashvilleHousingData

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant, 
CASE
	WHEN SoldAsVacant ='Y'
	THEN 'Yes'
	WHEN SoldAsVacant ='N'
	THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NashvilleHousingData



UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacant = CASE
					WHEN SoldAsVacant ='Y'
					THEN 'Yes'
					WHEN SoldAsVacant ='N'
					THEN 'No'
					ELSE SoldAsVacant
					END







					
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates






WITH RowNumCTE AS(
Select *,  ROW_NUMBER() OVER(
							PARTITION BY ParcelId,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY UniqueId) AS row_num
From PortfolioProject..NashvilleHousingData)
Select *
From RowNumCTE
Where row_num >1

WITH RowNumCTE AS(
Select *,  ROW_NUMBER() OVER(
							PARTITION BY ParcelId,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY UniqueId) AS row_num
From PortfolioProject..NashvilleHousingData)
DELETE
From RowNumCTE
Where row_num >1







---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


