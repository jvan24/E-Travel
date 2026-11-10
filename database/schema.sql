-- =====================================================================
--  schema.sql : struktur database Web E-Travel (12 tabel)
--  Jalankan: mysql -u root -p < database/schema.sql
--  Aman dijalankan berulang (database lama dihapus dulu).
--
--  Catatan keputusan:
--  * id angka  -> INT UNSIGNED AUTO_INCREMENT (nomor urut otomatis)
--  * kode      -> dipakai langsung sebagai PK bila sudah unik secara alami
--                 (kode bandara CGK, kode voucher HEMAT50)
--  * uang      -> INT UNSIGNED (rupiah bulat, tanpa desimal)
--  * password  -> VARCHAR(255) karena menyimpan hash bcrypt, bukan teks asli
-- =====================================================================

DROP DATABASE IF EXISTS travel_db;
CREATE DATABASE travel_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE travel_db;

-- ---------------------------------------------------------------------
-- 1. users
-- ---------------------------------------------------------------------
CREATE TABLE users (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama        VARCHAR(100) NOT NULL,
  email       VARCHAR(100) NOT NULL UNIQUE,      -- UNIQUE: satu email satu akun
  password    VARCHAR(255) NOT NULL,             -- hash bcrypt (+-60 karakter)
  role        ENUM('user','admin') NOT NULL DEFAULT 'user',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. airports  (PK = kode IATA 3 huruf, mis. CGK, DPS)
-- ---------------------------------------------------------------------
CREATE TABLE airports (
  kode  CHAR(3) PRIMARY KEY,
  nama  VARCHAR(100) NOT NULL,
  kota  VARCHAR(60)  NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. flights  (asal & tujuan sama-sama mengarah ke airports.kode)
-- ---------------------------------------------------------------------
CREATE TABLE flights (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  kode_flight VARCHAR(10) NOT NULL,              -- mis. GA-402
  maskapai    VARCHAR(50) NOT NULL,
  asal        CHAR(3) NOT NULL,
  tujuan      CHAR(3) NOT NULL,
  berangkat   DATETIME NOT NULL,
  tiba        DATETIME NOT NULL,
  harga       INT UNSIGNED NOT NULL,             -- per orang, rupiah
  CONSTRAINT fk_flights_asal   FOREIGN KEY (asal)   REFERENCES airports(kode),
  CONSTRAINT fk_flights_tujuan FOREIGN KEY (tujuan) REFERENCES airports(kode),
  CONSTRAINT ck_flights_rute   CHECK (asal <> tujuan),
  INDEX idx_flights_cari (asal, tujuan, berangkat)   -- mempercepat pencarian
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. seats  (kursi per penerbangan)
-- ---------------------------------------------------------------------
CREATE TABLE seats (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flight_id   INT UNSIGNED NOT NULL,
  kode_kursi  VARCHAR(4) NOT NULL,               -- mis. 12A
  status      ENUM('available','taken') NOT NULL DEFAULT 'available',
  UNIQUE KEY uq_seat (flight_id, kode_kursi),    -- kursi tidak boleh ganda
  CONSTRAINT fk_seats_flight FOREIGN KEY (flight_id) REFERENCES flights(id)
    ON DELETE CASCADE                            -- hapus flight -> kursi ikut terhapus
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. hotels
-- ---------------------------------------------------------------------
CREATE TABLE hotels (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama         VARCHAR(100) NOT NULL,
  kota         VARCHAR(60)  NOT NULL,
  alamat       VARCHAR(200),
  bintang      TINYINT UNSIGNED NOT NULL DEFAULT 3,
  harga_mulai  INT UNSIGNED NOT NULL,            -- harga per malam terendah
  deskripsi    TEXT,
  INDEX idx_hotels_kota (kota)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. rooms
-- ---------------------------------------------------------------------
CREATE TABLE rooms (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  hotel_id   INT UNSIGNED NOT NULL,
  tipe       VARCHAR(50) NOT NULL,               -- Standard, Deluxe, Suite
  kapasitas  TINYINT UNSIGNED NOT NULL DEFAULT 2,
  harga      INT UNSIGNED NOT NULL,              -- per malam
  stok       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT fk_rooms_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. vouchers  (PK = kode voucher itu sendiri)
-- ---------------------------------------------------------------------
CREATE TABLE vouchers (
  kode           VARCHAR(30) PRIMARY KEY,        -- mis. HEMAT50
  tipe           ENUM('persen','nominal') NOT NULL,
  nilai          INT UNSIGNED NOT NULL,          -- 10 = 10% atau Rp10.000
  maks_diskon    INT UNSIGNED NULL,              -- batas atas utk tipe persen
  min_belanja    INT UNSIGNED NOT NULL DEFAULT 0,
  berlaku_untuk  ENUM('pesawat','hotel','semua') NOT NULL DEFAULT 'semua',
  kuota          INT UNSIGNED NOT NULL,
  terpakai       INT UNSIGNED NOT NULL DEFAULT 0,
  berlaku_sampai DATE NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. bookings
--    tipe + item_id: item_id = flights.id (tipe 'flight') ATAU
--    rooms.id (tipe 'hotel'). Karena menunjuk dua tabel, tidak dibuat FK;
--    validasinya dilakukan di kode backend.
-- ---------------------------------------------------------------------
CREATE TABLE bookings (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  kode_booking  VARCHAR(12) NOT NULL UNIQUE,     -- mis. TRV8K2P9Q
  user_id       INT UNSIGNED NOT NULL,
  tipe          ENUM('flight','hotel') NOT NULL,
  item_id       INT UNSIGNED NOT NULL,
  jumlah        TINYINT UNSIGNED NOT NULL DEFAULT 1,   -- penumpang / kamar
  check_in      DATE NULL,                       -- khusus hotel
  check_out     DATE NULL,                       -- khusus hotel
  voucher_kode  VARCHAR(30) NULL,
  subtotal      INT UNSIGNED NOT NULL,
  diskon        INT UNSIGNED NOT NULL DEFAULT 0,
  total         INT UNSIGNED NOT NULL,
  status        ENUM('pending','paid','expired','cancelled') NOT NULL DEFAULT 'pending',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bookings_user    FOREIGN KEY (user_id)      REFERENCES users(id),
  CONSTRAINT fk_bookings_voucher FOREIGN KEY (voucher_kode) REFERENCES vouchers(kode),
  INDEX idx_bookings_user (user_id, created_at)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. passengers  (penumpang pesawat / tamu hotel)
-- ---------------------------------------------------------------------
CREATE TABLE passengers (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_id  INT UNSIGNED NOT NULL,
  nama        VARCHAR(100) NOT NULL,
  seat_id     INT UNSIGNED NULL,                 -- NULL untuk hotel
  CONSTRAINT fk_pass_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_pass_seat    FOREIGN KEY (seat_id)    REFERENCES seats(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10. payments  (1 booking = 1 pembayaran)
-- ---------------------------------------------------------------------
CREATE TABLE payments (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_id   INT UNSIGNED NOT NULL UNIQUE,     -- UNIQUE = relasi 1-1
  metode       VARCHAR(30) NOT NULL,             -- Transfer, E-Wallet, VA
  status       ENUM('pending','paid','expired') NOT NULL DEFAULT 'pending',
  batas_waktu  DATETIME NOT NULL,                -- dibuat = sekarang + 15 menit
  dibayar_pada DATETIME NULL,
  CONSTRAINT fk_pay_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 11. saved_items  (penerbangan / hotel yang disimpan)
-- ---------------------------------------------------------------------
CREATE TABLE saved_items (
  id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id   INT UNSIGNED NOT NULL,
  tipe      ENUM('flight','hotel') NOT NULL,
  item_id   INT UNSIGNED NOT NULL,
  UNIQUE KEY uq_saved (user_id, tipe, item_id),  -- tidak bisa simpan 2x
  CONSTRAINT fk_saved_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 12. notifications
-- ---------------------------------------------------------------------
CREATE TABLE notifications (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL,
  pesan       VARCHAR(255) NOT NULL,
  dibaca      TINYINT(1) NOT NULL DEFAULT 0,     -- 0 = belum, 1 = sudah
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  INDEX idx_notif_user (user_id, dibaca)
) ENGINE=InnoDB;
