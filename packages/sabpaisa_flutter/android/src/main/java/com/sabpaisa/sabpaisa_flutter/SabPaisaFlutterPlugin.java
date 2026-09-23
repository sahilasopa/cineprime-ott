package com.sabpaisa.sabpaisa_flutter;

import androidx.annotation.NonNull;

import org.json.JSONException;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SabPaisaFlutterPlugin
 */
public class SabPaisaFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private SabPaisaDelegate SabPaisaDelegate;
    private ActivityPluginBinding pluginBinding;
    private static String CHANNEL_NAME = "sabpaisa_flutter";
    Map<String, Object> _arguments;
    String customerMobile ;
    String color;
    private MethodChannel channel;

    public SabPaisaFlutterPlugin() {
    }


    /// v2 plugin registration
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public void onMethodCall(MethodCall call, Result result) {


        switch (call.method) {

            case "open":
                SabPaisaDelegate.openCheckout((Map<String, Object>) call.arguments, result);
                break;
            default:
                result.notImplemented();

        }

    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.SabPaisaDelegate = new SabPaisaDelegate(binding.getActivity());
        this.pluginBinding = binding;
        binding.addActivityResultListener(SabPaisaDelegate);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        pluginBinding.removeActivityResultListener(SabPaisaDelegate);
        pluginBinding = null;
    }
}