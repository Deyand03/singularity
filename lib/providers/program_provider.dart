import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// 1. Kelas Pembungkus Filter (Biar rapi)
class ProgramFilter {
  final String category;
  final String query;

  ProgramFilter({required this.category, required this.query});

  // Override == dan hashCode biar Riverpod tau kalau filternya berubah
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramFilter &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          query == other.query;

  @override
  int get hashCode => category.hashCode ^ query.hashCode;
}

// 2. Provider yang sudah di-upgrade
final programListProvider = FutureProvider.family<List<Map<String, dynamic>>, ProgramFilter>((ref, filter) async {
  
  // Base Query
  var query = supabase
      .from('program_magang')
      .select('*, mitra(nama_perusahaan, alamat_perusahaan, logo_perusahaan)');

  // Filter Kategori
  if (filter.category != "Semua") {
    query = query.eq('kategori', filter.category); 
  }

  // Filter Pencarian (Judul) -> ILIKE (Case Insensitive)
  if (filter.query.isNotEmpty) {
    // Mencari berdasarkan judul program yang mengandung kata kunci
    query = query.ilike('judul', '%${filter.query}%');
  }

  // Urutkan
  final data = await query.order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data);
});