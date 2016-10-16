
var boardSize = 8;

function isValidIndex(x, y) {
    return x >= 0 && x < boardSize && y >= 0 && y < boardSize;
}

function isCellOccupied(model, index) {
    for (var i = 0; i < pieceModel.count; i++) {
        if (pieceModel.get(i).pieceIndex === index) {
            return true;
        }
    }
    return false;
}

function getModelIndex(model, positionIndex) {
    for (var i = 0; i < model.count; i++) {
        if (pieceModel.get(i).pieceIndex === positionIndex) {
            return i;
        }
    }
    return -1;
}

function getPieceByIndex(model, index) {
    for (var i = 0; i < pieceModel.count; i++) {
        var piece = pieceModel.get(i);
        if (piece.pieceIndex === index) {
            return piece;
        }
    }
}

function isSameColor(color1, color2) {
    return color1 === color2;
}

function oppositeColor(color) {
    return color === 'white' ? 'black' : 'white';
}
