// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_wechat_suppression.dart';

const _tracerName = 'dartastic_otel_libs_wechat';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class WechatResult {
  /// Creates a result.
  const WechatResult({
    this.appId,
    this.openId,
    this.unionId,
    this.platform,
    this.scope,
    this.accessTokenLength,
    this.refreshTokenLength,
    this.expiresInSec,
    this.shareScene,
    this.shareMessageType,
    this.payPartnerId,
    this.payPrepayId,
    this.payAmountCents,
    this.payResultCode,
    this.miniProgramId,
    this.miniProgramPath,
    this.miniProgramType,
    this.errorCode,
    this.statusCode,
  });

  /// WeChat Open Platform app id.
  final String? appId;

  /// Per-app stable user id.
  final String? openId;

  /// Cross-app stable user id (requires WeChat Open Platform binding).
  final String? unionId;

  /// `ios`, `android`.
  final String? platform;

  /// `snsapi_userinfo`, `snsapi_login`, etc.
  final String? scope;

  final int? accessTokenLength;
  final int? refreshTokenLength;
  final int? expiresInSec;

  /// `session` (chat), `timeline` (moments), `favorite`.
  final String? shareScene;

  /// `text`, `image`, `audio`, `video`, `webpage`, `miniProgram`,
  /// `emoji`, `file`.
  final String? shareMessageType;

  final String? payPartnerId;
  final String? payPrepayId;

  /// Total cents on WeChat Pay (RMB minor units).
  final int? payAmountCents;

  /// `0` success, `-1` general error, `-2` cancelled.
  final int? payResultCode;

  /// Mini Program id launched / shared.
  final String? miniProgramId;
  final String? miniProgramPath;

  /// `release` / `test` / `preview`.
  final String? miniProgramType;

  /// WeChat error code: `0` ok, `-1` common, `-2` user_cancel,
  /// `-3` send_failed, `-4` auth_denied, `-5` unsupported.
  final int? errorCode;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class WechatCallResult<T> {
  /// Creates a call result.
  const WechatCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final WechatResult? result;
}

/// Wraps a WeChat SDK call in a CLIENT span. [operation] is one of
/// `auth`, `sendAuthRequest`, `payRequest`, `shareToSession`,
/// `shareToTimeline`, `shareToFavorite`, `launchMiniProgram`,
/// `subscribeMessage`, `openCustomerServiceChat`, `openBusinessView`,
/// `isInstalled`, `openWeChat`, `openWXApp`.
Future<T> tracedWechat<T>({
  required String operation,
  required Future<WechatCallResult<T>> Function() invoke,
}) async {
  if (wechatInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'wechat',
    'rpc.method': operation,
    'wechat.operation': operation,
  };

  final span = _tracer().startSpan(
    'wechat $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.appId != null) {
        extras.add(OTelAPI.attributeString('wechat.app.id', res.appId!));
      }
      if (res.openId != null) {
        extras.add(OTelAPI.attributeString('wechat.open_id', res.openId!));
      }
      if (res.unionId != null) {
        extras.add(OTelAPI.attributeString('wechat.union_id', res.unionId!));
      }
      if (res.platform != null) {
        extras.add(OTelAPI.attributeString('wechat.platform', res.platform!));
      }
      if (res.scope != null) {
        extras.add(OTelAPI.attributeString('wechat.scope', res.scope!));
      }
      if (res.accessTokenLength != null) {
        extras.add(OTelAPI.attributeInt(
          'wechat.access_token.length',
          res.accessTokenLength!,
        ));
      }
      if (res.refreshTokenLength != null) {
        extras.add(OTelAPI.attributeInt(
          'wechat.refresh_token.length',
          res.refreshTokenLength!,
        ));
      }
      if (res.expiresInSec != null) {
        extras.add(OTelAPI.attributeInt(
          'wechat.expires_in_sec',
          res.expiresInSec!,
        ));
      }
      if (res.shareScene != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.share.scene',
          res.shareScene!,
        ));
      }
      if (res.shareMessageType != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.share.message_type',
          res.shareMessageType!,
        ));
      }
      if (res.payPartnerId != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.pay.partner_id',
          res.payPartnerId!,
        ));
      }
      if (res.payPrepayId != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.pay.prepay_id',
          res.payPrepayId!,
        ));
      }
      if (res.payAmountCents != null) {
        extras.add(OTelAPI.attributeInt(
          'wechat.pay.amount_cents',
          res.payAmountCents!,
        ));
      }
      if (res.payResultCode != null) {
        extras.add(OTelAPI.attributeInt(
          'wechat.pay.result_code',
          res.payResultCode!,
        ));
        if (res.payResultCode == -1) {
          span.setStatus(SpanStatusCode.Error, 'WeChat Pay error');
        }
      }
      if (res.miniProgramId != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.miniprogram.id',
          res.miniProgramId!,
        ));
      }
      if (res.miniProgramPath != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.miniprogram.path',
          res.miniProgramPath!,
        ));
      }
      if (res.miniProgramType != null) {
        extras.add(OTelAPI.attributeString(
          'wechat.miniprogram.type',
          res.miniProgramType!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeInt(
          'wechat.error.code',
          res.errorCode!,
        ));
        if (res.errorCode != 0 && res.errorCode != -2 && res.errorCode != -4) {
          span.setStatus(
            SpanStatusCode.Error,
            'WeChat error ${res.errorCode}',
          );
        }
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'WeChat HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
