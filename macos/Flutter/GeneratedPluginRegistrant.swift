//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import device_info_plus
import path_provider_foundation
import screen_retriever_macos
import shared_preferences_foundation
import videosdk
import videosdk_webrtc
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  VideosdkPlugin.register(with: registry.registrar(forPlugin: "VideosdkPlugin"))
  FlutterWebRTCPlugin.register(with: registry.registrar(forPlugin: "FlutterWebRTCPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
