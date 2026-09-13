---
sop_id: LAB-000
title: Pengendalian dokumen dan Daftar Induk SOP
title_en: Document control and the SOP register
kelas: manajemen          # prosedur pengelolaan laboratorium
kode_kegiatan: "[[PNS: Kode Butir Kegiatan untuk prosedur pengelolaan laboratorium]]"
angka_kredit: "[[PNS: Angka Kredit Acuan]]"
laboratorium: "[[PNS: nama laboratorium]]"
revisi: 0
tanggal_terbit: "[[PNS: tanggal terbit]]"
tinjauan_berikutnya: "[[PNS: dua tahun setelah tanggal terbit]]"
pemilik: Kepala Laboratorium
dibuat_oleh: "[[PNS: nama, jabatan]]"
diperiksa_oleh: "[[PNS: nama, jabatan]]"
disetujui_oleh: "[[PNS: nama, jabatan]]"
status: Draf
lang: id
role: draft-scaffold
source_of_record: id
---

# LAB-000 · Pengendalian dokumen dan Daftar Induk SOP

> **Ini adalah kerangka, bukan dokumen.** Naskah ini disusun dalam bahasa Inggris oleh penasihat
> dari luar, kemudian dialihbahasakan ke bahasa Indonesia agar dapat langsung dikoreksi dan ditulis
> ulang oleh jurusan. **Tidak ada yang menandatangani berkas ini.** Versi bahasa Indonesia adalah
> dokumennya; lihat `README.md` bagian 3.
>
> **Prosedur ini ditulis lengkap lebih dahulu**, karena paling ringkas, karena inilah dokumen yang
> pertama ditanyakan dalam sebuah audit, dan karena selama prosedur ini belum ada, prosedur lain
> tidak dapat dinyatakan berlaku.

---

## 1. Tujuan / Purpose

Memastikan setiap prosedur laboratorium memiliki pemilik, nomor revisi, tanggal tinjauan dan lokasi
penyimpanan yang jelas, serta memastikan bahwa kumpulan prosedur yang berlaku pada suatu saat dapat
didaftar.

## 2. Ruang Lingkup / Scope

`[A]` Seluruh prosedur pengoperasian, pemeliharaan dan pengelolaan untuk laboratorium pada program
studi Teknologi Rekayasa Komputer — Laboratorium Informatika, Laboratorium Komputer selama masih
digunakan untuk praktikum IoT, serta laboratorium IoT khusus setelah beroperasi.

**Koreksi:**
`_________________________________________________________________________________`

## 3. Referensi / References

- `[C]` Formulir *Rekaman Kegiatan Pengelolaan Laboratorium*
- `[C]` Kode Butir Kegiatan PLP `II.A.12.b` (pengoperasian) dan `II.A.13.a.b` (pemeliharaan)
- `[?]` `[[PNS: apakah SOP-02.002-BPTI-2020 sudah mengatur pengendalian dokumen di tingkat
  institusi?]]` Bila sudah, prosedur ini merujuk kepadanya dan tidak mengulanginya.

## 4. Pemilik dokumen / Document owner

**Kepala Laboratorium.** `[C]` Untuk Laboratorium Informatika, jabatan ini dipegang oleh
**Handoko, S.Kom., M.Kom**, yang selama ini telah mengesahkan prosedur yang berlaku.

## 5. Tinjauan / Review

Setiap dua tahun, dan segera setelah terjadi perubahan pada rantai pengesahan.

## 6. Prosedur / Procedure

> `[C]` Digambarkan sebagai diagram alir. Lima langkah, satu titik keputusan.

**1. Mengajukan.** Penyusun membuka prosedur baru, atau revisi atas prosedur yang sudah ada.
Prosedur tersebut dicatat dalam daftar induk dengan nomor berikutnya dalam keluarganya dan berstatus
*Draf*.

**2. Memeriksa.** PLP kedua memeriksa prosedur **terhadap peralatan atau kegiatan sebagaimana
benar-benar dilaksanakan** — bukan terhadap versi dokumen sebelumnya. `[A]` Pembedaan inilah yang
membedakan pemeriksaan dari sekadar mengoreksi ketikan.

**3. Mengesahkan.** Kepala Laboratorium mengesahkan. `[C]` Blok *Dibuat → Diperiksa → Disetujui*
diisi dengan nama, jabatan dan tanggal. **Rantai ini sudah berjalan dan tidak diubah.**

*Keputusan: disahkan, atau dikembalikan kepada penyusun?* Yang dikembalikan kembali ke langkah 1
sebagai revisi baru atas draf tersebut; daftar induk mencatat bahwa dokumen itu dikembalikan.

**4. Menerbitkan dan mencatat.** Revisi yang telah disahkan menggantikan revisi sebelumnya dalam
daftar induk. Revisi sebelumnya **tetap disimpan dan ditandai Digantikan**, tidak pernah dihapus.
Daftar induk mencatat nomor revisi, tanggal pengesahan dan tanggal tinjauan berikutnya.

**5. Meninjau sesuai jadwal.** Pada tanggal tinjauan, pemilik dokumen menyatakan prosedur tetap
berlaku tanpa perubahan — **dan pernyataan itu sendiri dicatat, lengkap dengan tanggal** — atau
mengajukan revisi pada langkah 1.

