select *
from PortfolioProject..nhousing




---------------------------------------------------------------------------------------------------------------------------------
--change date format
---------------------------------------------------------------------------------------------------------------------------------
select saledate, convert(date, saledate)
from PortfolioProject..nhousing
update PortfolioProject..nhousing
set saledate = convert(date,saledate)

--or  

alter table portfolioproject..nhousing
add saledateconverted date
 update PortfolioProject..nhousing
 set saledateconverted= convert(date,saledate)

select *
from PortfolioProject..nhousing





--Property address cleaning (Modify Null address)
---------------------------------------------------------------------------------------------------------------------------------
select*
from PortfolioProject..nhousing
--where propertyaddress is null 
order by ParcelID

select a.[UniqueID ] ,a.ParcelID,a.PropertyAddress,b.[UniqueID ], b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..nhousing a
join PortfolioProject..NHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null
order by a.ParcelID

update a
set PropertyAddress =  ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..nhousing a
join PortfolioProject..NHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]




---------------------------------------------------------------------------------------------------------------------------------
--Property address cleaning (Separate Address and City)
---------------------------------------------------------------------------------------------------------------------------------
select *
from PortfolioProject..NHousing

select PropertyAddress, SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1),
						SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))
from PortfolioProject..NHousing 

alter table portfolioproject..nhousing
add PropertySplitAddress nvarchar(255),PropertySplitCity nvarchar(255)

update portfolioproject..nhousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1),
	PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))





--Owner address cleaning (Separate Address,City,State)
---------------------------------------------------------------------------------------------------------------------------------
select *
from PortfolioProject..NHousing

select OwnerAddress,Parsename(Replace(owneraddress,',','.'),3),
					Parsename(Replace(owneraddress,',','.'),2),
					Parsename(Replace(owneraddress,',','.'),1)
from PortfolioProject..NHousing 

alter table portfolioproject..nhousing
add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

update PortfolioProject..NHousing
set OwnerSplitAddress =Parsename(Replace(owneraddress,',','.'),3),
	OwnerSplitCity =Parsename(Replace(owneraddress,',','.'),2),
	OwnerSplitState =Parsename(Replace(owneraddress,',','.'),1)




---------------------------------------------------------------------------------------------------------------------------------
--Change Y to Yes and N to No in SoldAsVacant
---------------------------------------------------------------------------------------------------------------------------------
select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NHousing	
group by SoldAsVacant

select soldasvacant,
	case when soldasvacant='Y'
			then 'Yes'
		when soldasvacant='N'
			then 'No'
		else soldasvacant end
from portfolioproject..nhousing
order by 1

update PortfolioProject..NHousing
set soldasvacant=case when soldasvacant='Y' then 'Yes'
					when soldasvacant='N' then 'No'
					else soldasvacant end




---------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicate Rows
---------------------------------------------------------------------------------------------------------------------------------
select *
from PortfolioProject..NHousing	

with RowNumber as
(
select *, ROW_NUMBER() over (partition by parcelid,propertyaddress,landuse,saledate, saleprice, legalreference order by uniqueid) rowN
from PortfolioProject..NHousing
)
delete
from rownumber
where rowN > 1 





---------------------------------------------------------------------------------------------------------------------------------
--Delete unusable columns
---------------------------------------------------------------------------------------------------------------------------------
select *
from PortfolioProject..NHousing

alter table PortfolioProject..NHousing
drop column propertyaddress, owneraddress, 
saledate
