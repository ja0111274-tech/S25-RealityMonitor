#!/usr/bin/env bash
set -e

# ============================================================
# S25RealityMonitor - Project Bootstrap Script
# Creates the full Android project structure.
# ============================================================

mkdir -p app/src/main/java/com/s25realitymonitor/data
mkdir -p app/src/main/java/com/s25realitymonitor/ui/dashboard
mkdir -p app/src/main/java/com/s25realitymonitor/ui/theme
mkdir -p app/src/main/java/com/s25realitymonitor/util
mkdir -p app/src/main/res/values
mkdir -p .github/workflows

# ---------- settings.gradle.kts ----------
cat > settings.gradle.kts <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "S25RealityMonitor"
include(":app")
EOF

# ---------- build.gradle.kts (root) ----------
cat > build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}
EOF

# ---------- gradle.properties ----------
cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

# ---------- app/build.gradle.kts ----------
cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.s25realitymonitor"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.s25realitymonitor"
        minSdk = 29
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
EOF

# ---------- AndroidManifest.xml ----------
cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- No INTERNET. No BATTERY_STATS. No storage. No location. -->
    <!-- ACCESS_NETWORK_STATE is required only to READ network type/state. -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/Theme.S25RealityMonitor">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.S25RealityMonitor">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# ---------- strings.xml ----------
cat > app/src/main/res/values/strings.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">S25 Reality Monitor</string>
</resources>
EOF

# ---------- themes.xml ----------
cat > app/src/main/res/values/themes.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.S25RealityMonitor" parent="android:Theme.Material.Light.NoActionBar" />
</resources>
EOF

# ---------- MainActivity.kt ----------
cat > app/src/main/java/com/s25realitymonitor/MainActivity.kt <<'EOF'
package com.s25realitymonitor

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import com.s25realitymonitor.ui.dashboard.DashboardScreen
import com.s25realitymonitor.ui.theme.S25RealityTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            S25RealityTheme {
                CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Rtl) {
                    DashboardScreen()
                }
            }
        }
    }
}
EOF

# ---------- data/Models.kt ----------
cat > app/src/main/java/com/s25realitymonitor/data/Models.kt <<'EOF'
package com.s25realitymonitor.data

data class BatteryMetrics(
    val percentage: Int?,
    val status: String?,
    val plugged: String?,
    val temperatureC: Double?,
    val voltageMv: Int?,
    val currentMa: Double?,
    val health: String?,
    val healthReason: String?
)

data class MemoryMetrics(
    val totalBytes: Long,
    val availableBytes: Long,
    val usedBytes: Long,
    val usagePercent: Double?
) {
    companion object {
        fun unavailable() = MemoryMetrics(0, 0, 0, null)
    }
}

data class StorageMetrics(
    val totalBytes: Long,
    val availableBytes: Long,
    val usedBytes: Long,
    val usagePercent: Double?
)

data class ThermalMetrics(
    val statusCode: Int?,
    val statusLabel: String?,
    val unavailableReason: String?
) {
    companion object {
        fun unavailable(reason: String) = ThermalMetrics(null, null, reason)
    }
}

data class CpuMetrics(
    val usagePercent: Double?,
    val cores: Int,
    val unavailableReason: String?
) {
    companion object {
        fun unavailable(cores: Int, reason: String) = CpuMetrics(null, cores, reason)
    }
}

data class NetworkMetrics(
    val connected: Boolean,
    val transport: String?,
    val validated: Boolean?,
    val downKbps: Int?,
    val upKbps: Int?
) {
    companion object {
        fun unavailable(reason: String) = NetworkMetrics(false, null, null, null, null)
    }
}

data class RefreshRateMetrics(
    val currentHz: Float?,
    val supportedHz: List<Float>
) {
    companion object {
        fun unavailable() = RefreshRateMetrics(null, emptyList())
    }
}

data class DeviceMetrics(
    val model: String,
    val manufacturer: String,
    val androidVersion: String,
    val sdkInt: Int
)

data class MetricsSnapshot(
    val battery: BatteryMetrics,
    val memory: MemoryMetrics,
    val storage: StorageMetrics,
    val thermal: ThermalMetrics,
    val cpu: CpuMetrics,
    val network: NetworkMetrics,
    val refreshRate: RefreshRateMetrics,
    val device: DeviceMetrics,
    val timestamp: Long
)
EOF

