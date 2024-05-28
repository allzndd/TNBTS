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
    die(json_encode(['error' => 'Connection failed: ' . mysqli_connect_error()]));
}

// Query untuk mengambil data dari laporan_bencana dengan latitude dan longitude yang valid
$sql = "SELECT id, jenis_bencana, photo AS photo, deskripsi, latitude AS lintang, longitude AS bujur FROM laporan_bencana WHERE latitude != 0 AND longitude != 0";
$result = mysqli_query($connection, $sql);

$locations = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        // Lakukan base64_decode pada foto
        $photo = base64_encode($row['photo']);
        // Tambahkan data ke dalam array $locations
        $locations[] = [
            'id' => $row['id'],
            'jenis_bencana' => $row['jenis_bencana'],
            'deskripsi' => $row['deskripsi'],
            'lintang' => $row['lintang'],
            'bujur' => $row['bujur'],
            'photo' => $photo
        ];
    }
} else {
    // Jika query gagal, kirim pesan error
    echo json_encode(['error' => 'Query failed: ' . mysqli_error($connection)]);
    exit();
}

// Encode array $locations menjadi JSON dan kirim sebagai respons
echo json_encode($locations);

// Tutup koneksi
mysqli_close($connection);

?>
