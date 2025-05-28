import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

import 'controller/transfer_controller.dart';

class TransferPage extends StatefulWidget {
  final TransferController controller;
  const TransferPage({super.key, required this.controller});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _observationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedSourceGroupId;
  String? _selectedDestinationGroupId;

  @override
  void initState() {
    super.initState();
    widget.controller.loadGroups();
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
        title: const Text('Transferência'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          if (widget.controller.state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (widget.controller.state.hasError) {
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
                  Text(widget.controller.state.errorMessage ??
                      'Erro desconhecido'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.controller.loadGroups,
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
              hintText: 'Ex: Transferência para viagem',
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
              hintText: 'Ex: 100,00',
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

          // Grupo de Origem
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Grupo de Origem',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.arrow_upward),
            ),
            value: _selectedSourceGroupId,
            items: widget.controller.state.groups.map((group) {
              return DropdownMenuItem<String>(
                value: group.id,
                child: Text(group.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSourceGroupId = value;
                // Se o grupo de destino for igual ao de origem, limpar seleção de destino
                if (_selectedDestinationGroupId == value) {
                  _selectedDestinationGroupId = null;
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione um grupo de origem';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Grupo de Destino
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Grupo de Destino',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.arrow_downward),
            ),
            value: _selectedDestinationGroupId,
            items: widget.controller.state.groups
                .where((group) => group.id != _selectedSourceGroupId)
                .map((group) {
              return DropdownMenuItem<String>(
                value: group.id,
                child: Text(group.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDestinationGroupId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione um grupo de destino';
              }
              if (value == _selectedSourceGroupId) {
                return 'Os grupos de origem e destino devem ser diferentes';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Observações
          TextFormField(
            controller: _observationController,
            decoration: const InputDecoration(
              labelText: 'Observações (opcional)',
              hintText: 'Informações adicionais sobre a transferência',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Botão de Transferir
          ElevatedButton(
            onPressed: widget.controller.state.isSaving ? null : _saveTransfer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: widget.controller.state.isSaving
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
                      Text('Transferindo...'),
                    ],
                  )
                : const Text('Realizar Transferência'),
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

  void _saveTransfer() async {
    if (_formKey.currentState!.validate()) {
      // Formatar valor para double
      final cleanValue =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.parse(cleanValue);

      // Encontrar nomes dos grupos selecionados
      final sourceGroup = widget.controller.state.groups.firstWhere(
        (group) => group.id == _selectedSourceGroupId,
      );

      final destinationGroup = widget.controller.state.groups.firstWhere(
        (group) => group.id == _selectedDestinationGroupId,
      );

      final result = await widget.controller.saveTransfer(
        description: _descriptionController.text,
        amount: amount,
        date: _selectedDate,
        sourceGroupId: _selectedSourceGroupId!,
        sourceGroupName: sourceGroup.name,
        destinationGroupId: _selectedDestinationGroupId!,
        destinationGroupName: destinationGroup.name,
        observation: _observationController.text,
      );

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transferência realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Modular.to.pop();
      }
    }
  }
}
