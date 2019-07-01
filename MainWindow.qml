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
                    if (!root.renaming && desktopList.visible && !filterTextField.focus)
                    {
                        openExternallyCurrentItem()
                    }
                }
            }
            
            Action {
                text: qsTr("&Open location") + translator.emptyString
                onTriggered: {
                    if (!root.renaming && desktopList.visible)
                    {
                        if (desktopItemsModel.get(desktopList.currentIndex).exists)
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
                    Qt.quit()
                }
                shortcut: "Ctrl+W"
            }
        }
        
        Menu {
            title: qsTr("&Edit") + translator.emptyString
            
            Action {
                text: qsTr("&Rename") + translator.emptyString
                onTriggered: {
                    if (desktopList.visible)
                    {
                        root.renaming = true
                    }
                }
                shortcut: "F2"
            }
            
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
            
            Action {
                text: qsTr("&Delete") + translator.emptyString
                onTriggered: {
                    if (desktopList.visible)
                    {
                        root.renaming = false
                        deleteItemAt(desktopList.currentIndex)
                    }
                }
                shortcut: StandardKey.Delete
            }

            MenuSeparator{}

            Action {
                text: qsTr("&Move up") + translator.emptyString
                enabled: desktopList.currentIndex != 0
                onTriggered: {
                    desktopList.currentIndex = moveUrl(true, desktopList.currentIndex)
                }
            }

            Action {
                text: qsTr("&Move down") + translator.emptyString
                enabled: desktopList.currentIndex != desktopList.count
                onTriggered: {
                    desktopList.currentIndex = moveUrl(false, desktopList.currentIndex)
                }
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
                shortcut: "Ctrl+T"
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
                    desktopList.visible = false
                    helpRect.visible = true
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
        refreshModel();
        desktopList.currentIndex = 0

        root.visible = settings.showWindowAtStartup
    }
    onClosing: {
        root.visible = false
        close.accepted = false
    }
    
    property var desktopItems: []
    property var desktopItemsNames: []
    property bool renaming: false
    property bool darkTheme: true
    property string language: "en"
    onLanguageChanged: {
        translator.selectLanguage(language)
    }
    property bool keepLink: false
    property bool moving: false
    
    Settings {
        id: settings
        
        // Logic state
        property alias desktopItems: root.desktopItems
        property alias desktopItemsNames: root.desktopItemsNames
        // Current filter
        property alias currentFilter: filterTextField.text
        
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
    }
    
    Rectangle{
        id: baseRectangle
        anchors.fill: parent

        color: Material.background

        Shortcut {
            sequences: [StandardKey.Paste, "Ctrl+Shift+V"]
            onActivated: {
                if (desktopList.visible && Clipboard.getUrls().length > 0)
                {
                    addUrls(Clipboard.getUrls())
                }
            }
        }
        
        DropArea{
            id: globalDropArea
            anchors.fill: parent
            
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
        
        ListView{
            id: desktopList
            anchors.fill:parent
            clip: true
            focus: true
            model: desktopItemsModel
            
            Keys.onUpPressed: {

                if (event.modifiers & Qt.ControlModifier)
                {
                    desktopList.currentIndex = moveUrl(true, desktopList.currentIndex)
                }
                else
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

                if (event.modifiers & Qt.ControlModifier)
                {
                    desktopList.currentIndex = moveUrl(false, desktopList.currentIndex)
                }
                else
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
                else if (event.key === Qt.Key_Control)
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
                else if (event.key === Qt.Key_Control)
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
                        anchors.right: delOpenLocationButton.left
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
                        
                        Keys.onEscapePressed: {root.renaming = false}
                        
                    }
                    
                    Text {
                        id: delText
                        
                        text: name
                        
                        anchors.left: parent.left
                        anchors.right: delOpenLocationButton.left
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
                        
                        color: exists ? Material.foreground : Material.color(Material.Red)
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
                        
                        visible: desktopItemsDelegate.hovered
                        
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
                        
                        visible: desktopItemsDelegate.hovered
                        
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

                        visible: desktopItemsDelegate.hovered

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

                        visible: desktopItemsDelegate.hovered

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
                    border.width: desktopItemsDelegate.highlighted && root.moving ? 3 : 1
                    border.color:  desktopItemsDelegate.highlighted && root.moving ? Material.primary : color
                }
                
                onClicked: {
                    
                    if (!root.renaming || !desktopItemsModel.get(desktopList.currentIndex).exists)
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
        }
        
        Text
        {
            id: emptyListTExt
            
            anchors.fill: parent
            anchors.margins: 10
            text: qsTr("Drag and drop files, folders, applications, shortcuts or internet links.") + translator.emptyString
            font.family: "Segoe UI"
            visible: desktopItems.length === 0
            font.italic: true
            font.pointSize: 14
            wrapMode: Text.Wrap
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            color: Material.color(Material.Grey)
        }
        
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
                      qsTr("You can also open the item location in the file explorer if said file is local.")+ "<br><br>"+
                      qsTr("Drag and drop an item (file, folder, application etc...) onto the My Desktop window to add it to the list of available items.")+ "<br>" +
                      qsTr("You can also paste a link to the item from the clipboard.") + "<br>" +
                      qsTr("If you wish to open the folder containing an item, click on the folder icon which appears when hovering an item.")+"<br>" +
                      qsTr("To delete an item, click on the trashcan icon which appears when hovering the item.")+ "<br>" +
                      qsTr("To open an item with its default associated program, double-click an item.")+ "<br><br>" +
                      qsTr("To reorder your items you can use the up arrow and down arrow buttons or click on \"Edit\" then \"Move up\" or \"Move down\".") + "<br><br>" +
                      qsTr("If an item is displayed in red and is striked out, this means the item does not exist anymore.")+ "<br>" +
                      qsTr("If you are trying to open an item and it does not work, maybe it has been deleted. Click the refresh button at the bottom of the window to refresh the display and check if it appears red.")+ "<br><br>" +
                      qsTr("You can rename an item by selecting it and then clicking \"Edit\" then \"Rename\". This will only rename the list entry and not the underlying file/folder/application.")+ "<br><br>" +
                      qsTr("You can change the application language by clicking \"?\" then \"Language\".") + "<br>" + "<br>" +
                      qsTr("You can make this application launch automatically at startup by clicking \"?\" then \"Launch at startup\".") + "<br>" + "<br>" +
                      "<b>" + qsTr("Note: ")+"</b>"+qsTr("If you drag and drop a shortcut file onto the My Desktop window then what will be remembered is the shortcut target, not the shortcut itself, as such you can safely delete said shortcut.")+ "<br><br>" +
                      "<h2>" + qsTr("Shortcut list") + "</h2>" +
                      "<ul>" +
                      "<li><b><i>" + qsTr("Enter: ")+"</i></b>" + qsTr("open the selected item with the associated application.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + O: ")+"</i></b>" + qsTr("open the folder containing the selected item.") + "</li>"+
                      "<li><b><i>" + qsTr("Del: ")+"</i></b>" + qsTr("delete the selected item from the list.") + "</li>"+
                      "<li><b><i>" + qsTr("F2: ")+"</i></b>" + qsTr("rename the selected item. \"Enter\" to validate \"Esc\" to cancel.") + "</li>"+
                      "<li><b><i>" + qsTr("F5: ")+"</i></b>" + qsTr("refresh display.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + T: ")+"</i></b>" + qsTr("switch between light and dark theme.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + F: ")+"</i></b>" + qsTr("search shortcut.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + H: ")+"</i></b>" + qsTr("opens this help page.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + W: ")+"</i></b>" + qsTr("closes the application.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + V: ")+"</i></b>" + qsTr("Add an item to the list by pasting from the clipboard.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + UpArrow: ")+"</i></b>" + qsTr("Move up the current item.") + "</li>"+
                      "<li><b><i>" + qsTr("Ctrl + DownArrow: ")+"</i></b>" + qsTr("Move down the current item.") + "</li>"+
                      "</ul>"  + translator.emptyString
                wrapMode: Text.Wrap
            }
        }
    }
    
    
    header: TextField {
        id: filterTextField
        width: parent.width * 0.77
        anchors.centerIn: parent
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
                helpRect.visible = false
            }
        }
    }
    
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
    
    ListModel {
        id: desktopItemsModel
    }
    
    function deleteItemAt(index)
    {
        if (root.renaming)
        {
            root.renaming = false
        }
        
        var itemsCopy = root.desktopItems.slice()
        itemsCopy.splice(index,1)
        
        var namesCopy = root.desktopItemsNames.slice()
        namesCopy.splice(index,1)
        
        root.desktopItems = itemsCopy
        root.desktopItemsChanged()
        
        root.desktopItemsNames = namesCopy
        root.desktopItemsNamesChanged()
        
        refreshModel()
    }
    
    function updateName(index, newName)
    {
        var NamesCopy = root.desktopItemsNames.slice()
        NamesCopy.splice(index, 1, newName)
        root.desktopItemsNames = NamesCopy
        root.desktopItemsNamesChanged()
        root.renaming = false
        
        refreshModel()
    }
    
    function refreshModel()
    {
        var currentIndex = desktopList.currentIndex
        desktopItemsModel.clear()
        
        var lPath = ""
        var lExists = true
        
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
        
        desktopList.currentIndex = Math.min(currentIndex, desktopList.count - 1)
    }
    
    function openExternally(index)
    {
        if (index === undefined)
        {
            index = 0
        }
        
        Qt.openUrlExternally(root.desktopItems[index])
    }
    
    function openExternallyCurrentItem(){
        if (root.renaming)
        {
            root.renaming = false
        }
        else if (desktopItemsModel.get(desktopList.currentIndex).exists)
        {
            openExternally(desktopList.currentIndex)
        }
    }

    function moveUrl(isGoingUp, indexToMove)
    {
        if (filterTextField.text !== "")
        {
            return desktopList.currentIndex
        }

        // Compute new index (clamped)
        var NewIndex = Math.min(Math.max(isGoingUp ? indexToMove - 1 : indexToMove + 1, 0), desktopList.count);

        if (NewIndex === indexToMove)
        {
            return
        }


        var ItemsCopy = root.desktopItems.slice()
        var NamesCopy = root.desktopItemsNames.slice()

        // Modifying lists
        ItemsCopy.splice(NewIndex, 0, ItemsCopy.splice(indexToMove, 1)[0])
        NamesCopy.splice(NewIndex, 0, NamesCopy.splice(indexToMove, 1)[0])

        //Updating model
        root.desktopItems = ItemsCopy
        root.desktopItemsChanged()

        root.desktopItemsNames = NamesCopy
        root.desktopItemsNamesChanged()

        refreshModel()

        return NewIndex
    }

    function addUrls(urls)
    {
        var ItemsCopy = root.desktopItems.slice()
        var NamesCopy = root.desktopItemsNames.slice()

        var currentUrl = ""
        var currentName = ""
        var currentExtension = ""
        var lNewExtension = ""
        var dirs = []

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
        }

        root.desktopItems = ItemsCopy;
        root.desktopItemsNames = NamesCopy;

        root.desktopItemsChanged();
        root.desktopItemsNamesChanged();

        refreshModel();
    }
}
