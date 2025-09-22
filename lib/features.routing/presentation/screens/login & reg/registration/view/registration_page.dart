import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/mock/mock_auth_service.dart';
import 'package:flutter_valhalla/core/utils/hone_mask.dart';
import 'package:flutter_valhalla/core/utils/user_role_extension.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/view/home_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_event.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../widgets/foreman_fields.dart';
import '../widgets/supplier_fields.dart';
import '../widgets/courier_fields.dart';

enum RegistrationRole { customer, foreman, supplier, courier }


class RegistrationPage extends StatefulWidget {
  final RegistrationRole? initialRole;
  const RegistrationPage({super.key, this.initialRole});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

    final _iinMaskFormatter = MaskTextInputFormatter(
    mask: '############', // 12 цифр подряд
    filter: {"#": RegExp(r'[0-9]')},
  );
  final Map<String, TextEditingController> _controllers = {
    'phone': TextEditingController(),
    'smsCode': TextEditingController(),
    'city': TextEditingController(),
    'name': TextEditingController(),
    'password': TextEditingController(),
    'passwordRepeat': TextEditingController(),
    'iin': TextEditingController(),
    'experience': TextEditingController(),
    'objectsCount': TextEditingController(),
    'jobCost': TextEditingController(),
    'carMake': TextEditingController(),
    'licensePlate': TextEditingController(),
    'carColor': TextEditingController(),
  };

  late RegistrationRole _selectedRole;
  late bool _isAddRoleMode;

  String? _photoPath;
  String? _idPhotoPath;
  List<String> _workPhotosPaths = [];
  bool _isSafeDealWorker = false;
  bool _isConditionsAccepted = false;
  String? _courierBodyType;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? RegistrationRole.customer;
    _isAddRoleMode = widget.initialRole != null;

    final auth = MockAuthService();
    final user = auth.currentUser;

