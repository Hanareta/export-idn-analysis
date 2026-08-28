SELECT 
	f.komoditi_id 
FROM fact_ekspor_komoditi f
LEFT JOIN dim_komoditi d ON f.komoditi_id = d.komoditi_id
WHERE d.komoditi_id IS NULL

SELECT f.negara_id
FROM fact_ekspor_negara f
LEFT JOIN dim_negara d ON f.negara_id = d.negara_id
WHERE d.negara_id IS NULL

SELECT
	tahun,
	COUNT(*) as jumlah
FROM fact_ekspor_negara
WHERE nilai_juta_usd IS NULL
GROUP BY tahun

SELECT
	negara_id,
	COUNT(*) as jumlah
FROM fact_ekspor_negara
WHERE nilai_juta_usd IS NULL
GROUP BY negara_id

SELECT * FROM dim_negara
WHERE negara_id = 9

SELECT
	negara_id,
	tahun,
	nilai_juta_usd
FROM fact_ekspor_negara
WHERE nilai_juta_usd IS NULL
ORDER BY tahun

--
SELECT 
	COUNT(*) as jumlah_baris,
	SUM(CASE WHEN nilai_juta_usd IS NULL THEN 1 ELSE 0 END) as nilai_null,
	SUM(CASE WHEN volume_ribu_ton IS NULL THEN 1 ELSE 0 END) as volume_null,
	SUM(CASE WHEN nilai_juta_usd IS NULL AND volume_ribu_ton IS NULL THEN 1 ELSE 0 END) as keduanya_null
FROM fact_ekspor_negara;

SELECT d.nama_negara, COUNT(*)
FROM fact_ekspor_negara f 
LEFT JOIN dim_negara d ON f.negara_id = d.negara_id
WHERE nilai_juta_usd IS NULL AND volume_ribu_ton IS NULL
GROUP BY d.nama_negara


SELECT negara_id, tahun
FROM fact_ekspor_negara 
WHERE nilai_juta_usd IS NULL AND volume_ribu_ton IS NOT NULL

SELECT *
FROM fact_ekspor_negara 
WHERE negara_id = 27;
