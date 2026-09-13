---
sop_id: LAB-NET
title: Jaringan, akun dan pendaftaran perangkat
title_en: Network, accounts and device registration
kelas: manajemen          # prosedur pengelolaan laboratorium
kode_kegiatan: "[[PNS: Kode Butir Kegiatan untuk prosedur pengelolaan laboratorium]]"
angka_kredit: "[[PNS: Angka Kredit Acuan]]"
laboratorium: "[[PNS: nama laboratorium]]"
revisi: 0
tanggal_terbit: "[[PNS: tanggal terbit]]"
tinjauan_berikutnya: "[[PNS: dua tahun setelah tanggal terbit]]"
pemilik: Kepala Laboratorium, bersama UPT TIK
dibuat_oleh: "[[PNS: nama, jabatan]]"
diperiksa_oleh: "[[PNS: nama, jabatan]]"
disetujui_oleh: "[[PNS: nama, jabatan]]"
status: Draf
lang: id
role: draft-scaffold
source_of_record: id
---

# LAB-NET · Jaringan, akun dan pendaftaran perangkat

> **Ini adalah kerangka, bukan dokumen.** Naskah ini disusun dalam bahasa Inggris oleh penasihat dari
> luar, kemudian dialihbahasakan ke bahasa Indonesia agar dapat langsung dikoreksi dan ditulis ulang
> oleh jurusan. **Tidak ada yang menandatangani berkas ini.**
>
> **Prosedur ini ditulis lengkap** karena berada tepat di perbatasan antara program studi dan UPT TIK,
> dan karena di sinilah arsitektur laboratorium jarak jauh yang aman menjadi praktik sehari-hari.
> Ditulis dengan buruk, prosedur ini menjadi daftar alamat yang sudah keliru dalam sebulan; ditulis
> dengan baik, prosedur ini mencatat **siapa memutuskan apa**, dan itu tidak menjadi usang.

---

## 1. Tujuan / Purpose

Menetapkan bagaimana perangkat diterima masuk ke jaringan laboratorium, bagaimana akun diterbitkan dan
dicabut, serta bagaimana perubahan terhadap jaringan laboratorium diajukan, disetujui dan dicatat.

## 2. Ruang Lingkup / Scope

Segmen jaringan laboratorium dan segala sesuatu yang terhubung padanya: perangkat milik laboratorium,
perangkat milik mahasiswa, komputer kerja laboratorium, dan **Gateway** — `[R]` nama yang dipakai
arsitektur untuk mesin virtual yang menjalankan control plane dan layanan pusat laboratorium.

**Tidak mencakup jaringan kampus**, yang dioperasikan oleh UPT TIK. `[C]` UPT TIK adalah unit pusat;
perbatasan pada §6.1 adalah alasan utama keberadaan dokumen ini.

**Koreksi:**
`_________________________________________________________________________________`

## 3. Referensi / References

- `[C]` Jawaban tertulis UPT TIK tanggal 27 Agustus 2026
- Arsitektur laboratorium jarak jauh yang aman — `../R3-architecture-draft.md`
- `[R]` Dokumen arsitektur, yang merupakan **sumber acuan bagi setiap nama perangkat dan nama
  perbatasan yang dipakai di bawah ini** — `HLD.md` §2 untuk kosakatanya dan §3 untuk daftar zone-nya.
  Bila prosedur ini dan dokumen tersebut berbeda, dokumen tersebutlah yang berlaku
- `[C]` Bab 5 *Internet of Things with MQTT* (autentikasi broker dan daftar kendali akses)
- `[?]` `[[PNS: kebijakan keamanan atau penggunaan TI di tingkat institusi, bila ada]]`

## 4. Pemilik dokumen / Document owner

**Kepala Laboratorium**, bersama seorang narahubung yang ditunjuk di UPT TIK.
`[[PNS: nama narahubung UPT TIK dan jabatannya]]`

> `[A]` **Dokumen dengan kepemilikan bersama tidak lazim dan di sini hal itu disengaja.** Tidak ada
> satu pihak pun yang dapat menjalankannya sendiri: laboratorium tidak dapat menyetujui perubahan
> jaringan, dan UPT TIK tidak dapat mengetahui perangkat mana milik kelompok mahasiswa yang mana.
> Pemilik tunggal akan menjadikan salah satu pihak sekadar penonton atas dokumen yang harus diikutinya.

## 5. Tinjauan / Review

Setiap dua tahun, dan segera setelah terjadi perubahan pada segmen jaringan laboratorium atau pada
kebijakan UPT TIK.

## 6. Prosedur / Procedure

### 6.1 Perbatasan, dinyatakan satu kali

