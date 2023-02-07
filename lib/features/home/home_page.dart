import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/app_router/app_router.dart';

import 'package:flutter_sample/features/home/bloc/home_bloc.dart';
import 'package:flutter_sample/services/fcm/fcm_service.dart';

import '../../injector/app_injector.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc _homeBloc = AppInjector.instance<HomeBloc>();
  final FcmService _fcmService = AppInjector.instance<FcmService>();

  @override
  void initState() {
    _homeBloc.add(const HomeLoaded());
    _fcmService.setupInteractedMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _homeBloc,
      child: const Scaffold(
        body: _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => previous.handle != current.handle,
      listener: (context, state) {
        state.handle?.when(
          viewDetail: (id) {
            context.router.pushAll([
              MediaDetailRoute(
                id: id,
                heroTag: 'list[$id]',
              ),
              BookingRoute(
                modelId: id,
              ),
            ]);
          },
          failure: (message) {},
        );
      },
      child: AutoTabsRouter(
        routes: const [
          NewsFeedRoute(),
          DiscoveryRoute(),
          ProfileRoute(),
        ],
        duration: const Duration(milliseconds: 400),
        builder: (context, child, animation) {
          final tabsRouter = context.tabsRouter;
          return Scaffold(
            body: FadeTransition(
              opacity: animation,
              child: child,
            ),
            bottomNavigationBar: _BottomBar(tabsRouter: tabsRouter),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({Key? key, required this.tabsRouter}) : super(key: key);

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 30.0,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: false,
      backgroundColor: Colors.white,
      currentIndex: tabsRouter.activeIndex,
      onTap: tabsRouter.setActiveIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore), label: 'Discovery'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Profile'),
      ],
    );
  }
}
