
import 'package:CardApp/Food%20Truck/Telas/Excluirlanche.dart';
import 'package:CardApp/Food%20Truck/Telas/cadastrarlanche.dart';
import 'package:flutter/material.dart';
import 'HIstoricoPedidos.dart';
import 'InicioFD.dart';
import 'ListaFD.dart';

class FoodTruck extends StatefulWidget {
  const FoodTruck({super.key});

  @override
  State<FoodTruck> createState() => _FoodTruckState();
}

class _FoodTruckState extends State<FoodTruck> {
  int _indiceAtual = 0;

  // Adicionamos uma chave global para poder chamar métodos da tela Iniciofd
  final GlobalKey<IniciofdState> iniciofdKey = GlobalKey<IniciofdState>();

  @override
  Widget build(BuildContext context) {
    // Agora passamos a chave para o widget Iniciofd
    List<Widget> Telas = [Iniciofd(key: iniciofdKey), Listafd()];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        backgroundColor: Color(0xff5a1616),
        title: Center(
          child: Image.asset(
            "imagens/CardApp.png",
            width: 260,
            height: 260,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xff5a1616),
          width: 300,
          child: Column(
            children: <Widget>[
              DrawerHeader(
                child: Image.asset(
                  "imagens/Menu.png",
                  width: 200,
                  height: 200,
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Histórico de Pedidos',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 15),
                    Icon(Icons.history, color: Color(0xfff0af35)),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HistoricoPedidos()),
                  );
                },
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cadastrar Lanches',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 15),
                    Icon(Icons.add_circle, color: Color(0xfff0af35)),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context); // Fecha o drawer
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CadastroLancheScreen(
                        onLancheCadastrado: () {
                          // Recarrega os dados do cardápio
                          iniciofdKey.currentState?.carregarCardapio();
                        },
                      ),
                    ),
                  );

                  setState(() {
                    _indiceAtual = 0; // Garante que a aba certa seja exibida
                  });
                },
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Excluir Lanches',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 15),
                    Icon(Icons.delete, color: Color(0xfff0af35)),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExcluirLancheScreen(),
                    ),
                  );
                  setState(() {
                    _indiceAtual = 0; // Atualiza o cardápio após voltar
                  });
                },

              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Telas[_indiceAtual],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: (indice) {
          setState(() {
            _indiceAtual = indice;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xff5a1616),
        unselectedItemColor: Colors.white,
        fixedColor: Color(0xfff0af35),
        items: [
          BottomNavigationBarItem(
            label: "Cardápio",
            icon: Icon(Icons.punch_clock),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: "Em preparo",
          ),
        ],
      ),
    );
  }
}
