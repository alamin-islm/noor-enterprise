import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NoorEnterpriseApp());

const brandGreen = Color(0xFF147D48);

class Product {
  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.weight,
    required this.cartonSize,
    required this.stock,
    this.imagePath = '',
  });

  String id, name, code, weight, cartonSize, imagePath;
  double price;
  int stock;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'code': code, 'price': price,
    'weight': weight, 'cartonSize': cartonSize, 'stock': stock,
    'imagePath': imagePath,
  };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
    name: j['name'] ?? '',
    code: j['code'] ?? '',
    price: (j['price'] as num? ?? 0).toDouble(),
    weight: j['weight'] ?? '',
    cartonSize: j['cartonSize'] ?? '',
    stock: (j['stock'] as num? ?? 0).toInt(),
    imagePath: j['imagePath'] ?? '',
  );
}

class SalesOrder {
  SalesOrder({
    required this.id, required this.productName, required this.quantity,
    required this.unitPrice, required this.createdAt, required this.createdBy,
    this.status = 'Pending',
  });

  String id, productName, createdBy, status;
  int quantity;
  double unitPrice;
  String createdAt;
  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
    'id': id, 'productName': productName, 'quantity': quantity,
    'unitPrice': unitPrice, 'createdAt': createdAt, 'createdBy': createdBy,
    'status': status,
  };

  factory SalesOrder.fromJson(Map<String, dynamic> j) => SalesOrder(
    id: j['id'] ?? '',
    productName: j['productName'] ?? '',
    quantity: (j['quantity'] as num? ?? 0).toInt(),
    unitPrice: (j['unitPrice'] as num? ?? 0).toDouble(),
    createdAt: j['createdAt'] ?? '',
    createdBy: j['createdBy'] ?? '',
    status: j['status'] ?? 'Pending',
  );
}

