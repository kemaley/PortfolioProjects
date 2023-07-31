-- Data Cleaning Project - Nashville Housing Data

SELECT *
FROM
	PortfolioProjects.dbo.NashvilleHousing;

---------------------------------------------------------------------------

-- Standardizing the Date Format

SELECT 
	SaleDate,
	CONVERT(Date, SaleDate) AS FormattedDate
FROM
	PortfolioProjects.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


---------------------------------------------------------------------------

-- Populate missing Property Address data based on ParcelID

SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing
--WHERE 
--	PropertyAddress IS NULL
ORDER BY
	ParcelID;


SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProjects.dbo.NashvilleHousing a
JOIN 
	PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL; 


UPDATE a
SET
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProjects.dbo.NashvilleHousing a
JOIN 
	PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL;


---------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- PropertyAddress

SELECT
	PropertyAddress
FROM 
	PortfolioProjects.dbo.NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address2
FROM 
	PortfolioProjects.dbo.NashvilleHousing;


ALTER TABLE 
	NashvilleHousing
ADD 
	PropertySplitAddress NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE 
	NashvilleHousing
ADD 
	PropertySplitCity NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing;



-- Owner Address

SELECT 
	OwnerAddress
FROM 
	PortfolioProjects.dbo.NashvilleHousing;

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM 
	PortfolioProjects.dbo.NashvilleHousing;


ALTER TABLE 
	NashvilleHousing
ADD 
	OwnerSplitAddress NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE 
	NashvilleHousing
ADD 
	OwnerSplitCity NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE 
	NashvilleHousing
ADD 
	OwnerSplitState NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing;


---------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant"-field

SELECT 
	DISTINCT(SoldAsVacant), -- (Yes, No, y, n)
	COUNT(SoldAsVacant)
FROM
	PortfolioProjects.dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	COUNT(SoldAsVacant) DESC;


SELECT 
	SoldAsVacant,
	CASE WHEN
		SoldAsVacant = 'Y' THEN 'Yes'
	WHEN
		SoldAsVacant = 'N' THEN 'No'
	ELSE
		SoldAsVacant
	END
FROM
	PortfolioProjects.dbo.NashvilleHousing;


UPDATE
	NashvilleHousing
SET SoldAsVacant = 
	CASE WHEN
		SoldAsVacant = 'Y' THEN 'Yes'
	WHEN
		SoldAsVacant = 'N' THEN 'No'
	ELSE
		SoldAsVacant
	END;


---------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER(
		PARTITION BY 
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID) row_num
FROM
	PortfolioProjects.dbo.NashvilleHousing)

DELETE
FROM 
	RowNumCTE
WHERE 
	row_num > 1
--ORDER BY
--	PropertyAddress; 


---------------------------------------------------------------------------

-- Delete unused columns

SELECT 
	*
FROM
	PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE
	PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN
	OwnerAddress, TaxDistrict, PropertyAddress