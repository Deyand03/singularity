import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TambahProgram extends StatefulWidget {
  const TambahProgram({super.key});

  @override
  State<TambahProgram> createState() => _TambahProgramState();
}

class _TambahProgramState extends State<TambahProgram> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- PALET WARNA DARI GAMBAR ---
  final Color _primaryBlue = const Color(0xFF0E6586); // Biru Tua (Kiri Bawah)
  final Color _accentYellow = const Color(0xFFF5C533); // Kuning Emas (Kanan)
  final Color _lightBlue = const Color(0xFF259CCC); // Biru Cerah (Kiri Atas)

  // Controller
  final _posisiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _durasiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _selectedLocationType;
  final List<String> _locationOptions = [
    "Onsite (WFO)",
    "Remote (WFH)",
    "Hybrid",
  ];

  Future<void> _pickDateRange() async {
    FocusScope.of(context).unfocus();
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryBlue, // Warna header kalender
              onPrimary: Colors.white,
              onSurface: _primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      String start =
          "${pickedRange.start.day}/${pickedRange.start.month}/${pickedRange.start.year}";
      String end =
          "${pickedRange.end.day}/${pickedRange.end.month}/${pickedRange.end.year}";
      setState(() {
        _durasiController.text = "$start - $end";
      });
    }
  }

  void _simpanData() async {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Program berhasil diterbitkan!"),
            ],
          ),
          backgroundColor: _primaryBlue, // Warna snackbar sesuai tema
          behavior: SnackBarBehavior.floating,
        ),
      );

      _posisiController.clear();
      _lokasiController.clear();
      _durasiController.clear();
      _deskripsiController.clear();
      setState(() {
        _selectedLocationType = null;
      });
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Tambah Program Magang"),
          backgroundColor: _primaryBlue, // Update Warna AppBar
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, double opacity, child) {
              return Opacity(opacity: opacity, child: child);
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detail Lowongan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                      Divider(height: 30, color: _lightBlue.withOpacity(0.3)),

                      _buildInputFormatted(
                        "Nama Posisi",
                        "Ex: UI/UX Designer",
                        _posisiController,
                        Icons.badge,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Tipe Lokasi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedLocationType,
                        items: _locationOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedLocationType = val;
                            _lokasiController.text = val ?? "";
                          });
                        },
                        decoration: _inputDecoration(
                          "Pilih Tipe Kerja",
                          Icons.location_on,
                        ),
                        validator: (val) =>
                            val == null ? "Wajib dipilih" : null,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Durasi Magang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _durasiController,
                        readOnly: true,
                        onTap: _pickDateRange,
                        validator: (val) =>
                            val!.isEmpty ? "Durasi wajib diisi" : null,
                        decoration: _inputDecoration(
                          "Pilih Tanggal Mulai - Selesai",
                          Icons.date_range,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildInputFormatted(
                        "Deskripsi Pekerjaan",
                        "Jelaskan tanggung jawab...",
                        _deskripsiController,
                        Icons.description,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _simpanData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue, // Tombol Biru Tua
                            foregroundColor: Colors.white, // Teks Putih
                            shadowColor: _primaryBlue.withOpacity(0.5),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: _accentYellow,
                                ) // Loading Kuning Emas
                              : const Text(
                                  "Terbitkan Program",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFormatted(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (val) => val!.isEmpty ? "$label tidak boleh kosong" : null,
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _primaryBlue), // Ikon warna Biru
      filled: true,
      fillColor: Colors.grey[50],
      // Border biasa
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      // Border saat diklik jadi KUNING EMAS
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentYellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
