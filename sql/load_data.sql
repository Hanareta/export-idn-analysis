--Load to dim_negara
INSERT INTO dim_negara(nama_negara_en, nama_negara, kawasan)
SELECT DISTINCT negara, n.nama_negara_id, n.kawasan FROM staging_nilai_ekspor e
	LEFT JOIN mapping_negara n
		ON e.negara = n.nama_negara_en
WHERE n.kawasan IS NOT NULL


--load to fact_ekspor_negara
WITH unpivot_nilai AS (
	SELECT n.negara_id as negara_id,
		CAST(REPLACE(tahun, 'y', '') AS INT) AS tahun, 
		nilai_juta_usd
	FROM staging_nilai_ekspor 
		UNPIVOT (
		nilai_juta_usd FOR tahun IN (y2000, y2001, y2002, y2003, y2004, y2005, y2006, y2007, y2008,y2009,
		y2010, y2011, y2012, y2013, y2014, y2015, y2016, y2017, y2018, y2019, y2020, y2021, y2022, y2023, y2024, y2025)
		) as nilai
		INNER JOIN dim_negara n ON negara = n.nama_negara_en
		),
unpivot_volume AS (
SELECT 
	n.negara_id, 
	CAST(REPLACE(tahun, 'y', '') AS INT) AS tahun, 
	volume
FROM staging_volume_ekspor
UNPIVOT (volume FOR tahun IN (y2000, y2001, y2002, y2003, y2004, y2005, y2006, y2007, y2008,y2009,
		y2010, y2011, y2012, y2013, y2014, y2015, y2016, y2017, y2018, y2019, y2020, y2021, y2022, y2023, y2024, y2025)
		) as volume
INNER JOIN dim_negara n ON negara = n.nama_negara
)
INSERT INTO fact_ekspor_negara(negara_id, tahun, nilai_juta_usd, volume_ribu_ton)
SELECT 
	COALESCE(n.negara_id, v.negara_id) as negara_id, 
	COALESCE(n.tahun, v.tahun) as tahun, 
	TRY_CAST(REPLACE(nilai_juta_usd, ',', '') AS DECIMAL(19,4)) as nilai_juta_usd, 
	TRY_CAST(REPLACE(volume, ',', '') AS DECIMAL(12,2)) as volume_ribu_ton
FROM unpivot_nilai n
FULL JOIN unpivot_volume v 
	ON n.negara_id = v.negara_id
	AND n.tahun = v.tahun

--load to dim_komoditi
INSERT INTO dim_komoditi(kode_sitc, nama_komoditi)
SELECT 
	LEFT(komoditi, 1) as kode_sitc,
	SUBSTRING(komoditi,4, LEN(komoditi)) as nama_komoditi
FROM staging_sitc_komoditi
WHERE LEFT(komoditi, 1) LIKE '[0-9]'
;

--load to fact_erkspor_komoditi
INSERT INTO fact_ekspor_komoditi(komoditi_id, tahun, nilai_juta_usd)
SELECT 
	d.komoditi_id,
	CAST(REPLACE(tahun,'y','') AS INT) as tahun,
	TRY_CAST(nilai_juta_usd AS DECIMAL(19,4)) as nilai_juta_usd
FROM staging_sitc_komoditi 
UNPIVOT(
	nilai_juta_usd FOR tahun IN( y2010, y2011, y2012, y2013, y2014, y2015, 
	y2016, y2017, y2018, y2019, y2020, y2021, y2022, y2023, y2024, y2025)
) as sitc
JOIN dim_komoditi d ON d.kode_sitc = LEFT(sitc.komoditi,1)
WHERE LEFT(komoditi, 1) LIKE '[0-9]'