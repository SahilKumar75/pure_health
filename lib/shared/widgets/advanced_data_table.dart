import 'package:flutter/material.dart';
import 'package:pure_health/core/theme/government_theme.dart';
import 'package:pure_health/core/theme/text_styles.dart';

/// Advanced data table with sorting, filtering, and pagination for government use
class AdvancedDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataTableColumn> columns;
  final Function(Map<String, dynamic>)? onRowTap;
  final bool showFilters;
  final bool showPagination;
  final int rowsPerPage;
  final String? emptyMessage;

  const AdvancedDataTable({
    Key? key,
    required this.data,
    required this.columns,
    this.onRowTap,
    this.showFilters = true,
    this.showPagination = true,
    this.rowsPerPage = 10,
    this.emptyMessage,
  }) : super(key: key);

  @override
  State<AdvancedDataTable> createState() => _AdvancedDataTableState();
}

class _AdvancedDataTableState extends State<AdvancedDataTable> {
  late List<Map<String, dynamic>> _filteredData;
  int _currentPage = 0;
  String? _sortColumn;
  bool _sortAscending = true;
  final Map<String, TextEditingController> _filterControllers = {};

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(widget.data);
    for (var column in widget.columns) {
      if (column.filterable) {
        _filterControllers[column.key] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _filterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredData = widget.data.where((row) {
        for (var entry in _filterControllers.entries) {
          final filterValue = entry.value.text.toLowerCase();
          if (filterValue.isEmpty) continue;
          
          final cellValue = row[entry.key]?.toString().toLowerCase() ?? '';
          if (!cellValue.contains(filterValue)) {
            return false;
          }
        }
        return true;
      }).toList();
      _currentPage = 0;
    });
  }

  void _sortData(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnKey;
        _sortAscending = true;
      }

      _filteredData.sort((a, b) {
        final aValue = a[columnKey];
        final bValue = b[columnKey];

        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return _sortAscending ? 1 : -1;
        if (bValue == null) return _sortAscending ? -1 : 1;

        int comparison;
        if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }

        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  List<Map<String, dynamic>> _getPaginatedData() {
    if (!widget.showPagination) {
      return _filteredData;
    }

    final startIndex = _currentPage * widget.rowsPerPage;
    final endIndex = (startIndex + widget.rowsPerPage).clamp(0, _filteredData.length);
    
    if (startIndex >= _filteredData.length) {
      return [];
    }
    
    return _filteredData.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredData.length / widget.rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return GovernmentCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showFilters) _buildFilters(),
          _buildTable(),
          if (widget.showPagination && _totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentTheme.governmentWhite,
        border: Border(
          bottom: BorderSide(
            color: GovernmentTheme.governmentBorder,
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: widget.columns
            .where((col) => col.filterable)
            .map((col) => SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _filterControllers[col.key],
                    decoration: InputDecoration(
                      labelText: 'Filter ${col.label}',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _filterControllers[col.key]?.clear();
                          _applyFilters();
                        },
                      ),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTable() {
    if (_filteredData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            widget.emptyMessage ?? 'No data available',
            style: AppTextStyles.body.copyWith(
              color: GovernmentTheme.governmentGray,
            ),
          ),
        ),
      );
    }

    final paginatedData = _getPaginatedData();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          GovernmentTheme.governmentWhite,
        ),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return GovernmentTheme.governmentBlue.withOpacity(0.05);
          }
          return Colors.white;
        }),
        columns: widget.columns.map((col) {
          return DataColumn(
            label: Row(
              children: [
                Text(
                  col.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: GovernmentTheme.governmentBlue,
                  ),
                ),
                if (col.sortable) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _sortColumn == col.key
                        ? (_sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : Icons.unfold_more,
                    size: 16,
                    color: GovernmentTheme.governmentGray,
                  ),
                ],
              ],
            ),
            onSort: col.sortable
                ? (_, __) => _sortData(col.key)
                : null,
          );
        }).toList(),
        rows: paginatedData.map((row) {
          return DataRow(
            onSelectChanged: widget.onRowTap != null
                ? (_) => widget.onRowTap!(row)
                : null,
            cells: widget.columns.map((col) {
              final value = row[col.key];
              final formattedValue = col.formatter != null
                  ? col.formatter!(value)
                  : value?.toString() ?? '-';

              return DataCell(
                Text(
                  formattedValue,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: GovernmentTheme.governmentGray,
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: GovernmentTheme.governmentBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_currentPage * widget.rowsPerPage + 1}-${((_currentPage + 1) * widget.rowsPerPage).clamp(0, _filteredData.length)} of ${_filteredData.length} records',
            style: AppTextStyles.bodySmall.copyWith(
              color: GovernmentTheme.governmentGray,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: AppTextStyles.bodySmall.copyWith(
                  color: GovernmentTheme.governmentGray,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Column configuration for AdvancedDataTable
class DataTableColumn {
  final String key;
  final String label;
  final bool sortable;
  final bool filterable;
  final String Function(dynamic)? formatter;

  const DataTableColumn({
    required this.key,
    required this.label,
    this.sortable = true,
    this.filterable = true,
    this.formatter,
  });
}
