 //defined the model used for stroing item in database
class Item {
  String name;
  String? maintenanceDate;
  String? imageUrl;
  String? installmentDate;
  String? documentId;

  Item({
    required this.name,
    required this.installmentDate,
    required this.imageUrl,
    required this.maintenanceDate,
    required this.documentId,
  });
}
