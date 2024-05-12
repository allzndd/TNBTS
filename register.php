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
$username = $_POST['username'];
$email = $_POST['email'];
$password = $_POST['password'];
$role = 2;

// Hash kata sandi
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Query untuk menyimpan data pengguna ke dalam tabel pengguna
$sql = "INSERT INTO pengguna (nama_pengguna, surel, kata_sandi, peran) VALUES ('$username', '$email', '$hashed_password', $role)";

if (mysqli_query($connection, $sql)) {
    echo 'Registration successful';
} else {
    echo 'Error: ' . $sql . '<br>' . mysqli_error($connection);
}

// Tutup koneksi
mysqli_close($connection);

?>
