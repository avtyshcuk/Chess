import QtQuick 2.2
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1
import "Global.js" as Global

Repeater {
    id: pieceRepeater

    property real cellWidth: 0
    property real cellHeight: 0

    property int promotedIndex: -1

    property MessageDialog gameOverDialog: MessageDialog {
        id: messageDialog
        title: 'Game Over!'
        text: Global.invertedColor(gameManager.moveColor) + ' wins!'
        onAccepted: {
            Qt.quit()
        }
    }

    property Window pawnPromotionWindow: Window {
        id: promotionWindow
        title: "Choose New Piece"
        modality: Qt.ApplicationModal
        width: 325
        height: 80
        visible: false

        ListModel {
            id: replacementPieceModel

            ListElement {
                piece: "queen"
            }

            ListElement {
                piece: "rook"
            }

            ListElement {
                piece: "knight"
            }

            ListElement {
                piece: "bishop"
            }
        }

        Component {
            id: highlightBar
            Rectangle {
                width: 200; height: 50
                border.color: 'red'
                color: "#FFFF88"
            }
        }

        ListView {
            id: replacementPieceView

            anchors.fill: parent
            orientation: ListView.Horizontal
            model: replacementPieceModel
            signal choosenPie

            delegate: Image {
                source: Global.invertedColor(gameManager.moveColor) + '_' + piece + '.png'

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        replacementPieceView.currentIndex = index;

                        removePieceFromModel(pieceModel, promotedIndex);

                        var color = Global.invertedColor(gameManager.moveColor);
                        var newPiece = {"pieceIndex": promotedIndex, "color": color, "piece": piece}
                        pieceModel.append(newPiece);

                        promotionWindow.visible = false;
                    }
                }
            }

            focus: true
            highlight: highlightBar
        }
    }

    delegate: Piece {
        id: pieceID
        x: getXFromIndex(pieceIndex)
        y: getYFromIndex(pieceIndex)
        width: cellWidth
        height: cellHeight
        source: color + "_" + piece + ".png";

        property int toIndex: 0
        property alias animationRunning: positionAnimation.running

        ParallelAnimation {
            id: positionAnimation
            NumberAnimation { target: pieceID; property: "x"; to: getXFromIndex(toIndex); }
            NumberAnimation { target: pieceID; property: "y"; to: getYFromIndex(toIndex); }

            onStopped: {
                removePieceFromModel(pieceModel, toIndex);
                pieceModel.get(index).pieceIndex = toIndex;

                // Specific pawns feature - promotion and 'en passant'
                handlePawnInPassing(toIndex);
                handlePawnPromotion(toIndex);

                // Pawns and king rules depend on fact whether were moved
                var modelIndex = Global.getModelIndex(pieceModel, toIndex);
                pieceModel.setProperty(modelIndex, "wasMoved", true);

                if (!gameManager.isKingMate()) {
                    gameOverDialog.open();
                }
            }
        }
    }

    function getXFromIndex(index)
    {
        return (index % Global.boardSize) * cellWidth;
    }

    function getYFromIndex(index)
    {
        return Math.floor(index / Global.boardSize) * cellHeight;
    }

    function removePieceFromModel(pieceModel, index)
    {
        var modelIndex = Global.getModelIndex(pieceModel, index);
        if (modelIndex !== -1) {
            pieceModel.remove(modelIndex);
        }
    }

    function handlePawnPromotion(toIndex)
    {
        var piece = gameManager.currentPiece;
        if (piece.piece !== 'pawn') {
            return;
        }

        var y = Math.floor(toIndex / Global.boardSize);
        var rank = piece.color === 'white' ? 0 : Global.boardSize - 1;

        if (y === rank) {
            pawnPromotionWindow.visible = true;
            promotedIndex = toIndex;
        }
    }

    function handlePawnInPassing(toIndex)
    {
        var piece = gameManager.currentPiece;
        if (piece.piece !== 'pawn') {
            gameManager.captureField = {'index': -1, 'captureIndex': -1};
            return;
        }

        if (gameManager.captureField.index === toIndex) {
            removePieceFromModel(pieceModel, gameManager.captureField.captureIndex);
        }

        gameManager.captureField = {'index': -1, 'captureIndex': -1};
        if (!piece.wasMoved) {
            var x = toIndex % boardSize;
            var y = Math.floor(toIndex / boardSize);

            var checkedPiece = {'piece': 'pawn', 'color': gameManager.moveColor};

            var pieces = Global.getPiecesFromModel(pieceModel);
            if (Global.isValidIndex(x + 1, y)) {
                var rightIndex = y * boardSize + (x + 1);
                if (Global.isPieceOnCell(pieces, checkedPiece, rightIndex)) {
                    gameManager.inCaptionPawns.push(rightIndex);
                }
            }

            if (Global.isValidIndex(x - 1, y)) {
                var leftIndex = y * boardSize + (x - 1);
                if (Global.isPieceOnCell(pieces, checkedPiece, leftIndex)) {
                    gameManager.inCaptionPawns.push(leftIndex);
                }
            }

            var direction = piece.color === 'white' ? -1 : 1;
            var inPassingIndex = (y - direction) * boardSize + x;

            // Some pawns are 'ready' to capture us
            if (gameManager.inCaptionPawns.length > 0) {
                gameManager.captureField.index = inPassingIndex;
                gameManager.captureField.captureIndex = toIndex;
            }
        }
    }
}
