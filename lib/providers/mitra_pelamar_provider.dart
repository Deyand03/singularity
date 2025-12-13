import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// Provider buat ambil daftar pelamar
final mitraApplicantsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
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

  // 2. Cari semua Lowongan milik Mitra ini
  final programsRes = await supabase
      .from('program_magang')
      .select('id')
      .eq('mitra_id', mitraId);
  
  final List<dynamic> programIds = (programsRes as List).map((e) => e['id']).toList();

  if (programIds.isEmpty) return [];

  // 3. Ambil data Pendaftaran berdasarkan ID Lowongan 
  final response = await supabase
      .from('pendaftaran')
      .select('*, mahasiswa(*), program_magang(judul)')
      .inFilter('program_magang_id', programIds)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});