# ---------- data/SystemMetricsReader.kt ----------
cat > app/src/main/java/com/s25realitymonitor/data/SystemMetricsReader.kt <<'EOF'
package com.s25realitymonitor.data

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.display.DisplayManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.os.StatFs
import android.view.Display
import androidx.core.content.getSystemService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import java.io.File

class SystemMetricsReader(private val context: Context) {

    suspend fun readAll(): MetricsSnapshot = withContext(Dispatchers.IO) {
        MetricsSnapshot(
            battery = readBattery(),
            memory = readMemory(),
            storage = readStorage(),
            thermal = readThermal(),
            cpu = readCpu(),
            network = readNetwork(),
            refreshRate = readRefreshRate(),
            device = readDevice(),
            timestamp = System.currentTimeMillis()
        )
    }

    private fun readBattery(): BatteryMetrics {
        val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            ?: return BatteryMetrics(null, null, null, null, null, null, null,
                "تعذر قراءة بث البطارية")

        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val pct = if (level >= 0 && scale > 0) level * 100 / scale else null

        val status = when (intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "يشحن"
            BatteryManager.BATTERY_STATUS_FULL -> "ممتلئ"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "يفرغ"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "لا يشحن"
            else -> null
        }
        val plugged = when (intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)) {
            BatteryManager.BATTERY_PLUGGED_AC -> "شاحن AC"
            BatteryManager.BATTERY_PLUGGED_USB -> "USB"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "لاسلكي"
            0 -> "غير موصول"
            else -> null
        }
        val tempRaw = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
        val tempC = if (tempRaw > 0) tempRaw / 10.0 else null
        val voltMv = intent.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1).takeIf { it > 0 }

        val bm = context.getSystemService<BatteryManager>()
        val currentUa = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
            ?.takeIf { it != Int.MIN_VALUE && it != 0 && kotlin.math.abs(it) < 10_000_000 }
        val currentMa = currentUa?.let { it / 1000.0 }

        return BatteryMetrics(
            percentage = pct,
            status = status,
            plugged = plugged,
            temperatureC = tempC,
            voltageMv = voltMv,
            currentMa = currentMa,
            health = null,
            healthReason = "لا تتوفر صحة بطارية موثوقة عبر Android public API"
        )
    }

    private fun readMemory(): MemoryMetrics {
        val am = context.getSystemService<ActivityManager>() ?: return MemoryMetrics.unavailable()
        val info = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        val used = info.totalMem - info.availMem
        val pct = if (info.totalMem > 0) used.toDouble() / info.totalMem * 100 else null
        return MemoryMetrics(info.totalMem, info.availMem, used, pct)
    }

    private fun readStorage(): StorageMetrics {
        val stat = StatFs(Environment.getDataDirectory().path)
        val total = stat.totalBytes
        val available = stat.availableBytes
        val used = total - available
        val pct = if (total > 0) used.toDouble() / total * 100 else null
        return StorageMetrics(total, available, used, pct)
    }

    private fun readThermal(): ThermalMetrics {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return ThermalMetrics.unavailable("يتطلب Android 10 أو أحدث")
        }
        val pm = context.getSystemService<PowerManager>()
            ?: return ThermalMetrics.unavailable("PowerManager غير متاح")
        val code = pm.currentThermalStatus
        val label = when (code) {
            PowerManager.THERMAL_STATUS_NONE -> "طبيعي"
            PowerManager.THERMAL_STATUS_LIGHT -> "خفيف"
            PowerManager.THERMAL_STATUS_MODERATE -> "متوسط"
            PowerManager.THERMAL_STATUS_SEVERE -> "شديد"
            PowerManager.THERMAL_STATUS_CRITICAL -> "حرج"
            PowerManager.THERMAL_STATUS_EMERGENCY -> "طوارئ"
            PowerManager.THERMAL_STATUS_SHUTDOWN -> "إيقاف"
            else -> "غير معروف"
        }
        return ThermalMetrics(code, label, null)
    }

    private data class ProcStat(val total: Long, val idle: Long)

    private suspend fun readCpu(): CpuMetrics {
        val cores = Runtime.getRuntime().availableProcessors()
        return try {
            val first = readProcStat() ?: return CpuMetrics.unavailable(cores,
                "غير متاح من النظام — /proc/stat محظور على هذا الإصدار")
            delay(750)
            val second = readProcStat() ?: return CpuMetrics.unavailable(cores,
                "غير متاح من النظام — /proc/stat محظور على هذا الإصدار")
            val totalDelta = second.total - first.total
            val idleDelta = second.idle - first.idle
            if (totalDelta <= 0L) {
                return CpuMetrics.unavailable(cores,
                    "غير متاح من النظام — /proc/stat محظور على هذا الإصدار")
            }
            val usage = (totalDelta - idleDelta).toDouble() / totalDelta * 100
            if (usage < 0 || usage > 100) {
                return CpuMetrics.unavailable(cores, "قيم /proc/stat غير منطقية")
            }
            CpuMetrics(usage, cores, null)
        } catch (e: Exception) {
            CpuMetrics.unavailable(cores,
                "غير متاح من النظام — /proc/stat محظور على هذا الإصدار")
        }
    }

    private fun readProcStat(): ProcStat? = try {
        val line = File("/proc/stat").readLines().firstOrNull { it.startsWith("cpu ") }
        if (line == null) null
        else {
            val parts = line.trim().split(Regex("\\s+")).drop(1).mapNotNull { it.toLongOrNull() }
            if (parts.size < 5) null
            else {
                val idle = parts[3] + (parts.getOrNull(4) ?: 0)
                val total = parts.take(8).sum()
                if (total == 0L) null else ProcStat(total, idle)
            }
        }
    } catch (e: Exception) { null }

    private fun readNetwork(): NetworkMetrics {
        val cm = context.getSystemService<ConnectivityManager>()
            ?: return NetworkMetrics.unavailable("ConnectivityManager غير متاح")
        val network = cm.activeNetwork ?: return NetworkMetrics(false, null, null, null, null)
        val caps = cm.getNetworkCapabilities(network)
            ?: return NetworkMetrics(false, null, null, null, null)
        val transport = when {
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "Wi-Fi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Cellular"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "Ethernet"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "VPN"
            else -> "أخرى"
        }
        val validated = caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        val down = caps.linkDownstreamBandwidthKbps.takeIf { it > 0 }
        val up = caps.linkUpstreamBandwidthKbps.takeIf { it > 0 }
        return NetworkMetrics(true, transport, validated, down, up)
    }

    private fun readRefreshRate(): RefreshRateMetrics {
        val dm = context.getSystemService<DisplayManager>()
            ?: return RefreshRateMetrics.unavailable()
        val display = dm.getDisplay(Display.DEFAULT_DISPLAY)
            ?: return RefreshRateMetrics.unavailable()
        val current = display.refreshRate
        val modes = display.supportedModes.map { it.refreshRate }.distinct().sorted()
        return RefreshRateMetrics(current, modes)
    }

    private fun readDevice(): DeviceMetrics = DeviceMetrics(
        model = Build.MODEL,
        manufacturer = Build.MANUFACTURER,
        androidVersion = Build.VERSION.RELEASE,
        sdkInt = Build.VERSION.SDK_INT
    )
}
EOF

