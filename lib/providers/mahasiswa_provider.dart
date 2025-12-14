import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// 1. AMBIL DATA DIRI LENGKAP
final userProfileDetailProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final data = await supabase
      .from('mahasiswa')
      .select() 
      .eq('user_id', user.id)
      .maybeSingle();
  
  return data;
});

// 2. AMBIL RIWAYAT LAMARAN (UPDATED)
final applicationHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final mhs = await supabase.from('mahasiswa').select('id').eq('user_id', user.id).maybeSingle();
  if (mhs == null) return [];

  final data = await supabase
      .from('pendaftaran')
      .select('status, created_at, file_cv, transkrip_nilai, program_magang(judul, mitra(id, nama_perusahaan, logo_perusahaan))') 
      .eq('mahasiswa_id', mhs['id'])
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data);
});