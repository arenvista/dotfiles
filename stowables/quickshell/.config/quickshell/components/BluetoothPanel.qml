import Quickshell
import "../Common"
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: btPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: 40; right: root.btVisible ? 6 : -350 }
    height: 460
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
                    text: "󰂯"
                    color: Theme.color5
                    font.pixelSize: 22
                }
                StyledText {
                    text: "Bluetooth"
                    color: Theme.color5
                    font.pixelSize: 16
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                ToggleSwitch {
                    checked: root.btEnabled
                    onToggled: {
                        if (root.btEnabled)
                            btToggleOffProc.running = true
                        else
                            btToggleOnProc.running = true
                    }
                }
            }

            StyledText {
                text: "Paired Devices"
                color: Theme.color8
                font.pixelSize: 11
                visible: root.btEnabled
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                radius: 12
                clip: true
                visible: root.btEnabled
                ListView {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.btPairedDevices
                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 48
                        radius: 10
                        color: btPairedMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            StyledText {
                                text: modelData.connected ? "󰂱" : "󰂲"
                                color: modelData.connected ? Theme.color2 : Theme.color8
                                font.pixelSize: 18
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                StyledText {
                                    text: modelData.name
                                    color: modelData.connected ? Theme.color2 : Theme.foreground
                                    font.pixelSize: 12
                                    font.bold: modelData.connected
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: {
                                        if (root.btConnectingMAC === modelData.mac) return "Connecting..."
                                        if (modelData.connected) return "Connected"
                                        return "Paired"
                                    }
                                    color: Theme.color8
                                    font.pixelSize: 9
                                    font.family: Theme.fontFamily
                                }
                            }
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 8
                                color: btConnBtnMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                StyledText {
                                    anchors.centerIn: parent
                                    text: modelData.connected ? "󰅖" : "󰐕"
                                    color: modelData.connected ? Theme.color1 : Theme.color5
                                    font.pixelSize: 12
                                }
                                MouseArea {
                                    id: btConnBtnMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.connected)
                                            root.disconnectBt(modelData.mac)
                                        else
                                            root.connectBt(modelData.mac)
                                    }
                                }
                            }
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 8
                                color: btForgetMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                StyledText {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    color: Theme.color8
                                    font.pixelSize: 12
                                }
                                MouseArea {
                                    id: btForgetMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.forgetBt(modelData.mac)
                                }
                            }
                        }
                        MouseArea {
                            id: btPairedMa
                            anchors.fill: parent
                            hoverEnabled: true
                            z: -1
                            onClicked: {
                                if (modelData.connected)
                                    root.disconnectBt(modelData.mac)
                                else
                                    root.connectBt(modelData.mac)
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                }
                StyledText {
                    anchors.centerIn: parent
                    visible: root.btPairedDevices.length === 0
                    text: "No paired devices"
                    color: Theme.color8
                    font.pixelSize: 12
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.btEnabled
                StyledText {
                    text: "Available Devices"
                    color: Theme.color8
                    font.pixelSize: 11
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 60
                    height: 24
                    radius: 6
                    color: btScanBtnMa.containsMouse ? Theme.alpha(Theme.color5, 0.2) : Qt.rgba(0, 0, 0, 0.3)
                    StyledText {
                        anchors.centerIn: parent
                        text: root.btScanning ? "Scanning" : "Scan"
                        color: Theme.color5
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: btScanBtnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!root.btScanning) {
                                root.btScanning = true
                                root.btAvailableDevices = []
                                btScanProc.running = true
                            }
                        }
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                clip: true
                visible: root.btEnabled
                ListView {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.btAvailableDevices
                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 44
                        radius: 10
                        color: btAvailMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            StyledText {
                                text: "󰂲"
                                color: Theme.color8
                                font.pixelSize: 16
                            }
                            StyledText {
                                text: modelData.name
                                color: Theme.foreground
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            StyledText {
                                visible: root.btConnectingMAC === modelData.mac
                                text: "..."
                                color: Theme.color8
                                font.pixelSize: 12
                            }
                        }
                        MouseArea {
                            id: btAvailMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.pairBt(modelData.mac)
                        }
                    }
                    ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                }
                StyledText {
                    anchors.centerIn: parent
                    visible: root.btAvailableDevices.length === 0 && !root.btScanning
                    text: "Press Scan to find devices"
                    color: Theme.color8
                    font.pixelSize: 11
                }
                StyledText {
                    anchors.centerIn: parent
                    visible: root.btScanning
                    text: "Scanning..."
                    color: Theme.color8
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !root.btEnabled
                color: "transparent"
                StyledText {
                    anchors.centerIn: parent
                    text: "Bluetooth is off"
                    color: Theme.color8
                    font.pixelSize: 13
                }
            }
        }
    }
}
