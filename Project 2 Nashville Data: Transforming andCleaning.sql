--Nashville Housing Data Cleaning Project

--Cleaning Data in SQL Queries
--(1)First Review Data Set
Select *
From PortfolioProject.dbo.NashvilleHousing

--(2)Standardize (Change) SaleDate Format- Test
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

--(3)Update table to reflect SaleDate Format 
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--(4)Update did not work so use Alter
ALTER TABLE NashvilleHousing
Add SaleDateUpdated Date;

--(5) Update table to reflect SaleDate Formate
Update NashvilleHousing
SET SaleDateUpdated = CONVERT(Date,SaleDate)

--Populate Missing Property Address Data (ParcelID=PropertyAddress)
--(1)First review Data Set
Select *
From PortfolioProject.dbo.NashvilleHousing
Where propertyaddress is null

--(2)Join Table to fill in missing address data using if statement- Test
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.Propertyaddress, b.propertyaddress) as PropertyAddressUpdated
From PortfolioProject.dbo.NashvilleHousing A
Join PortfolioProject.dbo.NashvilleHousing B
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--(3)Update Null Address Data (Must use alias after 'update' in update statement, otherwise query will return error)
Update A
SET PropertyAddress = ISNULL(a.Propertyaddress, b.propertyaddress)
From PortfolioProject.dbo.NashvilleHousing A
Join PortfolioProject.dbo.NashvilleHousing B
on a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Split Property Address string into Individual Columns (Street Name and City)
--(1) Review Data
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

--(2)Separate Street Name and City using Substring and Charindex- Test
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as StreetName,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

--(3)Alter Table to add Columns to accommodate the Address Separation and Update Table to reflect separated address data
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add AddressStreetName nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET AddressStreetName = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add AddressCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET AddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Populate Missing Owner Address Data
--(1)First review Data Set
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
Where OwnerAddress is null

--(2)Join Table to fill in missing owner address data using if statement
Select a.ParcelID, A.PropertyAddress, A.OwnerAddress, b.ParcelID, b.propertyaddress, b.OwnerAddress, ISNull(a.owneraddress,b.PropertyAddress) as OwnerAddressUpdated
From PortfolioProject.dbo.NashvilleHousing A
Join PortfolioProject.dbo.NashvilleHousing B
on a.ParcelID = b.ParcelID
Where a.OwnerAddress is null

--(3)Update Null owner Address Data (Must use alias after 'update' in update statement, otherwise query will return error)
Update A
SET OwnerAddress = ISNULL(a.OwnerAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
Join PortfolioProject.dbo.NashvilleHousing B
on a.ParcelID = b.ParcelID
Where a.OwnerAddress is null

--Add State (TN) to Owner Address Data Missing State
--(1)Review Data Set
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
where OwnerAddress not like '%tn'

--(2)Update records with missing state data
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerAddress = CONCAT(OwnerAddress,', TN')
where OwnerAddress like '%tn'

--(3)To correct State data lost due to update mishap (in step 2) 
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerAddress = PropertyAddress

--(4)Add TN as State to Owner Address Data
Update NashvilleHousing
Set OwnerAddress = CONCAT(OwnerAddress,', TN')
where OwnerAddress not like '%, TN'

--Separate Owner Address Column into Individual Columns (Street Name, City, and State)
--(1)Review Data
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--(2)Separate Street Name and City using Parse- Test
Select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From NashvilleHousing

--(3)Alter Table to add Columns to accommodate Owner Address Separation
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerStreetName nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerCity nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerState nvarchar(255);

--(4) Update Table to reflect separated Owner Address data
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerStreetName = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

--(5) Final Review of Address Formatting and Updates
Select *
From NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' Field
--(1)Review Data in 'Sold As Vacant' Field
Select Distinct(SoldAsVacant)
From NashvilleHousing

--(2)Update N to say No and Y to say Yes
Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = REPLACE(SoldAsVacant, 'N', 'No')

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = REPLACE(SoldAsVacant, 'Noo', 'No')

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = REPLACE(SoldAsVacant, 'Y', 'Yes')

--(3)Review Changes
Select Distinct(SoldAsVacant), Count(SoldasVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant asc

--(4)Updated Yeses to Yes
Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = REPLACE(SoldAsVacant, 'Yeses', 'Yes')

--(5)Review Again
Select Distinct(SoldAsVacant), Count(SoldasVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant asc

--Alternative method to change N to No and Y to Yes
-(6)-Change Y to Yes and N to No using 'Case When'-Test
Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END
From NashvilleHousing

--(7)Update Table to reflet changes using 'Change When
Update NashvilleHousing
SET SoldasVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END
---------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
--Note: Not a usual practice to delete data, usually a temp table can be created to run queries
--(1)Determine row duplicates--Test
Select *, ROW_NUMBER() Over (Partition by ParcelId, PropertyAddress,SalePrice,SaleDate,LegalReference Order By uniqueid) Duplicates
From NashvilleHousing
Order by ParcelID

--(2)Run CTE to delete row duplicates
With DuplicateCTE AS(
Select *, ROW_NUMBER() Over (Partition by
 ParcelId,
 PropertyAddress, 
 SalePrice,SaleDate, 
 LegalReference
 Order By uniqueid) Duplicates
From NashvilleHousing
--Order by ParcelID
)
Delete
From DuplicateCTE
Where Duplicates > 1
--Order by PropertyAddress
---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns (Property Address, Owner Address, SaleDate)
--(1)Review Data
Select *
From NashvilleHousing

--(2)Delete Property and Owner Address Columns
Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress

--(3)Delete Sales Date 
Alter Table NashvilleHousing
Drop Column SaleDate

--(4)Final Table Data Review
Select *
From NashvilleHousing
