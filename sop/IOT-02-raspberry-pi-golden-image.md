---
sop_id: IOT-02
title: Pembangunan golden image Raspberry Pi dan pendaftarannya, kedua peran
title_en: Raspberry Pi golden-image build and enrolment, both roles
kelas: peralatan          # prosedur pengoperasian peralatan
kode_kegiatan: II.A.12.b
angka_kredit: 0.32
laboratorium: "[[PNS: nama laboratorium]]"
revisi: 0
tanggal_terbit: "[[PNS: tanggal terbit]]"
tinjauan_berikutnya: "[[PNS: tiga tahun setelah tanggal terbit]]"
pemilik: PLP
dibuat_oleh: "[[PNS: nama, jabatan]]"
diperiksa_oleh: "[[PNS: nama, jabatan]]"
disetujui_oleh: "[[PNS: nama, jabatan]]"
status: Draf
lang: id
role: draft-scaffold
source_of_record: id
---

# IOT-02 · Pembangunan golden image Raspberry Pi dan pendaftarannya, kedua peran

> **Ini adalah kerangka, bukan dokumen.** Naskah ini disusun dalam bahasa Inggris oleh penasihat dari
> luar, kemudian dialihbahasakan ke bahasa Indonesia agar dapat langsung dikoreksi dan ditulis ulang
> oleh jurusan. **Tidak ada yang menandatangani berkas ini.**
>
> **Ini adalah contoh prosedur peralatan, dan tujuannya adalah menunjukkan bahwa tidak ada yang
> berubah.** Ini adalah prosedur pengoperasian peralatan `II.A.12.b` yang biasa, dalam formulir milik
> jurusan sendiri, atas peralatan milik jurusan sendiri, membawa *angka kredit* milik jurusan sendiri.
> Satu-satunya perbedaan dari prosedur access point yang sudah ada adalah peralatan yang dijelaskannya.
>
> **Prosedur ini mencakup kedua peran yang dapat disandang sebuah Raspberry Pi laboratorium**, karena
> pembangunannya adalah pembangunan yang sama. `[R]` Arsitektur menyiapkan sebuah IoT Node dan sebuah
> Area Concentrator dari satu golden image, dan satu-satunya perbedaan adalah kunci pendaftaran yang
> diletakkan pada kartu — yang kemudian menentukan kelompok perangkat itu, dan dengan demikian perannya
> serta konfigurasinya. **Satu image, satu prosedur, satu percabangan pada langkah 2.** Prosedur kedua
> untuk peran kedua akan menjelaskan sembilan langkah yang sama dua kali, dan kedua salinannya akan
> saling menyimpang dalam waktu setahun.

---

## 1. Tujuan / Purpose

Membangun sebuah Raspberry Pi laboratorium sampai pada keadaan yang diketahui dan dapat diulang, dalam
salah satu dari dua peran yang digunakan laboratorium, serta mendaftarkannya ke sistem pengelolaan
laboratorium — sehingga setiap perangkat dapat dibangun ulang tanpa perlu bertanya kepada orang yang
membangunnya terakhir kali.

## 2. Ruang Lingkup / Scope

`[C]` 13–15 Raspberry Pi milik laboratorium, dalam kedua peran yang dibangun untuknya:

| Peran / Role | Apa yang dikerjakannya | Kelompok pendaftaran |
|---|---|---|
| **IoT Node** | Perangkat meja kerja yang menjadi peer jaringan penuh dan mengirimkan bacaannya langsung ke Gateway, tanpa singgah di perantara | `IoT-Nodes` |
| **Area Concentrator** | `[R]` Perangkat yang melayani sekitar sepuluh mahasiswa: access point-nya sendiri, broker lokal terautentikasinya sendiri, dan relai yang meneruskan bacaan mereka ke atas | `Area-Concentrators` |

**Tidak mencakup perangkat milik mahasiswa**, yang tidak pernah menjadi anggota armada — lihat
`LAB-NET` §6.2. **Tidak mencakup Gateway**, yang tidak dibangun dari image ini.

> `[R]` **Nama peran dan nama kelompok berasal dari dokumen arsitektur dan bukan milik prosedur ini
> untuk diciptakan.** Ditulis sebagai prosa, nama-nama itu memakai spasi — *IoT Node*,
> *Area Concentrator*. Ditulis sebagai kelompok pendaftaran atau nama host, nama-nama itu memakai tanda
> hubung — `IoT-Nodes`, `Area-Concentrators`, `Area-Concentrator-01`. Kedua bentuk dilindungi dalam
> `document-pipeline/glossary.yaml`, sehingga tidak ada yang diterjemahkan.

