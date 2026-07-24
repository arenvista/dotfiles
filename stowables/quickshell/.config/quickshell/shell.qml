import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "./Common"
import "./components"

ShellRoot {
    id: root

    property bool dashboardVisible: false
    property bool musicVisible: false
    property bool launcherVisible: false
    property bool wifiVisible: false
    property bool btVisible: false
    property var pfpFiles: []
    property string searchTerm: ""
    property var appList: []
    property var appUsage: ({})
    property var filteredApps: {
        var source = appList
        var usage = appUsage
        if (searchTerm !== "") {
            var result = []
            for (var i = 0; i < source.length; i++) {
                var entry = source[i]
                if (entry.name.toLowerCase().includes(searchTerm) || entry.exec.toLowerCase().includes(searchTerm)) {
                    result.push(entry)
                }
            }
            source = result
        }
        var sorted = source.slice().sort(function(a, b) {
            var countA = usage[a.name] || 0
            var countB = usage[b.name] || 0
            if (countB !== countA) return countB - countA
            return a.name.localeCompare(b.name)
        })
        return sorted
    }
    property int selectedIndex: 0
    property int activeTab: 0
    property string wallSearchTerm: ""
    property var wallpaperList: []
    property var filteredWallpapers: {
        if (wallSearchTerm === "") return wallpaperList
        var result = []
        for (var i = 0; i < wallpaperList.length; i++) {
            if (wallpaperList[i].name.toLowerCase().includes(wallSearchTerm)) {
                result.push(wallpaperList[i])
            }
        }
        return result
    }
    property int wallSelectedIndex: 0
    property string currentWallpaper: ""
    property bool wallsLoaded: false
    property bool thumbsReady: false
    property bool walApplying: false

    property bool btEnabled: true
    property var btPairedDevices: []
    property var btAvailableDevices: []
    property bool btScanning: false
    property string btConnectingMAC: ""


    function toggleLauncher() { launcherVisible = !launcherVisible }

    function toggleDashboard() {
        dashboardVisible = !dashboardVisible
        if (dashboardVisible) { wifiVisible = false; btVisible = false }
    }
    function toggleMusic() { musicVisible = !musicVisible }

    function toggleWifi() {
        wifiVisible = !wifiVisible
        if (wifiVisible) { btVisible = false; dashboardVisible = false }
    }

    function toggleBluetooth() {
        btVisible = !btVisible
        if (btVisible) { wifiVisible = false; dashboardVisible = false; refreshBluetooth() }
    }

    function refreshBluetooth() {
        root.btPairedDevices = []
        root.btAvailableDevices = []
        root.btScanning = false
        root.btConnectingMAC = ""
        btStatusProc.running = true
    }

    function connectBt(mac) {
        root.btConnectingMAC = mac
        btActionProc.command = ["bash", "-c", "(printf 'trust %s\\nconnect %s\\n' \"$1\" \"$1\"; sleep 2; echo quit) | bluetoothctl 2>/dev/null", "_", mac]
        btActionProc.running = true
    }

    function disconnectBt(mac) {
        btActionProc.command = ["bash", "-c", "printf 'disconnect %s\\nquit\\n' \"$1\" | bluetoothctl 2>/dev/null", "_", mac]
        btActionProc.running = true
    }

    function pairBt(mac) {
        root.btConnectingMAC = mac
        btActionProc.command = ["bash", "-c", "printf 'pair %s\\nquit\\n' \"$1\" | bluetoothctl 2>/dev/null; sleep 2; printf 'trust %s\\nquit\\n' \"$1\" | bluetoothctl 2>/dev/null; sleep 1; printf 'connect %s\\nquit\\n' \"$1\" | bluetoothctl 2>/dev/null", "_", mac]
        btActionProc.running = true
    }

    function forgetBt(mac) {
        btActionProc.command = ["bash", "-c", "printf 'remove %s\\nquit\\n' \"$1\" | bluetoothctl 2>/dev/null", "_", mac]
        btActionProc.running = true
    }


    Component.onCompleted: {
        appListProc.running = true
        loadUsageProc.running = true
        currentWallProc.running = true
        thumbDirProc.running = true
    }

    function launchApp(app) {
        launchProc.command = ["bash", "-c", app.exec + " &"]
        launchProc.running = true
        var usage = appUsage
        var updated = {}
        for (var key in usage) updated[key] = usage[key]
        updated[app.name] = (updated[app.name] || 0) + 1
        appUsage = updated
        saveUsageProc.command = ["bash", "-c", "mkdir -p \"$(dirname \"$2\")\" && printf '%s' \"$1\" > \"$2\"", "_", JSON.stringify(updated), Paths.state + "/app_usage.json"]
        saveUsageProc.running = true
        root.launcherVisible = false
    }

    function applyWallpaper(wallpaper) {
        root.currentWallpaper = wallpaper.path
        root.walApplying = true
        applyWallProc.command = ["bash", "-c", "exec \"$1/scripts/applwal.sh\" \"$2\"", "_", Paths.config, wallpaper.path]
        // applyWallProc.command = ["bash", "-c",
        //     "notify-send '" + wallpaper.path + "' ~/wallpapers/current && " +
        //     "ln -sf '" + wallpaper.path + "' ~/wallpapers/current && " +
        //     "swww img '" + wallpaper.path + "' --transition-type any --transition-duration 2 & " +
        //     "wal -i '" + wallpaper.path + "' -n -q && " +
        //     "sleep 1"
        // ]
        applyWallProc.running = true
    }

    function loadWallpapers() {
        root.wallpaperList = []
        root.wallsLoaded = false
        root.thumbsReady = false
        wallpaperListProc.running = true
    }

    Process {
        id: thumbDirProc
        command: ["bash", "-c", "mkdir -p ~/.cache/wallpaper-thumbs"]
        onExited: root.loadWallpapers()
    }

    Process {
        id: wallpaperListProc
        command: ["bash", "-c", "find ~/wallpapers/favorites -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \\) ! -name '.*' | sort"]
        stdout: SplitParser {
            onRead: data => {
                var path = data.trim()
                if (path.length === 0) return
                var parts = path.split("/")
                var name = parts[parts.length - 1]
                var current = root.wallpaperList.slice()
                current.push({ name: name, path: path })
                root.wallpaperList = current
            }
        }
        onExited: {
            root.wallsLoaded = true
            thumbGenProc.running = true
        }
    }

    Process {
        id: thumbGenProc
        command: ["bash", "-c", "exec \"$1/scripts/create_thumbs.sh\"", "_", Paths.config]
        onExited: root.thumbsReady = true
    }

    Process {
        id: applyWallProc
        // Theme reloads colors itself via a watched FileView; just kick off the
        // "apply theme everywhere" chain (waybar/swaync/blur).
        onExited: walStepWaybar.running = true
    }

    Process {
        id: walStepWaybar
        command: ["bash", "-c", "killall waybar; waybar &"]
        onExited: walStepSwaync.running = true
    }

    Process {
        id: walStepSwaync
        command: ["bash", "-c", "cp ~/.cache/wal/colors-swaync.css ~/.config/swaync/style.css && pkill -SIGUSR1 swaync"]
        onExited: walStepBlur.running = true
    }

    Process {
        id: walStepBlur
        command: {
            var wp = root.currentWallpaper
            // gif: blur only the first frame ([0]); pass wp as a positional arg
            var src = wp.endsWith(".gif") ? "\"$1\"'[0]'" : "\"$1\""
            return ["bash", "-c", "convert " + src + " -resize 1920x -blur 0x8 -quality 85 ~/wallpapers/.current-blurred.jpg", "_", wp]
        }
        onExited: root.walApplying = false
    }

    Process {
        id: currentWallProc
        command: ["bash", "-c", "readlink -f ~/wallpapers/current 2>/dev/null || echo ''"]
        stdout: SplitParser { onRead: data => root.currentWallpaper = data.trim() }
    }

    Process {
        id: loadUsageProc
        command: ["bash", "-c", "cat \"$1\" 2>/dev/null || echo '{}'", "_", Paths.state + "/app_usage.json"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try { root.appUsage = JSON.parse(data.trim()) } catch(e) { root.appUsage = {} }
            }
        }
    }

    Process { id: saveUsageProc }
    Process { id: launchProc }

    Process {
        id: appListProc
        command: ["bash", "-c", String.raw`
        for f in /usr/share/applications/*.desktop "$HOME"/.local/share/applications/*.desktop; do
        [ -f "$f" ] || continue
        nodisplay=$(grep -i '^NoDisplay=true' "$f")
        [ -n "$nodisplay" ] && continue
        hidden=$(grep -i '^Hidden=true' "$f")
        [ -n "$hidden" ] && continue
        name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
        exec=$(grep -m1 '^Exec=' "$f" | cut -d= -f2- | sed 's/ %[fFuUdDnNickvm]//g')
        icon=$(grep -m1 '^Icon=' "$f" | cut -d= -f2-)
        [ -z "$name" ] && continue
        [ -z "$exec" ] && continue
        printf '%s\t%s\t%s\n' "$name" "$exec" "$icon"
        done | sort -f -t$'\t' -k1,1 | awk -F'\t' '!seen[$1]++'
        `]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split("\t")
                if (parts.length < 2) return
                var current = root.appList.slice()
                current.push({ name: parts[0], exec: parts[1], icon: parts.length > 2 ? parts[2] : "" })
                root.appList = current
            }
        }
    }


    Process {
        id: btStatusProc
        command: ["bash", "-c", "echo -e 'show\\nquit' | bluetoothctl 2>/dev/null | grep -q 'Powered: yes' && echo 'true' || echo 'false'"]
        stdout: SplitParser {
            onRead: data => root.btEnabled = data.trim() === "true"
        }
        onExited: {
            if (root.btEnabled) btDevicesProc.running = true
        }
    }

    Process {
        id: btToggleOnProc
        command: ["bash", "-c", "echo -e 'power on\\nquit' | bluetoothctl 2>/dev/null"]
        onExited: {
            btToggleDelayTimer.start()
        }
    }

    Timer {
        id: btToggleDelayTimer
        interval: 1000
        repeat: false
        onTriggered: refreshBluetooth()
    }

    Process {
        id: btToggleOffProc
        command: ["bash", "-c", "echo -e 'power off\\nquit' | bluetoothctl 2>/dev/null"]
        onExited: {
            root.btEnabled = false
            root.btPairedDevices = []
            root.btAvailableDevices = []
        }
    }

    Process {
        id: btDevicesProc
        command: ["bash", "-c", "echo -e 'devices\\nquit' | bluetoothctl 2>/dev/null | grep '^Device' | while read -r line; do mac=$(echo \"$line\" | awk '{print $2}'); name=$(echo \"$line\" | cut -d' ' -f3-); info=$(echo -e \"info $mac\\nquit\" | bluetoothctl 2>/dev/null); paired=$(echo \"$info\" | grep -oP 'Paired: \\K\\w+'); connected=$(echo \"$info\" | grep -oP 'Connected: \\K\\w+'); if [ \"$paired\" = \"yes\" ]; then echo \"${mac}|${name}|${connected}\"; fi; done"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split("|")
                if (parts.length < 3) return
                var mac = parts[0]
                var name = parts[1]
                var connected = parts[2] === "yes"
                var current = root.btPairedDevices.slice()
                for (var i = 0; i < current.length; i++) {
                    if (current[i].mac === mac) return
                }
                current.push({ mac: mac, name: name, connected: connected })
                root.btPairedDevices = current
            }
        }
    }

    Process {
        id: btScanProc
        command: ["bash", "-c", "echo -e 'scan on\\nquit' | bluetoothctl 2>/dev/null; sleep 5; echo -e 'scan off\\nquit' | bluetoothctl 2>/dev/null; sleep 1; echo -e 'devices\\nquit' | bluetoothctl 2>/dev/null | grep '^Device' | while read -r line; do mac=$(echo \"$line\" | awk '{print $2}'); name=$(echo \"$line\" | cut -d' ' -f3-); info=$(echo -e \"info $mac\\nquit\" | bluetoothctl 2>/dev/null); paired=$(echo \"$info\" | grep -oP 'Paired: \\K\\w+'); if [ \"$paired\" != \"yes\" ] && [ -n \"$name\" ] && [ \"$name\" != \"$mac\" ]; then echo \"${mac}|${name}\"; fi; done"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split("|")
                if (parts.length < 2) return
                var mac = parts[0]
                var name = parts[1]
                if (mac.length !== 17) return
                var current = root.btAvailableDevices.slice()
                for (var j = 0; j < current.length; j++) {
                    if (current[j].mac === mac) return
                }
                current.push({ mac: mac, name: name })
                root.btAvailableDevices = current
            }
        }
        onExited: root.btScanning = false
    }

    Process {
        id: btActionProc
        onExited: {
            root.btConnectingMAC = ""
            btActionDelayTimer.start()
        }
    }

    Timer {
        id: btActionDelayTimer
        interval: 1500
        repeat: false
        onTriggered: refreshBluetooth()
    }

    Dashboard {}
    MusicPanel {}
    WifiPanel {}
    BluetoothPanel {}
    LauncherPanel {}

    IpcHandler {
        target: "launcher"
        function toggle() {
            root.activeTab = 0
            root.toggleLauncher()
        }
    }
    IpcHandler {
        target: "dashboard"
        function toggle() { root.toggleDashboard() }
    }
    IpcHandler {
        target: "music"
        function toggle() { root.toggleMusic() }
    }
    IpcHandler {
        target: "wallpaper"
        function toggle() {
            if (!root.launcherVisible) {
                root.activeTab = 1
                root.toggleLauncher()
            } else if (root.activeTab === 1) {
                root.toggleLauncher()
            } else {
                root.activeTab = 1
                if (!root.wallsLoaded) root.loadWallpapers()
            }
        }
    }
    IpcHandler {
        target: "wifi"
        function toggle() { root.toggleWifi() }
    }
    IpcHandler {
        target: "bluetooth"
        function toggle() { root.toggleBluetooth() }
    }
}
