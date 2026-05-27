import 'dart:async';
import '../database/app_database.dart';
import '../database/entities/categoria.dart';
import '../database/entities/lancamento.dart';

class LancamentoRepository {
  final AppDatabase _db;

  LancamentoRepository(this._db);


  Future<List<Categoria>> getCategorias() {
    return _db.categoriaDao.findAll();
  }

  Future<Categoria?> getCategoriaById(int id) {
    return _db.categoriaDao.findById(id);
  }

  Future<void> saveCategoria(Categoria c) async {
    if (c.id == null) {
      await _db.categoriaDao.insertCategoria(c);
    } else {
      await _db.categoriaDao.updateCategoria(c);
    }
  }


  Future<List<Lancamento>> getAll() {
    return _db.lancamentoDao.findAll();
  }

  Stream<List<Lancamento>> watchAll() {
    return _db.lancamentoDao.watchAll();
  }

  Stream<List<Lancamento>> watchByTipo(String tipo) {
    if (tipo == 'Todos') {
      return _db.lancamentoDao.watchAll();
    }
    return _db.lancamentoDao.watchByTipo(tipo);
  }

  Future<List<Lancamento>> getByTipo(String tipo) {
    if (tipo == 'Todos') {
      return _db.lancamentoDao.findAll();
    }
    return _db.lancamentoDao.findByTipo(tipo);
  }

  Future<void> save(Lancamento l) async {
    if (l.id == null) {
      await _db.lancamentoDao.insertLancamento(l);
    } else {
      await _db.lancamentoDao.updateLancamento(l);
    }
  }

  Future<void> remove(Lancamento l) {
    return _db.lancamentoDao.deleteLancamento(l);
  }


  Future<Map<String, double>> getBalance() async {
    final result = await _db.database.rawQuery('''
      SELECT
        SUM(CASE WHEN tipo = 'receita' THEN valor ELSE 0 END) AS total_receitas,
        SUM(CASE WHEN tipo = 'despesa' THEN valor ELSE 0 END) AS total_despesas
      FROM Lancamento
    ''');

    if (result.isEmpty) {
      return {'receitas': 0.0, 'despesas': 0.0, 'saldo': 0.0};
    }

    final row = result.first;
    final totalReceitas = (row['total_receitas'] as num?)?.toDouble() ?? 0.0;
    final totalDespesas = (row['total_despesas'] as num?)?.toDouble() ?? 0.0;
    final saldo = totalReceitas - totalDespesas;

    return {
      'receitas': totalReceitas,
      'despesas': totalDespesas,
      'saldo': saldo,
    };
  }


  Future<void> seedCategoriesIfEmpty() async {
    final categories = await _db.categoriaDao.findAll();
    if (categories.isEmpty) {
      final defaultCategories = [
        Categoria(nome: 'Alimentação', cor: '#FF9500'),
        Categoria(nome: 'Transporte', cor: '#007AFF'),
        Categoria(nome: 'Moradia', cor: '#FF3B30'),
        Categoria(nome: 'Salário', cor: '#34C759'),
        Categoria(nome: 'Lazer', cor: '#AF52DE'),
        Categoria(nome: 'Saúde', cor: '#FF2D55'),
        Categoria(nome: 'Outros', cor: '#8E8E93'),
      ];
      for (final cat in defaultCategories) {
        await _db.categoriaDao.insertCategoria(cat);
      }
    }
  }
}
