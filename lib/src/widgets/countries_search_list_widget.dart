import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final bool autoFocus;
  final bool? showFlags;
  final bool? useEmoji;
  final VoidCallback? onBack;
  final String textBar;
  final TextStyle textBarStyle;

  CountrySearchListWidget(
      this.countries,
      this.locale,
      this.textBar,
      this.textBarStyle, {
        this.searchBoxDecoration,
        this.showFlags,
        this.onBack,
        this.useEmoji,
        this.autoFocus = false,
      });

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;
  bool _expanded = false;

  @override
  void initState() {
    final String value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ??
        InputDecoration(labelText: 'Search by country name or dial code');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              color: Colors.black,
            ),
            Text(
              widget.textBar,
              style: widget.textBarStyle,
            ),
            Spacer(),
            Expanded(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: const Icon(
                  Icons.search,
                ),
                color: Colors.black,
              ),
            ),
          ],
        ),
        AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: _expanded ? MediaQuery.of(context).size.height * 0.05 : 0,
            width: MediaQuery.of(context).size.width,
            child: itemExpanded()
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredCountries.length,
            itemBuilder: (BuildContext context, int index) {
              Country country = filteredCountries[index];
              return DirectionalCountryListTile(
                country: country,
                locale: widget.locale,
                showFlags: widget.showFlags!,
                useEmoji: widget.useEmoji!,
              );
            },
          ),
        ),
      ],
    );
  }

  //#region Widgets

  Widget itemExpanded() {
    return Container(
      height: _expanded ? MediaQuery.of(context).size.height * 0.05 : 0,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Flexible(
            child: TextFormField(
              key: Key(TestHelper.CountrySearchInputKeyValue),
              decoration: getSearchBoxDecoration(),
              controller: _searchController,
              autofocus: widget.autoFocus,
              onChanged: (value) {
                final String value = _searchController.text.trim();
                return setState(
                      () => filteredCountries = Utils.filterCountries(
                    countries: widget.countries,
                    locale: widget.locale,
                    value: value,
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _searchController.text = "";
                _searchController.clear();
                filteredCountries = Utils.filterCountries(
                  countries: widget.countries,
                  locale: widget.locale,
                  value: "",
                );
              });
            },
            icon: const Icon(
              Icons.close,
            ),
            color: _expanded ? Colors.black : Colors.transparent,
            disabledColor: Colors.white,
          ),
        ],
      ),
    );
  }

  //#endregion

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  final Country country;
  final String? locale;
  final bool showFlags;
  final bool useEmoji;

  const DirectionalCountryListTile({
    Key? key,
    required this.country,
    required this.locale,
    required this.showFlags,
    required this.useEmoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
      leading: (showFlags ? _Flag(country: country, useEmoji: useEmoji) : null),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${Utils.getCountryName(country, locale)}',
          textDirection: Directionality.of(context),
          textAlign: TextAlign.start,
        ),
      ),
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${country.dialCode ?? ''}',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
        ),
      ),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? useEmoji;

  const _Flag({Key? key, this.country, this.useEmoji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return country != null
        ? Container(
      child: useEmoji!
          ? Text(
        Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
        style: Theme.of(context).textTheme.headline5,
      )
          : country?.flagUri != null
          ? CircleAvatar(
        backgroundImage: AssetImage(
          country!.flagUri,
          package: 'intl_phone_number_input',
        ),
      )
          : SizedBox.shrink(),
    )
        : SizedBox.shrink();
  }
}
