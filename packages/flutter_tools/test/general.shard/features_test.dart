// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_tools/src/base/config.dart';
import 'package:flutter_tools/src/features.dart';
import 'package:flutter_tools/src/base/platform.dart';
import 'package:flutter_tools/src/version.dart';
import 'package:mockito/mockito.dart';

import '../src/common.dart';
import '../src/testbed.dart';

void main() {
  group('Features', () {
    MockFlutterVerion mockFlutterVerion;
    MockFlutterConfig mockFlutterConfig;
    MockPlatform mockPlatform;
    Testbed testbed;

    setUp(() {
      mockFlutterVerion = MockFlutterVerion();
      mockFlutterConfig = MockFlutterConfig();
      mockPlatform = MockPlatform();
      when<bool>(mockFlutterConfig.getValue(any)).thenReturn(false);
      when(mockPlatform.environment).thenReturn(const <String, String>{});
      testbed = Testbed(overrides: <Type, Generator>{
        FlutterVersion: () => mockFlutterVerion,
        FeatureFlags: () => const FeatureFlags(),
        Config: () => mockFlutterConfig,
        Platform: () => mockPlatform,
      });
    });

    test('setting has safe defaults', () {
      const FeatureChannelSetting featureSetting = FeatureChannelSetting();

      expect(featureSetting.available, false);
      expect(featureSetting.enabledByDefault, false);
    });

    test('has safe defaults', () {
      const Feature feature = Feature(name: 'example');

      expect(feature.name, 'example');
      expect(feature.environmentOverride, null);
      expect(feature.configSetting, null);
    });

    test('retrieves the correct setting for each branch', () {
      final FeatureChannelSetting masterSetting = FeatureChannelSetting(available: nonconst(true));
      final FeatureChannelSetting devSetting = FeatureChannelSetting(available: nonconst(true));
      final FeatureChannelSetting betaSetting = FeatureChannelSetting(available: nonconst(true));
      final FeatureChannelSetting stableSetting = FeatureChannelSetting(available: nonconst(true));
      final Feature feature = Feature(
        name: 'example',
        master: masterSetting,
        dev: devSetting,
        beta: betaSetting,
        stable: stableSetting,
      );

      expect(feature.getSettingForChannel('master'), masterSetting);
      expect(feature.getSettingForChannel('dev'), devSetting);
      expect(feature.getSettingForChannel('beta'), betaSetting);
      expect(feature.getSettingForChannel('stable'), stableSetting);
      expect(feature.getSettingForChannel('unknown'), masterSetting);
    });

    test('env variables are only enabled with "true" string', () => testbed.run(() {
      when(mockPlatform.environment).thenReturn(<String, String>{'FLUTTER_WEB': 'hello'});

      expect(featureFlags.isWebEnabled, false);

      when(mockPlatform.environment).thenReturn(<String, String>{'FLUTTER_WEB': 'true'});

      expect(featureFlags.isWebEnabled, true);
    }));

    test('flutter web help string', () {
      expect(flutterWebFeature.generateHelpMessage(), 'Enable or disable Flutter Web on master, dev channels.');
    });

    test('flutter macOS desktop help string', () {
      expect(flutterMacOSDesktopFeature.generateHelpMessage(), 'Enable or disable Flutter Desktop for macOS on the master channel.');
    });

    test('flutter Linux desktop help string', () {
      expect(flutterLinuxDesktopFeature.generateHelpMessage(), 'Enable or disable Flutter Desktop for Linux on the master channel.');
    });

    test('flutter Windows desktop help string', () {
      expect(flutterWindowsDesktopFeature.generateHelpMessage(), 'Enable or disable Flutter Desktop for Windows on the master channel.');
    });

    /// Flutter Web

    test('flutter web off by default on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web enabled with config on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when<bool>(mockFlutterConfig.getValue('enable-web')).thenReturn(true);

      expect(featureFlags.isWebEnabled, true);
    }));

    test('flutter web enabled with environment variable on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when(mockPlatform.environment).thenReturn(<String, String>{'FLUTTER_WEB': 'true'});

      expect(featureFlags.isWebEnabled, true);
    }));

    test('flutter web off by default on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web enabled with config on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when<bool>(mockFlutterConfig.getValue('enable-web')).thenReturn(true);

      expect(featureFlags.isWebEnabled, true);
    }));

    test('flutter web enabled with environment variable on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when(mockPlatform.environment).thenReturn(<String, String>{'FLUTTER_WEB': 'true'});

      expect(featureFlags.isWebEnabled, true);
    }));

    test('flutter web off by default on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web not enabled with config on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when<bool>(mockFlutterConfig.getValue('enable-web')).thenReturn(true);

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web not enabled with environment variable on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when(mockPlatform.environment).thenReturn(<String, String>{'FLUTTER_WEB': 'true'});

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web off by default on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web not enabled with config on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when<bool>(mockFlutterConfig.getValue('enable-web')).thenReturn(true);

      expect(featureFlags.isWebEnabled, false);
    }));

    test('flutter web not enabled with environment variable on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when(mockPlatform.environment).thenReturn(<String, String>{'FLUTTER_WEB': 'enabled'});

      expect(featureFlags.isWebEnabled, false);
    }));

    /// Flutter macOS desktop.

    test('flutter macos desktop off by default on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop enabled with config on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when<bool>(mockFlutterConfig.getValue('enable-macos-desktop')).thenReturn(true);

      expect(featureFlags.isMacOSEnabled, true);
    }));

    test('flutter macos desktop enabled with environment variable on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isMacOSEnabled, true);
    }));

    test('flutter macos desktop off by default on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop not enabled with config on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when<bool>(mockFlutterConfig.getValue('flutter-desktop-macos')).thenReturn(true);

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop not enabled with environment variable on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop off by default on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('fflutter macos desktop not enabled with config on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when<bool>(mockFlutterConfig.getValue('flutter-desktop-macos')).thenReturn(true);

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop not enabled with environment variable on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop off by default on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop not enabled with config on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when<bool>(mockFlutterConfig.getValue('flutter-desktop-macos')).thenReturn(true);

      expect(featureFlags.isMacOSEnabled, false);
    }));

    test('flutter macos desktop not enabled with environment variable on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isMacOSEnabled, false);
    }));

    /// Flutter Linux Desktop
    test('flutter linux desktop off by default on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop enabled with config on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when<bool>(mockFlutterConfig.getValue('enable-linux-desktop')).thenReturn(true);

      expect(featureFlags.isLinuxEnabled, true);
    }));

    test('flutter linux desktop enabled with environment variable on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isLinuxEnabled, true);
    }));

    test('flutter linux desktop off by default on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop not enabled with config on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when<bool>(mockFlutterConfig.getValue('enable-linux-desktop')).thenReturn(true);

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop not enabled with environment variable on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop off by default on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('fflutter linux desktop not enabled with config on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when<bool>(mockFlutterConfig.getValue('enable-linux-desktop')).thenReturn(true);

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop not enabled with environment variable on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop off by default on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop not enabled with config on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when<bool>(mockFlutterConfig.getValue('enable-linux-desktop')).thenReturn(true);

      expect(featureFlags.isLinuxEnabled, false);
    }));

    test('flutter linux desktop not enabled with environment variable on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isLinuxEnabled, false);
    }));

    /// Flutter Windows desktop.
    test('flutter windows desktop off by default on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop enabled with config on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when<bool>(mockFlutterConfig.getValue('enable-windows-desktop')).thenReturn(true);

      expect(featureFlags.isWindowsEnabled, true);
    }));

    test('flutter windows desktop enabled with environment variable on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isWindowsEnabled, true);
    }));

    test('flutter windows desktop off by default on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop not enabled with config on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when<bool>(mockFlutterConfig.getValue('enable-windows-desktop')).thenReturn(true);

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop not enabled with environment variable on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop off by default on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('fflutter windows desktop not enabled with config on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when<bool>(mockFlutterConfig.getValue('enable-windows-desktop')).thenReturn(true);

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop not enabled with environment variable on beta', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('beta');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop off by default on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop not enabled with config on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when<bool>(mockFlutterConfig.getValue('enable-windows-desktop')).thenReturn(true);

      expect(featureFlags.isWindowsEnabled, false);
    }));

    test('flutter windows desktop not enabled with environment variable on stable', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('stable');
      when(mockPlatform.environment).thenReturn(<String, String>{'ENABLE_FLUTTER_DESKTOP': 'true'});

      expect(featureFlags.isWindowsEnabled, false);
    }));

    /// Plugins as AARS
    test('plugins built as AARs with config on master', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('master');
      when<bool>(mockFlutterConfig.getValue('enable-build-plugin-as-aar')).thenReturn(true);

      expect(featureFlags.isPluginAsAarEnabled, true);
    }));

    test('plugins built as AARs with config on dev', () => testbed.run(() {
      when(mockFlutterVerion.channel).thenReturn('dev');
      when<bool>(mockFlutterConfig.getValue('enable-build-plugin-as-aar')).thenReturn(true);

      expect(featureFlags.isPluginAsAarEnabled, true);
    }));
  });
}

class MockFlutterVerion extends Mock implements FlutterVersion {}
class MockFlutterConfig extends Mock implements Config {}
class MockPlatform extends Mock implements Platform {}

T nonconst<T>(T item) => item;
