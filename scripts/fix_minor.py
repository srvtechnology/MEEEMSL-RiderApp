with open('lib/core/utils/formatters.dart', 'r') as f:
    c = f.read().replace("'${hours} hrs'", "'$hours hrs'")
with open('lib/core/utils/formatters.dart', 'w') as f:
    f.write(c)

with open('lib/presentation/modules/navigation/controllers/navigation_controller.dart', 'r') as f:
    c = f.read().replace("${lat},${lng}", "$lat,$lng")
with open('lib/presentation/modules/navigation/controllers/navigation_controller.dart', 'w') as f:
    f.write(c)

with open('test/data/models/order_model_test.dart', 'r') as f:
    c = f.read().replace("const tOrderModel = OrderModel(", "final tOrderModel = OrderModel(").replace("createdAt: null,", "createdAt: DateTime(2026, 1, 1),")
with open('test/data/models/order_model_test.dart', 'w') as f:
    f.write(c)

with open('test/widget_test.dart', 'r') as f:
    c = f.read().replace("import 'package:get/get.dart';\n", "")
with open('test/widget_test.dart', 'w') as f:
    f.write(c)

print("Minor fixes applied.")
