--Script en SQL paralimpiar una dataset hasta hacerlo funcional

--Se realiza una consulta general de la base de datos para observar los errores que pueda tener
SELECT *
FROM ProjectNashvilleHousing..HousingData;

/* De la consulta se observan los siguientes errores:
	-Problema con el formato de las fechas;
	-Valores NULL en PropertyAddress;
	-Las direcciones contienen dirección, ciudad y estado (lo que complicaría si se quisiera trabajar con estos datos de manera individual);
	-SoldAsVacant debería de ser únicamente valores No o Yes, pero también tiene N y Y
	-Se asume que hubo un error en el sistema por lo que se crearon ordenes duplicadas pero con diferente UniqueID (Primary Key),
	se tiene que elimnar esas ordenes duplicadas.
	*/

--Resolicón de problemas:
	
	--Formato de fechas


UPDATE ProjectNashvilleHousing..HousingData 
SET SaleDate = CONVERT(Date, SaleDate); 

SELECT SaleDateConverted, SaleDate
FROM ProjectNashvilleHousing..HousingData;

/*Debido a errores que no pude corregir con la query de arriba, se creará una nueva columna
donde se registrarán los valores con la fecha correcta llamada SalesDate
*/

--Nueva columna
ALTER TABLE ProjectNashvilleHousing..HousingData
Add SalesDate Date;

UPDATE ProjectNashvilleHousing..HousingData
SET SalesDate = CONVERT(Date,SaleDate);

--Eliminar columna original
ALTER TABLE ProjectNashvilleHousing..HousingData
DROP COLUMN SaleDate;

SELECT *
FROM ProjectNashvilleHousing..HousingData

/* Valores Nulos en PropertyAdress.
	Después de observar la base de datos vemos que los valores con mismo ParcelID es la misma dirección
	por lo que se decide rellenar los valores nulos con observaciones del mismo ParcelID con selfjoin
*/
SELECT PropertyAddress
FROM ProjectNashvilleHousing..HousingData
WHERE PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM ProjectNashvilleHousing..HousingData a
JOIN ProjectNashvilleHousing..HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Dividir PropertyAdress y OwnerAddress en dirección, ciudad y estado.
	--Dividir PropertyAdress En PropertyAddress y Property City
SELECT PropertyAddress
FROM ProjectNashvilleHousing..HousingData;

--Crear y llenar la columna PropertyCity

ALTER TABLE ProjectNashvilleHousing..HousingData
ADD PropertyCity NVARCHAR(255);

UPDATE ProjectNashvilleHousing..HousingData
SET PropertyCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress));

--Actualizar la columna PropertyAddress para solo mantener la dirección
UPDATE ProjectNashvilleHousing..HousingData
SET PropertyAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1 );

--Verificar que el resultado sea correcto
SELECT *
FROM ProjectNashvilleHousing..HousingData;

--Dividir OwnerAddress En OwnerAddress, OwnerCity y OwnerState

--Crear y llenar la columna OwnerState

ALTER TABLE ProjectNashvilleHousing..HousingData
ADD OwnerState NVARCHAR(255);

UPDATE ProjectNashvilleHousing..HousingData
SET OwnerState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1);

--Crear y llenar la columna OwnerCity

ALTER TABLE ProjectNashvilleHousing..HousingData
ADD OwnerCity NVARCHAR(255);

UPDATE ProjectNashvilleHousing..HousingData
SET OwnerCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2);

--Actualizar la columna PropertyAddress para solo mantener la dirección
UPDATE ProjectNashvilleHousing..HousingData
SET OwnerAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3);

--Verificar si se ejecutó el proceso correctamente
SELECT *
FROM ProjectNashvilleHousing..HousingData;


--Corregir las respuestas en la columna SoldAsVacant
UPDATE ProjectNashvilleHousing..HousingData
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant IN ('Y', 'Yes') THEN 'Yes'
		WHEN SoldAsVacant IN ('N', 'No') THEN 'No'
		ELSE SoldAsVacant
	END;

--Verificar si se ejecutó el proceso correctamente
SELECT 
	DISTINCT(SoldAsVacant)
FROM ProjectNashvilleHousing..HousingData;

--Eliminar órdenes duplicadas

WITH DupliCTE AS(
	SELECT *,
			ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
								LandUse,
								PropertyAddress,
								SalePrice,
								LegalReference,
								SoldAsVacant,
								OwnerName,
								OwnerAddress,
								Acreage,
								TaxDistrict,
								TotalValue,
								YearBuilt,
								SalesDate,
								PropertyCity,
								OwnerCity
								ORDER BY UniqueID) AS RowNum
	FROM ProjectNashvilleHousing..HousingData
)
DELETE
FROM DupliCTE
WHERE RowNum > 1

-- Verificamos que ya no haya duplicados

WITH DupliCTE AS(
	SELECT *,
			ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
								LandUse,
								PropertyAddress,
								SalePrice,
								LegalReference,
								SoldAsVacant,
								OwnerName,
								OwnerAddress,
								Acreage,
								TaxDistrict,
								TotalValue,
								YearBuilt,
								SalesDate,
								PropertyCity,
								OwnerCity
								ORDER BY UniqueID) AS RowNum
	FROM ProjectNashvilleHousing..HousingData
)
SELECT *
FROM DupliCTE
WHERE RowNum > 1
ORDER BY [UniqueID ]