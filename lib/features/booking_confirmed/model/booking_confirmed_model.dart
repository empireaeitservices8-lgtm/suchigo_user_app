class BookingConfirmedModel {
  final String bookingId;
  final String status;
  final String wasteType;
  final String collectionDate;
  final String estWeight;
  final String contactName;
  final String contactPhone;
  final String pickupAddress;
  final String co2Saved;
  final String recycledPercent;
  final String treesEquiv;
  final String standardRate;

  const BookingConfirmedModel({
    this.bookingId = 'WC-115',
    this.status = 'Confirmed',
    this.wasteType = '1',
    this.collectionDate = 'Friday, 2 Oct 2026',
    this.estWeight = '2.5 kg',
    this.contactName = 'aslam',
    this.contactPhone = '+917306929058',
    this.pickupAddress =
        '9F, Kakkanad, Keralam, 682303,\nIndia,\nErnakulam – 682303',
    this.co2Saved = '2.4 kg',
    this.recycledPercent = '85%',
    this.treesEquiv = '0.3',
    this.standardRate = '₹40.00/kg',
  });
}
