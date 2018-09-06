package com.mapswithme.maps.purchase;

import android.app.Activity;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClient.BillingResponse;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.mapswithme.util.log.Logger;
import com.mapswithme.util.log.LoggerFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class PlayStoreBillingManager implements BillingManager<PlayStoreBillingCallback>,
                                                PurchasesUpdatedListener,
                                                PlayStoreBillingConnection.ConnectionListener
{
  final static Logger LOGGER = LoggerFactory.INSTANCE.getLogger(LoggerFactory.Type.MISC);
  final static String TAG = PlayStoreBillingManager.class.getSimpleName();
  @Nullable
  private Activity mActivity;
  @Nullable
  private BillingClient mBillingClient;
  @Nullable
  private PlayStoreBillingCallback mCallback;
  @NonNull
  private final List<String> mProductIds;
  @NonNull
  @BillingClient.SkuType
  private final String mProductType;
  @SuppressWarnings({ "NullableProblems" })
  @NonNull
  private BillingConnection mConnection;
  @NonNull
  private final List<BillingRequest> mPendingRequests = new ArrayList<>();
  
  PlayStoreBillingManager(@NonNull @BillingClient.SkuType String productType,
                          @NonNull String... productIds)
  {
    mProductIds = Collections.unmodifiableList(Arrays.asList(productIds));
    mProductType = productType;
  }

  @Override
  public void initialize(@NonNull Activity context)
  {
    LOGGER.i(TAG, "Creating play store billing client...");
    mActivity = context;
    mBillingClient = BillingClient.newBuilder(mActivity).setListener(this).build();
    mConnection = new PlayStoreBillingConnection(mBillingClient, this);
    mConnection.open();
  }

  @Override
  public void destroy()
  {
    mActivity = null;
    mConnection.close();
    mPendingRequests.clear();
  }

  @Override
  public void queryProductDetails()
  {
    executeBillingRequest(new QueryProductDetailsRequest(getClientOrThrow(), mProductType,
                                                         mCallback, mProductIds));
  }

  private void executeBillingRequest(@NonNull BillingRequest request)
  {
    switch (mConnection.getState())
    {
      case CONNECTING:
        mPendingRequests.add(request);
        break;
      case CONNECTED:
        request.execute();
        break;
      case DISCONNECTED:
        mPendingRequests.add(request);
        mConnection.open();
        break;
      case CLOSED:
        throw new IllegalStateException("Billing service connection already closed, " +
                                        "please initialize it again.");
    }
  }

  @Override
  public void launchBillingFlowForProduct(@NonNull String productId)
  {
    if (!isBillingSupported())
    {
      LOGGER.w(TAG, "Subscription is not supported by this device!");
      return;
    }

    executeBillingRequest(new LaunchBillingFlowRequest(getActivityOrThrow(), getClientOrThrow(),
                                                       mProductType, productId));
  }

  @Override
  public boolean isBillingSupported()
  {
    @BillingResponse
    int result = getClientOrThrow().isFeatureSupported(BillingClient.FeatureType.SUBSCRIPTIONS);
    return result != BillingResponse.FEATURE_NOT_SUPPORTED;
  }

  @Nullable
  @Override
  public String obtainPurchaseToken()
  {
    return null;
  }

  @Override
  public void addCallback(@NonNull PlayStoreBillingCallback callback)
  {
    mCallback = callback;
  }

  @Override
  public void removeCallback(@NonNull PlayStoreBillingCallback callback)
  {
    mCallback = null;
  }

  @Override
  public void onPurchasesUpdated(int responseCode, @Nullable List<Purchase> purchases)
  {
    if (responseCode != BillingResponse.OK || purchases == null || purchases.isEmpty())
    {
      LOGGER.e(TAG, "Billing failed. Response code: " + responseCode);
      if (mCallback != null)
        mCallback.onPurchaseFailure();
      return;
    }

    LOGGER.i(TAG, "Purchase process successful. Count of purchases: " + purchases.size());
    if (mCallback != null)
      mCallback.onPurchaseSuccessful(purchases);
  }

  @NonNull
  private BillingClient getClientOrThrow()
  {
    if (mBillingClient == null)
      throw new IllegalStateException("Manager must be initialized! Call 'initialize' method first.");

    return mBillingClient;
  }

  @NonNull
  private Activity getActivityOrThrow()
  {
    if (mActivity == null)
      throw new IllegalStateException("Manager must be initialized! Call 'initialize' method first.");

    return mActivity;
  }

  @Override
  public void onConnected()
  {
    for(@NonNull BillingRequest request: mPendingRequests)
      request.execute();

    mPendingRequests.clear();
  }

  @Override
  public void onDisconnected()
  {
    if (mPendingRequests.isEmpty())
      return;

    mPendingRequests.clear();
    if (mCallback != null)
      mCallback.onPurchaseFailure();
  }
}
