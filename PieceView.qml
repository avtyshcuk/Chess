import QtQuick 2.2
import QtQuick.Dialogs 1.1
import "Global.js" as Global

Repeater {
    id: pieceRepeater

    property real cellWidth: 0
    property real cellHeight: 0

    property MessageDialog gameOverDialog: MessageDialog {
        id: messageDialog
        title: 'Game Over!'
        text: Global.invertedColor(gameManager.moveColor) + ' wins!'
        onAccepted: {
            Qt.quit()
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
                var modelIndex = Global.getModelIndex(pieceModel, toIndex);
                if (modelIndex !== -1) {
                    pieceModel.remove(modelIndex);
                }
                pieceModel.get(index).pieceIndex = toIndex;

                handlePawnInPassing(toIndex);

                if (!gameManager.isKingMate()) {
                    gameOverDialog.open();
                }
            }
        }
    }

    function getXFromIndex(index) {
        return (index % Global.boardSize) * cellWidth;
    }

    function getYFromIndex(index) {
        return Math.floor(index / Global.boardSize) * cellHeight;
    }

    function handlePawnInPassing(toIndex) {
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
