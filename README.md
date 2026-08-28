# Case Study SQL: Struktur & Konsentrasi Ekspor Indonesia (Data BPS)

Case study SQL berbasis data riil dari Badan Pusat Statistik (BPS) Republik Indonesia,
dikerjakan end-to-end di SQL Server / SSMS — dari data mentah hasil unduhan manual,
proses cleaning, desain skema, sampai menjawab 2 pertanyaan bisnis konkret.

## Sumber Data

Diunduh manual dari [bps.go.id](https://www.bps.go.id/en/exim):

| File mentah | Isi | Cakupan tahun |
|---|---|---|
| Value of Exports by Major Country/Region... | Nilai ekspor per negara tujuan (FOB, juta US$) | 2000–2025 |
| Volume Ekspor Menurut Negara/Wilayah... | Volume ekspor per negara tujuan (ribu ton) | 2000–2025 |
| Nilai Ekspor Menurut Golongan Barang SITC | Nilai ekspor per golongan komoditi (juta US$) | 2010–2025 |

## Arsitektur

Staging → langsung ke model data final (dimension + fact table), tanpa layer
perantara terpisah (medallion penuh dipertimbangkan tapi dianggap berlebihan untuk
skala data ini — 3 file CSV, load sekali, tidak bertambah otomatis).

```
staging_nilai_ekspor       (raw, semua kolom teks)
staging_volume_ekspor      (raw, semua kolom teks)
staging_sitc_komoditi      (raw, semua kolom teks)
mapping_negara             (jembatan nama Inggris <-> Indonesia, dipakai sekali
                             saat mengisi dim_negara)
        |
        v
dim_negara (37 baris)              dim_komoditi (10 baris)
fact_ekspor_negara (962 baris)     fact_ekspor_komoditi (160 baris)
```

`fact_ekspor_negara` digabung dari 2 sumber (nilai + volume) yang bahasanya berbeda
(Inggris vs Indonesia) lewat `UNPIVOT` (wide → long) + `FULL JOIN` + `COALESCE`
(supaya kombinasi negara-tahun yang cuma py salah satu data, misal nilai tanpa
volume, tetap masuk dengan NULL di sisi yang kosong, bukan hilang).

## Masalah Data Nyata yang Ditemukan & Cara Ditangani

Ini bagian yang paling banyak memakan waktu di proyek ini, dan sengaja
didokumentasikan karena prosesnya sendiri adalah bagian dari nilai portofolio:

- **BOM (Byte Order Mark)** di awal file CSV membuat wizard import GUI salah baca
  kolom → dipindah ke `BULK INSERT` manual dengan parameter eksplisit.
- **Angka pakai koma sebagai pemisah ribuan** (mis. `10,883.7`) menyebabkan `CAST`
  gagal massal → dibersihkan dengan `REPLACE(kolom, ',', '')` sebelum `TRY_CAST`.
- **Tanda `-` untuk data yang tidak dipublikasikan BPS** (bukan nol) → ditangani
  otomatis oleh `TRY_CAST` (menghasilkan NULL, bukan error yang menghentikan query).
- **Baris header seksi & subtotal tercampur dengan baris negara** (mis. "ASIA",
  "NAFTA", "Total", "Rest of Asia") → diidentifikasi dengan mengecek isi datanya
  (NULL semua vs ada angka), bukan menebak dari nama label — pendekatan ini
  menyelamatkan "AFRICA" (yang terlihat seperti header tapi sebenarnya satu-satunya
  baris data untuk benua itu) dari terhapus keliru.
- **Footnote menempel di nama negara** (mis. `"Tiongkok1)"` di file volume, versus
  `"Tiongkok"` polos di `dim_negara`) menyebabkan seluruh data volume 1 negara besar
  hilang diam-diam dari hasil `JOIN` — ditemukan lewat validasi pola NULL menyeluruh
  di Fase 8 (bukan asumsi "row count cocok berarti data benar"), lalu diperbaiki
  dengan `UPDATE ... FROM ... JOIN` setelah nama dibersihkan pakai `REPLACE`.

## Pertanyaan Bisnis & Temuan

### 1. Tren pangsa barang olahan/manufaktur (2010–2025)

**Definisi "barang olahan"**: kategori SITC 6, 7, 8 (manufaktur murni) — sengaja
tidak memasukkan kategori 5 (bahan kimia, wilayah abu-abu antara mentah/olahan) atau
kategori 9 (tidak dirinci).

Pangsa barang olahan terhadap total ekspor komoditas naik dari ~35% (2010) menjadi
~45% (2025), meski tidak mulus — ada penurunan di beberapa tahun, paling mencolok di
2011 dan 2021-2022, kemungkinan bertepatan dengan lonjakan harga komoditas mentah
global. **Dugaan ini tidak diverifikasi langsung** karena data hanya mencatat nilai,
bukan volume, di level komoditi.

### 2. Konsentrasi ekspor ke 3 negara tujuan terbesar (2010 vs 2025)

Kontribusi 3 negara tujuan terbesar terhadap total ekspor naik dari 35% (2010) ke
40% (2025). Komposisinya sendiri berubah signifikan: Jepang adalah mitra dagang #1
di 2010, tapi turun ke posisi #3 di 2025, disalip Tiongkok (melonjak jadi #1, lebih
dari 2x nilai Amerika Serikat di posisi #2).

*Catatan kualitas data: total ekspor 2025 dari tabel per-negara vs tabel
per-komoditi selisih ~1.187 juta USD (±0.4%), kemungkinan karena kedua publikasi
BPS ini tidak sepenuhnya sinkron waktu revisinya. Selisih di 2010 adalah nol,
jadi ini bukan indikasi kesalahan pengolahan data di proyek ini.*

## Batasan & Peringatan Penting

- **Klasifikasi "barang mentah" vs "barang olahan" di sini hanya menggunakan kode
  SITC 1 digit (0-9), yaitu level paling kasar/agregat dari sistem klasifikasi
  SITC.** Sistem SITC sebenarnya berjenjang jauh lebih detail (2, 3, bahkan 5 digit),
  dan di level yang lebih rinci, satu golongan 1-digit bisa berisi campuran produk
  yang sifatnya sangat berbeda — misalnya kategori "6: Barang buatan pabrik dirinci
  menurut bahan" bisa saja memuat produk olahan sederhana (mis. bahan setengah jadi)
  bersebelahan dengan produk manufaktur bernilai tambah tinggi. Kesimpulan "pergeseran
  ke barang olahan" di proyek ini adalah **gambaran kasar di level agregat tertinggi**,
  bukan analisis rinci per jenis produk — data BPS yang tersedia untuk proyek ini
  tidak memiliki pemecahan ke level SITC yang lebih detail.
- `fact_ekspor_negara` dan `fact_ekspor_komoditi` tidak bisa di-JOIN silang — BPS
  tidak mempublikasikan pemecahan negara × komoditi di tabel-tabel sumber ini.
- Beberapa kombinasi negara-tahun punya nilai NULL genuine (bukan bug) karena BPS
  sendiri tidak mempublikasikan datanya untuk kombinasi tersebut (ditandai `-` di
  sumber aslinya).
- Entitas seperti "Lainnya", "Amerika Lainnya", "Eropa Lainnya", dll adalah
  agregat resmi BPS untuk negara-negara kecil yang tidak dirinci — bukan satu
  negara sungguhan, dan dikeluarkan dari analisis ranking/top-N negara (tapi tetap
  dihitung di angka total, karena nilainya tetap ekspor riil).

## Belum Termasuk di Repo Ini

Dashboard/visualisasi interaktif sengaja belum dibuat pada tahap ini — proyek
berhenti di level query + tabel angka + narasi tertulis.