`[C]` Kelima pernyataan di bawah ini seluruhnya berasal dari jawaban UPT TIK sendiri tanggal
27 Agustus 2026.

- Laboratorium memiliki **VLAN dan subnet-nya sendiri**, terpisah dari perkantoran.
- Laboratorium memiliki **akses internet keluar** melalui jaringan kampus.
- **Lalu lintas antar-perangkat di dalam segmen sudah disaring**, dan UPT TIK lebih memilih keadaan itu
  dipertahankan.
- **Terowongan keluar yang menetap diizinkan**, dengan syarat perangkatnya terdaftar.
- **Akses masuk adalah sebuah proses, bukan larangan.** Jalur SSH sudah ada sebagai preseden yang
  disetujui, dan kepala UPT TIK adalah pihak yang berwenang menyetujui perubahan jaringan.

> **Kelima kalimat ini adalah bagian paling berharga dari dokumen ini.** Kalimat-kalimat itu ditulis
> dari jawaban UPT TIK sendiri, dan menetapkan dalam satu tempat apa yang harus diperjuangkan dan apa
> yang tidak perlu.

**Koreksi:**
`_________________________________________________________________________________`

#### Nama dari perbatasan ini

`[R]` Kelima pernyataan di atas menggambarkan **satu zone dan satu conduit**, dan menyebutnya demikian
sepadan dengan dua kalimat yang diperlukan. Kedua istilah itu tidak diterjemahkan, karena keduanya
adalah nama dalam standar dan bukan uraian.

- **Zone** adalah segmen jaringan laboratorium beserta seluruh isinya: sekelompok aset yang berbagi
  satu persyaratan keamanan, berada di bawah satu pemilik, dan diatur oleh satu kebijakan. Dalam
  arsitektur, namanya **AIoT Laboratory Zone**. Pemiliknya adalah Kepala Laboratorium; jaringan kampus
  di seberang perbatasan adalah milik UPT TIK, dan merupakan zone lain dengan pemilik lain.
- **Conduit** adalah satu-satunya jalur yang diizinkan melintasi perbatasan itu, dengan aliran data
  yang dibawanya tertulis. Segala hal dalam prosedur ini yang melintasi garis tersebut — akses internet
  keluar, terowongan menetap yang terdaftar, jalur masuk yang disetujui — melintas di sana dan tidak di
  tempat lain. **Jalur yang aliran datanya tidak tertulis bukanlah sebuah conduit**, dan menemukan
  jalur semacam itu adalah sebuah temuan.

> **Mengapa memakai kedua istilah ini, padahal kelima kalimat di atas sudah menyatakannya dalam bahasa
> biasa?** Karena keduanya adalah istilah yang dipakai peninjau dari luar. Keduanya berasal dari
> **IEC 62443-3-2**, standar internasional untuk penilaian risiko keamanan pada sistem otomasi dan
> kendali industri, dan sebuah laboratorium yang dapat menyebutkan zone dan conduit-nya sendiri sudah
> menjawab sebuah pertanyaan sebelum pertanyaan itu diajukan.
>
> `[R]` **Dan batas klaimnya dinyatakan di sini, bukan dibiarkan menjadi anggapan.** Rancangan ini
> menggunakan **kosakata dan model struktural** standar tersebut sebagai disiplin kerja. **Ini bukan
> klaim sertifikasi dan bukan klaim kesesuaian penuh terhadap IEC 62443**, dan klaim semacam itu tidak
> boleh disimpulkan dari dokumen ini — baik dalam sebuah tinjauan, dalam sebuah laporan, maupun dari
> atas panggung.

### 6.2 Empat kelas perangkat, diperlakukan berbeda

`[R]` Nama kelas di bawah ini berasal dari arsitektur, bukan dari prosedur ini. Ditulis sebagai prosa,
nama-nama itu memakai spasi — *IoT Node*, *Area Concentrator*, *Gateway*. Ditulis sebagai nama
kelompok pendaftaran, nama-nama itu memakai tanda hubung — `IoT-Nodes`, `Area-Concentrators`.

