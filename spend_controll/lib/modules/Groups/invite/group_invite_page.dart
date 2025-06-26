import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/invite/controller/group_invite_controller.dart';
import 'package:spend_controll/modules/Groups/invite/controller/group_invite_state.dart';
import 'package:spend_controll/modules/Groups/model/group_invitation_model.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/shared/widgets/appBar.dart';
import 'package:spend_controll/shared/widgets/button.dart';

class GroupInvitePage extends StatefulWidget {
  final GroupInviteController controller;
  final Group group;

  const GroupInvitePage({
    super.key,
    required this.controller,
    required this.group,
  });

  @override
  State<GroupInvitePage> createState() => _GroupInvitePageState();
}

class _GroupInvitePageState extends State<GroupInvitePage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.controller,
      child: BlocConsumer<GroupInviteController, GroupInviteState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            widget.controller.resetMessages();
          }

          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            widget.controller.resetMessages();

            if (state.inviteStatus == InviteStatus.success) {
              _emailController.clear();
              widget.controller.resetSearch();
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: const AppBarWidget(
              pageTitle: 'Convidar Membros',
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(context, state),
                  const SizedBox(height: 24),
                  _buildPendingInvitationsSection(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, GroupInviteState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicionar novo membro',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Digite o email do usuário que você deseja convidar para o grupo ${widget.group.name}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email do usuário',
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: state.searchStatus != SearchStatus.loading,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: state.searchStatus == SearchStatus.loading
                  ? null
                  : () {
                      widget.controller
                          .searchUserByEmail(_emailController.text);
                    },
              child: state.searchStatus == SearchStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Buscar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.searchStatus == SearchStatus.success &&
            state.foundUser != null)
          _buildUserSearchResult(context, state),
      ],
    );
  }

  Widget _buildUserSearchResult(BuildContext context, GroupInviteState state) {
    final user = state.foundUser!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName![0].toUpperCase()
                        : user.email[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Usuário',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.hasExistingInvite)
              const Text(
                'Este usuário já possui um convite pendente para este grupo.',
                style: TextStyle(
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Button(
                text: 'Enviar Convite',
                onPressed: () {
                  widget.controller.sendInvitation(user.email);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingInvitationsSection(
      BuildContext context, GroupInviteState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Convites Pendentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (state.invitationsStatus == InvitationsStatus.loaded)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => widget.controller.loadPendingInvitations(),
                tooltip: 'Atualizar convites',
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.invitationsStatus == InvitationsStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.invitationsStatus == InvitationsStatus.loaded)
          state.pendingInvitations.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'Nenhum convite pendente',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.pendingInvitations.length,
                  itemBuilder: (context, index) {
                    final invitation = state.pendingInvitations[index];
                    return _buildInvitationItem(context, invitation);
                  },
                )
        else if (state.invitationsStatus == InvitationsStatus.error)
          Center(
            child: Column(
              children: [
                const Text(
                  'Erro ao carregar convites',
                  style: TextStyle(color: Colors.red),
                ),
                TextButton(
                  onPressed: () => widget.controller.loadPendingInvitations(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInvitationItem(
      BuildContext context, GroupInvitation invitation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(invitation.inviteeEmail),
        subtitle: Text(
          'Enviado em ${_formatDate(invitation.createdAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          onPressed: () => _showCancelConfirmation(context, invitation),
          tooltip: 'Cancelar convite',
        ),
      ),
    );
  }

  void _showCancelConfirmation(
      BuildContext context, GroupInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Convite'),
        content: Text(
          'Tem certeza que deseja cancelar o convite para ${invitation.inviteeEmail}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.cancelInvitation(invitation.id);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
