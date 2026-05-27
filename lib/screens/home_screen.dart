

import 'dart:async';
import 'package:flutter/material.dart';
import '../database/entities/categoria.dart';
import '../database/entities/lancamento.dart';
import '../repositories/lancamento_repository.dart';
import 'lancamento_form.dart';

class HomeScreen extends StatefulWidget {
  final LancamentoRepository repository;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filtroTipo = 'Todos';
  double _receitas = 0.0;
  double _despesas = 0.0;
  double _saldo = 0.0;
  
  Map<int, Categoria> _categoriasMap = {};
  late StreamSubscription<List<Lancamento>> _subscription;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _listenToTransactions();
  }

  void _listenToTransactions() {
    _subscription = widget.repository.watchAll().listen((_) {
      _atualizarSaldo();
    });
  }

  Future<void> _carregarCategorias() async {
    final cats = await widget.repository.getCategorias();
    if (mounted) {
      setState(() {
        _categoriasMap = {for (var c in cats) c.id!: c};
      });
    }
  }

  Future<void> _atualizarSaldo() async {
    final balance = await widget.repository.getBalance();
    if (mounted) {
      setState(() {
        _receitas = balance['receitas']!;
        _despesas = balance['despesas']!;
        _saldo = balance['saldo']!;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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

  Future<void> _confirmarExclusao(Lancamento lancamento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este lançamento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.repository.remove(lancamento);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lançamento excluído com sucesso!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _abrirFormulario({Lancamento? lancamento}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LancamentoForm(
          repository: widget.repository,
          lancamento: lancamento,
        ),
      ),
    );

    _carregarCategorias();
    _atualizarSaldo();
  }

  String _formatarData(String dataIso) {
    try {
      final partes = dataIso.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return dataIso;
    } catch (e) {
      return dataIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minhas Finanças',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Controle financeiro pessoal inteligente',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: widget.onToggleTheme,
                    ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _saldo >= 0
                        ? [const Color(0xFF0073E6), const Color(0xFF00BFFF)]
                        : [const Color(0xFFD32F2F), const Color(0xFFFF5252)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (_saldo >= 0 ? const Color(0xFF0073E6) : Colors.red).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Geral',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${_saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Receitas',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  'R\$ ${_receitas.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward, color: Colors.redAccent, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Despesas',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  'R\$ ${_despesas.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _filtroTipo,
                        icon: const Icon(Icons.filter_list, size: 18),
                        elevation: 16,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _filtroTipo = newValue;
                            });
                          }
                        },
                        items: <String>['Todos', 'receita', 'despesa'].map<DropdownMenuItem<String>>((String value) {
                          String label = value;
                          if (value == 'receita') label = 'Receitas';
                          if (value == 'despesa') label = 'Despesas';
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
              child: StreamBuilder<List<Lancamento>>(
                stream: widget.repository.watchByTipo(_filtroTipo),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
                  }

                  final lancamentos = snapshot.data ?? [];

                  if (lancamentos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 72,
                            color: isDark ? Colors.grey[700] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum lançamento encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _filtroTipo == 'Todos'
                                ? 'Toque no botão + para adicionar o primeiro.'
                                : 'Sem lançamentos desse tipo.',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: lancamentos.length,
                    itemBuilder: (context, index) {
                      final l = lancamentos[index];
                      final cat = _categoriasMap[l.categoriaId];
                      final catColor = cat != null ? _parseColor(cat.cor) : Colors.grey;
                      final catNome = cat?.nome ?? 'Desconhecido';
                      final isReceita = l.tipo == 'receita';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                          ),
                        ),
                        color: isDark ? Colors.grey[900] : Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _abrirFormulario(lancamento: l),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [

                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      catNome.isNotEmpty ? catNome[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: catColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.descricao,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            catNome,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: catColor.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatarData(l.data),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isReceita ? '+' : '-'} R\$ ${l.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isReceita ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                                      onPressed: () => _confirmarExclusao(l),
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.red.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: const Color(0xFF0073E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
