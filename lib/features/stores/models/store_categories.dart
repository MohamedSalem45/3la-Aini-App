class StoreCategories {
  StoreCategories._();

  static const List<Map<String, String>> all = [
    {'id': 'supermarket', 'label': '\u0633\u0648\u0628\u0631 \u0645\u0627\u0631\u0643\u062a', 'icon': '\ud83c\udfea'},
    {'id': 'pharmacy', 'label': '\u0635\u064a\u062f\u0644\u064a\u0629', 'icon': '\ud83d\udc8a'},
    {'id': 'fruits', 'label': '\u062e\u0636\u0627\u0631 \u0648\u0641\u0648\u0627\u0643\u0647', 'icon': '\ud83e\udd6c'},
    {'id': 'bakery', 'label': '\u0645\u062e\u0628\u0632 \u0648\u062d\u0644\u0648\u064a\u0627\u062a', 'icon': '\ud83c\udf5e'},
    {'id': 'meat', 'label': '\u0644\u062d\u0648\u0645 \u0648\u062f\u0648\u0627\u062c\u0646', 'icon': '\ud83e\udd69'},
    {'id': 'dairy', 'label': '\u0623\u0644\u0628\u0627\u0646 \u0648\u0623\u062c\u0628\u0627\u0646', 'icon': '\ud83e\udd5b'},
    {'id': 'cleaning', 'label': '\u0645\u0648\u0627\u062f \u062a\u0646\u0638\u064a\u0641', 'icon': '\ud83e\uddf9'},
    {'id': 'electronics', 'label': '\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a\u0627\u062a', 'icon': '\ud83d\udcbb'},
    {'id': 'clothes', 'label': '\u0645\u0644\u0627\u0628\u0633', 'icon': '\ud83d\udc57'},
    {'id': 'restaurant', 'label': '\u0645\u0637\u0639\u0645', 'icon': '\ud83c\udf7d\ufe0f'},
    {'id': 'coffee', 'label': '\u0642\u0647\u0648\u0629 \u0648\u0645\u0634\u0631\u0648\u0628\u0627\u062a', 'icon': '\u2615'},
    {'id': 'other', 'label': '\u0623\u062e\u0631\u0649', 'icon': '\ud83d\udce6'},
  ];

  static String labelOf(String id) =>
      all.firstWhere((c) => c['id'] == id,
          orElse: () => all.last)['label']!;

  static String iconOf(String id) =>
      all.firstWhere((c) => c['id'] == id,
          orElse: () => all.last)['icon']!;
}
