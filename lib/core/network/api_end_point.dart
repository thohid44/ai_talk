class ApiEndPoint {
  static const String baseUrl = 'https://peanut.ifxdb.com';
  static const String clientApiBaseUrl = 'https://client-api.instaforex.com';
  static const String partnerApiBaseUrl =
      'https://client-api.contentdatapro.com';

  static const String isAccountCredentialsCorrect =
      '/api/ClientCabinetBasic/IsAccountCredentialsCorrect';
  static const String getAccountInformation =
      '/api/ClientCabinetBasic/GetAccountInformation';
  static const String getLastFourNumbersPhone =
      '/api/ClientCabinetBasic/GetLastFourNumbersPhone';

  static const String requestMobileCabinetApiToken =
      '/api/Authentication/RequestMobileCabinetApiToken';

  static String analyticSignals(int login) =>
      '/clientmobile/GetAnalyticSignals/$login';

  static const String cabinetMicroServiceUrl =
      'https://api-forexcopy.contentdatapro.com/Services/CabinetMicroService.svc';
  static const String getCcPromoAction =
      'http://tempuri.org/CabinetMicroService/GetCCPromo';
}
