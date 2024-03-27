import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:system_info2/system_info2.dart';
//import 'package:system_resources/system_resources.dart';

const String x_api_key = 'NXlkZGg1bmVqdTl5MTY5a2I3NnRyM2I0cWV5YTVoMmI=';
final String ip = '0.0.0.0';
const int port = 80;

final _router = Router()
  ..post('/server-info', _rootHandler)
  ..get('/', _index);

Response _index(Request req) {
  return Response(
    200,
    body: jsonEncode(
      {'status': 'ok'},
    ),
    headers: {"Content-Type": "application/json"},
  );
}

Response _rootHandler(Request req) {
  const int megaByte = 1024 * 1024;

  int physicalMemoryTotal = SysInfo.getTotalPhysicalMemory() ~/ megaByte;
  int physicalMemoryFree = SysInfo.getFreePhysicalMemory() ~/ megaByte;

  int virtualMemoryTotal = SysInfo.getTotalVirtualMemory() ~/ megaByte;
  int virtualMemoryFree = SysInfo.getFreeVirtualMemory() ~/ megaByte;

  if (x_api_key != req.headers['x-api-key']) {
    return Response.badRequest(
      body: jsonEncode(
        {'error': 'bad request'},
      ),
      headers: {"Content-Type": "application/json"},
    );
  }

  return Response(
    200,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(
      {
        'kernel_bitness': SysInfo.kernelBitness,
        'kernel_name': SysInfo.kernelName,
        'kernel_version': SysInfo.kernelVersion,
        'system_name': SysInfo.operatingSystemName,
        'system_version': SysInfo.operatingSystemVersion,
        'user_directory': SysInfo.userDirectory,
        'user_id': SysInfo.userId,
        'user_name': SysInfo.userName,
        'user_space_bitness': SysInfo.userSpaceBitness,
        'cores': SysInfo.cores.length,
        'physical_memory': {
          'total': physicalMemoryTotal,
          'free': physicalMemoryFree,
          'busy': physicalMemoryTotal - physicalMemoryFree
        },
        'virtual_memory': {
          'total': virtualMemoryTotal,
          'free': virtualMemoryFree,
          'busy': virtualMemoryTotal - virtualMemoryFree
        },
        // 'cpu_load_average': (SystemResources.cpuLoadAvg() * 100).toInt(),
        // 'memory_usage': (SystemResources.memUsage() * 100).toInt()
      },
    ),
  );
}

void main(List<String> args) async {
  //SystemResources.init();

  final handler = Pipeline()
      .addMiddleware(
        logRequests(),
      )
      .addHandler(
        _router.call,
      );

  final server = await serve(handler, ip, port);

  print('Server listening on port ${server.port}');
}
