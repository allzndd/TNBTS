<?php
// Database connection configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tnbts";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

// SQL query to fetch data from laporan_bencana table
$sql = "SELECT id, id_pengguna, jenis_bencana, photo, deskripsi, status, latitude, longitude, dibuat_pada, diperbarui_pada FROM laporan_bencana";
$result = $conn->query($sql);

$laporanBencana = [];

if ($result->num_rows > 0) {
    // Fetch data for each row
    while($row = $result->fetch_assoc()) {
        $laporanBencana[] = [
            'id' => $row['id'],
            'id_pengguna' => $row['id_pengguna'],
            'jenis_bencana' => $row['jenis_bencana'],
            'photo' => base64_encode($row['photo']),
            'deskripsi' => $row['deskripsi'],
            'status' => $row['status'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'dibuat_pada' => $row['dibuat_pada'],
            'diperbarui_pada' => $row['diperbarui_pada']
        ];
    }
    echo json_encode($laporanBencana);
} else {
    echo json_encode(['message' => 'No data found']);
}

$conn->close();
?>
