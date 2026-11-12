import 'screens/image_to_pdf_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DocuMasterApp());
}

const Color primaryBlue = Color(0xFF1769E8);
const Color lightBlue = Color(0xFFEAF2FF);

class DocuMasterApp extends StatelessWidget {
  const DocuMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocuMaster',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FD),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    MyFilesScreen(),
    PremiumScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'My Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium),
            label: 'Premium',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> tools = const [
    {'name': 'Image to PDF', 'icon': Icons.image, 'color': Color(0xFF2878E8)},
    {'name': 'PDF Merge', 'icon': Icons.merge_type, 'color': Color(0xFF8B5CF6)},
    {'name': 'PDF Split', 'icon': Icons.call_split, 'color': Color(0xFF00A88F)},
    {'name': 'PDF Compress', 'icon': Icons.compress, 'color': Color(0xFFE58B24)},
    {'name': 'Photo Compress', 'icon': Icons.photo_size_select_small, 'color': Color(0xFFE05B79)},
    {'name': 'Image Converter', 'icon': Icons.transform, 'color': Color(0xFF3986A8)},
    {'name': 'Document Scanner', 'icon': Icons.document_scanner, 'color': Color(0xFF5C70D6)},
    {'name': 'Signature Maker', 'icon': Icons.draw, 'color': Color(0xFF159C79)},
    {'name': 'Passport Photo', 'icon': Icons.portrait, 'color': Color(0xFFB56A38)},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DocuMaster',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your all-in-one document toolkit',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: lightBlue,
                    child: Icon(Icons.person_outline, color: primaryBlue),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1769E8), Color(0xFF5599F5)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Documents,',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Simplified.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'Create, convert and manage documents easily.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.offline_bolt, color: Colors.white, size: 19),
                        SizedBox(width: 7),
                        Text(
                          'Document tools designed for offline use',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Tools',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${tools.length} tools',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 25),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tool = tools[index];
                  final Color color = tool['color'] as Color;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${tool['name']} feature will be added next.',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE9EDF4)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              tool['icon'] as IconData,
                              color: color,
                              size: 29,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tool['name'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: tools.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      icon: Icons.folder_open,
      title: 'My Files',
      subtitle: 'Your processed documents will appear here.',
    );
  }
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      icon: Icons.workspace_premium,
      title: 'DocuMaster Premium',
      subtitle: 'Unlock a better document experience. Premium plans coming soon.',
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      icon: Icons.settings,
      title: 'Settings',
      subtitle: 'Manage your app preferences.',
    );
  }
}

class SimplePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const SimplePage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryBlue, size: 65),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
