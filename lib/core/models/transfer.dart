/// transfer.dart
/// Handles player transfers: offers, negotiations, contracts, completed transfers

import 'team.dart';
import 'player.dart';

enum TransferStatus { pending, accepted, rejected, completed }

class TransferOffer {
  Player player;
  Team fromTeam;
  Team toTeam;
  double offerAmount;
  int contractDuration; // in years
  TransferStatus status;
  DateTime offerDate;

  TransferOffer({
    required this.player,
    required this.fromTeam,
    required this.toTeam,
    required this.offerAmount,
    this.contractDuration = 3,
    this.status = TransferStatus.pending,
    DateTime? offerDate,
  }) : offerDate = offerDate ?? DateTime.now();

  /// Evaluate the offer
  bool evaluate() {
    // Basic evaluation: offer must meet player's value
    if (offerAmount >= player.marketValue) {
      status = TransferStatus.accepted;
      return true;
    } else {
      status = TransferStatus.rejected;
      return false;
    }
  }

  /// Complete the transfer
  void complete() {
    if (status != TransferStatus.accepted) return;

    // Remove player from old team and add to new team
    fromTeam.roster.remove(player);
    toTeam.roster.add(player);

    // Update player's team and contract
    player.club = toTeam as String;
    player.contractYears = contractDuration;

    status = TransferStatus.completed;
  }
}

class TransferMarket {
  List<TransferOffer> offers = [];

  /// Propose a new transfer
  void proposeTransfer({
    required Player player,
    required Team fromTeam,
    required Team toTeam,
    required double offerAmount,
    int contractDuration = 3,
  }) {
    final offer = TransferOffer(
      player: player,
      fromTeam: fromTeam,
      toTeam: toTeam,
      offerAmount: offerAmount,
      contractDuration: contractDuration,
    );
    offers.add(offer);
  }

  /// Process all pending offers
  void processOffers() {
    for (var offer in offers.where((o) => o.status == TransferStatus.pending)) {
      if (offer.evaluate()) {
        offer.complete();
      }
    }
  }

  /// Cancel an offer
  void cancelOffer(TransferOffer offer) {
    if (offer.status == TransferStatus.pending) {
      offer.status = TransferStatus.rejected;
    }
  }

  /// List all active offers for a player
  List<TransferOffer> offersForPlayer(Player player) {
    return offers
        .where((o) => o.player == player && o.status == TransferStatus.pending)
        .toList();
  }

  /// List all completed transfers
  List<TransferOffer> completedTransfers() {
    return offers.where((o) => o.status == TransferStatus.completed).toList();
  }
}
