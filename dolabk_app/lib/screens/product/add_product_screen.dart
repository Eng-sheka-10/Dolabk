// lib/screens/product/add_product_screen.dart
import 'package:dolabk_app/models/create_product_dto.dart';
import 'package:dolabk_app/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/di/service_locator.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = getIt<ProductService>();
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _rentPriceController = TextEditingController();

  String _selectedType = 'Sale';
  String? _selectedCategory;
  String? _selectedCondition;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _rentPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _productService.getCategories();
      if (response.success && response.data != null) {
        setState(() {
          _categories = List<String>.from(response.data!);
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        if (_selectedImages.length + images.length <= 10) {
          setState(() {
            _selectedImages.addAll(images);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only add up to 10 images')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _publishProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _productService.createProductWithImages(
        CreateProductDto(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: _selectedType == 'Sale'
              ? double.parse(_priceController.text)
              : 0,
          rentPricePerDay: _selectedType == 'Rent'
              ? double.parse(_rentPriceController.text)
              : null,
          type: ProductType.values.firstWhere((e) => e.name == _selectedType),
          condition: ProductCondition.values.firstWhere(
            (e) => e.name == _selectedCondition,
          ),
          category: _selectedCategory ?? '',
        ),
        _selectedImages.map((img) => img.path).toList(),
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product published successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to publish product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: _isLoading
          ? const LoadingIndicator(message: 'Publishing product...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    const Text(
                      'Product Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Image Button
                          InkWell(
                            onTap: _pickImages,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.mediumGray),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_selectedImages.length}/10',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Selected Images
                          ..._selectedImages.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(entry.value.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () => _removeImage(entry.key),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Name
                    CustomTextField(
                      label: 'Product Name',
                      hint: 'Enter product name',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      label: 'Description',
                      hint: 'Enter product description',
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Product Type
                    const Text(
                      'Product Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Sale', 'Rent', 'Exchange'].map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedType = type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Price fields based on type
                    if (_selectedType == 'Sale')
                      CustomTextField(
                        label: 'Price',
                        hint: 'Enter price',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    if (_selectedType == 'Rent')
                      CustomTextField(
                        label: 'Price Per Day',
                        hint: 'Enter rental price per day',
                        controller: _rentPriceController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rental price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        hintText: 'Select category',
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Condition
                    const Text(
                      'Condition',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['New', 'Like New', 'Good', 'Fair', 'Poor'].map(
                        (condition) {
                          return ChoiceChip(
                            label: Text(condition),
                            selected: _selectedCondition == condition,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCondition = condition);
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Publish Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomButton(
                        text: 'Publish Product',
                        onPressed: _publishProduct,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
