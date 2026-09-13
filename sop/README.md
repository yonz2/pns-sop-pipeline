# Draf SOP Laboratorium

*Draf kerja · revisi 0.3 · 13 September 2026 · untuk dikoreksi, bukan untuk disahkan*
*Revisi 0.3: versi bahasa Indonesia menjadi berkas kerja di folder ini; versi bahasa Inggris
dipindahkan ke `EN/` sebagai rujukan selama sesi.*

Satu berkas untuk satu prosedur, sebagaimana diusulkan `R1a-documentation-architecture.md`. Kerangka
yang diwujudkan berkas-berkas ini adalah `R1-SOP-wireframe.md`; model penerjemahan di bawah adalah
`R1b-translation-pipeline.md`.

---

## 1. Dua bahasa, dan mana yang menjadi dokumennya

| Folder | Isi | Untuk siapa |
|---|---|---|
| `R1-drafts/` — folder ini | **Versi bahasa Indonesia.** Inilah berkas yang dikerjakan di ruangan, dicoret, diisi dan ditulis ulang oleh jurusan | Jurusan |
| `R1-drafts/EN/` | **Versi bahasa Inggris.** Rujukan selama sesi saja, agar penasihat dan peserta berbahasa Inggris dapat mengikuti dokumen yang sama | Rujukan |

**Versi bahasa Indonesia adalah dokumennya. Versi bahasa Inggris adalah salinan rujukan.**

Ini bukan basa-basi terhadap jurusan; inilah satu-satunya pengaturan yang berfungsi.

- `[C]` Blok pengesahan — *Dibuat · Diperiksa · Disetujui* — memuat nama, jabatan dan tanggal.
  **Sebuah tanda tangan mengesahkan satu naskah tertentu.** Bila naskah yang ditandatangani adalah
  terjemahan, tidak ada seorang pun yang benar-benar menandatangani dokumen yang berlaku.
- `[C]` Menyusun prosedur menghasilkan *angka kredit* pada formulir nasional. Pengajuannya berbahasa
  Indonesia.
- Orang yang mengikuti prosedur di meja kerja berbahasa Indonesia, dan sebuah prosedur diikuti dalam
  bahasa yang dipakai membacanya.

> **Satu hal yang harus dinyatakan terus terang tentang folder ini.** `[A]` Berkas bahasa Indonesia di
> sini **dialihbahasakan dari kerangka bahasa Inggris oleh penasihat**, dan arah itu adalah kebalikan
> dari arah yang ditetapkan `R1b-translation-pipeline.md` untuk dokumen yang sudah berlaku. Hal itu
> dapat diterima justru karena berkas-berkas ini **belum merupakan dokumen**: tidak ada yang
> menandatanganinya, tidak ada yang menghasilkan *angka kredit* darinya, dan seluruh isinya memang
> disediakan untuk dicoret. **Begitu jurusan menuliskan versinya sendiri, arah itu berbalik dan tidak
> pernah berbalik kembali:** bahasa Indonesia menjadi sumber acuan, dan bahasa Inggris dihasilkan
> darinya.

---

## 2. Apa berkas-berkas ini, dan apa yang bukan

**Semuanya adalah kerangka yang disusun oleh penasihat dari luar, untuk dikoreksi dan kemudian ditulis
ulang oleh jurusan.** Berkas ini bukan dokumennya. Berkas ini bukan terjemahan dari dokumen mana pun.
Tidak ada yang menandatanganinya.

Tiga dari sebelas berkas memuat naskah prosedur sebagai contoh yang dikerjakan penuh — `LAB-000`,
`LAB-NET` dan `IOT-02`. Sisanya memuat strukturnya, rekaman yang harus dihasilkan setiap prosedur, dan
uraian tentang apa yang dinyatakan oleh versi yang baik dari setiap bagian. Ruang kosongnya disengaja.

| Tanda | Arti |
|---|---|
| `[C]` | Dikonfirmasi jurusan secara tertulis sebelum 1 September 2026 |
| `[R]` | Dari implementasi rujukan atau dokumen arsitektur |
| `[A]` | **Asumsi penasihat. Bukan fakta. Koreksi atau coret** |
| `[?]` | Sudah ditanyakan dan belum dijawab |
| `[[...]]` | Ruang kosong menunggu nilai yang dipegang jurusan |

---

## 3. Daftar berkas

| Berkas | Nomor | Keluarga (`kelas`) | Keadaan |
|---|---|---|---|
| `LAB-000-document-control.md` | LAB-000 | `manajemen` · pengelolaan | **Contoh penuh, terisi** |
| `LAB-ACC-access-authorisation.md` | LAB-ACC | `manajemen` · pengelolaan | Struktur saja |
| `LAB-SAF-safety-emergency.md` | LAB-SAF | `manajemen` · pengelolaan | Struktur saja |
| `LAB-EQP-equipment-lifecycle.md` | LAB-EQP | `manajemen` · pengelolaan | Struktur saja |
| `LAB-MNT-maintenance-calibration.md` | LAB-MNT | `manajemen` · pengelolaan | Struktur saja |
| `LAB-PRC-practicum-operation.md` | LAB-PRC | `manajemen` · pengelolaan | Struktur saja |
| `LAB-NET-network-accounts.md` | LAB-NET | `manajemen` · pengelolaan | **Contoh penuh, terisi** |
| `LAB-CMP-competence-induction.md` | LAB-CMP | `manajemen` · pengelolaan | Struktur saja |
| `LAB-INC-incident-change.md` | LAB-INC | `manajemen` · pengelolaan | Struktur saja |
| `IOT-02-raspberry-pi-golden-image.md` | IOT-02 | `peralatan` · pengoperasian | **Contoh penuh, terisi** |

