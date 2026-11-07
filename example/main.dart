// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_wechat/otel_wechat.dart';

/// Traces WeChat calls with OpenTelemetry.
///
/// `otel_wechat` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each WeChat call in
/// [tracedWechat]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'wechat-example');

  // Wraps a WeChat SDK call in a CLIENT span.
  final wechatId = await tracedWechat<String>(
    operation: 'create',
    invoke: () async {
      // Make the WeChat call here, then report what it returned.
      const id = 'wechat_8f3a2c';
      return const WechatCallResult(
          value: id,
          result: WechatResult(
              appId: 'app_8f3a2c',
              openId: 'open_8f3a2c',
              unionId: 'union_8f3a2c',
              platform: 'ios',
              scope: 'snsapi_userinfo',
              accessTokenLength: 128,
              refreshTokenLength: 128,
              expiresInSec: 1,
              shareScene: 'session',
              shareMessageType: 'text',
              payPartnerId: 'paypartner_8f3a2c',
              payPrepayId: 'payprepay_8f3a2c',
              payAmountCents: 1999,
              payResultCode: 1,
              miniProgramId: 'miniprogram_8f3a2c',
              miniProgramPath: '/v1/orders',
              miniProgramType: 'release',
              errorCode: 1,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedWechat create returned $wechatId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutWechatInstrumentationAsync.
  await runWithoutWechatInstrumentationAsync(
    () => tracedWechat<String>(
      operation: 'create',
      invoke: () async {
        const id = 'wechat_8f3a2c';
        return const WechatCallResult(
            value: id,
            result: WechatResult(
                appId: 'app_8f3a2c',
                openId: 'open_8f3a2c',
                unionId: 'union_8f3a2c',
                platform: 'ios',
                scope: 'snsapi_userinfo',
                accessTokenLength: 128,
                refreshTokenLength: 128,
                expiresInSec: 1,
                shareScene: 'session',
                shareMessageType: 'text',
                payPartnerId: 'paypartner_8f3a2c',
                payPrepayId: 'payprepay_8f3a2c',
                payAmountCents: 1999,
                payResultCode: 1,
                miniProgramId: 'miniprogram_8f3a2c',
                miniProgramPath: '/v1/orders',
                miniProgramType: 'release',
                errorCode: 1,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
