import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

class MitraDashboardData {
  final Map<String, dynamic> mitraProfile;
  final int activeLoker;
  final int totalPelamar;
  final int needReview;
  final int activeInterns;
  final List<Map<String, dynamic>> recentApplicants;

  MitraDashboardData({
    required this.mitraProfile,
    required this.activeLoker,
    required this.totalPelamar,
    required this.needReview,
    required this.activeInterns,
    required this.recentApplicants,
  });
}

final mitraDashboardProvider = FutureProvider.autoDispose<MitraDashboardData>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw "User tidak login";

  // 1. Ambil Mitra ID
  final mitraData = await supabase
      .from('mitra')
      .select()
      .eq('user_id', user.id)
      .single();
  
  final mitraId = mitraData['id'];

  // 2. Hitung Loker Aktif
  final lokerCount = await supabase
      .from('program_magang')
      .count()
      .eq('mitra_id', mitraId)
      .eq('status_magang', 'buka');

  // 3. Ambil ID Program Milik Mitra
  final myPrograms = await supabase
      .from('program_magang')
      .select('id')
      .eq('mitra_id', mitraId);
  
  final List<int> programIds = (myPrograms as List).map((e) => e['id'] as int).toList();

  int totalPelamar = 0;
  int needReview = 0;
  int activeInterns = 0;
  List<Map<String, dynamic>> recentApps = [];

  if (programIds.isNotEmpty) {
    totalPelamar = await supabase.from('pendaftaran').count().inFilter('program_magang_id', programIds);
    needReview = await supabase.from('pendaftaran').count().inFilter('program_magang_id', programIds).eq('status', 'pending');
    activeInterns = await supabase.from('pendaftaran').count().inFilter('program_magang_id', programIds).eq('status', 'berlangsung');

    final appsData = await supabase
        .from('pendaftaran')
        .select('*, mahasiswa(*), program_magang(judul)')
        .inFilter('program_magang_id', programIds)
        .order('created_at', ascending: false)
        .limit(5);
        
    recentApps = List<Map<String, dynamic>>.from(appsData);
  }

  return MitraDashboardData(
    mitraProfile: mitraData,
    activeLoker: lokerCount,
    totalPelamar: totalPelamar,
    needReview: needReview,
    activeInterns: activeInterns,
    recentApplicants: recentApps,
  );
});