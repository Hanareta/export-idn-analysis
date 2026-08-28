WITH data_tiongkok AS (
	SELECT 
		REPLACE(negara, '1)', '') as negara,
		CAST(REPLACE(tahun, 'y', '') AS INT) as tahun,
		TRY_CAST(REPLACE(volume, ',', '') AS DECIMAL(12,2)) as volume
	FROM staging_volume_ekspor
		UNPIVOT (volume FOR tahun IN (y2000, y2001, y2002, y2003, y2004, y2005, y2006, y2007, y2008,y2009,
		y2010, y2011, y2012, y2013, y2014, y2015, y2016, y2017, y2018, y2019, y2020, y2021, y2022, y2023, y2024, y2025)
		) as volume
	WHERE negara = 'Tiongkok1)'
	)
UPDATE fact_ekspor_negara
SET volume_ribu_ton = dt.volume
FROM fact_ekspor_negara f
JOIN dim_negara d ON d.negara_id = f.negara_id
JOIN data_tiongkok dt On dt.tahun = f.tahun	
WHERE d.nama_negara = 'Tiongkok'