## 3. Referensi / References

- `[C]` Daftar peralatan — `LAB-EQP`
- Pendaftaran perangkat dan penerbitan akun — `LAB-NET` §6.3
- Siklus pemutakhiran yang kemudian menaungi perangkat ini — `IOT-06`, dijadwalkan oleh `LAB-MNT`
- `[C]` Bab 4 *Internet of Things with MQTT*, untuk peran broker yang dijalankan perangkat ini
- `[R]` Dokumen arsitektur, untuk kedua peran dan penamaannya — `HLD.md` §2 dan §3, serta
  `ESP32-Area-Concentrator-HLD.md` §3 dan §6

## 4. Pemilik dokumen / Document owner

**PLP.** `[C]` Kariyanto, S.Kom menyusun prosedur di laboratorium ini dan Adang K., S.T memeriksanya;
`[A]` pembagian yang sama diperkirakan berlaku di sini.

## 5. Tinjauan / Review

`[A]` Setiap tiga tahun, dan segera setelah terjadi perubahan pada image, pada rilis sistem operasi,
pada proses pendaftaran, atau pada kumpulan peran yang dapat disandang sebuah perangkat laboratorium.

## 6. Prosedur / Procedure

> `[A]` **Sembilan langkah, untuk dikonfirmasi dan dikoreksi langsung di meja kerja** pada pelatihan
> tanggal 21 dan 22 September, dan digambarkan sebagai diagram alir sesudahnya. **Jangan mengesahkan
> prosedur ini sebelum dijalankan sekurang-kurangnya dua kali oleh orang yang akan menggunakannya.**

**1. Mendaftarkan perangkat.** Catat dalam daftar peralatan dengan nomor seri dan kategorinya, menurut
`LAB-EQP`. **Sebelum apa pun ditulis ke kartu**, sehingga sebuah perangkat tidak pernah dapat digunakan
tanpa tercatat dalam daftar.

**2. Menulis image yang disetujui, dan memilih peran.** Versi image yang berlaku, dari lokasi yang
diketahui. `[[PNS: di mana image disimpan]]` **Image-nya sama untuk kedua peran.** Yang berbeda adalah
kunci pendaftaran yang diletakkan pada kartu sebelum penyalaan pertama: kunci `IoT-Nodes` atau kunci
`Area-Concentrators`. *Keputusan: perangkat ini dibangun untuk peran yang mana?* `[A]` Catat jawabannya
dalam daftar peralatan pada langkah 1, bukan di sini — perangkat yang perannya hanya diketahui dari
kartu asal pembangunannya tidak dapat diaudit.

**3. Penyalaan pertama.** Tetapkan nama host dari daftar peralatan. **Ubah kredensial bawaan.** `[A]`
Bila langkah ini pernah dilewati, perangkatnya dibangun ulang, bukan diperbaiki.

**4. Mendaftarkan ke UPT TIK.** Menurut `LAB-NET` §6.3.1.

**5. Mendaftarkan ke sistem pengelolaan.** Perangkat menerima identitasnya di sini — **bukan
sebelumnya, dan tidak pernah ditanamkan ke dalam image.** `[A]` Identitas yang ditanamkan ke dalam
image adalah identitas yang dipakai bersama oleh setiap perangkat yang dibangun darinya, yang justru
meniadakan gunanya memiliki identitas.

> `[R]` **Kunci yang dipilih pada langkah 2 menempatkan perangkat pada kelompoknya, dan kelompok itulah
> yang menerapkan sisa konfigurasinya.** Sebuah IoT Node tidak memerlukan apa pun lagi. Sebuah Area
> Concentrator selanjutnya diberi access point-nya, broker lokal terautentikasinya dan relainya oleh
> playbook penyiapan untuk kelompok tersebut, dan diberi nomor Area-nya pada saat yang sama. **Tidak
> ada yang bersifat khas peran dikonfigurasi dengan tangan**, dan itulah sebabnya kedua peran dapat
> berbagi satu prosedur. `[[PNS: nomor Area yang dialokasikan untuk setiap Area Concentrator, setelah
> besaran kelompok diketahui]]`