| Kelas / Class | Contoh / Examples | Cara diterima masuk | Cara dikelola |
|---|---|---|---|
| **Gateway** | `[C]` Mesin virtual yang telah disediakan, yang menjalankan layanan pengelolaan laboratorium | Didaftarkan ke UPT TIK sebelum tersambung pertama kali | Dimutakhirkan dan dipantau sebagai perangkat terkelola. **Inilah ujung conduit di sisi zone**, dan satu-satunya host yang menerima akses administratif dari luar |
| **Armada terkelola — IoT Node** | `[C]` 13–15 Raspberry Pi laboratorium yang dibangun dalam peran IoT Node, dan 10–15 Arduino | Didaftarkan ke UPT TIK sebelum tersambung pertama kali | Dibangun dari golden image menurut `IOT-02`, didaftarkan, dimutakhirkan terjadwal, dipantau |
| **Armada terkelola — Area Concentrator** | `[R]` Raspberry Pi yang dibangun dalam peran Area Concentrator, satu untuk setiap kelompok sekitar sepuluh mahasiswa | Sama seperti di atas, **dan jaringan access point miliknya didaftarkan bersamanya**, bukan terpisah | Sama seperti di atas — image yang sama, siklus pemutakhiran yang sama. **Sekaligus merupakan sebuah perbatasan tersendiri**: ia menjalankan broker terautentikasi lokal yang dijangkau papan mahasiswa, dan meneruskan bacaannya ke atas |
| **Perangkat daun tak tepercaya** | `[C]` Papan ESP32 dan ESP8266 milik mahasiswa | Tidak didaftarkan satu per satu | Hanya menjangkau **broker lokal pada Area Concentrator-nya sendiri dan tidak lebih**. Tidak ada lalu lintas antar-perangkat. Tidak ada kredensial yang diterbitkan atas nama seseorang |
| **Komputer kerja laboratorium** | Komputer di ruang bersama | `[C]` Dosen dan teknisi memegang hak administratif lokal | `[?]` Berada di bawah kebijakan komputer kerja UPT TIK, bukan prosedur ini |

> **Armada terkelola tidak boleh berisi perangkat keras yang dibawa pulang di dalam tas.** Papan
> mahasiswa adalah perangkat daun tak tepercaya karena rancangan, bukan karena kecurigaan — dan itu
> memang postur yang benar dalam keadaan apa pun. `[A]` Itu juga bahan ajar yang baik: **persis
> begitulah sebuah pabrik memperlakukan laptop seorang kontraktor.**

> `[R]` **Area Concentrator adalah satu-satunya perangkat dalam tabel ini yang sekaligus dua hal**, dan
> perlu dijelaskan mengapa ia mendapat barisnya sendiri alih-alih ikut tenang di dalam armada
> terkelola. Ia adalah perangkat terkelola, dibangun dan dimutakhirkan seperti perangkat lain. Ia
> **sekaligus** merupakan titik tempat sekelompok papan tak tepercaya diterima masuk ke laboratorium
> sama sekali — papan-papan itu tidak pernah menjangkau Gateway, melainkan menjangkau dia, dan dialah
> yang menentukan apa yang diteruskan ke atas. **Perangkat yang sekaligus anggota armada dan
> perbatasan harus didaftarkan, dimutakhirkan dan dicabut sebagai keduanya**, dan itulah sebabnya alur
> 1 dan 5 di bawah menyebutnya secara khusus.

### 6.3 Lima alur

> `[C]` Untuk digambarkan sebagai diagram alir. Masing-masing ringkas.

**1. Mendaftarkan perangkat.**
`[?]` `[[PNS: formulir pendaftaran UPT TIK, siapa yang mengajukan, berapa lama prosesnya]]`
— sudah ditanyakan, dan akan dituntaskan pada 9 September. Yang dicatat di sisi laboratorium: nomor
perangkat dari daftar peralatan, **kelasnya menurut §6.2**, dan pemiliknya.

`[R]` **Sebuah Area Concentrator didaftarkan satu kali, untuk kedua hal yang disandangnya.** Satu entri
sebagai perangkat terkelola pada segmen laboratorium, dan di dalam entri yang sama jaringan access
point yang dilayaninya serta nomor Area yang disandangnya. **Mendaftarkan concentrator tetapi melupakan
access point-nya meninggalkan sebuah jaringan nirkabel di kampus yang tidak dimiliki siapa pun**, dan
itulah kegagalan yang hendak dicegah kalimat ini. Access point-nya merupakan perubahan pada jaringan
laboratorium dan karena itu juga melalui alur 4.

**2. Menerbitkan akun.** Siapa yang boleh mengajukan, siapa yang menyetujui, apa yang boleh
dijangkaunya, dan rekaman apa yang dibuat. `[A]` Akun diterbitkan **per orang dan tidak pernah dipakai
bersama antar kelompok** — akun bersama tidak dapat dicabut dari satu orang saja, dan tidak dapat
menjawab pertanyaan *siapa yang melakukan ini?*

