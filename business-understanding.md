# Business Understanding — Case Study Ekspor Indonesia (Data BPS)

## Latar Belakang

Indonesia sering diasosiasikan sebagai pengekspor komoditas mentah (bahan bakar, hasil
tambang, hasil pertanian). Namun ada narasi kebijakan yang berkembang — terutama lewat
program hilirisasi — bahwa komposisi ekspor nasional sedang bergeser ke arah barang
olahan/manufaktur bernilai tambah lebih tinggi. Case study ini menguji narasi tersebut
memakai data resmi BPS, bukan asumsi.

## Pertanyaan Bisnis

**Bagaimana pangsa (%) golongan "barang buatan pabrik/olahan" terhadap total ekspor
komoditas Indonesia berubah antara tiga periode berikut?**

| Periode | Rentang Tahun | Konteks |
|---|---|---|
| Sebelum COVID | 2017–2019 | Kondisi normal sebelum pandemi |
| Masa COVID | 2020–2022 | Gangguan rantai pasok & permintaan global |
| Setelah COVID | 2023–2025 | Periode pemulihan |

Pertanyaan ini sengaja dibuat dengan 3 titik pembanding (bukan cuma 2 ujung tahun),
supaya pola naik-turun di tengah periode — termasuk kemungkinan penurunan tajam saat
COVID — tidak hilang tertutup rata-rata jangka panjang.

## Audiens

Analisis ini ditujukan untuk **pembaca umum/media**, bukan analis atau pembuat kebijakan.
Konsekuensinya:
- Istilah teknis (kode golongan SITC, nama kolom database) tidak dipakai di narasi akhir
- Nama kategori diterjemahkan ke bahasa awam, misal "barang olahan/manufaktur" alih-alih
  menyebut kode atau nama resmi golongan SITC
- Prioritas pada satu insight utama yang mudah dicerna, bukan laporan teknis lengkap

## Definisi Selesai

Analisis dianggap tuntas jika menghasilkan tiga hal sekaligus:
1. **Tabel ringkas** — pangsa % golongan barang olahan di tiap 3 periode
2. **Grafik tren** — visualisasi perubahan antar periode
3. **Narasi pendek** — 2-3 kalimat yang menjelaskan arah perubahan dan maknanya bagi
   pembaca awam (naik/turun, seberapa besar, apa artinya)

## Batasan Data (Diketahui Sejak Awal)

- Data golongan komoditi SITC hanya tersedia level agregat tinggi (10 golongan besar)
  dan hanya mencakup 2010–2025 — analisis periode "sebelum COVID" tidak bisa mundur
  lebih jauh dari itu.
- Data ini adalah **nilai ekspor per golongan komoditi secara nasional**, bukan per
  negara tujuan — pertanyaan ini tidak bisa dipecah lebih lanjut per negara.
