import QtQuick 2.0
import QtGraphicalEffects 1.0
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

                border { width: 3; color: internal.getHighlightColor(index) }

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
                            var pieces = Global.getPiecesFromModel(pieceModel);

                            if (!Global.isSquareOccupied(pieces, index)) {
                                break;
                            }

                            var piece = pieces[index];

                            // Not correct if piece is not belong to us
                            if (piece.color !== gameManager.moveColor) {
                                break;
                            }

                            // Let's find possible moves
                            gameManager.getMoves(pieces, index);

                            // No moves, reset state and make another choice
                            if (!gameManager.hasPieceMoves()) {
                                gameManager.state = 'initState';
                                break;
                            }

                            gameManager.firstClickIndex = index;
                            gameManager.currentPiece = piece;
                            gameManager.state = 'firstClickState';
                            break;

                        case 'firstClickState':
                            if (!gameManager.isCorrectMove(index)) {
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

        function movePiece(fromIndex, toIndex)
        {
            for (var i = 0; i < pieceModel.count; ++i) {
                if (pieceModel.get(i).pieceIndex === fromIndex) {
                    pieceRepeater.itemAt(i).toIndex = toIndex;
                    pieceRepeater.itemAt(i).animationRunning = true;
                }
            }
        }

        function getHighlightColor(index)
        {
            var colors = {
                'current': 'yellow',
                'move': 'green',
                'attack': 'red'
            };

            if (index in gameManager.moves) {
                return colors[gameManager.moves[index]];
            }

            return 'transparent';
        }
    }
}

