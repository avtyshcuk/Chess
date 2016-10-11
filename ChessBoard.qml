import QtQuick 2.0

Item {
    id: root
    anchors.fill: parent
    property int boardSize: 8

    QtObject {
        id: gameManager

        property string moveColor: 'white'
        property int firstClickIndex: -1
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
                        var piece = internal.getPieceByIndex(index);
                        if (piece === 'undefined') {
                            return;
                        }

                        if (statesID.state == 'initState') {
                            if (gameManager.moveColor === piece.color) {
                                gridRect.border.color = "red";
                                statesID.state = 'firstClick';
                                gameManager.firstClickIndex = index;
                            }
                        } else if (statesID.state == 'firstClick') {
                            internal.movePiece(gameManager.firstClickIndex, index);
                            statesID.state = 'initState';
                        }
                    }
                }
            }
        }
    }

    StateGroup {
        id: statesID

        state: 'initState'
        states: [
            State {
                name: 'initState'
                PropertyChanges {
                    target: gameManager
//                    moveColor: 'black'/*moveColor == 'white' ? 'black' : 'white'*/
                }
            },
            State {
                name: 'firstClickState'
                PropertyChanges {
                    target: gameManager
                }
            }
        ]
    }

    Repeater {
        id: pieceRepeater
        model: pieceModel

        delegate: Piece {
            id: pieceID
            x: internal.getXFromIndex(pieceIndex)
            y: internal.getYFromIndex(pieceIndex)
            width: internal.cellWidth
            height: internal.cellHeight
            source: color + "_" + piece + ".png";

            property int toIndex: 0
            property alias animationRunning: positionAnimation.running

            ParallelAnimation {
                id: positionAnimation
                NumberAnimation { target: pieceID; property: "x"; to: internal.getXFromIndex(toIndex); }
                NumberAnimation { target: pieceID; property: "y"; to: internal.getYFromIndex(toIndex); }

                onStopped: {
                    pieceModel.get(index).pieceIndex = toIndex;
                }
            }
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

        function getPieceByIndex(index) {
            for (var i = 0; i < pieceModel.count; ++i) {
                var piece = pieceModel.get(i);
                if (piece.pieceIndex === index) {
                    return piece;
                }
            }
        }

        function movePiece(fromIndex, toIndex) {
//            var piece = getPieceByIndex(fromIndex)
            for (var i = 0; i < pieceModel.count; ++i) {
                if (pieceModel.get(i).pieceIndex === fromIndex) {
                    pieceRepeater.itemAt(i).toIndex = toIndex;
                    pieceRepeater.itemAt(i).animationRunning = true;
                }
            }
        }

        function getXFromIndex(index) {
            return (index % boardSize) * internal.cellWidth;
        }

        function getYFromIndex(index) {
            return Math.floor(index / boardSize) * internal.cellHeight;
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

