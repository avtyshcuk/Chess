
var boardSize = 8;

function isValidIndex(x, y) {
    return x >= 0 && x < boardSize && y >= 0 && y < boardSize;
}

function isCellOccupied(model, index) {
    for (var i = 0; i < model.count; i++) {
        if (model.get(i).pieceIndex === index) {
            return true;
        }
    }
    return false;
}

function isCellPossibleOccupied(possibleModel, index) {
    for (var i = 0; i < possibleModel.length; i++) {
        if (possibleModel[i].pieceIndex === index) {
            return true;
        }
    }
    return false;
}

function getModelIndex(model, positionIndex) {
    for (var i = 0; i < model.count; i++) {
        if (model.get(i).pieceIndex === positionIndex) {
            return i;
        }
    }
    return -1;
}

function getPieceByIndex(model, index) {
    for (var i = 0; i < model.count; i++) {
        var piece = model.get(i);
        if (piece.pieceIndex === index) {
            return piece;
        }
    }
}

function getPossiblePieceByIndex(possibleModel, index) {
    for (var i = 0; i < possibleModel.length; i++) {
        var piece = possibleModel[i];
        if (piece.pieceIndex === index) {
            return piece;
        }
    }
}

function getPieceIndex(model, pieceName, color) {
    for (var i = 0; i < model.count; i++) {
        var piece = model.get(i);
        if (piece.piece === pieceName && piece.color === color) {
            return piece.pieceIndex;
        }
    }
    return -1;
}

function getPossiblePieceIndex(model, pieceName, color) {
    for (var i = 0; i < model.length; i++) {
        var piece = model[i];
        if (piece.piece === pieceName && piece.color === color) {
            return piece.pieceIndex;
        }
    }
    return -1;
}

function isSameColor(color1, color2) {
    return color1 === color2;
}

function oppositeColor(color) {
    return color === 'white' ? 'black' : 'white';
}
