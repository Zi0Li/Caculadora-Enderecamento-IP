import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  return runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _IpMask = new MaskTextInputFormatter(
    mask: '###.###.###.###/##',
  );
  var _MaskMask = new MaskTextInputFormatter(
    mask: '###.###.###.###',
  );
  var _CidrMask = new MaskTextInputFormatter(
    mask: '/##',
  );
  var _ClassMask = new MaskTextInputFormatter(mask: '#'.toUpperCase());

  CalculatorIp calcular = CalculatorIp();
  String _backupIP = '';
  String _backupMask = '';
  String _errorMenssage = '';
  TextEditingController _IpController = TextEditingController();
  TextEditingController _ClassController = TextEditingController();
  TextEditingController _MaskController = TextEditingController();
  TextEditingController _CidrController = TextEditingController();
  TextEditingController _SrController = TextEditingController();
  TextEditingController _HostController = TextEditingController();
  TextEditingController _BinaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          ElevatedButton(
            onPressed: _clearAll,
            child: Icon(
              Icons.cleaning_services_outlined,
              size: 24,
            ),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
          )
        ],
        title: Text(
          'Endereçamento de IP',
          style: TextStyle(fontSize: 30, color: Colors.amber),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TextInput(_IpController, 'IP', TextInputType.number, _IpMask),
            Divider(),
            _TextInput(
                _MaskController, 'Mascara', TextInputType.number, _MaskMask),
            Divider(),
            Row(
              children: [
                Expanded(
                    child: _TextInput(_ClassController, 'Classe',
                        TextInputType.text, _CidrMask, false)),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: _TextInput(_CidrController, 'CIDR',
                        TextInputType.number, _IpMask, false)),
                SizedBox(
                  width: 8,
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                    child: _TextInput(_SrController, 'SR', TextInputType.number,
                        _IpMask, false)),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: _TextInput(_HostController, 'HOST\'s',
                        TextInputType.number, _IpMask, false)),
              ],
            ),
            Divider(),
            _TextInput(_BinaryController, 'IP Binario', TextInputType.number,
                _IpMask, false),
            Divider(),
            Text(
              _errorMenssage,
              style: TextStyle(color: Colors.red),
            ),
            Divider(),
            ElevatedButton(
              onPressed: _mission,
              child: Text(
                'Calcular',
                style: TextStyle(color: Colors.amber, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, fixedSize: Size(250, 45)),
            )
          ],
        ),
      ),
    );
  }

  Widget _TextInput(TextEditingController controller, String label,
      TextInputType keyType, MaskTextInputFormatter mask,
      [bool arg = true]) {
    return TextField(
      enabled: arg,
      keyboardType: keyType,
      controller: controller,
      inputFormatters: [mask],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 18),
        border: OutlineInputBorder(),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _IpController.text = '';
      _ClassController.text = '';
      _MaskController.text = '';
      _CidrController.text = '';
      _SrController.text = '';
      _HostController.text = '';
      _BinaryController.text = '';
      _errorMenssage = '';
    });
  }

  void _missionIpCidr(List<String> ip) {
    String cidr = ip[4];
    ip.remove(ip[4]);
    final classe = calcular._classIdentifier(ip).toString();
    final ipBinary = calcular._binaryConverter(ip);
    final mask = calcular._cidrForMask(cidr);
    final maskBinary = calcular._binaryConverter(calcular._ipSeparator(mask));
    final bits = calcular._bitsCont(maskBinary);
    final hosts = calcular._getHosts(int.parse(bits[0]));

    setState(() {
      _ClassController.text = classe;
      _BinaryController.text = ipBinary.toString();
      _MaskController.text = mask.toString();
      _HostController.text = hosts.toString();
      _CidrController.text = cidr;
      _SrController.text = (hosts + 2).toString();
      _backupIP = _IpController.text;
      _backupMask = _MaskController.text;
    });
  }

  void _missionMaskIp(List<String> ip, String mask) {
    if (ip.length == 5) ip.remove(ip[4]);
    final maskBinary = calcular._binaryConverter(calcular._ipSeparator(mask));
    final bits = calcular._bitsCont(maskBinary);
    String cidr = bits[1];
    String _ip = calcular._ipFormatter(ip);
    _ip += '/' + cidr;
    final classe = calcular._classIdentifier(ip).toString();
    final ipBinary = calcular._binaryConverter(ip);
    final hosts = calcular._getHosts(int.parse(bits[0]));
    ip.add(cidr);

    setState(() {
      _IpController.text = _ip;
      _ClassController.text = classe;
      _BinaryController.text = ipBinary.toString();
      _MaskController.text = mask.toString();
      _HostController.text = hosts.toString();
      _CidrController.text = cidr;
      _SrController.text = (hosts + 2).toString();
      _backupIP = _IpController.text;
      _backupMask = _MaskController.text;
    });
  }

  void _mission() {
    bool error = true;
    _errorMenssage = '';
    setState(() {
      if (_IpController.text == '') {
        _errorMenssage = 'Digite um IP';
      } else {
        final ip = calcular._ipSeparator(_IpController.text);
        if (ip.length == 4 && _MaskController.text == '') {
          _errorMenssage = 'Digite uma mascara';
        } else {
          for (int i = 0; i < 4; i++) {
            if (int.parse(ip[i]) > 255 || int.parse(ip[i]) < 0) {
              error = false;
              _errorMenssage = 'IP invalido';
            }
          }
          if (ip.length == 5) {
            if (_ClassController.text == 'A' && int.parse(ip[4]) < 8) {
              error = false;
              _errorMenssage = "CIDR da classe 'A' é maior ou igual a '8'";
            } else if (_ClassController.text == 'B' && int.parse(ip[4]) < 16) {
              error = false;
              _errorMenssage = "CIDR da classe 'B' é maior ou igual a '16'";
            } else if (_ClassController.text == 'C' && int.parse(ip[4]) < 24) {
              error = false;
              _errorMenssage = "CIDR da classe 'C é maior ou igual a '24'";
            }
          }
          if (error) {
            if (_IpController.text != _backupIP && ip.length == 5) {
              _missionIpCidr(ip);
            } else if (_MaskController.text != _backupMask ||
                _IpController.text != _backupIP) {
              _missionMaskIp(ip, _MaskController.text);
            } else {
              _errorMenssage = 'Não teve alterações';
            }
          }
        }
      }
    });
  }
}