# ---------- data/MetricsRepository.kt ----------
cat > app/src/main/java/com/s25realitymonitor/data/MetricsRepository.kt <<'EOF'
package com.s25realitymonitor.data

import android.content.Context

class MetricsRepository(context: Context) {
    private val reader = SystemMetricsReader(context)
    suspend fun snapshot(): MetricsSnapshot = reader.readAll()
}
EOF

# ---------- util/Formatters.kt ----------
cat > app/src/main/java/com/s25realitymonitor/util/Formatters.kt <<'EOF'
package com.s25realitymonitor.util

import java.util.Locale

object Formatters {
    fun bytes(bytes: Long): String {
        if (bytes <= 0) return "0 B"
        val kb = 1024.0
        val mb = kb * 1024
        val gb = mb * 1024
        return when {
            bytes >= gb -> String.format(Locale.US, "%.2f GB", bytes / gb)
            bytes >= mb -> String.format(Locale.US, "%.1f MB", bytes / mb)
            bytes >= kb -> String.format(Locale.US, "%.0f KB", bytes / kb)
            else -> "$bytes B"
        }
    }

    fun percent(value: Double?): String =
        if (value == null) "غير متاح" else String.format(Locale.US, "%.1f%%", value)

    fun available(value: Any?): String = value?.toString() ?: "غير متاح من النظام"
}
EOF

