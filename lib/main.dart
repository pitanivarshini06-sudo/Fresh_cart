
import 'package:flutter/material.dart';

void main() {
  runApp(const FreshCartApp());
}

class FreshCartApp extends StatelessWidget {
  const FreshCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshCart',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF238B45),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;

  String searchText = '';

  final TextEditingController searchController =
      TextEditingController();

  final Map<String, int> cart = {};

  final List<String> categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Dairy',
    'Bakery',
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Fresh Apples',
      'category': 'Fruits',
      'price': 120,
      'unit': '1 kg',
      'emoji': '🍎',
      'color': const Color(0xFFFFE5E5),
    },
    {
      'name': 'Bananas',
      'category': 'Fruits',
      'price': 50,
      'unit': '1 dozen',
      'emoji': '🍌',
      'color': const Color(0xFFFFF2CC),
    },
    {
      'name': 'Tomatoes',
      'category': 'Vegetables',
      'price': 35,
      'unit': '1 kg',
      'emoji': '🍅',
      'color': const Color(0xFFFFE4DC),
    },
    {
      'name': 'Broccoli',
      'category': 'Vegetables',
      'price': 60,
      'unit': '500 g',
      'emoji': '🥦',
      'color': const Color(0xFFE1F3DF),
    },
    {
      'name': 'Milk',
      'category': 'Dairy',
      'price': 30,
      'unit': '500 ml',
      'emoji': '🥛',
      'color': const Color(0xFFE3F0FF),
    },
    {
      'name': 'Bread',
      'category': 'Bakery',
      'price': 40,
      'unit': '1 pack',
      'emoji': '🍞',
      'color': const Color(0xFFFFEBD5),
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategory == 0 ||
          product['category'] == categories[selectedCategory];

      final matchesSearch = product['name']
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      String name = product['name'];
      cart[name] = (cart[name] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          products: products,
          cart: cart,
          onIncrease: (name) {
            setState(() {
              cart[name] = (cart[name] ?? 0) + 1;
            });
          },
          onDecrease: (name) {
            setState(() {
              if ((cart[name] ?? 0) > 1) {
                cart[name] = cart[name]! - 1;
              } else {
                cart.remove(name);
              }
            });
          },
        ),
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FreshCart 🛒',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF238B45),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Fresh groceries, happy living!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE0F1E4),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF238B45),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search groceries...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF238B45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fresh Deals!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Get up to 30% OFF\non fresh groceries.',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '🛍️',
                          style: TextStyle(fontSize: 55),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        categories.length,
                        (index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(categories[index]),
                              selected: selectedCategory == index,
                              selectedColor:
                                  const Color(0xFF238B45),
                              labelStyle: TextStyle(
                                color: selectedCategory == index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Popular Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int columns = 2;

                      if (constraints.maxWidth >= 900) {
                        columns = 4;
                      } else if (constraints.maxWidth >= 550) {
                        columns = 3;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];

                          return ProductCard(
                            product: product,
                            onAdd: () => addToCart(product),
                          );
                        },
                      );
                    },
                  ),

                  if (filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text('No products found.'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            openCart();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This section is coming soon!'),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Reusable Product Card

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product['color'],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  product['emoji'],
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product['unit'],
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product['price']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF238B45),
                ),
              ),
              IconButton.filled(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF238B45),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Shopping Cart Screen

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, int> cart;
  final Function(String) onIncrease;
  final Function(String) onDecrease;

  const CartScreen({
    super.key,
    required this.products,
    required this.cart,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final cartProducts = products
        .where((product) => cart.containsKey(product['name']))
        .toList();

    int subtotal = 0;

    for (var product in cartProducts) {
      subtotal +=
          (product['price'] as int) * cart[product['name']]!;
    }

    final int deliveryFee = cartProducts.isEmpty ? 0 : 30;
    final int total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7F9F5),
      ),
      body: cartProducts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your cart is empty!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some fresh groceries to continue.',
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProducts.length,
                    itemBuilder: (context, index) {
                      final product = cartProducts[index];
                      final name = product['name'];
                      final quantity = cart[name]!;

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(
                                  color: product['color'],
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    product['emoji'],
                                    style: const TextStyle(
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '₹${product['price']}',
                                      style: const TextStyle(
                                        color: Color(0xFF238B45),
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    onDecrease(name),
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                ),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    onIncrease(name),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF238B45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('₹$subtotal'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee'),
                          Text('₹$deliveryFee'),
                        ],
                      ),
                      const Divider(height: 25),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '₹$total',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF238B45),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Checkout will be available soon!',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF238B45),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
