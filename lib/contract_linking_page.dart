// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart";

import 'package:web3dart/web3dart.dart';
import 'package:web3dart/json_rpc.dart';

class Item {
  final EthereumAddress? itemAddress;
  final String? itemName;
  final BigInt? itemPrice;
  final BigInt? supplyChainStatus;

  Item(this.itemAddress, this.itemName, this.itemPrice, this.supplyChainStatus);
}

class ContractLinking extends ChangeNotifier {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final TextEditingController itemIndexController = TextEditingController();

  /// RPC => Remote Procedure Calls
  final String _rpcUrl = 'http://127.0.0.1:7545';
  // WS => Web Socket
  final String _wsUrl = 'ws://127.0.0.1:7545';
  final String _privateKey =
      '80f9b035021b9c00d3ad02077ad4d99f9e8b9da88a5195315ba3d7cc3f2baeba';
  Web3Client? _web3client;

  /// ABI => application binary interface
  String? _abiCode;
  EthereumAddress? _contractAddress;

  Credentials? _credentials;

  DeployedContract? _contract;

  ContractFunction? _items;

  /// These are functions for create item,
  /// pay amount towards particulur item and
  /// send delivery for item
  ContractFunction? _createItem;
  ContractFunction? _triggerPayment;
  ContractFunction? _triggerDelivery;

  Item? mySelectedItem;
  bool isLoading = false;
  late BuildContext context;

  ContractLinking(this.context) {
    setUp();
  }

  setUp() async {
    _web3client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString('client/src/contracts/ItemManager.json');
    final jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi['abi']);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi['networks']['5777']['address']);
  }

  Future<void> getCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, 'Item Manager'), _contractAddress!);
    _items = _contract!.function("items");
    _createItem = _contract!.function('createItem');
    _triggerPayment = _contract!.function('triggerPayment');
    _triggerDelivery = _contract!.function('triggerDelivery');
    getItemFromIndex(context: context, itemindex: BigInt.zero);
  }

  /// [getItemFromIndex] is for fetch existing item from itemIndex
  void getItemFromIndex(
      {required BigInt itemindex, required BuildContext context}) async {
    isLoading = true;
    notifyListeners();
    try {
      final myItems = await _web3client!
          .call(contract: _contract!, function: _items!, params: [itemindex]);

      mySelectedItem = Item(myItems[0], myItems[1], myItems[2], myItems[3]);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (e is RPCError) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  /// [createItem] is for the create brand new item
  ///  change SupplyChainState to SupplyChainState.Created
  void createItem(
      {required String identifier,
      required BigInt itemPrice,
      required BuildContext context}) async {
    isLoading = true;
    notifyListeners();
    try {
      await _web3client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _contract!,
          function: _createItem!,
          parameters: [identifier, itemPrice],
        ),
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (e is RPCError) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  /// [triggerPayment] is for the pay for respected item
  ///  change SupplyChainState to SupplyChainState.Paid
  void triggerPayment(
      {required BigInt itemIndex, required BuildContext context}) async {
    isLoading = true;
    notifyListeners();
    try {
      await _web3client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _contract!,
          value: EtherAmount.inWei(mySelectedItem?.itemPrice ?? BigInt.one),
          function: _triggerPayment!,
          parameters: [itemIndex],
        ),
      );

      getItemFromIndex(
        itemindex: itemIndex,
        context: context,
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (e is RPCError) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  /// [triggerDelivery] is for the deliver the item toward respected
  /// itemIndex and change SupplyChainState to SupplyChainState.Delivered
  void triggerDelivery(
      {required BigInt itemIndex, required BuildContext context}) async {
    isLoading = true;
    notifyListeners();
    try {
      await _web3client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _contract!,
          function: _triggerDelivery!,
          parameters: [itemIndex],
        ),
      );
      getItemFromIndex(
        itemindex: itemIndex,
        context: context,
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (e is RPCError) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
