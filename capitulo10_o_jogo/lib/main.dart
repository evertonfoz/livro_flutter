import 'package:capitulo10ojogo/local_persistence/daos/palavra_dao.dart';
import 'package:capitulo10ojogo/routes/jogo/mobx_stores/jogo_store.dart';
import 'package:capitulo10ojogo/routes/jogo/mobx_stores/teclado_store.dart';
import 'package:capitulo10ojogo/routes/palavras/bloc/crud/palavras_crud_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'apphelpers/app_router.dart';
import 'drawer/blocs/drawer_open_state_bloc.dart';
import 'functions/device_functions.dart' as DeviceFunctions;
import 'functions/getit_function.dart';
import 'routes/palavras/bloc/listview/palavras_listview_bloc.dart';
import 'routes/splash_screen_route.dart';

void main() {
  getIt.registerSingleton<JogoStore>(JogoStore());
  getIt.registerSingleton<TecladoStore>(TecladoStore());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<DrawerOpenStateBloc>(
          create: (BuildContext context) => DrawerOpenStateBloc(),
        ),
        BlocProvider<PalavrasCrudFormBloc>(
          create: (BuildContext context) => PalavrasCrudFormBloc(),
        ),
        BlocProvider<PalavrasListViewBloc>(
          create: (BuildContext context) =>
              PalavrasListViewBloc(palavraDAO: PalavraDAO()),
        ),
      ],
      child: ForcaApp(),
    ),
  );
}

class ForcaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    BlocSupervisor.delegate = SimpleBlocDelegate();

//    PalavraDAO palavraDAO = PalavraDAO();
//    for (int i = 0; i < 30; i++) {
//      var random = Random();
//      var palavra = random.nextInt(1000).toString();
//      palavraDAO.insert(
//          palavraModel: PalavraModel(
//              palavra: 'Palavra $palavra',
//              ajuda: 'Ajuda para palavra $palavra'));
//    }
    return MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      title: 'Forca da UTFPR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.green,
      ),
      home: ForcaHomePage(),
    );
  }
}

class ForcaHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DeviceFunctions.Dimensoes.deviceHeight = MediaQuery.of(context).size.height;
    DeviceFunctions.Dimensoes.deviceWidth = MediaQuery.of(context).size.width;
    DeviceFunctions.Dimensoes.shortestSide =
        MediaQuery.of(context).size.shortestSide;
    DeviceFunctions.Dimensoes.safeAreaTop = MediaQuery.of(context).padding.top;
    DeviceFunctions.Dimensoes.safeAreaBottom =
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SplashScreenRoute(),
    );
  }
}
