# --- Huawei/HMS: не ругаться и не выкидывать используемые классы ---
# Если код лишь ссылается на них условно, R8 сможет отрезать недостижимые пути.

# Не падать из-за отсутствующих HMS/EMUI классов
-dontwarn com.huawei.**
-dontwarn org.bouncycastle.**

# Сохранить публичные API HMS Analytics, если они внезапно попали транзитивно
-keep class com.huawei.hianalytics.** { *; }
-keep class com.huawei.hms.** { *; }

# Иногда встречаются ссылки на BuildEx/EMUI утилиты
-keep class com.huawei.android.os.BuildEx$VERSION { *; }

# Если попадаются util-классы libcore Huawei
-keep class com.huawei.libcore.io.** { *; }

# BouncyCastle: сохранить, если попадёт транзитивно
-keep class org.bouncycastle.** { *; }

# Безопасно отключить логирование от HMS (если не нужно)
-assumenosideeffects class com.huawei.hms.support.hianalytics.HiAnalyticsUtils {
    public static *** enableLog(...);
}
-assumenosideeffects class com.huawei.hms.framework.common.hianalytics.HianalyticsHelper {
    public *** *(...);
}
