# Lariku - GPS Activity Tracker

## Description / Overview
Lariku adalah aplikasi mobile berbasis GPS yang memungkinkan pengguna merekam dan memantau aktivitas olahraga seperti lari, jalan kaki, atau bersepeda. Aplikasi ini dirancang untuk mencatat jalur rute, jarak tempuh, kecepatan rata-rata, dan durasi secara presisi. Selain sebagai pelacak kebugaran pribadi, Lariku hadir dengan fitur komunitas untuk meningkatkan motivasi pengguna melalui sistem pertemanan dan peringkat (leaderboard).

## Demo
![Demo Lariku Placeholder](https://via.placeholder.com/600x300?text=Insert+Lariku+GIF/Image+Here)

**[Lihat Video Demonstrasi Aplikasi](https://drive.google.com/drive/folders/1rLQMjbOV0P7DPACG2LsPKrKAsdY5Qrcz?usp=sharing)**

## Features
* **Real-time GPS Tracking:** Mengaktifkan GPS untuk merekam durasi, jarak tempuh, kecepatan (pace), dan menggambar rute di peta secara real-time saat pengguna berlari.
* **Authentication & Onboarding:** Mendukung proses pendaftaran dan login menggunakan Email/Password serta otentikasi Google Sign-In yang aman.
* **Activity History:** Menyimpan seluruh data lari pengguna ke dalam database, memungkinkan pengguna melihat detail riwayat aktivitas (tanggal, total jarak, durasi, pace rata-rata).
* **Social Connections:** Fitur pertemanan interaktif di mana pengguna dapat mencari, mengirim, menerima, atau menolak permintaan pertemanan.
* **Leaderboard & Rankings:** Menampilkan peringkat jarak lari antar teman untuk menciptakan kompetisi sehat dan memantau progres mingguan/bulanan.

## Tech Stack / Built With
Aplikasi ini dibangun menggunakan kerangka kerja lintas platform modern dan layanan komputasi awan:

**Frontend / Mobile Framework:**
* Flutter (Dart) 
* Provider (State Management)

**Backend & Database:**
* Firebase Authentication (Email/Password & Google Sign-In)
* Cloud Firestore (NoSQL Database untuk menyimpan data user, riwayat aktivitas, dan relasi pertemanan)

**Location & Mapping Services:**
* Google Maps Flutter (Integrasi peta visual)
* Geolocator & Location (Pengambilan titik koordinat GPS)
* Permission Handler (Manajemen izin akses perangkat)

**UI & Animations:**
* Lottie & Animate_do (Animasi antarmuka dinamis)
* Cupertino Icons & Material Design

## Installation
Ikuti langkah-langkah berikut untuk menjalankan proyek ini di lingkungan lokal (pastikan Flutter SDK sudah terpasang):

1. **Clone repositori ini:**
   ```bash
   git clone [https://github.com/ZeroZennn/Lariku.git](https://github.com/ZeroZennn/Lariku.git)
   cd Lariku

```

2. **Unduh seluruh dependensi:**
```bash
flutter pub get

```


3. **Konfigurasi Firebase:**
Pastikan Anda telah mengatur proyek Firebase Anda sendiri dan memasukkan file `google-services.json` (untuk Android) dan `GoogleService-Info.plist` (untuk iOS) ke dalam direktori yang sesuai.
4. **Konfigurasi Google Maps API:**
Tambahkan API Key Google Maps Anda di file konfigurasi Android (`AndroidManifest.xml`) dan iOS (`AppDelegate.swift`).

## Usage

Jalankan aplikasi di emulator atau perangkat fisik menggunakan perintah berikut:

```bash
flutter run

```

## Contributing

Kontribusi selalu dipersilakan! Jika Anda ingin meningkatkan fitur atau memperbaiki *bug*:

1. Fork repositori ini.
2. Buat *branch* fitur Anda (`git checkout -b feature/AmazingFeature`).
3. Lakukan *commit* pada perubahan Anda (`git commit -m 'Add some AmazingFeature'`).
4. *Push* ke *branch* tersebut (`git push origin feature/AmazingFeature`).
5. Buka Pull Request.

## License

Didistribusikan di bawah Lisensi MIT. Lihat file `LICENSE` untuk informasi lebih lanjut.

## Credits / Acknowledgments

Proyek ini dikembangkan oleh **Kelompok 5 (TI 4B - Politeknik Negeri Jakarta)**:

* Muhammad Arya Maulana
* Muhammad Dzaky Fauzan
* Achmad Zikran Maulida
* Yasmeen Almira
* Muhammad Hafiz
* Melvin Okniel Sinaga

Di bawah bimbingan Dosen Pengampu: **Viving Frendiana, S.ST., M.T.**
