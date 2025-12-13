import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// 1. PROVIDER PROFIL USER (Buat Header)
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception("User belum login");

  final data = await supabase
      .from('mahasiswa')
      .select()
      .eq('user_id', user.id)
      .single();
  
  return data;
});

// 2. PROVIDER STATISTIK DASHBOARD (UPDATED)
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return {'Pending': 0, 'Diterima': 0, 'Berlangsung': 0, 'Selesai': 0, 'Ditolak': 0};

  final mhs = await supabase.from('mahasiswa').select('id').eq('user_id', user.id).single();
  final mhsId = mhs['id'];

  final data = await supabase
      .from('pendaftaran')
      .select('status')
      .eq('mahasiswa_id', mhsId);

  int pending = 0;
  int diterima = 0;
  int berlangsung = 0; // Baru
  int selesai = 0;     // Baru
  int ditolak = 0;

  for (var item in data) {
    final status = (item['status'] as String).toLowerCase();
    if (status == 'pending') pending++;
    if (status == 'diterima') diterima++;
    if (status == 'berlangsung') berlangsung++; // Hitung
    if (status == 'selesai') selesai++;         // Hitung
    if (status == 'ditolak') ditolak++;
  }

  return {
    'Pending': pending,
    'Diterima': diterima,
    'Berlangsung': berlangsung,
    'Selesai': selesai,
    'Ditolak': ditolak,
  };
});

// 3. PROVIDER LOWONGAN TERBARU
final recentJobsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await supabase
      .from('program_magang')
      .select('*, mitra(nama_perusahaan, alamat_perusahaan, logo_perusahaan)')
      .order('created_at', ascending: false) 
      .limit(5); 

  return List<Map<String, dynamic>>.from(data);
});