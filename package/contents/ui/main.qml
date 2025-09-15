import QtQuick
import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls
import org.kde.plasma.core
import org.kde.plasma.plasmoid 2.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.20 as Kirigami
import QtQuick.LocalStorage 2.0

PlasmoidItem {     
    id: root                                                           
    width: 300                                                       
    height: 400 
    Layout.minimumWidth: 60                                                 
    Layout.minimumHeight: 80     

    property var mainModel: todoListModel
    property var currentModel: mainModel
    property bool subModel: !(mainModel == currentModel)
    property var subModelTitle

    Plasmoid.backgroundHints: "NoBackground"; // Transparent is better

    Item {
        id: mainViewWrapper
        anchors.fill: parent
        clip: true

        TodoList {
            id: mainTodoList
            width: parent.width                                      
            height: parent.height
            anchors.top: mainInputItem.bottom                         
            model: currentModel 
            thisModel: currentModel
        }

        
        InputItem {
            id: mainInputItem
            anchors.topMargin: 10
            anchors.top: topBarRectangle.bottom
            thisModel: currentModel
        }     

        Rectangle {
            id: topBarRectangle
            visible: subModel 
            width: parent.width
            height: subModel ? Math.max(title.contentHeight + 10, 40) : 0
            radius: 10
            anchors.top: parent.top
            color: "black"
            opacity: 0.3
        }
        Text {    
            id: title 
            width: parent.width * 0.75 
            visible: subModel                                                   
            text: root.subModelTitle                                                                                                   
            font.pixelSize: 18                                                                                                      
            color: "white"                                                                           
            anchors.verticalCenter: topBarRectangle.verticalCenter  
            anchors.left: backButton.right
            anchors.leftMargin: 15                                                                                                         
            wrapMode: Text.Wrap                                                                                                                                                                                               
        }  
        
        Button {
            id: backButton
            visible: subModel 
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.verticalCenter: topBarRectangle.verticalCenter
            onClicked: {
                
                var parentModel = mainTodoList.parentModelList[(mainTodoList.parentModelList.length - 1)]
                var parentModelTitle = mainTodoList.parentModelTitleList[(mainTodoList.parentModelTitleList.length - 2)]

                root.currentModel = parentModel
                root.subModelTitle = parentModelTitle
                mainTodoList.parentModelList.pop()
                mainTodoList.parentModelTitleList.pop()
            }
            background: Kirigami.Icon {
                id: backIcon
                source: "draw-arrow-back"
                width: Kirigami.Units.iconSizes.medium
                height: width 
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                HoverHandler {
                    id: backButtonHoverHandler
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }                                                                                
                states: [                                                                                     
                    State {                                                                                                                                                   
                        when: backButtonHoverHandler.hovered                                                                  
                        PropertyChanges {                                                                     
                            target: backIcon                                                                 
                            opacity: 0.4                                                               
                        }                                                                                     
                    }                                                                                      
                ] 
            }
        }
    } 
    
                                                                                                                          
    ListModel {                                                        
        id: todoListModel   
        Component.onCompleted: {
            loadModelFromJson("todoListModel", todoListModel)
        }                                        
    } 


    function saveModelToJson(fileName, listModel) {
        let jsonArray = []
        for (let i = 0; i < listModel.count; i++) {
            jsonArray.push(listModel.get(i))
        }
        let jsonString = JSON.stringify(jsonArray)
        let file = LocalStorage.openDatabaseSync("qtodo", "1.0", "StorageDatabase", 5000000)
        file.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS ListData (id TEXT UNIQUE, data TEXT)')
            tx.executeSql('INSERT OR REPLACE INTO ListData VALUES(?, ?)', [fileName, jsonString])
        })
    }

    function loadModelFromJson(fileName, listModel) {
        let file = LocalStorage.openDatabaseSync("qtodo", "1.0", "StorageDatabase", 5000000)
        let jsonString = ""
        file.transaction(function(tx) {
            let rs = tx.executeSql('SELECT data FROM ListData WHERE id=?', [fileName])
            if (rs.rows.length > 0) {
                jsonString = rs.rows.item(0).data
            }
        })

        if (jsonString !== "") {
            let jsonArray = JSON.parse(jsonString)
            listModel.clear()
            for (let i = 0; i < jsonArray.length; i++) {
                listModel.append(jsonArray[i])
            }
        }
    }                                                
}       