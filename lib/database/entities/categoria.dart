import 'package:floor/floor.dart';

@entity
class Categoria {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String nome;
  final String cor;

  Categoria({
    this.id,
    required this.nome,
    required this.cor,
  });
}
