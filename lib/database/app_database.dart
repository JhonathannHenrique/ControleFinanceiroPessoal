import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'entities/categoria.dart';
import 'entities/lancamento.dart';
import 'daos/categoria_dao.dart';
import 'daos/lancamento_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [Categoria, Lancamento])
abstract class AppDatabase extends FloorDatabase {
  CategoriaDao get categoriaDao;
  LancamentoDao get lancamentoDao;
}
