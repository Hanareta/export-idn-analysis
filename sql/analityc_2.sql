--
SELECT TOP 3
	d.nama_negara,
	f.tahun,
	f.nilai_juta_usd,
	f.volume_ribu_ton
FROM fact_ekspor_negara f
JOIN dim_negara d ON f.negara_id = d.negara_id
WHERE f.tahun = 2025 AND d.nama_negara NOT LIKE '%Lainnya'
ORDER BY f.nilai_juta_usd DESC

WITH ranking_negara AS (
	SELECT 
		d.nama_negara,
		f.tahun,
		f.nilai_juta_usd,
		RANK() OVER (PARTITION BY f.tahun ORDER BY nilai_juta_usd DESC) as peringkat
	FROM fact_ekspor_negara f
	JOIN dim_negara d ON f.negara_id = d.negara_id
	WHERE d.nama_negara NOT LIKE '%Lainnya' 
		AND	f.tahun IN( 2010, 2025)
),

top3 AS (
	SELECT
		tahun,
		SUM(nilai_juta_usd) as total_top3
	FROM ranking_negara
	WHERE peringkat <=3
	GROUP BY tahun
),

total_semua AS (
	SELECT
		tahun,
		SUM(nilai_juta_usd) as total_semua
	FROM fact_ekspor_negara
	WHERE tahun IN (2010, 2025)
	GROUP BY tahun
)
SELECT 
	t3.tahun,
	t3.total_top3,
	ts.total_semua,
	(t3.total_top3 / ts.total_semua) * 100 as persen_konsentrasi
FROM top3 t3
JOIN total_semua ts ON ts.tahun = t3.tahun



WITH ranking_negara AS (
    SELECT 
        d.nama_negara,
        f.tahun,
        f.nilai_juta_usd,
        RANK() OVER (PARTITION BY f.tahun ORDER BY f.nilai_juta_usd DESC) AS peringkat
    FROM fact_ekspor_negara f
    JOIN dim_negara d ON f.negara_id = d.negara_id
    WHERE d.nama_negara NOT LIKE '%Lainnya'
      AND f.tahun IN (2010, 2025)
)
SELECT tahun, peringkat, nama_negara, nilai_juta_usd
FROM ranking_negara
WHERE peringkat <= 3
ORDER BY tahun, peringkat;


SELECT 
    n.tahun,
    n.total_negara,
    k.total_komoditi,
    n.total_negara - k.total_komoditi AS selisih
FROM (
    SELECT tahun, SUM(nilai_juta_usd) AS total_negara
    FROM fact_ekspor_negara
    WHERE tahun IN (2010, 2025)
    GROUP BY tahun
) n
JOIN (
    SELECT tahun, SUM(nilai_juta_usd) AS total_komoditi
    FROM fact_ekspor_komoditi
    WHERE tahun IN (2010, 2025)
    GROUP BY tahun
) k ON k.tahun = n.tahun;

