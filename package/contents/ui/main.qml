import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls
import org.kde.plasma.core 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.20 as Kirigami



PlasmoidItem {     
    id: root                                                           
    width: 300                                                       
    height: 400 
    Layout.minimumWidth: 60                                                 
    Layout.minimumHeight: 80     

    property var fileUrl : "/home/fr1z/.local/Qtodo.json"
    property var mainModel: todoListModel
    property var currentModel: mainModel
    property bool subModel: !(mainModel == currentModel)
    property var subModelTitle

    Plasmoid.backgroundHints: "NoBackground" // Transparent background

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
            opacity: 0.3
            color: '#c9c9c9'
            border.color: Qt.lighter(color, 1.1)
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

    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    function saveModelToJson(fileName, listModel) {
        let jsonArray = []
        for (let i = 0; i < listModel.count; i++) {
            jsonArray.push(listModel.get(i))
        }
        let jsonString = JSON.stringify(jsonArray)
        return saveFile(fileUrl, jsonString)
    }

    function loadModelFromJson(fileName, listModel) {
        jsonString = openFile(fileUrl);
        if (jsonString !== "") {
            let jsonArray = JSON.parse(jsonString)
            listModel.clear()
            for (let i = 0; i < jsonArray.length; i++) {
                listModel.append(jsonArray[i])
            }
        }
    }                                                
}       