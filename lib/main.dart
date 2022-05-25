// ignore_for_file: deprecated_member_use, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pkcoin/slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MetaCoin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;

  final myAddress = "0x63e2b80AA34f048EDdBe67a687354b9F458187B2";
  int myAmount = 0;
  // ignore: prefer_typing_uninitialized_variables
  var myData;
  String? txHash;
  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/5ad3edc61eea4a0e92afdf73c4ff0b74",
        httpClient);

    getBalance(myAddress);
  }

// 0x2Bd4532953f109b82da5F4706c0c904869f1f0a1
// PKCoin
  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/api.json");
    String contractAddress = "0x3F6EE9d6f990A2Dad561de30Ef334C783D8977f0";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "MetaCoin"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
    data = true;
    setState(() {});
  }
  // 1f540732cc6999f019ca3476fbca5b2a22ff3599db02dc1846e0ba49ce034b32

  Future<String> submit(String funName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "1f540732cc6999f019ca3476fbca5b2a22ff3599db02dc1846e0ba49ce034b32");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(funName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        fetchChainIdFromNetworkId: false,
        chainId: 4);

    return result;
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmount]);
    // ignore: avoid_print
    print("Deposited");
    txHash = response;
    setState(() {});
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmount]);

    // ignore: avoid_print
    print("withdraw");
    txHash = response;
    setState(() {});
    return response;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .blue600
            .size(context.screenWidth, context.percentHeight * 30)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "\$METACOIN".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 5).heightBox,
          VxBox(
            child: VStack([
              "Balance".text.gray700.xl2.semiBold.makeCentered(),
              10.heightBox,
              data
                  ? "\$$myData".text.bold.xl4.makeCentered().shimmer()
                  : const CircularProgressIndicator().centered()
            ]),
          )
              .p16
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded
              .shadowXl
              .make()
              .p16(),
          30.heightBox,
          SliderWidget(
            min: 0,
            max: 100,
            finalVal: (val) {
              myAmount = (val * 100).round();
              print(myAmount);
            },
          ).centered(),
          HStack(
            [
              FlatButton.icon(
                onPressed: () => getBalance(myAddress),
                color: Colors.blue,
                shape: Vx.roundedSm,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: "Refesh".text.white.make(),
              ).h(50),
              FlatButton.icon(
                onPressed: () => sendCoin(),
                color: Colors.green,
                shape: Vx.roundedSm,
                icon: const Icon(
                  Icons.call_made_outlined,
                  color: Colors.white,
                ),
                label: "Deposit".text.white.make(),
              ).h(50),
              FlatButton.icon(
                onPressed: () => withdrawCoin(),
                color: Colors.red,
                shape: Vx.roundedSm,
                icon: const Icon(
                  Icons.call_received_outlined,
                  color: Colors.white,
                ),
                label: "Withdraw".text.white.make(),
              ).h(50),
            ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ).py12(),
          if (txHash != null) txHash!.text.black.makeCentered().p16()
        ]),
      ]),
    );
  }
}
