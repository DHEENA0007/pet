/// Home Screen - Main navigation hub with Custom Milky UI
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/pet_provider.dart';
import '../../core/providers/adoption_provider.dart';

import '../../models/category.dart';
import '../../models/pet.dart';
import '../../widgets/pet_card.dart';
import '../../core/providers/chat_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _currentFilter = 'Recent Additions';
  int? _selectedCategoryId;
  Timer? _searchTimer;
  final ScrollController _homeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _homeScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final adoptionProvider = Provider.of<AdoptionProvider>(context, listen: false);

    await petProvider.fetchCategories();
    await petProvider.fetchPets();
    await adoptionProvider.fetchRecommendations();
    Provider.of<ChatProvider>(context, listen: false).fetchUnreadCount();
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      final provider = Provider.of<PetProvider>(context, listen: false);
      provider.fetchAdoptedPets();
      provider.fetchMyPets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.milkyCream,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.small(
          heroTag: 'chatbot_fab',
          onPressed: () => context.push('/chatbot'),
          backgroundColor: AppColors.accentDarkBrown,
          tooltip: 'AI Pet Assistant',
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            bottom: 80, // Space for bottom nav
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                _buildSearchTab(),
                _buildMyPetsTab(),
                _buildProfileTab(),
              ],
            ),
          ),
          
          // Custom Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCustomBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryWarmBrown.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.search_rounded, 'Search'),
          _buildCenterNavItem(),
          _buildMessagesNavItem(),
          _buildNavItem(3, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.milkyCream : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryWarmBrown : AppColors.textGrey,
              size: 28,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryWarmBrown,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    return GestureDetector(
      onTap: () => context.push('/add-pet'),
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryWarmBrown, AppColors.accentDarkBrown],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryWarmBrown.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildMessagesNavItem() {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final unread = chat.totalUnread;
        return GestureDetector(
          onTap: () => context.push('/messages'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textGrey,
                  size: 28,
                ),
                if (unread > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        controller: _homeScrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${authProvider.user?.firstName ?? 'Friend'}!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentDarkBrown,
                      ),
                    ),
                    Text(
                      'Ready to find a new friend?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.accentDarkBrown),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Top Shortcuts
            Row(
              children: [
                Expanded(child: _buildShortcutCard(
                  'My Pets', 
                  Icons.pets, 
                  const Color(0xFFE8F5E9), 
                  const Color(0xFF4CAF50),
                  onTap: () => _switchTab(2),
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildShortcutCard(
                  'Messages', 
                  Icons.message_rounded, 
                  const Color(0xFFFFF3E0), 
                  const Color(0xFFFF9800),
                  onTap: () => context.push('/messages'),
                )),
              ],
            ),
            const SizedBox(height: 24),
            
            // Feature Banner 1 (Dog)
            _buildPromoBanner(
              'Find Your\nBest Friend',
              'Adopt a customized companion today',
              'assets/images/dog_3d.png',
              const Color(0xFFFFF3E0),
              AppColors.primaryWarmBrown,
              false, // Image on Right
            ),
            
            const SizedBox(height: 32),

            // Bento Grid Categories
            Text(
              'Explore Categories',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.accentDarkBrown,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dynamic Grid
            if (petProvider.categories.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildDynamicCategoryGrid(petProvider.categories),
              ),

            // Feature Banner 2 (Cat)
            _buildPromoBanner(
              'New Arrivals\nJust In!',
              'Check out our newest furry friends',
              'assets/images/cat_3d.png',
              const Color(0xFFFBE9E7),
              AppColors.accentDarkBrown,
              true, // Image on Left
            ),
            
            const SizedBox(height: 32),

            // Adopt Me Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentFilter,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentDarkBrown,
                  ),
                ),
                TextButton(
                  onPressed: () => _switchTab(1),
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryWarmBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<PetProvider>(
              builder: (context, provider, _) => _buildPetList2(provider),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard(String title, IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accentDarkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, String? imagePath, Color bgColor, {IconData? icon, bool isAsset = true, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null)
              Expanded(
                child: Center(
                  child: isAsset
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => Icon(Icons.pets, size: 60, color: AppColors.primaryWarmBrown.withOpacity(0.5)),
                        )
                      : Image.network(
                          imagePath.startsWith('http') 
                              ? imagePath 
                              : '${ApiConstants.baseUrl.replaceAll('/api', '')}$imagePath',
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => Icon(Icons.pets, size: 60, color: AppColors.primaryWarmBrown.withOpacity(0.5)),
                        ),
                ),
              )
            else if (icon != null)
               Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 32, color: Colors.black54),
                    ),
                  ),
               ),
            if (imagePath == null && icon == null) const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accentDarkBrown,
              ),
            ),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textGrey,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetList2(PetProvider provider) {
    if (provider.isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var pets = provider.pets.where((p) => p.isAvailable);
    // Client-side guard: ensure only the selected category is shown
    if (_selectedCategoryId != null) {
      pets = pets.where((p) => p.categoryId == _selectedCategoryId);
    }
    final petList = pets.take(5).toList();

    if (petList.isEmpty) {
      // Only show empty state if a category filter is active
      if (_selectedCategoryId == null) return const SizedBox.shrink();

      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 40, color: AppColors.textGrey.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'No pets found in "$_currentFilter"',
              style: GoogleFonts.poppins(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another category',
              style: GoogleFonts.poppins(
                color: AppColors.textGrey.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: petList.length,
        itemBuilder: (context, index) {
          final pet = petList[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.milkyCream,
                      borderRadius: BorderRadius.circular(20),
                      image: pet.primaryImage != null 
                        ? DecorationImage(
                            image: NetworkImage(pet.primaryImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: pet.primaryImage == null 
                      ? const Center(child: Icon(Icons.pets, color: AppColors.textGrey, size: 40))
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pet.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentDarkBrown,
                  ),
                ),
                Text(
                  '${pet.categoryName} • ${pet.ageString}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: pet.gender == 'female' ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        pet.gender == 'female' ? Icons.female : Icons.male,
                        size: 16,
                        color: pet.gender == 'female' ? Colors.pink : Colors.blue,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push('/pets/${pet.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWarmBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPromoBanner(String title, String subtitle, String imagePath, Color bgColor, Color textColor, bool imageOnLeft) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          if (imageOnLeft) ...[
            Expanded(
              flex: 3,
              child: Image.asset(imagePath, fit: BoxFit.contain, height: 120),
            ),
            const SizedBox(width: 20),
          ],
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                   ),
                   child: Text(
                      'Explore Now',
                      style: GoogleFonts.poppins(
                         fontSize: 12,
                         fontWeight: FontWeight.w600,
                         color: textColor,
                      ),
                   ),
                ),
              ],
            ),
          ),
          if (!imageOnLeft) ...[
             const SizedBox(width: 20),
             Expanded(
                flex: 3,
                child: Image.asset(imagePath, fit: BoxFit.contain, height: 120),
             ),
          ],
        ],
      ),
    );
  }


  Widget _buildSearchTab() {
    return Container(
      color: AppColors.milkyCream,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryWarmBrown.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search pets...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textGrey),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryWarmBrown),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    _searchTimer?.cancel();
                    _searchTimer = Timer(const Duration(milliseconds: 500), () {
                      Provider.of<PetProvider>(context, listen: false).fetchPets(search: value);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Consumer<PetProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pets = provider.pets.where((p) => p.isAvailable).toList();
                  if (pets.isEmpty) {
                    return Center(
                      child: Text(
                        'No pets found',
                        style: GoogleFonts.poppins(color: AppColors.textGrey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      // Reuse the modern list item or build a new one
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: pet.primaryImage != null
                                    ? DecorationImage(
                                        image: NetworkImage(pet.primaryImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: AppColors.primaryWarmBrown.withOpacity(0.1),
                              ),
                              child: pet.primaryImage == null
                                  ? const Icon(Icons.pets, color: AppColors.primaryWarmBrown)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.accentDarkBrown,
                                    ),
                                  ),
                                  Text(
                                    '${pet.categoryName} • ${pet.ageString}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryWarmBrown),
                              onPressed: () => context.push('/pets/${pet.id}'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 80), // Bottom nav space
          ],
        ),
      ),
    );
  }

  Widget _buildMyPetsTab() {
    return Consumer<PetProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Pets",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentDarkBrown,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppColors.primaryWarmBrown),
                      onPressed: () {
                        provider.fetchAdoptedPets();
                        provider.fetchMyPets();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adopted Pets Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                        child: Row(
                          children: [
                            Icon(Icons.favorite_rounded, size: 18, color: AppColors.primaryWarmBrown),
                            const SizedBox(width: 8),
                            Text(
                              'Adopted Pets',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentDarkBrown,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWarmBrown.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.adoptedPets.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryWarmBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (provider.adoptedPets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.pets, size: 40, color: AppColors.textGrey.withOpacity(0.4)),
                              const SizedBox(height: 8),
                              Text(
                                'No adopted pets yet',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else
                        ...provider.adoptedPets.map((pet) => _buildMyPetCard(pet, isAdopted: true)),

                      const SizedBox(height: 24),

                      // My Posts Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_rounded, size: 18, color: AppColors.primaryWarmBrown),
                            const SizedBox(width: 8),
                            Text(
                              'My Posts',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentDarkBrown,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWarmBrown.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.myPets.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryWarmBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (provider.myPets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textGrey.withOpacity(0.4)),
                              const SizedBox(height: 8),
                              Text(
                                'You haven\'t posted any pets yet',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else
                        ...provider.myPets.map((pet) => _buildMyPetCard(pet, isAdopted: false)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyPetCard(Pet pet, {required bool isAdopted}) {
    final statusColor = pet.status == 'available'
        ? Colors.green
        : pet.status == 'adopted'
            ? AppColors.primaryWarmBrown
            : Colors.orange;
    final statusLabel = pet.status == 'available'
        ? 'Available'
        : pet.status == 'adopted'
            ? 'Adopted'
            : pet.status == 'pending'
                ? 'Pending'
                : pet.status;

    return GestureDetector(
      onTap: () => context.push('/pet/${pet.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: pet.primaryImage != null && pet.primaryImage!.isNotEmpty
                    ? Image.network(
                        pet.primaryImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryWarmBrown.withOpacity(0.1),
                          child: Icon(Icons.pets, color: AppColors.primaryWarmBrown, size: 32),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryWarmBrown.withOpacity(0.1),
                        child: Icon(Icons.pets, color: AppColors.primaryWarmBrown, size: 32),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDarkBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [pet.categoryName, pet.breed].where((s) => s != null && s.isNotEmpty).join(' · '),
                      style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDynamicCategoryGrid(List<PetCategory> categories) {
    if (categories.isEmpty) return const SizedBox();
    
    // Split into two columns
    List<PetCategory> leftCol = [];
    List<PetCategory> rightCol = [];
    
    for (int i = 0; i < categories.length; i++) {
       if (i % 2 == 0) {
          leftCol.add(categories[i]);
       } else {
          rightCol.add(categories[i]);
       }
    }
    
    return Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          // Left Column
          Expanded(
             child: Column(
                children: List.generate(leftCol.length, (index) {
                   // Alternate height: Large (220), Small (160)
                   double height = (index % 2 == 0) ? 220 : 160;
                   
                   return Container(
                      height: height,
                      margin: EdgeInsets.only(bottom: index < leftCol.length - 1 ? 16.0 : 0),
                      child: _buildCategoryItem(leftCol[index]),
                   );
                }),
             ),
          ),
          const SizedBox(width: 16),
          // Right Column
          Expanded(
             child: Column(
                children: List.generate(rightCol.length, (index) {
                   // Alternate opposite height: Small (160), Large (220)
                   double height = (index % 2 == 0) ? 160 : 220;
                   
                   return Container(
                      height: height,
                      margin: EdgeInsets.only(bottom: index < rightCol.length - 1 ? 16.0 : 0),
                      child: _buildCategoryItem(rightCol[index]),
                   );
                }),
             ),
          ),
       ],
    );
  }

  Widget _buildCategoryItem(PetCategory category) {
     String? imagePath;
     bool isAsset = true;
     Color bgColor;
     
     // Default values
     imagePath = null;
     bgColor = const Color(0xFFF5F5F5);

     // Check for backend image first
     if (category.icon != null && category.icon!.isNotEmpty) {
        imagePath = category.icon;
        isAsset = false;
     }

     final name = category.name.toLowerCase();
     if (name.contains('dog')) {
        bgColor = const Color(0xFFFFF8E1);
     } else if (name.contains('cat')) {
        bgColor = const Color(0xFFFBE9E7);
     } else if (name.contains('rabbit')) {
        bgColor = const Color(0xFFF3E5F5);
     } else if (name.contains('bird')) {
        bgColor = const Color(0xFFE1F5FE);
     } else if (name.contains('fish')) {
         bgColor = const Color(0xFFE0F7FA);
     } else if (name.contains('hamster')) {
         bgColor = const Color(0xFFFFF3E0);
     }
     
     final isSelected = _selectedCategoryId == category.id;
     return Stack(
       children: [
         _buildCategoryCard(
           category.name,
           category.description ?? 'Tap to explore',
           imagePath,
           isSelected ? AppColors.primaryWarmBrown.withOpacity(0.15) : bgColor,
           isAsset: isAsset,
           icon: null,
           onTap: () => _onCategoryTap(category.name),
         ),
         if (isSelected)
           Positioned(
             top: 10,
             right: 10,
             child: Container(
               padding: const EdgeInsets.all(4),
               decoration: const BoxDecoration(
                 color: AppColors.primaryWarmBrown,
                 shape: BoxShape.circle,
               ),
               child: const Icon(Icons.check, size: 12, color: Colors.white),
             ),
           ),
       ],
     );
  }


  void _onCategoryTap(String categoryName) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    try {
      final category = petProvider.categories.firstWhere(
        (c) => c.name.toLowerCase().contains(categoryName.toLowerCase()),
      );

      // Toggle: tap same category again to reset
      if (_selectedCategoryId == category.id) {
        setState(() {
          _selectedCategoryId = null;
          _currentFilter = 'Recent Additions';
        });
        petProvider.fetchPets();
      } else {
        setState(() {
          _selectedCategoryId = category.id;
          _currentFilter = category.name;
        });
        petProvider.fetchPets(category: category.id);
      }

      // Scroll to pet list section
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_homeScrollController.hasClients) {
          _homeScrollController.animateTo(
            _homeScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Fallback or ignore
    }
  }

  Widget _buildProfileTab() {
     final authProvider = Provider.of<AuthProvider>(context);
     final user = authProvider.user;

     return SafeArea(
       child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
             children: [
                const SizedBox(height: 20),
                // Profile Pic
                Container(
                   width: 120,
                   height: 120,
                   decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primaryWarmBrown.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      image: user?.profileImage != null && user!.profileImage!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                  user.profileImage!.startsWith('http')
                                      ? user.profileImage!
                                      : '${ApiConstants.baseUrl.replaceAll('/api', '')}${user.profileImage}'
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                   ),
                   child: user?.profileImage == null || user!.profileImage!.isEmpty
                       ? const Icon(Icons.person, size: 60, color: AppColors.primaryWarmBrown)
                       : null,
                ),
                const SizedBox(height: 24),
                Text(
                   user?.fullName.isNotEmpty == true ? user!.fullName : (user?.username ?? "User"),
                   style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentDarkBrown),
                ),
                Text(
                   user?.email.isNotEmpty == true ? user!.email : "No email provided",
                   style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
                ),
                const SizedBox(height: 48),
                
                // Admin Dashboard (Only for Admin)
                if (user?.role == 'admin')
                  _buildProfileMenuItem(
                    Icons.admin_panel_settings_rounded, 
                    "Admin Dashboard",
                    onTap: () => context.push('/admin'),
                    isHighlight: true,
                  ),

                // Menu Items
                _buildProfileMenuItem(Icons.person_outline, "Edit Profile", onTap: () => context.push('/profile')),
                _buildProfileMenuItem(Icons.settings_outlined, "Settings", onTap: () => context.push('/settings')),
                _buildProfileMenuItem(Icons.help_outline, "Help & Support", onTap: () => context.push('/help')),
                _buildProfileMenuItem(Icons.history_rounded, "Adoption History", onTap: () => context.push('/my-requests')),
                
                const SizedBox(height: 48),
                
                // Logout
                SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                      onPressed: () async {
                         await authProvider.logout();
                         if (mounted) context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.red[50],
                         foregroundColor: Colors.red,
                         elevation: 0,
                         padding: const EdgeInsets.symmetric(vertical: 18),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("Logout", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                   ),
                ),
                const SizedBox(height: 100),
             ],
          ),
       ),
     );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, {VoidCallback? onTap, bool isHighlight = false}) {
     return GestureDetector(
       onTap: onTap,
       child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
             color: isHighlight ? AppColors.primaryWarmBrown.withOpacity(0.1) : Colors.white,
             borderRadius: BorderRadius.circular(20),
             border: isHighlight ? Border.all(color: AppColors.primaryWarmBrown.withOpacity(0.5)) : null,
             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
             children: [
                Icon(icon, color: isHighlight ? AppColors.primaryWarmBrown : AppColors.primaryWarmBrown),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: GoogleFonts.poppins(
                  fontSize: 16, 
                  fontWeight: FontWeight.w500, 
                  color: isHighlight ? AppColors.primaryWarmBrown : AppColors.accentDarkBrown
                ))),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isHighlight ? AppColors.primaryWarmBrown : Colors.black26),
             ],
          ),
       ),
     );
  }
}
