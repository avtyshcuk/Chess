import QtQuick 2.0
import "Global.js" as Global

Repeater {
    id: pieceRepeater

    property real cellWidth: 0
    property real cellHeight: 0

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

                internal.removeHighlights();
                internal.handlePawnInPassing(toIndex);
            }
        }
    }

    function getXFromIndex(index) {
        return (index % Global.boardSize) * cellWidth;
    }

    function getYFromIndex(index) {
        return Math.floor(index / Global.boardSize) * cellHeight;
    }
}
