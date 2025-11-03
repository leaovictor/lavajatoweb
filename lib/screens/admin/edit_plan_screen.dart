import 'package:flutter/material.dart';
import 'package:lavajato/models/plan_model.dart';
import 'package:lavajato/services/plan_service.dart';

class EditPlanScreen extends StatefulWidget {
  final Plan? plan;

  const EditPlanScreen({super.key, this.plan});

  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final PlanService _planService = PlanService();

  late String _name;
  late double _price;
  late List<String> _features;

  @override
  void initState() {
    super.initState();
    _name = widget.plan?.name ?? '';
    _price = widget.plan?.price ?? 0.0;
    _features = widget.plan?.features ?? [];
  }

  void _addFeature() {
    setState(() {
      _features.add('');
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _features.removeAt(index);
    });
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final plan = Plan(
        id: widget.plan?.id ?? '',
        name: _name,
        price: _price,
        features: _features,
      );

      if (widget.plan == null) {
        _planService.addPlan(plan);
      } else {
        _planService.updatePlan(plan);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == null ? 'Novo Plano' : 'Editar Plano'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePlan,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Nome do Plano'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um nome';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              initialValue: _price.toString(),
              decoration: const InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || double.tryParse(value) == null) {
                  return 'Por favor, insira um preço válido';
                }
                return null;
              },
              onSaved: (value) => _price = double.parse(value!),
            ),
            const SizedBox(height: 24),
            Text('Benefícios', style: Theme.of(context).textTheme.titleLarge),
            ..._features.asMap().entries.map((entry) {
              int index = entry.key;
              String feature = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: feature,
                      onChanged: (value) {
                        _features[index] = value;
                      },
                      decoration: InputDecoration(labelText: 'Benefício #${index + 1}'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeFeature(index),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addFeature,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Benefício'),
            ),
          ],
        ),
      ),
    );
  }
}
