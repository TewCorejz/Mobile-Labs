enum PressureUnit {
  mmHg(label: 'мм рт. ст.', shortLabel: 'мм', hpaFactor: 0.750062),
  hPa(label: 'гПа', shortLabel: 'гПа', hpaFactor: 1);

  const PressureUnit({
    required this.label,
    required this.shortLabel,
    required this.hpaFactor,
  });

  final String label;
  final String shortLabel;
  final double hpaFactor;

  int fromHpa(double hpa) => (hpa * hpaFactor).round();
}