**3. Mencabut akun.** Pada akhir semester, pada perubahan peran, atau atas permintaan.
`[A]` **Inilah langkah yang paling sering hilang dari sebuah prosedur jaringan, dan yang pertama
ditanyakan seorang auditor.** Daftar akun yang tidak pernah dicabut adalah temuan yang paling lazim
dalam tinjauan laboratorium mana pun.

**4. Mengajukan perubahan jaringan.** Diajukan oleh Kepala Laboratorium, disetujui oleh kepala UPT TIK,
dicatat beserta alasan dan tanggalnya. `[C]` Jalur ini sudah ada — prosedur ini menuliskannya, bukan
menciptakannya.

**5. Menghapus perangkat.** Dari daftar peralatan, dari sistem pengelolaan, dan **dari setiap kebijakan
yang menyebutnya.** `[A]` Yang ketiga itulah yang terlupakan, dan kebijakan yang menyebut perangkat
yang sudah tidak ada adalah cara sebuah daftar kendali akses perlahan kehilangan maknanya.

`[R]` **Menghapus sebuah Area Concentrator berarti menghapus sebuah perbatasan, dan perangkat di
belakangnya harus punya tujuan lain.** Sebelum ia ditarik: nyatakan Area Concentrator mana yang akan
dipakai papan-papan yang dilayaninya, atau catat bahwa kelompok tersebut memang dibubarkan. Kemudian
tarik access point-nya melalui alur 4, dan baru setelah itu perangkatnya sendiri. **Perbatasan yang
dihapus selagi masih ada lalu lintas yang bergantung padanya bukanlah penghapusan, melainkan gangguan
di tengah praktikum seseorang.**

**Koreksi:**
`_________________________________________________________________________________`

## 7. Rekaman / Records

| Rekaman / Record | Disimpan oleh / Kept by | Di mana / Where | Masa simpan / Retained |
|---|---|---|---|
| Daftar perangkat terdaftar, dengan kelas dan pemiliknya | PLP | `[[PNS: di mana]]` | Selama perangkat masih digunakan |
| Rekaman penerbitan dan pencabutan akun | Kepala Laboratorium | `[[PNS: di mana]]` | `[A]` Dua tahun |
| Perubahan jaringan yang disetujui, dengan pengaju, penyetuju, alasan dan tanggal | Kepala Laboratorium | `[[PNS: di mana]]` | Selamanya |

## 8. Pengesahan / Approval

**Blok pengesahan adalah milik formulir, bukan milik naskah ini.** Blok tersebut dihasilkan dari
templat, `document-pipeline/templates/SOP-Pengoperasian-Template.dotx`, sehingga setiap prosedur
membawa blok yang sama pada tempat yang sama dan tidak ada dokumen yang dapat menyimpang darinya. Tidak
ada yang ditandatangani di dalam berkas ini.

`[C]` Rantai yang selama ini berlaku di jurusan, tanpa perubahan.

`[A]` Untuk prosedur ini, narahubung UPT TIK sebaiknya turut dicatat sebagai pemeriksa, karena
perbatasan pada bagian 6.1 adalah milik mereka sebagaimana juga milik laboratorium. Blok pada templat
memiliki tiga kolom tanda tangan dan tidak ada yang keempat, sehingga pemeriksa dari UPT TIK dicatat
pada blok pengendalian dokumen di atas, atau bloknya diperlebar. `[[PNS: yang mana?]]`

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

**Tulislah tentang keputusan, bukan tentang alamat.** `[A]` Setiap alamat IP, nomor port dan nama host
di dalam prosedur seperti ini sudah keliru dalam setahun. Setiap kalimat tentang *siapa menyetujui apa*
masih benar lima tahun lagi. Bila sebuah nilai tertentu memang diperlukan, letakkan nilai itu dalam
berkas konfigurasi yang ditunjuk oleh prosedur, dan jaga prosedurnya tetap bersih darinya.

**Satu pertanyaan yang harus dituntaskan pada 9 September, dan ini keputusan rancangan, bukan selera.**
`[?]` `[[PNS: kelompok tersendiri bagi UPT TIK dalam kebijakan akses, atau kelompok administrator
laboratorium?]]` Kelompok tersendiri adalah jawaban yang lebih baik bila mereka ingin dapat menjangkau
perangkat laboratorium tanpa laboratorium dapat menjangkau perangkat mereka.

**Jangan menyajikan §6.1 sebagai temuan.** `[C]` Sebuah laboratorium dengan VLAN sendiri, dengan lalu
lintas antar-perangkat yang sudah disaring dan tanpa paparan akses masuk, adalah titik berangkat yang
sehat. Prosedur ini menambahkan jangkauan dan penatausahaan di atasnya; prosedur ini tidak memperbaiki
apa pun.
