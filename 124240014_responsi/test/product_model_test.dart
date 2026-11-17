import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_responsi/models/product_model.dart';

void main() {
  test('ProductModel parses DummyJSON product fields', () {
    final product = ProductModel.fromJson({
      'id': 1,
      'title': 'Phone',
      'description': 'A test product',
      'price': 99.5,
      'rating': 4.7,
      'category': 'smartphones',
      'thumbnail': 'https://example.com/phone.jpg',
      'images': ['https://example.com/phone.jpg'],
    });

    expect(product.id, 1);
    expect(product.title, 'Phone');
    expect(product.price, 99.5);
    expect(product.rating, 4.7);
    expect(product.category, 'smartphones');
    expect(product.images, ['https://example.com/phone.jpg']);
  });
}
