import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/info_card.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> list) => _search.isEmpty
      ? list
      : list.where((u) => u.fullName.toLowerCase().contains(_search.toLowerCase()) || u.email.toLowerCase().contains(_search.toLowerCase())).toList();

  void _showEditDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Name', value: user.fullName),
            const SizedBox(height: 8),
            _InfoRow(label: 'Email', value: user.email),
            const SizedBox(height: 8),
            _InfoRow(label: 'Role', value: user.role[0].toUpperCase() + user.role.substring(1)),
            if (user.phone != null) ...[
              const SizedBox(height: 8),
              _InfoRow(label: 'Phone', value: user.phone!),
            ],
            const SizedBox(height: 8),
            _InfoRow(label: 'Status', value: user.isSuspended ? 'Suspended' : 'Active'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSuspendDialog(UserModel user) {
    final isSuspended = user.isSuspended;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSuspended ? 'Reactivate Account' : 'Suspend Account'),
        content: Text(
          isSuspended
              ? 'Reactivate ${user.fullName}\'s account? They will be able to log in again.'
              : 'Suspend ${user.fullName}\'s account? They will be unable to log in.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isSuspended ? AppColors.success : AppColors.warning,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context.read<UserProvider>().suspendUser(user.id, suspend: !isSuspended);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? (isSuspended ? '${user.fullName} reactivated' : '${user.fullName} suspended')
                      : 'Failed to update user'),
                ));
              }
            },
            child: Text(isSuspended ? 'Reactivate' : 'Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Permanently delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context.read<UserProvider>().deleteUser(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? '${user.fullName} deleted' : 'Failed to delete user')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    if (userProv.isLoading && userProv.users.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Manage Users')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final allUsers = userProv.users;
    final students = _filter(allUsers.where((u) => u.role == 'student').toList());
    final interpreters = _filter(allUsers.where((u) => u.role == 'interpreter').toList());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMD), borderSide: BorderSide.none),
                  ),
                ),
              ),
              TabBar(controller: _tabs, tabs: const [Tab(text: 'All'), Tab(text: 'Students'), Tab(text: 'Interpreters')]),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _UserList(users: _filter(allUsers), onEdit: _showEditDialog, onSuspend: _showSuspendDialog, onDelete: _showDeleteDialog),
          _UserList(users: students, onEdit: _showEditDialog, onSuspend: _showSuspendDialog, onDelete: _showDeleteDialog),
          _UserList(users: interpreters, onEdit: _showEditDialog, onSuspend: _showSuspendDialog, onDelete: _showDeleteDialog),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      );
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;
  final void Function(UserModel) onEdit;
  final void Function(UserModel) onSuspend;
  final void Function(UserModel) onDelete;

  const _UserList({
    required this.users,
    required this.onEdit,
    required this.onSuspend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Center(child: Text('No users found', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        return _UserCard(
          user: u,
          isSuspended: u.isSuspended,
          onEdit: () => onEdit(u),
          onSuspend: () => onSuspend(u),
          onDelete: () => onDelete(u),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isSuspended;
  final VoidCallback onEdit;
  final VoidCallback onSuspend;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isSuspended,
    required this.onEdit,
    required this.onSuspend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: ColorFiltered(
            colorFilter: isSuspended
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: UserAvatar(name: user.fullName, imageUrl: user.profilePhoto, radius: 22),
          ),
          title: Text(
            user.fullName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              color: isSuspended ? AppColors.textSecondary : null,
            ),
          ),
          subtitle: Text(
            isSuspended ? '${user.email} • Suspended' : user.email,
            style: TextStyle(
              fontSize: 12,
              color: isSuspended ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge(status: isSuspended ? 'suspended' : user.role),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (v) {
                  if (v == 'Edit') { onEdit(); }
                  else if (v == 'Suspend') { onSuspend(); }
                  else if (v == 'Delete') { onDelete(); }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'Edit', child: Text('View Details')),
                  PopupMenuItem(
                    value: 'Suspend',
                    child: Text(
                      isSuspended ? 'Reactivate Account' : 'Suspend Account',
                      style: TextStyle(color: isSuspended ? AppColors.success : AppColors.warning),
                    ),
                  ),
                  const PopupMenuItem(value: 'Delete', child: Text('Delete User', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
        ),
      );
}
