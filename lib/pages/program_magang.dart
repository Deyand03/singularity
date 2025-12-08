import 'package:flutter/material.dart';
import 'detail_program_magang.dart';
import 'dart:math';

class ProgramMagang extends StatefulWidget {
  const ProgramMagang({super.key});

  @override
  State<ProgramMagang> createState() => _ProgramMagangState();
}

class _ProgramMagangState extends State<ProgramMagang> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // DUMMY DATA
  // Nanti ini diganti dengan data dari API/Database
  final List<Map<String, String>> _allPrograms = List.generate(
    50,
    (index) => {
      'company': 'PT. Moonton ${index + 1}',
      'title': 'Program Bootcamp MDL ${index + 1} yang Intens',
      'address': 'Jl. Yang Benar No. ${index + 1}, Jakarta',
      'quota': '${(index + 1) * 10}',
      'image_url':
          'https://i0.wp.com/www.lapakgaming.com/blog/id-id/wp-content/uploads/2025/10/MLBB-9th-Anniv-P.ACE-Cici-9th-Anniversary.jpg?fit=1200%2C675&ssl=1',
    },
  );

  @override
  Widget build(BuildContext context) {
    // LOGIKA PAGINATION

    int totalPages = (_allPrograms.length / _itemsPerPage).ceil();
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = min(startIndex + _itemsPerPage, _allPrograms.length);

    List<Map<String, String>> currentData = _allPrograms.sublist(
      startIndex,
      endIndex,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        backgroundColor: const Color(0xFF146C94),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Daftar Program Tersedia',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          _buildSearchBar(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: currentData.length + 1,
              itemBuilder: (context, index) {
                if (index == currentData.length) {
                  return _buildPaginationControl(totalPages);
                }

                final program = currentData[index];
                return ProgramCard(
                  companyName: program['company']!,
                  programTitle: program['title']!,
                  address: program['address']!,
                  quota: program['quota']!,
                  imageUrl: program['image_url']!,
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF146C94),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Lowongan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Program',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E98D0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControl(int totalPages) {
    const mainColor = Color(0xFF146C94);
    const disabledColor = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _currentPage > 1 ? mainColor : disabledColor,
            ),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '$_currentPage',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _currentPage < totalPages ? mainColor : disabledColor,
            ),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final String companyName;
  final String programTitle;
  final String address;
  final String quota;
  final String imageUrl;

  const ProgramCard({
    Key? key,
    required this.companyName,
    required this.programTitle,
    required this.address,
    required this.quota,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://i0.wp.com/www.lapakgaming.com/blog/id-id/wp-content/uploads/2025/10/MLBB-9th-Anniv-P.ACE-Cici-9th-Anniversary.jpg?fit=1200%2C675&ssl=1',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF146C94),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      programTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Kuota: $quota',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailProgramPage(
                                title: programTitle,
                                companyName: companyName,
                                address: address,
                                imageUrl: imageUrl,
                                quota: quota,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5C219),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Lihat Selengkapnya',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}