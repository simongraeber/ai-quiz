import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';

/// This widget is used to display a dropdown menu with all the available languages
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? Localizations.localeOf(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: locale,
        icon: const SizedBox(width: 12),
        items: L10n.all.map(
              (locale) {
            final String flag = L10n.getFlag(locale.languageCode);
            return DropdownMenuItem(
              value: locale,
              onTap: () {
                final provider =
                Provider.of<LocaleProvider>(context, listen: false);

                // set the new locale and notify the app
                provider.setLocale(locale);
              },
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            );
          },
        ).toList(),
        onChanged: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
  }
}