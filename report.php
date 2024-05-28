<?php
// Koneksi ke database
$host = 'localhost';
$user = 'root';
$password = ''; // Ganti dengan password MySQL Anda
$database = 'tnbts';

// Buat koneksi
$connection = mysqli_connect($host, $user, $password, $database);

// Periksa koneksi
if (mysqli_connect_errno()) {
    echo 'Koneksi Gagal: ' . mysqli_connect_error();
    exit();
}

// Periksa apakah request method adalah POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data yang diterima dari Flutter
    $description = isset($_POST['description']) ? $_POST['description'] : '';
    $latitude = isset($_POST['latitude']) ? $_POST['latitude'] : '';
    $longitude = isset($_POST['longitude']) ? $_POST['longitude'] : '';
    $disasterType = isset($_POST['disasterType']) ? $_POST['disasterType'] : '';
    $status = isset($_POST['status']) ? $_POST['status'] : '';
    $image = isset($_POST['image']) ? $_POST['image'] : '';

    // Logging untuk debugging
    error_log("Description: $description");
    error_log("Latitude: $latitude");
    error_log("Longitude: $longitude");
    error_log("DisasterType: $disasterType");
    error_log("Status: $status");
    error_log("Image: (length: " . strlen($image) . ")");

    // Gunakan prepared statement untuk mencegah SQL injection
    $stmt = $connection->prepare("INSERT INTO laporan_bencana (jenis_bencana, photo, latitude, longitude, deskripsi, status) VALUES (?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        echo 'Prepare failed: ' . $connection->error;
        exit();
    }

    $stmt->bind_param("ssddss", $disasterType, $image, $latitude, $longitude, $description, $status);

    // Jalankan prepared statement
    if ($stmt->execute()) {
        // Jika berhasil disimpan, kirim pesan sukses
        echo 'success=Data berhasil disimpan';
    } else {
        // Jika terjadi kesalahan, kirim pesan kesalahan
        echo 'error=Execute failed: ' . $stmt->error;
    }

    // Tutup prepared statement dan koneksi database
    $stmt->close();
} else {
    echo 'error=Invalid request method';
}

$connection->close();
?>