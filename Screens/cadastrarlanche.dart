import 'package:CardApp/Food%20Truck/supabase/CRUD_supabase.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class CadastroLancheScreen extends StatefulWidget {
  final VoidCallback? onLancheCadastrado;

  CadastroLancheScreen({this.onLancheCadastrado});

  @override
  _CadastroLancheScreenState createState() => _CadastroLancheScreenState();
}

class _CadastroLancheScreenState extends State<CadastroLancheScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  Uint8List? _imagemSelecionadaBytes;

  final SupabaseService supabaseService = SupabaseService();

  Future<void> selecionarImagem() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _imagemSelecionadaBytes = result.files.single.bytes;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Imagem selecionada com sucesso!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nenhuma imagem foi selecionada.")),
          );
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
        if (imagem != null) {
          final bytes = await imagem.readAsBytes();
          setState(() {
            _imagemSelecionadaBytes = bytes;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Imagem selecionada com sucesso!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nenhuma imagem foi selecionada.")),
          );
        }
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao selecionar imagem!")),
      );
    }
  }

  Future<void> salvarLanche() async {
    final nome = nomeController.text.trim();
    final preco = double.tryParse(precoController.text);

    if (nome.isNotEmpty && preco != null && _imagemSelecionadaBytes != null) {
      try {
        final imagemUploadUrl = await supabaseService.uploadImagem(
          _imagemSelecionadaBytes!,
          "imagem_${DateTime.now().millisecondsSinceEpoch}.png",
        );

        if (imagemUploadUrl != null) {
          await supabaseService.inserirLanche(nome, preco, imagemUploadUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lanche cadastrado com sucesso!")),
          );

          nomeController.clear();
          precoController.clear();
          setState(() {
            _imagemSelecionadaBytes = null;
          });

          widget.onLancheCadastrado?.call();

        } else {
          throw Exception("Erro ao fazer upload da imagem.");
        }
      } catch (e) {
        print("Erro ao salvar o lanche: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar o lanche: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos corretamente!")),
      );
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Lanche'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Lanche',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: precoController,
              decoration: InputDecoration(
                labelText: 'Preço',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _imagemSelecionadaBytes == null
                ? Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Nenhuma imagem selecionada',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
                : Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  _imagemSelecionadaBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: selecionarImagem,
              child: Text(
                'Selecionar Imagem',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: salvarLanche,
                child: Text(
                  'Salvar Lanche',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
