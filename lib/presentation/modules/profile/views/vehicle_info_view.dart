import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../domain/entities/vehicle_entity.dart';
import '../controllers/profile_controller.dart';

class _VehicleOptionData {
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;

  const _VehicleOptionData({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const List<_VehicleOptionData> _vehicleOptions = [
  _VehicleOptionData(
    code: '2_WHEELER',
    title: '2-Wheeler (Motorcycle / Scooter)',
    subtitle: 'Motorcycle, Scooter, E-Bike',
    icon: Icons.two_wheeler,
  ),
  _VehicleOptionData(
    code: '3_WHEELER',
    title: '3-Wheeler (Auto Rickshaw / TukTuk)',
    subtitle: 'Auto Rickshaw, TukTuk, Cargo Trike',
    icon: Icons.electric_rickshaw_rounded,
  ),
  _VehicleOptionData(
    code: '4_WHEELER',
    title: '4-Wheeler (Car / Van / Delivery Truck)',
    subtitle: 'Car, Van, Delivery Truck',
    icon: Icons.directions_car_rounded,
  ),
  _VehicleOptionData(
    code: 'BICYCLE',
    title: 'Bicycle / Cargo Bike',
    subtitle: 'Standard Bicycle, Cargo Bike, Foot Courier',
    icon: Icons.pedal_bike_rounded,
  ),
];

class VehicleInfoView extends StatefulWidget {
  const VehicleInfoView({super.key});

  @override
  State<VehicleInfoView> createState() => _VehicleInfoViewState();
}

class _VehicleInfoViewState extends State<VehicleInfoView> {
  final controller = Get.find<ProfileController>();

  String selectedType = '2_WHEELER';
  final modelCtrl = TextEditingController();
  final plateCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final yearCtrl = TextEditingController();

  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _populateFromProfile();

    // Listen to real-time dynamic profile updates from API
    _profileSubscription = controller.riderProfile.listen((rider) {
      if (mounted && rider != null) {
        _populateFromProfile(overwriteIfUserEdited: false);
      }
    });
  }

  void _populateFromProfile({bool overwriteIfUserEdited = true}) {
    final rider = controller.riderProfile.value;
    if (rider == null) return;

    final rawType = rider.vehicleType ?? rider.vehicle?.type;
    final normalized = _normalizeVehicleType(rawType);

    final model = rider.vehicleName ?? rider.vehicle?.model ?? '';
    final plate = rider.vehicleNumber ?? rider.vehicle?.licensePlate ?? '';
    final color = rider.vehicle?.color ?? '';
    final year = rider.vehicle?.year ?? '';

    setState(() {
      selectedType = normalized;
      if (overwriteIfUserEdited || modelCtrl.text.isEmpty) {
        modelCtrl.text = model;
      }
      if (overwriteIfUserEdited || plateCtrl.text.isEmpty) {
        plateCtrl.text = plate;
      }
      if (overwriteIfUserEdited || colorCtrl.text.isEmpty) {
        colorCtrl.text = color;
      }
      if (overwriteIfUserEdited || yearCtrl.text.isEmpty) {
        yearCtrl.text = year;
      }
    });
  }

  String _normalizeVehicleType(String? raw) {
    if (raw == null || raw.isEmpty) return '2_WHEELER';
    final upper = raw.toUpperCase().replaceAll('-', '_');
    if (upper.contains('3_WHEELER') || upper.contains('RICKSHAW') || upper.contains('TUKTUK')) {
      return '3_WHEELER';
    }
    if (upper.contains('4_WHEELER') || upper.contains('CAR') || upper.contains('VAN') || upper.contains('TRUCK')) {
      return '4_WHEELER';
    }
    if (upper.contains('BICYCLE') || upper.contains('PEDAL')) {
      return 'BICYCLE';
    }
    return '2_WHEELER';
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    modelCtrl.dispose();
    plateCtrl.dispose();
    colorCtrl.dispose();
    yearCtrl.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    final plate = plateCtrl.text.trim();
    final model = modelCtrl.text.trim();

    if (plate.isEmpty) {
      Get.snackbar('Required Field', 'Please enter your vehicle license plate number.');
      return;
    }
    if (model.isEmpty) {
      Get.snackbar('Required Field', 'Please enter your vehicle make and model.');
      return;
    }

    final vehicle = VehicleEntity(
      type: selectedType,
      model: model,
      licensePlate: plate,
      color: colorCtrl.text.trim(),
      year: yearCtrl.text.trim(),
    );
    controller.saveVehicleInfo(vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vehicleDetails),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered Delivery Vehicle', style: AppTextStyles.headlineSmall()),
                    const SizedBox(height: 4),
                    Text(
                      'Ensure your vehicle details match your official documents.',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Type Selector (2-Wheeler, 3-Wheeler, 4-Wheeler, Bicycle)
                    const Text(
                      AppStrings.vehicleType,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),

                    ..._vehicleOptions.map((opt) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildVehicleOption(opt),
                      );
                    }),

                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: plateCtrl,
                      label: 'License Plate Number',
                      hintText: 'e.g. SL-AA-9988',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: modelCtrl,
                      label: 'Vehicle Make & Model',
                      hintText: 'e.g. Honda CB Shine 125',
                      prefixIcon: Icons.minor_crash_outlined,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: colorCtrl,
                            label: 'Color',
                            hintText: 'e.g. Sapphire Blue',
                            prefixIcon: Icons.color_lens_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: yearCtrl,
                            label: 'Year',
                            hintText: 'e.g. 2023',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: AppColors.lightCardBorder)),
              ),
              child: Obx(() => CustomButton(
                    text: 'Update Vehicle Details',
                    icon: Icons.check,
                    isLoading: controller.isLoading.value,
                    onPressed: _saveVehicle,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption(_VehicleOptionData opt) {
    final isSelected = selectedType == opt.code;

    return GestureDetector(
      onTap: () => setState(() => selectedType = opt.code),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightCardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.lightSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(opt.icon, color: isSelected ? Colors.white : AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(opt.subtitle, style: AppTextStyles.bodySmall()),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
