
                                             -- Nashville Housing Project [Data Cleansing] --


select * from NashvilleHousing;
----------------------------------------------------------------------


-- 1. Standardize date format ?

select saledateConverted ,CONVERT(date,SaleDate) from NashvilleHousing;


-- Adding a new column with date datatype
alter table nashvilleHousing
add saledateConverted date;

-- updating & converting above new column in old column (ie: sale date)
update NashvilleHousing
set saledateConverted = CONVERT(date,SaleDate);





-- 2. Populate Property address data ?

select * from NashvilleHousing;



-- populating all the null values in Property Address
select * from NashvilleHousing
where PropertyAddress is null;



-- Finding out null address 
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , ISNULL(a.propertyAddress,b.PropertyAddress) from 
NashvilleHousing as a
join
NashvilleHousing as b
on a.ParcelID = b. ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null ;


-- 
update a
set propertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress) from 
NashvilleHousing as a
join
NashvilleHousing as b
on a.ParcelID = b. ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null ;





-- 3. Breaking out Address into Individual Columns (Address, city, state) ?
select propertyAddress from NashvilleHousing;


-- splititng propertyAddress column
select 
SUBSTRING(propertyAddress,1,charindex(',',propertyAddress)-1) as address
,SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress)) as adderss
from NashvilleHousing;


-- adding new column address & city
alter table NashvilleHousing
add PropertysplitAddress nvarchar(255);

alter table NashvilleHousing
add Propertysplitcity nvarchar(255);


-- updating individual column in address & city
update NashvilleHousing
set PropertysplitAddress = SUBSTRING(propertyAddress,1,charindex(',',propertyAddress)-1); 

update NashvilleHousing
set PropertysplitCity = SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress));



                                  --- using Another Mehtod ---



-- 4.  Breaking out Address into Individual Columns (Address, city, state) ?

select ownerAddress 
from NashvilleHousing
where OwnerAddress is not null;

select 
PARSENAME(replace(ownerAddress,',','.'),3) as Address,
PARSENAME(replace(ownerAddress,',','.'),2) as city,
PARSENAME(replace(ownerAddress,',','.'),1) as state
from NashvilleHousing
where OwnerAddress is not null;



-- Adding column for address, city & state
alter table NashvilleHousing
add OwnersplitAddress nvarchar(255);

alter table NashvilleHousing
add Ownersplitcity nvarchar(255);

alter table NashvilleHousing
add Ownersplitstate nvarchar(255);



-- updating individual column in address, city & state
update NashvilleHousing
set OwnersplitAddress = PARSENAME(replace(ownerAddress,',','.'),3);

update NashvilleHousing
set OwnersplitCity = PARSENAME(replace(ownerAddress,',','.'),2);

update NashvilleHousing
set OwnersplitState = PARSENAME(replace(ownerAddress,',','.'),1);






-- 5. Change Y & N to YES & NO ?

-- cheking, where is Y & N
select distinct(soldasVacant), count(SoldasVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;


-- Converting 
select soldasVacant,
case 
when soldasVacant = 'Y' then 'YES'
when soldasVacant = 'N' then 'NO'
else soldasVacant
end 
from NashvilleHousing ;


-- Updating the result in the columns
update NashvilleHousing
set soldasVacant =
case 
when soldasVacant = 'Y' then 'YES'
when soldasVacant = 'N' then 'NO'
else soldasVacant
end 






-- 6.Removing Duplicates with CTE & Window Functions

With CTE as (
select *,
  ROW_NUMBER() over(partition by parcelID,propertyAddress,salePrice,SaleDate,LegalReference order by uniqueID) as row_num
from NashvilleHousing
)
select * from CTE 
where row_num >1;

--Delete from CTE 
--where row_num >1;






-- 7. Deleting unusual Columns
select * from NashvilleHousing;

alter table NashvilleHousing
drop column saledate,ownerAddress,TaxDistrict,PropertyAddress;
