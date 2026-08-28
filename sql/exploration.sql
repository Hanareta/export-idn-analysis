SELECT COUNT(*) AS jumlah_baris FROM staging_nilai_ekspor
UNION ALL
SELECT COUNT(*) AS jumlah_baris FROM staging_volume_ekspor
UNION ALL
SELECT COUNT(*) AS jumlah_baris FROM staging_sitc_komoditi;

SELECT * FROM staging_sitc_komoditi;

SELECT DISTINCT negara FROM staging_nilai_ekspor ORDER BY negara;

SELECT * FROM staging_nilai_ekspor
WHERE negara = 'Rest of European Union'
-- ASEAN2), European Union1),

SELECT COUNT(*) FROM mapping_negara;
SELECT * FROM mapping_negara;

SELECT DISTINCT negara FROM staging_volume_ekspor
WHERE negara NOT IN (SELECT nama_negara_en FROM mapping_negara)
  AND negara NOT IN (SELECT negara FROM staging_nilai_ekspor);

SELECT DISTINCT e.negara
FROM staging_nilai_ekspor e
LEFT JOIN mapping_negara n ON e.negara = n.nama_negara_en
WHERE n.nama_negara_en IS NULL;

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
SELECT 
	COALESCE(n.negara_id, v.negara_id) as negara_id, 
	COALESCE(n.tahun, v.tahun) as tahun, 
	TRY_CAST(REPLACE(nilai_juta_usd, ',', '') AS DECIMAL(19,4)) as nilai_juta_usd, 
	TRY_CAST(REPLACE(volume, ',', '') AS DECIMAL(12,2)) as volume_ribu_ton
FROM unpivot_nilai n
FULL JOIN unpivot_volume v ON n.negara_id = v.negara_id


SELECT DISTINCT y2000 FROM staging_nilai_ekspor WHERE ISNUMERIC(y2000) = 0;

SELECT y2000
FROM staging_nilai_ekspor
WHERE TRY_CAST(y2000 AS DECIMAL(19,4)) IS NULL
  AND y2000 IS NOT NULL;

SELECT COUNT(*) FROM fact_ekspor_negara;

SELECT f.tahun, f.nilai_juta_usd, f.volume_ribu_ton
FROM fact_ekspor_negara f
JOIN dim_negara d ON d.negara_id = f.negara_id
WHERE d.nama_negara = 'Jepang'
ORDER BY f.tahun;

SELECT 
	komoditi,
	LEFT(komoditi, 1) as kode_sitc,
	SUBSTRING(komoditi,4, LEN(komoditi)) as nama_komoditi
FROM staging_sitc_komoditi
WHERE LEFT(komoditi, 1) LIKE '[0-9]'
;

--pengecekan sesudah load to dim_komoditi
SELECT * FROM dim_komoditi;

--pengecekan sebelum load to fact_ekspor_komoditi
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

SELECT COUNT(*) FROM (SELECT 
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
) x

SELECT komoditi_id, tahun, nilai_juta_usd
FROM (
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
) x
WHERE nilai_juta_usd IS NULL;

--pengecekan sesudahload to fact_ekspor_komoditi
SELECT COUNT(*) FROM fact_ekspor_komoditi;

SELECT * FROM fact_ekspor_komoditi WHERE nilai_juta_usd IS NULL;