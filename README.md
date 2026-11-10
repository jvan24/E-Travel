# E-Travel

Website e-travel untuk **mencari, memilih, dan memesan** tiket pesawat dan hotel secara online, dengan konsep seperti Traveloka. Proyek tugas kelompok yang dikembangkan dengan model SDLC **Waterfall**.

> **Status:** frontend dan database sudah tersedia. Backend (Node.js + Express) masih dalam pengerjaan.

## Fitur

| Fitur | Pesawat | Hotel |
|-------|:-------:|:-----:|
| Cari dan filter hasil (harga, maskapai/bintang) | Rencana | Rencana |
| Voucher diskon | Rencana | Rencana |
| Pilih kursi | Rencana | - |
| Simpan penerbangan / hotel favorit | Rencana | Rencana |
| Pembayaran simulasi + notifikasi status | Rencana | Rencana |
| E-ticket dan riwayat pesanan | Rencana | Rencana |
| Panel admin (kelola data, voucher, pesanan) | Rencana | Rencana |

Pencarian bisa dipakai tanpa login. Login diminta saat user akan memesan.

## Teknologi

| Lapisan | Teknologi |
|---------|-----------|
| Frontend | HTML, CSS, JavaScript |
| Backend | Node.js, Express *(segera)* |
| Database | MySQL 8 |
| Keamanan | bcrypt (hash password), express-session *(segera)* |

## Struktur Folder

```
E-Travel/
├── Admin/
│   ├── Admindashboard.html   # dashboard admin
│   └── admin.js
├── User/
│   ├── Userdashboard.html    # dashboard user
│   ├── Transaksi.html        # halaman transaksi
│   ├── config.js
│   └── tran.js
├── database/
│   ├── schema.sql      # struktur database (12 tabel)
│   └── seed.sql        # data dummy untuk demo
├── formlogin.html      # halaman login user
├── loginadmin.html     # halaman login admin
├── login.js
├── script.js
└── README.md
```

## Prasyarat

- [MySQL](https://dev.mysql.com/downloads/mysql/) 8.0.16 atau lebih baru
- Klien SQL, misalnya DBeaver atau MySQL Workbench (opsional jika memakai CLI)
- Browser modern (untuk membuka frontend)

## Menjalankan Database

Jalankan **schema.sql lebih dulu**, lalu seed.sql.

**Lewat DBeaver / Workbench:** buka masing-masing file di editor SQL, pastikan koneksi MySQL aktif, lalu jalankan seluruh script (DBeaver: `Alt+X`).

**Lewat terminal:**
```bash
mysql -u root -p < database/schema.sql
mysql -u root -p travel_db < database/seed.sql
```

> **Perhatian:** `schema.sql` diawali `DROP DATABASE IF EXISTS travel_db`, sehingga menjalankannya akan **menghapus seluruh data lama**. Aman untuk development, tetapi jangan dijalankan ulang jika ada data yang ingin dipertahankan.

## Akun Demo

| Peran | Email | Password |
|-------|-------|----------|
| Admin | admin@travel.test | admin123 |
| User | user@travel.test | user123 |

Akun ini hanya untuk pengujian. Password tersimpan sebagai hash bcrypt di database.

### Data Uji Lainnya

| Data | Kegunaan |
|------|----------|
| Voucher `HEMAT50`, `HOTEL20`, `NEWUSER` | Voucher aktif |
| Voucher `EXPIRED1` | Uji voucher kedaluwarsa |
| Voucher `HABIS01` | Uji kuota habis |
| Kursi 1A, 1B, 2C, 3D, 5A, 5B, 7F (semua penerbangan) | Uji kursi yang sudah terisi |

Tanggal penerbangan dibuat relatif terhadap hari ini, sehingga selalu ada jadwal di masa depan.

## Desain Database

Database `travel_db` terdiri dari 12 tabel:

| Tabel | Fungsi |
|-------|--------|
| `users` | Akun user dan admin (kolom `role`) |
| `airports` | Daftar bandara |
| `flights` | Jadwal penerbangan |
| `seats` | Kursi per penerbangan |
| `hotels` | Data hotel |
| `rooms` | Tipe kamar per hotel |
| `vouchers` | Kode promo |
| `bookings` | Pesanan pesawat dan hotel |
| `passengers` | Penumpang / tamu per pesanan |
| `payments` | Pembayaran dan batas waktunya |
| `saved_items` | Penerbangan / hotel yang disimpan |
| `notifications` | Notifikasi status pembayaran |

Catatan: `bookings.item_id` menunjuk ke `flights.id` atau `rooms.id` sesuai kolom `tipe`, sehingga validasinya dilakukan di kode backend.

## Alur Utama

```
Beranda -> Cari (asal, tujuan, tanggal, penumpang) -> Pilih hasil
-> Login (jika belum) -> Isi data (+ pilih kursi untuk pesawat)
-> Voucher (opsional) -> Pembayaran (batas 15 menit)
-> E-ticket + notifikasi   |   Expired -> dibatalkan + notifikasi
```

Setelah login, sistem memeriksa `role`: user diarahkan ke beranda, admin ke dashboard admin.

## Status Pengerjaan

- [x] Perencanaan dan analisis kebutuhan (SDLC)
- [x] Desain: sitemap, flowchart, ERD
- [x] Database: `schema.sql` dan `seed.sql`
- [x] Frontend: halaman login, dashboard user dan admin, halaman transaksi
- [ ] Fase 1: login, cari penerbangan, voucher, pembayaran simulasi, e-ticket
- [ ] Fase 2: pilih kursi, simpan penerbangan, notifikasi pembayaran
- [ ] Fase 3: modul hotel
- [ ] Pengujian dan dokumentasi akhir

## Catatan Pengembangan

- Perubahan struktur tabel dilakukan lewat `database/schema.sql`, jangan hanya diubah langsung di klien SQL, agar database semua anggota tetap sama.
- Setelah `git pull`, jalankan ulang `schema.sql` dan `seed.sql` bila ada perubahan di folder `database/`.
- Satu fitur dikerjakan di satu branch, lalu digabung lewat Pull Request.
