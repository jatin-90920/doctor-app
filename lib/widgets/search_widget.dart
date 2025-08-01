import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final TextEditingController? controller;

  const SearchWidget({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.onClear,
    this.autofocus = false,
    this.controller,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onSearchChanged(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            MdiIcons.magnify,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    MdiIcons.close,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final List<String> availableFilters;
  final Map<String, dynamic> initialFilters;

  const AdvancedSearchWidget({
    super.key,
    required this.onFiltersChanged,
    required this.availableFilters,
    this.initialFilters = const {},
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  late Map<String, dynamic> _filters;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null || value == '' || (value is List && value.isEmpty)) {
        _filters.remove(key);
      } else {
        _filters[key] = value;
      }
    });
    widget.onFiltersChanged(_filters);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _isExpanded = false;
    });
    widget.onFiltersChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.filterVariant,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Advanced Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_filters.isNotEmpty)
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear All'),
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? MdiIcons.chevronUp : MdiIcons.chevronDown,
                  ),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: widget.availableFilters.map((filter) {
                  return _buildFilterChip(filter);
                }).toList(),
              ),
            ],
            if (_filters.isNotEmpty && !_isExpanded) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filters.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    onDeleted: () => _updateFilter(entry.key, null),
                    deleteIcon: Icon(MdiIcons.close, size: 16),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isActive = _filters.containsKey(filter);
    
    return FilterChip(
      label: Text(filter),
      selected: isActive,
      onSelected: (selected) {
        if (selected) {
          _showFilterDialog(filter);
        } else {
          _updateFilter(filter, null);
        }
      },
      avatar: isActive ? Icon(MdiIcons.check, size: 16) : null,
    );
  }

  void _showFilterDialog(String filter) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        filterName: filter,
        currentValue: _filters[filter],
        onValueChanged: (value) => _updateFilter(filter, value),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final String filterName;
  final dynamic currentValue;
  final Function(dynamic) onValueChanged;

  const FilterDialog({
    super.key,
    required this.filterName,
    this.currentValue,
    required this.onValueChanged,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _controller;
  dynamic _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
    _controller = TextEditingController(
      text: _value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter by ${widget.filterName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter ${widget.filterName.toLowerCase()}',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _value = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onValueChanged(_value);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

