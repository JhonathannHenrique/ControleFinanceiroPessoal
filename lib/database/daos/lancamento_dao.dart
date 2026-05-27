import 'package:floor/floor.dart';
import '../entities/lancamento.dart';

@dao
abstract class LancamentoDao {
  @Query('SELECT * FROM Lancamento ORDER BY data DESC')
  Future<List<Lancamento>> findAll();

  @Query('SELECT * FROM Lancamento ORDER BY data DESC')
  Stream<List<Lancamento>> watchAll();

  @Query('SELECT * FROM Lancamento WHERE tipo = :tipo ORDER BY data DESC')
  Future<List<Lancamento>> findByTipo(String tipo);

  @Query('SELECT * FROM Lancamento WHERE tipo = :tipo ORDER BY data DESC')
  Stream<List<Lancamento>> watchByTipo(String tipo);

  @insert
  Future<void> insertLancamento(Lancamento lancamento);

  @update
  Future<void> updateLancamento(Lancamento lancamento);

  @delete
  Future<void> deleteLancamento(Lancamento lancamento);
}
