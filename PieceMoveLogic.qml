import QtQml 2.2

QtObject {
    id: pieceMoveLogic
    property int boardSize: 8
    property var moveRules: {
        'white_pawn': [[2, 0, -1]],

        'black_pawn': [[2, 0, 1]],

//        'knight': [[2, -2, -1], [boardSize, 0, 1]/*,
//                   [boardSize, -1, 0], [boardSize, 1, 0],
//                   [boardSize, -1, -1], [boardSize, 1, -1],
//                   [boardSize, -1, 1], [boardSize, 1, 1]*/],

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

    function getValidMoves(index, piece, color) {
        var validMoves = [];

        var pieceX = index % boardSize;
        var pieceY = Math.floor(index / boardSize);

        var pieceName = piece === 'pawn' ? color + '_' + piece : piece;

        var pieceRules = moveRules[pieceName];
        for (var i = 0; i < pieceRules.length; i++) {
            var x = pieceX;
            var y = pieceY;
            for (var count = 0; count < pieceRules[i][0]; count++) {
                x += pieceRules[i][1];
                y += pieceRules[i][2];

                if (!isValidIndex(x, y)) {
                    break;
                }

                validMoves.push(y * boardSize + x);
            }
        }

        return validMoves;
    }
}
