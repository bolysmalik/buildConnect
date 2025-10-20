import 'package:flutter/material.dart';

typedef OnCitySelected = void Function(String country, String city);

class CountryCityDropdown extends StatefulWidget {
  final OnCitySelected onSelected;
  final String? initialCountry;
  final String? initialCity;

  const CountryCityDropdown({
    super.key,
    required this.onSelected,
    this.initialCountry,
    this.initialCity,
  });

  @override
  State<CountryCityDropdown> createState() => _CountryCityDropdownState();
}

class _CountryCityDropdownState extends State<CountryCityDropdown> {
  final Map<String, List<String>> countryCityMap = {
    'kazakhstan': ['almaty', 'valhalla_almaty', 'astana'],
    'usa': ['new_york', 'los_angeles'],
  };

  late String selectedCountry;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.initialCountry != null && countryCityMap.containsKey(widget.initialCountry)
        ? widget.initialCountry!
        : countryCityMap.keys.first;

    final cities = countryCityMap[selectedCountry] ?? [];
    selectedCity = widget.initialCity != null && cities.contains(widget.initialCity)
        ? widget.initialCity
        : (cities.isNotEmpty ? cities.first : null);

    if (selectedCity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelected(selectedCountry, selectedCity!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = countryCityMap[selectedCountry] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130, // ширина страны
          child: DropdownButton<String>(
            isExpanded: true, // важно!
            value: selectedCountry,
            onChanged: (country) {
              if (country != null && countryCityMap.containsKey(country)) {
                setState(() {
                  selectedCountry = country;
                  final newCities = countryCityMap[country]!;
                  selectedCity = newCities.isNotEmpty ? newCities.first : null;
                });
                if (selectedCity != null) {
                  widget.onSelected(selectedCountry, selectedCity!);
                }
              }
            },
            items: countryCityMap.keys
                .map((country) => DropdownMenuItem(
              value: country,
              child: Text(
                country.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),

          ))
                .toList(),
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          width: 130, // ширина города
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedCity,
            onChanged: (city) {
              if (city != null) {
                setState(() => selectedCity = city);
                widget.onSelected(selectedCountry, selectedCity!);
              }
            },
            items: cities
                .map((city) => DropdownMenuItem(
              value: city,
              child:  Text(
                city.replaceAll('_', ' ').toUpperCase(),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