> `[A]` **Langkah 5 adalah langkah yang benar-benar bekerja.** Dokumen yang tidak pernah dibuka sejak
> tahun 2020 dan dokumen yang ditinjau tahun lalu lalu dinyatakan masih benar tampak sama persis dari
> luar. Satu-satunya perbedaan adalah satu baris dalam daftar induk, dan baris itulah yang sebenarnya
> ditanyakan seorang auditor.

**Koreksi:**
`_________________________________________________________________________________`

## 7. Rekaman / Records

| Rekaman / Record | Disimpan oleh / Kept by | Di mana / Where | Masa simpan / Retained |
|---|---|---|---|
| **Daftar Induk SOP** — satu baris per prosedur: nomor, judul, revisi, tanggal pengesahan, pemilik, tinjauan berikutnya, status | Kepala Laboratorium | `[[PNS: di mana]]` | Selamanya |
| Revisi yang digantikan | Kepala Laboratorium | Sama seperti di atas | `[A]` Satu siklus akreditasi |
| Pernyataan bahwa prosedur telah ditinjau dan tidak diubah | Pemilik dokumen | Daftar induk | Sampai tinjauan berikutnya |

### 7.1 Daftar induk itu sendiri

`[A]` **Sembilan kolom, dan tidak perlu lebih dari ini.** Satu lembar kerja sudah memenuhinya
sepenuhnya; demikian pula satu tabel di dalam repositori yang dijelaskan pada
`../R1a-documentation-architecture.md`.

| Nomor | Judul / Title | Kode | Revisi | Tanggal terbit | Pemilik | Tinjauan berikutnya | Status | Catatan |
|---|---|---|---|---|---|---|---|---|
| LAB-000 | Pengendalian dokumen dan Daftar Induk SOP | | 0 | | Kepala Laboratorium | | Draf | |
| IOT-02 | Pembangunan golden image Raspberry Pi dan pendaftarannya, kedua peran | `II.A.12.b` | 0 | | PLP | | Draf | |
| *(sepuluh prosedur yang sudah ada masuk di sini pada revisinya masing-masing)* | | | | | | | | |

> **Sepuluh dokumen yang sudah ada dimasukkan apa adanya.** `[C]` Dokumen-dokumen itu
> mempertahankan revisi dan isinya; yang bertambah hanyalah satu baris, seorang pemilik dan tanggal
> tinjauan. **Tidak ada yang diketik ulang** — mengetik ulang dokumen yang sudah disahkan adalah cara
> kesalahan masuk ke dalam sebuah kumpulan dokumen.

**Koreksi:**
`_________________________________________________________________________________`

## 8. Pengesahan / Approval

**Blok pengesahan adalah milik formulir, bukan milik naskah ini.** Blok tersebut dihasilkan dari
templat, `document-pipeline/templates/SOP-Pengoperasian-Template.dotx`, sehingga setiap prosedur
membawa blok yang sama pada tempat yang sama dan tidak ada dokumen yang dapat menyimpang darinya.
Tidak ada yang ditandatangani di dalam berkas ini.

`[C]` Rantai yang selama ini berlaku di jurusan, tanpa perubahan.

> **Rantai mana yang dicetak pada formulir belum ditetapkan, dan bukan penasihat yang menetapkannya.**
> Dalam kumpulan dokumen terdapat dua. Prosedur peminjaman tahun 2020 menandatangani
> *Dibuat → Diperiksa → Disetujui*. SOP pengoperasian tahun 2025 menandatangani *Verifikator*,
> *Disahkan Oleh*, *Dibuat Oleh*. Templat mencetak bentuk tahun 2025, karena bentuk itulah yang lebih
> baru dan yang sudah digunakan oleh prosedur pengoperasian yang diperluas oleh kumpulan ini. Tercatat
> sebagai pertanyaan terbuka nomor 1 dalam `document-pipeline/glossary.yaml`.
>
> `[[PNS: rantai pengesahan mana yang berlaku untuk prosedur pengelolaan laboratorium yang baru?]]`

---

## Catatan untuk penyusun — hapus ketika dokumen diadopsi

**Mengapa prosedur ini didahulukan.** Prosedur ini tidak menuntut peralatan, tidak menuntut perubahan
jaringan, dan tidak menuntut waktu kerja siapa pun di laboratorium. Prosedur ini dapat ditulis dan
disahkan dalam satu sore, dan begitu ada, setiap prosedur lain dalam daftar induk memiliki tempat
untuk dicatat.

**Satu keputusan yang harus diambil dengan sengaja: di mana daftar induk disimpan.** `[A]` Bila
berupa berkas di komputer satu orang, daftar itu akan hilang. Dua jawaban yang layak adalah sebuah
lokasi bersama yang dapat dibaca seluruh jurusan, atau repositori dalam
`../R1a-documentation-architecture.md`. **Pertanyaan ini harus dijawab ke mana pun usulan
Docs-as-Code bermuara** — daftar induk tetap diperlukan dalam kedua keadaan, dan itulah inti
pertanyaan terbuka nomor 5 dalam dokumen tersebut.

`[A]` **Jangan membuat daftar induk menjadi rumit.** Sembilan kolom, satu baris per prosedur. Setiap
kolom tambahan adalah satu ruas yang harus dipelihara seseorang, dan daftar induk yang tidak
dipelihara lebih buruk daripada tidak ada sama sekali, karena ia keliru dengan penuh keyakinan.
