import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('UTXO activation merge parameters', () {
    test('parses and serializes utxo_merge_params', () {
      final params = UtxoActivationParams.fromJson({
        'electrum': [],
        'utxo_merge_params': {
          'merge_at': 50,
          'check_every': 1000,
          'max_merge_at_once': 40,
        },
      });

      final expectedMergeParams = {
        'merge_at': 50,
        'check_every': 1000,
        'max_merge_at_once': 40,
      };

      expect(params.toRpcParams()['utxo_merge_params'], expectedMergeParams);
      expect(
        params.copyWith(txHistory: true).toRpcParams()['utxo_merge_params'],
        expectedMergeParams,
      );
    });

    test('omits utxo_merge_params when not configured', () {
      final params = UtxoActivationParams.fromJson({'electrum': []});

      expect(params.toRpcParams().containsKey('utxo_merge_params'), isFalse);
    });
  });
}
