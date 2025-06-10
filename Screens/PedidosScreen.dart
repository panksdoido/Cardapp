  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import '../metodosBB.dart';
  import 'package:firebase_database/firebase_database.dart';

  // Adicione a referência
  final DatabaseReference ref = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://food-truck-fd524-default-rtdb.firebaseio.com",
  ).ref("pedidosEmPreparo");

  class PedidoScreen extends StatefulWidget {
    final Pedido pedido;

    PedidoScreen({required this.pedido});

    @override
    _PedidoScreenState createState() => _PedidoScreenState();
  }

  class _PedidoScreenState extends State<PedidoScreen> {
    final TextEditingController _nomeController = TextEditingController();
    final TextEditingController _clienteController = TextEditingController();
    String _formaPagamento = "Cartão";

    void finalizarPedido() {
      if (widget.pedido.itens.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Pedido Vazio'),
              content: Text(
                  'Não foi possível finalizar o pedido pois ele está vazio.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordas arredondadas
            ),
            title: Center(
              child: Text(
                'Detalhes do Pedido',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _clienteController,
                    decoration: InputDecoration(
                      hintText: 'Nome do Cliente',
                      labelText: 'Cliente',
                      labelStyle: TextStyle(color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.orange),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      hintText: 'Nome do Pedido',
                      labelText: 'Pedido',
                      labelStyle: TextStyle(color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.fastfood, color: Colors.orange),
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _formaPagamento,
                    decoration: InputDecoration(
                      labelText: 'Forma de Pagamento',
                      labelStyle: TextStyle(color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: <String>['Cartão', 'Dinheiro', 'Pix'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _formaPagamento = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceAround, // Centraliza os botões
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent, // Cor de fundo
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Cor de fundo
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    widget.pedido.cliente = _clienteController.text;
                    widget.pedido.nome = _nomeController.text;
                    widget.pedido.formaPagamento = _formaPagamento;
                    widget.pedido.calcularTotal();

                    // Cria o nó automaticamente no "pedidosEmPreparo"
                    final DatabaseReference refPreparo = ref;
                    refPreparo.push().set({
                      "nome": widget.pedido.nome,
                      "cliente": widget.pedido.cliente,
                      "formaPagamento": widget.pedido.formaPagamento,
                      "total": widget.pedido.total,
                      "itens": widget.pedido.itens.map((item) => {
                        "nome": item.nome,
                        "preco": item.preco,
                      }).toList(),
                    }).then((_) {
                      print("Pedido salvo com sucesso em `pedidosEmPreparo`!");
                    }).catchError((erro) {
                      print("Erro ao salvar no Firebase: $erro");
                    });

                    // Limpa os itens do pedido após salvar
                    widget.pedido.itens.clear();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
                'Pedido',
                style: TextStyle(color: Color(0xffffffff)),
              )),
          backgroundColor: Color(0xff5a1616),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.pedido.itens.length,
                itemBuilder: (context, index) {
                  final item = widget.pedido.itens[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 5, // Sombra para dar profundidade
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Bordas arredondadas
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(Icons.fastfood, color: Colors.orange),
                        ),
                        title: Text(
                          item.nome,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'R\$${item.preco.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              widget.pedido.itens.removeAt(index);
                              widget.pedido.calcularTotal(); // Recalcula o total
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.nome} removido do pedido'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  // Fundo suave para destaque
                  borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                ),
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Total: R\$${widget.pedido.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff000000), // Cor de destaque
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: finalizarPedido,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff5a1616), // Cor do botão "Finalizar"
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Bordas arredondadas
                      ),
                    ),
                    child: Text(
                      'Finalizar Pedido',
                      style: TextStyle(fontSize: 18,  color:Color(
                          0xffffffff)),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff5a1616), // Cor do botão "Voltar ao Cardápio"
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Bordas arredondadas
                        ),
                      ),
                      child: Text(
                        'Voltar ao Cardápio',
                        style: TextStyle(fontSize: 18, color: Color(
                            0xffffffff)),

                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
