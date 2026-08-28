# Guideline Lengkap: Case Study SQL — Ekspor Indonesia (BPS)

Dokumen ini adalah peta jalan dari nol sampai jadi portofolio yang siap dipublikasikan.
Setiap fase dipecah jadi task kecil dengan **checkpoint** (kriteria "sudah benar,
lanjut" yang bisa kamu cek sendiri). Status saat ini ditandai di tiap task.

Legenda status: ✅ Selesai | 🔄 Sedang berjalan | ⬜ Belum dimulai

---

## FASE 0 — Business Understanding
**Tujuan fase:** Tahu persis pertanyaan apa yang mau dijawab sebelum sentuh data.

- [x] ✅ **Task 0.1** — Tentukan topik analisis
  Checkpoint: topik spesifik (bukan "analisis tren" yang umum). *Hasil: pergeseran
  struktur ekspor dari komoditas mentah ke barang olahan.*
- [x] ✅ **Task 0.2** — Tentukan audiens
  Checkpoint: tahu siapa pembaca akhirnya, karena ini menentukan gaya bahasa.
  *Hasil: umum/media — hindari istilah teknis di narasi akhir.*
- [x] ✅ **Task 0.3** — Rumuskan pertanyaan bisnis jadi bentuk terukur
  Checkpoint: pertanyaan harus punya rentang tahun eksplisit dan bisa dijawab 1
  angka/tabel, bukan deskripsi umum.
  *Hasil: pangsa % golongan "barang olahan" di 3 periode — sebelum COVID
  (2017-2019), COVID (2020-2022), setelah COVID (2023-2025).*
- [x] ✅ **Task 0.4** — Tentukan definisi "selesai"
  Checkpoint: tahu bentuk output akhir sebelum mulai bangun apa pun.
  *Hasil: tabel + grafik + narasi pendek.*
- [x] ✅ **Task 0.5** — Tulis semua di atas jadi `business-understanding.md`

**Catatan teknikal:** fase ini tidak butuh SQL sama sekali — murni thinking exercise.
Ini paling sering dilewati orang yang portofolionya biasa-biasa saja: langsung loncat
ke query tanpa tahu kenapa query itu dibuat.

---

## FASE 1 — Persiapan Lingkungan Kerja
**Tujuan fase:** Alat sudah siap sebelum sentuh data sungguhan.

- [x] ✅ **Task 1.1** — Pastikan SQL Server engine + SSMS 22 terinstal dan bisa connect
  Checkpoint: berhasil connect ke `localhost` via Windows Authentication.
- [x] ✅ **Task 1.2** — Buat database kosong (`ekspor_belajar`)
  Checkpoint: database muncul di Object Explorer.

**Catatan praktikal:** SSMS itu client, bukan database engine — connect gagal kalau
SQL Server service belum jalan (cek lewat SQL Server Configuration Manager kalau
connect gagal).

---

## FASE 2 — Desain Skema (Data Modeling)
**Tujuan fase:** Struktur tabel final sudah ditentukan sebelum data masuk.

- [x] ✅ **Task 2.1** — Rancang skema bintang: 2 dimension table + 2 fact table
  Checkpoint: tahu kolom apa saja dan tipe primary/foreign key-nya di atas kertas,
  sebelum nulis `CREATE TABLE`.
- [x] ✅ **Task 2.2** — `CREATE TABLE dim_negara`
  Checkpoint: kolom `negara_id` (PK, identity), `nama_negara` (unique, not null),
  `nama_negara_en`, `kawasan`.
- [x] ✅ **Task 2.3** — `CREATE TABLE dim_komoditi`
  Checkpoint: kolom `komoditi_id` (PK, identity), `kode_sitc` (unique), `nama_komoditi`
  — perhatikan panjang `NVARCHAR`, nama kategori SITC bisa panjang (>50 karakter).
- [x] ✅ **Task 2.4** — `CREATE TABLE fact_ekspor_negara`
  Checkpoint: composite PK (`negara_id`, `tahun`), FK ke `dim_negara`.
- [x] ✅ **Task 2.5** — `CREATE TABLE fact_ekspor_komoditi`
  Checkpoint: composite PK (`komoditi_id`, `tahun`), FK ke `dim_komoditi`.

**Catatan teknikal:** kenapa fact table pakai composite PK, bukan `id` tunggal? Karena
kombinasi (negara, tahun) itu sendiri sudah unik secara alami — 1 negara cuma boleh
punya 1 baris per tahun. Bikin `id` auto-increment terpisah di sini cuma nambah kolom
tanpa guna.

---

## FASE 3 — Bronze Layer: Import Data Mentah
**Tujuan fase:** Data CSV mentah masuk ke database, apa adanya, tanpa dibersihkan dulu.

- [x] ✅ **Task 3.1** — Cek beberapa baris pertama tiap CSV sebelum import
  Checkpoint: tahu di baris ke berapa header sebenarnya dimulai, dan apakah ada BOM
  atau baris judul yang harus dilewati.
- [x] ✅ **Task 3.2** — `CREATE TABLE staging_nilai_ekspor` (semua kolom NVARCHAR)
  Checkpoint: staging table sengaja pakai tipe teks semua — pembersihan tipe data
  dilakukan lewat SQL nanti, bukan saat import.
- [x] ✅ **Task 3.3** — Import `nilai_ekspor_clean.csv` via `BULK INSERT`
  Checkpoint: `SELECT COUNT(*)` = jumlah baris data di CSV asli (56 baris ✅ cocok).
- [x] ✅ **Task 3.4** — Ulangi untuk `staging_volume_ekspor` (58 baris ✅ cocok)
- [x] ✅ **Task 3.5** — Ulangi untuk `staging_sitc` (11 baris ✅ cocok — beda dari total
  baris CSV karena baris kosong & catatan kaki otomatis tersaring, bukan salah import)

**Catatan teknikal (masalah nyata yang kita alami, dan cara diagnosisnya):**
- **BOM (Byte Order Mark)** di awal file bikin wizard salah baca kolom → dicek lewat
  `file <namafile>.csv` di terminal, hasil "UTF-8 with BOM" adalah tandanya.
- **Wizard GUI ("Import Flat File") tidak reliable** untuk file dengan struktur rumit
  (banyak baris header/subtotal) → pindah ke `BULK INSERT` manual supaya semua
  parameter (delimiter, baris awal, encoding) eksplisit tertulis, tidak ditebak wizard.
- **Angka pakai koma sebagai pemisah ribuan (mis. "10,883.7") yang ke-quote CSV**
  bisa bikin `BULK INSERT` dasar salah hitung kolom (karena tidak mengerti tanda
  kutip pembungkus) → solusinya tambahkan `FORMAT = 'CSV', FIELDQUOTE = '"'` di
  parameter `BULK INSERT`, atau bersihkan koma ribuan dari sumber sebelum import.
- **Jumlah baris di staging ≠ jumlah baris di CSV itu wajar**, bukan selalu tanda
  error — cek dulu isinya sebelum panik (lihat kasus AFRICA vs baris header kosong).

---

## FASE 4 — Persiapan Data Cleaning
**Tujuan fase:** Tahu persis apa yang perlu dibuang/disatukan sebelum tulis query cleaning.

- [x] ✅ **Task 4.1** — `SELECT DISTINCT` semua label negara di `staging_nilai_ekspor`
  Checkpoint: dapat daftar lengkap semua label unik.
- [x] ✅ **Task 4.2** — Klasifikasi manual: mana negara/entitas sungguhan, mana
  header/subtotal yang harus dibuang
  Checkpoint: **jangan tebak dari nama label** — cek isi datanya (`SELECT * WHERE
  negara = 'X'`), apakah kolom tahun-nya NULL semua (→ header) atau ada angka
  (→ data sungguhan, meski namanya kedengaran seperti header, contoh: "AFRICA").
- [x] ✅ **Task 4.3** — Buat `mapping_negara` (nama Inggris ↔ Indonesia ↔ kawasan)
  Checkpoint: 37 baris, mencakup semua entitas valid dari Task 4.2.

**Catatan teknikal — daftar final yang harus dieliminasi (15 label):**
`NULL`, `NULL`, footnote UK-EU, footnote Timor Leste-ASEAN, `AMERICA`, `ASEAN2)`,
`ASIA`, `AUSTRALIA & OCEANIA`, catatan sumber data, `NAFTA`, `Note :`, `EUROPE`,
`European Union1)`, **`Rest of Asia`** (header kosong, bukan data), **`Total`**
(baris grand total — kalau lolos, semua `SUM()` per negara jadi salah karena dobel
hitung). Dua yang di-bold ini yang paling sering lolos karena tidak semencolok
"ASIA"/"NAFTA".

⬜ **Task 4.4 (belum)** — Jalankan `mapping_negara.sql`, verifikasi 37 baris masuk.

---

## FASE 5 — Transform: Isi `dim_negara`
**Tujuan fase:** Tabel dimensi negara final terisi, sumbernya staging + mapping.

- ⬜ **Task 5.1** — Tulis `INSERT INTO dim_negara (...) SELECT DISTINCT ... FROM
  staging_nilai_ekspor JOIN mapping_negara ON ... WHERE negara NOT IN (15 label
  eliminasi)`
  Checkpoint: `SELECT COUNT(*) FROM dim_negara` = 37.
- ⬜ **Task 5.2** — Cek tidak ada negara di staging yang gagal ketemu pasangannya di
  `mapping_negara` (pakai `LEFT JOIN ... WHERE mapping_negara.nama_negara_en IS
  NULL` untuk negara yang seharusnya valid)
  Checkpoint: hasil query ini harus 0 baris (kalau ada, berarti ada nama negara yang
  belum termasuk di mapping — biasanya karena perbedaan karakter tersembunyi,
  seperti kasus "Lao People's Dem. Rep").

**Catatan praktikal:** ini task pertama yang benar-benar menggabungkan staging +
mapping — kalau nanti ada error "0 rows inserted" atau jumlahnya kurang dari 37,
kemungkinan besar penyebabnya nama di `WHERE negara NOT IN (...)` tidak persis sama
(spasi ekstra, huruf besar/kecil) dengan yang ada di staging — cek pakai
`SELECT negara, LEN(negara) FROM staging_nilai_ekspor WHERE negara = '...'` untuk
pastikan tidak ada spasi tersembunyi di akhir teks.

---

## FASE 6 — Transform: Isi `fact_ekspor_negara` (Wide → Long)
**Tujuan fase:** Data nilai + volume ekspor per negara per tahun masuk ke fact table.

- ⬜ **Task 6.1** — Pelajari konsep `UNPIVOT` (mengubah kolom-per-tahun jadi
  baris-per-tahun)
  Checkpoint: paham kenapa staging (1 baris = 1 negara, banyak kolom tahun) perlu
  diubah ke bentuk (1 baris = 1 negara + 1 tahun) sebelum bisa masuk fact table.
- ⬜ **Task 6.2** — Tulis `UNPIVOT` untuk `staging_nilai_ekspor` → hasil sementara
  (negara, tahun, nilai_juta_usd)
  Checkpoint: jumlah baris hasil = 37 negara × jumlah tahun (banyak NULL untuk
  data yang memang hilang di sumber, itu wajar).
- ⬜ **Task 6.3** — Ulangi `UNPIVOT` untuk `staging_volume_ekspor`
- ⬜ **Task 6.4** — `INSERT INTO fact_ekspor_negara` — gabungkan hasil 2 UNPIVOT di
  atas via `FULL JOIN` (bukan `INNER JOIN` — supaya negara/tahun yang cuma py
  data nilai atau cuma py data volume tetap masuk, bukan hilang)
  Checkpoint: `SELECT COUNT(*) FROM fact_ekspor_negara` masuk akal (37 negara ×
  ~26 tahun, dikurangi kombinasi yang benar-benar tidak ada datanya sama sekali).
- ⬜ **Task 6.5** — Spot-check: bandingkan 2-3 angka acak di `fact_ekspor_negara`
  dengan angka yang sama di CSV asli (buka manual, cocokkan)
  Checkpoint: harus identik persis, bukan mendekati.

**Catatan teknikal:** kenapa `FULL JOIN`, bukan `INNER JOIN`? Karena sudah kita temukan
di Fase 3 ada kombinasi negara-tahun yang cuma punya data nilai TANPA volume (atau
sebaliknya) — misal "Amerika Lainnya" 2002-2003. Kalau pakai `INNER JOIN`, baris ini
akan **hilang total** dari fact table, padahal datanya sebagian ada dan harus tetap
direkam (dengan NULL di kolom yang memang tidak tersedia).

---

## FASE 7 — Transform: Isi `dim_komoditi` + `fact_ekspor_komoditi`
**Tujuan fase:** Data SITC masuk ke skema final. Lebih sederhana dari Fase 5-6 karena
sudah punya kode kategori jelas (0-9), tidak perlu tabel mapping bahasa.

- ⬜ **Task 7.1** — `INSERT INTO dim_komoditi` dari `staging_sitc`, filter buang baris
  "Jumlah" (total) dan baris kosong
  Checkpoint: `SELECT COUNT(*) FROM dim_komoditi` = 10.
- ⬜ **Task 7.2** — `UNPIVOT` + `INSERT INTO fact_ekspor_komoditi`
  Checkpoint: `SELECT COUNT(*) FROM fact_ekspor_komoditi` = 10 kategori × 16 tahun
  (2010-2025) = 160.
- ⬜ **Task 7.3** — Validasi silang: `SELECT tahun, SUM(nilai_juta_usd) FROM
  fact_ekspor_komoditi GROUP BY tahun` — bandingkan dengan baris "Jumlah" di CSV
  asli untuk tiap tahun
  Checkpoint: harus identik. Kalau beda, kemungkinan ada kategori yang double-insert
  atau ke-skip.

---

## FASE 8 — Validasi Kualitas Data (Menyeluruh)
**Tujuan fase:** Yakin skema final benar sebelum dipakai jawab pertanyaan bisnis.

- ⬜ **Task 8.1** — Cek tidak ada `negara_id`/`komoditi_id` yang orphan (ada di fact
  tapi tidak ada di dim) — seharusnya mustahil kalau FK constraint sudah benar, tapi
  tetap baik dicek eksplisit.
- ⬜ **Task 8.2** — Cek distribusi NULL di `fact_ekspor_negara` — berapa % baris yang
  `nilai_juta_usd` atau `volume_ribu_ton`-nya NULL, apakah polanya masuk akal
  (mis. terkonsentrasi di tahun-tahun awal atau negara kecil tertentu).
- ⬜ **Task 8.3** — Cek tidak ada negara duplikat dengan ejaan beda (mis. "Tiongkok"
  dan "China" muncul sebagai 2 baris terpisah di `dim_negara` — tandanya mapping
  gagal untuk satu varian penulisan).

---

## FASE 9 — Jawab Pertanyaan Bisnis Inti
**Tujuan fase:** Ini tujuan akhir seluruh proyek — jawab pertanyaan dari
`business-understanding.md`.

- ⬜ **Task 9.1** — Tulis query: pangsa % golongan "barang buatan pabrik/olahan"
  (kode SITC 6, dan pertimbangkan juga kode 7 & 8 — mesin & alat pengangkutan,
  berbagai barang buatan pabrik — diskusikan definisi "olahan" versi kamu) terhadap
  total ekspor komoditas, per tahun 2017-2025.
- ⬜ **Task 9.2** — Agregasi ke 3 periode (rata-rata pangsa % per periode: 2017-2019,
  2020-2022, 2023-2025).
- ⬜ **Task 9.3** — Tulis 2-3 kalimat kesimpulan dalam bahasa awam (sesuai audiens
  yang sudah ditentukan di Fase 0) — arah perubahan dan makna praktisnya.

**Catatan praktikal:** ini titik paling penting untuk didiskusikan ulang sebelum
eksekusi — definisi "barang olahan" itu pilihan analitis (SITC 6 saja, atau
gabungan 6+7+8), bukan fakta tunggal. Dokumentasikan pilihanmu dan alasannya di
narasi akhir, supaya pembaca (atau interviewer) tahu itu keputusan sadar.

---

## FASE 10 — Visualisasi
- ⬜ **Task 10.1** — Export hasil Task 9.2 (3 baris: periode + pangsa %) ke Excel atau
  tool visualisasi pilihanmu.
- ⬜ **Task 10.2** — Buat 1 grafik (bar chart atau line chart) yang menunjukkan
  perubahan pangsa % antar 3 periode.

---

## FASE 11 — Dokumentasi Portofolio
- ⬜ **Task 11.1** — Tulis `README.md` versi publik: business understanding (ringkas),
  skema, cara reproduce (cara import data + jalankan query), temuan utama.
- ⬜ **Task 11.2** — Tulis `case-study.md` atau sejenis: pertanyaan tambahan
  (selain pertanyaan inti) dari level dasar-menengah-lanjutan, tiap query disertai
  penjelasan hasil — ini bagian yang mendemonstrasikan breadth kemampuan SQL kamu,
  bukan cuma jawaban 1 pertanyaan inti.
- ⬜ **Task 11.3** — Sertakan catatan keterbatasan data (level agregasi SITC, tidak
  bisa cross negara×komoditi, dll) — jangan disembunyikan, ini nunjukin kejujuran
  analitis.

---

## FASE 12 — Publikasi
- ⬜ **Task 12.1** — Buat repository GitHub baru.
- ⬜ **Task 12.2** — Upload semua file: SQL script (schema, mapping, transform),
  file CSV mentah + hasil cleaning, dokumen (business understanding, README,
  case study), screenshot grafik.
- ⬜ **Task 12.3** — Review akhir: buka README dari sudut pandang orang asing yang
  belum pernah lihat proyek ini — apakah alurnya bisa diikuti tanpa penjelasan
  tambahan darimu secara langsung?

---

## Ringkasan Posisi Saat Ini

Kamu ada di **akhir Fase 4 / awal Fase 5** — staging sudah bersih dan terverifikasi,
tabel mapping sudah dibuat, tinggal jalankan dan mulai isi `dim_negara`.
