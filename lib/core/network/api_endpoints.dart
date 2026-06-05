class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String products = '/products';
  static const String sales = '/sales';

  static String productById(int id) => '/products/$id';

  static String productByBarcode(String barcode) =>
      '/products/barcode/$barcode';
}
