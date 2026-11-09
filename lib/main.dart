
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const green = Color(0xFF238B45);
const lightGreen = Color(0xFFEAF6EE);

// ---------------- PRODUCT MODEL ----------------

class Product {
  String id;
  String name;
  String category;
  int price;
  String unit;
  String image;
  String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.image,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'unit': unit,
    'image': image,
    'description': description,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    price: json['price'],
    unit: json['unit'],
    image: json['image'],
    description: json['description'],
  );
}

// ---------------- DEFAULT PRODUCTS ----------------

List<Product> defaultProducts() => [
  Product(
    id: '1', name: 'Apples', category: 'Fruits',
    price: 120, unit: '1 kg',
    image: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
    description: 'Fresh and juicy apples.',
  ),
  Product(
    id: '2', name: 'Bananas', category: 'Fruits',
    price: 50, unit: '1 dozen',
    image: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
    description: 'Naturally sweet bananas.',
  ),
  Product(
    id: '3', name: 'Tomatoes', category: 'Vegetables',
    price: 35, unit: '1 kg',
    image: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=500',
    description: 'Fresh red tomatoes.',
  ),
  Product(
    id: '4', name: 'Broccoli', category: 'Vegetables',
    price: 60, unit: '500 g',
    image: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=500',
    description: 'Fresh green broccoli.',
  ),
  Product(
    id: '5', name: 'Milk', category: 'Dairy',
    price: 30, unit: '500 ml',
    image: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500',
    description: 'Fresh dairy milk.',
  ),
  Product(
    id: '6', name: 'Bread', category: 'Bakery',
    price: 40, unit: '1 pack',
    image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500',
    description: 'Soft and fresh bread.',
  ),
];

// ---------------- APP STATE ----------------

class ShopState extends ChangeNotifier {
  List<Product> products = defaultProducts();
  Map<String, int> cart = {};
  Set<String> wishlist = {};
  List<Map<String, dynamic>> orders = [];

  Map<String, String> users = {};
  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';
  String currentEmail = '';
  String role = '';

  bool loaded = false;

  int get cartCount =>
      cart.values.fold(0, (sum, quantity) => sum + quantity);

  int get subtotal {
    int amount = 0;
    for (final p in products) {
      amount += p.price * (cart[p.id] ?? 0);
    }
    return amount;
  }

  int get delivery => cart.isEmpty ? 0 : 30;
  int get total => subtotal + delivery;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedProducts = prefs.getString('products');
    if (savedProducts != null) {
      products = (jsonDecode(savedProducts) as List)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final savedCart = prefs.getString('cart');
    if (savedCart != null) {
      cart = Map<String, int>.from(jsonDecode(savedCart));
    }

    wishlist = (prefs.getStringList('wishlist') ?? []).toSet();

    final savedOrders = prefs.getString('orders');
    if (savedOrders != null) {
      orders = List<Map<String, dynamic>>.from(
        (jsonDecode(savedOrders) as List)
            .map((e) => Map<String, dynamic>.from(e)),
      );
    }

    final savedUsers = prefs.getString('users');
    if (savedUsers != null) {
      users = Map<String, String>.from(jsonDecode(savedUsers));
    }

    loaded = true;
    notifyListeners();
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'products',
      jsonEncode(products.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(cart));
  }

  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist', wishlist.toList());
  }

  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orders', jsonEncode(orders));
  }

  Future<void> saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', jsonEncode(users));
  }

  Future<void> register(String name, String email, String password) async {
    users[email] = password;
    await saveUsers();
    customerName = name;
    currentEmail = email;
    role = 'customer';
    notifyListeners();
  }

  bool login(String email, String password) {
    if (email == 'admin@freshcart.com' && password == 'admin123') {
      currentEmail = email;
      role = 'admin';
      notifyListeners();
      return true;
    }

    if (users[email] == password) {
      currentEmail = email;
      role = 'customer';
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    currentEmail = '';
    role = '';
    notifyListeners();
  }

  void addToCart(Product p) {
    cart[p.id] = (cart[p.id] ?? 0) + 1;
    saveCart();
    notifyListeners();
  }

  void changeQuantity(Product p, int change) {
    final quantity = (cart[p.id] ?? 0) + change;
    if (quantity <= 0) {
      cart.remove(p.id);
    } else {
      cart[p.id] = quantity;
    }
    saveCart();
    notifyListeners();
  }

  void toggleFavorite(Product p) {
    if (wishlist.contains(p.id)) {
      wishlist.remove(p.id);
    } else {
      wishlist.add(p.id);
    }
    saveWishlist();
    notifyListeners();
  }

  int discount(String coupon) =>
      coupon.trim().toUpperCase() == 'FRESH10'
          ? (subtotal * 0.10).round()
          : 0;

  Future<void> placeOrder({
    required String name,
    required String phone,
    required String address,
    required String payment,
    required int discountAmount,
  }) async {
    orders.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'phone': phone,
      'address': address,
      'payment': payment,
      'discount': discountAmount,
      'total': total - discountAmount,
      'status': 'Order Placed',
      'items': Map<String, int>.from(cart),
    });

    customerName = name;
    customerPhone = phone;
    customerAddress = address;

    cart.clear();
    await saveCart();
    await saveOrders();
    notifyListeners();
  }

  Future<void> updateProfile(
    String name, String phone, String address,
  ) async {
    customerName = name;
    customerPhone = phone;
    customerAddress = address;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customerName', name);
    await prefs.setString('customerPhone', phone);
    await prefs.setString('customerAddress', address);
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    products.add(p);
    await saveProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(Product p) async {
    products.removeWhere((item) => item.id == p.id);
    cart.remove(p.id);
    wishlist.remove(p.id);
    await saveProducts();
    await saveCart();
    await saveWishlist();
    notifyListeners();
  }

  Future<void> updateOrderStatus(
    String orderId, String status,
  ) async {
    final index = orders.indexWhere((o) => o['id'] == orderId);
    if (index != -1) {
      orders[index]['status'] = status;
      await saveOrders();
      notifyListeners();
    }
  }
}

