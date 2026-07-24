import Quickshell
import "../Common"
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: dashboard
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; right: true }
    margins { top: 40; bottom: 10; right: root.dashboardVisible ? 6 : -450 }
    implicitWidth: 420
    color: "transparent"
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property int cpuVal: 0
    // /proc/stat jiffy counters from the previous sample, for CPU% deltas
    property real cpuPrevTotal: 0
    property real cpuPrevIdle: 0
    property int ramVal: 0
    property int diskVal: 0
    property int batVal: 100
    property bool batCharging: false
    property bool batLowNotified: false
    readonly property int batLowThreshold: 15
    readonly property bool batLow: batVal <= batLowThreshold && !batCharging
    property int volVal: 50
    property int brightVal: 100

    // Notify once when the battery drops into the low range while discharging;
    // re-arm when charging or back above the threshold.
    function checkLowBattery() {
        if (batLow && !batLowNotified) {
            batLowNotified = true
            batNotifyProc.running = true
        } else if (!batLow) {
            batLowNotified = false
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.background, 0.7)
        radius: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Card {
                id: profileSection
                Layout.fillWidth: true
                Layout.preferredHeight: pfpPickerOpen ? 280 : 100
                radius: 15
                clip: true
                property bool pfpPickerOpen: false
                Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        Item {
                            id: pfpContainer
                            width: 74
                            height: 74
                            Rectangle {
                                id: pfpBorder
                                anchors.fill: parent
                                radius: 37
                                color: "transparent"
                                border.width: 3
                                border.color: Theme.color5
                            }
                            Image {
                                id: pfpImage
                                anchors.centerIn: parent
                                width: 68
                                height: 68
                                source: Paths.fileUrl("assets/pfps/pfp.jpg")
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                cache: false
                                sourceSize.width: 256
                                sourceSize.height: 256
                                visible: false
                                property int reloadTrigger: 0
                                function reload() {
                                    reloadTrigger++
                                    source = ""
                                    source = Paths.fileUrl("assets/pfps/pfp.jpg") + "?" + reloadTrigger
                                }
                            }
                            Rectangle {
                                id: pfpMask
                                anchors.centerIn: parent
                                width: 68
                                height: 68
                                radius: 34
                                visible: false
                            }
                            OpacityMask {
                                anchors.centerIn: parent
                                width: 68
                                height: 68
                                source: pfpImage
                                maskSource: pfpMask
                            }
                            Rectangle {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                width: 22
                                height: 22
                                radius: 11
                                color: Theme.color5
                                border.width: 2
                                border.color: Theme.background
                                StyledText {
                                    anchors.centerIn: parent
                                    text: "󰏫"
                                    color: Theme.background
                                    font.pixelSize: 12
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    profileSection.pfpPickerOpen = !profileSection.pfpPickerOpen
                                    if (profileSection.pfpPickerOpen) {
                                        root.pfpFiles = []
                                        pfpListProc.running = true
                                    }
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            StyledText {
                                text: Quickshell.env("USER")
                                color: Theme.color5
                                font.pixelSize: 26
                                font.bold: true
                            }
                            StyledText {
                                id: uptimeText
                                text: "up ..."
                                color: Theme.foreground
                                font.pixelSize: 12
                            }
                        }
                    }
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        visible: profileSection.pfpPickerOpen
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            StyledText {
                                text: "Choose Avatar"
                                color: Theme.color5
                                font.pixelSize: 12
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: pfpGrid.height
                                clip: true
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                GridLayout {
                                    id: pfpGrid
                                    width: parent.width
                                    columns: 6
                                    rowSpacing: 8
                                    columnSpacing: 8
                                    Repeater {
                                        model: root.pfpFiles
                                        Item {
                                            width: 48
                                            height: 48
                                            Layout.alignment: Qt.AlignHCenter
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 24
                                                color: "transparent"
                                                border.width: 2
                                                border.color: thumbMa.containsMouse ? Theme.color13 : Theme.color5
                                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                            }
                                            Image {
                                                id: thumbImg
                                                anchors.centerIn: parent
                                                width: 44
                                                height: 44
                                                source: "file://" + modelData
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                sourceSize.width: 128
                                                sourceSize.height: 128
                                                visible: false
                                            }
                                            Rectangle {
                                                id: thumbMask
                                                anchors.centerIn: parent
                                                width: 44
                                                height: 44
                                                radius: 22
                                                visible: false
                                            }
                                            OpacityMask {
                                                anchors.centerIn: parent
                                                width: 44
                                                height: 44
                                                source: thumbImg
                                                maskSource: thumbMask
                                            }
                                            MouseArea {
                                                id: thumbMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    setPfpProc.selFile = modelData
                                                    setPfpProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Process {
                    id: pfpListProc
                    command: ["bash", "-c", "find \"$1/pfps\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif' \\) ! -name 'pfp.jpg' | sort", "_", Paths.assets]
                    stdout: SplitParser {
                        onRead: data => {
                            var file = data.trim()
                            if (file.length > 0) {
                                var current = root.pfpFiles.slice()
                                current.push(file)
                                root.pfpFiles = current
                            }
                        }
                    }
                }
                Process {
                    id: setPfpProc
                    property string selFile: ""
                    command: ["cp", selFile, Paths.assets + "/pfps/pfp.jpg"]
                    onExited: {
                        pfpImage.reload()
                        profileSection.pfpPickerOpen = false
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 15
                Row {
                    anchors.centerIn: parent
                    spacing: 25
                    PowerBtn { icon: "⏻"; iconColor: Theme.color2; cmd: "systemctl poweroff" }
                    PowerBtn { icon: "󰜉"; iconColor: Theme.color13; cmd: "systemctl reboot" }
                    PowerBtn { icon: "󰌾"; iconColor: Theme.color5; cmd: "hyprlock" }
                    PowerBtn { icon: "󰒲"; iconColor: Theme.color4; cmd: "systemctl suspend" }
                    PowerBtn { icon: "󰍃"; iconColor: Theme.color1; cmd: "hyprctl dispatch exit" }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 15
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    StyledText {
                        id: batIcon
                        text: "󰁹"
                        color: dashboard.batLow ? Theme.color1 : Theme.color2
                        font.pixelSize: 32
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        StyledText {
                            text: "Battery " + dashboard.batVal + "%"
                            color: Theme.foreground
                            font.pixelSize: 18
                        }
                        StyledText {
                            id: batStatus
                            text: "Checking..."
                            color: dashboard.batLow ? Theme.color1 : Theme.color8
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                radius: 15
                Row {
                    anchors.centerIn: parent
                    spacing: 30
                    CircularStat { label: "CPU"; icon: ""; barColor: Theme.color1; value: dashboard.cpuVal }
                    CircularStat { label: "RAM"; icon: ""; barColor: Theme.color5; value: dashboard.ramVal }
                    CircularStat { label: "DISK"; icon: ""; barColor: Theme.color4; value: dashboard.diskVal }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                radius: 15
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    ValueSlider {
                        icon: dashboard.volVal == 0 ? "󰝟" : dashboard.volVal < 50 ? "󰖀" : "󰕾"
                        barColor: Theme.color4
                        value: dashboard.volVal
                        iconInteractive: true
                        onIconClicked: volMuteProc.running = true
                        onMoved: percent => {
                            dashboard.volVal = percent
                            volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (percent / 100).toFixed(2)]
                            volSetProc.running = true
                        }
                    }
                    ValueSlider {
                        icon: dashboard.brightVal < 30 ? "󰃞" : dashboard.brightVal < 70 ? "󰃟" : "󰃠"
                        barColor: Theme.color13
                        value: dashboard.brightVal
                        minValue: 1
                        onMoved: percent => {
                            dashboard.brightVal = percent
                            brightSetProc.command = ["bash", "-c", "brightnessctl set " + percent + "%"]
                            brightSetProc.running = true
                        }
                    }
                    Process {
                        id: volMuteProc
                        command: ["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
                        onExited: volProc.running = true
                    }
                    Process { id: volSetProc }
                    Process { id: brightSetProc }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 15
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    StyledText {
                        id: timeDisplay
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "12:00:00 AM"
                        color: Theme.color5
                        font.pixelSize: 40
                    }
                    StyledText {
                        id: dateDisplay
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "01.01.2026, Friday"
                        color: Theme.foreground
                        font.pixelSize: 14
                    }
                }
            }
        }
    }

    component CircularStat: Item {
        property string label
        property string icon
        property color barColor
        property int value
        width: 90
        height: 110
        Column {
            anchors.centerIn: parent
            spacing: 8
            Item {
                width: 70
                height: 70
                anchors.horizontalCenter: parent.horizontalCenter
                Canvas {
                    anchors.fill: parent
                    property int statValue: value
                    onStatValueChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.lineWidth = 5
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.3)
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, 0, 2 * Math.PI)
                        ctx.stroke()
                        ctx.strokeStyle = barColor
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, -Math.PI / 2, -Math.PI / 2 + (statValue / 100) * 2 * Math.PI)
                        ctx.stroke()
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: icon
                        color: barColor
                        font.pixelSize: 16
                    }
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: value + "%"
                        color: Theme.foreground
                        font.pixelSize: 14
                    }
                }
            }
            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: Theme.color8
                font.pixelSize: 11
            }
        }
    }

    component PowerBtn: Rectangle {
        property string icon
        property color iconColor
        property string cmd
        width: 40
        height: 40
        radius: 10
        color: powerMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        StyledText {
            anchors.centerIn: parent
            text: icon
            color: iconColor
            font.pixelSize: 18
        }
        MouseArea {
            id: powerMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cmdProc.running = true
        }
        Process {
            id: cmdProc
            command: ["bash", "-c", cmd]
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var hours = now.getHours()
            var minutes = now.getMinutes()
            var seconds = now.getSeconds()
            var ampm = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            var h = hours < 10 ? '0' + hours : hours
            var m = minutes < 10 ? '0' + minutes : minutes
            var s = seconds < 10 ? '0' + seconds : seconds
            timeDisplay.text = h + ':' + m + ':' + s + ' ' + ampm
            dateDisplay.text = Qt.formatDate(now, "dd.MM.yyyy, dddd")
        }
    }

    // Full stats poll — only while the dashboard is visible.
    // triggeredOnStart gives an instant refresh the moment it opens.
    Timer {
        interval: 2000
        running: root.dashboardVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            diskProc.running = true
            batProc.running = true
            batStatusProc.running = true
            volProc.running = true
            brightProc.running = true
            uptimeProc.running = true
        }
    }

    // Battery must keep updating while hidden so low-battery notify still fires.
    // (Phase 3 replaces this with event-driven UPower.)
    Timer {
        interval: 30000
        running: !root.dashboardVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batProc.running = true
            batStatusProc.running = true
        }
    }

    // CPU% from /proc/stat jiffy deltas — cheap read, no `top` process.
    Process {
        id: cpuProc
        command: ["head", "-1", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                var f = data.trim().split(/\s+/)  // ["cpu", user, nice, system, idle, iowait, ...]
                if (f.length < 5 || f[0] !== "cpu") return
                var total = 0
                for (var i = 1; i < f.length; i++) total += parseInt(f[i]) || 0
                var idle = (parseInt(f[4]) || 0) + (parseInt(f[5]) || 0)  // idle + iowait
                var dTotal = total - dashboard.cpuPrevTotal
                var dIdle = idle - dashboard.cpuPrevIdle
                if (dashboard.cpuPrevTotal > 0 && dTotal > 0)
                    dashboard.cpuVal = Math.round(100 * (dTotal - dIdle) / dTotal)
                dashboard.cpuPrevTotal = total
                dashboard.cpuPrevIdle = idle
            }
        }
    }
    Process {
        id: ramProc
        command: ["bash", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.ramVal = parseInt(data) || 0 }
    }
    Process {
        id: diskProc
        command: ["bash", "-c", "df / | awk 'NR==2 {gsub(/%/,\"\"); print $5}'"]
        stdout: SplitParser { onRead: data => dashboard.diskVal = parseInt(data) || 0 }
    }
    Process {
        id: batProc
        command: ["bash", "-c", "bat=$(ls /sys/class/power_supply/ 2>/dev/null | grep -m1 '^BAT'); cat \"/sys/class/power_supply/$bat/capacity\" 2>/dev/null || echo 100"]
        stdout: SplitParser {
            onRead: data => {
                dashboard.batVal = parseInt(data) || 100
                var cap = dashboard.batVal
                if (cap >= 90) batIcon.text = "󰁹"
                else if (cap >= 80) batIcon.text = "󰂂"
                else if (cap >= 70) batIcon.text = "󰂁"
                else if (cap >= 60) batIcon.text = "󰂀"
                else if (cap >= 50) batIcon.text = "󰁿"
                else if (cap >= 40) batIcon.text = "󰁾"
                else if (cap >= 30) batIcon.text = "󰁽"
                else if (cap >= 20) batIcon.text = "󰁼"
                else if (cap >= 10) batIcon.text = "󰁻"
                else batIcon.text = "󰁺"
                dashboard.checkLowBattery()
            }
        }
    }
    Process {
        id: batStatusProc
        command: ["bash", "-c", "bat=$(ls /sys/class/power_supply/ 2>/dev/null | grep -m1 '^BAT'); cat \"/sys/class/power_supply/$bat/status\" 2>/dev/null || echo Unknown"]
        stdout: SplitParser {
            onRead: data => {
                var status = data.trim()
                dashboard.batCharging = (status === "Charging" || status === "Full")
                if (status === "Charging") {
                    batStatus.text = "Charging"
                    batIcon.text = "󰂄"
                } else if (status === "Full") {
                    batStatus.text = "Fully charged"
                } else {
                    batStatus.text = dashboard.batLow ? "Low battery!" : "Discharging"
                }
                dashboard.checkLowBattery()
            }
        }
    }
    Process {
        id: batNotifyProc
        command: ["notify-send", "-u", "critical", "-i", "battery-caution",
                  "Low battery", "Battery at " + dashboard.batVal + "% — plug in your charger."]
    }
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.volVal = parseInt(data) || 0 }
    }
    Process {
        id: brightProc
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{gsub(/%/,\"\"); print $4}'"]
        stdout: SplitParser { onRead: data => dashboard.brightVal = parseInt(data) || 100 }
    }
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p"]
        stdout: SplitParser { onRead: data => uptimeText.text = data.trim() }
    }
}
