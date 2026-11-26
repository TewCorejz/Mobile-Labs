import 'package:material_ui/material_ui.dart';

import 'package:flutter/services.dart';

class NewsSearchTitle extends StatefulWidget {
  const NewsSearchTitle({super.key, required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<NewsSearchTitle> createState() => _NewsSearchTitleState();
}

class _NewsSearchTitleState extends State<NewsSearchTitle> {
  final _controller = TextEditingController();
  late final _focusNode = FocusNode(onKeyEvent: _handleKey);

  bool _isSearching = false;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;

    if (event is KeyDownEvent &&
        isEnter &&
        _controller.value.composing.isCollapsed) {
      widget.onSearch(_controller.text);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _toggleSearch() {
    setState(() => _isSearching = !_isSearching);

    if (_isSearching) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      _controller.clear();
      widget.onSearch('');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _isSearching
              ? TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: widget.onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Поиск новостей',
                    border: InputBorder.none,
                  ),
                )
              : const Text(
                  'Новости',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
        IconButton(
          tooltip: _isSearching ? 'Закрыть поиск' : 'Поиск',
          onPressed: _toggleSearch,
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: const Color(0xFF006AFF),
          ),
        ),
      ],
    );
  }
}
