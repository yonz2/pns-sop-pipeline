---
sop_id: LAB-MNT
title: Program pemeliharaan pencegahan dan kalibrasi
title_en: Preventive maintenance and calibration programme
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

# LAB-MNT · Program pemeliharaan pencegahan dan kalibrasi

> **Ini adalah kerangka, bukan dokumen.** Naskah ini disusun dalam bahasa Inggris oleh penasihat dari
> luar, kemudian dialihbahasakan ke bahasa Indonesia agar dapat langsung dikoreksi dan ditulis ulang
> oleh jurusan. **Tidak ada yang menandatangani berkas ini.** Versi bahasa Indonesia adalah
> dokumennya; lihat `README.md` bagian 3.
>
> `[C]` dikonfirmasi · `[A]` asumsi, koreksi atau coret · `[?]` sudah ditanyakan, belum dijawab ·
> `[[...]]` ruang kosong yang diisi oleh jurusan.

---

## 1. Tujuan / Purpose

Menjaga peralatan laboratorium tetap layak untuk pembelajaran melalui pemeliharaan dan kalibrasi
terjadwal, bukan melalui perbaikan setelah terjadi kerusakan.

## 2. Ruang Lingkup / Scope

`[A]` Seluruh peralatan terdaftar dalam kategori yang memerlukan pemeliharaan, dan seluruh alat ukur
yang memerlukan kalibrasi. **Prosedur ini adalah programnya — jadwal dan buktinya. `[C]` Prosedur
pemeliharaan per perangkat yang sudah ada menjadi lampirannya** dan tidak ditulis ulang.

**Koreksi:**
`_________________________________________________________________________________`

## 3. Referensi / References

- `[C]` Tiga prosedur pemeliharaan yang sudah ada: SOP-02.002-BPTI-2020 di tingkat institusi,
  pemeliharaan multimeter digital, dan pemeliharaan access point
- `[?]` `[[PNS: apakah kalibrasi dilakukan sendiri atau oleh lembaga luar, dan dalam pengaturan
  institusi yang mana]]`

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

**1. Jadwal.** Barang mana, kegiatan apa, dengan selang waktu berapa, dan siapa yang mengerjakan.
`[A]` Satu tabel, ditinjau sekali setahun.

**2. Melaksanakan dan mencatat.** Prosedur per perangkat diikuti; penyelesaiannya dicatat pada barang
yang bersangkutan di dalam daftar peralatan. **Rekamannya adalah intinya** — pemeliharaan yang tidak
dicatat tidak dapat dibuktikan pernah dilakukan.

**3. Kalibrasi.** Alat ukur mana, dengan selang waktu berapa, oleh siapa, dan di mana sertifikatnya
disimpan. `[A]` Multimeter adalah kasus yang paling jelas.

**4. Kerusakan di luar jadwal pemeliharaan.** Bagaimana dilaporkan dan apa yang terjadi berikutnya —
penyerahan ke `LAB-INC`.

**5. Pemeliharaan perangkat lunak.** `[A]` **Baru, dan tidak memiliki padanan dalam kumpulan dokumen
yang ada.** Siklus pemutakhiran untuk perangkat terkelola dan layanan platform, dalam jendela waktu
yang diumumkan. `IOT-06` adalah prosedur di tingkat perangkat; ini adalah jadwal yang menaunginya.

**6. Meninjau jadwal.** Setiap tahun, dan setiap kali ada peralatan yang ditambahkan atau dihapus.

**Koreksi:**
`_________________________________________________________________________________`

## 7. Rekaman / Records

**Apa yang dihasilkan prosedur ini, dan apa yang akan diminta dalam sebuah tinjauan mutu.**

| Rekaman / Record | Disimpan oleh / Kept by | Di mana / Where | Masa simpan / Retained |
|---|---|---|---|
| Jadwal pemeliharaan itu sendiri | PLP | `[[PNS: di mana]]` | Versi berlaku |
| Rekaman penyelesaian per barang | PLP | Daftar peralatan | `[A]` Tiga tahun |
| Sertifikat kalibrasi | PLP | `[[PNS: di mana]]` | `[A]` Sampai digantikan, ditambah satu |
| Rekaman jendela pemutakhiran yang diumumkan dan apa yang diterapkan | PLP | `[[PNS: di mana]]` | `[A]` Satu tahun |

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

`[C]` **Prosedur pemeliharaan yang ada bersifat per perangkat. Yang belum ada adalah programnya —
kapan masing-masing dijalankan.** Itulah seluruh sumbangan dokumen ini, dan wujudnya adalah sebuah
tabel.

**Mengenai bagian perangkat lunak, satu kalimat yang layak dipertahankan.** Pemutakhiran yang sudah
diunduh tetapi belum diikuti penyalaan ulang baru diterapkan separuh: kode lama masih berjalan.
`[A]` Armada yang memutakhirkan tanpa pernah menyalakan ulang akan selamanya setengah termutakhirkan,
sebaru apa pun pengakuan pengelola paketnya — itulah sebabnya jendela waktu diumumkan dan mencakup
penyalaan ulang.

`[A]` **Jendela pemeliharaan yang diumumkan adalah bahan ajar sekaligus praktik operasi.** Persis
begitulah sebuah lini produksi menjadwalkan waktu berhentinya sendiri secara terencana, dan mahasiswa
tidak menjumpai gagasan itu di bagian kurikulum mana pun.
