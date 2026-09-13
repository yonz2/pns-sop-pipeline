---
sop_id: LAB-EQP
title: Siklus hidup peralatan — dari pengadaan sampai penghapusan
title_en: Equipment lifecycle
kelas: manajemen          # prosedur pengelolaan laboratorium
kode_kegiatan: "[[PNS: Kode Butir Kegiatan untuk prosedur pengelolaan laboratorium]]"
angka_kredit: "[[PNS: Angka Kredit Acuan]]"
laboratorium: "[[PNS: nama laboratorium]]"
revisi: 0
tanggal_terbit: "[[PNS: tanggal terbit]]"
tinjauan_berikutnya: "[[PNS: dua tahun setelah tanggal terbit]]"
pemilik: PLP
dibuat_oleh: "[[PNS: nama, jabatan]]"
diperiksa_oleh: "[[PNS: nama, jabatan]]"
disetujui_oleh: "[[PNS: nama, jabatan]]"
status: Draf
lang: id
role: draft-scaffold
source_of_record: id
---

# LAB-EQP · Siklus hidup peralatan — dari pengadaan sampai penghapusan

> **Ini adalah kerangka, bukan dokumen.** Naskah ini disusun dalam bahasa Inggris oleh penasihat dari
> luar, kemudian dialihbahasakan ke bahasa Indonesia agar dapat langsung dikoreksi dan ditulis ulang
> oleh jurusan. **Tidak ada yang menandatangani berkas ini.** Versi bahasa Indonesia adalah
> dokumennya; lihat `README.md` bagian 3.
>
> `[C]` dikonfirmasi · `[A]` asumsi, koreksi atau coret · `[?]` sudah ditanyakan, belum dijawab ·
> `[[...]]` ruang kosong yang diisi oleh jurusan.

---

## 1. Tujuan / Purpose

Memastikan setiap peralatan laboratorium tercatat, terklasifikasi, dapat ditelusuri selama digunakan,
dan dipertanggungjawabkan ketika keluar — dari pengadaan sampai penghapusan.

## 2. Ruang Lingkup / Scope

`[C]` Peralatan milik laboratorium: 13–15 Raspberry Pi, 10–15 Arduino, alat ukur, perangkat jaringan
dan komputer kerja. `[C]` **Tidak mencakup papan ESP32 dan ESP8266 milik mahasiswa**, yang merupakan
milik mahasiswa dan tidak pernah menjadi aset laboratorium — pembedaan yang juga penting bagi prosedur
jaringan.

**Koreksi:**
`_________________________________________________________________________________`

## 3. Referensi / References

- `[C]` Prosedur peminjaman dan pengembalian peralatan tanggal 12 Agustus 2020, revisi 0 — **prosedur
  ini menyerapnya pada isinya yang berlaku sekarang**
- `[C]` Prosedur pemeliharaan yang sudah ada, yang berlaku bagi barang yang tercatat di sini
- `[?]` `[[PNS: daftar aset institusi, dan apakah peralatan laboratorium tercantum di dalamnya]]`

## 4. Pemilik dokumen / Document owner

**PLP** — sebuah jabatan, bukan nama orang, sehingga dokumen ini tetap berlaku ketika terjadi
pergantian staf.

## 5. Tinjauan / Review

`[A]` Setiap dua tahun, dan segera setelah terjadi perubahan pada hal yang diatur prosedur ini.
`[[PNS: apakah institusi sudah menetapkan selang waktu tinjauan untuk prosedur laboratorium?]]`

## 6. Prosedur / Procedure

> `[C]` **Kedua bentuk digunakan di jurusan ini: diagram alir dengan percabangan *Ya/Tidak*, atau
> tabel langkah bernomor (*No · Langkah Kerja · Penjelasan*).** Langkah-langkah di bawah adalah isi
> yang harus ditunjukkan oleh salah satu bentuk itu, berurutan. Langkah-langkah ini ditulis sebagai
> prosa di sini semata-mata karena penggambarannya dilakukan setelah langkahnya disepakati, bukan
> sebelumnya.

**1. Mencatat pada saat pengadaan.** Yang dicatat: uraian, nomor seri, tanggal, sumber dana, kategori,
lokasi. `[A]` Dicatat sebelum barang pertama kali digunakan, bukan sesudahnya.

**2. Mengklasifikasi.** `[C]` Jurusan sudah mengklasifikasi peralatan menurut *kategori* — prosedur
yang berlaku menyebut *peralatan kategori 2*. **Gunakan sistem itu; jangan menciptakan sistem baru.**
`[[PNS: definisi kategori 1, 2 dan 3, serta konsekuensi masing-masing]]`

