import 'package:flutter/material.dart';
import 'package:singularity/pages/login_regis/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum UserRole { mahasiswa, mitra }

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  UserRole? _selectedRole = UserRole.mahasiswa;

  final Color _primaryColor = const Color(0xFF1880AB);
  final Color _lightColor = const Color(0xFF28A3CF);

  void _handleRegister() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final role = _selectedRole == UserRole.mahasiswa ? 'Mahasiswa' : 'Mitra';

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Konfirmasi password tidak cocok!'),
        ),
      );
      return;
    }

    print('--- Tombol Daftar Ditekan ---');
    print('Email: $email');
    print('Password: $password');
    print('Role: $role');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulasi Pendaftaran berhasil untuk Role: $role!'),
      ),
    );
  }

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, '/login');
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
                horizontal: 27.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    'Email:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Password:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Masukkan Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Konfirmasi password:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Masukkan Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Role',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 140,
                        child: _buildRoleRadio(
                          title: 'Mahasiswa',
                          value: UserRole.mahasiswa,
                        ),
                      ),
                      _buildRoleRadio(title: 'Mitra', value: UserRole.mitra),
                    ],
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 15.0,
        ),
      ),
    );
  }

  Widget _buildRoleRadio({required String title, required UserRole value}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Radio<UserRole>(
            value: value,
            groupValue: _selectedRole,
            onChanged: (UserRole? val) {
              setState(() {
                _selectedRole = val;
              });
            },
            activeColor: _primaryColor,
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenHeight) {
    final headerHeight = screenHeight * 0.45;

    return Container(
      height: headerHeight,
      child: Stack(
        children: <Widget>[
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/Logo_Regis.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: _handleLogin,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
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
