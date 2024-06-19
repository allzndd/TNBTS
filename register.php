<?php
// Set header Content-Type sebagai application/json
header('Content-Type: application/json');

// Konfigurasi koneksi ke database
$host = 'localhost';
$user = 'root';
$password = ''; // Ganti dengan password MySQL Anda
$database = 'tnbts';

// Buat koneksi ke database
$connection = mysqli_connect($host, $user, $password, $database);

// Cek koneksi
if (!$connection) {
    http_response_code(500);
    echo json_encode(['error' => 'Connection failed: ' . mysqli_connect_error()]);
    exit();
}

// Baca data dari permintaan JSON
$data = json_decode(file_get_contents('php://input'), true);

// Periksa apakah data sudah diterima
if (isset($data['username']) && isset($data['email']) && isset($data['password'])) {
    // Ambil data dari payload JSON
    $username = $data['username'];
    $email = $data['email'];
    $password = $data['password'];
    $role = 2;

    // Hash kata sandi
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Query untuk menyimpan data pengguna ke dalam tabel pengguna
    $sql = "INSERT INTO pengguna (nama_pengguna, surel, kata_sandi, peran) VALUES ('$username', '$email', '$hashed_password', $role)";

    if (mysqli_query($connection, $sql)) {
        http_response_code(200);
        echo json_encode(['message' => 'Registration successful']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Error: ' . mysqli_error($connection)]);
    }
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Error: Data is not set']);
}

// Tutup koneksi
mysqli_close($connection);
?>