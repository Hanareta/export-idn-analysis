BULK INSERT staging_nilai_ekspor
FROM "D:\Coder\export-indo-sql\data\nilai_ekspor_clean.csv"
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDQUOTE = '"',
	FIELDTERMINATOR = ',' ,
	ROWTERMINATOR = '\n',
	TABLOCK
)

BULK INSERT staging_volume_ekspor
FROM "D:\Coder\export-indo-sql\data\volume_ekspor_clean.csv"
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDQUOTE = '"',
	FIELDTERMINATOR = ',' ,
	ROWTERMINATOR = '\n',
	TABLOCK
)

BULK INSERT staging_sitc_komoditi
FROM 'D:\Coder\export-indo-sql\data\sitc_komoditi_clean.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    TABLOCK
);