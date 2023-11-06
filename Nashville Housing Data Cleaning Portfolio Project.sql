/* Cleaning Data in SQL Queries */

/* Standardize Date Format */

Select SaleDateConverted, CONVERT(Date,SaleDate)
From dbo.NashvilleHousing;


Update dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

/* Doesn't Update properly, so.. */

ALTER TABLE dbo.NashvilleHousing
Add SaleDateConverted Date;

Update dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

/* Populate Property Address data */

SELECT * 
FROM dbo.NashvilleHousing
--WHERE propertyAddress IS NULL
ORDER BY parcelID;

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, 
ISNULL(A.propertyAddress, B.propertyAddress)
FROM dbo.NashvilleHousing AS A
JOIN dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.propertyAddress, B.propertyAddress)
FROM dbo.NashvilleHousing AS A
JOIN dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

/* Breaking out Address into Individual Columns (Address, City, State) */

SELECT PropertyAddress
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY parcelID;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Addresss,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

 Update dbo.NashvilleHousing 
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );
--ALTER TABLE dbo.NashvilleHousing
--Add PropertySplitCity Nvarchar(255);

Update dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


/*PARSENAME */

SELECT OwnerAddress
FROM dbo.NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM dbo.NashvilleHousing;


ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update dbo.NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


/* Change Y and N to Yes and No in "Sold as Vacant" field  */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM dbo.NashvilleHousing


UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



/* Remove Duplicates */
CTE--

SELECT * 
FROM dbo.NashvilleHousing;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



 Delete Unused Columns

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;



