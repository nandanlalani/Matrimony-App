import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../string_const.dart';
import '../backend/Database.dart';
import 'package:image_picker/image_picker.dart';

class AddProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? userId;

  AddProfileScreen({this.userData, this.userId});

  @override
  _AddProfileScreenState createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  bool isHide1 = true;
  bool isHide2 = true;
  File? _profileImage;
  bool success = false;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCity;
  String? _selectedGender;
  List<String> _selectedHobbies = [];
  List<String> _selectedUsername = [];

  final List<String> _hobbies = ['Reading', 'Traveling', 'Music', 'Sports', 'Dancing', 'Cooking'];
  final List<String> _cities = ['Ahmedabad', 'Anand', 'Jamnagar', 'Rajkot', 'Surat'];


  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _mobileError;
  String? _dobError;
  String? _passwordError;
  String? _conPasswordError;
  String? _userNameError;

  final List<DateFormat> _dateFormats = [
    DateFormat('yyyy/MM/dd'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('MM/dd/yyyy'),
  ];

  DateTime? _parseDateString(String dateStr) {
    for (var format in _dateFormats) {
      try {
        return format.parse(dateStr);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon, String? errorText) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pink),
      errorText: errorText,
      filled: true,
      fillColor: Colors.pink.shade100, // Light pink shade for a subtle background
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _firstNameController.text = widget.userData!["user_firstName"] ?? '';
      _lastNameController.text = widget.userData!["user_lastName"] ?? '';
      _emailController.text = widget.userData!["user_email"] ?? '';
      _mobileController.text = widget.userData!["user_number"] ?? '';
      _dobController.text = widget.userData!["dob"] ?? '';
      _selectedCity = widget.userData!["city"];
      _selectedGender = widget.userData!["gender"];
      _passwordController.text = widget.userData!["password"];
      _userNameController.text = widget.userData!["user_Name"];
      _selectedHobbies = List<String>.from(widget.userData!["hobbies"] ?? []);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _validateFirstName(String value) {
    setState(() {
      _firstNameError = RegExp(r"^[a-zA-Z]{3,50}$").hasMatch(value) ? null : "must contain alphabets only and 3-50 characters";
    });
  }
  void _validateLastName(String value) {
    setState(() {
      _lastNameError = RegExp(r"^[a-zA-Z]{3,50}$").hasMatch(value) ? null : "must contain alphabets only and 3-50 characters";
    });
  }
  void _validateEmail(String value) {
    setState(() {
      _emailError = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)
          ? null
          : "Enter a valid email address";
    });
  }
  void _validateUserName(String value) async {
    // Local validation for format
    if (!RegExp(r"^[a-zA-Z0-9]{3,50}$").hasMatch(value)) {
      setState(() {
        _userNameError = "Username must contain alphabets and digits only (3-50 characters)";
      });
      return; // Stop further checks
    }
    _userNameError = null;

    // Get old username (if editing an existing profile)
    String? oldUsername = widget.userData?["user_Name"];

    // If the username is the same as the old one, no need to check for duplicates
    if (oldUsername != null && value == oldUsername) {
      setState(() {
        _userNameError = null;
      });
      return;
    }

    final ApiService apiService = ApiService();
    bool usernameExists = await apiService.isUsernameExists(context,value);
    if (usernameExists) {
      print("Username already exists!");
    } else {
      print("Username is available.");
    }

    if (widget.userId == null || widget.userData!["user_Name"] != value) {
      bool usernameExists = await _apiService.isUsernameExists(context,value);
      if (usernameExists) {
        _showAlert("Username already exists. Please choose another one.");
        return;
      }
    }
  }

  void _validateMobile(String value) {
    setState(() {
      _mobileError = RegExp(r"^\d{10}$").hasMatch(value) ? null : "Enter a valid 10-digit mobile number";
    });
  }

  void _validatePassword(String value){
    setState(() {
      _passwordError = "";
      if(value == null){
        _passwordError = "Please enter password";
      }
      else if(!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^A-Za-z0-9]).{6,}$').hasMatch(value)){
        _passwordError = "Must contain atleast one Uppercase,Lowercase,special character,digit and min 6 characters";
      }
      else {
        _passwordError = null;
      }
    });
  }

  void _validateconPassword(String value){
    setState(() {
      _conPasswordError = "";
      if(value == null){
        _conPasswordError = "Please enter password";
      }
      else if(!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^A-Za-z0-9]).{6,}$').hasMatch(value)){
        _conPasswordError = "Must contain atleast one Uppercase,Lowercase,special character,digit and min 6 characters";
      }
      else if(value.toString() != _passwordController.text){
        _conPasswordError = "Password and Confirm Password Does Not Match";
        _passwordError = "Password and Confirm Password Does Not Match";
      }
      else {
        _conPasswordError = null;
        _passwordError = null;
      }
    });
  }

  void _validateDOB() {
    setState(() {
      if (_dobController.text.isNotEmpty) {
        DateTime? dob = _parseDateString(_dobController.text);

        if (dob != null) {
          DateTime now = DateTime.now();
          int age = now.year - dob.year;
          if (dob.month > now.month || (dob.month == now.month && dob.day > now.day)) {
            age--;
          }
          _dobError = (age >= 18 && age <= 80)
              ? null
              : "You must be at least 18 years old to register";

          // Update the date format to be consistent
          _dobController.text = DateFormat('dd/MM/yyyy').format(dob);
        } else {
          _dobError = "Invalid date format";
        }
      } else {
        _dobError = "Date of Birth is required";
      }
    });
  }

  void _resetForm(){
    _firstNameController.text = "";
    _lastNameController.text = "";
    _userNameController.text = "";
    _emailController.text = "";
    _passwordController.text = "";
    _conPasswordController.text = "";
    _mobileController.text = "";
    _dobController.text = "";
    _selectedCity = null;
    _selectedGender = null;
    _selectedHobbies = [];
    setState(() {

    });
  }

  Future<void> _submitForm() async {
    try {
      // Perform validations
      _validateFirstName(_firstNameController.text);
      _validateLastName(_lastNameController.text);
      _validateEmail(_emailController.text);
      _validateMobile(_mobileController.text);
      _validateUserName(_userNameController.text);
      _validatePassword(_passwordController.text);
      _validateconPassword(_conPasswordController.text);

      print("Validation errors: $_firstNameError, $_lastNameError, $_emailError, $_mobileError, $_passwordError, $_conPasswordError, $_dobError");

      if(_conPasswordController.text != _passwordController.text){
        setState(() {
          _conPasswordError = "Password and Confirm Password Does Not Match";
          _passwordError = "Password and Confirm Password Does Not Match";
        });
        return; // Exit early if passwords don't match
      }

      if (_firstNameError == null &&
          _lastNameError == null &&
          _userNameError == null &&
          _emailError == null &&
          _mobileError == null &&
          _passwordError == null &&
          _dobError == null &&
          _userNameError == null &&
          _conPasswordError == null) {

        if (_selectedCity == null || _selectedGender == null || _selectedHobbies.isEmpty) {
          _showAlert("Please complete all selections.");
          return;
        }

        print("Validation passed. Saving to database...");

        Map<String, dynamic> user = {
          "user_firstName": _firstNameController.text,
          "user_lastName": _lastNameController.text,
          "user_email": _emailController.text,
          "user_number": _mobileController.text,
          "dob": _dobController.text,
          "city": _selectedCity,
          "gender": _selectedGender,
          "password": _passwordController.text,
          "user_Name": _userNameController.text,
          "hobbies": _selectedHobbies,
          "profile_image": _profileImage?.path ?? "",
        };

        bool success = false;
        if (widget.userId != null) {
          print("Updating user with ID: ${widget.userId} and Data: $user");
          success = await _apiService.updateUser(context, widget.userId!, user);
        } else {
          print("Adding new user with Data: $user");
          success = await _apiService.addUser(context, user);
        }

        // Check if operation was successful
        if (success) {
          print("User saved successfully!");

          if (mounted) {
            // First show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.userId != null ? 'User updated successfully!' : 'User added successfully!'),
                duration: Duration(seconds: 1),
                // Shorter duration
              ),
            );

            // Then pop immediately - don't wait for the snackbar

            Navigator.pop(context,true);
            Navigator.pop(context,true);
          }
        } else {
          print("Failed to save user!");
          _showAlert("Failed to save user. Please try again.");
        }
      } else {
        print("Form validation failed - not submitting");
        _showAlert("Please fix the errors in the form before submitting.");
      }
    } catch (e) {
      print("Exception during form submission: $e");
      _showAlert("An error occurred: $e");
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userId != null ? 'Edit Profile' : 'Register',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.pink.shade300,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.pink.shade100,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : AssetImage('assets/images/default_profile.png') as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Form Sections
                  _buildSectionTitle("Personal Information"),
                  SizedBox(height: 16),

                  // First Name field with improved styling
                  _buildFormField(
                    title: "First Name",
                    controller: _firstNameController,
                    icon: Icons.person,
                    errorText: _firstNameError,
                    inputType: TextInputType.name,
                    formatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))],
                    capitalization: TextCapitalization.sentences,
                    onChanged: _validateFirstName,
                  ),

                  // Last Name field
                  _buildFormField(
                    title: "Last Name",
                    controller: _lastNameController,
                    icon: Icons.person,
                    errorText: _lastNameError,
                    inputType: TextInputType.name,
                    formatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))],
                    capitalization: TextCapitalization.sentences,
                    onChanged: _validateLastName,
                  ),

                  SizedBox(height: 24),
                  _buildSectionTitle("Account Information"),
                  SizedBox(height: 16),

                  // Username field
                  _buildFormField(
                    title: "Username",
                    controller: _userNameController,
                    icon: Icons.alternate_email,
                    errorText: _userNameError,
                    inputType: TextInputType.name,
                    formatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]"))],
                    onChanged: (value) {
                      // Call username validation
                      // _validateUserName(value);
                    },
                  ),

                  // Email field
                  _buildFormField(
                    title: "Email Address",
                    controller: _emailController,
                    icon: Icons.email,
                    errorText: _emailError,
                    inputType: TextInputType.emailAddress,
                    onChanged: _validateEmail,
                  ),

                  // Password field
                  _buildPasswordField(
                    title: "Password",
                    controller: _passwordController,
                    isHidden: isHide1,
                    errorText: _passwordError,
                    onToggleVisibility: () {
                      setState(() {
                        if(widget.userData == null || widget.userData!["user_id"] == null)
                          isHide1 = !isHide1;
                        else{
                          _showAlert("Cannot see password, enter confirm password to update details");
                        }
                      });
                    },
                    onChanged: _validatePassword,
                  ),

                  // Confirm Password field
                  _buildPasswordField(
                    title: "Confirm Password",
                    controller: _conPasswordController,
                    isHidden: isHide2,
                    errorText: _conPasswordError,
                    onToggleVisibility: () {
                      setState(() {
                        isHide2 = !isHide2;
                      });
                    },
                    onChanged: _validateconPassword,
                  ),

                  SizedBox(height: 24),
                  _buildSectionTitle("Additional Details"),
                  SizedBox(height: 16),

                  // Mobile Number field
                  _buildFormField(
                    title: "Mobile Number",
                    controller: _mobileController,
                    icon: Icons.phone_android,
                    errorText: _mobileError,
                    inputType: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    onChanged: _validateMobile,
                  ),

                  // Date of Birth field
                  _buildDatePickerField(),

                  // City dropdown
                  _buildImprovedDropdownField(),

                  // Gender selection
                  _buildImprovedGenderSelection(),

                  // Hobbies selection
                  _buildImprovedHobbiesSelection(),

                  SizedBox(height: 30),
                  _buildActionButtons(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create consistent section titles
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.pink, width: 3),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.pink.shade700,
        ),
      ),
    );
  }

  // Form field with consistent styling
  Widget _buildFormField({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    String? errorText,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.none,
    int? maxLength,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(icon, color: Colors.pink),
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.pink, width: 2),
              ),
              hintText: "Enter your $title",
              counterText: "",
            ),
            keyboardType: inputType,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            maxLength: maxLength,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Password field with visibility toggle
  Widget _buildPasswordField({
    required String title,
    required TextEditingController controller,
    required bool isHidden,
    String? errorText,
    required Function() onToggleVisibility,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: isHidden,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.lock, color: Colors.pink),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility : Icons.visibility_off,
                  color: Colors.pink,
                ),
                onPressed: onToggleVisibility,
              ),
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.pink, width: 2),
              ),
              hintText: "Enter your $title",
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Date picker field with improved styling
  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
            child: Text(
              "Date of Birth",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.calendar_today, color: Colors.pink),
              errorText: _dobError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.pink, width: 2),
              ),
              hintText: "Select your date of birth",
            ),
            onTap: () async {
              // Close keyboard to avoid issues
              FocusScope.of(context).requestFocus(FocusNode());

              // Default date for picker
              DateTime initialDate = DateTime.now().subtract(Duration(days: 18 * 365));

              // If there's already a date selected, use that as the initial date
              if (_dobController.text.isNotEmpty) {
                try {
                  initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
                } catch (e) {
                  initialDate = DateTime.now().subtract(Duration(days: 18 * 365));
                }
              }

              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime.now().subtract(Duration(days: 80 * 365)), // Max age: 80 years
                lastDate: DateTime.now().subtract(Duration(days: 18 * 365)), // Min age: 18 years
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.pink,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                setState(() {
                  _dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  _dobError = null; // Clear errors
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Improved dropdown for city selection
  Widget _buildImprovedDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
            child: Text(
              "City",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                prefixIcon: Icon(Icons.location_city, color: Colors.pink),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.pink),
              value: _selectedCity,
              items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
              onChanged: (value) => setState(() => _selectedCity = value),
              validator: (value) => value == null ? 'Please select a city' : null,
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  // Improved gender selection with visual elements
  Widget _buildImprovedGenderSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 12.0),
            child: Text(
              "Gender",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = "Male"),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedGender == "Male" ? Colors.pink.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _selectedGender == "Male" ? Colors.pink : Colors.grey.shade300,
                        width: _selectedGender == "Male" ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male,
                          color: _selectedGender == "Male" ? Colors.pink : Colors.grey,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Male",
                          style: TextStyle(
                            color: _selectedGender == "Male" ? Colors.pink : Colors.grey.shade700,
                            fontWeight: _selectedGender == "Male" ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = "Female"),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedGender == "Female" ? Colors.pink.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _selectedGender == "Female" ? Colors.pink : Colors.grey.shade300,
                        width: _selectedGender == "Female" ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.female,
                          color: _selectedGender == "Female" ? Colors.pink : Colors.grey,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Female",
                          style: TextStyle(
                            color: _selectedGender == "Female" ? Colors.pink : Colors.grey.shade700,
                            fontWeight: _selectedGender == "Female" ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Improved hobbies selection with visual chips
  Widget _buildImprovedHobbiesSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 12.0),
            child: Text(
              "Hobbies",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _hobbies.map((hobby) {
                    bool isSelected = _selectedHobbies.contains(hobby);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedHobbies.remove(hobby);
                          } else {
                            _selectedHobbies.add(hobby);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.pink.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.pink : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isSelected
                                ? Icon(Icons.check_circle, size: 16, color: Colors.pink)
                                : Icon(Icons.circle_outlined, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text(
                              hobby,
                              style: TextStyle(
                                color: isSelected ? Colors.pink : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action buttons for form submission
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pink.shade700,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.pink.shade300),
              ),
              elevation: 0,
            ),
            child: Text(
              "Reset",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            child: Text(
              widget.userId != null ? "Update" : "Register",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}