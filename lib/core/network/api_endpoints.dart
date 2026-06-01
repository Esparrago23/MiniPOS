class ApiEndpoints {
  static const String baseUrl = 'http://98.85.68.58:8000';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String products = '/products';

  static String productById(int id) => '/products/$id';

  static String productByBarcode(String barcode) =>
      '/products/barcode/$barcode';
}
