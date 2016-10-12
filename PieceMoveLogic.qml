import QtQml 2.2

QtObject {
    id: pieceMoveLogic
    property int boardSize: 8
    property var moveRules: {
        'white_pawn': {'up': 2},
        'black_pawn': {'down': 2},
        'rook': {'up': boardSize, 'down': boardSize}
    }

    function getValidMoves(index, piece, color) {
        var validMoves = [];

        var pieceX = index % boardSize;
        var pieceY = Math.floor(index / boardSize);

        var pieceName = piece === 'pawn' ? color + '_' + piece : piece;
        var pieceRules = moveRules[pieceName];
        for (var direction in pieceRules) {
            switch (direction) {
            case 'up':
                var y = pieceY;
                for (var count = 0; count < pieceRules[direction] && y > 0; count++) {
                    validMoves.push(--y * boardSize + pieceX);
                }
                break;

            case 'down':
                y = pieceY;
                for (count = 0; count < pieceRules[direction] && y < boardSize - 1; count++) {
                    validMoves.push(++y * boardSize + pieceX);
                }
                break;
            }
        }

        return validMoves;
    }
}
