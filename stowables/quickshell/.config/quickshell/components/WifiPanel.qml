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
                StyledText {
                    text: "󰤨"
                    color: Theme.color5
                    font.pixelSize: 22
                }
                StyledText {
                    text: "Wi-Fi"
                    color: Theme.color5
                    font.pixelSize: 16
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                ToggleSwitch {
                    checked: root.wifiEnabled
                    onToggled: wifiToggleProc.running = true
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 12
                visible: root.wifiCurrentSSID !== ""
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    StyledText {
                        text: root.wifiSignal > 66 ? "󰤨" : root.wifiSignal > 33 ? "󰤥" : "󰤟"
                        color: Theme.color2
                        font.pixelSize: 18
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        StyledText {
                            text: root.wifiCurrentSSID
                            color: Theme.color2
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        StyledText {
                            text: "Connected · " + root.wifiSignal + "%"
                            color: Theme.color8
                            font.pixelSize: 10
                        }
                    }
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: wifiDiscMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        StyledText {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: Theme.color1
                            font.pixelSize: 12
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

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 10
                visible: root.wifiPasswordSSID !== ""
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8
                    StyledText {
                        text: "󰌾"
                        color: Theme.color8
                        font.pixelSize: 12
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
                        StyledText {
                            anchors.centerIn: parent
                            text: "→"
                            color: Theme.background
                            font.pixelSize: 11
                            font.bold: true
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
                StyledText {
                    text: "Available Networks"
                    color: Theme.color8
                    font.pixelSize: 11
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 24
                    height: 24
                    radius: 6
                    color: wifiRefreshMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                    StyledText {
                        anchors.centerIn: parent
                        text: root.wifiScanning ? "󰑓" : "󰑐"
                        color: Theme.color8
                        font.pixelSize: 12
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

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                            StyledText {
                                text: modelData.signal > 66 ? "󰤨" : modelData.signal > 33 ? "󰤥" : "󰤟"
                                color: Theme.color5
                                font.pixelSize: 16
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                StyledText {
                                    text: modelData.ssid
                                    color: Theme.foreground
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                StyledText {
                                    text: (modelData.security !== "" && modelData.security !== "--" ? "󰌾 " + modelData.security : "Open") + " · " + modelData.signal + "%"
                                    color: Theme.color8
                                    font.pixelSize: 9
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
                StyledText {
                    anchors.centerIn: parent
                    visible: root.wifiNetworks.length === 0 && !root.wifiScanning
                    text: root.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                    color: Theme.color8
                    font.pixelSize: 12
                }
                StyledText {
                    anchors.centerIn: parent
                    visible: root.wifiScanning
                    text: "Scanning..."
                    color: Theme.color8
                    font.pixelSize: 12
                }
            }
        }
    }
}