import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// 1. PROVIDER PROFIL USER (Buat Header)
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception("User belum login");

  // Ambil data dari tabel 'mahasiswa' berdasarkan user_id login
  final data = await supabase
      .from('mahasiswa')
      .select()
      .eq('user_id', user.id)
      .single();

  return data;
});

// 2. PROVIDER STATISTIK DASHBOARD (Hitung Lamaran)
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return {'Pending': 0, 'Diterima': 0, 'Ditolak': 0};

  final mhs = await supabase
      .from('mahasiswa')
      .select('id')
      .eq('user_id', user.id)
      .single();
  final mhsId = mhs['id'];

  final data = await supabase
      .from('pendaftaran')
      .select('status')
      .eq('mahasiswa_id', mhsId);

  int pending = 0;
  int diterima = 0;
  int ditolak = 0;

  for (var item in data) {
    final status = item['status'] as String;
    if (status.toLowerCase() == 'pending') pending++;
    if (status.toLowerCase() == 'diterima') diterima++;
    if (status.toLowerCase() == 'ditolak') ditolak++;
  }

  return {'Pending': pending, 'Diterima': diterima, 'Ditolak': ditolak};
});

// 3. PROVIDER LOWONGAN TERBARU 
final recentJobsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // Ambil data program, sekaligus data Mitra pemilik
  final data = await supabase
      .from('program_magang')
      .select('*, mitra(nama_perusahaan, logo_perusahaan, alamat_perusahaan)')
      .order('created_at', ascending: false) // Urutkan dari yang terbaru
      .limit(5); // Cuma ambil 5 biji

  return List<Map<String, dynamic>>.from(data);
});
