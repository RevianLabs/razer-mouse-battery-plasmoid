import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    property var batteryLevelTxt: "ERR" // Variable used for holding the text to display in the widget
    property double batteryLevel: 0 // State variable, used for storing battery level
    property double queryResponse: 0 // State variable, used for storing raw battery level read from the charge_level file
    property double queryResponseChargeStatus: 0 // State variable, used for storing raw battery level read from the charge_status file
    property string chargeLevelPath: "" // Path to file which stores the battery information
    property string chargeStatusPath: "" // Path to file which stores the charge status

    // The main UI component, shows simple text
    fullRepresentation: PlasmaComponents.Label {
        id: output
        text: root.batteryLevelTxt
        fontSizeMode: Text.Fit
        font.pixelSize: 1000
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: plasmoid.configuration.bold
        color:  {
            if (root.batteryLevel <= plasmoid.configuration.lowBatteryThreshold) {
                return plasmoid.configuration.lowBatteryColor
            } else if (root.batteryLevel <= plasmoid.configuration.mediumBatteryThreshold) {
                return plasmoid.configuration.mediumBatteryColor
            } else {
                return plasmoid.configuration.highBatteryColor
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (errorDialog.errorMessage.length > 0) {
                    errorDialog.open()
                }
            }
        }
    }

    Component.onCompleted: {
        // Initialize the charge level path
        initDevicePath();
    }

    // Error dialog component
    PlasmaComponents.Dialog {
        id: errorDialog
        title: "Error"
        property string errorMessage: ""

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: errorDialog.errorMessage
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight

                PlasmaComponents.Button {
                    text: "OK"
                    onClicked: errorDialog.close()
                }
            }
        }
    }

    Plasma5Support.DataSource {
        id: batterySource
        engine: "executable"
        connectedSources: []
        onNewData: function (source, data) {
            // Check for error conditions
            if (data["stderr"] && data["stderr"].length > 0) {
                handleError(data, source)
                return;
            }

            // when a command is executed, store the output of the command into stdout variable.
            // gets response from stdout and stores it in queryResponse variable.
            const stdout = data["stdout"].trim();
            disconnectSource(source); // refresh DataSource
            if (source.indexOf('basename') !== -1) {
                // Response to the device path query
                if (stdout) {
                    root.chargeLevelPath = "/sys/bus/hid/drivers/razermouse/" + stdout + "/charge_level";
                    root.chargeStatusPath = "/sys/bus/hid/drivers/razermouse/" + stdout + "/charge_status";
                    update(); // Initial update after setting the path
                }
            } else {
                // Response to the query
                root.queryResponse = stdout;
            }
        }

        function exec(cmd) {
            batterySource.connectSource(cmd);
        }
    }

    Plasma5Support.DataSource {
        id: chargeStatusSource
        engine: "executable"
        connectedSources: []
        onNewData: function (source, data) {
            // Check for error conditions
            if (data["stderr"] && data["stderr"].length > 0) {
                handleError(data, source)
                return;
            }

            // when a command is executed, store the output of the command into stdout variable.
            // gets response from stdout and stores it in queryResponseChargeStatus variable.
            const stdout = data["stdout"].trim();
            disconnectSource(source); // refresh DataSource

            root.queryResponseChargeStatus = stdout;
        }

        function exec(cmd) {
            chargeStatusSource.connectSource(cmd);
        }
    }

    function update() {
        // Recalculate and update the UI
        batterySource.exec('cat ' + root.chargeLevelPath);
        if (isNaN(root.queryResponse)) {
            root.batteryLevelTxt = "NaN";
        } else {
            root.batteryLevel = Math.round((root.queryResponse / 255) * 100);
            root.batteryLevelTxt = root.batteryLevel + '%';

            console.log(chargeLevelPath)
            console.log(chargeStatusPath)
            console.log(batteryLevel)
            chargeStatusSource.exec('cat ' + root.chargeStatusPath);
            if (!isNaN(root.queryResponseChargeStatus) && root.queryResponseChargeStatus === 1) {
                root.batteryLevelTxt = '🔋' + root.batteryLevelTxt;
            }
        }
    }

    function initDevicePath() {
        batterySource.exec('for dir in /sys/bus/hid/drivers/razermouse/*/; do ' +
            'if [ -f "${dir}device_type" ] && [ -f "${dir}charge_level" ]; then ' +
            'if grep -q "^Razer" "${dir}device_type"; then ' +
            '  if [ -f "${dir}charge_status" ] && [ "$(cat ${dir}charge_status)" = "1" ]; then ' +
            '    basename "$dir"; ' +
            '    exit 0; ' +
            '  else ' +
            '    FALLBACK_DIR="$dir"; ' +
            '  fi; ' +
            'fi; ' +
            'fi; ' +
            'done; ' +
            'if [ -n "$FALLBACK_DIR" ]; then ' +
            '  basename "$FALLBACK_DIR"; ' +
            'fi');

    }

    function handleError(data, source) {
        console.log("Error from source:", source);
        console.log("Error message:", data["stderr"]);

        // Indicate that there's an error
        root.batteryLevelTxt = "ERR";

        let errorMsg = "";

        if (data["stderr"].indexOf("No such file or directory") !== -1) {
            errorMsg = "The required file could not be found. This might mean the Razer device is not connected or the OpenRazer drivers are not installed properly.";
            initDevicePath();
        } else if (data["stderr"].indexOf("Permission denied") !== -1) {
            errorMsg = "Permission denied when accessing device files. You may need to adjust file permissions or run with elevated privileges.";
        } else {
            errorMsg = "An unknown error occurred: " + data["stderr"];
        }

        // Set the error message in the dialog
        errorDialog.errorMessage = errorMsg;

        // Don't show the dialog. It will pop up when the user clicks on the errored applet
    }


    Timer {
        // Repeating trigger which calls the update function
        interval: plasmoid.configuration.delay * 1000
        repeat: true
        running: true
        onTriggered: update()
    }

    Timer {
        // OS startup initialization run
        interval: 1000 // 1s interval
        property int counter: 0
        repeat: true
        running: true
        onTriggered: {
            counter++
            if (counter >= 10) {
                stop()
                counter = 0
            }
            update()
        }
    }
}
