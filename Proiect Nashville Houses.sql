Select *
From Proiect_Nashville_Houses.dbo.NashvilleHouses

-- Curatam datele in SQL

Select SaleDateConverted, CONVERT(Date, SaleDate)
From Proiect_Nashville_Houses.dbo.NashvilleHouses

Update NashvilleHouses
SET  SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHouses
Add SaleDateConverted Date;

Update NashvilleHouses
SET  SaleDateConverted = CONVERT(date,SaleDate)

-- Populam datele Adreselor Propietatii
Select *
From Proiect_Nashville_Houses.dbo.NashvilleHouses
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Proiect_Nashville_Houses.dbo.NashvilleHouses a
JOIN Proiect_Nashville_Houses.dbo.NashvilleHouses b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] != b.[UniqueID]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Proiect_Nashville_Houses.dbo.NashvilleHouses a
JOIN Proiect_Nashville_Houses.dbo.NashvilleHouses b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] != b.[UniqueID]
where a.PropertyAddress is NULL


-- IMpartim adresa in coluane individuale (Adresa, Oras, Stat)
Select PropertyAddress
From Proiect_Nashville_Houses.dbo.NashvilleHouses
--Where PropertyAddress is null
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From Proiect_Nashville_Houses.dbo.NashvilleHouses

ALTER TABLE NashvilleHouses
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHouses
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHouses
Add PropertySplitCity Nvarchar(255);

Update NashvilleHouses
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Proiect_Nashville_Houses.dbo.NashvilleHouses


Select OwnerAddress
From Proiect_Nashville_Houses.dbo.NashvilleHouses

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Proiect_Nashville_Houses.dbo.NashvilleHouses


ALTER TABLE NashvilleHouses
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHouses
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE NashvilleHouses
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHouses
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHouses
Add OwnerSplitState Nvarchar(255);

Update NashvilleHouses
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From Proiect_Nashville_Houses.dbo.NashvilleHouses

-- Schimbam Y si N cu Yes si NO in coloana "Sold as Vacant"

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From Proiect_Nashville_Houses.dbo.NashvilleHouses
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from Proiect_Nashville_Houses.dbo.NashvilleHouses

Update NashvilleHouses
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Eliminam Copiile
WITH RowNumCTE as(
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

from Proiect_Nashville_Houses.dbo.NashvilleHouses
--order by ParcelID
)
SELECT *
From RowNumCTE
where row_num > 1
Order by PropertyAddress

-- Stergem coluanele de care nu avem nevoie
Select *
from Proiect_Nashville_Houses.dbo.NashvilleHouses

ALTER TABLE Proiect_Nashville_Houses.dbo.NashvilleHouses
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
ALTER TABLE Proiect_Nashville_Houses.dbo.NashvilleHouses
DROP COLUMN SaleDate