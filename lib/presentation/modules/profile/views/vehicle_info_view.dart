import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../domain/entities/vehicle_entity.dart';
import '../controllers/profile_controller.dart';

class VehicleInfoView extends StatefulWidget {
  const VehicleInfoView({super.key});

  @override
  State<VehicleInfoView> createState() => _VehicleInfoViewState();
}

class _VehicleInfoViewState extends State<VehicleInfoView> {
  final controller = Get.find<ProfileController>();

  late String selectedType;
  final modelCtrl = TextEditingController();
  final plateCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final yearCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vehicle = controller.riderProfile.value?.vehicle;
    selectedType = vehicle?.type ?? '2-Wheeler (Motorcycle / Scooter)';
    modelCtrl.text = vehicle?.model ?? 'Honda CB500X';
    plateCtrl.text = vehicle?.licensePlate ?? 'RD-8842-NY';
    colorCtrl.text = vehicle?.color ?? 'Sapphire Blue';
    yearCtrl.text = vehicle?.year ?? '2023';
  }

  @override
  void dispose() {
    modelCtrl.dispose();
    plateCtrl.dispose();
    colorCtrl.dispose();
    yearCtrl.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    final vehicle = VehicleEntity(
      type: selectedType,
      model: modelCtrl.text.trim(),
      licensePlate: plateCtrl.text.trim(),
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
                    Text('Ensure your vehicle details match your official documents.', style: AppTextStyles.bodyMedium()),
                    const SizedBox(height: 20),

                    // Vehicle Type Selector (2-Wheeler, 3-Wheeler, 4-Wheeler)
                    const Text(
                      AppStrings.vehicleType,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),

                    _buildVehicleOption('2-Wheeler (Motorcycle / Scooter)', 'Motorcycle, Scooter, E-Bike', Icons.two_wheeler),
                    const SizedBox(height: 8),
                    _buildVehicleOption('3-Wheeler (Auto Rickshaw / TukTuk)', 'Auto Rickshaw, TukTuk, Cargo Trike', Icons.electric_rickshaw_rounded),
                    const SizedBox(height: 8),
                    _buildVehicleOption('4-Wheeler (Car / Van / Delivery Truck)', 'Car, Van, Delivery Truck', Icons.directions_car_rounded),

                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: plateCtrl,
                      label: AppStrings.vehiclePlate,
                      hintText: 'RD-8842-NY',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: modelCtrl,
                      label: AppStrings.vehicleModel,
                      hintText: 'Honda CB500X',
                      prefixIcon: Icons.minor_crash_outlined,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: colorCtrl,
                            label: 'Color',
                            hintText: 'Sapphire Blue',
                            prefixIcon: Icons.color_lens_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: yearCtrl,
                            label: 'Year',
                            hintText: '2023',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ],
                    ),
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
              child: CustomButton(
                text: 'Update Vehicle Details',
                icon: Icons.check,
                isLoading: controller.isLoading.value,
                onPressed: _saveVehicle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption(String typeValue, String subtitle, IconData icon) {
    final isSelected = selectedType.startsWith(typeValue.split(' ').first);

    return GestureDetector(
      onTap: () => setState(() => selectedType = typeValue),
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
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(typeValue, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(subtitle, style: AppTextStyles.bodySmall()),
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
