import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/merchant_provider.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  bool _loading = false;

  // Demo İstanbul koordinatları
  static const _pickupLatLng = LatLng(40.9849, 29.0270);
  static const _deliveryLatLng = LatLng(40.9901, 29.0218);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _weightCtrl.dispose();
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryGreen,
            onPrimary: AppTheme.darkNavy,
            surface: AppTheme.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Capture provider reference before async gap
    final provider = context.read<MerchantProvider>();

    Future.delayed(const Duration(milliseconds: 600), () {
      provider.addListing(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        weightKg: double.tryParse(_weightCtrl.text) ?? 1.0,
        pickupAddress: _pickupCtrl.text.trim(),
        deliveryAddress: _deliveryCtrl.text.trim(),
        pickupLocation: _pickupLatLng,
        deliveryLocation: _deliveryLatLng,
        timeStart: _fmt(_startTime),
        timeEnd: _fmt(_endTime),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.darkNavy),
                SizedBox(width: 8),
                Text('İlan başarıyla oluşturuldu!'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        title: const Text('Yeni İlan Oluştur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Paket Bilgileri'),
              const SizedBox(height: 12),
              _Field(
                controller: _titleCtrl,
                label: 'İlan Başlığı',
                hint: 'örn. Taze Ekmek Teslimatı',
                icon: Icons.title_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _descCtrl,
                label: 'Ürün Açıklaması',
                hint: 'İçerik, özel dikkat gereken durumlar...',
                icon: Icons.description_rounded,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Açıklama gerekli' : null,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _weightCtrl,
                label: 'Ağırlık (kg)',
                hint: 'örn. 2.5',
                icon: Icons.scale_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ağırlık gerekli';
                  if (double.tryParse(v) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _SectionLabel('Adresler'),
              const SizedBox(height: 12),
              _Field(
                controller: _pickupCtrl,
                label: 'Alış Adresi',
                hint: 'örn. Moda Cad. No:12, Kadıköy',
                icon: Icons.location_on_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Alış adresi gerekli' : null,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _deliveryCtrl,
                label: 'Teslimat Adresi',
                hint: 'örn. Bahariye Cad. No:45, Kadıköy',
                icon: Icons.flag_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Teslimat adresi gerekli' : null,
              ),
              const SizedBox(height: 24),
              _SectionLabel('Zaman Aralığı'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Başlangıç',
                      time: _fmt(_startTime),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: 'Bitiş',
                      time: _fmt(_endTime),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.darkNavy,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_loading ? 'Oluşturuluyor...' : 'İlan Oluştur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: AppTheme.accentOrange),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label, time;
  final VoidCallback onTap;
  const _TimePicker({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDarker,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
