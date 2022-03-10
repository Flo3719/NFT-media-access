// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3dart/browser.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyHomePage());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter. STATELESS',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter. STATELESS'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}

Future<String> getWalletOwner() async {
  final eth = window.ethereum;
  if (eth == null) {
    print('MetaMask is not available');
    return EthereumAddress.fromHex("0x0").toString();
  }

  final client = Web3Client.custom(eth.asRpcService());
  final credentials = await eth.requestAccount();

  print('Using ${credentials.address}');
  print('Client is listening: ${await client.isListeningForNetwork()}');

  return credentials.address.toString();
}

Future<DeployedContract> loadContract() async {
  String abiCode = await rootBundle.loadString("abi.json");
  String contractAddress = "0x0305ef0f0322daA0C1BD3fEbC18928b7Bebc8464";

  final contract = DeployedContract(ContractAbi.fromJson(abiCode, "LUZ"),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

Future<void> getConnectedNetwork() async {
  final eth = window.ethereum;
  if (eth == null) {
    print('MetaMask is not available');
  }
  final client = Web3Client.custom(eth!.asRpcService());

  final int currentNetwork = await client.getNetworkId();
  print('Current Network connected: $currentNetwork');

  // Values:
  // 1: Ethereum Mainnet
  // 2: Morden Testnet (deprecated)
  // 3: Ropsten Testnet
  // 4: Rinkeby Testnet
  // 42: Kovan Testnet
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;

  String ownerOfNumberOne = "press query";

  @override
  void initState() {
    super.initState();
    httpClient = new Client();
    ethClient = new Web3Client("https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161", httpClient);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter. STATEFUL',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter. STATEFUL'),
        ),
        body: Center(
          child: Column(
            children: [
              CurrentWalletOwner(),
              TextButton(
                  onPressed: () async {
                    var result = await getOwnershipData(1);
                    setState(() {
                      ownerOfNumberOne = result;
                    });
                  },
                  child: const Text('Query')),
                  Text("The Number one is owned by: $ownerOfNumberOne")
            ],
          ),
        ),
      ),
    );
  }

  // Pbbly. Don't need submit function for this app.
  // Future<String> submit(String functionName, List<dynamic> args) async {
  //   EthPrivateKey credentials = EthPrivateKey.fromHex(
  //     "3d272d3193203d7a4458ea2a38ace936075c776512fc27093597ca2c790602a9");

  //   DeployedContract contract = await loadContract();

  //   final ethFunction = contract.function(functionName);

  //   var result = await ethClient.sendTransaction(
  //     credentials,
  //     Transaction.callContract(
  //       contract: contract,
  //       function: ethFunction,
  //       parameters: args,
  //     ),
  //   );
  //   return result;
  // }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return data;
  }

  Future<String> getOwnershipData(int tokenId) async {
    var tokenIdUint = BigInt.from(tokenId);

    var response = await query("getOwnershipData", [tokenIdUint]);

    print("response: $response");

    return response.toString();
  }
}

class CurrentWalletOwner extends StatelessWidget {
  const CurrentWalletOwner({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return FutureBuilder<String>(
        future: getWalletOwner(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

// Future<void> main() async {

//   // call contract method "getOwnershipData" for "totalSupply" times.
//   // add owned tokens for "credentials.address" to array
//   // show list with array of owned tokens

//   // final message = Uint8List.fromList(utf8.encode('Hello from web3dart'));
//   // final signature = await credentials.signPersonalMessage(message);
//   // print('Signature: ${base64.encode(signature)}');
// }
