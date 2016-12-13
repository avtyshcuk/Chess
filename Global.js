
var boardSize = 8;

function isValidIndex(x, y)
{
    return x >= 0 && x < boardSize && y >= 0 && y < boardSize;
}

function invertedColor(color)
{
    return color === 'white' ? 'black' : 'white';
}

function getPiecesFromModel(model)
{
    var pieces = { };

    for (var i = 0; i < model.count; i++) {
        var index = model.get(i).pieceIndex;

        pieces[index] = {
            'color': model.get(i).color,
            'piece': model.get(i).piece,
            'wasMoved': model.get(i).wasMoved
        };
    }

    return pieces;
}

function isSquareOccupied(pieces, index)
{
    return index in pieces;
}

function getPiece(pieces, index)
{
    return pieces[index];
}

function isPieceOnCell(pieces, piece, index)
{
    var color = piece.color
    var name = piece.piece;

    if (isSquareOccupied(pieces, index)) {
        var otherPiece = getPiece(pieces, index);

        if (otherPiece.color === color && otherPiece.piece === name) {
            return true;
        }
    }

    return false;
}

function getSquareBorder(pieces, index)
{
    var colors = {
        'current': 'green',
        'attack': 'red',
        'move': 'yellow'
    };

    for (var piece in pieces) {
        return colors[pieces[piece].color];
    }

    return 'transparent';
}

function getModelIndex(model, positionIndex)
{
    for (var i = 0; i < model.count; i++) {
        if (model.get(i).pieceIndex === positionIndex) {
            return i;
        }
    }

    return -1;
}