// ---------------- MAIN ----------------

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ShopState()..load(),
      child: const FreshCartApp(),
    ),
  );
}

class FreshCartApp extends StatelessWidget {
  const FreshCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshCart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
      ),
      home: Consumer<ShopState>(
        builder: (context, state, child) {
          if (!state.loaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.role == 'admin') return const AdminPage();
          if (state.role == 'customer') return const CustomerPage();
          return const LoginPage();
        },
      ),
    );
  }
}

// ---------------- LOGIN PAGE ----------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShopState>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const Icon(Icons.shopping_basket,
                        size: 65, color: green),
                    const SizedBox(height: 10),
                    const Text('FreshCart',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: green,
                        )),
                    const Text('Fresh groceries, delivered simply'),
                    const SizedBox(height: 28),
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: password,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                            () => hidePassword = !hidePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () {
                          final ok = state.login(
                            email.text.trim(),
                            password.text,
                          );
                          if (!ok) {
                            showMessage('Invalid email or password');
                          }
                        },
                        child: const Text('Login'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign up",
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Admin demo: admin@freshcart.com',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      'Password: admin123',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- SIGNUP PAGE ----------------

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShopState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const Icon(Icons.person_add_alt_1,
                    size: 65, color: green),
                const SizedBox(height: 20),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Enter your name'
                          : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                  .hasMatch(v.trim())
                          ? 'Enter a valid email'
                          : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6
                          ? 'Use at least 6 characters'
                          : null,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final userEmail = email.text.trim().toLowerCase();

                    if (userEmail == 'admin@freshcart.com' ||
                        state.users.containsKey(userEmail)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This email is already registered'),
                        ),
                      );
                      return;
                    }

                    await state.register(
                      name.text.trim(),
                      userEmail,
                      password.text,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- CUSTOMER NAVIGATION ----------------

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();

    final pages = [
      const HomePage(),
      const WishlistPage(),
      const CartPage(),
      const OrdersPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🛒 FreshCart',
          style: TextStyle(
            color: green,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => setState(() => selected = 2),
            icon: Badge(
              isLabelVisible: state.cartCount > 0,
              label: Text('${state.cartCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: selected, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => setState(() => selected = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined), label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border), label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined), label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined), label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ---------------- HOME PAGE ----------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String category = 'All';
  String search = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();
    final categories = [
      'All', 'Fruits', 'Vegetables', 'Dairy', 'Bakery',
    ];

    final filtered = state.products.where((p) {
      return (category == 'All' || p.category == category) &&
          p.name.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return LayoutBuilder(
      builder: (context, size) {
        final columns = size.maxWidth > 950
            ? 4
            : size.maxWidth > 600
                ? 3
                : 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [green, Color(0xFF62B879)],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fresh Deals, Every Day!',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: 8),
                        Text('Good food. Great prices. Delivered fresh.',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(height: 12),
                        Text('Shop your daily essentials now!',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: (v) => setState(() => search = v),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Shop by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  Wrap(
                    spacing: 8,
                    children: categories.map((c) {
                      return ChoiceChip(
                        label: Text(c),
                        selected: category == c,
                        onSelected: (_) => setState(() => category = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text('Popular Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const Center(child: Text('No products found'))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, i) =>
                          ProductCard(product: filtered[i]),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- PRODUCT CARD ----------------

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();
    final quantity = state.cart[product.id] ?? 0;
    final favorite = state.wishlist.contains(product.id);

    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    ),
                    child: ProductImage(url: product.image),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton.filledTonal(
                    onPressed: () => state.toggleFavorite(product),
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      color: favorite ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(product.unit,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text('₹${product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: () => state.addToCart(product),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (quantity > 0)
                  Text('Added: $quantity',
                      style: const TextStyle(color: green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  final String url;
  const ProductImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: lightGreen,
        child: const Center(
          child: Icon(Icons.shopping_basket, size: 48, color: green),
        ),
      ),
    );
  }
}

// ---------------- PRODUCT DETAILS ----------------

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShopState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ProductImage(url: product.image),
              ),
            ),
            const SizedBox(height: 18),
            Text(product.name,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            Text(product.unit),
            Text('₹${product.price}',
                style: const TextStyle(
                  color: green,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 10),
            Text(product.description),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  state.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- WISHLIST ----------------

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();
    final items = state.products
        .where((p) => state.wishlist.contains(p.id))
        .toList();

    if (items.isEmpty) {
      return const Center(child: Text('Your wishlist is empty'));
    }

    return ListView(
      padding: const EdgeInsets.all(15),
      children: items.map((p) => Card(
        color: Colors.white,
        child: ListTile(
          leading: SizedBox(width: 55, child: ProductImage(url: p.image)),
          title: Text(p.name),
          subtitle: Text('₹${p.price}'),
          trailing: IconButton(
            onPressed: () => state.toggleFavorite(p),
            icon: const Icon(Icons.favorite, color: Colors.red),
          ),
        ),
      )).toList(),
    );
  }
}

// ---------------- CART ----------------

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();
    final items = state.products
        .where((p) => (state.cart[p.id] ?? 0) > 0)
        .toList();

    if (items.isEmpty) {
      return const Center(child: Text('Your cart is empty'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('My Cart',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        ...items.map((p) => Card(
          color: Colors.white,
          child: ListTile(
            leading: SizedBox(width: 50, child: ProductImage(url: p.image)),
            title: Text(p.name),
            subtitle: Text('₹${p.price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => state.changeQuantity(p, -1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${state.cart[p.id]}'),
                IconButton(
                  onPressed: () => state.changeQuantity(p, 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 15),
        priceRow('Subtotal', state.subtotal),
        priceRow('Delivery', state.delivery),
        const Divider(),
        priceRow('Total', state.total, bold: true),
        const SizedBox(height: 15),
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckoutPage()),
          ),
          child: const Text('Proceed to Checkout'),
        ),
      ],
    );
  }
}

// ---------------- CHECKOUT ----------------

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final couponController = TextEditingController();

  String payment = 'Cash on Delivery';
  int discount = 0;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Delivery Information',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || !RegExp(r'^[0-9]{10}$').hasMatch(v)
                      ? 'Enter a 10-digit phone number'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().length < 5
                      ? 'Enter your address'
                      : null,
            ),
            const SizedBox(height: 20),
            const Text('Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...['Cash on Delivery', 'UPI (Demo)', 'Card (Demo)'].map(
              (method) => RadioListTile<String>(
                value: method,
                groupValue: payment,
                title: Text(method),
                onChanged: (v) => setState(() => payment = v!),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Coupon: FRESH10 gives 10% off'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      discount = state.discount(couponController.text);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(discount > 0
                            ? 'Coupon applied'
                            : 'Invalid coupon'),
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            priceRow('Subtotal', state.subtotal),
            priceRow('Delivery', state.delivery),
            priceRow('Discount', discount),
            const Divider(),
            priceRow('Final Total', state.total - discount, bold: true),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                await state.placeOrder(
                  name: name.text.trim(),
                  phone: phone.text.trim(),
                  address: address.text.trim(),
                  payment: payment,
                  discountAmount: discount,
                );

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderSuccessPage(),
                  ),
                  (route) => route.isFirst,
                );
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ORDER SUCCESS ----------------

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: green, size: 85),
            const SizedBox(height: 15),
            const Text('Order Placed Successfully!',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const CustomerPage()),
                (route) => false,
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ORDERS ----------------

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();

    if (state.orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('My Orders',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        ...state.orders.map((order) => Card(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.shopping_bag, color: green),
            title: Text('Order #${order['id']}'),
            subtitle: Text(
              '₹${order['total']} • ${order['status']}',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackingPage(order: order),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ---------------- ORDER TRACKING ----------------

class TrackingPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const TrackingPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'Order Placed',
      'Packed',
      'Out for Delivery',
      'Delivered',
    ];

    final current = statuses.indexOf(order['status']);

    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Order #${order['id']}',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ...List.generate(statuses.length, (i) => ListTile(
            leading: Icon(
              i <= current ? Icons.check_circle : Icons.circle_outlined,
              color: i <= current ? green : Colors.grey,
            ),
            title: Text(statuses[i]),
          )),
          const SizedBox(height: 15),
          Text('Total: ₹${order['total']}'),
          Text('Payment: ${order['payment']}'),
          Text('Address: ${order['address']}'),
        ],
      ),
    );
  }
}

// ---------------- PROFILE ----------------

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundColor: lightGreen,
          child: Icon(Icons.person, size: 50, color: green),
        ),
        const SizedBox(height: 15),
        Center(
          child: Text(
            state.customerName.isEmpty
                ? state.currentEmail
                : state.customerName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(child: Text(state.customerPhone)),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Profile'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Delivery Address'),
          subtitle: Text(state.customerAddress),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About FreshCart'),
          subtitle: const Text('Fresh groceries, delivered simply.'),
        ),
        const SizedBox(height: 15),
        FilledButton.tonal(
          onPressed: () => state.logout(),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

// ---------------- EDIT PROFILE ----------------

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController phone;
  late TextEditingController address;

  @override
  void initState() {
    super.initState();
    final s = context.read<ShopState>();
    name = TextEditingController(text: s.customerName);
    phone = TextEditingController(text: s.customerPhone);
    address = TextEditingController(text: s.customerAddress);
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShopState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            TextFormField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await state.updateProfile(
                  name.text.trim(),
                  phone.text.trim(),
                  address.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADMIN DASHBOARD ----------------

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshCart Admin'),
        actions: [
          IconButton(
            onPressed: () => state.logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Admin Dashboard',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: AdminStat(
                      title: 'Products',
                      value: '${state.products.length}',
                      icon: Icons.inventory_2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AdminStat(
                      title: 'Orders',
                      value: '${state.orders.length}',
                      icon: Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AdminStat(
                      title: 'Cart Items',
                      value: '${state.cartCount}',
                      icon: Icons.shopping_cart,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const AddProductDialog(),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...state.products.map((p) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    child: ProductImage(url: p.image),
                  ),
                  title: Text(p.name),
                  subtitle: Text('${p.category} • ₹${p.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete Product?'),
                        content: Text('Delete ${p.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              state.deleteProduct(p);
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 20),
              const Text('Manage Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              ...state.orders.map((order) => Card(
                color: Colors.white,
                child: ListTile(
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    '₹${order['total']} • ${order['status']}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => state.updateOrderStatus(
                      order['id'],
                      value,
                    ),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'Order Placed',
                        child: Text('Order Placed'),
                      ),
                      PopupMenuItem(
                        value: 'Packed',
                        child: Text('Packed'),
                      ),
                      PopupMenuItem(
                        value: 'Out for Delivery',
                        child: Text('Out for Delivery'),
                      ),
                      PopupMenuItem(
                        value: 'Delivered',
                        child: Text('Delivered'),
                      ),
                    ],
                    child: const Icon(Icons.edit_note),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AdminStat({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: green),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADD PRODUCT DIALOG ----------------

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final price = TextEditingController();
  final image = TextEditingController();
  final description = TextEditingController();
  String category = 'Fruits';
  String unit = '1 kg';

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    image.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShopState>();

    return AlertDialog(
      title: const Text('Add Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter product name' : null,
                ),
                TextFormField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price in ₹'),
                  validator: (v) =>
                      int.tryParse(v ?? '') == null ? 'Enter a valid price' : null,
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Fruits', 'Vegetables', 'Dairy', 'Bakery']
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => category = v!),
                ),
                TextFormField(
                  controller: image,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                  ),
                ),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            await state.addProduct(Product(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name.text.trim(),
              category: category,
              price: int.parse(price.text),
              unit: unit,
              image: image.text.trim().isEmpty
                  ? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500'
                  : image.text.trim(),
              description: description.text.trim().isEmpty
                  ? 'Fresh grocery product.'
                  : description.text.trim(),
            ));

            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ---------------- PRICE ROW ----------------

Widget priceRow(String label, int amount, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
        Text('₹$amount',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    ),
  );
}
