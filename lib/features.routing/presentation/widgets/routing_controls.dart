import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/shared/widgets/country_city_dropdown.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/routing/routing_bloc.dart';

class RoutingControls extends StatelessWidget {
  const RoutingControls({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RoutingBloc>();

    return Positioned(
      top: 20,
      left: 15,
      right: 15,
      child: BlocBuilder<RoutingBloc, RoutingState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Маршрут'),
                onPressed: () => bloc.add(BuildRoute()),
              ),
              CountryCityDropdown(
                initialCountry: state.selectedCountry,
                initialCity: state.selectedCity,
                onSelected: (country, city) {
                  bloc.add(InitValhalla(country, city));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
