import 'package:CardApp/Food%20Truck/Telas/PedidosProntosScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Listafd extends StatefulWidget {
  const Listafd({super.key});

  @override
  State<Listafd> createState() => _ListafdState();
}

class _ListafdState extends State<Listafd> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff5a1616),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade400,
            indicatorColor: Colors.orange,
            indicatorWeight: 3.0,
            tabs: const [
              Tab(icon: Icon(Icons.receipt_long), text: 'Em Preparo'),
              Tab(icon: Icon(Icons.check_circle), text: 'Prontos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            PedidosEmPreparoScreen(), // Agora é uma tela separada
            PedidosProntosScreen(),
          ],
        ),
      ),
    );
  }
}

class PedidosEmPreparoScreen extends StatelessWidget {
  final DatabaseReference refPedidosEmPreparo = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://food-truck-fd524-default-rtdb.firebaseio.com",
  ).ref("pedidosEmPreparo");

  void entregarPedido(BuildContext context, Map<String, dynamic> pedido) async {
    try {
      final DatabaseReference refPedidosProntos = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://food-truck-fd524-default-rtdb.firebaseio.com",
      ).ref("pedidosProntos");

      await refPedidosProntos.push().set({
        "nome": pedido["nome"],
        "cliente": pedido["cliente"],
        "formaPagamento": pedido["formaPagamento"],
        "total": pedido["total"],
        "itens": pedido["itens"],
      });

      await refPedidosEmPreparo.child(pedido["id"]).remove();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 6),
              Text('Pedido movido para "Pedidos Prontos"'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erro ao mover o pedido!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: refPedidosEmPreparo.onValue.asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar dados: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('Nenhum pedido em preparo.'));
        }

        final Map<dynamic, dynamic> pedidosMap =
        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        final List<Map<String, dynamic>> pedidosList = pedidosMap.entries.map((entry) {
          final Map<String, dynamic> pedido = Map<String, dynamic>.from(entry.value);

          List<Map<String, dynamic>> itens = [];
          if (pedido['itens'] is List) {
            itens = (pedido['itens'] as List).map<Map<String, dynamic>>((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return {};
            }).toList();
          }

          return {
            "id": entry.key,
            ...pedido,
            "itens": itens,
          };
        }).toList();

        return ListView.builder(
          itemCount: pedidosList.length,
          itemBuilder: (context, index) {
            final pedido = pedidosList[index];
            final nomePedido = (pedido['nome'] ?? '').toString().isNotEmpty
                ? pedido['nome']
                : 'Pedido ${index + 1}';

            return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange.shade50,
                title: Text(
                  nomePedido,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                subtitle: Text(
                  'Cliente: ${pedido['cliente'] ?? 'Desconhecido'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.receipt_long, color: Colors.orange.shade800),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        ...pedido['itens'].map<Widget>((item) {
                          return ListTile(
                            title: Text(
                              item['nome'] ?? 'Sem nome',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Text(
                              'R\$${(item['preco'] ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        Divider(thickness: 1.2, color: Colors.grey.shade400),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Total: R\$${(pedido['total'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                entregarPedido(context, pedido);
                              },
                              icon: const Icon(Icons.done, color: Colors.white),
                              label: const Text(
                                'Pronto',
                                style: TextStyle(color: Colors.white),
                               ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xa82dff00),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Código para excluir o pedido
                                refPedidosEmPreparo.child(pedido["id"]).remove().then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Pedido excluído com sucesso!'),
                                        ],
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Erro ao excluir o pedido!'),
                                        ],
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: const Text(
                                'Excluir',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
