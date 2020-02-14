import 'package:capitulo09_persistencia_e_anim/local_persistence/daos/palavra_dao.dart';
import 'package:capitulo09_persistencia_e_anim/mixins/widgets_mixin.dart';
import 'package:capitulo09_persistencia_e_anim/models/palavra_model.dart';
import 'package:capitulo09_persistencia_e_anim/widgets/container_iluminado_widget.dart';
import 'package:capitulo09_persistencia_e_anim/widgets/dialogs/actions_flatbutton_to_alertdialog_widget.dart';
import 'package:capitulo09_persistencia_e_anim/widgets/dialogs/information_alert_dialog_widget.dart';
import 'package:capitulo09_persistencia_e_anim/widgets/raisedbutton_with_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/crud/palavras_crud_bloc.dart';

class PalavrasCRUDRoute extends StatefulWidget {
  @override
  _PalavrasCRUDRouteState createState() => _PalavrasCRUDRouteState();
}

class _PalavrasCRUDRouteState extends State<PalavrasCRUDRoute>
    with TextFormFieldMixin {
  //#region Variáveis
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _palavraController = TextEditingController();
  final _ajudaController = TextEditingController();
  final FocusNode _palavraFocus = FocusNode();
  final FocusNode _ajudaFocus = FocusNode();

  PalavrasCrudFormBloc _palavrasCrudFormBloc;
  BuildContext _buildContext;
  //#endregion

  //#region _mainColumn
  Widget _mainColumn() {
    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: ContainerIluminadoWidget(
              backgroundColor: Colors.white,
              shadowColor: Colors.white70,
              height: 350,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: BlocBuilder<PalavrasCrudFormBloc, PalavrasCrudFormState>(
                    builder: (context, formState) {
//                    return SuccessDialogWidget(
//                      onDismissed: () {
//                        _palavraController.clear();
//                        _ajudaController.clear();
//                        this._palavrasCrudFormBloc.add(FormReset());
//                      },
//                    );
//                  }
                  return _form(formState);
                }),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
  //#endregion

  //#region _form
  Widget _form(PalavrasCrudFormState formState) {
    return Form(
//      key: this._formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          textFormField(
              focusNode: this._palavraFocus,
              controller: this._palavraController,
              labelText: 'Palavra',
              onFieldSubmitted: (_) => FocusScope.of(this._buildContext)
                  .requestFocus(this._ajudaFocus),
              textInputAction: TextInputAction.next,
              validator: (_) {
                return formState.isWordValid ? null : 'Informe a palavra';
              }),
          SizedBox(
            height: 20,
          ),
          textFormField(
              maxLines: 5,
              focusNode: this._ajudaFocus,
              controller: this._ajudaController,
              labelText: 'Ajuda',
              validator: (_) {
                return formState.isHelpValid ? null : 'Informe a ajuda';
              }),
          SizedBox(
            height: 20,
          ),
          RaisedButtonWithSnackbarWidget(
            onPressedVisible: formState.isFormValid,
            buttonText: 'Gravar',
            successTextToSnackBar:
                'Os dados informados foram registrados com sucesso.',
            failTextToSnackBar: 'Erro na inserção',
            onButtonPressed: _onSubmitPressed,
            onStackBarClosed: _resetForm,
          ),
        ],
      ),
    );
  }
  //#endregion

  void _onPalavraChanged() {
    _palavrasCrudFormBloc
        .add(PalavraChanged(word: this._palavraController.text));
  }

  void _onAjudaChanged() {
    _palavrasCrudFormBloc.add(AjudaChanged(help: this._ajudaController.text));
  }

  void _onSubmitPressed() async {
    PalavraDAO palavraDAO = PalavraDAO();
    PalavraModel palavraModel = PalavraModel(
        palavra: this._palavraController.text,
        ajuda: this._ajudaController.text);

    try {
      await palavraDAO.insert(palavraModel: palavraModel);
      _palavrasCrudFormBloc.add(FormSuccessSubmitted());
    } catch (e) {
      rethrow;
    }
  }

  _successDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      child: InformationAlertDialogWidget(
        title: 'Tudo certo',
        message: 'Os dados informados foram registrados com sucesso.',
        actions: [
          ActionsFlatButtonToAlertDialogWidget(
            messageButton: 'OK',
            isDefaultAction: true,
          ),
        ],
      ),
    );
  }

  _resetForm() {
    _palavraController.clear();
    _ajudaController.clear();
    this._palavrasCrudFormBloc.add(FormReset());
  }

  //#region initState
  @override
  void initState() {
    super.initState();
    this._palavrasCrudFormBloc = BlocProvider.of<PalavrasCrudFormBloc>(context);
    this._palavraController.addListener(_onPalavraChanged);
    this._ajudaController.addListener(_onAjudaChanged);
  }
  //#endregion

  //#region dispose
  @override
  void dispose() {
    this._palavraController.dispose();
    this._ajudaController.dispose();
    super.dispose();
  }
  //#endregion

  //#region build
  @override
  Widget build(BuildContext context) {
    this._buildContext = context;
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        title: Text(
          'Registro de Palavras',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: _mainColumn(),
          ),
        ),
      ),
    );
  }
  //#endregion
}
