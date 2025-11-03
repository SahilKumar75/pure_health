import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import '../../data/models/water_body_location.dart';
import '../../data/water_bodies_maharashtra.dart';

class LocationSelector extends StatefulWidget {
  final WaterBodyLocation? selectedLocation;
  final Function(WaterBodyLocation) onLocationSelected;
  final VoidCallback onClearLocation;

  const LocationSelector({
    super.key,
    this.selectedLocation,
    required this.onLocationSelected,
    required this.onClearLocation,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<WaterBodyLocation> _filteredLocations = [];
  String _selectedFilter = 'all'; // all, river, lake, dam, reservoir, coastal

  @override
  void initState() {
    super.initState();
    _filteredLocations = MaharashtraWaterBodies.allWaterBodies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      var locations = _selectedFilter == 'all'
          ? MaharashtraWaterBodies.allWaterBodies
          : MaharashtraWaterBodies.getByType(_selectedFilter);

      if (query.isEmpty) {
        _filteredLocations = locations;
      } else {
        _filteredLocations = locations
            .where((location) =>
                location.name.toLowerCase().contains(query.toLowerCase()) ||
                location.district.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.selectedLocation != null
              ? GovernmentTheme.governmentBlue.withOpacity(0.5)
              : AppColors.borderLight,
          width: widget.selectedLocation != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.map_pin_ellipse,
                color: GovernmentTheme.governmentBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Select Water Body Location',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.selectedLocation != null)
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed: widget.onClearLocation,
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppColors.mediumText,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Selected Location Display
          if (widget.selectedLocation != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GovernmentTheme.governmentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GovernmentTheme.governmentBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTypeChip(widget.selectedLocation!.type),
                      const SizedBox(width: 8),
                      Text(
                        widget.selectedLocation!.district,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.selectedLocation!.name,
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: AppColors.mediumText,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lat: ${widget.selectedLocation!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${widget.selectedLocation!.longitude.toStringAsFixed(4)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterLocations,
                  decoration: InputDecoration(
                    hintText: 'Search by name or district...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.dimText,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: AppColors.mediumText,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppColors.darkBg2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: GovernmentTheme.governmentBlue,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.lightText,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterButton(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Type Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', CupertinoIcons.square_grid_2x2),
                _buildFilterChip('river', 'Rivers', CupertinoIcons.wind),
                _buildFilterChip('lake', 'Lakes', CupertinoIcons.drop),
                _buildFilterChip('dam', 'Dams', CupertinoIcons.building_2_fill),
                _buildFilterChip('reservoir', 'Reservoirs', CupertinoIcons.square_stack_3d_down_right),
                _buildFilterChip('coastal', 'Coastal', CupertinoIcons.waveform),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Locations List
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: AppColors.darkBg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No water bodies found',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mediumText,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredLocations.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.borderLight,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      final isSelected = widget.selectedLocation == location;
                      
                      return InkWell(
                        onTap: () => widget.onLocationSelected(location),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? GovernmentTheme.governmentBlue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildTypeChip(location.type),
                                        const SizedBox(width: 8),
                                        Text(
                                          location.district,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.mediumText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location.name,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.lightText,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lat: ${location.latitude.toStringAsFixed(4)}, '
                                      'Lng: ${location.longitude.toStringAsFixed(4)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.dimText,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: GovernmentTheme.governmentBlue,
                                  size: 20,
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

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = value;
            _filterLocations(_searchController.text);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? GovernmentTheme.governmentBlue
                : AppColors.darkBg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? GovernmentTheme.governmentBlue
                  : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.mediumText,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.buttonSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.lightText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final typeColors = {
      'river': Colors.blue,
      'lake': Colors.cyan,
      'dam': Colors.orange,
      'reservoir': Colors.purple,
      'coastal': Colors.teal,
      'barrage': Colors.amber,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (typeColors[type] ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: typeColors[type] ?? Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Show filter options
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Icon(
          CupertinoIcons.slider_horizontal_3,
          color: AppColors.mediumText,
          size: 18,
        ),
      ),
    );
  }
}
