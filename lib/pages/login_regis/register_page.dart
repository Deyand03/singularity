import 'package:flutter/material.dart';
import 'package:singularity/utility/supabase.client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  // Account Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Biodata Controllers
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _universitasController = TextEditingController();
  final _noHpController = TextEditingController();

  // Birth Info Controllers (NEW)
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController =
      TextEditingController(); // Buat nampilin teks tanggal
  DateTime? _selectedDate; // Buat nyimpen objek tanggal asli

  // Gender State
  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  final Color _primaryColor = const Color(0xFF19A7CE);
  final Color _lightColor = const Color(0xFF28A3CF);

  // --- LOGIC DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Default kira-kira umur 18 thn
      firstDate: DateTime(1970), // Batas paling tua
      lastDate: DateTime.now(), // Batas hari ini
      builder: (context, child) {
        // Custom warna kalender biar senada sama tema
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format jadi YYYY-MM-DD buat ditampilkan di text field
        _tanggalLahirController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- LOGIC REGISTER ---
  Future<void> _handleRegister() async {
    // 1. Validasi Input Dasar
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _nimController.text.isEmpty ||
        _selectedGender == null ||
        _tempatLahirController.text.isEmpty || // Cek Tempat Lahir
        _selectedDate == null) {
      // Cek Tanggal Lahir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data wajib!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password konfirmasi tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Bersihkan email dari spasi bandel
    final cleanEmail = _emailController.text.trim();

    try {
      // 2. DAFTAR AUTH (Buat Akun Login)
      final authResponse = await supabase.auth.signUp(
        email: cleanEmail,
        password: _passwordController.text,
        data: {
          'role': 'mahasiswa', // Metadata buat Trigger public.users
          'full_name': _namaController.text,
        },
      );

      final user = authResponse.user;

      if (user != null) {
        // 3. SIMPAN BIODATA LENGKAP KE TABEL 'mahasiswa'
        await supabase.from('mahasiswa').insert({
          'user_id': user.id, // Sambungkan dengan ID Auth
          'nama': _namaController.text,
          'nim': _nimController.text,
          'jurusan': _jurusanController.text,
          'universitas': _universitasController.text,
          'no_hp': _noHpController.text,
          'gender': _selectedGender,
          'tempat_lahir': _tempatLahirController.text,
          'tanggal_lahir': _selectedDate!
              .toIso8601String(), // Simpan format ISO ke DB
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Berhasil! Silakan Login.'),
              backgroundColor: Colors.green,
            ),
          );
          // Lempar ke Login
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogin() {
    Navigator.pop(context); // Kembali ke halaman Login
  }

  void _handleRegisterMitra() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Register Mitra akan segera hadir!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(screenHeight),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Mahasiswa",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Lengkapi data dirimu untuk mulai mencari pengalaman.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 25),

                  // --- FORM BIODATA ---
                  _buildSectionLabel("Data Diri"),
                  _buildInputField(
                    controller: _namaController,
                    hintText: 'Nama Lengkap',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),

                  // Gender Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedGender,
                        hint: const Text(
                          "Pilih Jenis Kelamin",
                          style: TextStyle(color: Colors.grey),
                        ),
                        items: _genders.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedGender = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // TEMPAT & TANGGAL LAHIR (NEW)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _tempatLahirController,
                          hintText: 'Tempat Lahir',
                          icon: Icons.location_city,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField(
                          controller: _tanggalLahirController,
                          hintText: 'Tgl Lahir',
                          icon: Icons.calendar_today,
                          isReadOnly: true, // Gak bisa diketik manual
                          onTap: () =>
                              _selectDate(context), // Munculin Kalender
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  _buildInputField(
                    controller: _noHpController,
                    hintText: 'Nomor WhatsApp',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 25),

                  // --- FORM AKADEMIK ---
                  _buildSectionLabel("Data Akademik"),
                  _buildInputField(
                    controller: _nimController,
                    hintText: 'NIM',
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _universitasController,
                    hintText: 'Universitas',
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _jurusanController,
                    hintText: 'Jurusan',
                    icon: Icons.book,
                  ),
                  const SizedBox(height: 25),

                  // --- FORM AKUN ---
                  _buildSectionLabel("Detail Akun"),
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),

                  const SizedBox(height: 30),

                  // TOMBOL DAFTAR
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // LOGIN LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      GestureDetector(
                        onTap: _handleLogin,
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: _lightColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // MITRA LINK (DIVIDER)
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Atau",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TOMBOL DAFTAR MITRA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _handleRegisterMitra,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Daftar Sebagai Mitra Perusahaan',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isReadOnly = false, // Parameter baru buat tanggal
    VoidCallback? onTap, // Parameter baru buat klik
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: isReadOnly, // Aktifkan mode baca aja
      onTap: onTap, // Aksi kalau diklik
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
      ),
    );
  }

  Widget _buildHeader(double screenHeight) {
    final headerHeight = screenHeight * 0.30;
    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          ClipPath(
            clipper: LoginClipper(),
            child: Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_lightColor, _primaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset(
                'assets/images/Logo_Regis.png',
                height: headerHeight * 0.6,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person_add, size: 80, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height * 0.85);
    var controlPoint1 = Offset(size.width * 0.25, size.height * 1.0);
    var endPoint1 = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
      controlPoint1.dx,
      controlPoint1.dy,
      endPoint1.dx,
      endPoint1.dy,
    );
    var controlPoint2 = Offset(size.width * 0.75, size.height * 0.75);
    var endPoint2 = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint2.dx,
      endPoint2.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(LoginClipper oldClipper) => false;
}
