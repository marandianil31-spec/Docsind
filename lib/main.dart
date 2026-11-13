
import 'package:flutter/material.dart';

import 'screens/image_to_pdf_screen.dart';
import 'screens/pdf_merge_screen.dart';
import 'screens/pdf_split_screen.dart';

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
          seedColor: const Color(0xFF1769E0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF172B4D),
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
        indicatorColor: const Color(0xFFDCEAFF),
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

// HOME SCREEN

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> tools = [
    {
      'name': 'Image to PDF',
      'subtitle': 'Convert photos into PDF',
      'icon': Icons.image,
      'color': Color(0xFF1769E0),
    },
    {
      'name': 'PDF Merge',
      'subtitle': 'Combine multiple PDFs',
      'icon': Icons.merge_type,
      'color': Color(0xFFE53935),
    },
    {
      'name': 'PDF Split',
      'subtitle': 'Separate PDF pages',
      'icon': Icons.call_split,
      'color': Color(0xFF8E44AD),
    },
    {
      'name': 'PDF Compress',
      'subtitle': 'Reduce PDF file size',
      'icon': Icons.compress,
      'color': Color(0xFF00897B),
    },
    {
      'name': 'Photo Compress',
      'subtitle': 'Reduce photo size',
      'icon': Icons.photo_size_select_small,
      'color': Color(0xFFF57C00),
    },
    {
      'name': 'Image Converter',
      'subtitle': 'Convert image formats',
      'icon': Icons.transform,
      'color': Color(0xFF3949AB),
    },
    {
      'name': 'Document Scanner',
      'subtitle': 'Scan documents',
      'icon': Icons.document_scanner,
      'color': Color(0xFF0097A7),
    },
    {
      'name': 'Signature Maker',
      'subtitle': 'Create your signature',
      'icon': Icons.draw,
      'color': Color(0xFF6D4C41),
    },
    {
      'name': 'Passport Photo',
      'subtitle': 'Create passport photos',
      'icon': Icons.portrait,
      'color': Color(0xFF7B1FA2),
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
        title: const Row(
          children: [
            Icon(
              Icons.description,
              color: Color(0xFF1769E0),
              size: 28,
            ),
            SizedBox(width: 9),
            Text(
              'DocuMaster',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1769E0),
                      Color(0xFF4895FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Documents.\nOne Simple App.',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Manage, convert and organize your documents easily.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 16),
                    Icon(
                      Icons.picture_as_pdf,
                      size: 42,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'All Tools',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Choose a tool to get started',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 17),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tools.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: 1.12,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(17),
                    onTap: () {
                      openTool(
                        context,
                        tool['name'] as String,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFE7ECF5),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 47,
                            height: 47,
                            decoration: BoxDecoration(
                              color: (tool['color'] as Color)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              tool['icon'] as IconData,
                              color: tool['color'] as Color,
                              size: 25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tool['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tool['subtitle'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// MY FILES SCREEN

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'My Files',
      icon: Icons.folder_open,
      message: 'Your saved documents will appear here.',
    );
  }
}

// PREMIUM SCREEN

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'DocuMaster Premium',
      icon: Icons.workspace_premium,
      message: 'Premium features are coming soon.',
    );
  }
}

// SETTINGS SCREEN

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'Settings',
      icon: Icons.settings,
      message: 'App settings will be available here.',
    );
  }
}

// COMMON PLACEHOLDER PAGE

class SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const SimplePage({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 65,
                color: const Color(0xFF1769E0),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
