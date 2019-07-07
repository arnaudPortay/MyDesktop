import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Window 2.12
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.2
import Apy.file.utilies 1.0
import Qt.labs.platform 1.1 as Labs
import Apy.clipboard 1.0

ApplicationWindow {
    id: root
    visible: false
    width: 640
    height: 480
    title: qsTr("My Desktop") + translator.emptyString
    
    Material.theme: darkTheme ? Material.Dark : Material.Light
    Material.accent: Material.Cyan
    

    // *************************************   MENU BAR ******************************************
    menuBar: MenuBar {
        
        id: myMenuBar
        
        background: Rectangle{
            width: parent.width
            color: Material.background
            height: myMenuBar.height
        }
        
        Menu {
            title: qsTr("&Actions") + translator.emptyString
            Material.elevation: 20
            
            Action {
                text: qsTr("&Launch selected item")+ translator.emptyString
                shortcut: "Return"
                onTriggered:{
                    if (!root.renaming && desktopList.visible && !filterTextField.focus && !dialogVisible)
                    {
                        openExternallyCurrentItem()
                    }
                }
            }
            
            Action {
                text: qsTr("&Open location") + translator.emptyString
                onTriggered: {
                    if (!root.renaming && desktopList.visible && !dialogVisible)
                    {
                        if (desktopItemsModel.get(mapToGlobalIndex(desktopList.currentIndex)).exists)
                        {
                            Qt.openUrlExternally(File.getDir(root.desktopItems[desktopList.currentIndex]))
                        }
                    }
                }
                shortcut: "Ctrl+O"
            }
            
            MenuSeparator{}
            
            Action {
                text: qsTr("&Quit") + translator.emptyString
                onTriggered: {
                    updateCurrentTabIndexSetting()
                    Qt.quit()
                }
                shortcut: "Ctrl+Q"
            }
        }
        
        Menu {
            title: qsTr("&Edit") + translator.emptyString

            Menu {
                title: qsTr("&Item") + translator.emptyString

                Action {
                    id: renameItemAction
                    text: qsTr("&Rename item") + translator.emptyString
                    onTriggered: {
                        if (desktopList.visible && !dialogVisible)
                        {
                            root.renaming = true
                        }
                    }
                }

                Action {
                    id: deleteItemAction
                    text: qsTr("&Delete item") + translator.emptyString
                    onTriggered: {
                        if (desktopList.visible && desktopList.currentIndex >= 0 && desktopList.currentIndex < desktopList.count && !dialogVisible)
                        {
                            root.renaming = false

                            if (tabBar.currentIndex === 0)
                            {
                                deleteItemAt(desktopList.currentIndex)
                            }
                            else
                            {
                                switch (deletionBehaviour)
                                {
                                case 0:
                                    deleteBehaviorDialog.index = desktopList.currentIndex
                                    deleteBehaviorDialog.tabIndex = tabBar.currentIndex-1
                                    deleteBehaviorDialog.open()
                                    break
                                case 1:
                                    deleteItemFromTab(tabBar.currentIndex-1, desktopList.currentIndex)
                                    break
                                case 2:
                                    deleteItemAt(desktopList.currentIndex)
                                    break
                                default:
                                    break
                                }
                            }
                        }
                    }
                }

                MenuSeparator{}

                Action {
                    text: qsTr("&Move item up") + translator.emptyString
                    enabled: desktopList.currentIndex != 0 && desktopList.count != 0
                    onTriggered: {
                        if ( desktopList.visible && !root.renaming && !dialogVisible)
                        {
                            desktopList.currentIndex = moveUrl(true, desktopList.currentIndex)
                        }
                    }
                }

                Action {
                    text: qsTr("&Move item down") + translator.emptyString
                    enabled: desktopList.currentIndex != desktopList.count - 1
                    onTriggered: {
                        if ( desktopList.visible && !root.renaming && !dialogVisible)
                        {
                            desktopList.currentIndex = moveUrl(false, desktopList.currentIndex)
                        }
                    }
                }
            }

            Menu {
                title: qsTr("&Tab") + translator.emptyString

                Action {
                    id: renameTabAction
                    text: qsTr("&Rename custom tab") + translator.emptyString
                    onTriggered: {
                        if (tabBar.currentIndex !== 0 && desktopList.visible && !dialogVisible)
                        {
                            renameTabDialog.open()
                        }
                    }
                    enabled: tabBar.currentIndex !== 0
                }

                Action {
                    id: deleteTabAction
                    text: qsTr("&Delete custom tab") + translator.emptyString
                    onTriggered: {
                        if (tabBar.currentIndex !== 0 && desktopList.visible && !dialogVisible)
                        {
                            renaming = false
                            deleteTab(tabBar.currentIndex)
                        }
                    }
                    enabled: tabBar.currentIndex !== 0
                }

                Action {
                    id: addTabAction
                    text: qsTr("&Add custom tab") + translator.emptyString
                    onTriggered: {
                        renaming = false
                        addTabBar()
                    }
                }

                MenuSeparator{}

                Action {
                    text: qsTr("&Move tab left") + translator.emptyString
                    enabled: tabBar.currentIndex > 1
                    onTriggered: {
                        if ( desktopList.visible && !root.renaming)
                        {
                            renaming = false
                            tabBar.currentIndex = moveTabBar(true, tabBar.currentIndex)
                        }
                    }
                }

                Action {
                    text: qsTr("&Move tab right") + translator.emptyString
                    enabled: tabBar.currentIndex != tabBar.count - 1 && tabBar.currentIndex != 0
                    onTriggered: {
                        if ( desktopList.visible && !root.renaming)
                        {
                            renaming = false
                            tabBar.currentIndex = moveTabBar(false, tabBar.currentIndex)
                        }
                    }
                }
            }

            MenuSeparator{}
            
            Action {
                text: qsTr("&Refresh") + translator.emptyString
                onTriggered: {
                    if (desktopList.visible)
                    {
                        root.renaming = false
                        refreshModel()
                    }
                }
                shortcut: StandardKey.Refresh
            }
        }
        
        Menu {
            title: qsTr("&?")
            
            Action{
                text: qsTr("&Use dark theme") + translator.emptyString
                checkable: true
                checked: root.darkTheme
                onTriggered: {
                    root.darkTheme = !root.darkTheme
                }
                shortcut: "Shift+T"
            }
            
            Menu{
                title: qsTr("&Language") + translator.emptyString
                Action {
                    text: "Français"
                    checkable: true
                    checked: root.language === "fr"
                    enabled: root.language !== "fr"
                    onTriggered: {
                        root.language = "fr"
                    }
                }
                
                Action {
                    text: "English"
                    checkable: true
                    checked: root.language === "en"
                    enabled: root.language !== "en"
                    onTriggered: {
                        root.language = "en"
                    }
                }
            }

            Menu {
                title: qsTr("&Deletion behavior") + translator.emptyString

                Action{
                    text: qsTr("&Always ask") + translator.emptyString
                    checkable: true
                    checked: root.deletionBehaviour === 0
                    enabled: root.deletionBehaviour !== 0
                    onTriggered: {
                        root.deletionBehaviour = 0
                    }
                }

                Action{
                    text: qsTr("&Delete from tab") + translator.emptyString
                    checkable: true
                    checked: root.deletionBehaviour === 1
                    enabled: root.deletionBehaviour !== 1
                    onTriggered: {
                        root.deletionBehaviour = 1
                    }
                }

                Action{
                    text: qsTr("&Permanently delete") + translator.emptyString
                    checkable: true
                    checked: root.deletionBehaviour === 2
                    enabled: root.deletionBehaviour !== 2
                    onTriggered: {
                        root.deletionBehaviour = 2
                    }
                }
            }
            
            Action {
                text: qsTr("&Launch at startup") + translator.emptyString
                checkable: true
                checked: File.isLaunchingAtStartup()
                onTriggered: {
                    if (Qt.platform.os === "windows")
                    {
                        File.toggleLaunchAtStartup();
                    }
                    else
                    {
                        notSupportedDialog.open()
                    }
                }
            }
            Action {
                text: qsTr("&Show window at app startup") + translator.emptyString
                checkable: true
                checked: settings.showWindowAtStartup
                onTriggered: {
                    settings.showWindowAtStartup = !settings.showWindowAtStartup
                }
            }
            
            MenuSeparator {}
            
            Action{
                text: qsTr("&Help") + translator.emptyString
                shortcut: "Ctrl+H"
                onTriggered: {
                    if (!dialogVisible)
                    {
                        desktopList.visible = false
                        tabBar.visible = false
                        addTabButton.visible = false
                        helpRect.visible = true
                    }
                }
            }
            
            MenuSeparator {}
            
            Action {
                text: qsTr("About") + translator.emptyString
                onTriggered: {
                    aboutDialog.open()
                }
            }
        }
    }
    
    Component.onCompleted: {
        refreshTabs()
        tabBar.currentIndex = settings.currentTab

        refreshModel()
        desktopList.currentIndex = 0

        root.visible = settings.showWindowAtStartup

    }
    onClosing: {
        root.visible = false
        close.accepted = false
        updateCurrentTabIndexSetting()
    }
    
    property var desktopItems: []
    property var desktopItemsNames: []
    property var customTabs: []
    property bool renaming: false
    property bool darkTheme: true
    property string language: "en"
    onLanguageChanged: {
        translator.selectLanguage(language)
    }
    property bool keepLink: false
    property bool moving: false
    // Array of array with the first array being the tabs and the inner array being as big as their number of items
    // with the value being the global index in the model (ie in desktopItems and desktopItemsNames ) for customTabs
    property var localToGlobalIndexMatrix: []
    property int deletionBehaviour: 0
    property bool dialogVisible: deleteBehaviorDialog.visible || notSupportedDialog.visible || aboutDialog.visible
    
    // *************************************   SETTINGS ******************************************
    Settings {
        id: settings
        
        // Logic state
        property alias desktopItems: root.desktopItems
        property alias desktopItemsNames: root.desktopItemsNames
        property alias customTabs: root.customTabs
        // Current filter
        property alias currentFilter: filterTextField.text
        //current Tab
        property int currentTab
        //Deletion behaviour
        property alias deletionBehaviour: root.deletionBehaviour
        
        // Window position and size
        property alias windowX: root.x
        property alias windowY: root.y
        property alias windowWidth: root.width
        property alias windowHeight: root.height
        
        // Theme
        property alias darkTheme: root.darkTheme
        
        // Language
        property alias language: root.language

        // Window visibility at application startup
        property bool showWindowAtStartup: true;

        // Tabs to global correspondance matrix for customTabs ONLY
        property alias localToGlobalIndexMatrix: root.localToGlobalIndexMatrix

    }
    
    // *************************************   BASE RECTANGLE ******************************************
    Rectangle{
        id: baseRectangle
        anchors.fill: parent

        color: Material.background

        Shortcut {
            sequences: [StandardKey.Paste, "Ctrl+Shift+V"]
            onActivated: {
                if (desktopList.visible && Clipboard.getUrls().length > 0 && !dialogVisible)
                {
                    addUrls(Clipboard.getUrls())
                }
            }
        }

        Shortcut {
            sequences: ["F2"]
            onActivated: {
                renameItemAction.trigger()
            }
        }

        Shortcut {
            sequences: [StandardKey.Delete]
            onActivated:{
                deleteItemAction.trigger()
            }
        }

        Shortcut{
            sequences: ["Shift+F2"]
            onActivated: {
                renameTabAction.trigger()
            }
        }

        Shortcut{
            sequences: ["Ctrl+W"]
            onActivated: {
                deleteTabAction.trigger()
            }
        }

        Shortcut{
            sequences: ["Ctrl+T"]
            onActivated: {
                addTabAction.trigger()
            }
        }
        
        DropArea{
            id: globalDropArea
            anchors.fill: desktopList
            
            onEntered: {
                if (!drag.hasUrls)
                {
                    drag.accepted = false
                }
            }
            
            onDropped: {
                if (desktopList.visible)
                {
                    addUrls(drop.urls)
                }
            }
        }
        

        TabBar {
            id: tabBar
            anchors.top: parent.top
            width: parent.width - addTabButton.width
            x:parent.x
            clip: true
            onCurrentIndexChanged: {
                refreshModel()
                desktopList.forceActiveFocus()
                desktopList.currentIndex = 0
            }

            Component {
                id: tabButton
                TabButton {
                    text: qsTr("New Tab") + translator.emptyString
                    width: implicitWidth + 20
                    font.pointSize: 10

                    onDoubleClicked: {
                        renameTabDialog.open()
                    }

                    DropArea{
                        id: tabDropArea
                        anchors.fill: parent
                        keys: ["myDesktop/item"]
                        onEntered: {
                            if (tabBar.currentIndex === parent.TabBar.index)
                            {
                                drag.accepted = false;
                            }
                        }

                        onDropped: {
                            var globalIndex = (tabBar.currentIndex === 0) ? parseInt(drop.getDataAsString("myDesktop/item"), 10) :
                                                                            mapToGlobalIndex(parseInt(drop.getDataAsString("myDesktop/item"), 10))

                            var matrix = root.localToGlobalIndexMatrix.slice()
                            matrix[parent.TabBar.index-1].push(globalIndex)
                            root.localToGlobalIndexMatrix = matrix
                            if (tabBar.currentIndex !== 0 && drop.action === Qt.MoveAction)
                            {
                                deleteItemFromTab(tabBar.currentIndex - 1, parseInt(drop.getDataAsString("myDesktop/item"), 10))
                            }

                            refreshModel()
                        }
                    }
                }
            }

            TabButton{
                text:  qsTr("All") + translator.emptyString
                width: implicitWidth + 20
                font.pointSize: 10
            }
        }

        Button{
            id:addTabButton
            anchors.right: parent.right
            anchors.top: parent.top

            contentItem : Text
            {
                id: addText
                text: "+"
                anchors.fill: parent
                color: addTabButton.hovered ? Material.accent : Material.foreground
                font.bold: true
                font.pointSize: 10
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
            }

            onClicked: {
                addTabBar()
            }
        }


        TextField {
            id: filterTextField

            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: parent.width * 0.2
            anchors.rightMargin: parent.width * 0.2
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            placeholderText: qsTr("Search...") + translator.emptyString
            selectByMouse: true
            visible: desktopList.visible && desktopList.count > 0
            color: root.moving ? "red" : Material.foreground

            ToolTip.text: qsTr("You cannot move items while search bar is not empty") + translator.emptyString
            ToolTip.visible: root.moving && text !== ""


            onFocusChanged: {
                if (focus)
                    renaming = false
            }

            Shortcut {
                sequence: "Ctrl+F"
                onActivated: {
                    filterTextField.focus = true
                }
            }

            Keys.onShortcutOverride: {
                event.accepted = (event.key === Qt.Key_Return)
            }

            onAccepted: {
                desktopList.focus = true

                if (!desktopList.currentItem.visible)
                {
                    desktopList.currentIndex = 0
                }

                if (!desktopList.currentItem.visible)
                {
                    do
                    {
                        desktopList.incrementCurrentIndex()
                    }
                    while (!desktopList.currentItem.visible && desktopList.currentIndex < desktopList.count - 1)
                }
            }
            Keys.onEscapePressed: {
                text = ""
                desktopList.focus = true
            }
        }

        // *************************************   LIST PAGE ******************************************
        ListView{
            id: desktopList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: filterTextField.bottom

            clip: true
            focus: true
            model: desktopItemsModel

            onCurrentIndexChanged: {
                tabBar.focus = false
            }


            Keys.onLeftPressed: {
                if (event.modifiers & Qt.ControlModifier && tabBar.count > 0 && !root.renaming && !dialogVisible)
                {
                    tabBar.currentIndex = moveTabBar(true, tabBar.currentIndex)
                }
            }

            Keys.onRightPressed: {
                if (event.modifiers & Qt.ControlModifier && tabBar.count > 0 && !root.renaming && !dialogVisible)
                {
                    tabBar.currentIndex = moveTabBar(false, tabBar.currentIndex)
                }
            }

            Keys.onTabPressed: {
                if (!dialogVisible)
                    tabBar.incrementCurrentIndex()
            }

            Keys.onBacktabPressed: {
                if (!dialogVisible)
                    tabBar.decrementCurrentIndex()
            }

            Keys.onUpPressed: {

                if (event.modifiers & Qt.ControlModifier && desktopList.count > 0 && !dialogVisible)
                {
                    desktopList.currentIndex = moveUrl(true, desktopList.currentIndex)
                }
                else if (desktopList.count > 0 && !dialogVisible)
                {
                    var index = desktopList.currentIndex
                    do
                    {
                        desktopList.decrementCurrentIndex()
                    }
                    while (!desktopList.currentItem.visible && desktopList.currentIndex > 0)

                    if (desktopList.currentIndex === 0 && ! desktopList.currentItem.visible)
                    {
                        desktopList.currentIndex = index
                    }
                }
            }

            Keys.onDownPressed: {

                if (event.modifiers & Qt.ControlModifier && desktopList.count > 0 && !dialogVisible)
                {
                    desktopList.currentIndex = moveUrl(false, desktopList.currentIndex)
                }
                else if (desktopList.count > 0 && !dialogVisible)
                {
                    var index = desktopList.currentIndex
                    do
                    {
                        desktopList.incrementCurrentIndex()
                    }
                    while (!desktopList.currentItem.visible && desktopList.currentIndex < desktopList.count - 1)

                    if (desktopList.currentIndex === desktopList.count - 1 && ! desktopList.currentItem.visible)
                    {
                        desktopList.currentIndex = index
                    }
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Shift)
                {
                    root.keepLink = true;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Control && !renaming)
                {
                    root.moving = true;
                    event.accepted = true;
                }
            }

            Keys.onReleased: {
                if (event.key === Qt.Key_Shift)
                {
                    root.keepLink = false;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Control && !renaming)
                {
                    root.moving = false;
                    event.accepted = true;
                }
            }

            ScrollBar.vertical: ScrollBar {
                id: vScrollBar
                policy: desktopList.contentHeight > desktopList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            }

            delegate: ItemDelegate
            {
                id:desktopItemsDelegate

                property bool matchesFilter: {
                    return String(name).toLowerCase().includes(filterTextField.text.toLowerCase());
                }

                anchors.left: parent.left
                anchors.right: parent.right
                leftPadding: bgRect.width + 10

                height: matchesFilter ? childrenRect.height : 0
                visible: matchesFilter

                ToolTip.visible: desktopItemsDelegate.hovered
                ToolTip.delay: 2000
                ToolTip.timeout: 5000
                ToolTip.text: (""+path).replace("file:///","")

                highlighted: ListView.isCurrentItem

                focus: true

                contentItem: Item
                {
                    id: delItem

                    anchors.left: bgRect.right
                    anchors.right: parent.right
                    anchors.top:parent.top

                    MouseArea{
                        id: dragArea
                        anchors.fill: parent
                        drag.target: draggable

                        onClicked: {

                            if (!root.renaming || !desktopItemsModel.get(mapToGlobalIndex(desktopList.currentIndex)).exists)
                            {
                                root.renaming = false;
                                desktopList.currentIndex = model.index
                            }
                        }

                        onDoubleClicked: {
                            if (!root.renaming)
                            {
                                openExternally(model.index)
                            }
                        }
                    }

                    Item
                    {
                        id: draggable
                        anchors.fill: parent

                        Drag.active: dragArea.drag.active && delText.visible
                        Drag.hotSpot.x: 0
                        Drag.hotSpot.y:0
                        Drag.dragType: Drag.Automatic
                        Drag.mimeData: {"myDesktop/item" : model.index}
                    }

                    states:
                        [
                        State
                        {
                            name: "renaming"; when: root.renaming && desktopItemsDelegate.highlighted && exists

                            PropertyChanges
                            {
                                target: delItem
                                focus:true
                            }

                            PropertyChanges
                            {
                                target: delTextEdit
                                visible: true
                                focus: true
                                text: delText.text
                            }

                            // 2 steps process to have the text change first then we select it
                            PropertyChanges
                            {
                                target: delTextEdit
                                hackityHack:{
                                    selectAll()
                                    delTextEdit.forceActiveFocus()
                                    true
                                }
                            }

                            PropertyChanges
                            {
                                target: delText
                                visible: false
                            }
                        }
                    ]

                    TextEdit {
                        id: delTextEdit

                        text: ""

                        focus: false

                        anchors.left: parent.left
                        anchors.right: moveUpButton.left
                        anchors.top: parent.top
                        anchors.topMargin: (bgRect.height - height)/2
                        anchors.rightMargin: 5

                        verticalAlignment: Qt.AlignVCenter

                        font.bold: desktopItemsDelegate.highlighted
                        font.pointSize: 10

                        visible:false

                        leftPadding: 10
                        textFormat: TextEdit.PlainText

                        selectionColor: Material.accent
                        color: Material.foreground

                        selectByMouse: true
                        wrapMode: TextEdit.Wrap

                        property bool hackityHack: true

                        //Overload key pressed handlers to negate their effect
                        Keys.onUpPressed: {}

                        Keys.onDownPressed: {}

                        Keys.onReturnPressed: {
                            updateName(model.index, delTextEdit.text)
                        }

                        Keys.onEnterPressed: {
                            updateName(model.index, delTextEdit.text)
                        }

                        Keys.onEscapePressed: {root.renaming = false;}

                    }

                    Text {
                        id: delText

                        text: name

                        anchors.left: parent.left
                        anchors.right: moveUpButton.left
                        anchors.top: parent.top
                        anchors.topMargin: (bgRect.height - height)/2
                        anchors.rightMargin: 5

                        verticalAlignment: Qt.AlignVCenter

                        font.bold: desktopItemsDelegate.highlighted
                        font.strikeout: !exists
                        font.pointSize: 10

                        visible: true
                        leftPadding: 10
                        wrapMode: Text.Wrap

                        color: moving && desktopList.currentIndex === index ? Material.accent : exists ? Material.foreground : Material.color(Material.Red)
                    }

                    IconButton {
                        id: delTrashButton
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: (bgRect.height - height)/2
                        anchors.rightMargin: vScrollBar.width
                        height: 40
                        width: height
                        imageSource: "qrc:///img/trash.svg"
                        ToolTip.text: qsTr("Delete") + translator.emptyString
                        ToolTip.delay: 500

                        visible: desktopItemsDelegate.hovered

                        enabled: !renaming

                        Material.background: Material.color(Material.Red)
                        onClicked: {
                            deleteItemAt(index)
                        }
                    }

                    IconButton {
                        id: delOpenLocationButton
                        anchors.right: delTrashButton.left
                        anchors.top: parent.top
                        anchors.topMargin: (bgRect.height - height)/2
                        height: 40
                        width: height
                        imageSource: hovered ? "qrc:///img/folderOpen.svg" : "qrc:///img/folder.svg"
                        ToolTip.text: qsTr("Open location") + translator.emptyString
                        ToolTip.delay: 500

                        visible: desktopItemsDelegate.hovered

                        enabled: !renaming

                        onClicked: {
                            if (exists)
                            {
                                Qt.openUrlExternally(File.getDir(path))
                            }
                        }
                    }

                    IconButton
                    {
                        id: moveDownButton
                        anchors.right: delOpenLocationButton.left
                        anchors.top: parent.top
                        anchors.topMargin: (bgRect.height - height)/2
                        height: 40
                        width: height
                        imageSource: "qrc:///img/keyboard_arrow_down.svg"
                        ToolTip.text: qsTr("Move down") + translator.emptyString
                        ToolTip.delay: 500

                        visible: desktopItemsDelegate.hovered

                        enabled: !renaming

                        onClicked: {
                            moveUrl(false, index)
                        }
                    }

                    IconButton
                    {
                        id: moveUpButton
                        anchors.right: moveDownButton.left
                        anchors.top: parent.top
                        anchors.topMargin: (bgRect.height - height)/2
                        height: 40
                        width: height
                        imageSource: "qrc:///img/keyboard_arrow_up.svg"
                        ToolTip.text: qsTr("Move up") + translator.emptyString
                        ToolTip.delay: 500

                        visible: desktopItemsDelegate.hovered

                        enabled: !renaming

                        onClicked: {
                            moveUrl(true, index)
                        }
                    }
                }


                background: Rectangle{
                    id: bgRect
                    anchors.left: parent.left
                    width: 20
                    height: Math.max (delTrashButton.height, Math.max( delTextEdit.height, delText.height)) + 10 // Creates binding loop but oh well...
                    color: desktopItemsDelegate.highlighted ? Material.accent : Qt.darker(Material.accent)
                    visible: desktopItemsDelegate.highlighted || desktopItemsDelegate.hovered
                }
            }
        }


        // *************************************   EMPTY PAGE ******************************************
        Text
        {
            id: emptyListText

            anchors.fill: parent
            anchors.margins: 10
            text: qsTr("Drag and drop files, folders, applications, shortcuts or internet links.") + translator.emptyString
            font.family: "Segoe UI"
            visible: desktopItemsModel.count === 0 && !helpRect.visible
            font.italic: true
            font.pointSize: 14
            wrapMode: Text.Wrap
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            color: Material.color(Material.Grey)
        }


        // *************************************   HELP PAGE ******************************************
        ScrollView{
            id: helpRect
            visible: false
            anchors.fill: parent

            // disable horizontal scrolling
            contentWidth: -1
            // set proper content height
            contentHeight: helpText.contentHeight

            ScrollBar.vertical.policy: helpRect.contentHeight > helpRect.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            Text
            {
                id: helpText
                leftPadding: 10
                rightPadding: 15
                width: parent.width
                color: Material.foreground
                font.family: "Segoe UI"
                font.pointSize: 10
                text: "<h1>" + qsTr("My Desktop Help Page") + "</h1><br>" +
                      qsTr("My Desktop allows you to gather applications, files, folders and hyperlinks and to open them with their default program.")+ "<br>" +
                      qsTr("You can also open the item location in the file explorer if said file is local.")+ "<br>"+
                      qsTr("You can also paste a link to the item from the clipboard.") + "<br>" +
                      qsTr("Double-click on an item to open it with its default associated program.")+ "<br><br>" +
                      qsTr("If an item is displayed in red and is striked out, this means the item does not exist anymore.")+ "<br>" +
                      qsTr("There is a refresh button at the bottom of the window.")+ "<br><br>" +
                      qsTr("You can change the application language by clicking \"?\" then \"Language\".") + "<br><br>" +
                      qsTr("You can make this application launch automatically at startup by clicking \"?\" then \"Launch at startup\".") + "<br><br>" +
                      "<b>" + qsTr("Note: ")+"</b>"+qsTr("If you drag and drop a shortcut file onto the My Desktop window then what will be remembered is the shortcut target, not the shortcut itself, as such you can safely delete said shortcut.")+ "<br><br>" +
                      "<h2>" + qsTr("Shortcut list") + "</h2>" +
                      "<ul>" +
                      "<li><b><i>" + qsTr("Enter: ")+"</i></b>" + qsTr("open the selected item with the associated application.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + O: ")+"</i></b>" + qsTr("open the folder containing the selected item.") + "</li>"+
                      "<li><b><i>" + qsTr("Del: ")+"</i></b>" + qsTr("delete the selected item from the list.") + "</li>"+
                      "<li><b><i>" + qsTr("F2: ")+"</i></b>" + qsTr("rename the selected item. \"Enter\" to validate \"Esc\" to cancel.") + "</li>"+
                      "<li><b><i>" + qsTr("F5: ")+"</i></b>" + qsTr("refresh display.") + "</li>"+
                      "<li><b><i>" + qsTr("Shift + T: ")+"</i></b>" + qsTr("switch between light and dark theme.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + F: ")+"</i></b>" + qsTr("search shortcut.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + H: ")+"</i></b>" + qsTr("opens this help page.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + Q: ")+"</i></b>" + qsTr("closes the application.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + V: ")+"</i></b>" + qsTr("Add an item to the list by pasting from the clipboard.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + UpArrow: ")+"</i></b>" + qsTr("Move up the current item.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + DownArrow: ")+"</i></b>" + qsTr("Move down the current item.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + LeftArrow: ")+"</i></b>" + qsTr("Move left the current custom tab.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + RightArrow: ")+"</i></b>" + qsTr("Move right the current custom tab.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + W: ")+"</i></b>" + qsTr("Delete the current custom tab.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + T: ")+"</i></b>" + qsTr("Add a custom tab.") + "</li>"+
                      "<li><b><i>" + qsTr("Tab: ")+"</i></b>" + qsTr("Go to next tab.") + "</li>"+
                      "<li><b><i>" + qsTr("Shift + Tab: ")+"</i></b>" + qsTr("Go to previous tab.") + "</li>"+
                      "</ul>"  + translator.emptyString
                wrapMode: Text.Wrap
            }
        }
    }

    // *************************************   FOOTER ******************************************
    footer: Rectangle {
        id: myFooter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: Material.background

        IconButton {
            id: refreshButton
            anchors.centerIn: parent
            imageSource: "qrc:///img/refresh.svg"
            margins: 10
            visible: !helpRect.visible
            ToolTip.text: qsTr("Refresh") + translator.emptyString
            ToolTip.delay: 2000
            ToolTip.timeout: 5000
            onClicked: {
                root.renaming = false
                refreshModel()
            }
        }

        Button {
            id: okButton
            anchors.centerIn: parent
            text: qsTr("Ok") + translator.emptyString
            visible: helpRect.visible
            onClicked: {
                desktopList.visible = true
                tabBar.visible = true
                addTabButton.visible = true
                helpRect.visible = false
            }
        }
    }

    // *************************************   ABOUT PAGE ******************************************
    Dialog {
        id: aboutDialog

        modal: true
        standardButtons: Dialog.Ok
        font.pointSize: 12

        title: qsTr("About") + translator.emptyString

        Text {
            text: "<style>a:link { color: " + Material.accent + "; }</style>" + qsTr("MyDesktop was developped by Arnaud Portay.<br>The source code is available on <a href=\"https://github.com/arnaudPortay/MyDesktop\">Github</a>.<br>Some code was taken here and there on the web, including from the <a href = \"https:\/\/github.com/VincentPonchaut/qmlplayground\">QmlPlayground</a> application by Vincent Ponchaut.<br><br>The application icon was made by <a href=\"https://www.flaticon.com/authors/pixel-perfect\">Pixel perfect</a> and taken from <a href=\"www.flaticon.com\">www.flaticon.com</a>.") + translator.emptyString
            color: Material.foreground
            font.family: "Segoe UI"
            font.pointSize: 10
            textFormat: Text.RichText
            wrapMode: Text.Wrap
            anchors.fill: parent
            onLinkActivated: Qt.openUrlExternally(link)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }


    // *************************************   UNSUPPORTED PAGE ******************************************
    Dialog {
        id: notSupportedDialog

        modal: true
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pointSize: 12

        title: qsTr("Woops...") + translator.emptyString

        Text
        {
            text: qsTr("This feature is not supported on your platform yet.") + translator.emptyString
            color: Material.foreground
            font.family: "Segoe UI"
            font.pointSize: 10
            wrapMode: Text.Wrap
            anchors.fill: parent
        }
    }

    // *************************************   RENAME TAB PAGE ******************************************
    Dialog {
        id: renameTabDialog

        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        font.pointSize: 12

        title: qsTr("Renaming Tab") + translator.emptyString

        TextField
        {
            id: renameTextField
            text: tabBar.currentItem.text
            color: Material.foreground
            selectionColor: Material.accent
            font.family: "Segoe UI"
            font.pointSize: 10
            wrapMode: Text.Wrap
            anchors.fill: parent
            selectByMouse: true

            Keys.onShortcutOverride: {
                event.accepted = (event.key === Qt.Key_Return)
            }

            Keys.onEnterPressed: {
                renameTabDialog.accept()
            }

            Keys.onReturnPressed: {
                renameTabDialog.accept()
            }

            Keys.onEscapePressed: {
                renameTabDialog.reject()
            }
        }

        onOpened:{
            renameTextField.text = tabBar.currentItem.text

            renameTextField.forceActiveFocus()
            renameTextField.selectAll()
        }

        onAccepted:{
            updateTabName(tabBar.currentIndex, renameTextField.text)
            desktopList.forceActiveFocus()
        }

        onRejected: {
            desktopList.forceActiveFocus()
        }
    }

    // *************************************   DELETION BEHAVIOUR DIALOG ******************************************

    Dialog {
        id: deleteBehaviorDialog

        modal: true
        anchors.centerIn: parent
        font.pointSize: 12
        height: implicitHeight + 50
        title: qsTr("Deleting item") + translator.emptyString
        property bool permaDelete: false
        property int index: 0
        property int tabIndex: 1

        footer: DialogButtonBox {
            Button{
                text: qsTr("Delete from tab") + translator.emptyString
                flat: true
                DialogButtonBox.buttonRole:  DialogButtonBox.AcceptRole
            }

            Button{
                text: qsTr("Permanently delete") + translator.emptyString
                flat: true
                DialogButtonBox.buttonRole:  DialogButtonBox.AcceptRole
                onClicked: {
                    deleteBehaviorDialog.permaDelete = true
                }
            }

            Button{
                text: qsTr("Cancel") + translator.emptyString
                flat: true
                DialogButtonBox.buttonRole:  DialogButtonBox.RejectRole
            }
        }

        Text
        {
            id: deleteBehaviorDialogText

            text: qsTr("You are about to delete an item from a custom tab.") + "<br>" +
                  qsTr(" Do you wish to remove the item from the tab or to delete it permanently ?") + "<br>" +
                  qsTr("If you choose the former, the item will still be available in your other tabs.") + translator.emptyString
            color: Material.foreground
            font.family: "Segoe UI"
            font.pointSize: 10
            wrapMode: Text.Wrap

            CheckBox{
                id: deleteDialogCB
                y: deleteBehaviorDialogText.implicitHeight + 15
                text: "<i>" + qsTr("Do not ask me again") + translator.emptyString + "</i>"
                font.family: "Segoe UI"
                font.pointSize: 10
            }

            Keys.onEscapePressed: {
                renameTabDialog.reject()
            }
        }

        onAccepted:{
            if (deleteBehaviorDialog.permaDelete)
            {
                deleteItemAt(index)
            }
            else
            {
                deleteItemFromTab(tabIndex, index)
            }

            root.deletionBehaviour = deleteDialogCB.checked ? permaDelete ? 2 : 1 : 0


            desktopList.forceActiveFocus()
        }

        onRejected: {
            desktopList.forceActiveFocus()
        }
    }

    // *************************************   MODEL ******************************************
    ListModel {
        id: desktopItemsModel
    }


    // *************************************   FUNCTIONS ******************************************

    function mapToGlobalIndex(index)
    {
        if (tabBar.currentIndex === 0)
        {
            return index
        }

        if (index < localToGlobalIndexMatrix[tabBar.currentIndex-1].length)
        {
            return localToGlobalIndexMatrix[tabBar.currentIndex-1][index]
        }

        return localToGlobalIndexMatrix[tabBar.currentIndex-1].length
    }

    // *************************************

    function updateTabName(index, newName)
    {
        var tabs = customTabs.slice()
        tabs[index-1] = newName
        customTabs = tabs
        refreshTabs()
    }

    // *************************************

    function deleteItemAt(index)
    {
        if (root.renaming)
        {
            root.renaming = false
        }


        var globalIndex = mapToGlobalIndex(index)
        var itemsCopy = root.desktopItems.slice()
        itemsCopy.splice(globalIndex,1)

        var namesCopy = root.desktopItemsNames.slice()
        namesCopy.splice(globalIndex,1)

        root.desktopItems = itemsCopy
        root.desktopItemsChanged()

        root.desktopItemsNames = namesCopy
        root.desktopItemsNamesChanged()

        // update tab map
        var matrixCopy = localToGlobalIndexMatrix.slice()

        // iterate through tabs
        for (var i = 0; i < matrixCopy.length; i++)
        {
            // Delete all instances of global index
            var found = matrixCopy[i].findIndex(function(element){
                return element === globalIndex
            })

            while (found !== -1)
            {
                matrixCopy[i].splice(found,1)
                found = matrixCopy[i].findIndex(function(element){
                                return element === globalIndex
                            })
            }

            // Decrease indexes higher than globalIndex
            for (var j = 0; j < matrixCopy[i]; j++ )
            {
                if (matrixCopy[i][j] > globalIndex)
                {
                    matrixCopy[i][j] -= 1
                }
            }
        }


        localToGlobalIndexMatrix = matrixCopy

        //refresh
        refreshModel()
    }

    // *************************************
    function deleteItemFromTab(tabIndex, itemIndex)
    {
        var matrixCopy = localToGlobalIndexMatrix.slice()
        matrixCopy[tabIndex].splice(itemIndex, 1)
        localToGlobalIndexMatrix = matrixCopy
        refreshModel()
    }

    // *************************************

    function deleteTab(index)
    {
        var copy = customTabs.slice()
        var matrix = localToGlobalIndexMatrix.slice()
        copy.splice(tabBar.currentIndex-1, 1)
        matrix.splice(tabBar.currentIndex-1, 1)
        customTabs = copy
        localToGlobalIndexMatrix = matrix
        refreshTabs()
    }

    // *************************************

    function updateName(index, newName)
    {
        var NamesCopy = root.desktopItemsNames.slice()
        NamesCopy.splice(mapToGlobalIndex(index), 1, newName)
        root.desktopItemsNames = NamesCopy
        root.desktopItemsNamesChanged()
        root.renaming = false

        refreshModel()
    }

    // *************************************

    function refreshModel()
    {
        var currentIndex = desktopList.currentIndex
        desktopItemsModel.clear()

        var lPath = ""
        var lExists = true
        if (tabBar.currentIndex === 0 )
        {
            for (var i =0; i < root.desktopItems.length; i++)
            {
                lPath = root.desktopItems[i];
                lExists = true
                if (lPath.startsWith("file:///"))
                {
                    lExists = File.exists(lPath)
                }

                desktopItemsModel.append({"name": root.desktopItemsNames[i], "path": lPath, "exists": lExists})
            }
        }
        else if (root.desktopItems.length > 0)
        {
            for (var j =0; j < root.localToGlobalIndexMatrix[tabBar.currentIndex - 1].length; j++)
            {
                var globalIndex = root.localToGlobalIndexMatrix[tabBar.currentIndex - 1][j]
                lPath = root.desktopItems[globalIndex];
                lExists = true
                if (lPath.startsWith("file:///"))
                {
                    lExists = File.exists(lPath)
                }

                desktopItemsModel.append({"name": root.desktopItemsNames[globalIndex], "path": lPath, "exists": lExists})
            }
        }

        desktopList.currentIndex = Math.min(currentIndex, desktopList.count - 1)
    }

    // *************************************

    function refreshTabs()
    {
        var currentIndex = tabBar.currentIndex
        while (tabBar.count !== 1)
        {
            tabBar.removeItem(tabBar.itemAt(1))
        }

        for (var i=0; i< customTabs.length; i++)
        {
            var item = tabButton.createObject(tabBar)
            item.text = customTabs[i]
            tabBar.addItem(item)
        }

        tabBar.currentIndex = Math.min(currentIndex, tabBar.count - 1)
    }

    // *************************************

    function openExternally(index)
    {
        var globalIndex = mapToGlobalIndex(index)
        if (globalIndex === undefined)
        {
            globalIndex = 0
        }

        Qt.openUrlExternally(root.desktopItems[globalIndex])
    }

    // *************************************

    function openExternallyCurrentItem()
    {
        if (root.renaming)
        {
            root.renaming = false
        }
        else if (desktopItemsModel.get(mapToGlobalIndex(desktopList.currentIndex)).exists)
        {
            openExternally(desktopList.currentIndex)
        }
    }

    // *************************************

    function moveUrl(isGoingUp, indexToMove)
    {
        if (filterTextField.text !== "")
        {
            return desktopList.currentIndex
        }

        // Compute new index (clamped)
        var NewIndex = Math.min(Math.max(isGoingUp ? indexToMove - 1 : indexToMove + 1, 0), desktopList.count - 1);

        if (NewIndex === indexToMove)
        {
            return NewIndex
        }

        var matrix = root.localToGlobalIndexMatrix.slice()

        if (tabBar.currentIndex !== 0)
        {
            matrix[tabBar.currentIndex-1].splice(NewIndex, 0, matrix[tabBar.currentIndex-1].splice(indexToMove, 1)[0])
        }
        else
        {
            var ItemsCopy = root.desktopItems.slice()
            var NamesCopy = root.desktopItemsNames.slice()

            // Modifying lists
            ItemsCopy.splice(NewIndex, 0, ItemsCopy.splice(indexToMove, 1)[0])
            NamesCopy.splice(NewIndex, 0, NamesCopy.splice(indexToMove, 1)[0])

            // update tab map
            var matrixCopy = localToGlobalIndexMatrix.slice()
            for (var i = 0; i < matrixCopy.length; i++)
            {
                var found = matrixCopy[i].findIndex(function(element){
                    return element === indexToMove
                })

                if (found !== -1)
                {
                    matrixCopy[i][found] = NewIndex
                }
            }

            //Updating model
            root.desktopItems = ItemsCopy
            root.desktopItemsChanged()

            root.desktopItemsNames = NamesCopy
            root.desktopItemsNamesChanged()
        }


        root.localToGlobalIndexMatrix = matrix

        refreshModel()

        return NewIndex
    }

    // *************************************

    function moveTabBar(isGoingLeft, indexToMove)
    {
        // Compute new index (clamped)
        var NewIndex = Math.min(Math.max(isGoingLeft ? indexToMove - 1 : indexToMove + 1, 1), tabBar.count - 1) - 1;

        if (NewIndex + 1 === indexToMove || indexToMove === 0)
        {
            return indexToMove
        }


        var tabsCopy = root.customTabs.slice()
        var matrix = root.localToGlobalIndexMatrix.slice()

        // Modifying list
        tabsCopy.splice(NewIndex, 0, tabsCopy.splice(indexToMove - 1, 1)[0])
        matrix.splice(NewIndex, 0, matrix.splice(indexToMove - 1, 1)[0])


        //Updating model
        root.customTabs = tabsCopy
        root.localToGlobalIndexMatrix = matrix

        refreshTabs()

        return NewIndex + 1
    }

    // *************************************

    function addUrls(urls)
    {
        var ItemsCopy = root.desktopItems.slice()
        var NamesCopy = root.desktopItemsNames.slice()
        var matrix = root.localToGlobalIndexMatrix.slice()

        var currentUrl = ""
        var currentName = ""
        var currentExtension = ""
        var lNewExtension = ""
        var dirs = []
        var addingToCustomTab = tabBar.currentIndex !== 0

        for (var i=0; i < urls.length; i++){

            currentUrl = "" + urls[i]

            if (!currentUrl.startsWith("file:///"))
            {
                NamesCopy.push(currentUrl)
            }
            else
            {
                dirs = currentUrl.split("/")
                currentName = String(dirs[dirs.length - 1])
                currentExtension = File.getFileExtension(currentUrl)

                if (!keepLink)
                {
                    currentUrl = File.symLinkTarget(currentUrl)
                }

                if (currentExtension !== "")
                {
                    lNewExtension = File.getFileExtension(currentUrl)
                    currentName = currentName.replace("." + currentExtension,
                                                      (lNewExtension === "") ? "" : "." + lNewExtension )
                }
                else if (File.getFileExtension(currentUrl) !== "")
                {
                    currentName = currentName.concat('.', File.getFileExtension(currentUrl))
                }

                NamesCopy.push(currentName)
            }

            ItemsCopy.push(currentUrl)

            if (addingToCustomTab)
            {
                matrix[tabBar.currentIndex - 1].push(ItemsCopy.length-1)
            }

        }

        root.desktopItems = ItemsCopy
        root.desktopItemsNames = NamesCopy
        root.localToGlobalIndexMatrix = matrix

        root.desktopItemsChanged()
        root.desktopItemsNamesChanged()

        refreshModel()
    }

    // *************************************

    function addTabBar()
    {
        var tabs = customTabs.slice()
        var matrix = localToGlobalIndexMatrix.slice()
        tabs.push(qsTr("New Tab") + translator.emptyString)
        matrix.push([])
        customTabs = tabs
        localToGlobalIndexMatrix = matrix
        refreshTabs()
        tabBar.currentIndex = tabBar.count - 1

        desktopList.forceActiveFocus()
    }

    // *************************************

    function updateCurrentTabIndexSetting()
    {
        settings.currentTab = Math.min(Math.max(0,tabBar.currentIndex), tabBar.count - 1)
    }
}
