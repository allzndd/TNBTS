<?php

// Konfigurasi koneksi ke database
$host = 'localhost';
$user = 'root';
$password = ''; // Ganti dengan password MySQL Anda
$database = 'tnbts';

// Buat koneksi ke database
$connection = mysqli_connect($host, $user, $password, $database);

// Cek koneksi
if (!$connection) {
    die('Connection failed: ' . mysqli_connect_error());
}

// Ambil data dari permintaan POST
$input = json_decode(file_get_contents('php://input'), true);
$usernameOrEmail = $input['username'];
$password = $input['password'];

// Query untuk mencari pengguna berdasarkan nama_pengguna atau surel
$sql = "SELECT * FROM pengguna WHERE nama_pengguna = ? OR surel = ?";
$stmt = mysqli_prepare($connection, $sql);
mysqli_stmt_bind_param($stmt, 'ss', $usernameOrEmail, $usernameOrEmail);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) == 1) {
    $user = mysqli_fetch_assoc($result);
    if (password_verify($password, $user['kata_sandi'])) {
        echo json_encode(array('message' => 'Login successful', 'user' => $user));
    } else {
        echo json_encode(array('message' => 'Invalid password'));
    }
} else {
    echo json_encode(array('message' => 'User not found'));
}

// Tutup koneksi
mysqli_stmt_close($stmt);
mysqli_close($connection);

?>