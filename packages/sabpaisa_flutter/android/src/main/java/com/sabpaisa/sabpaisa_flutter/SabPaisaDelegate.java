package com.sabpaisa.sabpaisa_flutter;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import io.github.sabpaisaandroid.interfaces.IPaymentSuccessCallBack;
import io.github.sabpaisaandroid.SabPaisaGateway;
import io.github.sabpaisaandroid.models.TransactionResponsesModel;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class SabPaisaDelegate implements ActivityResultListener, IPaymentSuccessCallBack<TransactionResponsesModel> {

    private final Activity activity;
    private Result pendingResult;
    private Map<String, Object> pendingReply;

    // Response codes for communicating with plugin
    private static final int CODE_PAYMENT_SUCCESS = 0;
    private static final int CODE_PAYMENT_ERROR = 1;

    // Payment error codes for communicating with plugin
    private static final int NETWORK_ERROR = 0;
    private static final int INVALID_OPTIONS = 1;
    private static final int PAYMENT_CANCELLED = 2;
    private static final int TLS_ERROR = 3;
    private static final int INCOMPATIBLE_PLUGIN = 3;
    private static final int UNKNOWN_ERROR = 100;
    private String packageName;

    Gson gson ;


    public SabPaisaDelegate(Activity activity) {
        this.activity = activity;
        this.gson = new Gson();
    }

    void setPackageName(String packageName){
        this.packageName = packageName;
    }

    void openCheckout(Map<String, Object> arguments, Result result) {

        this.pendingResult = result;

        JSONObject options = new JSONObject(arguments);
        SabPaisaModel model = (new Gson()).fromJson(options.toString(),SabPaisaModel.class);
        Log.d("sabpaisa",options.toString());


         SabPaisaGateway sabPaisaGateway1 =
             SabPaisaGateway.Companion.builder()
                        .setAmount(Double.valueOf(model.getAmount()))   
                        .setFirstName(model.getFirst_name()) 
                        .setLastName(model.getLast_name()) 
                        .setMobileNumber(model.getMobile_number()) 
                        .setEmailId(model.getEmail_id())
                        .setClientCode(model.getClient_code())
                        .setAesApiIv(model.getAes_iv())
                        .setAesApiKey(model.getAes_key())
                        .setTransUserName(model.getUser_name())
                        .setTransUserPassword(model.getPassword())
                        .setClientTransactionId(model.getTxn_id())
                        .setCallbackUrl(model.getCallback_url())
                        .setEnv(model.getEnv())
                     .setUdf1(model.getUdf1())
                     .setUdf2(model.getUdf2())
                     .setUdf3(model.getUdf3())
                     .setUdf4(model.getUdf4())
                     .setUdf5(model.getUdf5())
                     .setUdf6(model.getUdf6())
                     .setUdf7(model.getUdf7())
                     .setUdf8(model.getUdf8())
                     .setUdf9(model.getUdf9())
                     .setUdf10(model.getUdf10())
                     .setUdf11(model.getUdf11())
                     .setUdf12(model.getUdf12())
                     .setUdf13(model.getUdf13())
                     .setUdf14(model.getUdf14())
                     .setUdf15(model.getUdf15())
                     .setUdf16(model.getUdf16())
                     .setUdf17(model.getUdf17())
                     .setUdf18(model.getUdf18())
                     .setUdf19(model.getUdf19())
                     .setUdf20(model.getUdf20())
                     .build();
     sabPaisaGateway1.init(activity, this );



    }

    private void sendReply(Map<String, Object> data) {
        if (pendingResult != null) {
            pendingResult.success(data);
            pendingReply = null;
        } else {
            pendingReply = data;
        }
    }

    public void resync(Result result) {
        result.success(pendingReply);
        pendingReply = null;
    }




    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        // try{
        //     Method merchantActivityResult = Checkout.class.getMethod("merchantActivityResult", Activity.class, Integer.class, Integer.class, Intent.class, PaymentResultWithDataListener.class, ExternalWalletListener.class);
        //     merchantActivityResult.invoke(null,activity, requestCode, resultCode, data, this, this);
        // }catch (Exception e){
        //     Checkout.handleActivityResult(activity, requestCode, resultCode, data, this, this);
        // }
        return true;
    }



    @Override
    public void onPaymentSuccess(@Nullable TransactionResponsesModel o) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_SUCCESS);
        reply.put("data", (new Gson()).toJson(o));
        sendReply(reply);
    }

    @Override
    public void onPaymentFail(@Nullable TransactionResponsesModel o) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_ERROR);
        reply.put("data", (new Gson()).toJson(o));
        sendReply(reply);
    }
}
