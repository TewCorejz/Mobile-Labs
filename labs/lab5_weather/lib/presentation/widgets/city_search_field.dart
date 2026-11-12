import 'package:material_ui/material_ui.dart';

import '../theme/sky_colors.dart';

class CitySearchField extends StatefulWidget {
  const CitySearchField({
    super.key,
    required this.query,
    required this.onSearch,
    required this.onChanged,
    this.errorText,
    this.isLoading = false,
  });

  final String query;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isLoading;

  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  late final _controller = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(CitySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.words,
      onChanged: widget.onChanged,
      onSubmitted: (_) => _submit(),
      cursorColor: SkyColors.foreground,
      style: const TextStyle(color: SkyColors.foreground, fontSize: 17),
      decoration: InputDecoration(
        hintText: 'Название города',
        hintStyle: const TextStyle(color: SkyColors.secondaryForeground),
        errorText: widget.errorText,
        errorStyle: const TextStyle(color: SkyColors.errorText),
        filled: true,
        fillColor: SkyColors.glass,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        prefixIcon: const Icon(Icons.location_on, color: SkyColors.foreground),
        suffixIcon: IconButton(
          tooltip: 'Найти',
          icon: const Icon(Icons.search, color: SkyColors.foreground),
          onPressed: widget.isLoading ? null : _submit,
        ),
      ),
    );
  }
}