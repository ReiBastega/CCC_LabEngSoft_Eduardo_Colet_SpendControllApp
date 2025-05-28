import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

import 'controller/add_income_controller.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _observationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedGroupId;
  String? _selectedCategory;

  final AddIncomeController controller = Modular.get<AddIncomeController>();

  @override
  void initState() {
    super.initState();
    controller.loadGroups();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Receita'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(controller.state.errorMessage ?? 'Erro desconhecido'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.loadGroups,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Descrição
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              hintText: 'Ex: Salário mensal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe uma descrição';
              }
              if (value.length > 100) {
                return 'A descrição deve ter no máximo 100 caracteres';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Valor
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Valor (R\$)',
              hintText: 'Ex: 1500,00',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe um valor';
              }

              final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
              final amount = double.tryParse(cleanValue);

              if (amount == null) {
                return 'Valor inválido';
              }

              if (amount <= 0) {
                return 'O valor deve ser maior que zero';
              }

              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Data
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Grupo
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Grupo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.group),
            ),
            value: _selectedGroupId,
            items: controller.state.groups.map((group) {
              return DropdownMenuItem<String>(
                value: group.id,
                child: Text(group.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGroupId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione um grupo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Categoria
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            value: _selectedCategory,
            items: _getIncomeCategories().map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Observações
          TextFormField(
            controller: _observationController,
            decoration: const InputDecoration(
              labelText: 'Observações (opcional)',
              hintText: 'Informações adicionais sobre a receita',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Botão de Salvar
          ElevatedButton(
            onPressed: controller.state.isSaving ? null : _saveIncome,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: controller.state.isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Salvando...'),
                    ],
                  )
                : const Text('Salvar Receita'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      // Formatar valor para double
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.parse(cleanValue);

      // Encontrar nome do grupo selecionado
      final selectedGroup = controller.state.groups.firstWhere(
        (group) => group.id == _selectedGroupId,
      );

      final result = await controller.saveIncome(
        description: _descriptionController.text,
        amount: amount,
        date: _selectedDate,
        groupId: _selectedGroupId!,
        groupName: selectedGroup.name,
        category: _selectedCategory,
        observation: _observationController.text,
      );

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Modular.to.pop();
      }
    }
  }

  List<String> _getIncomeCategories() {
    return [
      'Salário',
      'Investimentos',
      'Vendas',
      'Reembolso',
      'Presente',
      'Outros',
    ];
  }
}
