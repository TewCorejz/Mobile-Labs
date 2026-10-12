import 'package:flutter/material.dart';

import 'data/currency_api_client.dart';
import 'data/currency_repository.dart';
import 'models/currency.dart';
import 'state/converter_state.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key, this.state});

  final ConverterState? state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер валют',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E8A78),
          surface: const Color(0xFFF5F7F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        fontFamily: 'Roboto',
      ),
      home: ConverterPage(state: state),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key, this.state});

  final ConverterState? state;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  late final ConverterState _state;
  late final bool _ownsState;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsState = widget.state == null;
    _state =
        widget.state ??
        ConverterState(repository: ApiCurrencyRepository(CurrencyApiClient()));
    _state.initialize();
  }

  @override
  void dispose() {
    _amountController.dispose();
    if (_ownsState) {
      _state.dispose();
    }
    super.dispose();
  }

  Future<void> _openCurrencyPicker({required bool isSource}) async {
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPicker(state: _state),
    );
    if (selected == null || !mounted) return;

    if (isSource) {
      _state.setSourceCurrency(selected);
    } else {
      _state.setTargetCurrency(selected);
    }
  }

  Future<void> _selectFavorite(Currency currency) async {
    if (currency.code == _state.sourceCurrency.code) {
      await _openCurrencyPicker(isSource: true);
    } else {
      _state.setTargetCurrency(currency);
    }
  }

  Future<void> _openHistory() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConversionHistorySheet(state: _state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                _buildHeader(),
                const SizedBox(height: 26),
                _buildAmountInput(),
                const SizedBox(height: 20),
                _buildCurrencySelectors(),
                if (_state.favoriteCurrencies.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildFavorites(),
                ],
                if (_state.favoritesError != null) ...[
                  const SizedBox(height: 12),
                  _InlineMessage(
                    message: _state.favoritesError!,
                    icon: Icons.info_outline,
                    color: const Color(0xFF8A5A16),
                  ),
                ],
                if (_state.historyError != null) ...[
                  const SizedBox(height: 12),
                  _InlineMessage(
                    message: _state.historyError!,
                    icon: Icons.info_outline,
                    color: const Color(0xFF8A5A16),
                  ),
                ],
                const SizedBox(height: 24),
                _buildConvertButton(),
                const SizedBox(height: 20),
                if (_state.error != null)
                  _InlineMessage(
                    message: _state.error!,
                    icon: Icons.error_outline,
                    color: const Color(0xFFAD3737),
                  ),
                if (_state.isLoading) _buildLoading(),
                if (_state.result != null) _buildResult(),
                if (_state.error == null &&
                    !_state.isLoading &&
                    _state.result == null)
                  _buildHint(),
                const SizedBox(height: 24),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E8A78).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.currency_exchange_rounded,
            color: Color(0xFF1E8A78),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Конвертер валют',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: Color(0xFF182522),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Актуальные курсы в пару касаний',
                style: TextStyle(fontSize: 13, color: Color(0xFF73807C)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          key: const Key('history-button'),
          tooltip: 'История конвертаций',
          onPressed: _openHistory,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E7566),
            side: const BorderSide(color: Color(0xFFE7ECE9)),
          ),
          icon: const Icon(Icons.history_rounded),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('СУММА'),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: _cardDecoration(),
          child: TextField(
            key: const Key('amount-input'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _state.convert(_amountController.text),
            decoration: const InputDecoration(
              hintText: 'Например, 100',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFFA8B1AE)),
            ),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182522),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('ВАЛЮТЫ'),
        const SizedBox(height: 9),
        _currencyRow(
          label: 'Отдаете',
          currency: _state.sourceCurrency,
          onTap: () => _openCurrencyPicker(isSource: true),
        ),
        Center(
          heightFactor: 1,
          child: Transform.translate(
            offset: const Offset(0, -2),
            child: Material(
              color: const Color(0xFF1E8A78),
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('swap-currencies'),
                tooltip: 'Поменять валюты местами',
                onPressed: () =>
                    _state.swapCurrencies(_amountController.text),
                color: Colors.white,
                icon: const Icon(Icons.swap_vert_rounded),
              ),
            ),
          ),
        ),
        _currencyRow(
          label: 'Получаете',
          currency: _state.targetCurrency,
          onTap: () => _openCurrencyPicker(isSource: false),
        ),
      ],
    );
  }

  Widget _currencyRow({
    required String label,
    required Currency currency,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE7ECE9)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF82908B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currency.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF182522),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.code,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF263A34),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF6F7F79),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star_rounded, size: 17, color: Color(0xFFE5A92D)),
            SizedBox(width: 5),
            _SectionLabel('ИЗБРАННЫЕ'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _state.favoriteCurrencies.map((currency) {
            return ActionChip(
              key: Key('favorite-${currency.code}'),
              onPressed: () => _selectFavorite(currency),
              avatar: const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFE5A92D),
              ),
              label: Text(currency.code),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE7ECE9)),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF34443E),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      height: 54,
      child: FilledButton(
        key: const Key('convert-button'),
        onPressed: _state.isLoading
            ? null
            : () => _state.convert(_amountController.text),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1E8A78),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: const Text('Конвертировать'),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: const Column(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF1E8A78),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Получаем свежий курс…',
            style: TextStyle(color: Color(0xFF73807C), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final exchangeRate = _state.exchangeRate!;
    return Container(
      key: const Key('result-card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF173D35),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'РЕЗУЛЬТАТ',
            style: TextStyle(
              color: Color(0xFFB1D2C7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 11),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${_formatAmount(_state.result!)} ${_state.targetCurrency.code}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${_formatAmount(_state.convertedAmount!)} '
            '${_state.sourceCurrency.code} = '
            '${_formatAmount(_state.result!)} ${_state.targetCurrency.code}',
            style: const TextStyle(color: Color(0xFFD2E3DD), fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFF41645B), height: 1),
          ),
          Text(
            '1 ${_state.sourceCurrency.code} = '
            '${_formatAmount(exchangeRate.rate)} ${_state.targetCurrency.code}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Курс на ${_formatDate(exchangeRate.date)} · ExchangeRate-API',
            style: const TextStyle(color: Color(0xFFB1D2C7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF1E8A78), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Введите сумму и выберите валюты — мы покажем результат и дату курса.',
              style: TextStyle(
                color: Color(0xFF52665F),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Курсы предоставлены ExchangeRate-API',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF96A19D), fontSize: 11),
      ),
    );
  }
}

class _CurrencyPicker extends StatefulWidget {
  const _CurrencyPicker({required this.state});

  final ConverterState state;

  @override
  State<_CurrencyPicker> createState() => _CurrencyPickerState();
}

class _ConversionHistorySheet extends StatelessWidget {
  const _ConversionHistorySheet({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => SafeArea(
        top: false,
        child: Material(
          color: const Color(0xFFF8FAF9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DEDA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'История конвертаций',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF182522),
                        ),
                      ),
                    ),
                    if (state.history.isNotEmpty)
                      IconButton(
                        key: const Key('clear-history-button'),
                        tooltip: 'Очистить историю',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Очистить историю?'),
                              content: const Text(
                                'Все записи о конвертациях будут удалены.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Отмена'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Очистить'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await state.clearHistory();
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFAD5353),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: state.history.isEmpty
                    ? const _EmptyHistory()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: state.history.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final entry = state.history[index];
                          return Container(
                            key: Key('history-entry-$index'),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE7ECE9),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_formatAmount(entry.amount)} '
                                        '${entry.sourceCode}  →  '
                                        '${_formatAmount(entry.result)} '
                                        '${entry.targetCode}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF263A34),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.currency_exchange_rounded,
                                      size: 18,
                                      color: Color(0xFF1E8A78),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'Курс: 1 ${entry.sourceCode} = '
                                  '${_formatAmount(entry.rate)} '
                                  '${entry.targetCode}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF73807C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(entry.convertedAt)} '
                                  '${_formatTime(entry.convertedAt)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF96A19D),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (state.historyError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _InlineMessage(
                    message: state.historyError!,
                    icon: Icons.error_outline,
                    color: const Color(0xFFAD3737),
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 42),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF1E8A78).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 28,
              color: Color(0xFF1E8A78),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Пока нет конвертаций',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF263A34),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Выполненные конвертации появятся здесь.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF82908B)),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerState extends State<_CurrencyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currencies = supportedCurrencies.where((currency) {
      final query = _query.toLowerCase();
      return currency.code.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      top: false,
      child: Material(
        color: const Color(0xFFF8FAF9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5DEDA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выберите валюту',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF182522),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    autofocus: false,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Поиск по коду или названию',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE4EBE7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE4EBE7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isFavorite = widget.state.isFavorite(currency);
                  return ListTile(
                    onTap: () => Navigator.pop(context, currency),
                    title: Text(
                      currency.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(currency.code),
                    trailing: IconButton(
                      key: Key('toggle-favorite-${currency.code}'),
                      tooltip: isFavorite
                          ? 'Убрать из избранного'
                          : 'Добавить в избранное',
                      onPressed: () async {
                        await widget.state.toggleFavorite(currency);
                        if (mounted) setState(() {});
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isFavorite
                            ? const Color(0xFFE5A92D)
                            : const Color(0xFF91A09A),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Color(0xFF82908B),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE7ECE9)),
  borderRadius: BorderRadius.circular(18),
);

String _formatAmount(double amount) {
  final fixed = amount.toStringAsFixed(amount.abs() >= 1000 ? 2 : 4);
  final normalized = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  return normalized.replaceAll('.', ',');
}

String _formatDate(DateTime date) {
  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  return '$day.$month.${localDate.year}';
}

String _formatTime(DateTime date) {
  final localDate = date.toLocal();
  return '${localDate.hour.toString().padLeft(2, '0')}:'
      '${localDate.minute.toString().padLeft(2, '0')}';
}
