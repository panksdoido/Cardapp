import 'package:flutter/material.dart';
import 'PedidosScreen.dart';
import '../metodosBB.dart';
import '../supabase/CRUD_supabase.dart'; // Importa o serviço Supabase

class Iniciofd extends StatefulWidget {
  const Iniciofd({Key? key}) : super(key: key);

  @override
  IniciofdState createState() => IniciofdState();
}

class IniciofdState extends State<Iniciofd> {
  List<Item> cardapio = [];
  Pedido pedido = Pedido();
  final SupabaseService supabaseService = SupabaseService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarCardapio();
  }

  // Método público para forçar recarregamento externo
  void refresh() {
    carregarCardapio();
  }

  Future<void> carregarCardapio() async {
    setState(() {
      isLoading = true;
    });

    try {
      final lanches = await supabaseService.buscarLanches();
      setState(() {
        cardapio = lanches.map<Item>((lanche) {
          return Lanche(
            lanche['nome'] ?? 'Sem Nome',
            double.tryParse(lanche['preco'].toString()) ?? 0.0,
            lanche['imagem_url'] ?? '',
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar cardápio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar cardápio")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Cardápio')),

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cardapio.isEmpty
          ? Center(child: Text("Nenhum lanche disponível."))
          : Stack(
        children: [
          GridView.builder(
            padding: EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2 / 3,
            ),
            itemCount: cardapio.length,
            itemBuilder: (context, index) {
              final item = cardapio[index];
              return Card(
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      item.imagem,
                      height: 100,
                      width: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                    SizedBox(height: 10),
                    Text(
                      item.nome,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'R\$ ${item.preco.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(Icons.add, color: Colors.orange),
                        onPressed: () {
                          setState(() {
                            pedido.adicionarItem(item);
                            pedido.calcularTotal();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${item.nome} adicionado ao pedido'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        splashColor: Colors.orange.shade300,
                        tooltip: 'Adicionar ao Pedido',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.orange.shade200,
              child: Icon(Icons.shopping_cart, color: Color(0xff5a1616),),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PedidoScreen(pedido: pedido),
                  ),
                ).then((updatedPedido) {
                  if (updatedPedido != null) {
                    setState(() {
                      pedido = updatedPedido;
                    });
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