    if (_isAddRoleMode && user != null) {
      if (auth.hasRole(_getUserRole().toRegistrationRole())) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomePage(userRole: _getUserRole()),
            ),
          );
        });
      }
      

      // подставляем данные из уже зарегистрированного юзера
      _controllers['phone']!.text = user['phone'] ?? '';
      _controllers['city']!.text = user['city'] ?? '';
      _controllers['name']!.text = user['name'] ?? '';
      _controllers['iin']!.text = user['iin'] ?? '';
    }
    
  }
  

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  UserRole _getUserRole() {
    switch (_selectedRole) {
      case RegistrationRole.customer:
        return UserRole.customer;
      case RegistrationRole.foreman:
        return UserRole.foreman;
      case RegistrationRole.supplier:
        return UserRole.supplier;
      case RegistrationRole.courier:
        return UserRole.courier;
    }
  }

  Future<void> _pickImage({bool isIdPhoto = false, bool allowMultiple = false}) async {
    final picker = ImagePicker();
    if (allowMultiple) {
      final files = await picker.pickMultiImage();
      if (files.isNotEmpty) {
        setState(() {
          _workPhotosPaths.addAll(files.map((e) => e.path));
        });
      }
    } else {
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          if (isIdPhoto) {
            _idPhotoPath = file.path;
          } else {
            _photoPath = file.path;
          }
        });
      }
    }
  }

  void _sendSmsCode() {
    if (_controllers['phone']!.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Код отправлен на ${_controllers['phone']!.text}')),
      );
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    final rawPhone = phoneMaskFormatter.getUnmaskedText(); // 7771234567
    final normalizedPhone = '+7$rawPhone'; // +77771234567


    final baseData = {
      'phone': normalizedPhone,
      'sms_code': _controllers['smsCode']!.text,
      'city': _controllers['city']!.text,
      'name': _controllers['name']!.text,
      'password': _controllers['password']!.text,
      'iin': _controllers['iin']!.text,
      'photo': _photoPath,
      'role': _getUserRole().name,
    };

    switch (_selectedRole) {
      case RegistrationRole.customer:
        context.read<AuthBloc>().add(AuthRegisterCustomerEvent(baseData));
        break;

      case RegistrationRole.foreman:
        if (!_isConditionsAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Согласитесь с условиями')),
          );
          return;
        }
        final data = {
          ...baseData,
          'experience': _controllers['experience']!.text,
          'objects_count': _controllers['objectsCount']!.text,
          'job_cost': _controllers['jobCost']!.text,
          'is_safe_deal_worker': _isSafeDealWorker,
          'photo_id': _idPhotoPath,
          'photos_work': _workPhotosPaths,
        };
        context.read<AuthBloc>().add(AuthRegisterForemanEvent(data));
        break;

      case RegistrationRole.supplier:
        final data = {
          ...baseData,
          'experience': _controllers['experience']!.text,
          'objects_count': _controllers['objectsCount']!.text,
          'photo_id': _idPhotoPath,
          'photos_work': _workPhotosPaths,
        };
        context.read<AuthBloc>().add(AuthRegisterSupplierEvent(data));
        break;

      case RegistrationRole.courier:
        final data = {
          ...baseData,
          'car_make': _controllers['carMake']!.text,
          'license_plate': _controllers['licensePlate']!.text,
          'car_color': _controllers['carColor']!.text,
          'body_type': _courierBodyType,
        };
        context.read<AuthBloc>().add(AuthRegisterCourierEvent(data));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Выберите роль',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildRoleSelectionSection(),
              const SizedBox(height: 24),

              // 🔹 Базовые поля показываем ТОЛЬКО если это не addRoleMode
              if (!_isAddRoleMode) ...[
                CustomTextField(
                  controller: _controllers['name']!,
                  label: 'Имя',
                  icon: Icons.person,
                ),
                CustomTextField(
                  controller: _controllers['iin']!,
                  label: 'ИИН',
                  icon: Icons.badge,
                  keyboard: TextInputType.number,
                  formatters: [_iinMaskFormatter],
                  validator: (v) {
                    if (v == null || v.length != 12) return 'ИИН должен содержать 12 цифр';
                    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Только цифры';
                    return null;
                  },
                ),

                 CustomTextField(
                  controller: _controllers['phone']!,
                  label: 'Номер телефона',
                  hint: '+7 (___) ___-__-__',
                  keyboard: TextInputType.phone,
                  formatters: [phoneMaskFormatter], // ✅ добавил маску
                  validator: (value) => value == null || value.isEmpty ? 'Введите ваш телефон' : null,
                ),
                ElevatedButton(
                  onPressed: _sendSmsCode,
                  child: const Text('Отправить СМС'),
                ),
                CustomTextField(
                  controller: _controllers['smsCode']!,
                  label: 'Код из СМС',
                  icon: Icons.sms,
                  keyboard: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.length < 4 || v.length > 6) return 'Некорректный код';
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _controllers['city']!,
                  label: 'Город',
                  icon: Icons.location_city,
                ),
                CustomTextField(
                  controller: _controllers['password']!,
                  label: 'Пароль',
                  icon: Icons.lock,
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Минимум 6 символов';
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _controllers['passwordRepeat']!,
                  label: 'Повторите пароль',
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) {
                    if (v != _controllers['password']!.text) return 'Пароли не совпадают';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // 🔹 динамические поля по роли
              _buildDynamicFields(),

              const SizedBox(height: 32),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    // регистрация успешна, переходим на HomePage
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => HomePage(userRole: _getUserRole())),
                      (route) => false,
                    );
                  } else if (state is AuthError) {
                    // ошибка регистрации
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else if (state is AuthRegistrationPendingModeration) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ваш профиль отправлен на модерацию')),
                    );
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isAddRoleMode ? 'Добавить роль' : 'Зарегистрироваться'),
                    );
                  },
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionSection() {
    final roles = {
      RegistrationRole.customer: 'Заказчик',
      RegistrationRole.foreman: 'Бригадир',
      RegistrationRole.supplier: 'Поставщик',
      RegistrationRole.courier: 'Курьер',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: PopupMenuButton<RegistrationRole>(
            position: PopupMenuPosition.under,
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            initialValue: _selectedRole, // 🔹 сразу выбран initialRole
            onSelected: (role) => setState(() => _selectedRole = role),
            itemBuilder: (context) => roles.entries
                .map(
                  (e) => PopupMenuItem(
                    value: e.key,
                    child: Text(
                      e.value,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
                .toList(),
            child: ListTile(
              leading: Icon(Icons.work_outline, color: Theme.of(context).primaryColor),
              title: Text(
                roles[_selectedRole]!,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicFields() {
    switch (_selectedRole) {
      case RegistrationRole.foreman:
        return ForemanFields(
          experience: _controllers['experience']!,
          objectsCount: _controllers['objectsCount']!,
          jobCost: _controllers['jobCost']!,
          idPhotoPath: _idPhotoPath,
          workPhotosPaths: _workPhotosPaths,
          isSafeDealWorker: _isSafeDealWorker,
          isConditionsAccepted: _isConditionsAccepted,
          onSafeDealChanged: (v) => setState(() => _isSafeDealWorker = v ?? false),
          onConditionsChanged: (v) => setState(() => _isConditionsAccepted = v ?? false),
          onPickIdPhoto: () => _pickImage(isIdPhoto: true),
          onPickWorkPhotos: () => _pickImage(allowMultiple: true),
          buildPhotoUploadButton: _buildPhotoUploadButton,
          buildMultiPhotoUploadButton: _buildMultiPhotoUploadButton,
        );

      case RegistrationRole.supplier:
        return SupplierFields(
          experience: _controllers['experience']!,
          objectsCount: _controllers['objectsCount']!,
          idPhotoPath: _idPhotoPath,
          workPhotosPaths: _workPhotosPaths,
          isSafeDealWorker: _isSafeDealWorker,
          isConditionsAccepted: _isConditionsAccepted,
          onSafeDealChanged: (v) => setState(() => _isSafeDealWorker = v ?? false),
          onConditionsChanged: (v) => setState(() => _isConditionsAccepted = v ?? false),
          onPickIdPhoto: () => _pickImage(isIdPhoto: true),
          onPickWorkPhotos: () => _pickImage(allowMultiple: true),
          buildPhotoUploadButton: _buildPhotoUploadButton,
          buildMultiPhotoUploadButton: _buildMultiPhotoUploadButton,
        );

      case RegistrationRole.courier:
        return CourierFields(
          carMake: _controllers['carMake']!,
          licensePlate: _controllers['licensePlate']!,
          carColor: _controllers['carColor']!,
          courierBodyType: _courierBodyType,
          onBodyTypeSelected: (v) => setState(() => _courierBodyType = v),
          isSafeDealWorker: _isSafeDealWorker,
          isConditionsAccepted: _isConditionsAccepted,
          onSafeDealChanged: (v) => setState(() => _isSafeDealWorker = v ?? false),
          onConditionsChanged: (v) => setState(() => _isConditionsAccepted = v ?? false),
        );

      case RegistrationRole.customer:

        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotoUploadButton(
    String label,
    VoidCallback onPressed,
    String? fileName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.upload),
          label: Text(fileName == null ? 'Загрузить' : 'Загрузить другое'),
        ),
        if (fileName != null)
          Text(
            'Выбрано: ${fileName.split('/').last}',
            style: const TextStyle(color: Colors.green),
          ),
      ],
    );
  }

  Widget _buildMultiPhotoUploadButton(
    String label,
    VoidCallback onPressed,
    List<String> fileNames,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.upload),
          label: const Text('Загрузить фото'),
        ),
        if (fileNames.isNotEmpty)
          ...fileNames.map(
            (e) => Text(
              e.split('/').last,
              style: const TextStyle(color: Colors.green),
            ), 
          ),
      ],
    );
  }

  
}
