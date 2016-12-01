
var boardSize = 8;

function isValidIndex(x, y) {
    return x >= 0 && x < boardSize && y >= 0 && y < boardSize;
}

function copyModel(model) {
    var possibleModel = [];
    for (var i = 0; i < model.count; i++) {
        possibleModel.push({"pieceIndex": model.get(i).pieceIndex,
                              "color": model.get(i).color,
                              "piece": model.get(i).piece});
    }
    return possibleModel;
}

function getPiecesFromModel(model) {
    var pieces = [];

    for (var i = 0; i < model.count; i++) {
        pieces.push({"pieceIndex": model.get(i).pieceIndex,
                        "color": model.get(i).color,
                        "piece": model.get(i).piece});
    }

    return pieces;
}

function isSquareOccupied(pieces, index) {
    for (var i = 0; i < pieces.length; i++) {
        if (pieces[i].pieceIndex === index) {
            return true;
        }
    }
    return false;
}

function getPiece(pieces, index) {
    for (var i = 0; i < pieces.length; i++) {
        // 'equality' is used for string keys
        if (pieces[i].pieceIndex == index) {
            return pieces[i];
        }
    }
}

function getSquareBorder(pieces, index) {
    var colors = {
        'current': 'green',
        'attack': 'red',
        'move': 'yellow'
    };

    for (var i = 0; i < pieces.length; i++) {
        for (var j in pieces[i]) {
            if (pieces[i][j] === index) {
                return colors[j];
            }
        }
    }

    return 'transparent';
}

function isCellOccupied(model, index) {
    var modelSize = (model instanceof Array) ? model.length : model.count;
    for (var i = 0; i < modelSize; i++) {
        var element = (model instanceof Array) ? model[i] : model.get(i);
        if (element.pieceIndex === index) {
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
