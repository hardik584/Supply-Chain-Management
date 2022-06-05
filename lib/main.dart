// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:scm/contract_linking_page.dart';
import 'package:scm/scm_page.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractLinking>(
      create: (context) => ContractLinking(context),
      child: MaterialApp(
        title: 'Supply Chain Management DAPP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SupplyChainPage(),
      ),
    );
  }
}
