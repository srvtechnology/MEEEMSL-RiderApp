import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.name,
    required super.quantity,
    super.notes = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productName = json['productNameSnapshot'] as String? ??
        (json['product'] is Map ? (json['product'] as Map)['name'] as String? : null) ??
        json['name'] as String? ??
        'Item';

    return OrderItemModel(
      name: productName,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      name: entity.name,
      quantity: entity.quantity,
      notes: entity.notes,
    );
  }
}