> **Kunci front matter berubah pada 13 September, dari `tier` menjadi `kelas`.** Arsitektur
> laboratorium ini memakai *tier* untuk kedudukan kepercayaan sebuah perangkat di dalam sebuah
> security zone, dan satu kata dengan dua makna di dalam satu kumpulan dokumen adalah cacat yang tinggal
> menunggu ditemukan orang lain. Tidak ada bagian dari perender yang membaca kunci lama, sehingga
> perubahan ini berbiaya satu baris per berkas. Tercatat sebagai pertanyaan terbuka nomor 7 dalam
> `document-pipeline/glossary.yaml`.

---

## 4. Kosakata tetap bersifat dwibahasa menurut konstruksinya

**Kosakata tetap dokumen-dokumen ini bersifat dwibahasa di dalam templat itu sendiri dan sama sekali
tidak pernah sampai ke penerjemah.** Judul bagian, nama ruas formulir, blok pengesahan dan kode butir
kegiatan merupakan himpunan tertutup berisi kira-kira enam puluh istilah. Semuanya ditulis satu kali,
sebagai glosarium, dan ditampilkan berdampingan dalam kedua bahasa:

> `## 1. Tujuan / Purpose`

Hanya **prosa isi** — apa yang sebenarnya dinyatakan sebuah prosedur — yang diterjemahkan. Satu
keputusan itu saja meniadakan seluruh golongan kegagalan yang di dalamnya sebuah mesin dengan penuh
niat baik mengganti nama *Kode Butir Kegiatan* menjadi sesuatu yang tidak dapat ditemukan seorang
auditor.

`[R]` **Kosakata arsitektur juga dilindungi dan tidak diterjemahkan** — *Gateway*, *IoT Node*,
*Area Concentrator*, *zone*, *conduit*. Semuanya adalah nama, bukan uraian, dan sumber acuannya adalah
dokumen arsitektur.
`[[PNS: padanan bahasa Inggris yang dikehendaki jurusan untuk setiap ruas formulir]]` Beberapa di
antaranya merupakan istilah teknis dalam sistem PLP dan tidak boleh diciptakan oleh orang luar.

---

## 5. Struktur bagian, dan mengapa strukturnya milik jurusan

`[C]` Setiap berkas menggunakan struktur milik jurusan sendiri, diambil dari sepuluh dokumen SOP yang
diserahkan pada 26 Agustus: pita kepala *Rekaman Kegiatan Pengelolaan Laboratorium*, lalu *Tujuan ·
Ruang Lingkup · Referensi · Prosedur*, dan sebuah blok pengesahan.

**Tiga bagian ditambahkan, dan ketiganya adalah seluruh lapisan pengelolaan itu**: pemilik dokumen,
selang waktu tinjauan, dan rekaman yang dihasilkan prosedur. Selebihnya tidak berubah.

**Dua hal dinyatakan terlalu tegas ketika berkas ini pertama kali ditulis, dan dikoreksi di sini.**
Keduanya digeneralisasi dari sebagian kumpulan dokumen, bukan dari keseluruhannya.

- **Rantai pengesahan — ada dua.** Prosedur peminjaman tahun 2020 menandatangani *Dibuat* ke
  *Diperiksa* ke *Disetujui*. SOP pengoperasian tahun 2025 menandatangani *Verifikator*,
  *Disahkan Oleh*, *Dibuat Oleh*. Mana yang berlaku bagi prosedur pengelolaan laboratorium yang baru
  adalah pertanyaan terbuka nomor 1 dalam `document-pipeline/glossary.yaml`, dan bagian 8 setiap berkas
  di bawah kini merujuk pada blok milik templat, bukan memuat tabel pengesahannya sendiri.
- **Cara sebuah prosedur digambarkan — kedua bentuk dipakai.** Beberapa prosedur berupa diagram alir
  dengan percabangan *Ya/Tidak*; prosedur Tang Krimping berupa tabel langkah tiga kolom
  (*No · Langkah Kerja · Penjelasan*). Gunakan yang sesuai dengan prosedurnya: pekerjaan yang lurus
  lebih jelas sebagai tabel, yang bercabang lebih jelas sebagai diagram alir.

---

## 6. Cara bekerja dengan sebuah berkas di folder ini

1. **Bacalah dan coret yang salah.** Setiap `[A]` adalah dugaan. Sumbangan tercepat yang mungkin
   diberikan adalah satu coretan pada salah satunya.
2. **Isilah sebuah ruang kosong, atau nyatakan bahwa nilainya tidak ada.** Ruang kosong
   `[[PNS: ...]]` adalah nilai yang dipegang jurusan. *"Hal itu tidak kami catat"* adalah jawaban yang
   lengkap dan berguna — dalam sebagian besar kasus, justru itulah yang hendak diperbaiki oleh prosedur
   yang sedang disusun.
3. **Kemudian tulislah versi jurusan sendiri**, dalam formulir milik jurusan, pada sesi penyusunan
   tanggal 14, 18 dan 22 September. Versi itulah dokumennya.

---

*Kerangka dan daftar: `../R1-SOP-wireframe.md` · Metode penyusunan:
`../R1a-documentation-architecture.md` · Penerjemahan: `../R1b-translation-pipeline.md` ·
Versi bahasa Inggris: `EN/`*
