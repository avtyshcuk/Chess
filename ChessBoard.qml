import QtQuick 2.0


Item {
    id: root
    anchors.fill: parent
    property int boardSize: 8

    function putPiece(index, color, piece) {
        var component = Qt.createComponent("Piece.qml");
        if (component.status == Component.Ready) {
            var piece = color + "_" + piece + ".png";
            component.createObject(repeater.itemAt(index), {"source": piece});
        }
    }

    function getIndexFromPosition(position) {
        var x = position.charCodeAt(0) - 'a'.charCodeAt(0);
        var y = boardSize - Number(position[1]);

        return y * boardSize + x;
    }

    PositionStorage {
        id: storage
    }

    Grid {
        id: chessGrid
        anchors.fill: parent
        columns: boardSize
        rows: boardSize

        Repeater {
            id: repeater
            model: boardSize * boardSize

            Rectangle {
                id: rect
                width: chessGrid.width / boardSize
                height: chessGrid.height / boardSize

                property color black: "#612700"
                property color white: "#ECB589"
                property bool isFirstCellWhite: Math.floor(index / boardSize) % 2
                property bool indexParity: index % 2
                color: isFirstCellWhite ? (indexParity ? white : black) :
                                          (indexParity ? black : white)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                    }
                }
            }
        }
    }

    Component.onCompleted: {
        var initialPosition = storage.initialPosition
        for (var color in initialPosition) {
            for (var position in initialPosition[color]) {
                var piece = initialPosition[color][position];
                putPiece(getIndexFromPosition(position), color, piece);
            }
        }
    }
}

