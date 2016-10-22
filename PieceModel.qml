import QtQuick 2.0
import "Global.js" as Global

ListModel {
    id: pieceModel

    property PositionStorage storage: PositionStorage { }

    function getIndexFromPosition(position) {
        var x = position.charCodeAt(0) - 'a'.charCodeAt(0);
        var y = boardSize - Number(position[1]);

        return y * boardSize + x;
    }

    Component.onCompleted: {
        var initialPosition = storage.initialPosition
        for (var color in initialPosition) {
            for (var position in initialPosition[color]) {
                var piece = initialPosition[color][position];
                var index = getIndexFromPosition(position);

                pieceModel.append({"pieceIndex": index, "color": color, "piece": piece});
            }
        }
    }
}
