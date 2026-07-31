import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/history_item.dart';
import '../../providers/app_settings_provider.dart';
import '../../services/scan_service.dart';
import '../../widgets/share_card_modal.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  static const int _pageSize = 21; // Multiple of 3 columns

  final ScrollController _scrollController = ScrollController();
  final List<HistoryItem> _items = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger loading more when 200px before bottom
    if (maxScroll - currentScroll <= 200) {
      if (!_isLoadingMore && _hasMore && !_isLoadingInitial) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitial = true;
      _error = null;
      _hasMore = true;
      _offset = 0;
    });

    try {
      final service = context.read<ScanService>();
      final list = await service.getHistory(
        limit: _pageSize,
        offset: 0,
        forceRefresh: forceRefresh,
      );

      final photoItems = list
          .where((e) =>
              (e.imageUrl != null && e.imageUrl!.isNotEmpty) ||
              (e.thumbnailUrl != null && e.thumbnailUrl!.isNotEmpty))
          .toList();

      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(photoItems);
          _offset = list.length;
          _hasMore = list.length >= _pageSize;
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể tải bộ sưu tập ảnh';
          _isLoadingInitial = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final service = context.read<ScanService>();
      final list = await service.getHistory(
        limit: _pageSize,
        offset: _offset,
        forceRefresh: false,
      );

      final photoItems = list
          .where((e) =>
              (e.imageUrl != null && e.imageUrl!.isNotEmpty) ||
              (e.thumbnailUrl != null && e.thumbnailUrl!.isNotEmpty))
          .toList();

      if (mounted) {
        setState(() {
          final existingIds = _items.map((e) => e.id).toSet();
          for (final item in photoItems) {
            if (!existingIds.contains(item.id)) {
              _items.add(item);
            }
          }
          _offset += list.length;
          _hasMore = list.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _showItemOptions(HistoryItem item) {
    final isDark = context.read<AppSettingsProvider>().isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1D24) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.monChinh,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.totalCalo.round()} kcal • C:${item.totalCarb.round()}g P:${item.totalProtein.round()}g F:${item.totalFat.round()}g',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: Color(0xFF2563EB)),
              title: const Text('Xem chi tiết kết quả'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/result/${item.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Color(0xFF10B981)),
              title: const Text('Chia sẻ Card Memory'),
              onTap: () {
                Navigator.pop(ctx);
                ShareCardModal.show(
                  context,
                  CardMemoryData(
                    dishName: item.monChinh,
                    imageUrl: item.imageUrl ?? item.thumbnailUrl,
                    calories: item.totalCalo,
                    carbs: item.totalCarb,
                    protein: item.totalProtein,
                    fat: item.totalFat,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Xóa ảnh này', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(ctx);
                await _confirmAndDelete(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(HistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ảnh món "${item.monChinh}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ScanService>().deleteScan(item.id);
        setState(() {
          _items.removeWhere((e) => e.id == item.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa món ăn khỏi bộ sưu tập')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể xóa. Vui lòng thử lại!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppSettingsProvider>().isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F0E13) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBgColor = isDark ? const Color(0xFF1E1D25) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26242E) : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Ảnh món ăn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: textColor,
        backgroundColor: isDark ? const Color(0xFF1E1D25) : Colors.white,
        onRefresh: () => _loadInitialData(forceRefresh: true),
        child: _buildBody(cardBgColor, textColor, isDark),
      ),
    );
  }

  Widget _buildBody(Color cardBgColor, Color textColor, bool isDark) {
    if (_isLoadingInitial) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: 15,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: cardBgColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: textColor)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadInitialData(forceRefresh: true),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1D25) : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có ảnh scan món ăn nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hãy chụp ảnh món ăn của bạn để lưu lại bộ sưu tập!',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: const Text('Scan món ăn ngay', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _items[index];
                final displayUrl = item.imageUrl ?? item.thumbnailUrl ?? '';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/result/${item.id}'),
                    onLongPress: () => _showItemOptions(item),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Food Image
                            if (displayUrl.isNotEmpty)
                              Image.network(
                                displayUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 300,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (_, __, ___) => Container(
                                  color: cardBgColor,
                                  child: const Icon(Icons.restaurant, color: Colors.grey),
                                ),
                              )
                            else
                              Container(
                                color: cardBgColor,
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              ),

                            // 2. Bottom Soft Dark Gradient for text readability
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.75),
                                    ],
                                    stops: const [0.0, 0.5, 0.75, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // 3. Calorie Badge Overlay at Bottom Left
                            Positioned(
                              left: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${item.totalCalo.round()} kcal',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _items.length,
            ),
          ),
        ),

        // Bottom Loading Indicator when lazy loading more items
        if (_isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
