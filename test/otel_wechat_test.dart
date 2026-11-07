// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_wechat/otel_wechat.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_wechat-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('sendAuthRequest records app + open/union ids + scope', () async {
    await tracedWechat<String>(
      operation: 'sendAuthRequest',
      invoke: () async => const WechatCallResult(
        value: 'ok',
        result: WechatResult(
          appId: 'wx_app_1',
          openId: 'open_1',
          unionId: 'union_1',
          scope: 'snsapi_userinfo',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('wechat sendAuthRequest')!);
    expect(a['wechat.open_id'], 'open_1');
    expect(a['wechat.union_id'], 'union_1');
  });

  test('payRequest result_code -1 sets span error', () async {
    await tracedWechat<String>(
      operation: 'payRequest',
      invoke: () async => const WechatCallResult(
        value: 'ok',
        result: WechatResult(
          payPartnerId: 'mch_1',
          payPrepayId: 'prepay_abc',
          payAmountCents: 19900,
          payResultCode: -1,
        ),
      ),
    );
    expect(
      spans.findSpanByName('wechat payRequest')!.status,
      SpanStatusCode.Error,
    );
  });

  test('user_cancel (-2) does NOT set span error', () async {
    await tracedWechat<String>(
      operation: 'payRequest',
      invoke: () async => const WechatCallResult(
        value: 'ok',
        result: WechatResult(errorCode: -2),
      ),
    );
    expect(
      spans.findSpanByName('wechat payRequest')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutWechatInstrumentationAsync(() async {
      await tracedWechat<String>(
        operation: 'isInstalled',
        invoke: () async => const WechatCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('wechat '), isEmpty);
  });
}
