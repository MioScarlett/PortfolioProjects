
/***** Cleaning Data in SQL queries *****/
select * 
from Housing.dbo.NashvilleHousing;


-- Standardize Data Format

alter table Housing.dbo.NashvilleHousing
alter column SaleDate date;

/**-- Populate Property Address data **/

select *
from Housing.dbo.NashvilleHousing
where PropertyAddress is null;

-- join table with itself to check if one address from one parcelID has been put into more than one uniqueid

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing.dbo.NashvilleHousing a
JOIN Housing.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

-- update where the propertyaddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing.dbo.NashvilleHousing a
JOIN Housing.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;


-- Breaking out address into individual columns (Address, City, State)
---SUBSTRING(string,startposition, length)
---CHARINDEX('t', 'Customer') >>return position: 4

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
from Housing.dbo.NashvilleHousing;

---add 2 columns of address seperated above

alter table Housing.dbo.NashvilleHousing
add 
PropertySplitAddress varchar(225)
,PropertySplitCity varchar(225);

update Housing.dbo.NashvilleHousing
set
PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
,PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));


---Do the same with OwnerAddress

select OwnerAddress 
from Housing.dbo.NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Housing.dbo.NashvilleHousing

 
alter table Housing.dbo.NashvilleHousing
add 
OwnerSplitAddress varchar(225)
,OwnerSplitCity varchar(225)
,OwnerSplitState varchar(225);


update Housing.dbo.NashvilleHousing
set
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);



-- Change Y and N to Yes and No in 'Sold as vacant' column

select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from Housing.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from Housing.dbo.NashvilleHousing


update Housing.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end





-- Remove duplicates

With RowNumCTE AS(
	Select *,
		ROW_NUMBER() OVER (
		partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
	from Housing.dbo.NashvilleHousing
	)
DELETE 
from RowNumCTE
where row_num > 1;


-- Delete unused columns

alter table Housing.dbo.NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate






select *
from Housing.dbo.NashvilleHousing