// Kiểm tra hợp đồng API: gọi backend thật bằng các model của app và báo
// trường nào backend trả về mà model bỏ qua (có thể sai tên).
//
//   dart run tool/api_check.dart [baseUrl]
//
// Cần chạy `npm run seed:demo-users` trước (mật khẩu demo trong seedDemoUsers.js).
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gutacosmetic/features/auth/data/auth_models.dart';
import 'package:gutacosmetic/features/shared/models/models.dart';

const _demoPassword = 'Letien@0110';
const _ignoredKeys = {'__v', 'password', 'id'};

int _failures = 0;
int _checks = 0;
final _warnings = <String>{};

Future<void> main(List<String> args) async {
  final baseUrl = args.isNotEmpty ? args.first : 'http://localhost:5000/api';
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      validateStatus: (_) => true,
      headers: {'Accept': 'application/json'},
    ),
  );
  print('API: $baseUrl\n');

  // ---------- Auth ----------
  final tokens = <UserRole, AuthResult>{};
  for (final role in UserRole.values) {
    final res = await dio.post<Object?>(
      '/auth/login',
      data: {
        'identifier': '${role.name}.guta.demo@gmail.com',
        'password': _demoPassword,
      },
    );
    final result = _parse('POST /auth/login (${role.name})', res, (j) {
      final auth = AuthResult.fromJson(j);
      _diff('AppUser', j['user'], auth.user.toJson());
      return auth;
    });
    if (result != null) tokens[role] = result;
  }
  if (tokens.length < 4) {
    print('\n⚠ Thiếu tài khoản demo — chạy `npm run seed:demo-users`.');
  }

  Options auth(UserRole role, {String? storeId}) => Options(
    headers: {
      'Authorization': 'Bearer ${tokens[role]?.token}',
      'X-Active-Store-Id': ?storeId,
    },
  );

  Future<T?> get<T>(
    UserRole role,
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, Object?>? query,
    String? storeId,
  }) async {
    if (!tokens.containsKey(role)) return null;
    final res = await dio.get<Object?>(
      path,
      queryParameters: query,
      options: auth(role, storeId: storeId),
    );
    final q = query == null || query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    return _parse('GET $path$q (${role.name})', res, parse);
  }

  await get(UserRole.customer, '/auth/me', (j) {
    final u = AppUser.fromJson(j['user'] as Map<String, dynamic>);
    _diff('AppUser(/me)', j['user'], u.toJson());
    return u;
  });

  // ---------- Danh mục chung ----------
  final stores =
      await get(UserRole.customer, '/stores', (j) {
        return _list(j, 'stores', 'Store', Store.fromJson, (s) => s.toJson());
      }) ??
      const <Store>[];
  final branch = stores.where((s) => !s.isCentral).firstOrNull;
  print(
    '  → ${stores.length} cửa hàng, chi nhánh dùng để test: ${branch?.name}',
  );

  final products =
      await get(UserRole.customer, '/products', (j) {
        return _list(
          j,
          'products',
          'Product',
          Product.fromJson,
          (p) => p.toJson(),
        );
      }) ??
      const <Product>[];
  print('  → ${products.length} sản phẩm');

  if (products.isNotEmpty) {
    final id = products.first.id;
    await get(UserRole.customer, '/products/$id', (j) {
      final p = Product.fromJson(j['product'] as Map<String, dynamic>);
      _diff('Product(detail)', j['product'], p.toJson());
      return p;
    });
    await get(UserRole.customer, '/reviews', query: {'productId': id}, (j) {
      return _list(j, 'reviews', 'Review', Review.fromJson, (r) => r.toJson());
    });
  }
  await get(UserRole.customer, '/wishlist', (j) {
    return _list(
      j,
      'products',
      'Product(wishlist)',
      Product.fromJson,
      (p) => p.toJson(),
    );
  });
  await get(UserRole.customer, '/inventory/products', query: {'limit': 5}, (j) {
    return _list(
      j,
      'products',
      'ProductInventory',
      ProductInventory.fromJson,
      (p) => p.toJson(),
      nested: (raw, model) {
        final inv = (raw['inventories'] as List?)?.firstOrNull;
        if (inv is Map && model.inventories.isNotEmpty) {
          _diff('StoreStock', inv, model.inventories.first.toJson());
        }
      },
    );
  });
  await get(UserRole.customer, '/orders', (j) {
    return _orders(j);
  });

  // ---------- Sales / Manager (theo chi nhánh) ----------
  final sid = branch?.id;
  await get(
    UserRole.sales,
    '/orders',
    query: {'channel': 'OFFLINE'},
    storeId: sid,
    _orders,
  );
  await get(UserRole.sales, '/inventory/alerts', storeId: sid, (j) {
    return _list(
      j,
      'alerts',
      'InventoryAlert',
      InventoryAlert.fromJson,
      (a) => a.toJson(),
    );
  });
  await get(
    UserRole.sales,
    '/inventory/restock-requests',
    query: {'status': 'ALL'},
    storeId: sid,
    (j) => _list(
      j,
      'requests',
      'RestockRequest',
      RestockRequest.fromJson,
      (r) => r.toJson(),
    ),
  );
  await get(
    UserRole.sales,
    '/users/search',
    query: {'query': '09'},
    storeId: sid,
    (j) {
      return _list(
        j,
        'customers',
        'CustomerSearchResult',
        CustomerSearchResult.fromJson,
        (c) => c.toJson(),
      );
    },
  );
  await get(UserRole.manager, '/orders', storeId: sid, _orders);
  await get(UserRole.manager, '/inventory/receipts', storeId: sid, (j) {
    return _list(
      j,
      'receipts',
      'InventoryReceipt',
      InventoryReceipt.fromJson,
      (r) => r.toJson(),
    );
  });
  await get(UserRole.manager, '/inventory/adjustments', storeId: sid, (j) {
    return _list(
      j,
      'adjustments',
      'InventoryAdjustment',
      InventoryAdjustment.fromJson,
      (a) => a.toJson(),
    );
  });
  await get(UserRole.manager, '/inventory/transfers/incoming', storeId: sid, (
    j,
  ) {
    return _list(
      j,
      'transfers',
      'StockTransfer',
      StockTransfer.fromJson,
      (t) => t.toJson(),
    );
  });

  // ---------- Owner ----------
  await get(UserRole.owner, '/owner/analytics/revenue', (j) {
    final raw = j['analytics'] as Map<String, dynamic>;
    final a = RevenueAnalytics.fromJson(raw);
    _diff('RevenueSummary', raw['summary'], a.summary.toJson());
    final rawStore = (raw['stores'] as List?)?.firstOrNull;
    if (rawStore is Map && a.stores.isNotEmpty) {
      _diff('StoreRevenue', rawStore, a.stores.first.toJson());
    }
    print(
      '  → doanh thu đã thu: ${a.summary.paidRevenue}, ${a.stores.length} dòng cửa hàng',
    );
    return a;
  });
  await get(
    UserRole.owner,
    '/owner/products',
    query: {'includeInactive': true},
    (j) {
      return _list(
        j,
        'products',
        'Product(owner)',
        Product.fromJson,
        (p) => p.toJson(),
      );
    },
  );
  await get(UserRole.owner, '/owner/stores', query: {'includeInactive': true}, (
    j,
  ) {
    return _list(
      j,
      'stores',
      'Store(owner)',
      Store.fromJson,
      (s) => s.toJson(),
    );
  });
  await get(UserRole.owner, '/owner/staff', query: {'includeInactive': true}, (
    j,
  ) {
    return _list(
      j,
      'staff',
      'AppUser(staff)',
      AppUser.fromJson,
      (u) => u.toJson(),
    );
  });
  await get(UserRole.owner, '/owner/transfers', query: {'status': 'ALL'}, (j) {
    return _list(
      j,
      'transfers',
      'StockTransfer(owner)',
      StockTransfer.fromJson,
      (t) => t.toJson(),
    );
  });
  await get(UserRole.owner, '/inventory/alerts', (j) {
    return _list(
      j,
      'alerts',
      'InventoryAlert(owner)',
      InventoryAlert.fromJson,
      (a) => a.toJson(),
    );
  });

  print('\n================ KẾT QUẢ ================');
  print('$_checks endpoint đã gọi, $_failures lỗi.');
  if (_warnings.isNotEmpty) {
    print('\nTrường backend trả về nhưng model chưa đọc:');
    for (final w in _warnings.toList()..sort()) {
      print('  • $w');
    }
  }
  exit(_failures == 0 ? 0 : 1);
}

