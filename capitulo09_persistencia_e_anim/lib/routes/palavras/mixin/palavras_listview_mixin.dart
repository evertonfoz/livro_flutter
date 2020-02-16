import 'package:capitulo09_persistencia_e_anim/local_persistence/daos/palavra_dao.dart';
import 'package:capitulo09_persistencia_e_anim/routes/palavras/bloc/listview/palavras_listview_bloc.dart';
import 'package:dialog_information_to_specific_platform/dialog_information_to_specific_platform.dart';
import 'package:dialog_information_to_specific_platform/flat_buttons/actions_flatbutton_to_alert_dialog.dart';
import 'package:flutter/material.dart';

mixin PalavrasListViewMixim {
  centerText({String text}) {
    return Center(child: Text(text));
  }

  onScroll(
      {PalavrasListViewBloc palavrasListViewBloc,
      ScrollController scrollController,
      double scrollThreshold}) {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= scrollThreshold) {
      palavrasListViewBloc.add(PalavrasListViewBlocEventFetch());
    }
  }

  Future<bool> confirmDismiss(
      {BuildContext context, String palavra, String palavraID}) async {
    String oQueFazer = await showDialog(
      barrierDismissible: false,
      context: context,
      child: InformationAlertDialog(
        iconTitle: Icon(
          Icons.message,
          color: Colors.red,
        ),
        title: 'Oops...Quer remover?',
        message: 'Confirma a remoção da palavra ${palavra.toUpperCase()}',
        buttons: [
          ActionsFlatButtonToAlertDialog(
            messageButton: 'Não',
            isEnabled: true,
          ),
          //   InformationAlertDialog.createFlatButton(),
          ActionsFlatButtonToAlertDialog(
            messageButton: 'Sim',
            isEnabled: true,
          ),
          //   InformationAlertDialog.createFlatButton(),
        ],
      ),
    );

    if (oQueFazer == 'Não') return false;

    try {
      PalavraDAO palavraDAO = PalavraDAO();
      await palavraDAO.deleteByID(palavraID);
      return true;
    } catch (exception) {
      showSnackBarMessage(
          context: context,
          message:
              'Erro ao remover a Palavra ${palavra.toUpperCase()}: $exception',
          backgroundColor: Colors.red);
      return false;
    }
  }

  Future<void> dismissedComplete(
      {BuildContext context, String palavraID, String palavra}) async {
    showSnackBarMessage(
        context: context,
        message: 'Palavra ${palavra.toUpperCase()} foi removida',
        backgroundColor: Colors.indigo);
  }

  Future showSnackBarMessage(
      {BuildContext context, String message, Color backgroundColor}) async {
    Scaffold.of(context)
        .showSnackBar(SnackBar(
          backgroundColor: backgroundColor,
          content: Text(
            message,
          ),
        ))
        .closed
        .then((_) {
      return;
    });
  }
}
