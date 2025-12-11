import 'package:flutter/material.dart';
import 'tambah_program.dart';

// NAMA CLASS SUDAH DIUBAH DI SINI
class ProfilPerusahaan extends StatefulWidget {
  const ProfilPerusahaan({super.key});

  @override
  State<ProfilPerusahaan> createState() => ProfilPerusahaanState();
}

class ProfilPerusahaanState extends State<ProfilPerusahaan> {
  String _logoFileName = "No file chosen";
  String _bannerFileName = "No file chosen";

  // --- PALET WARNA ---
  final Color _primaryBlue = const Color(0xFF0E6586);
  final Color _accentYellow = const Color(0xFFF5C533);
  final Color _lightBlue = const Color(0xFF259CCC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Profil Perusahaan"),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),
            _buildDetailSection(),
            const SizedBox(height: 20),
            _buildMediaSettingsSection(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA INTERAKTIF ---

  void _showImagePicker(BuildContext context, Function(String) onFileSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pilih Sumber Gambar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconBtn(Icons.camera_alt, "Kamera", _primaryBlue, () {
                    Navigator.pop(context);
                    onFileSelected("foto_kamera_baru.jpg");
                    _showSuccessMsg("Gambar diambil dari kamera!");
                  }),
                  _buildIconBtn(
                    Icons.photo_library,
                    "Galeri",
                    _accentYellow,
                    () {
                      Navigator.pop(context);
                      onFileSelected("gambar_dari_galeri.png");
                      _showSuccessMsg("Gambar dipilih dari galeri!");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryBlue,
      ),
    );
  }

  // --- TAMPILAN ---

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("PT. ID Star Technology"),
            accountEmail: const Text("idstar@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.business, size: 30, color: _primaryBlue),
            ),
            decoration: BoxDecoration(color: _primaryBlue),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text("Kelola Program"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahProgram(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: _accentYellow),
            title: Text(
              "Profil Perusahaan",
              style: TextStyle(
                color: _primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: true,
            selectedTileColor: _primaryBlue.withOpacity(0.05),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://via.placeholder.com/800x200.png?text=Banner',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: GestureDetector(
                  onTap: () =>
                      _showSuccessMsg("Fitur ganti foto profil diklik"),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150?text=Logo',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _accentYellow,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            "PT. ID Star Technology",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text("idstar@gmail.com", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showSuccessMsg("Masuk ke mode Edit Profil"),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit Profil"),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryBlue,
              side: BorderSide(color: _primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shadowColor: _lightBlue.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detail Perusahaan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              const Divider(height: 25),
              _InfoRow(
                icon: Icons.location_on,
                label: "Alamat",
                value: "Jl. Muaro Jambi No 34",
                iconColor: _lightBlue,
              ),
              const SizedBox(height: 15),
              _InfoRow(
                icon: Icons.info,
                label: "Deskripsi",
                value:
                    "PT. ID Star Technology adalah perusahaan yang bergerak di bidang teknologi informasi dan komunikasi.",
                iconColor: _lightBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shadowColor: _lightBlue.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pengaturan Media",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              const Divider(height: 25),
              _buildFileUploadUI(
                "Logo Perusahaan",
                "Rekomendasi: 1:1, maks 1MB",
                _logoFileName,
                (file) {
                  setState(() => _logoFileName = file);
                },
              ),
              const SizedBox(height: 20),
              _buildFileUploadUI(
                "Banner Perusahaan",
                "Rekomendasi: 1200x400, maks 2MB",
                _bannerFileName,
                (file) {
                  setState(() => _bannerFileName = file);
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _showSuccessMsg("Semua media berhasil disimpan!"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadUI(
    String label,
    String info,
    String fileName,
    Function(String) onFilePicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _showImagePicker(context, onFilePicked),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _primaryBlue,
                side: BorderSide(color: _lightBlue),
                elevation: 0,
              ),
              child: const Text("Choose File"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fileName.contains("No file")
                      ? Colors.grey
                      : _accentYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(info, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
