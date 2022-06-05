// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/contract_linking_page.dart';

class SupplyChainPage extends StatefulWidget {
  const SupplyChainPage({Key? key}) : super(key: key);

  @override
  State<SupplyChainPage> createState() => _SupplyChainPageState();
}

class _SupplyChainPageState extends State<SupplyChainPage> {
  void createItem({required ContractLinking contractLink}) {
    if (contractLink.itemNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter item name.'),
        ),
      );
    } else if (contractLink.itemPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter item price.'),
        ),
      );
    } else {
      contractLink.createItem(
          context: context,
          identifier: contractLink.itemNameController.text,
          itemPrice: BigInt.from(
              int.tryParse(contractLink.itemPriceController.text) ?? 0));
      contractLink.itemNameController.clear();
      contractLink.itemPriceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your item created successfully.'),
        ),
      );
    }
  }

  void getSelectedItemFromIndex({required ContractLinking contractLink}) {
    try {
      contractLink.getItemFromIndex(
          context: context,
          itemindex:
              BigInt.from(int.parse(contractLink.itemIndexController.text)));
    } catch (e) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void payForSelectedItem({required ContractLinking contractLink}) {
    try {
      contractLink.triggerPayment(
          context: context,
          itemIndex:
              BigInt.from(int.parse(contractLink.itemIndexController.text)));
    } catch (e) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void deliveryForSelectedItem({required ContractLinking contractLink}) {
    try {
      contractLink.triggerDelivery(
          context: context,
          itemIndex:
              BigInt.from(int.parse(contractLink.itemIndexController.text)));
    } catch (e) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractLink = Provider.of<ContractLinking>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: contractLink.isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        const Text(
                          'Welcome to Supply Chain Management Blockchain DApp',
                        ),
                        TextFormField(
                          controller: contractLink.itemNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter item name',
                          ),
                        ),
                        TextFormField(
                          controller: contractLink.itemPriceController,
                          decoration: const InputDecoration(
                            hintText: 'Enter item price',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            createItem(contractLink: contractLink);
                          },
                          child: const Text(
                            'Create New Item',
                          ),
                        ),
                        for (int i = 0; i < 5; i++)
                          const Divider(color: Colors.blue, height: 1.3),
                        TextFormField(
                          controller: contractLink.itemIndexController,
                          decoration: const InputDecoration(
                            hintText: 'Enter item index',
                          ),
                        ),
                        if (contractLink.mySelectedItem != null)
                          ItemWidget(
                            itemAddress: contractLink
                                    .mySelectedItem?.itemAddress
                                    .toString() ??
                                '',
                            itemIndex: contractLink.itemIndexController.text,
                            itemName:
                                contractLink.mySelectedItem?.itemName ?? '',
                            itemPrice: contractLink.mySelectedItem?.itemPrice
                                    .toString() ??
                                '',
                            itemStatus:
                                contractLink.mySelectedItem!.supplyChainStatus!,
                          ),
                        ElevatedButton(
                          onPressed: () {
                            getSelectedItemFromIndex(
                                contractLink: contractLink);
                          },
                          child: const Text(
                            'Get item from index',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            payForSelectedItem(contractLink: contractLink);
                          },
                          child: const Text(
                            'Pay for item',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            deliveryForSelectedItem(contractLink: contractLink);
                          },
                          child: const Text(
                            'Deliver to item',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String itemIndex;
  final String itemName;
  final String itemPrice;
  final String itemAddress;
  final BigInt itemStatus;
  const ItemWidget(
      {Key? key,
      required this.itemIndex,
      required this.itemName,
      required this.itemPrice,
      required this.itemAddress,
      required this.itemStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(child: Text(itemIndex)),
        title: Text(itemAddress),
        subtitle: Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: Text(itemName)),
              const Text(' | '),
              Flexible(child: Text(itemPrice)),
            ],
          ),
        ),
        trailing: ProductSupplyChainStatusBadgeWidget(
          itemStatus: itemStatus,
        ));
  }
}

class ProductSupplyChainStatusBadgeWidget extends StatelessWidget {
  final BigInt itemStatus;
  const ProductSupplyChainStatusBadgeWidget(
      {Key? key, required this.itemStatus})
      : super(key: key);

  Color getRespectedColor() {
    if (itemStatus == BigInt.zero) {
      return Colors.amber;
    } else if (itemStatus == BigInt.one) {
      return Colors.blue;
    } else if (itemStatus == BigInt.two) {
      return Colors.green;
    } else {
      return Colors.amber;
    }
  }

  String getRespectedStatusText() {
    if (itemStatus == BigInt.zero) {
      return "Created";
    } else if (itemStatus == BigInt.one) {
      return "Paid";
    } else if (itemStatus == BigInt.two) {
      return "Delivery";
    } else {
      return "Created";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: getRespectedColor(),
      label: Text(
        getRespectedStatusText(),
      ),
    );
  }
}
