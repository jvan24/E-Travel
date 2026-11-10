-- =====================================================================
--  seed.sql : data dummy untuk demo
--  Jalankan SETELAH schema.sql:
--     mysql -u root -p travel_db < database/seed.sql
--
--  Akun tes:
--     admin@travel.test / admin123   (role admin)
--     user@travel.test  / user123    (role user)
--  Tanggal penerbangan dibuat relatif terhadap hari ini (CURDATE),
--  sehingga selalu ada jadwal di masa depan saat demo.
-- =====================================================================

USE travel_db;

-- ---- users (password = hash bcrypt) ----------------------------------
INSERT INTO users (nama, email, password, role) VALUES
('Administrator', 'admin@travel.test', '$2b$10$X1vWU0Y/GmIqpHBitMBKfuX87w5Il/7Dv5pC/rmnmO.I3RS7X6QIi', 'admin'),
('Budi Santoso',  'user@travel.test',  '$2b$10$B579UXyPO/ymTfVNNFBJm.pHXIRf927PRmyAxJTSNkCL4xsEuMrWO', 'user');

-- ---- airports --------------------------------------------------------
INSERT INTO airports (kode, nama, kota) VALUES
('CGK', 'Soekarno-Hatta International Airport',   'Jakarta'),
('DPS', 'I Gusti Ngurah Rai International Airport','Denpasar (Bali)'),
('SUB', 'Juanda International Airport',           'Surabaya'),
('YIA', 'Yogyakarta International Airport',       'Yogyakarta'),
('BDO', 'Husein Sastranegara Airport',            'Bandung'),
('KNO', 'Kualanamu International Airport',        'Medan'),
('UPG', 'Sultan Hasanuddin International Airport','Makassar'),
('LBJ', 'Komodo Airport',                         'Labuan Bajo');

-- ---- flights ---------------------------------------------------------
INSERT INTO flights (kode_flight, maskapai, asal, tujuan, berangkat, tiba, harga) VALUES
('GA-402', 'Garuda Indonesia', 'CGK', 'DPS', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 3 DAY), '07:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 3 DAY), '09:50:00'), 1450000),
('JT-610', 'Lion Air',         'CGK', 'DPS', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 3 DAY), '10:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 3 DAY), '13:20:00'),  890000),
('QG-731', 'Citilink',         'CGK', 'DPS', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 4 DAY), '15:15:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 4 DAY), '18:05:00'), 1020000),
('GA-208', 'Garuda Indonesia', 'DPS', 'CGK', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 7 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 7 DAY), '08:50:00'), 1480000),
('JT-350', 'Lion Air',         'CGK', 'SUB', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 2 DAY), '06:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 2 DAY), '08:10:00'),  760000),
('QG-820', 'Citilink',         'CGK', 'YIA', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 5 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 5 DAY), '10:25:00'),  720000),
('ID-6510','Batik Air',        'CGK', 'KNO', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 6 DAY), '12:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 6 DAY), '14:30:00'), 1250000),
('GA-650', 'Garuda Indonesia', 'CGK', 'LBJ', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 8 DAY), '06:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 8 DAY), '10:00:00'), 2300000),
('ID-7312','Batik Air',        'SUB', 'DPS', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 4 DAY), '13:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 4 DAY), '14:05:00'),  680000),
('JT-912', 'Lion Air',         'UPG', 'CGK', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 9 DAY), '16:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 9 DAY), '17:50:00'), 1350000);

