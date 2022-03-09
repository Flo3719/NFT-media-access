// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3dart/browser.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

Future<EthereumAddress> getWalletOwner() async {
  final eth = window.ethereum;
  if (eth == null) {
    print('MetaMask is not available');
    return EthereumAddress.fromHex("0x0");
  }

  final client = Web3Client.custom(eth.asRpcService());
  final credentials = await eth.requestAccount();

  print('Using ${credentials.address}');
  print('Client is listening: ${await client.isListeningForNetwork()}');

  return credentials.address;
}

Future<DeployedContract> loadContract() async {
  String abiCode = await rootBundle.loadString("assets/abi.json");
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

// Future<void> main() async {
  


//   // call contract method "getOwnershipData" for "totalSupply" times.
//   // add owned tokens for "credentials.address" to array
//   // show list with array of owned tokens

//   // final message = Uint8List.fromList(utf8.encode('Hello from web3dart'));
//   // final signature = await credentials.signPersonalMessage(message);
//   // print('Signature: ${base64.encode(signature)}');
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpClient;
  Web3Client ethClient;

  @override
  void initState() {
    super.initState();
    httpClient = new Client();
    ethClient = new Web3Client("http://localhost:8545", httpClient);
  }

  // rest of class
}
