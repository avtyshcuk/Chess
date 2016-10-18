import QtQml 2.2
import "Global.js" as Global

QtObject {
    id: pieceMoveLogic

    property int boardSize: Global.boardSize
    property var pieceModel: []
    property var possibleMoves: []
    property var attackMoves: []
    property var captureField: {'index': -1, 'color': '', 'captureIndex': -1}
    property var moveRules: {
        'white_pawn': [2, 0, -1],
        'black_pawn': [2, 0, 1],
        'knight': [[1, -2, -1], [1, -2, 1],
                   [1, -1, -2], [1, -1, 2],
                   [1, 2, -1], [1, 2, 1],
                   [1, 1, -2], [1, 1, 2]],
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

    function getPossibleMoves(index, piece) {
        possibleMoves = [];
        attackMoves = [];

        var pieceX = index % Global.boardSize;
        var pieceY = Math.floor(index / Global.boardSize);

        var color = piece.color;
        var pieceName = piece.piece === 'pawn' ? color + '_' + piece.piece : piece.piece;
        var pieceRules = moveRules[pieceName];

        if (piece.piece === 'pawn') {
            return getPawnMoves(pieceX, pieceY, piece, pieceRules);
        }

        for (var i = 0; i < pieceRules.length; i++) {
            for (var j = 1; j <= pieceRules[i][0]; j++) {
                var x = pieceX + j * pieceRules[i][1];
                var y = pieceY + j * pieceRules[i][2];

                if (!Global.isValidIndex(x, y)) {
                    break;
                }

                var newIndex = y * boardSize + x;

                if (Global.isCellOccupied(pieceModel, newIndex)) {
                    var otherPiece = Global.getPieceByIndex(pieceModel, newIndex);

                    // Cell is occupied with enemy
                    if (!Global.isSameColor(otherPiece.color, color)) {
                        attackMoves.push(newIndex);
                    }
                    break;
                }

                possibleMoves.push(newIndex);
            }
        }
    }

    function getPawnMoves(x, y, piece, pieceRules) {
        var maxMove = piece.wasMoved !== true ? pieceRules[0] : pieceRules[0] - 1;

        for (var i = 1; i <= maxMove; i++) {
            var newX = x + i * pieceRules[1];
            var newY = y + i * pieceRules[2];

            if (!Global.isValidIndex(newX, newY)) {
                break;
            }

            var newIndex = newY * boardSize + newX;

            if (Global.isCellOccupied(pieceModel, newIndex)) {
                break;
            }

            possibleMoves.push(newIndex);
        }

        if (captureField.index !== -1) {
            attackMoves.push(captureField.index);
        }

        var xAttack = [x + 1, x - 1];
        var yAttack = y + pieceRules[2];

        for (var j = 0; j < xAttack.length; j++) {
            if (Global.isValidIndex(xAttack[j], yAttack)) {
                var attackIndex = yAttack * boardSize + xAttack[j];

                if (Global.isCellOccupied(pieceModel, attackIndex)) {
                    var attackPiece = Global.getPieceByIndex(pieceModel, attackIndex);

                    if (!Global.isSameColor(attackPiece.color, piece.color)) {
                        attackMoves.push(attackIndex);
                    }
                }
            }

            // If move is long "in passing capture" is possible
            if (possibleMoves.length == 2) {
                var captureIndex = (yAttack + pieceRules[2]) * boardSize + xAttack[j];

                if (Global.isCellOccupied(pieceModel, captureIndex)) {
                    var capturePiece = Global.getPieceByIndex(pieceModel, captureIndex);

                    if (!Global.isSameColor(capturePiece.color, piece.color)
                            && capturePiece.piece === 'pawn') {
                        captureField.index = yAttack  * boardSize + x;
                        captureField.color = piece.color;
                        captureField.captureIndex = newIndex;
                    }
                }
            }
        }
    }
}


