import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:singularity/utility/supabase.client.dart';

// 1. STREAM DAFTAR CHAT (List Room)
final chatListProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) {
    final user = supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return supabase
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('last_updated', ascending: false)
        .asyncMap((rooms) async {
          final List<Map<String, dynamic>> enrichedRooms = [];

          for (var room in rooms) {
            final mhsRes = await supabase
                .from('mahasiswa')
                .select()
                .eq('id', room['mahasiswa_id'])
                .single();
            final mitraRes = await supabase
                .from('mitra')
                .select()
                .eq('id', room['mitra_id'])
                .single();

            bool amIMahasiswa = mhsRes['user_id'] == user.id;

            enrichedRooms.add({
              ...room,
              'lawan_bicara': amIMahasiswa
                  ? mitraRes['nama_perusahaan']
                  : mhsRes['nama'],
              'foto_lawan': amIMahasiswa
                  ? mitraRes['logo_perusahaan']
                  : mhsRes['foto_profil'],
              'role_saya': amIMahasiswa ? 'mahasiswa' : 'mitra',
            });
          }
          return enrichedRooms;
        });
  },
);

// 2. STREAM ISI PESAN (FIXED ORDER)
final chatMessagesProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, roomId) {
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .map((data) => List<Map<String, dynamic>>.from(data));
    });

// 3. FUNGSI KIRIM PESAN
Future<void> sendMessage(int roomId, String content) async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  await supabase.from('messages').insert({
    'room_id': roomId,
    'sender_id': user.id,
    'content': content,
  });

  await supabase
      .from('chat_rooms')
      .update({
        'last_message': content,
        'last_updated': DateTime.now().toIso8601String(),
      })
      .eq('id', roomId);
}

// 4. FUNGSI BUAT ROOM BARU
Future<int> getOrCreateChatRoom(int mahasiswaId, int mitraId) async {
  final existing = await supabase
      .from('chat_rooms')
      .select('id')
      .eq('mahasiswa_id', mahasiswaId)
      .eq('mitra_id', mitraId)
      .maybeSingle();

  if (existing != null) {
    return existing['id'];
  } else {
    final newRoom = await supabase
        .from('chat_rooms')
        .insert({
          'mahasiswa_id': mahasiswaId,
          'mitra_id': mitraId,
          'last_message': 'Memulai percakapan...',
        })
        .select()
        .single();
    return newRoom['id'];
  }
}
