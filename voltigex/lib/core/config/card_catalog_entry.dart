class CardCatalogEntry {
  const CardCatalogEntry({
    required this.key,
    required this.labels,
    this.imageUrl,
    this.sort = 0,
    this.amount = 0,
  });

  final String key;
  final Map<String, String> labels;
  final String? imageUrl;
  final int sort;
  final double amount;

  String labelForLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    return labels[code] ??
        labels['fr'] ??
        labels['en'] ??
        key;
  }

  factory CardCatalogEntry.fromJson(Map<String, dynamic> json) {
    final labelsRaw = json['labels'];
    final labels = <String, String>{};
    if (labelsRaw is Map) {
      labelsRaw.forEach((k, v) {
        labels[k.toString()] = v.toString();
      });
    }
    final image = json['image_url']?.toString().trim();
    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw?.toString().replaceAll(',', '.') ?? '') ?? 0;

    return CardCatalogEntry(
      key: json['key']?.toString() ?? '',
      labels: labels,
      imageUrl: (image == null || image.isEmpty) ? null : image,
      sort: int.tryParse(json['sort']?.toString() ?? '') ?? 0,
      amount: amount,
    );
  }
}
