CREATE TABLE dim_negara(
	negara_id INT IDENTITY(1,1) PRIMARY KEY,
	nama_negara NVARCHAR(100) UNIQUE NOT NULL,
	nama_negara_en NVARCHAR(100),
	kawasan NVARCHAR(100)
)

CREATE TABLE dim_komoditi(
	komoditi_id INT IDENTITY(1,1) PRIMARY KEY,
	kode_sitc NVARCHAR(50) UNIQUE NOT NULL,
	nama_komoditi NVARCHAR(150) NOT NULL
)

CREATE TABLE fact_ekspor_negara(
	negara_id INT NOT NULL,
	tahun INT NOT NULL,
	nilai_juta_usd DECIMAL(19,4),
	volume_ribu_ton DECIMAL(12,2),

	CONSTRAINT FK_negara_id
	FOREIGN KEY (negara_id)
	REFERENCES dim_negara(negara_id),

	CONSTRAINT PK_negara_id_tahun PRIMARY KEY (negara_id, tahun)
)

CREATE TABLE fact_ekspor_komoditi(
	komoditi_id INT NOT NULL,
	tahun INT NOT NULL,
	nilai_juta_usd DECIMAL(19,4),

	CONSTRAINT FK_komoditi_id FOREIGN KEY (komoditi_id) REFERENCES dim_komoditi(komoditi_id),
	CONSTRAINT PK_komoditi_id_tahun PRIMARY KEY (komoditi_id, tahun)
)