List<Order> _orders(Map<String, dynamic> j) => _list(
  j,
  'orders',
  'Order',
  Order.fromJson,
  (o) => o.toJson(),
  nested: (raw, model) {
    final item = (raw['items'] as List?)?.firstOrNull;
    if (item is Map && model.items.isNotEmpty) {
      _diff('OrderItem', item, model.items.first.toJson());
    }
  },
);

T? _parse<T>(
  String label,
  Response<Object?> res,
  T Function(Map<String, dynamic>) parse,
) {
  _checks++;
  final data = res.data;
  if ((res.statusCode ?? 0) >= 400 || data is! Map) {
    _failures++;
    final msg = data is Map
        ? '${data['code'] ?? ''} ${data['message']}'
        : '$data';
    print('✗ $label → HTTP ${res.statusCode}: $msg');
    return null;
  }
  try {
    final value = parse(Map<String, dynamic>.from(data));
    print('✓ $label');
    return value;
  } catch (e, st) {
    _failures++;
    print(
      '✗ $label → lỗi parse: $e\n${st.toString().split('\n').take(4).join('\n')}',
    );
    return null;
  }
}

List<T> _list<T>(
  Map<String, dynamic> json,
  String key,
  String modelName,
  T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> Function(T) toJson, {
  void Function(Map<dynamic, dynamic> raw, T model)? nested,
}) {
  final raw = json[key];
  if (raw is! List) {
    throw FormatException('thiếu mảng "$key"; keys=${json.keys}');
  }
  final result = <T>[];
  for (final item in raw.whereType<Map<dynamic, dynamic>>()) {
    final model = fromJson(Map<String, dynamic>.from(item));
    result.add(model);
    _diff(modelName, item, toJson(model));
    nested?.call(item, model);
  }
  return result;
}

void _diff(String model, Object? raw, Map<String, dynamic> parsed) {
  if (raw is! Map) return;
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    if (_ignoredKeys.contains(key) || entry.value == null) continue;
    if (!parsed.containsKey(key)) _warnings.add('$model.$key');
  }
}
