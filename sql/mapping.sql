-- Tabel mapping nama negara: Inggris (staging_nilai_ekspor) <-> Indonesia (staging_volume_ekspor)
-- nama_negara_id dipakai sebagai nama final di dim_negara.

CREATE TABLE mapping_negara (
    nama_negara_en NVARCHAR(200) NOT NULL PRIMARY KEY,
    nama_negara_id NVARCHAR(200) NOT NULL,
    kawasan NVARCHAR(50) NOT NULL
);

INSERT INTO mapping_negara (nama_negara_en, nama_negara_id, kawasan) VALUES
('AFRICA', 'Afrika', 'Africa'),
('Australia', 'Australia', 'Australia & Oceania'),
('Belgium', 'Belgia', 'Europe'),
('Brunei Darussalam', 'Brunei Darussalam', 'Asia'),
('Cambodia', 'Kamboja', 'Asia'),
('Canada', 'Kanada', 'America'),
('China', 'Tiongkok', 'Asia'),
('Denmark', 'Denmark', 'Europe'),
('East Timor', 'Timor Leste', 'Asia'),
('Finland', 'Finlandia', 'Europe'),
('France', 'Perancis', 'Europe'),
('Germany', 'Jerman', 'Europe'),
('Greece', 'Yunani', 'Europe'),
('Hongkong', 'Hongkong', 'Asia'),
('Italy', 'Italia', 'Europe'),
('Japan', 'Jepang', 'Asia'),
('Korea, Republic of', 'Korea Selatan', 'Asia'),
('Lao People"s Dem. Rep,', 'Laos', 'Asia'),
('Malaysia', 'Malaysia', 'Asia'),
('Mexico', 'Meksiko', 'America'),
('Myanmar', 'Myanmar', 'Asia'),
('Netherlands', 'Belanda', 'Europe'),
('New Zealand', 'Selandia Baru', 'Australia & Oceania'),
('Others', 'Lainnya', 'Asia'),
('Philippines', 'Filipina', 'Asia'),
('Poland', 'Polandia', 'Europe'),
('Rest of America', 'Amerika Lainnya', 'America'),
('Rest of Europe', 'Eropa Lainnya', 'Europe'),
('Rest of European Union', 'Uni Eropa Lainnya', 'Europe'),
('Rest of Oceania', 'Oceania Lainnya', 'Australia & Oceania'),
('Singapore', 'Singapura', 'Asia'),
('Spain', 'Spanyol', 'Europe'),
('Sweden', 'Swedia', 'Europe'),
('Taiwan', 'Taiwan', 'Asia'),
('Thailand', 'Thailand', 'Asia'),
('United States', 'Amerika Serikat', 'America'),
('Vietnam', 'Vietnam', 'Asia');