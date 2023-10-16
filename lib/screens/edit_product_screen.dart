import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';

  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isNotEmpty) {
        if ((!_imageUrlController.text.startsWith('http') &&
                !_imageUrlController.text.startsWith('https')) ||
            (!_imageUrlController.text.endsWith('.png') &&
                !_imageUrlController.text.endsWith('.jpg') &&
                !_imageUrlController.text.endsWith('jpeg'))) return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_editedProduct.id != '') {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error has occurred!'),
          content: const Text('Something went wrong!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refresh to see new product.'),
        duration: Duration(seconds: 5),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _editedProduct.title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _editedProduct = Product(
                        title: value as String,
                        id: _editedProduct.id,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a title!';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.price.toString() == '0.0'
                          ? null
                          : _editedProduct.price.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _editedProduct = Product(
                        title: _editedProduct.title,
                        id: _editedProduct.id,
                        price: double.parse(value as String),
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a price!';
                        if (double.tryParse(value) == null) {
                          return 'Please, enter a valid price!';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please, enter number greater than 0!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.description,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      textInputAction: TextInputAction.newline,
                      onSaved: (value) => _editedProduct = Product(
                        title: _editedProduct.title,
                        id: _editedProduct.id,
                        price: _editedProduct.price,
                        description: value as String,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description!';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long!';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text(
                                  'Enter an image URL',
                                  textAlign: TextAlign.center,
                                )
                              : FittedBox(
                                  child: FadeInImage(
                                    placeholder: const AssetImage(
                                        'lib/assets/images/product-placeholder.png'),
                                    image:
                                        NetworkImage(_imageUrlController.text),
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return const FadeInImage(
                                        placeholder: AssetImage(
                                            'lib/assets/images/product-placeholder.png'),
                                        image: AssetImage(
                                            'lib/assets/images/connection_error.jpg'),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            onSaved: (value) => _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: value as String,
                              isFavorite: _editedProduct.isFavorite,
                            ),
                            onFieldSubmitted: (_) {
                              setState(() {});
                              _saveForm();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an image URL!';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL!';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('jpeg')) {
                                return 'Please enter a valid image URL!';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
