import 'dart:async';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_cex_market_data/src/models/_models_index.dart';

/// Interface for fetching prices from Komodo API.
abstract class IKomodoPriceProvider {
  Future<Map<String, AssetMarketInformation>> getKomodoPrices();
}

/// A class for fetching prices from Komodo API.
class KomodoPriceProvider implements IKomodoPriceProvider {
  /// Creates a new instance of [KomodoPriceProvider].
  KomodoPriceProvider({
    this.mainTickersUrl =
        'https://defistats.gleec.com/api/v3/prices/tickers_v2?expire_at=600',
  });

  /// The URL to fetch the main tickers from.
  final String mainTickersUrl;

  /// Fetches prices from Komodo API.
  ///
  /// Returns a map of coin IDs to their prices.
  ///
  /// Throws an error if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final Map<String, AssetMarketInformation> prices =
  ///   await komodoPriceProvider.getKomodoPrices();
  /// ```
  @override
  Future<Map<String, AssetMarketInformation>> getKomodoPrices() async {
    final mainUri = Uri.parse(mainTickersUrl);

    final res = await http.get(mainUri);

    if (res.statusCode != 200) {
      throw Exception(
        'HTTP ${res.statusCode}: Failed to fetch prices from Komodo API',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>?;

    if (json == null) {
      throw Exception('Invalid response from Komodo API: empty JSON');
    }

    final prices = <String, AssetMarketInformation>{};
    json.forEach((String priceTicker, dynamic pricesData) {
      prices[priceTicker] = AssetMarketInformation.fromJson(
        pricesData as Map<String, dynamic>,
      ).copyWith(ticker: priceTicker);
    });
    // no CHTA in current komodo price json, fill in
    if (!prices.containsKey('CHTA')) {
      prices['CHTA'] = prices['KMD']!.copyWith(ticker: 'CHTA');
    }
    // obtain accurate prices on CHTA from nonKYC.io
    var CHTAResponse = await http.get(Uri.parse('https://api.nonkyc.io/api/v2/market/trades?symbol=CHTA_DOGE'));
    dynamic chtaNonkycData = jsonDecode(CHTAResponse.body);
    double CHTA_DOGE_price = double.parse(chtaNonkycData[0]['price'].toString());
    double CHTA_USD_price = CHTA_DOGE_price * prices['DOGE']!.lastPrice.toDouble();
    prices['CHTA'] = prices['CHTA']!.copyWith(lastPrice: Decimal.parse(CHTA_USD_price.toString()));
    return prices;
  }
}
