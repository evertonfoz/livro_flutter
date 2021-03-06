import 'package:capitulo10ojogo/appconstants/router_constants.dart';
import 'package:capitulo10ojogo/routes/palavras/widgets/palavras_listtile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/listview/palavras_listview_business_bloc.dart';
import 'bloc/listview/palavras_listview_event.dart';
import 'bloc/listview/palavras_listview_state.dart';
import 'mixin/palavras_listview_mixin.dart';
import 'widgets/bottom_loader_widget.dart';

class PalavrasListViewRoute extends StatefulWidget {
  @override
  _PalavrasListViewRouteState createState() => _PalavrasListViewRouteState();
}

class _PalavrasListViewRouteState extends State<PalavrasListViewRoute>
    with PalavrasListViewMixim {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  final double _listTileHeight = 70;
  PalavrasListViewBloc _palavrasListViewBloc;
  String _palavraIDSelected;
  String _palavraIDOfTileToDestaque;

  @override
  void initState() {
    super.initState();
    _palavrasListViewBloc = BlocProvider.of<PalavrasListViewBloc>(context)
      ..add(PalavrasListViewBlocEventFetch());

    _scrollController.addListener(() => onScroll(
        palavrasListViewBloc: _palavrasListViewBloc,
        scrollController: _scrollController,
        scrollThreshold: _scrollThreshold));
  }

  @override
  void dispose() {
    _palavrasListViewBloc.add(PalavrasListViewBlocEventResetFetch());
    _scrollController.dispose();
//    _palavrasListViewBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Palavras registradas'),
        elevation: 10,
      ),
      body: BlocBuilder<PalavrasListViewBloc, PalavrasListViewBlocState>(
          builder: (context, state) {
        if (state is PalavrasListViewBlocError) {
          return centerText(
              text: 'Falha ao recuperar palavras: ${state.errorMessage}');
        }

        if (state is PalavrasListViewLoaded) {
          if (state.palavras.isEmpty) {
            return centerText(text: 'Nenhuma palavra registrada ainda.');
          }

          Future.delayed(Duration(milliseconds: 500)).then((onValue) {
            if (this._scrollController.hasClients) {
              for (int i = 0; i < state.palavras.length; i++) {
                if (state.palavras[i].palavraID == this._palavraIDSelected) {
                  _scrollController.animateTo(i * _listTileHeight,
                      duration: new Duration(seconds: 2), curve: Curves.ease);
                  setState(() {
                    _palavraIDOfTileToDestaque = this._palavraIDSelected;
                  });
                  this._palavraIDSelected = null;
                }
              }
              if (this._palavraIDSelected != null)
                _palavrasListViewBloc.add(PalavrasListViewBlocEventFetch());
            }
          });

          return ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: state.hasReachedMax
                ? state.palavras.length
                : state.palavras.length + 1,
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              return (index >= state.palavras.length)
                  ? BottomLoaderWidget()
                  : Dismissible(
                      key: Key(state.palavras[index].palavraID),
                      confirmDismiss: (direction) async {
                        return await confirmDismiss(
                            context: context,
                            palavra: state.palavras[index].palavra,
                            palavraID: state.palavras[index].palavraID);
                      },
                      onDismissed: (direction) async {
                        await dismissedComplete(
                            context: context,
                            palavraID: state.palavras[index].palavraID,
                            palavra: state.palavras[index].palavra);

                        _palavrasListViewBloc.add(
                          PalavrasListViewBlocEventConfirmDismiss(
                              indexOfDismissible: index),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: InkWell(
                        onLongPress: () async {
                          _palavraIDSelected = state.palavras[index].palavraID;

                          _palavrasListViewBloc
                              .add(PalavrasListViewBlocEventResetFetch());

                          await Navigator.of(context).pushNamed(
                              kPalavrasCRUDRoute,
                              arguments: state.palavras[index]);

                          _palavrasListViewBloc
                              .add(PalavrasListViewBlocEventFetch());
                        },
                        child: PalavrasListTileWidget(
                          title: state.palavras[index].palavra,
                          trailing: Icon(Icons.keyboard_arrow_right),
                          listTileHeight: _listTileHeight,
                          color: (_palavraIDOfTileToDestaque ==
                                  state.palavras[index].palavraID)
                              ? Colors.grey[300]
                              : Colors.transparent,
                        ),
                      ),
                    );
            },
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}
