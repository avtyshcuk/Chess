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

                handlePawnInPassing(toIndex);
                handlePawnPromotion(toIndex);

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
        // In passing capture is possible only for pawns
        var capture = gameManager.captureField;
        var isAttackColor = gameManager.moveColor === capture.color;
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
}
