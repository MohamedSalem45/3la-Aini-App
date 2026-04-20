# 🚀 دليل البدء السريع - المرحلة الأولى

## ✅ تم الانتهاء من جميع الميزات!

---

## 📥 كيفية التثبيت والتشغيل

### 1. تحديث المكتبات

```bash
cd d:\3ala 3eny
flutter pub get
```

### 2. تشغيل الاختبارات

```bash
# اختبارات المرحلة الأولى
flutter test test/phase_1_test.dart

# جميع الاختبارات
flutter test test/unit_test.dart test/phase_1_test.dart
```

---

## 🎯 الميزات الرئيسية

### 1️⃣ نظام الإشعارات (Push Notifications)

**الملف:** `lib/core/services/notification_service.dart`

**الميزات:**

- ✅ استقبال الإشعارات من Firebase
- ✅ عرض إشعارات محلية
- ✅ معالجة النقر على الإشعار
- ✅ الاشتراك في مواضيع (Topics)

**الاستخدام:**

```dart
// تنبيه عند تغيير الحالة
await NotificationService().notifyOrderStatusChange(
  orderId: '123',
  status: 'accepted',
  message: 'تم قبول طلبيتك',
);

// تنبيه بقرب المندوب
await NotificationService().notifyDeliveryNearby(
  orderId: '123',
  driverName: 'محمد',
);
```

---

### 2️⃣ نظام التتبع الحي (Live Tracking)

**الملف:** `lib/features/orders/services/tracking_service.dart`

**الميزات:**

- ✅ تتبع موقع المندوب الحي
- ✅ عرض الموقع على خريطة Google Maps
- ✅ حساب الوقت المتبقي للوصول
- ✅ سجل كامل للمواقع المسجلة

**الاستخدام:**

```dart
// عرض شاشة التتبع
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OrderTrackingScreen(
      orderId: '123',
      order: orderObject,
    ),
  ),
);
```

**الشاشة:** `lib/features/orders/screens/tracking_screen.dart`

---

### 3️⃣ نظام التقييمات (Ratings & Reviews)

**الملف:** `lib/features/orders/services/rating_service.dart`

**الميزات:**

- ✅ تقييم المتجر (1-5 نجوم)
- ✅ تقييم المندوب (1-5 نجوم)
- ✅ إضافة تعليقات وصور
- ✅ حساب متوسط التقييمات

**الاستخدام:**

```dart
// عرض شاشة التقييم
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AddRatingScreen(
      orderId: '123',
      storeId: 'store_789',
      driverName: 'محمد أحمد',
      userId: 'user_456',
    ),
  ),
);

// الحصول على متوسط التقييم
double average = await RatingService()
    .getStoreAverageRating('store_789');
```

**الشاشة:** `lib/features/orders/screens/add_rating_screen.dart`

---

## 📁 ملخص الملفات المضافة

### Models

```
✅ lib/features/orders/models/tracking_model.dart      (71 سطر)
✅ lib/features/orders/models/rating_model.dart        (82 سطر)
```

### Services

```
✅ lib/core/services/notification_service.dart         (160 سطر)
✅ lib/features/orders/services/tracking_service.dart  (150 سطر)
✅ lib/features/orders/services/rating_service.dart    (140 سطر)
```

### Screens

```
✅ lib/features/orders/screens/tracking_screen.dart    (220 سطر)
✅ lib/features/orders/screens/add_rating_screen.dart  (280 سطر)
```

### Tests

```
✅ test/phase_1_test.dart                              (140 سطر)
```

**المجموع:** أكثر من **1000 سطر** من الكود الاحترافي!

---

## 🔧 الإعدادات المطلوبة

### Android

#### 1. AndroidManifest.xml

أضف الأذونات:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### 2. Google Maps API Key

في `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

### iOS

#### 1. Info.plist

أضف الأوصاف:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج إلى موقعك لتتبع الطلبية</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>نحتاج إلى موقعك لتتبع الطلبية</string>
```

#### 2. Google Maps API Key

في `ios/Runner/Info.plist`:

```xml
<key>com.google.ios.maps.API_KEY</key>
<string>YOUR_API_KEY_HERE</string>
```

---

## 📊 نتائج الاختبارات

✅ جميع الاختبارات نجحت!

```
✓ TrackingData يمكن إنشاؤه بالحقول المطلوبة
✓ TrackingData يمكن تحويله من وإلى Map
✓ RatingModel يمكن إنشاؤه بالحقول المطلوبة
✓ RatingModel يمكن تحويله من وإلى Map
✓ RatingModel copyWith يعمل بشكل صحيح
✓ TrackingData له إحداثيات صحيحة
✓ RatingModel له قيمة تقييم صحيحة

7 tests passed! ✅
```

---

## 🎮 أمثلة الاستخدام

### مثال 1: إظهار التتبع الحي

```dart
class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(
                    orderId: order.id,
                    order: order,
                  ),
                ),
              );
            },
            child: const Text('تتبع الطلبية'),
          ),
        ],
      ),
    );
  }
}
```

### مثال 2: إضافة تقييم

```dart
// بعد اكتمال الطلبية
bool canRate = await RatingService()
    .canRateOrder(userId, orderId);

if (canRate) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddRatingScreen(
        orderId: orderId,
        storeId: order.storeId,
        driverName: order.driverName,
        userId: userId,
      ),
    ),
  );
}
```

### مثال 3: الاستماع للإشعارات

```dart
@override
void initState() {
  super.initState();

  NotificationService().notificationStream.listen((data) {
    print('إشعار جديد: $data');

    // تحديث واجهة الطلبيات
    setState(() {
      // تحديث الحالة
    });
  });
}
```

---

## 🚀 الخطوات التالية

### المرحلة 2 (القريبة جداً):

- [ ] نظام البحث المتقدم
- [ ] نظام الشات (In-app Chat)
- [ ] نظام الكوبونات والعروض
- [ ] تقارير وإحصائيات

### للمزيد من التفاصيل:

اطلع على ملف `PHASE_1_IMPLEMENTATION.md` الشامل

---

## 💡 نصائح مهمة

1. **الخصوصية**: اطلب من المستخدم الموافقة على الموقع قبل التتبع
2. **الأداء**: استخدم `distanceFilter` لتقليل استهلاك البطارية
3. **التكاليف**: راقب استخدام Google Maps API
4. **الموثوقية**: تعامل مع الأخطاء في الاتصال بالإنترنت

---

## 🤝 الدعم والمساعدة

في حالة وجود أي مشاكل:

1. تحقق من وثائق Firebase
2. اطلع على Google Maps Documentation
3. تأكد من الأذونات في AndroidManifest.xml و Info.plist
4. تحقق من تفعيل Google Maps API

---

**شكراً لاستخدامك تطبيق على عيني! 🎉**

_تم التطوير بواسطة: فريق على عيني_
_التاريخ: 19 أبريل 2026_
