import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/labeled_text_field.dart';
import '../../../data/models/client_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../client/providers/clients_provider.dart';
import '../providers/cases_search_provider.dart';
import '../widgets/case_card.dart';

class SearchCasesPage extends StatefulWidget {
  const SearchCasesPage({super.key});

  @override
  State<SearchCasesPage> createState() => _SearchCasesPageState();
}

class _SearchCasesPageState extends State<SearchCasesPage> {
  final _searchController = TextEditingController();
  ClientModel? _selectedClient;
  String? _selectedOrdering;
  DateTime? _selectedDateAfter;
  DateTime? _selectedDateBefore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ClientsProvider>(context, listen: false).fetchClients();
        Provider.of<CasesSearchProvider>(context, listen: false).fetchData();
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isAfter) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isAfter) {
          _selectedDateAfter = picked;
        } else {
          _selectedDateBefore = picked;
        }
      });
    }
  }

  void _applyFilters() {
    final provider = Provider.of<CasesSearchProvider>(context, listen: false);
    provider.setSearchText(_searchController.text);
    provider.setClientName(_selectedClient?.name);
    provider.setOrdering(_selectedOrdering);
    provider.setDateAfter(
      _selectedDateAfter?.toIso8601String().split('T').first,
    );
    provider.setDateBefore(
      _selectedDateBefore?.toIso8601String().split('T').first,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedClient = null;
      _selectedOrdering = null;
      _selectedDateAfter = null;
      _selectedDateBefore = null;
    });
    Provider.of<CasesSearchProvider>(context, listen: false).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final casesProvider = Provider.of<CasesSearchProvider>(context);
    final clientsProvider = Provider.of<ClientsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.searchCases)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            LabeledTextField(
              label: '',
              hint: AppLocalizations.of(context)!.search,
              controller: _searchController,
            ),
            const SizedBox(height: 16),

            _buildClientSelectionField(clientsProvider),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedOrdering,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.orderBy,
              ),

              items: [
                DropdownMenuItem(
                  value: 'created_at',
                  child: Text(
                    AppLocalizations.of(context)!.createdAtAsc,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DropdownMenuItem(
                  value: '-created_at',
                  child: Text(
                    AppLocalizations.of(context)!.createdAtDesc,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DropdownMenuItem(
                  value: 'date',
                  child: Text(
                    AppLocalizations.of(context)!.dateAsc,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DropdownMenuItem(
                  value: '-date',
                  child: Text(
                    AppLocalizations.of(context)!.dateDesc,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedOrdering = val);
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      _selectedDateAfter != null
                          ? '${AppLocalizations.of(context)!.after}: ${_selectedDateAfter!.toLocal().toString().split(' ')[0]}'
                          : AppLocalizations.of(context)!.pickDateAfter,
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                      _selectedDateBefore != null
                          ? '${AppLocalizations.of(context)!.before}: ${_selectedDateBefore!.toLocal().toString().split(' ')[0]}'
                          : AppLocalizations.of(context)!.pickDateBefore,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Iconsax.search_normal),
                    onPressed: _applyFilters,
                    label: Text(AppLocalizations.of(context)!.applyFilters),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: Text(AppLocalizations.of(context)!.clear),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ✅ Results
            if (casesProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (casesProvider.errorMessage != null)
              Text(
                '${AppLocalizations.of(context)!.error}: ${casesProvider.errorMessage}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else if (casesProvider.cases.isEmpty)
              _buildEmptyState()
            else
              ...casesProvider.cases.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CaseCard(caseModel: c),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.nothingToDisplayHere,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.youMustAddCasesToShowThem,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSelectionField(ClientsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provider.errorMessage != null) {
      return Text(
        '${AppLocalizations.of(context)!.errorLoadingClients} ${provider.errorMessage}',
      );
    } else {
      return DropdownButtonFormField<ClientModel>(
        value: _selectedClient,

        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.chooseYourClient,
        ),
        items: provider.clients.map((client) {
          return DropdownMenuItem(value: client, child: Text(client.name));
        }).toList(),
        onChanged: (val) => setState(() => _selectedClient = val),
      );
    }
  }
}
