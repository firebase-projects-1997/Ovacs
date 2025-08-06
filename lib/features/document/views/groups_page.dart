import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:provider/provider.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import 'package:new_ovacs/data/models/document_group_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../main.dart';
import '../providers/groups_provider.dart';
import 'group_details_page.dart';

class GroupsPage extends StatefulWidget {
  final int sessionId;
  const GroupsPage({super.key, required this.sessionId});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GroupsProvider>(
        context,
        listen: false,
      ).fetchGroupsBySession(widget.sessionId);
    });
  }

  void _showEditDialog(DocumentGroupModel group) {
    final nameController = TextEditingController(text: group.name);
    final descriptionController = TextEditingController(
      text: group.description,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<GroupsProvider>(
                dialogContext,
                listen: false,
              );
              final success = await provider.updateGroup(
                groupId: group.id,
                name: nameController.text,
                description: descriptionController.text,
                sessionId: widget.sessionId,
              );
              if (success) {
                Provider.of<GroupsProvider>(
                  context,
                  listen: false,
                ).fetchGroupsBySession(widget.sessionId);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(DocumentGroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<GroupsProvider>(
                context,
                listen: false,
              );
              final success = await provider.deleteGroup(group.id);
              if (success) {
                Provider.of<GroupsProvider>(
                  context,
                  listen: false,
                ).fetchGroupsBySession(widget.sessionId);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<GroupsProvider>(
                context,
                listen: false,
              );
              final success = await provider.createGroup(
                sessionId: widget.sessionId,
                name: nameController.text,
                description: descriptionController.text,
              );
              if (success) {
                Provider.of<GroupsProvider>(
                  context,
                  listen: false,
                ).fetchGroupsBySession(widget.sessionId);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsProvider = Provider.of<GroupsProvider>(context);
    final groups = groupsProvider.groups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Folders'),
        actions: [
          IconButton(
            icon: Icon(Iconsax.add_circle),
            onPressed: _showAddGroupDialog,
            tooltip: 'Add Folder',
          ),
        ],
      ),
      body: groupsProvider.status == GroupsStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : groupsProvider.status == GroupsStatus.error
          ? Center(child: Text(groupsProvider.errorMessage ?? 'Error'))
          : ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 10),
              padding: AppSizes.noAppBarPadding(context),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return RoundedContainer(
                  onTap: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => GroupDetailsPage(
                          groupId: group.id,
                          sessionId: widget.sessionId,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.folder5,
                        size: 75,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(group);
                          } else if (value == 'delete') {
                            _showDeleteDialog(group);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(
                                  Iconsax.edit,
                                  size: 18,
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(
                                  Iconsax.trash,
                                  size: 18,
                                  color: AppColors.red,
                                ),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(Iconsax.more_circle),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
