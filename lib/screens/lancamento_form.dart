

import 'package:flutter/material.dart';
import '../database/entities/categoria.dart';
import '../database/entities/lancamento.dart';
import '../repositories/lancamento_repository.dart';

class LancamentoForm extends StatefulWidget {
  final LancamentoRepository repository;
  final Lancamento? lancamento;

  const LancamentoForm({
    super.key,
    required this.repository,
    this.lancamento,
  });

  @override
  State<LancamentoForm> createState() => _LancamentoFormState();
}

class _LancamentoFormState extends State<LancamentoForm> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  String _tipo = 'despesa';
  DateTime _dataSelecionada = DateTime.now();
  int? _categoriaIdSelecionada;
  List<Categoria> _categorias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final cats = await widget.repository.getCategorias();
    setState(() {
      _categorias = cats;
      _isLoading = false;


      if (widget.lancamento != null) {
        final l = widget.lancamento!;
        _descricaoController.text = l.descricao;
        _valorController.text = l.valor.toString();
        _tipo = l.tipo;
        _dataSelecionada = DateTime.parse(l.data);
        _categoriaIdSelecionada = l.categoriaId;
      } else if (cats.isNotEmpty) {

        _categoriaIdSelecionada = cats.first.id;
      }
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0073E6),
              primary: const Color(0xFF0073E6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      if (_categoriaIdSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma categoria!')),
        );
        return;
      }

      final descricao = _descricaoController.text.trim();
      final valor = double.parse(_valorController.text.trim());
      final dataIso = _dataSelecionada.toIso8601String().split('T')[0];

      final novoLancamento = Lancamento(
        id: widget.lancamento?.id,
        descricao: descricao,
        valor: valor,
        tipo: _tipo,
        data: dataIso,
        categoriaId: _categoriaIdSelecionada!,
      );

      await widget.repository.save(novoLancamento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.lancamento == null
                ? 'Lançamento cadastrado com sucesso!'
                : 'Lançamento atualizado com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lancamento != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Lançamento' : 'Novo Lançamento'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tipo = 'receita'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _tipo == 'receita'
                                    ? Colors.green.withOpacity(0.15)
                                    : (isDark ? Colors.grey[900] : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _tipo == 'receita' ? Colors.green : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Receita',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _tipo == 'receita' ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tipo = 'despesa'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _tipo == 'despesa'
                                    ? Colors.red.withOpacity(0.15)
                                    : (isDark ? Colors.grey[900] : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _tipo == 'despesa' ? Colors.red : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Despesa',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _tipo == 'despesa' ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),


                    TextFormField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Valor (R\$)',
                        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        prefixIcon: const Icon(Icons.attach_money, size: 28),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira um valor';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Insira um valor numérico válido maior que 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),


                    TextFormField(
                      controller: _descricaoController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Insira uma descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),


                    DropdownButtonFormField<int>(
                      value: _categoriaIdSelecionada,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: _categorias.map((Categoria cat) {
                        final catColor = _parseColor(cat.cor);
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: catColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(cat.nome),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _categoriaIdSelecionada = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione uma categoria' : null,
                    ),
                    const SizedBox(height: 20),


                    InkWell(
                      onTap: () => _selecionarData(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(
                                  'Data: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),


                    ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0073E6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        isEdit ? 'Salvar Alterações' : 'Confirmar Lançamento',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
