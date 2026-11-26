import 'package:material_ui/material_ui.dart';

import '../data/favorites_repository.dart';
import '../models/article.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.article});

  final Article article;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _repository = FavoritesRepository.instance;
  late Future<bool> _status = _repository.contains(widget.article.id);

  Future<bool> _setSaved(bool saved) async {
    await _repository.setSaved(widget.article, saved);
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _status,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return IconButton(
            tooltip: 'Ошибка избранного. Проверить ещё раз',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _status = _repository.contains(widget.article.id);
            }),
          );
        }

        final saved = snapshot.data ?? false;
        final ready = snapshot.connectionState == ConnectionState.done;

        return IconButton(
          tooltip: saved ? 'Убрать из избранного' : 'В избранное',
          icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
          color: saved ? const Color(0xFF006AFF) : null,
          onPressed: ready
              ? () => setState(() {
                  _status = _setSaved(!saved);
                })
              : null,
        );
      },
    );
  }
}
