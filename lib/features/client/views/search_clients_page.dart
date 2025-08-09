import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../data/models/country_model.dart';
import '../providers/client_search_provider.dart';
import '../../../common/providers/country_provider.dart';
import '../widgets/client_card.dart';

class SearchClientsPage extends StatefulWidget {
  const SearchClientsPage({super.key});

  @override
  State<SearchClientsPage> createState() => _SearchClientsPageState();
}

class _SearchClientsPageState extends State<SearchClientsPage> {
  final TextEditingController _searchController = TextEditingController();
  CountryModel? _selectedCountry;
  String _selectedOrdering = '-created_at';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final countryProvider = Provider.of<CountryProvider>(
      context,
      listen: false,
    );
    final searchProvider = Provider.of<ClientsSearchProvider>(
      context,
      listen: false,
    );

    Future.microtask(() async {
      countryProvider.fetchCountries();
      await searchProvider.clearFilters();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        searchProvider.fetchMoreClientsBySearch();
      }
    });
  }

  void _onSearch() {
    final searchProvider = Provider.of<ClientsSearchProvider>(
      context,
      listen: false,
    );

    searchProvider.fetchClientsBySearch(
      search: _searchController.text,
      ordering: _selectedOrdering,
      country: _selectedCountry?.name,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<ClientsSearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Clients"),
        actions: [
          IconButton(
            tooltip: 'Clear Filters',
            icon: const Icon(Iconsax.filter_remove1),
            onPressed: () async {
              setState(() {
                _searchController.clear();
                _selectedCountry = null;
                _selectedOrdering = '-created_at';
              });

              final searchProvider = Provider.of<ClientsSearchProvider>(
                context,
                listen: false,
              );

              // clearFilters now automatically fetches with workspace context
              await searchProvider.clearFilters();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: LabeledTextField(
                    onFieldSubmitted: (_) => _onSearch(),
                    controller: _searchController,
                    hint: 'Search by name, email or mobile',
                    label: '',
                  ),
                ),
                ElevatedButton(
                  onPressed: _onSearch,
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Consumer<CountryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const CircularProgressIndicator();
                } else if (provider.error != null) {
                  return Text(
                    'Error: ${provider.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }

                return DropdownButtonFormField<CountryModel>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.mediumGrey.withValues(alpha: .1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  isExpanded: true,
                  hint: Text(
                    "Select Country",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  style: Theme.of(context).textTheme.bodyMedium,
                  items: provider.countries
                      .map(
                        (country) => DropdownMenuItem(
                          value: country,
                          child: Text(country.name ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCountry = value);
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedOrdering,
              decoration: InputDecoration(
                fillColor: AppColors.mediumGrey.withValues(alpha: .1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              isExpanded: true,
              hint: Text(
                "Sort By",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              items: [
                DropdownMenuItem(
                  value: 'name',
                  child: Text(
                    'Name ↑',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownMenuItem(
                  value: '-name',
                  child: Text(
                    'Name ↓',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownMenuItem(
                  value: 'created_at',
                  child: Text(
                    'Created At ↑',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownMenuItem(
                  value: '-created_at',
                  child: Text(
                    'Created At ↓',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedOrdering = value!);
              },
            ),

            const SizedBox(height: 12),

            // 📋 Search Results
            Expanded(
              child: Builder(
                builder: (_) {
                  if (searchProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (searchProvider.errorMessage != null) {
                    return Center(
                      child: Text(
                        searchProvider.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  if (searchProvider.clients.isEmpty) {
                    return Center(
                      child: Text(
                        'No clients found.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    itemCount:
                        searchProvider.clients.length +
                        (searchProvider.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == searchProvider.clients.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final client = searchProvider.clients[index];
                      return ClientCard(client: client);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
