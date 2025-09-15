import QtQuick
import QtQuick.Controls 
import org.kde.kirigami as Kirigami

ListView {    
    id: todoList                                                                                                 
    anchors.topMargin: 8  
    spacing: 8
    clip: true 
    anchors.top: inputItem.bottom
    
    property var thisModel
    property var parentModelList: []
    property var parentModelTitleList: []

    property bool itemDropped: false  
    
    delegate: Item {
        id: itemWrapper
        width: parent.width * 0.9                                                                                                                                                                                                                                                                                                                     
        height: todoText.contentHeight + 40                                                                                                     
        anchors.horizontalCenter: parent.horizontalCenter   

        property int dragItemIndex: index
        property double originalY: itemWrapper.y

        Drag.active: itemMouseArea.drag.active
        Drag.hotSpot: Qt.point(itemWrapper.width/2, itemWrapper.height/2)
        MouseArea {                                                            
            id: itemMouseArea                                                  
            anchors.fill: parent                                               
            drag.target: itemWrapper                                           
                                                                            
            drag.onActiveChanged: {                                            
                if (itemMouseArea.drag.active) {                               
                    itemWrapper.dragItemIndex = index                          
                    itemWrapper.originalY = itemWrapper.y 
                }                                                              
            }                                                                  
            onReleased: {   
                itemWrapper.Drag.drop()                                    
                if (!itemDropped) {                                                                                  
                    itemWrapper.y = itemWrapper.originalY                                                                           
                }                 
                itemDropped = false                                                                                                                                      
            }                                                                  
        } 
        DropArea {
            id: itemDropArea
            anchors.fill: parent
            onDropped: {
                itemWrapper.dragItemIndex = index 
                thisModel.move(drag.source.dragItemIndex, itemWrapper.dragItemIndex, 1)
                saveModelToJson("todoListModel", todoListModel) 
                itemDropped = true
            }
        }
        
        Rectangle {
            anchors.fill: parent                                                 
            radius: 10                                                           
            opacity: 0.3                                                         
            color: "black"                                                   
        }                                                                                                                                                                                                                  
        Item {                                                                                                                           
            anchors.fill: parent
            height: parent.height * 0.9  
            anchors.margins: 10
            Column {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    Button {                                                                 
                        id: dropdownButton                                                   
                        text: "Dropdown"                                                     
                        width: 10                       
                        onClicked: dropdownMenu.popup()    
                        background: Kirigami.Icon {
                            id: menuIcon
                            source: "application-menu-symbolic"
                            width: Kirigami.Units.iconSizes.small
                            height: width 
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            HoverHandler {
                                id: dropdownButtonHoverHandler
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }                                                                                
                            states: [                                                                                     
                                State {                                                                                                                                                   
                                    when: dropdownButtonHoverHandler.hovered                                                                  
                                    PropertyChanges {                                                                     
                                        target: menuIcon                                                                 
                                        opacity: 0.4                                                                 
                                    }                                                                                     
                                }                                                                                      
                            ] 
                        }                                                                                                    
                    }
                }
                Text {
                    id: remainingText
                    text: getCheckedItemCount(thisModel.get(index).sublist)+"/"+thisModel.get(index).sublist.count
                    visible: thisModel.get(index).sublist.count != 0
                    color: "white" 
                    anchors.right: parent.right
                } 
            }                                                                                                                  

            Menu {
                id: dropdownMenu
                width: 100
                MenuItem {                                                                                                                   
                    contentItem: Button {
                        id: editButton
                        text: "Edit"
                        onClicked: { 
                            dropdownMenu.close()
                            editPopup.open() 
                        }
                    }  
                }
                MenuItem { 
                    contentItem: Button {
                        id: deleteButton
                        text: "Remove"
                        onClicked: { 
                            dropdownMenu.close()
                            thisModel.remove(index) 
                            saveModelToJson("todoListModel", todoListModel)
                        }
                    }   
                }    
            }
            Popup {                                                                  
                id: editPopup                                                       
                modal: true                                                          
                focus: true                                                          
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside         
                                                                                                          
                width: root.width                                                                                       
                height: editTextArea.contentHeight + 35 

                TextArea {                                                                                                                      
                    id: editTextArea                                                                                                               
                    anchors.fill: parent                                                                                                        
                    font.pixelSize: 18                                                                                                   
                    color: "white" 
                    horizontalAlignment: TextArea.AlignHCenter                                                                                  
                    verticalAlignment: TextArea.AlignVCenter                                                                                    
                    wrapMode: TextArea.Wrap 
                    text: model.text                                                                                                                                                                                                                                                                                                                   
                    
                    background: Rectangle {
                        anchors.fill: parent   
                        height: parent.height + 30                                           
                        radius: 10                                                           
                        opacity: 0.3                                                         
                        color: "black"                                                        
                    }                                                                                                                                                                                                                                                                                                                            

                    Keys.onReturnPressed: {  
                        model.text = editTextArea.text
                        editPopup.close()
                        saveModelToJson("todoListModel", todoListModel)    
                                                                                                                                                                               
                    }                                                                                                                                                                                                                                                                                                               
                }                                                                                                                         
            }
                                                                                                           
            Text {   
                id: todoText  
                width: parent.width * 0.75
                anchors.left: checkbox.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 6
                text: model.text                                                                                                        
                font.pixelSize: 16                                                                                                      
                color: "white"                                                                       
                wrapMode: Text.Wrap                                                                                                                                                                                               
            }        
            CheckBox {  
                id: checkbox 
                anchors.verticalCenter: parent.verticalCenter    
                anchors.left: parent.left                                                                                                           
                checked: model.checked                                                                                                  
                onCheckedChanged: {
                    model.checked = checked  
                    saveModelToJson("todoListModel", todoListModel) 
                }
            } 
                                                                                                                                                                                                                                                            
        }                                                                                                                               
    } 
    displaced: Transition {                                                                                    
        NumberAnimation {                                                                                      
            properties: "y"                                                                                    
            duration: 200                                                                                      
        }                                                                                                      
    }

    function getCheckedItemCount(model) {                                        
        var count = 0;                                                           
        for (var i = 0; i < model.count; i++) {                                  
            if (model.get(i).checked) {                                  
                count++;                                                         
            }                                                                    
        }                                                                        
        return count;                                                            
    }  
                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
}