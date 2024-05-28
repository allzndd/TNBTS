<?php
session_start();

// Periksa apakah pengguna sudah login dengan memeriksa variabel sesi
if (!isset($_SESSION['id_pengguna'])) {
    die(json_encode(['error' => 'User not logged in']));
}

$userId = $_SESSION['id_pengguna'];

// Fungsi untuk mendapatkan data pengguna dari database
function getUser($userId) {
    $conn = new mysqli("localhost", "root", "", "tnbts");

    if ($conn->connect_error) {
        die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
    }

    $sql = "SELECT id, nama_pengguna, surel FROM pengguna WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();

    $user = $result->fetch_assoc();

    $stmt->close();
    $conn->close();

    return json_encode($user);
}

// Fungsi untuk memperbarui data pengguna berdasarkan ID
function updateUser($userId, $namaPengguna, $surel) {
    $conn = new mysqli("localhost", "root", "", "tnbts");

    if ($conn->connect_error) {
        die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
    }

    $sql = "UPDATE pengguna SET nama_pengguna=?, surel=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssi", $namaPengguna, $surel, $userId);

    if ($stmt->execute()) {
        echo json_encode(['message' => 'Data pengguna berhasil diperbarui']);
    } else {
        echo json_encode(['error' => 'Gagal memperbarui data pengguna: ' . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    echo getUser($userId);
    $namaPengguna = $_GET['nama_pengguna'] ?? '';
    $surel = $_GET['surel'] ?? '';
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $namaPengguna = $_POST['nama_pengguna'] ?? '';
    $surel = $_POST['surel'] ?? '';

    updateUser($userId, $namaPengguna, $surel);
}

?>