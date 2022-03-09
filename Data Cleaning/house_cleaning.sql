/*
Cleaning data in SQL QUERY
*/
SELECT * FROM sc_covid_19.nashvillehousing;

-- query all columns name with their datatypes
SELECT COLUMN_NAME , DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'sc_covid_19' and table_name= 'nashvillehousing'; 
--  another way 
describe sc_covid_19.nashvillehousing;
 -- saleData columns has datatype text so we should covert that to date datatype

-- -------------------------------------------------
--  1-Standardized Date Format
describe sc_covid_19.nashvillehousing;

SELECT DISTINCT SaleDate
FROM sc_covid_19.nashvillehousing; 

select SaleDate , str_to_date(SaleDate  , "%M %d,%Y") 
from sc_covid_19.nashvillehousing;

 ALTER TABLE sc_covid_19.nashvillehousing
 ADD sale_date_convert date;

update  sc_covid_19.nashvillehousing
set sale_date_convert  = str_to_date(SaleDate  , "%M %d,%Y");

-- ------------------------------------------------------------------------------------------------------------------------
-- 2-Breaking out Address into Individual Columns (Address, City)
SELECT distinct PropertyAddress
FROM sc_covid_19.nashvillehousing;

select PropertyAddress,
substr(PropertyAddress , 
         1 , 
         locate(',' , PropertyAddress)-1
         ) as address,
substr(PropertyAddress , 
         locate(',' , PropertyAddress)+1 , 
         length(PropertyAddress)
         ) as city
FROM sc_covid_19.nashvillehousing;

alter table sc_covid_19.nashvillehousing
add property_address varchar(255),
add property_city varchar(20);

update sc_covid_19.nashvillehousing
set property_address = substr(PropertyAddress , 1 , locate(',' , PropertyAddress)-1 ) ,
	property_city = substr(PropertyAddress , locate(',' , PropertyAddress)+1 , length(PropertyAddress));
    
--  --------------------------------------------------------------------
-- We need to do the same wth the owner address
-- split OwnerAddress into (address , city ,state)

select OwnerAddress ,
	 SUBSTRING_INDEX( nashvillehousing.OwnerAddress , ',' , 1) AS address  ,
	 SUBSTRING_INDEX(SUBSTRING_INDEX( nashvillehousing.OwnerAddress , ',' , 2) , ',' , -1) AS city,
     SUBSTRING_INDEX(nashvillehousing.OwnerAddress , ',' , -1) AS state
FROM sc_covid_19.nashvillehousing;

ALTER TABLE sc_covid_19.nashvillehousing
add address varchar(200),
add  city   varchar(20),
add state  varchar(20);

-- let's make column name more sensitive
alter table sc_covid_19.nashvillehousing
change address owner_split_address varchar(255),
change	city owner_split_city varchar(20),
change state owner_plit_state varchar(20);
  
update sc_covid_19.nashvillehousing
set address = SUBSTRING_INDEX( nashvillehousing.OwnerAddress , ',' , 1) ,
    city = SUBSTRING_INDEX(SUBSTRING_INDEX( nashvillehousing.OwnerAddress , ',' , 2) , ',' , -1),
    state = SUBSTRING_INDEX(nashvillehousing.OwnerAddress , ',' , -1);

-- ------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select  distinct SoldAsVacant , count(*) as count_v 
from sc_covid_19.nashvillehousing
group by SoldAsVacant
ORDER BY count_v desc;

select SoldAsVacant , 
		CASE WHEN SoldAsVacant  = 'N' THEN SoldAsVacant='No'
			 WHEN SoldAsVacant = 'Y'  THEN SoldAsVacant = 'Yes'
             ELSE SoldAsVacant
             END as sold_conv
FROM sc_covid_19.nashvillehousing;

update sc_covid_19.nashvillehousing
set SoldAsVacant = CASE WHEN SoldAsVacant  = 'N' THEN SoldAsVacant='No'
			            WHEN SoldAsVacant = 'Y'  THEN SoldAsVacant = 'Yes'
                        ELSE SoldAsVacant
                   END ;

-- -------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
select * from sc_covid_19.nashvillehousing;

alter table sc_covid_19.nashvillehousing
drop column PropertyAddress , 
drop column SaleDate , 
drop column OwnerAddress,
drop column TaxDistrict ;