**3. Meminjamkan dan menerima kembali.** `[C]` Prosedur peminjaman tahun 2020 sudah menjelaskan hal
ini. Prosedur itu diserap ke sini, bukan digantikan, dan diagram alirnya digunakan kembali.

**4. Memindahkan.** Antar laboratorium atau ke unit lain: siapa yang menyetujui, dan apa yang
diperbarui.

**5. Menghentikan penggunaan dan menghapus.** Ketika sebuah barang tidak dapat diperbaiki atau sudah
usang: siapa yang memutuskan, apa yang dicatat, dan apa yang terjadi pada barang itu. `[A]` Inilah
langkah yang sama sekali belum tercakup dalam kumpulan dokumen.

**6. Memverifikasi.** `[A]` Pemeriksaan tahunan bahwa daftar sesuai dengan barang yang ada di ruangan.
**Inilah yang membuat daftar itu dapat dipercaya**, dan pekerjaannya setengah hari sekali setahun.

**Koreksi:**
`_________________________________________________________________________________`

## 7. Rekaman / Records

**Apa yang dihasilkan prosedur ini, dan apa yang akan diminta dalam sebuah tinjauan mutu.**

| Rekaman / Record | Disimpan oleh / Kept by | Di mana / Where | Masa simpan / Retained |
|---|---|---|---|
| Daftar peralatan, dengan kategori dan lokasi | PLP | `[[PNS: di mana]]` | Selamanya |
| Rekaman peminjaman dan pengembalian | PLP | `[[PNS: di mana]]` | `[A]` Satu tahun akademik |
| Rekaman pemindahan dan penghapusan | Kepala Laboratorium | `[[PNS: di mana]]` | Selamanya |
| Rekaman verifikasi tahunan | PLP | `[[PNS: di mana]]` | `[A]` Tiga tahun |

**Koreksi:**
`_________________________________________________________________________________`

## 8. Pengesahan / Approval

**Blok pengesahan adalah milik formulir, bukan milik naskah ini.** Blok tersebut dihasilkan dari
templat, `document-pipeline/templates/SOP-Pengoperasian-Template.dotx`, sehingga setiap prosedur
membawa blok yang sama pada tempat yang sama dan tidak ada dokumen yang dapat menyimpang darinya.
Tidak ada yang ditandatangani di dalam berkas ini.

`[C]` Rantai yang selama ini berlaku di jurusan, tanpa perubahan.

> **Rantai mana yang dicetak pada formulir belum ditetapkan, dan bukan penasihat yang menetapkannya.**
> Dalam kumpulan dokumen terdapat dua. Prosedur peminjaman tahun 2020 menandatangani *Dibuat* ke
> *Diperiksa* ke *Disetujui*. SOP pengoperasian tahun 2025 menandatangani *Verifikator*,
> *Disahkan Oleh*, *Dibuat Oleh*. Templat mencetak bentuk tahun 2025, karena bentuk itulah yang lebih
> baru dan yang sudah digunakan oleh prosedur pengoperasian yang diperluas oleh kumpulan ini. Tercatat
> sebagai pertanyaan terbuka nomor 1 dalam `document-pipeline/glossary.yaml`.
>
> `[[PNS: rantai pengesahan mana yang berlaku untuk prosedur pengelolaan laboratorium yang baru?]]`

---

## Catatan untuk penyusun — hapus ketika dokumen diadopsi

**Daftar peralatan adalah keluarannya, bukan prosedurnya.** `[C]` Sebelum penugasan ini tidak tersedia
inventaris peralatan, dan itu sendiri sudah merupakan temuan: penelusuran laboratorium pada 8
September dijadwalkan untuk menghasilkan inventaris pertama, bersama-sama.

`[A]` **Mulailah sebagai tabel dengan enam kolom dan tidak lebih**: nomor, uraian, nomor seri,
kategori, lokasi, status. Kolom dapat ditambahkan kemudian; daftar yang terlalu ambisius untuk
dipelihara tidak akan pernah dipelihara.

**Satu hal yang dimungkinkan prosedur ini dan tidak mungkin tanpanya.** Tanggal pembangunan dan versi
image setiap Raspberry Pi, yang dicatat di sini oleh `IOT-02`, adalah yang mengubah lima belas
perangkat rakitan tangan menjadi sebuah armada.
