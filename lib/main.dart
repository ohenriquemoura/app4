import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> tarefas = <String>[];
  bool isChecked = false;

  TextEditingController tarefaController = TextEditingController();

  _recuperarBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "bdTarefas.db");

    var bd = await openDatabase(localBancoDados, version: 1,
        onCreate: (db, dbVersaoRecente) {
      String sql =
          "CREATE TABLE tarefas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR) ";
      db.execute(sql);
    });

    return bd;
  }

  _salvar() async {
    Database bd = await _recuperarBancoDados();

    Map<String, dynamic> dadosTarefa = {"titulo": tarefaController.text};
    int id = await bd.insert("tarefas", dadosTarefa);
    print("Salvo: $id ");
  }

  _listarTarefas() async {
    Database bd = await _recuperarBancoDados();
    String sql = "SELECT * FROM tarefas "; //ASC, DESC
    List tarefas = await bd.rawQuery(sql);

    for (var tarefa in tarefas) {
      print("item id: " +
          tarefa['id'].toString() +
          " titulo: " +
          tarefa['titulo']);
    }
  }

  _excluirTarefa(String titulo) async {
    Database bd = await _recuperarBancoDados();

    await bd.delete("tarefas", where: "titulo = ?", whereArgs: [titulo]);
    String sql = "SELECT * FROM tarefas "; //ASC, DESC
    List tarefas = await bd.rawQuery(sql);

    for (var tarefa in tarefas) {
      print("item id: " +
          tarefa['id'].toString() +
          " titulo: " +
          tarefa['titulo']);
    }
  }

  void addItemToList() {
    setState(() {
      tarefas.insert(0, tarefaController.text);
    });
  }

  void removeItemToList() {
    setState(() {
      tarefas.remove(tarefaController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lista de Tarefas'),
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: tarefas.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: isChecked,
                            onChanged: (bool value) {
                              setState(() {
                                isChecked = value;
                              });
                            },
                          ),
                          Text(tarefas[index], style: TextStyle(fontSize: 18)),
                          IconButton(
                              onPressed: () {
                                _excluirTarefa(tarefas[index]);
                                removeItemToList();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ));
                })),
        Container(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Nova tarefa'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                                controller: tarefaController,
                                decoration:
                                    InputDecoration(labelText: 'Título'),
                                autofocus: true),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              _listarTarefas();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Salvar'),
                            onPressed: () {
                              addItemToList();
                              _salvar();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
            },
            child: const Icon(Icons.add_outlined),
            backgroundColor: Colors.blue,
          ),
        )
      ]),
    );
  }
}