-- ---- seats: tiap penerbangan 10 baris x 6 kolom (A-F) = 60 kursi ------
INSERT INTO seats (flight_id, kode_kursi)
SELECT f.id, CONCAT(n.baris, k.kolom)
FROM flights f
CROSS JOIN (SELECT 1 AS baris UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
            UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
CROSS JOIN (SELECT 'A' AS kolom UNION SELECT 'B' UNION SELECT 'C'
            UNION SELECT 'D' UNION SELECT 'E' UNION SELECT 'F') k;

-- beberapa kursi sudah terisi, supaya fitur "kursi tidak bisa dipilih" bisa dites
UPDATE seats SET status = 'taken'
WHERE kode_kursi IN ('1A','1B','2C','3D','5A','5B','7F');

-- ---- hotels ----------------------------------------------------------
INSERT INTO hotels (nama, kota, alamat, bintang, harga_mulai, deskripsi) VALUES
('Bali Sunset Resort',   'Denpasar (Bali)', 'Jl. Pantai Kuta No. 12',      4,  850000, 'Resor dekat pantai dengan kolam renang dan sarapan.'),
('Kuta Budget Inn',      'Denpasar (Bali)', 'Jl. Legian No. 45',           2,  320000, 'Penginapan hemat, dekat pusat kuliner.'),
('Malioboro Heritage',   'Yogyakarta',      'Jl. Malioboro No. 88',        4,  600000, 'Hotel bergaya klasik di pusat kota.'),
('Bandung Highland',     'Bandung',         'Jl. Dago Atas No. 7',         3,  450000, 'Pemandangan pegunungan, udara sejuk.'),
('Komodo Bay Hotel',     'Labuan Bajo',     'Jl. Waterfront No. 3',        4,  990000, 'Hotel tepi laut, dekat dermaga wisata.'),
('Jakarta Central Suites','Jakarta',        'Jl. M.H. Thamrin No. 20',     5, 1500000, 'Hotel bisnis bintang lima di pusat kota.');

-- ---- rooms -----------------------------------------------------------
INSERT INTO rooms (hotel_id, tipe, kapasitas, harga, stok) VALUES
(1, 'Standard', 2,  850000, 10),
(1, 'Deluxe',   3, 1250000,  6),
(1, 'Suite',    4, 2400000,  2),
(2, 'Standard', 2,  320000, 12),
(2, 'Family',   4,  550000,  4),
(3, 'Standard', 2,  600000,  8),
(3, 'Deluxe',   3,  900000,  5),
(4, 'Standard', 2,  450000, 10),
(4, 'Deluxe',   3,  700000,  4),
(5, 'Standard', 2,  990000,  7),
(5, 'Suite',    4, 2100000,  2),
(6, 'Deluxe',   2, 1500000,  9),
(6, 'Suite',    4, 3200000,  3);

-- ---- vouchers --------------------------------------------------------
INSERT INTO vouchers (kode, tipe, nilai, maks_diskon, min_belanja, berlaku_untuk, kuota, berlaku_sampai) VALUES
('HEMAT50',  'nominal',  50000, NULL,   500000, 'pesawat', 100, DATE_ADD(CURDATE(), INTERVAL 90 DAY)),
('HOTEL20',  'persen',      20, 200000, 300000, 'hotel',    50, DATE_ADD(CURDATE(), INTERVAL 60 DAY)),
('NEWUSER',  'persen',      10, 100000,      0, 'semua',   200, DATE_ADD(CURDATE(), INTERVAL 180 DAY)),
('EXPIRED1', 'nominal',  25000, NULL,        0, 'semua',    10, DATE_SUB(CURDATE(), INTERVAL 1 DAY)),   -- untuk tes voucher kedaluwarsa
('HABIS01',  'nominal',  25000, NULL,        0, 'semua',     0, DATE_ADD(CURDATE(), INTERVAL 30 DAY));  -- untuk tes kuota habis

-- ---- contoh transaksi untuk user Budi (bookings, passengers, payments) ---
INSERT INTO bookings (kode_booking, user_id, tipe, item_id, jumlah, voucher_kode, subtotal, diskon, total, status) VALUES
('TRV0000001', 2, 'flight', 2, 1, 'HEMAT50', 890000, 50000, 840000, 'paid');

INSERT INTO passengers (booking_id, nama, seat_id)
VALUES (1, 'Budi Santoso', (SELECT id FROM seats WHERE flight_id = 2 AND kode_kursi = '4C'));

UPDATE seats SET status = 'taken' WHERE flight_id = 2 AND kode_kursi = '4C';
UPDATE vouchers SET terpakai = terpakai + 1 WHERE kode = 'HEMAT50';

INSERT INTO payments (booking_id, metode, status, batas_waktu, dibayar_pada)
VALUES (1, 'E-Wallet', 'paid', NOW(), NOW());

INSERT INTO notifications (user_id, pesan, dibaca) VALUES
(2, 'Pembayaran TRV0000001 berhasil. E-ticket sudah tersedia.', 0);

INSERT INTO saved_items (user_id, tipe, item_id) VALUES
(2, 'flight', 1),
(2, 'hotel', 1);
