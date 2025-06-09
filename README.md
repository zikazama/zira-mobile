# Zira Mobile

Aplikasi pasangan dengan teknologi Flutter dan Firebase.

## Fitur

- **Login**: Autentikasi dengan email dan password
- **Dashboard**: Menampilkan durasi hubungan, fitur ciuman, dan sentuhan
- **Kalender**: Menyimpan momen spesial dengan judul, deskripsi, dan foto
- **Alarm**: Pengaturan alarm untuk diri sendiri, pasangan, atau keduanya
- **Pelacak Menstruasi**: Melacak dan memprediksi siklus menstruasi
- **Daftar Tugas**: Mengelola tugas bersama pasangan
- **Perencanaan Anggaran**: Merencanakan target tabungan dan memprediksi waktu pencapaian
- **Pengaturan**: Memperbarui tanggal jadian dan background slider

## Persiapan

1. Pastikan Flutter SDK sudah terinstal
2. Clone repositori ini
3. Jalankan `flutter pub get` untuk menginstal dependensi
4. Buat project Firebase dan tambahkan konfigurasi ke aplikasi
5. Jalankan aplikasi dengan `flutter run`

## Konfigurasi Firebase

Untuk menggunakan Firebase, Anda perlu:

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Tambahkan aplikasi Android dan iOS ke project
3. Unduh file konfigurasi (`google-services.json` untuk Android dan `GoogleService-Info.plist` untuk iOS)
4. Tempatkan file konfigurasi di direktori yang sesuai:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Struktur Proyek

- `lib/models/`: Model data aplikasi
- `lib/screens/`: Layar UI aplikasi
- `lib/services/`: Layanan untuk Firebase dan fitur lainnya
- `lib/providers/`: Provider state management
- `lib/utils/`: Utilitas dan helper
- `lib/widgets/`: Widget yang dapat digunakan kembali

## Dependensi Utama

- Firebase Auth: Autentikasi pengguna
- Cloud Firestore: Database untuk menyimpan data
- Firebase Storage: Penyimpanan file dan gambar
- Firebase Messaging: Notifikasi push
- Provider: State management
- Table Calendar: Widget kalender
- Flutter Local Notifications: Notifikasi lokal
- Vibration: Kontrol getaran perangkat
- Image Picker: Memilih gambar dari galeri