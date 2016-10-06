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
            id: repeater
            model: boardSize * boardSize

            Rectangle {
                id: gridRect
                width: internal.cellWidth
                height: internal.cellHeight

                property color black: "#612700"
                property color white: "#ECB589"
                property bool isFirstCellWhite: Math.floor(index / boardSize) % 2
                property bool indexParity: index % 2
                color: isFirstCellWhite ? (indexParity ? white : black) :
                                          (indexParity ? black : white)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        internal.movePiece(0, index);
                    }
                }
            }
        }
    }

    Repeater {
        model: pieceModel

        delegate: Piece {
            x: (pieceIndex % boardSize) * internal.cellWidth
            y: Math.floor(pieceIndex / boardSize) * internal.cellHeight
            width: internal.cellWidth
            height: internal.cellHeight
            source: color + "_" + piece + ".png";
        }
    }

    ListModel {
        id: pieceModel
    }

    PositionStorage {
        id: storage
    }

    QtObject {
        id: internal

        property real cellWidth: chessGrid.width / boardSize
        property real cellHeight: chessGrid.height / boardSize

        function movePiece(fromIndex, toIndex) {
            for (var i = 0; i < pieceModel.count; ++i) {
                if (pieceModel.get(i).pieceIndex === fromIndex) {
                    pieceModel.get(i).pieceIndex = toIndex;
                }
            }
        }

        function getIndexFromPosition(position) {
            var x = position.charCodeAt(0) - 'a'.charCodeAt(0);
            var y = boardSize - Number(position[1]);

            return y * boardSize + x;
        }
    }

    Component.onCompleted: {
        var initialPosition = storage.initialPosition
        for (var color in initialPosition) {
            for (var position in initialPosition[color]) {
                var piece = initialPosition[color][position];
                var index = internal.getIndexFromPosition(position);
                pieceModel.append({"pieceIndex": index, "color": color, "piece": piece});
            }
        }
    }
}

