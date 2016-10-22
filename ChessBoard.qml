import QtQuick 2.0
import "Global.js" as Global

Item {
    id: root
    anchors.fill: parent
    property int boardSize: Global.boardSize

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

//                Text {
//                    anchors.fill: parent
//                    text: index
//                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        switch (gameManager.state) {
                        case 'initState':
                            // Empty cell is wrong first move
                            if (!Global.isCellOccupied(pieceModel, index)) {
                                break;
                            }

                            // Not correct if piece is not belong to us
                            var piece = Global.getPieceByIndex(pieceModel, index);
                            if (!Global.isSameColor(piece.color, gameManager.moveColor)) {
                                break;
                            }

                            // Let's find possible moves
                            gameManager.getPossibleMoves(index, piece);
                            if (!gameManager.hasPieceMoves()) {
                                gameManager.state = 'initState';
                                break;
                            }

                            gameManager.firstClickIndex = index;
                            internal.highlightRects();
                            gameManager.currentPiece = piece;
                            gameManager.state = 'firstClickState';
                            break;

                        case 'firstClickState':
                            if (gameManager.possibleMoves.indexOf(index) === -1
                                    && gameManager.attackMoves.indexOf(index) === -1) {
                                break;
                            }
                            var modelIndex = Global.getModelIndex(pieceModel, gameManager.firstClickIndex);
                            pieceModel.setProperty(modelIndex, "wasMoved", true);

                            internal.movePiece(gameManager.firstClickIndex, index);
                            gameManager.secondClickIndex = index;
                            gameManager.state = 'initState';
                            break;
                        }
                    }
                }
            }
        }
    }

    PieceView {
        id: pieceRepeater
        model: pieceModel
        cellWidth: internal.cellWidth
        cellHeight: internal.cellHeight
    }

    PieceModel {
        id: pieceModel
    }

    GameManager {
        id: gameManager
        pieceModel: pieceModel
    }

    QtObject {
        id: internal

        property real cellWidth: chessGrid.width / boardSize
        property real cellHeight: chessGrid.height / boardSize

        function movePiece(fromIndex, toIndex) {
            for (var i = 0; i < pieceModel.count; ++i) {
                if (pieceModel.get(i).pieceIndex === fromIndex) {
                    pieceRepeater.itemAt(i).toIndex = toIndex;
                    pieceRepeater.itemAt(i).animationRunning = true;
                }
            }
        }

        function handlePawnInPassing(toIndex) {
            // In passing capture is possible only for pawns
            var capture = gameManager.captureField;
            var isAttackColor = gameManager.moveColor === gameManager.captureField.color;
            if (toIndex === capture.index && isAttackColor) {
                if (gameManager.currentPiece.piece === 'pawn') {
                    var modelIndex = Global.getModelIndex(pieceModel, capture.captureIndex);
                    pieceModel.remove(modelIndex);
                    gameManager.captureField.index = -1;
                }
            }

            // In passing pawn capture works only once
            // and only if pawn moved two ranks forward
            if (isAttackColor) {
                gameManager.captureField.index = -1;
            } else if (toIndex !== capture.captureIndex) {
                gameManager.captureField.index = -1;
            }
        }

        function highlightRects() {
            var width = 3;
            for (var i = 0; i < gameManager.possibleMoves.length; i++) {
                var rect1 = repeater.itemAt(gameManager.possibleMoves[i]);
                rect1.border.width = width;
                rect1.border.color = 'green';
            }
            for (var j = 0; j < gameManager.attackMoves.length; j++) {
                var rect2 = repeater.itemAt(gameManager.attackMoves[j]);
                rect2.border.width = width;
                rect2.border.color = 'red';
            }

            var rect3 = repeater.itemAt(gameManager.firstClickIndex);
            rect3.border.width = 3;
            rect3.border.color = 'yellow';
        }

        function removeHighlights() {
            var rects = gameManager.possibleMoves.concat(
                        gameManager.attackMoves,
                        [gameManager.firstClickIndex]);
            for (var i = 0; i < rects.length; i++) {
                var rect = repeater.itemAt(rects[i]);
                rect.border.width = 0;
            }
        }
    }
}

