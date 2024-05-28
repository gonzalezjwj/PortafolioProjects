/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortafolioProject..NashvilleHousing

---------------------------------------------------------------------

-- Change Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortafolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

---------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortafolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortafolioProject..NashvilleHousing AS a
JOIN PortafolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortafolioProject..NashvilleHousing AS a
JOIN PortafolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortafolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortafolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(355)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortafolioProject..NashvilleHousing


-- Breaking out Owner Address

SELECT OwnerAddress
FROM PortafolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS ParseAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS ParseCity, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS ParseState
FROM PortafolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortafolioProject..NashvilleHousing

---------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortafolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortafolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE	
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortafolioProject..NashvilleHousing

---------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY
		UniqueID
	) AS row_num
FROM PortafolioProject..NashvilleHousing
)
-- DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1



SELECT *
FROM PortafolioProject..NashvilleHousing

---------------------------------------------------------------------

-- Delete Unuse Columns

SELECT *
FROM PortafolioProject..NashvilleHousing

ALTER TABLE PortafolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortafolioProject..NashvilleHousing
DROP COLUMN SaleDate

---------------------------------------------------------------------