# ---------- ui/theme/Theme.kt ----------
cat > app/src/main/java/com/s25realitymonitor/ui/theme/Theme.kt <<'EOF'
package com.s25realitymonitor.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColors = darkColorScheme(
    primary = Color(0xFF80CBC4),
    secondary = Color(0xFF9FA8DA),
    background = Color(0xFF101418),
    surface = Color(0xFF1B1F24)
)

private val LightColors = lightColorScheme(
    primary = Color(0xFF00695C),
    secondary = Color(0xFF3949AB),
    background = Color(0xFFF5F7FA),
    surface = Color(0xFFFFFFFF)
)

@Composable
fun S25RealityTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkColors else LightColors
    MaterialTheme(colorScheme = colors, content = content)
}
EOF

# ---------- ui/dashboard/DashboardViewModel.kt ----------
cat > app/src/main/java/com/s25realitymonitor/ui/dashboard/DashboardViewModel.kt <<'EOF'
package com.s25realitymonitor.ui.dashboard

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.s25realitymonitor.data.MetricsRepository
import com.s25realitymonitor.data.MetricsSnapshot
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class DashboardViewModel(app: Application) : AndroidViewModel(app) {

    private val repository = MetricsRepository(app)
    private val _snapshot = MutableStateFlow<MetricsSnapshot?>(null)
    val snapshot: StateFlow<MetricsSnapshot?> = _snapshot.asStateFlow()

    private var job: Job? = null

    fun start(intervalMs: Long = 1000L) {
        stop()
        job = viewModelScope.launch {
            while (isActive) {
                try {
                    _snapshot.value = repository.snapshot()
                } catch (e: Exception) {
                    // keep last snapshot
                }
                delay(intervalMs)
            }
        }
    }

    fun stop() {
        job?.cancel()
        job = null
    }

    fun refreshOnce() {
        viewModelScope.launch {
            try { _snapshot.value = repository.snapshot() } catch (_: Exception) {}
        }
    }
}
EOF

# ---------- ui/dashboard/DashboardScreen.kt ----------
cat > app/src/main/java/com/s25realitymonitor/ui/dashboard/DashboardScreen.kt <<'EOF'
package com.s25realitymonitor.ui.dashboard

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.s25realitymonitor.data.MetricsSnapshot
import com.s25realitymonitor.util.Formatters

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(vm: DashboardViewModel = viewModel()) {
    val snapshot by vm.snapshot.collectAsState()
    var intervalMs by remember { mutableStateOf(1000L) }

    LaunchedEffect(intervalMs) { vm.start(intervalMs) }
    DisposableEffect(Unit) { onDispose { vm.stop() } }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("S25 Reality Monitor", fontWeight = FontWeight.Bold) },
                actions = {
                    TextButton(onClick = { vm.refreshOnce() }) { Text("تحديث") }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .padding(12.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            IntervalSelector(intervalMs) { intervalMs = it }
            val s = snapshot
            if (s == null) {
                Box(Modifier.fillMaxWidth().padding(24.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator()
                }
            } else {
                BatteryCard(s)
                MemoryCard(s)
                StorageCard(s)
                ThermalCard(s)
                CpuCard(s)
                NetworkCard(s)
                RefreshRateCard(s)
                DeviceCard(s)
                Text(
                    "آخر تحديث: ${java.text.SimpleDateFormat("HH:mm:ss", java.util.Locale.US).format(java.util.Date(s.timestamp))}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(Modifier.height(24.dp))
            }
        }
    }
}

@Composable
private fun IntervalSelector(current: Long, onSelect: (Long) -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("معدل التحديث:", fontSize = 14.sp)
        listOf(1000L to "1ث", 2000L to "2ث", 5000L to "5ث").forEach { (ms, label) ->
            FilterChip(selected = current == ms, onClick = { onSelect(ms) }, label = { Text(label) })
        }
    }
}