class CalculatorIp {
  List<int> bits = [128, 64, 32, 16, 8, 4, 2, 1];

  String _ipFormatter(List<String> ip) {
    String _ip = '';
    for (int i = 0; i < ip.length - 1; i++) {
      _ip += ip[i] + '.';
    }
    _ip += ip[ip.length - 1];
    return _ip;
  }

  num _getHosts(int cont0) {
    final hosts = pow(2, cont0);
    return hosts - 2;
  }

  List<String> _bitsCont(List<String> binary) {
    String aux = '';
    int cont1 = 0, cont0 = 0;
    List<String> bits = [];
    for (int i = 0; i < binary.length; i++) {
      aux += binary[i];
    }
    var teste = aux.replaceAll(".", "");
    aux = '';
    for (int i = 0; i < teste.length; i++) {
      aux += teste[i];
    }
    for (int i = 0; i < aux.length; i++) {
      if (aux[i] == '1') {
        cont1 += 1;
      } else {
        cont0 += 1;
      }
    }
    bits.add(cont0.toString());
    bits.add(cont1.toString());
    return bits;
  }

  String _cidrForMask(String cidr) {
    var num = int.parse(cidr);
    int aux = 0, z = 0;
    List<String> mask = [];
    String _mask = '';
    for (int i = 0; i < num; i++) {
      aux += bits[z];
      z++;
      if (aux == 255) {
        mask.add('${aux.toString()}.');
        aux = 0;
        z = 0;
      }
    }
    mask.add(aux.toString());

    if (mask.length == 2) {
      mask.add('.0');
      mask.add('.0');
    } else if (mask.length == 3) {
      mask.add('.0');
    }
    for (int i = 0; i < 4; i++) _mask += mask[i];
    return _mask;
  }

  List<String> _ipSeparator(String x) {
    final aux = x.replaceAll("/", ".");
    final ip = aux.split(".");
    return ip;
  }

  String _classIdentifier(List<String> ip) {
    if (int.parse(ip[0]) >= 0 && int.parse(ip[0]) <= 127) {
      return 'A';
    } else if (int.parse(ip[0]) >= 128 && int.parse(ip[0]) <= 191) {
      return 'B';
    } else if (int.parse(ip[0]) >= 192 && int.parse(ip[0]) <= 223) {
      return 'C';
    } else {
      return 'Error';
    }
  }

  List<String> _binaryConverter(List<String> ip) {
    String binary = '';
    List<String> x = [];
    for (int i = 0; i < ip.length; i++) {
      int aux = int.parse(ip[i]);
      int resultado = aux ~/ 2;
      for (int h = 0; h < 8 && resultado >= 2; h++) {
        int resto = aux - (resultado * 2);
        binary += resto.toString();
        aux = resultado;
        resultado = aux ~/ 2;
      }
      binary += (aux - (resultado * 2)).toString();
      binary += resultado.toString();
      x.add(_zeroFill(binary));
      binary = '';
    }
    return x;
  }

  String _zeroFill(String ip) {
    String binary = ip;
    int aux = 8 - (ip.length);
    for (int i = 0; i < aux; i++) {
      binary += '0';
    }
    binary = binary.split('').reversed.join();
    return binary;
  }
}
