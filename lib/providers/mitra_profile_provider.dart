import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// Provider buat ambil data profil Mitra lengkap
final mitraProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final data = await supabase
      .from('mitra')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();
  
  return data;
});