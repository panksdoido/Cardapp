
import 'package:CardApp/Food%20Truck/Telas/TelaFD.dart';
import 'package:flutter/material.dart';
import '../supabase/CRUD_supabase.dart';

class ExcluirLancheScreen extends StatefulWidget {
  @override
  _ExcluirLancheScreenState createState() => _ExcluirLancheScreenState();
}

class _ExcluirLancheScreenState extends State<ExcluirLancheScreen> {
  final SupabaseService supabaseService = SupabaseService(); // Instância do serviço Supabase
  List<Map<String, dynamic>> lanches = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    carregarLanches();
  }

  // Método para carregar os lanches do Supabase
  Future<void> carregarLanches() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabaseService.buscarLanches();
      setState(() {
        lanches = response;
      });
      print("Lanches carregados com sucesso: $lanches");
    } catch (e) {
      print("Erro ao carregar lanches: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar lanches!")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para excluir um lanche
  Future<void> excluirLanche(int id) async {
    try {
      await supabaseService.deletarLanche(id);
      await carregarLanches();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lanche excluído com sucesso!")),
      );
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoodTruck()),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ExcluirLancheScreen()),
      );

    } catch (e) {
      print("Erro ao excluir lanche: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir lanche: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Excluir Lanches"),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : lanches.isEmpty
          ? Center(child: Text("Nenhum lanche encontrado."))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: lanches.length,
        itemBuilder: (context, index) {
          final lanche = lanches[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.fastfood, color: Colors.orange),
              title: Text(
                lanche['nome'] ?? 'Sem Nome',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'R\$ ${lanche['preco'] ?? '0.00'}',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  excluirLanche(lanche['id']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
