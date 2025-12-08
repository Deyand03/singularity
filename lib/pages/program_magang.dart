import 'package:flutter/material.dart';

class ProgramMagang extends StatelessWidget {
  const ProgramMagang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Program Tersedia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16.0),
              child: ListTile(
                title: const Text('Program Magang A'),
                subtitle: const Text(
                  'Deskripsi singkat tentang Program Magang A.',
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Aksi ketika tombol ditekan
                  },
                  child: const Text('Daftar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
