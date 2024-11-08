import 'package:mysql_client/mysql_client.dart';

class DBconnector {
  static late MySQLConnection _connection;

  static Future<void> connect() async {
    print("Connecting to MySQL server...");

    _connection = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'msk_2023596',
      password: 'msk_2023596',
      databaseName: 'msk_2023596',
    );

    await _connection.connect();
    print("Connected");
  }

  static MySQLConnection get connection => _connection;

  static Future<void> close() async {
    await _connection.close();
    print("Connection closed");
  }
}