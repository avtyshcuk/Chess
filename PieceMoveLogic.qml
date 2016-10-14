import QtQml 2.2

QtObject {
    id: pieceMoveLogic

    property var pieceModel: []

    property var attackMoves: []

    property int boardSize: 8
    property var moveRules: {
        'white_pawn': [[2, 0, -1]],

        'black_pawn': [[2, 0, 1]],

        'knight': [[-2, -1], [ -2, 1],
                   [-1, -2], [-1, 2],
                   [2, -1], [2, 1],
                   [1, -2], [1, 2]],

        'bishop': [[boardSize, -1, -1], [boardSize, 1, -1],
                   [boardSize, -1, 1], [boardSize, 1, 1]],

        'rook': [[boardSize, 0, -1], [boardSize, 0, 1],
                 [boardSize, -1, 0], [boardSize, 1, 0]],

        'queen': [[boardSize, 0, -1], [boardSize, 0, 1],
                  [boardSize, -1, 0], [boardSize, 1, 0],
                  [boardSize, -1, -1], [boardSize, 1, -1],
                  [boardSize, -1, 1], [boardSize, 1, 1]],

        'king': [[1, 0, -1], [1, 0, 1],
                 [1, -1, 0], [1, 1, 0],
                 [1, -1, -1], [1, 1, -1],
                 [1, -1, 1], [1, 1, 1]]
    }

    function isValidIndex(x, y) {
        return x >= 0 && x < boardSize && y >= 0 && y < boardSize;
    }

    function getPieceByIndex(index) {
        for (var i = 0; i < pieceModel.count; ++i) {
            var piece = pieceModel.get(i);
            if (piece.pieceIndex === index) {
                return piece;
            }
        }
    }

    function getValidMoves(index, piece, color) {
        var validMoves = [];

        var pieceX = index % boardSize;
        var pieceY = Math.floor(index / boardSize);
        var pieceName = piece === 'pawn' ? color + '_' + piece : piece;
        var pieceRules = moveRules[pieceName];

        if (pieceName === 'knight') {
            return getKnightMoves(pieceX, pieceY, pieceRules, color);
        }

        for (var i = 0; i < pieceRules.length; i++) {
            var x = pieceX;
            var y = pieceY;
            for (var count = 0; count < pieceRules[i][0]; count++) {
                x += pieceRules[i][1];
                y += pieceRules[i][2];

                if (!isValidIndex(x, y)) {
                    break;
                }

                var newIndex = y * boardSize + x;
                if (isOccupiedPosition(newIndex, color)) {
                    break;
                }

                validMoves.push(newIndex);
            }
        }
        return validMoves;
    }

    function getKnightMoves(x, y, pieceRules, color) {
        var validMoves = [];
        for (var i = 0; i < pieceRules.length; i++) {
            var newX = x + pieceRules[i][0];
            var newY = y + pieceRules[i][1];

            if (!isValidIndex(newX, newY)) {
                continue;
            }

            var newIndex = newY * boardSize + newX;
            if (isOccupiedPosition(newIndex, color)) {
                continue;
            }

            validMoves.push(newIndex);
        }
        return validMoves;
    }

    function isOccupiedPosition(newIndex, color) {
        var otherPiece = getPieceByIndex(newIndex);
        if (otherPiece !== undefined) {
            if (otherPiece.color === color) {
                return true;
            }

            var oppositeColor = color === 'white' ? 'black' : 'white';
            if (otherPiece.color === oppositeColor) {
                attackMoves.push(newIndex);
                return true;
            }
        }
        return false;
    }
}
