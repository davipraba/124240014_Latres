import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductModel> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService().getProduct(widget.productId);
  }

  void _retry() {
    setState(() {
      _productFuture = ProductService().getProduct(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<ProductModel>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF58220)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat detail produk: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = snapshot.data!;
          return _buildDetails(context, product);
        },
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ProductModel product) {
    final provider = context.watch<ProductProvider>();
    final isWishlisted = provider.isWishlisted(product.id);
    final image = product.images.isNotEmpty
        ? product.images.first
        : product.thumbnail;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Image.network(
              image,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFFFF1E5),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFF58220),
                  size: 56,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          product.category.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFE56D0A),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF5A623)),
            const SizedBox(width: 5),
            Text(product.rating.toStringAsFixed(1)),
            const Spacer(),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFE56D0A),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Deskripsi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            await context.read<ProductProvider>().toggleWishlist(product);
          },
          icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border),
          label: Text(
            isWishlisted ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF58220),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
