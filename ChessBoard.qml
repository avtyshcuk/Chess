import QtQuick 2.0

Item {
    id: root
    anchors.fill: parent
    property int boardSize: 8

    Grid {
        id: chessGrid
        anchors.fill: parent
        columns: boardSize
        rows: boardSize

        Repeater {
            model: boardSize * boardSize

            Rectangle {
                id: rect
                width: chessGrid.width / boardSize
                height: chessGrid.height / boardSize

                property bool isFirstCellWhite: Math.floor(index / boardSize) % 2
                property bool indexParity: index % 2
                color: isFirstCellWhite ? (indexParity ? "white" : "black") :
                                          (indexParity ? "black" : "white")

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
//                        var component;

                        if (index == 0) {
                            var component = Qt.createComponent("Piece.qml");
                            if (component.status == Component.Ready)
                                component.createObject(rect, {/*"anchors.centerIn" : rect*/});

                            component.x = 400
                        }

//                        if (index == 63) {
//                            component.x = 300
//                        }

                    }
                }
            }
        }

        Component.onCompleted: {
//            var component = Qt.createComponent("Piece.qml");
//            if (component.status == Component.Ready)
//                component.createObject(parent, {"x": 100, "y": 100});
        }
    }
}

