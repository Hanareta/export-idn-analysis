SELECT 
	f.tahun,
	SUM(CASE WHEN d.kode_sitc IN('6','7','8') THEN f.nilai_juta_usd ELSE 0 END) as total,
	((SUM(CASE WHEN d.kode_sitc IN('6','7','8') THEN f.nilai_juta_usd ELSE 0 END))/ SUM(f.nilai_juta_usd)) * 100 as persen
FROM fact_ekspor_komoditi f
JOIN dim_komoditi d ON d.komoditi_id = f.komoditi_id
GROUP BY f.tahun
ORDER BY f.tahun


--
SELECT 
	d.nama_negara,
	f.tahun,
	f.nilai_juta_usd,
	f.volume_ribu_ton,
	CAST((f.nilai_juta_usd  * 1000) /(NULLIF(f.volume_ribu_ton, 0)) AS DECIMAL(18,2)) as usd_ton
FROM fact_ekspor_negara f
JOIN dim_negara d ON d.negara_id = f.negara_id
