import 'dart:async';
import 'dart:convert';
import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:hasura_connect/hasura_connect.dart' hide Request, Response;
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.post('/login', _login),
      ];

  FutureOr<Response> _login(
    Request request,
    ModularArguments args,
    Injector injector,
  ) async {
    final connect = injector.get<HasuraConnect>();

    //Consulta que procura por usuário com as credenciais
    //informadas pelo hasura.
    const loginQuery = r'''
      query Login($login: String!, $password: String!, $company_id: Int!) {
        user(where: {login: {_eq: $login}, password: {_eq: $password}, company_id: {_eq: $company_id}}) {
          id
          company_id
          default_role
        }
      }
    ''';

    //Realiza requisição graphQL.
    final response = await connect.query(
      loginQuery,
      variables: args.data['input'],
    );

    final userList = response['data']['user'] as List;

    print('Response Hasura: $response');

    if (userList.isEmpty) {
      final responseError = {'message': 'Falha na autenticação'};
      return Response.forbidden(jsonEncode(responseError));
    }

    var user = userList.first;

    //Criação de Token JWT com informações do usuário no payload seguindo
    //documentação do hasura.
    final builder = JWTBuilder();

    builder
      ..expiresAt = DateTime.now().add(Duration(minutes: 3))
      ..setClaim(
        'https://hasura.io/jwt/claims',
        {
          "x-hasura-allowed-roles": ['admin', 'editor', 'user'],
          "x-hasura-default-role": user['default_role'],
          "x-hasura-user-id": user['id'].toString(),
          "x-hasura-org-id": user['company_id'].toString(),
        },
      )
      ..getToken();

    //Assinando o token com mesmo segredo informado ao hasura.
    var secretKey = '06c219e5bc8378f3a8a3f83b4b7e4649';
    var signer = JWTHmacSha256Signer(secretKey);
    var signedToken = builder.getSignedToken(signer);

    final result = {
      'accessToken': signedToken.toString(),
      'expireIn': Duration(minutes: 3).inSeconds,
    };

    return Response.ok(jsonEncode(result));
  }
}
