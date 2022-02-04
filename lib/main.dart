import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/browser.dart';
import 'contracts/LongShortPairCreator.g.dart';
import 'contracts/ExpiringMultiPartyCreator.g.dart';
import 'package:date_time_picker/date_time_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AX APTS',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Launch an Athlete APT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Web3Client defaultClient;
  late Credentials defaultCredentials;
  late BigInt expirationTimestamp, collateralPerPair, prepaidProposerReward;
  late String syntheticName, syntheticSymbol;
  late EthereumAddress collateralToken, financialProductLibrary;
  late Uint8List priceIdentifier, customAncillaryData;
  late LongShortPairCreator _creator;

  void connect() async {
    final eth = window.ethereum;
    var client = Web3Client.custom(eth!.asRpcService());
    var credentials = await eth.requestAccount();
    checkChain();
    setState(() {
      defaultClient = client;
      defaultCredentials = credentials;
    });
  }

  void checkChain() async {
    const mainnetChainID = 137;
    const testnetChainID = 80001;
    var rawactiveChainID = await defaultClient.getChainId();
    var activeChainID = rawactiveChainID.toInt();
    EthereumAddress localCollateralToken, localFinancialProductLibrary;
    switch (activeChainID) {
      case mainnetChainID:
        localCollateralToken = EthereumAddress.fromHex(
            "0x5617604ba0a30e0ff1d2163ab94e50d8b6d0b0df");
        localFinancialProductLibrary = EthereumAddress.fromHex(
            "0xda768D869f1e89ea005cde7e1dBf630ff9307F33");
        break;
      case testnetChainID:
        localCollateralToken = EthereumAddress.fromHex(
            "0x76d9a6e4cdefc840a47069b71824ad8ff4819e85");
        localFinancialProductLibrary = EthereumAddress.fromHex(
            "0x9a5de999108042946F59848E083e12690ff018C6");
        break;
      default:
        localCollateralToken = EthereumAddress.fromHex(
            "0x76d9a6e4cdefc840a47069b71824ad8ff4819e85");
        localFinancialProductLibrary = EthereumAddress.fromHex(
            "0x9a5de999108042946F59848E083e12690ff018C6");
        break;
    }

    setState(() {
      collateralToken = localCollateralToken;
      financialProductLibrary = localFinancialProductLibrary;
    });
  }

  void mint() async {}

  void createAnAPT() async {
    List<int> theList = utf8.encode("0");
    List<int> priceId = utf8.encode("AAVEUSD");
    priceIdentifier = Uint8List.fromList(priceId);
    customAncillaryData = Uint8List.fromList(theList);
    prepaidProposerReward = BigInt.from(12);

    _creator.createLongShortPair(
        expirationTimestamp,
        collateralPerPair,
        priceIdentifier,
        syntheticName,
        syntheticSymbol,
        collateralToken,
        financialProductLibrary,
        customAncillaryData,
        prepaidProposerReward,
        credentials: defaultCredentials);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.accessibility_new_rounded),
                    title: Text("My Favorite Athlete"),
                    subtitle: Text("Mint meee!"),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Enter the Synthetic Name",
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  DateTimePicker(
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd MMM, yyyy',
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    icon: Icon(Icons.event),
                    dateLabelText: 'Date',
                    timeLabelText: "Hour",
                    selectableDayPredicate: (date) {
                      // Disable weekend days to select from the calendar
                      if (date.weekday == 6 || date.weekday == 7) {
                        return false;
                      }

                      return true;
                    },
                    onChanged: (val) => print(val),
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Enter the Synthetic Symbol",
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "How much collateral is needed?",
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(onPressed: onPressed, child: child)
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final eth = window.ethereum;
          var client = Web3Client.custom(eth!.asRpcService());
          var credentials = await eth.requestAccount();
        },
        tooltip: 'Connect',
        child: const Icon(Icons.account_balance_wallet),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
