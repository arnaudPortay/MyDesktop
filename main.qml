import QtQuick 2.12
import Qt.labs.platform 1.1

SystemTrayIcon {
    id: root

    visible: true
    icon.source: "qrc:/img/monitor.svg"
    tooltip: qsTr("Double click to open window\nRight click to show menu") + translator.emptyString

    menu: Menu {
        id: menu

        MenuItem {
            id: showItem
            text: qsTr("Show") + translator.emptyString
            onTriggered: showWindow()
        }
        MenuSeparator {}

        Instantiator {
            model: window.desktopItemsNames

            MenuItem {
                text: "" + model.modelData

                onTriggered: {
                    window.openExternally(index)
                }
            }

            //The trick is on those two lines
            onObjectAdded: menu.insertItem(index + 2, object)
            onObjectRemoved: menu.removeItem(object)
        }

        MenuSeparator {}
        MenuItem {
            text: qsTr("Exit") + translator.emptyString
            onTriggered: {
                window.updateCurrentTabIndexSetting()
                Qt.quit()
            }
        }

    }


    onActivated: {
        // handle double click
        if (reason == SystemTrayIcon.DoubleClick) {
            showWindow()
        }
        // handle simple click
        else if (reason == SystemTrayIcon.Trigger) {

            // I wanted to show the menu on simple click, but could not do it.
            // My experiments below.

            // Does not work...
            // menu.visible = true

            // Desperate attempt...
            // root.activated(SystemTrayIcon.Context);

            // This call crashes
            // root.menu.open(root, null)
        }
    }

    function showWindow() {
        window.show()
        window.raise()
        window.requestActivate()
    }

    property MainWindow window: MainWindow {
    }
}
