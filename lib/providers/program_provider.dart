import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

final programListProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  
  // 1. Base Query: Ambil data program + data mitra
  var query = supabase
      .from('program_magang')
      .select('*, mitra(nama_perusahaan, alamat_perusahaan, logo_perusahaan)');

  // 2. Filter Kategori
  if (category != "Semua") {
    query = query.eq('kategori', category); 
  }

  final data = await query.order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data);
});