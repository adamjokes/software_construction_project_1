import 'package:flutter/foundation.dart';
import 'package:workampus/app/locator.dart';
import 'package:workampus/models/contract.dart';
import 'package:workampus/models/payment.dart';
import 'package:workampus/models/payout.dart';
import 'package:workampus/models/user.dart';
import 'package:workampus/services/contract/contract_firestore_service.dart';
import 'package:workampus/services/payment/payment_firestore_service.dart';
import 'package:workampus/services/payment/payout_firestore_service.dart';
import 'package:workampus/services/user/user_firestore_service.dart';

import '../../viewmodel.dart';

class PaymentViewModel extends ViewModel {
  final UserFirestoreService _userFirestoreService =
      locator<UserFirestoreService>();
  final PaymentFirestoreService _paymentFirestoreService =
      locator<PaymentFirestoreService>();
  final ContractFirestoreService _contractFirestoreService =
      locator<ContractFirestoreService>();
  final PayoutFirestoreService _payoutFirestoreService =
      locator<PayoutFirestoreService>();

  bool empty = false;

  List<User> _contractors;
  List<User> get contractors => _contractors;

  List<Payment> _payments;
  List<Payment> get payments => _payments;

  List<Contract> _contracts;
  List<Contract> get completedContracts => _contracts;

  User _updatedUser;
  User get updatedUser => _updatedUser;

  //// Read Contract
  Future initialise() async {
    List<String> contractsIDs = [];
    List<String> jobProvidersIDs = [];

    // retrieve ongoing contracts from firebase
    setBusy(true);

    _updatedUser = await _userFirestoreService.getUser(currentUser.id);

    _payments =
        await _paymentFirestoreService.getJobSeekerPayments(currentUser.id);
    print("payment dapatttt " + _payments.length.toString());
    _payments.sort((b, a) => a.createdAt.millisecondsSinceEpoch
        .compareTo(b.createdAt.millisecondsSinceEpoch));
    if (_payments.length == 0) {
      setBusy(false);
      empty = true;
    } else {
      final temp = _payments.map((contract) {
        if (!contractsIDs.contains(contract.contractID))
          return contract.contractID;
      }).toList();
      contractsIDs.addAll(temp);
      print("contract ID dapatttt " + contractsIDs.length.toString());
      print("contract ID dapatttt " + contractsIDs.toString());
      _contracts = await _contractFirestoreService
          .getContractsFromIDs(contractsIDs)
          .then((value1) async {
        return _contracts = value1;
      }).whenComplete(() async {
        print("contract dapatttt " + _contracts.length.toString());
        final temp1 = _payments.map((contractor) {
          if (!jobProvidersIDs.contains(contractor.currUserID))
            return contractor.currUserID;
        }).toList();
        jobProvidersIDs.addAll(temp1);
        print("contractors ADAA " + jobProvidersIDs.length.toString());
        print(jobProvidersIDs);
        _contractors = await _userFirestoreService
            .getUsersFromIDs(jobProvidersIDs)
            .then((value2) {
          return _contractors = value2;
        }).whenComplete(() {
          setBusy(false);
        });
      });
    }
  }

  Contract getContract(String id) =>
      _contracts.firstWhere((completedContract) => completedContract.id == id);

  User getContractor(String id) =>
      _contractors.firstWhere((contractor) => contractor.id == id);

  void receiveCashPayment({
    @required String paymentID,
    @required String contractID,
    @required num amount,
    @required User jobProvider,
  }) async {
    setBusy(true);

    num newJPSpending = jobProvider.spending + amount;

    await _contractFirestoreService.updateContractStatus(contractID,
        status: 'completed');

    await _contractFirestoreService.updateContractPayment(
      contractID,
      pendingPayment: false,
    );

    await _paymentFirestoreService.receiveCashPayment(paymentID);

    await _userFirestoreService.updateUser(jobProvider.id,
        spending: newJPSpending);

    setBusy(false);
  }

  void withdrawFund({
    @required var amount,
  }) async {
    setBusy(true);

    var newEarning = currentUser.earning - amount;
    print('New Earning = ' + newEarning.toString());

    await _userFirestoreService.updateUser(currentUser.id, earning: newEarning);

    final requestPayout =
        Payout.createNew(userID: currentUser.id, requestAmount: amount);

    await _payoutFirestoreService.createPayout(requestPayout);
    // await _payoutFirestoreService.updatePayoutID(result);

    setBusy(false);
  }
}
