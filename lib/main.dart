import 'package:flutter/material.dart';

import 'screens/image_to_pdf_screen.dart';
import 'screens/pdf_merge_screen.dart';
import 'screens/pdf_split_screen.dart';
import 'screens/pdf_compress_screen.dart';
import 'screens/photo_compress_screen.dart';
import 'screens/image_converter_screen.dart';
import 'screens/document_scanner_screen.dart';
import 'screens/signature_maker_screen.dart';
import 'screens/passport_photo_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DocuMasterApp());
}

class DocuMasterApp extends StatelessWidget {
  const DocuMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2457C5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1746A2),
          elevation: 0,
          centerTitle: false,
        ),
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
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCE8FF),
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
    {
      'name': 'Image to PDF',
      'icon': Icons.image,
      'color': Color(0xFF3975E8),
    },
    {
      'name': 'PDF Merge',
      'icon': Icons.merge_type,
      'color': Color(0xFF7C4DCE),
    },
    {
      'name': 'PDF Split',
      'icon': Icons.call_split,
      'color': Color(0xFFE58A35),
    },
    {
      'name': 'PDF Compress',
      'icon': Icons.compress,
      'color': Color(0xFF16A085),
    },
    {
      'name': 'Photo Compress',
      'icon': Icons.photo_size_select_small,
      'color': Color(0xFFDB6090),
    },
    {
      'name': 'Image Converter',
      'icon': Icons.transform,
      'color': Color(0xFF008FA8),
    },
    {
      'name': 'Document Scanner',
      'icon': Icons.document_scanner,
      'color': Color(0xFF5969C9),
    },
    {
      'name': 'Signature Maker',
      'icon': Icons.draw,
      'color': Color(0xFF9B6BC4),
    },
    {
      'name': 'Passport Photo',
      'icon': Icons.portrait,
      'color': Color(0xFFCE8140),
    },
  ];

  void openTool(BuildContext context, String name) {
    Widget? screen;

    switch (name) {
      case 'Image to PDF':
        screen = const ImageToPdfScreen();
        break;

      case 'PDF Merge':
        screen = const PdfMergeScreen();
        break;

      case 'PDF Split':
        screen = const PdfSplitScreen();
        break;

      case 'PDF Compress':
        screen = const PdfCompressScreen();
        break;

      case 'Photo Compress':
        screen = const PhotoCompressScreen();
        break;

      case 'Image Converter':
        screen = const ImageConverterScreen();
        break;

      case 'Document Scanner':
        screen = const DocumentScannerScreen();
        break;

      case 'Signature Maker':
        screen = const SignatureMakerScreen();
        break;

      case 'Passport Photo':
        screen = const PassportPhotoScreen();
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name feature will be added next.'),
          ),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DocuMaster',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1746A2),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon.'),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1746A2),
                      Color(0xFF3975E8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                      size: 38,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'All Document Tools\nIn One Place',
                      style: TextStyle(
                        fontSize: 24,
                        height: 1.3,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage, convert and organize your documents easily.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'All Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Choose a tool to get started',
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tools.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.12,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];

                  return ToolCard(
                    name: tool['name'] as String,
                    icon: tool['icon'] as IconData,
                    color: tool['color'] as Color,
                    onTap: () {
                      openTool(
                        context,
                        tool['name'] as String,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Color(0xFF2457C5),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Documents, Your Control',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Document processing is designed to happen locally on your device.',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

class ToolCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8EDF7),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 29,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24344D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Files',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 75,
                color: Color(0xFF3975E8),
              ),
              SizedBox(height: 16),
              Text(
                'My Files',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your saved documents will appear here. File library feature is coming next.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium,
                size: 80,
                color: Color(0xFFE5A52B),
              ),
              const SizedBox(height: 18),
              const Text(
                'DocuMaster Premium',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Premium plans and additional benefits will be available here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Color(0xFF2457C5),
            ),
            title: Text('About DocuMaster'),
            subtitle: Text('Version 1.0.0'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Color(0xFF2457C5),
            ),
            title: Text('Privacy Policy'),
            subtitle: Text('Privacy information coming soon.'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Color(0xFF2457C5),
            ),
            title: Text('Help & Support'),
            subtitle: Text('Support information coming soon.'),
          ),
        ],
      ),
    );
  }
}