@Composable
private fun MetricCard(
    title: String,
    source: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(Modifier.fillMaxWidth()) {
        Column(Modifier.padding(14.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(title, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                Text(source, fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Spacer(Modifier.height(8.dp))
            content()
        }
    }
}

@Composable
private fun RowItem(label: String, value: String) {
    Row(Modifier.fillMaxWidth().padding(vertical = 2.dp), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, fontSize = 13.sp)
        Text(value, fontSize = 13.sp, fontWeight = FontWeight.Medium)
    }
}

@Composable
private fun BatteryCard(s: MetricsSnapshot) {
    MetricCard("البطارية", "Android API") {
        RowItem("النسبة", s.battery.percentage?.let { "$it%" } ?: "غير متاح من النظام")
        RowItem("الحالة", s.battery.status ?: "غير متاح من النظام")
        RowItem("المصدر", s.battery.plugged ?: "غير متاح من النظام")
        RowItem("الحرارة", s.battery.temperatureC?.let { String.format("%.1f °C", it) } ?: "غير متاح من النظام")
        RowItem("الجهد", s.battery.voltageMv?.let { "$it mV" } ?: "غير متاح من النظام")
        RowItem("التيار", s.battery.currentMa?.let { String.format("%.1f mA", it) } ?: "غير متاح من النظام")
        RowItem("الصحة", s.battery.health ?: "غير متاح من النظام")
    }
}

@Composable
private fun MemoryCard(s: MetricsSnapshot) {
    MetricCard("الذاكرة (RAM)", "Android API") {
        RowItem("الإجمالي", Formatters.bytes(s.memory.totalBytes))
        RowItem("المتاح", Formatters.bytes(s.memory.availableBytes))
        RowItem("المستخدم (محسوب)", Formatters.bytes(s.memory.usedBytes))
        RowItem("النسبة", Formatters.percent(s.memory.usagePercent))
    }
}

@Composable
private fun StorageCard(s: MetricsSnapshot) {
    MetricCard("التخزين الداخلي", "قياس نظام") {
        RowItem("الإجمالي", Formatters.bytes(s.storage.totalBytes))
        RowItem("المتاح", Formatters.bytes(s.storage.availableBytes))
        RowItem("المستخدم", Formatters.bytes(s.storage.usedBytes))
        RowItem("النسبة", Formatters.percent(s.storage.usagePercent))
    }
}

@Composable
private fun ThermalCard(s: MetricsSnapshot) {
    MetricCard("الحالة الحرارية", "Android API") {
        RowItem("الحالة", s.thermal.statusLabel ?: "غير متاح من النظام")
        if (s.thermal.unavailableReason != null) {
            Text(s.thermal.unavailableReason!!, fontSize = 11.sp, color = MaterialTheme.colorScheme.error)
        }
    }
}

@Composable
private fun CpuCard(s: MetricsSnapshot) {
    MetricCard("المعالج (CPU)", "قياس نظام") {
        RowItem("الاستخدام", s.cpu.usagePercent?.let { String.format("%.1f%%", it) } ?: (s.cpu.unavailableReason ?: "غير متاح من النظام"))
        RowItem("عدد الأنوية", s.cpu.cores.toString())
    }
}

@Composable
private fun NetworkCard(s: MetricsSnapshot) {
    MetricCard("الشبكة", "Android API") {
        RowItem("الحالة", if (s.network.connected) "متصل" else "غير متصل")
        RowItem("النوع", s.network.transport ?: "غير متاح من النظام")
        RowItem("مُحقّقة", s.network.validated?.let { if (it) "نعم" else "لا" } ?: "غير متاح من النظام")
        RowItem("تنزيل (تقديري)", s.network.downKbps?.let { "$it Kbps" } ?: "غير متاح من النظام")
        RowItem("رفع (تقديري)", s.network.upKbps?.let { "$it Kbps" } ?: "غير متاح من النظام")
    }
}

@Composable
private fun RefreshRateCard(s: MetricsSnapshot) {
    MetricCard("معدل تحديث الشاشة", "Android API") {
        RowItem("الحالي", s.refreshRate.currentHz?.let { String.format("%.1f Hz", it) } ?: "غير متاح من النظام")
        RowItem("المدعوم", if (s.refreshRate.supportedHz.isEmpty()) "غير متاح من النظام"
            else s.refreshRate.supportedHz.joinToString(", ") { String.format("%.0f", it) })
    }
}

@Composable
private fun DeviceCard(s: MetricsSnapshot) {
    MetricCard("الجهاز", "Android API") {
        RowItem("الطراز", s.device.model)
        RowItem("المصنّع", s.device.manufacturer)
        RowItem("إصدار Android", s.device.androidVersion)
        RowItem("API", s.device.sdkInt.toString())
    }
}
EOF

echo "Project files created successfully."