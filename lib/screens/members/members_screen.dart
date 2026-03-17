import 'package:admin/constants.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/members/components/member_form.dart';
import 'package:admin/screens/members/components/member_tables.dart';
import 'package:flutter/material.dart';

class MembrosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Responsive(
        mobile: MembrosScreenMobile(),
        tablet: MembrosScreenDesktop(),
        desktop: MembrosScreenDesktop(),
      ),
    );
  }
}

class MembrosScreenDesktop extends StatefulWidget {
  @override
  _MembrosScreenDesktopState createState() => _MembrosScreenDesktopState();
}

class _MembrosScreenDesktopState extends State<MembrosScreenDesktop> {
  bool _exibirPainelEdicao = false;
  Usuario? _membroSelecionado;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: MembrosTable(
                  onSelect: (membro) {
                    setState(() {
                      _membroSelecionado = membro;
                      _exibirPainelEdicao = true;
                    });
                  },
                ),
              ),
              if (_exibirPainelEdicao) ...[
                SizedBox(width: defaultPadding),
                _buildSidePanel(),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Equipe Baja SunCity",
            style: Theme.of(context).textTheme.titleLarge),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
          onPressed: () {
            setState(() {
              _membroSelecionado = null;
              _exibirPainelEdicao = !_exibirPainelEdicao;
            });
          },
          icon: Icon(Icons.person_add, color: Colors.black),
          label:
              Text("ADICIONAR MEMBRO", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildSidePanel() {
    return Container(
      width: 400,
      height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.only(left: defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
        children: [
          _buildPanelHeader(),
          Flexible(
            child: MemberForm(
              membro:
                  _membroSelecionado, // Passa o membro selecionado (ou null para novo)
              onSave: () {
                setState(() {
                  _exibirPainelEdicao = false;
                  _membroSelecionado = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(
            _membroSelecionado == null ? Icons.person_add : Icons.edit,
            color: Colors.orangeAccent,
          ),
          SizedBox(width: 10),
          Text(
            _membroSelecionado == null ? "Novo Membro" : "Editar Perfil",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _exibirPainelEdicao = false),
          ),
        ],
      ),
    );
  }
}

class MembrosScreenMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: defaultPadding),
          MembrosTable(
            onSelect: (membro) {
              _abrirFormularioModal(context, membro);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Equipe Baja SunCity",
            style: Theme.of(context).textTheme.titleLarge),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
          onPressed: () {
            _abrirFormularioModal(context, null);
          },
          icon: Icon(Icons.person_add, color: Colors.black),
          label: Text("ADICIONAR", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  void _abrirFormularioModal(BuildContext context, Usuario? membro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: MemberForm(
                membro: membro,
                onSave: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
