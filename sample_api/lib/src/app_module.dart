import 'package:hasura_connect/hasura_connect.dart' hide Response;
import 'package:sample_api/src/auth/auth_resource.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  final String graphQLApiUrl = 'http://localhost:8888/v1/graphql';
  final Map<String, String> headers = {'x-hasura-admin-secret': 'Senha123'};

  @override
  List<Bind<Object>> get binds => [
        Bind((i) => HasuraConnect(graphQLApiUrl, headers: headers)),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', () => Response.ok('Tudo funcionando!')),
        Route.resource(AuthResource()),
      ];
}
