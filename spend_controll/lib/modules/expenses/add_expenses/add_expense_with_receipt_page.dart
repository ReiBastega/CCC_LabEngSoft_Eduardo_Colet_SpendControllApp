import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';
import 'package:spend_controll/modules/expenses/add_expenses/controller/receipt_upload_controller.dart';
import 'package:spend_controll/modules/expenses/expense/model/expense_model.dart';
import 'package:spend_controll/modules/service/service.dart';
import 'package:spend_controll/shared/widgets/appBar.dart';
import 'package:spend_controll/shared/widgets/custom_button.dart';
import 'package:spend_controll/shared/widgets/custom_text_field.dart';

class AddExpenseWithReceiptPage extends StatefulWidget {
  final Group group;

  const AddExpenseWithReceiptPage({
    super.key,
    required this.group,
  });

  @override
  State<AddExpenseWithReceiptPage> createState() =>
      _AddExpenseWithReceiptPageState();
}

class _AddExpenseWithReceiptPageState extends State<AddExpenseWithReceiptPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late final ReceiptUploadController _receiptController;
  String? _selectedMemberId;
  List<String> _selectedParticipantIds = [];

  @override
  void initState() {
    super.initState();
    _receiptController = ReceiptUploadController(
      service: context.read<Service>(),
    );

    _selectedMemberId = context.read<Service>().getCurrentUserId();

    _selectedParticipantIds = List.from(widget.group.memberUserIds);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _receiptController),
      ],
      child: BlocConsumer<ReceiptUploadController, ReceiptUploadState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            _receiptController.clearError();
          }

          if (state.status == UploadStatus.complete) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Despesa adicionada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: const AppBarWidget(
              pageTitle: 'Adicionar Despesa',
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpenseForm(context),
                  const SizedBox(height: 24),
                  _buildPayerSelection(context),
                  const SizedBox(height: 24),
                  _buildParticipantsSelection(context),
                  const SizedBox(height: 24),
                  _buildReceiptUploadSection(context, state),
                  const SizedBox(height: 32),
                  _buildSaveButton(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes da Despesa',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _descriptionController,
          hintText: 'Descrição da despesa',
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _amountController,
          hintText: 'Valor (R\$)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
      ],
    );
  }

  Widget _buildPayerSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quem pagou?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, String>>(
          future: _loadMemberNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Erro ao carregar membros');
            }

            final memberNames = snapshot.data!;

            return DropdownButtonFormField<String>(
              value: _selectedMemberId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: memberNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMemberId = value;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticipantsSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participantes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione quem vai dividir esta despesa',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, String>>(
          future: _loadMemberNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Erro ao carregar membros');
            }

            final memberNames = snapshot.data!;

            return Column(
              children: [
                CheckboxListTile(
                  title: const Text('Selecionar todos'),
                  value: _selectedParticipantIds.length ==
                      widget.group.memberUserIds.length,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedParticipantIds =
                            List.from(widget.group.memberUserIds);
                      } else {
                        _selectedParticipantIds = [];
                      }
                    });
                  },
                ),
                const Divider(),
                ...memberNames.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.value),
                    value: _selectedParticipantIds.contains(entry.key),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedParticipantIds.add(entry.key);
                        } else {
                          _selectedParticipantIds.remove(entry.key);
                        }
                      });
                    },
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildReceiptUploadSection(
      BuildContext context, ReceiptUploadState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprovante',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Adicione uma foto do comprovante (opcional)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (state.imageFile != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    state.imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _receiptController.removeSelectedImage(),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
                onPressed: state.status == UploadStatus.selecting
                    ? null
                    : () => _receiptController.pickImageFromGallery(),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Câmera'),
                onPressed: state.status == UploadStatus.selecting
                    ? null
                    : () => _receiptController.takePhoto(),
              ),
            ],
          ),
        if (state.status == UploadStatus.uploading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                LinearProgressIndicator(value: state.uploadProgress),
                const SizedBox(height: 8),
                Text(
                  'Enviando comprovante... ${(state.uploadProgress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, ReceiptUploadState state) {
    final isLoading = state.status == UploadStatus.uploading ||
        state.status == UploadStatus.updating;

    return CustomButton(
      text: 'Salvar Despesa',
      isLoading: isLoading,
      onPressed: isLoading ? null : _saveExpense,
    );
  }

  // Carrega os nomes dos membros do grupo
  Future<Map<String, String>> _loadMemberNames() async {
    final Map<String, String> memberNames = {};

    for (final memberId in widget.group.memberUserIds) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          memberNames[memberId] = data['displayName'] ?? 'Usuário';
        } else {
          memberNames[memberId] = 'Usuário Desconhecido';
        }
      } catch (e) {
        memberNames[memberId] = 'Erro ao carregar usuário';
      }
    }

    return memberNames;
  }

  // Salva a despesa e faz upload do comprovante se houver
  void _saveExpense() async {
    // Validação básica
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe uma descrição'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um valor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione quem pagou'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedParticipantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um participante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      final expenseId = await context.read<Service>().addExpenseWithId(
            Expense(
              id: '',
              groupId: widget.group.id,
              description: _descriptionController.text,
              amount: amount,
              categoryId: '',
              payerUserId: _selectedMemberId!,
              participantsUserIds: _selectedParticipantIds,
              createdAt: Timestamp.now(),
              receiptImageUrl: null,
              createdByUserId: context.read<Service>().getCurrentUserId()!,
              type: '',
            ),
          );

      if (_receiptController.state.imageFile != null) {
        await _receiptController.uploadReceipt(
          groupId: widget.group.id,
          expenseId: expenseId,
        );

        await _receiptController.updateExpenseWithReceipt(
          groupId: widget.group.id,
          expenseId: expenseId,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Despesa adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar despesa: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
