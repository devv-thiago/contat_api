import 'package:dart_frog/dart_frog.dart';
import 'package:dart_odbc/dart_odbc.dart';
import 'package:dotenv/dotenv.dart';

Future<Response> onRequest(RequestContext context) async {
  //Carrega arquivo .ENV
  final env = DotEnv(includePlatformEnvironment: true)..load();

  //Identifica driver ODBC e realiza a conexão
  final odbc = DartOdbc(
    env['PATH_ODBC_DRIVER'] ?? '',
  )..connect(
      dsn: env['AMBIENTE'] ?? '', // Ambiente que vai conectar(Produção, etc)
      username: env['USER'] ?? '', // Usuario do banco
      password: env['PASSWORD'] ?? '', // Senha do banco
    );

  // Executa uma consulta
  final results = odbc.execute(
    'SELECT * FROM cotas WHERE dt_inicial = ? AND nome_ab_reg = ?;',
    params: ['01/02/2024', 'REGIONAL 10'],
  );

  // Fecha a conexão
  odbc.disconnect();

  // Verifica se há dados e retorna a resposta apropriada
  if (results.isNotEmpty) {
    return Response.json(
      body: results,
    );
  } else {
    return Response.json(
      body: {
        'error': 'No data found',
      },
    );
  }
}
