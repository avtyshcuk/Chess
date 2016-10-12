import QtQuick 2.0

Item {
    id: root
    anchors.fill: parent
    property int boardSize: 8

    PieceMoveLogic {
        id: logic
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
                        switch (gameManager.state) {
                        case 'initState':
                            var piece = internal.getPieceByIndex(index);
                            if (piece === undefined) {
                                break;
                            }
                            if (gameManager.moveColor !== piece.color) {
                                break;
                            }
                            internal.highlightRect(gridRect, 'yellow');

                            // Show possible moves
                            var moves = logic.getValidMoves(index, piece.piece, piece.color);
                            for (var i = 0; i < moves.length; i++) {
                                var rect = repeater.itemAt(moves[i]);
                                internal.highlightRect(rect, 'green');
                            }

                            gameManager.validMoves = moves;
                            gameManager.firstClickIndex = index;
                            gameManager.state = 'firstClickState';
                            break;

                        case 'firstClickState':
                            if (gameManager.validMoves.indexOf(index) === -1) {
                                break;
                            }

                            internal.movePiece(gameManager.firstClickIndex, index);
                            gameManager.state = 'initState';
                            break;
                        }
                    }
                }
            }
        }
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

                    internal.removeRectHighlight(repeater.itemAt(gameManager.firstClickIndex));
                    for (var i = 0; i < gameManager.validMoves.length; i++) {
                        internal.removeRectHighlight(repeater.itemAt(gameManager.validMoves[i]));
                    }
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

    GameManager {
        id: gameManager
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

        function highlightRect(rect, color) {
            rect.border.width = 3;
            rect.border.color = color;
        }

        function removeRectHighlight(rect) {
            rect.border.width = 0;
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

