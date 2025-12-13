import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// Provider untuk mengambil daftar lowongan milik Mitra yang sedang login
final mitraJobsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  // 1. Ambil Mitra ID
  final mitraRes = await supabase
      .from('mitra')
      .select('id')
      .eq('user_id', user.id)
      .maybeSingle();
      
  if (mitraRes == null) return [];
  final mitraId = mitraRes['id'];

  // 2. Ambil Lowongan + Hitung Jumlah Pelamar (pendaftaran)
  // Syntax 'pendaftaran(count)' adalah fitur Postgrest untuk menghitung relasi
  final response = await supabase
      .from('program_magang')
      .select('*, pendaftaran(count)') 
      .eq('mitra_id', mitraId)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});