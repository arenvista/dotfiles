import Quickshell
import "../Common"
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: wifiPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: 40; right: root.wifiVisible ? 6 : -350 }
    height: 420
    implicitWidth: 320
    color: "transparent"
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.background, 0.7)
        radius: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰤨"
                    color: Theme.color5
                    font.pixelSize: 22
                    font.family: Theme.fontFamily
                }
                Text {
                    text: "Wi-Fi"
                    color: Theme.color5
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Theme.fontFamily
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: root.wifiEnabled ? Theme.color5 : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        y: 2
                        x: root.wifiEnabled ? 22 : 2
                        color: Theme.background
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wifiToggleProc.running = true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 12
                color: Qt.rgba(0, 0, 0, 0.3)
                visible: root.wifiCurrentSSID !== ""
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    Text {
                        text: root.wifiSignal > 66 ? "󰤨" : root.wifiSignal > 33 ? "󰤥" : "󰤟"
                        color: Theme.color2
                        font.pixelSize: 18
                        font.family: Theme.fontFamily
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: root.wifiCurrentSSID
                            color: Theme.color2
                            font.pixelSize: 13
                            font.bold: true
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "Connected · " + root.wifiSignal + "%"
                            color: Theme.color8
                            font.pixelSize: 10
                            font.family: Theme.fontFamily
                        }
                    }
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: wifiDiscMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: Theme.color1
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                        }
                        MouseArea {
                            id: wifiDiscMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wifiDisconnectProc.running = true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.3)
                visible: root.wifiPasswordSSID !== ""
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8
                    Text {
                        text: "󰌾"
                        color: Theme.color8
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                    }
                    TextInput {
                        id: wifiPassInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.foreground
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        clip: true
                        Text {
                            text: "Password for " + root.wifiPasswordSSID
                            color: Theme.color8
                            visible: !parent.text
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font: parent.font
                        }
                        Keys.onReturnPressed: {
                            if (wifiPassInput.text.length > 0) {
                                root.wifiConnecting = true
                                wifiConnectProc.ssid = root.wifiPasswordSSID
                                wifiConnectProc.password = wifiPassInput.text
                                wifiConnectProc.running = true
                                wifiPassInput.text = ""
                            }
                        }
                        Keys.onEscapePressed: {
                            root.wifiPasswordSSID = ""
                            wifiPassInput.text = ""
                        }
                    }
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: Theme.color5
                        Text {
                            anchors.centerIn: parent
                            text: "→"
                            color: Theme.background
                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontFamily
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (wifiPassInput.text.length > 0) {
                                    root.wifiConnecting = true
                                    wifiConnectProc.ssid = root.wifiPasswordSSID
                                    wifiConnectProc.password = wifiPassInput.text
                                    wifiConnectProc.running = true
                                    wifiPassInput.text = ""
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.wifiEnabled
                Text {
                    text: "Available Networks"
                    color: Theme.color8
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 24
                    height: 24
                    radius: 6
                    color: wifiRefreshMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: root.wifiScanning ? "󰑓" : "󰑐"
                        color: Theme.color8
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        id: wifiRefreshMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!root.wifiScanning) root.refreshWifi()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0, 0, 0, 0.3)
                radius: 12
                clip: true
                ListView {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.wifiNetworks
                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 44
                        radius: 10
                        color: wifiNetMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text {
                                text: modelData.signal > 66 ? "󰤨" : modelData.signal > 33 ? "󰤥" : "󰤟"
                                color: Theme.color5
                                font.pixelSize: 16
                                font.family: Theme.fontFamily
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: modelData.ssid
                                    color: Theme.foreground
                                    font.pixelSize: 12
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: (modelData.security !== "" && modelData.security !== "--" ? "󰌾 " + modelData.security : "Open") + " · " + modelData.signal + "%"
                                    color: Theme.color8
                                    font.pixelSize: 9
                                    font.family: Theme.fontFamily
                                }
                            }
                        }
                        MouseArea {
                            id: wifiNetMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.security !== "" && modelData.security !== "--") {
                                    root.wifiPasswordSSID = modelData.ssid
                                    wifiPassInput.forceActiveFocus()
                                } else {
                                    root.wifiConnecting = true
                                    wifiConnectProc.ssid = modelData.ssid
                                    wifiConnectProc.password = ""
                                    wifiConnectProc.running = true
                                }
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.wifiNetworks.length === 0 && !root.wifiScanning
                    text: root.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                    color: Theme.color8
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.wifiScanning
                    text: "Scanning..."
                    color: Theme.color8
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }
            }
        }
    }
}