**6. Memastikan.** Perangkat muncul pada tampilan armada, **dalam kelompok yang dituntut perannya**,
dan melaporkan keadaan sehat. `[A]` Untuk sebuah Area Concentrator, pastikan satu hal lagi: bahwa
access point-nya terlihat dan bahwa sebuah bacaan yang dikirim ke broker lokalnya sampai ke atas.
*Keputusan: bila tidak muncul, atau muncul pada kelompok yang keliru, kembali ke langkah 3.*

**7. Menerapkan tingkat pemutakhiran berjalan dan menyalakan ulang.** **Pemutakhiran tanpa penyalaan
ulang baru separuh pemutakhiran** — kode lama masih berjalan sampai proses yang memakainya berhenti.

**8. Mencatat.** Tanggal pembangunan, versi image, tingkat pemutakhiran **dan peran**, pada perangkat
yang bersangkutan di dalam daftar peralatan. `[A]` **Langkah inilah yang mengubah lima belas perangkat
tersendiri menjadi sebuah armada**, dan wujudnya satu baris tulisan.

**9. Menyerahkan untuk digunakan.**

**Koreksi:**
`_________________________________________________________________________________`

## 7. Rekaman / Records

| Rekaman / Record | Disimpan oleh / Kept by | Di mana / Where | Masa simpan / Retained |
|---|---|---|---|
| Tanggal pembangunan, versi image, tingkat pemutakhiran **dan peran** per perangkat | PLP | Daftar peralatan | Selama perangkat masih digunakan |
| Versi image yang pernah diterbitkan, dengan perubahan pada masing-masing | PLP | `[[PNS: di mana]]` | Selamanya |

## 8. Pengesahan / Approval

**Blok pengesahan adalah milik formulir, bukan milik naskah ini.** Blok tersebut dihasilkan dari
templat, `document-pipeline/templates/SOP-Pengoperasian-Template.dotx`, sehingga setiap prosedur
membawa blok yang sama pada tempat yang sama dan tidak ada dokumen yang dapat menyimpang darinya. Tidak
ada yang ditandatangani di dalam berkas ini.

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

**Mengapa prosedur ini layak berada di daftar.** `[C]` Tiga belas sampai lima belas Raspberry Pi saat
ini dibangun dengan tangan dari sebuah resep. Ketika satu di antaranya rusak saat praktikum, biaya yang
sebenarnya bukanlah kartu memorinya — melainkan satu jam yang dihabiskan untuk membangun ulang, dan
kenyataan bahwa perangkat hasil pembangunan ulang itu sedikit berbeda dari dua belas perangkat lainnya.
`[A]` Langkah 8 meniadakan keduanya, dan wujudnya satu baris dalam daftar.

**Prosedur ini sekaligus merupakan latihan pertama dalam pelatihan staf tanggal 21 dan 22 September.**
`[A]` Menuliskannya dan menjalankannya adalah kegiatan yang sama: teknisi membangun lingkungannya, dan
membangunnya itulah pelatihannya. **Sebuah prosedur yang ditulis di meja kerja oleh orang yang akan
mengikutinya bernilai tiga kali prosedur yang dituliskan untuk mereka.**

`[A]` **Tahan diri untuk menambah langkah.** Sembilan sudah berada di batas yang benar-benar diikuti
dalam praktik. Bila langkah kesepuluh memang diperlukan, tanyakan lebih dahulu apakah langkah itu
sebenarnya milik image — langkah yang dapat ditanamkan ke dalam image adalah langkah yang tidak dapat
terlupakan.

**Peran kedua ditambahkan tanpa langkah kesepuluh, dan itu disengaja.** `[R]` Arsitektur menyiapkan
kedua peran dari satu golden image dan membedakannya semata-mata melalui kunci pendaftaran, sehingga
percabangannya berada pada langkah 2 dan akibatnya diterapkan secara otomatis pada langkah 5.
**Prosedur kedua adalah alternatif yang paling jelas dan hasilnya akan lebih buruk:** prosedur itu akan
mengulang sembilan langkah yang identik, dan kedua salinannya akan saling berbeda dalam waktu setahun.
Bila kelak jurusan memutuskan bahwa kedua peran itu cukup berbeda untuk dipisahkan, ujinya adalah
apakah langkah 1 sampai 4 dan 7 sampai 9 benar-benar sudah menyimpang — bukan apakah dokumennya terasa
panjang.
