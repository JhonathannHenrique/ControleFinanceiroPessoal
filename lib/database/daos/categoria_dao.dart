import 'package:floor/floor.dart';
import '../entities/categoria.dart';

@dao
abstract class CategoriaDao {
  @Query('SELECT * FROM Categoria')
  Future<List<Categoria>> findAll();

  @Query('SELECT * FROM Categoria WHERE id = :id')
  Future<Categoria?> findById(int id);

  @insert
  Future<void> insertCategoria(Categoria categoria);

  @update
  Future<void> updateCategoria(Categoria categoria);

  @delete
  Future<void> deleteCategoria(Categoria categoria);
}
