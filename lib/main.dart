import 'package:flutter/material.dart';
import 'screens/image_to_pdf_screen.dart';

void main() {
  runApp(const DocuMasterApp());
}

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
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFE53935),
    },
    {
      'name': 'PDF Merge',
      'subtitle': 'Combine multiple PDFs',
      'icon': Icons.merge_type,
      'color': Color(0xFF1769E0),
    },
    {
      'name': 'PDF Split',
      'subtitle': 'Split PDF pages',
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
      'color': Color(0xFFF39C12),
    },
    {
      'name': 'Image Converter',
      'subtitle': 'Convert image formats',
      'icon': Icons.image_outlined,
      'color': Color(0xFF3949AB),
    },
    {
      'name': 'Document Scanner',
      'subtitle': 'Scan documents',
      'icon': Icons.document_scanner_outlined,
      'color': Color(0xFF0097A7),
    },
    {
      'name': 'Signature Maker',
      'subtitle': 'Create digital signature',
      'icon': Icons.draw_outlined,
      'color': Color(0xFF6D4C41),
    },
    {
      'name': 'Passport Photo',
      'subtitle': 'Create passport photos',
      'icon': Icons.badge_outlined,
      'color': Color(0xFF2E7D32),
    },
  ];

  void openTool(BuildContext context, String name) {
    if (name == 'Image to PDF') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ImageToPdfScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name feature will be added next.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DocuMaster',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 23,
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
                      Color(0xFF42A5F5),
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
                      'Your Documents, Simplified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'All your PDF and image tools in one place.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Simple • Fast • Private',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'All Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tools.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.12,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      openTool(context, tool['name'] as String);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE7ECF5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: (tool['color'] as Color)
                                  .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              tool['icon'] as IconData,
                              color: tool['color'] as Color,
                              size: 27,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            tool['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          const SizedBox(height: 4),
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

              const Center(
                child: Text(
                  'DocuMaster • Made for everyone',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Files',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 75,
              color: Color(0xFF1769E0),
            ),
            SizedBox(height: 15),
            Text(
              'No files yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Your created documents will appear here.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// PREMIUM SCREEN

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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium,
                size: 85,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(height: 18),
              const Text(
                'DocuMaster Premium',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enjoy more document tools and an improved experience.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium plans coming soon.'),
                    ),
                  );
                },
                child: const Text('Coming Soon'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SETTINGS SCREEN

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
              color: Color(0xFF1769E0),
            ),
            title: Text('About DocuMaster'),
            subtitle: Text('Your document toolkit'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Color(0xFF1769E0),
            ),
            title: Text('Privacy Policy'),
            subtitle: Text('Privacy information coming soon'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(
              Icons.star_outline,
              color: Color(0xFF1769E0),
            ),
            title: Text('Rate App'),
            subtitle: Text('Coming soon'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(
              Icons.info,
              color: Color(0xFF1769E0),
            ),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

