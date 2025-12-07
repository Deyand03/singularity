import 'package:flutter/material.dart';
import 'package:singularity/components/custom_nav_mhs.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            children: [
              Stack(children: []),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavMhs(curentindex: 0),
    );
  }
}
