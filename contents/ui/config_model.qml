import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils

SimpleKCM {
    id: configItem
    property alias cfg_bold: bold.checked
    property alias cfg_lowBatteryThreshold: lowBatteryThreshold.value
    property alias cfg_mediumBatteryThreshold: mediumBatteryThreshold.value
    property alias cfg_lowBatteryColor: lowBatteryColor.text
    property alias cfg_mediumBatteryColor: mediumBatteryColor.text
    property alias cfg_highBatteryColor: highBatteryColor.text

    ColorDialog {
        id: lowColorDialog
        title: "Choose Low Battery Color"
        onAccepted: lowBatteryColor.text = selectedColor
    }

    ColorDialog {
        id: mediumColorDialog
        title: "Choose Medium Battery Color"
        onAccepted: mediumBatteryColor.text = selectedColor
    }

    ColorDialog {
        id: highColorDialog
        title: "Choose High Battery Color"
        onAccepted: highBatteryColor.text = selectedColor
    }


    Kirigami.FormLayout {
        Controls.CheckBox {
            id: bold
            text: "Use Bold Text"
            LayoutMirroring.enabled: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Controls.SpinBox {
            id: delay

            from: decimalToInt(0.1)
            value: decimalToInt(300.0)
            to: decimalToInt(3600)
            stepSize: decimalToInt(0.1)
            editable: true
            Kirigami.FormData.label: "Update Delay"
            hoverEnabled: true

            property int decimals: 1
            property real realValue: value / decimalFactor
            readonly property int decimalFactor: Math.pow(10, decimals)

            function decimalToInt(decimal) {
                return decimal * decimalFactor;
            }

            validator: DoubleValidator {
                bottom: Math.min(delay.from, delay.to)
                top: Math.max(delay.from, delay.to)
                decimals: delay.decimals
                notation: DoubleValidator.StandardNotation
            }

            textFromValue: function (value, locale) {
                return Number(value / decimalFactor).toLocaleString(locale, 'f', delay.decimals);
            }

            valueFromText: function (text, locale) {
                return Math.round(Number.fromLocaleString(locale, text) * decimalFactor);
            }
        }

        // Battery threshold settings
        Controls.SpinBox {
            id: lowBatteryThreshold
            from: 0
            to: mediumBatteryThreshold.value - 1
            value: 20
            Kirigami.FormData.label: "Low Battery Threshold (%)"
        }

        Controls.SpinBox {
            id: mediumBatteryThreshold
            from: lowBatteryThreshold.value + 1
            to: 100
            value: 50
            Kirigami.FormData.label: "Medium Battery Threshold (%)"
        }

        RowLayout {
            Kirigami.FormData.label: "Low Battery Color"
            Controls.TextField {
                id: lowBatteryColor
                placeholderText: "#ff0000"
                text: "#ff0000"
                Layout.preferredWidth: 100
            }
            Rectangle {
                width: 32
                height: 32
                color: lowBatteryColor.text
                border.width: 1
                border.color: "black"
                MouseArea {
                    anchors.fill: parent
                    onClicked: lowColorDialog.open()
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: "Medium Battery Color"
            Controls.TextField {
                id: mediumBatteryColor
                placeholderText: "#ffa500"
                text: "#ffa500"
                Layout.preferredWidth: 100
            }
            Rectangle {
                width: 32
                height: 32
                color: mediumBatteryColor.text
                border.width: 1
                border.color: "black"
                MouseArea {
                    anchors.fill: parent
                    onClicked: mediumColorDialog.open()
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: "High Battery Color"
            Controls.TextField {
                id: highBatteryColor
                placeholderText: "#ffffff"
                text: "#ffffff"
                Layout.preferredWidth: 100
            }
            Rectangle {
                width: 32
                height: 32
                color: highBatteryColor.text
                border.width: 1
                border.color: "black"
                MouseArea {
                    anchors.fill: parent
                    onClicked: highColorDialog.open()
                }
            }
        }
    }
}