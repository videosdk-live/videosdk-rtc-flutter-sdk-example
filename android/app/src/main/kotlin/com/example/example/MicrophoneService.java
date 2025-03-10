package com.example.example;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

public class MicrophoneService extends Service {

    private static final String TAG = "MicrophoneService";
    private static final String NOTIFICATION_CHANNEL_ID = "1001";
    private static final int NOTIFICATION_ID = 1001;
    private static final String NOTIFICATION_CHANNEL_DESC = "Microphone notification Channel";

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        Log.d(TAG, "onBind: Service bound");
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand: Microphone Service Initiated");
        generateForegroundNotification();
        Log.d(TAG, "onStartCommand: Microphone Service Started");
        return START_STICKY;
    }

    private void generateForegroundNotification() {
        Log.d(TAG, "generateForegroundNotification: Creating notification");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent notificationIntent = new Intent(this, getApplication().getClass());
            notificationIntent.addFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT);
            PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent,
                    PendingIntent.FLAG_IMMUTABLE);

            ApplicationInfo ai;
            String notificationTitle = null;
            String notificationContent = null;
            int resourceId = 0;

            try {
                ai = getPackageManager().getApplicationInfo(this.getPackageName(), PackageManager.GET_META_DATA);
                if (ai != null) {
                    Bundle bundle = ai.metaData;
                    if (bundle != null) {
                        notificationTitle = bundle.getString("notificationTitle");
                        notificationContent = bundle.getString("notificationContent");
                        resourceId = bundle.getInt("notificationIcon");
                    }
                }
            } catch (PackageManager.NameNotFoundException e) {
                Log.e(TAG, "Error retrieving notification metadata", e);
            }

            if (notificationTitle == null) {
                notificationTitle = "VideoSDK RTC is Running";
            }
            if (notificationContent == null) {
                notificationContent = "Meeting is running";
            }

            if (resourceId == 0) {
                resourceId = getApplicationInfo().icon;
            }

            Log.d(TAG, "Notification Title: " + notificationTitle);
            Log.d(TAG, "Notification Content: " + notificationContent);

            NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this,
                    NOTIFICATION_CHANNEL_ID)
                    .setContentTitle(notificationTitle)
                    .setSmallIcon(resourceId)
                    .setContentText(notificationContent)
                    .setContentIntent(pendingIntent);
            Notification notification = notificationBuilder.build();

            NotificationChannel channel = new NotificationChannel(NOTIFICATION_CHANNEL_ID,
                    "Microphone notification Channel", NotificationManager.IMPORTANCE_DEFAULT);
            channel.setDescription(NOTIFICATION_CHANNEL_DESC);
            NotificationManager notificationManager = (NotificationManager) getSystemService(
                    Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(channel);
            notificationManager.notify(NOTIFICATION_ID, notification);
            Log.d(TAG, "Notification created and displayed");

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE);
            } else {
                startForeground(NOTIFICATION_ID, notification);
            }
            Log.d(TAG, "Service started in foreground");
        }
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy: Microphone Service Stopping");
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(NOTIFICATION_ID);
        Log.d(TAG, "onDestroy: Notification cancelled");
    }
}