class NoorEnterpriseApp extends StatelessWidget {
  const NoorEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Noor Enterprise',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: brandGreen),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandGreen, foregroundColor: Colors.white,
      ),
    ),
    home: const LoginScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'Dealer';
  String error = '';

  void login() {
    final id = idController.text.trim().toLowerCase();
    final pw = passwordController.text;
    final valid = role == 'Admin'
        ? id == 'admin' && pw == 'admin123'
        : id == 'dealer' && pw == 'dealer123';
    if (!valid) {
      setState(() => error = 'ডেমো লগইন তথ্য মিলছে না। নিচের তথ্য ব্যবহার করুন।');
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => HomeScreen(role: role, username: id),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 42, backgroundColor: brandGreen,
                  child: Icon(Icons.storefront, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 16),
                const Text('Noor Enterprise',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                const Text('Product Catalogue & Sales',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 28),
                DropdownButtonFormField<String>(
                  value: role, decoration: const InputDecoration(
                    labelText: 'ব্যবহারকারীর ধরন', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'Dealer', child: Text('Dealer / Employee')),
                  ],
                  onChanged: (v) => setState(() => role = v ?? 'Dealer'),
                ),
                const SizedBox(height: 12),
                TextField(controller: idController,
                  decoration: const InputDecoration(labelText: 'User ID',
                    border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 12),
                TextField(controller: passwordController, obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password',
                    border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  onSubmitted: (_) => login()),
                if (error.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 18),
                FilledButton(onPressed: login,
                  child: const Padding(
                    padding: EdgeInsets.all(12), child: Text('লগইন করুন'))),
                const SizedBox(height: 14),
                const Card(child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('ডেমো Admin: admin / admin123\nডেমো Dealer: dealer / dealer123',
                    textAlign: TextAlign.center))),
                const Text('শুধু পরীক্ষার জন্য। প্রকাশের আগে নিরাপদ লগইন যুক্ত করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.redAccent)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.role, required this.username});
  final String role, username;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  bool loading = true;
  List<Product> products = [];
  List<SalesOrder> orders = [];
  double monthlyTarget = 300000;
  final picker = ImagePicker();

  bool get isAdmin => widget.role == 'Admin';
  double get salesTotal => orders.where((o) => o.status != 'Cancelled')
      .fold(0, (s, o) => s + o.total);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProducts = prefs.getString('products_v1');
    final rawOrders = prefs.getString('orders_v1');
    if (rawProducts != null) {
      products = (jsonDecode(rawProducts) as List)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (rawOrders != null) {
      orders = (jsonDecode(rawOrders) as List)
          .map((e) => SalesOrder.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    monthlyTarget = prefs.getDouble('monthly_target_v1') ?? 300000;
    if (products.isEmpty) {
      products = [
        Product(id: 'demo1', name: 'Demo Snack Pack', code: 'NE-001',
          price: 25, weight: '20 gm', cartonSize: '100 pcs/carton', stock: 100),
        Product(id: 'demo2', name: 'Demo Juice', code: 'NE-002',
          price: 15, weight: '14 gm', cartonSize: '120 pcs/carton', stock: 80),
      ];
      await saveData();
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products_v1', jsonEncode(products.map((p) => p.toJson()).toList()));
    await prefs.setString('orders_v1', jsonEncode(orders.map((o) => o.toJson()).toList()));
    await prefs.setDouble('monthly_target_v1', monthlyTarget);
  }

  Future<String> saveImage(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/product_images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final target = '${imagesDir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    return (await File(file.path).copy(target)).path;
  }

  Future<void> addProduct() async {
    final name = TextEditingController();
    final code = TextEditingController();
    final price = TextEditingController();
    final weight = TextEditingController();
    final carton = TextEditingController();
    final stock = TextEditingController(text: '0');
    String imagePath = '';
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('নতুন পণ্য যোগ করুন'),
        content: SizedBox(width: 420, child: SingleChildScrollView(
          child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (imagePath.isNotEmpty && File(imagePath).existsSync())
              Image.file(File(imagePath), height: 100, fit: BoxFit.contain),
            OutlinedButton.icon(
              onPressed: () async {
                final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (f != null) {
                  imagePath = await saveImage(f);
                  setDialogState(() {});
                }
              },
              icon: const Icon(Icons.photo), label: const Text('পণ্যের ছবি নির্বাচন')),
            _field(name, 'পণ্যের নাম'),
            _field(code, 'পণ্য কোড'),
            _field(price, 'বিক্রয়মূল্য (৳)', number: true),
            _field(weight, 'সাইজ / ওজন'),
            _field(carton, 'কার্টন সাইজ'),
            _field(stock, 'প্রাথমিক স্টক', number: true),
          ]))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('বাতিল')),
          FilledButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            if (products.length >= 100) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('প্রথম সংস্করণে সর্বোচ্চ ১০০টি পণ্য রাখা যাবে।')));
              return;
            }
            products.add(Product(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: name.text.trim(), code: code.text.trim(),
              price: double.tryParse(price.text) ?? 0,
              weight: weight.text.trim(), cartonSize: carton.text.trim(),
              stock: int.tryParse(stock.text) ?? 0, imagePath: imagePath,
            ));
            await saveData();
            if (mounted) setState(() {});
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          }, child: const Text('সংরক্ষণ')),
        ],
      ),
    ));
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) =>
    Padding(padding: const EdgeInsets.only(top: 10), child: TextFormField(
      controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'এই ঘরটি পূরণ করুন' : null,
    ));

  Future<void> createOrder(Product p) async {
    final qty = TextEditingController(text: '1');
    final result = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: Text('অর্ডার: ${p.name}'),
      content: TextField(controller: qty, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'পরিমাণ', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
        FilledButton(onPressed: () {
          final q = int.tryParse(qty.text);
          if (q == null || q < 1) return;
          Navigator.pop(ctx, q);
        }, child: const Text('অর্ডার দিন')),
      ],
    ));
    if (result == null) return;
    if (result > p.stock) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('পর্যাপ্ত স্টক নেই।')));
      return;
    }
    p.stock -= result;
    orders.insert(0, SalesOrder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      productName: p.name, quantity: result, unitPrice: p.price,
      createdAt: DateTime.now().toIso8601String(),
      createdBy: widget.username, status: isAdmin ? 'Approved' : 'Pending',
    ));
    await saveData();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অর্ডার সংরক্ষণ হয়েছে (অফলাইনেও)।')));
    }
  }

  Future<void> changeStock(Product p) async {
    final c = TextEditingController();
    final delta = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: Text('স্টক পরিবর্তন: ${p.name}'),
      content: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: const InputDecoration(labelText: 'পরিমাণ (+ যোগ, - কমান)', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
        FilledButton(onPressed: () {
          final n = int.tryParse(c.text);
          if (n == null || p.stock + n < 0) return;
          Navigator.pop(ctx, n);
        }, child: const Text('আপডেট')),
      ],
    ));
    if (delta == null) return;
    p.stock += delta;
    await saveData();
    if (mounted) setState(() {});
  }

  Future<void> editTarget() async {
    final c = TextEditingController(text: monthlyTarget.toStringAsFixed(0));
    final value = await showDialog<double>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('মাসিক বিক্রির টার্গেট'),
      content: TextField(controller: c, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'টার্গেট (৳)', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
        FilledButton(onPressed: () {
          final n = double.tryParse(c.text);
          if (n == null || n < 0) return;
          Navigator.pop(ctx, n);
        }, child: const Text('সংরক্ষণ')),
      ],
    ));
    if (value == null) return;
    monthlyTarget = value;
    await saveData();
    if (mounted) setState(() {});
  }

  Widget productImage(Product p, {double size = 64}) {
    if (p.imagePath.isNotEmpty && File(p.imagePath).existsSync()) {
      return ClipRRect(borderRadius: BorderRadius.circular(8),
        child: Image.file(File(p.imagePath), width: size, height: size, fit: BoxFit.cover));
    }
    return Container(width: size, height: size,
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.inventory_2_outlined, color: brandGreen));
  }

  Widget productPage() => Column(children: [
    if (isAdmin) Padding(padding: const EdgeInsets.all(12),
      child: SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: addProduct, icon: const Icon(Icons.add), label: const Text('নতুন পণ্য যোগ করুন')))),
    Expanded(child: products.isEmpty
      ? const Center(child: Text('এখনও কোনো পণ্য নেই'))
      : ListView.builder(padding: const EdgeInsets.all(10), itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return Card(child: ListTile(
            leading: productImage(p),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${p.code} • ${p.weight}\n৳${p.price.toStringAsFixed(2)} • স্টক: ${p.stock}\n${p.cartonSize}',
              maxLines: 3),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'order') createOrder(p);
                if (v == 'stock' && isAdmin) changeStock(p);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'order', child: Text('অর্ডার করুন')),
                if (isAdmin) const PopupMenuItem(value: 'stock', child: Text('স্টক পরিবর্তন')),
              ],
            ),
            onTap: () => createOrder(p),
          ));
        })),
  ]);

  Widget ordersPage() => orders.isEmpty
    ? const Center(child: Text('এখনও কোনো অর্ডার নেই'))
    : ListView.builder(padding: const EdgeInsets.all(10), itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        return Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.shopping_bag_outlined)),
          title: Text(o.productName),
          subtitle: Text('${o.quantity} × ৳${o.unitPrice.toStringAsFixed(2)} = ৳${o.total.toStringAsFixed(2)}\n${o.createdBy} • ${o.status}'),
          isThreeLine: true,
          trailing: isAdmin && o.status == 'Pending'
            ? IconButton(tooltip: 'Approve', icon: const Icon(Icons.check_circle, color: brandGreen),
                onPressed: () async {
                  o.status = 'Approved'; await saveData(); if (mounted) setState(() {});
                })
            : null,
        ));
      });

  Widget reportsPage() {
    final approved = orders.where((o) => o.status == 'Approved').toList();
    final pending = orders.where((o) => o.status == 'Pending').toList();
    final approvedTotal = approved.fold<double>(0, (s, o) => s + o.total);
    final achievement = monthlyTarget == 0 ? 0.0 : (approvedTotal / monthlyTarget * 100).clamp(0, 1000);
    return ListView(padding: const EdgeInsets.all(16), children: [
      _metric('মোট পণ্য', '${products.length}/100', Icons.inventory_2),
      _metric('মোট অর্ডার', '${orders.length}', Icons.shopping_cart),
      _metric('অনুমোদিত বিক্রি', '৳${approvedTotal.toStringAsFixed(2)}', Icons.point_of_sale),
      _metric('অপেক্ষমাণ অর্ডার', '${pending.length}', Icons.pending_actions),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('মাসিক Target–Achievement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            if (isAdmin) IconButton(onPressed: editTarget, icon: const Icon(Icons.edit)),
          ]),
          Text('টার্গেট: ৳${monthlyTarget.toStringAsFixed(0)}'),
          Text('অনুমোদিত বিক্রি: ৳${approvedTotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: achievement / 100),
          const SizedBox(height: 6),
          Text('${achievement.toStringAsFixed(1)}% অর্জন'),
        ],
      ))),
      const Padding(padding: EdgeInsets.only(top: 8),
        child: Text('নোট: এই ডেমোতে অনুমোদিত অর্ডারের মোট মূল্যকে বিক্রি হিসেবে দেখানো হচ্ছে।',
          style: TextStyle(fontSize: 12, color: Colors.grey))),
    ]);
  }

  Widget _metric(String title, String value, IconData icon) => Card(
    child: ListTile(leading: CircleAvatar(backgroundColor: Colors.green.shade50,
      child: Icon(icon, color: brandGreen)), title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
  );

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final pages = [productPage(), ordersPage(), reportsPage()];
    final titles = ['Product Catalogue', 'Daily Orders', 'Reports & Target'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Noor Enterprise • ${titles[selected]}', style: const TextStyle(fontSize: 17)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text(widget.role, style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
      body: IndexedStack(index: selected, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => setState(() => selected = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
      drawer: null,
    );
  }
}
