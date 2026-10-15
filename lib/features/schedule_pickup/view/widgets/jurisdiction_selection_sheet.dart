import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/schedule_pickup_model.dart';

class JurisdictionOption {
  final int id;
  final String title;
  final String? subtitle;
  final dynamic data;

  const JurisdictionOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.data,
  });

  @override
  String toString() => title;
}

class JurisdictionSelectionSheet extends StatefulWidget {
  final String title;
  final String searchHint;
  final Future<List<JurisdictionOption>> Function()? loadItems;
  final List<JurisdictionOption>? initialItems;
  final String selectedItem;
  final int? selectedId;
  final bool isWard;
  final ValueChanged<JurisdictionOption> onSelect;

  const JurisdictionSelectionSheet({
    super.key,
    required this.title,
    required this.searchHint,
    this.loadItems,
    this.initialItems,
    required this.selectedItem,
    this.selectedId,
    this.isWard = false,
    required this.onSelect,
  });

  @override
  State<JurisdictionSelectionSheet> createState() =>
      _JurisdictionSelectionSheetState();
}

class _JurisdictionSelectionSheetState
    extends State<JurisdictionSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<JurisdictionOption> _allItems = [];
  List<JurisdictionOption> _filteredItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      _allItems = widget.initialItems!;
      _filteredItems = widget.initialItems!;
      _isLoading = false;
    } else if (widget.loadItems != null) {
      _isLoading = true;
      _fetchItems();
    }
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchItems() async {
    if (widget.loadItems == null) return;
    setState(() => _isLoading = true);
    try {
      final items = await widget.loadItems!();
      if (mounted) {
        setState(() {
          _allItems = items;
          _filteredItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allItems = [];
          _filteredItems = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          final matchesTitle = item.title.toLowerCase().contains(query);
          final matchesSubtitle =
              item.subtitle?.toLowerCase().contains(query) ?? false;
          return matchesTitle || matchesSubtitle;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Row (Title & Close Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Search Box
          Container(
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      hintStyle: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB0BEC5),
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Content List / Loader / Empty View
          Flexible(
            child: _isLoading
                ? Container(
                    height: 180.h,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF166534),
                          strokeWidth: 3.0,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Loading options...',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredItems.isEmpty
                    ? Container(
                        height: 140.h,
                        alignment: Alignment.center,
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = (widget.selectedId != null &&
                                  widget.selectedId == item.id) ||
                              widget.selectedItem == item.title;

                          final wardNumber = item.data is WardModel &&
                                  (item.data as WardModel).wardNumber > 0
                              ? (item.data as WardModel).wardNumber.toString()
                              : '${index + 1}';

                          return InkWell(
                            onTap: () {
                              widget.onSelect(item);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0FDF4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF166534)
                                      : const Color(0xFFF1F5F9),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Left Icon / Number
                                  if (widget.isWard)
                                    Container(
                                      width: 36.w,
                                      height: 36.w,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE8F6EF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          wardNumber,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF166534),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 36.w,
                                      height: 36.w,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          item.subtitle != null
                                              ? Icons.location_city_rounded
                                              : Icons.landscape_rounded,
                                          color: const Color(0xFF64748B),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 14.w),

                                  // Title & Subtitle Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 14.5.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        if (item.subtitle != null &&
                                            item.subtitle!.isNotEmpty) ...[
                                          SizedBox(height: 2.h),
                                          Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Checkmark Icon when selected
                                  if (isSelected)
                                    Container(
                                      width: 22.w,
                                      height: 22.w,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF166534),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
