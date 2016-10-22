import QtQml 2.2
import QtQuick 2.0
import "Global.js" as Global

QtObject {
    id: pieceMoveLogic

    property int boardSize: Global.boardSize
    property var pieceModel: []
    property var possibleMoves: []
    property var attackMoves: []
    property var captureField: {'index': -1, 'color': '', 'captureIndex': -1}
    property bool isKingCheck: false
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

                if (!isMoveSafeForKing(newIndex, piece)) {
                    break;
                }

                if (Global.isCellOccupied(pieceModel, newIndex)) {
                    var otherPiece = Global.getPieceByIndex(pieceModel, newIndex);

                    // Cell is occupied with enemy
                    if (!Global.isSameColor(otherPiece.color, color)) {
                        if (otherPiece.piece === 'king') {
                            isKingCheck = true;
                        }

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

            if (!isMoveSafeForKing(newIndex, piece)) {
                break;
            }

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
                        if (attackPiece.piece === 'king') {
                            isKingCheck = true;
                        }

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

    function isCellAttacked(pieceModel, index, color) {
        // TODO: make function for x,y from index
        var xCell = index % Global.boardSize;
        var yCell = Math.floor(index / Global.boardSize);

        // Check if cell is under pawn attack
        var pawnName = color + '_' + 'pawn';
        var pieceRules = moveRules[pawnName];
        var xAttack = [xCell + 1, xCell - 1];
        var yAttack = yCell + pieceRules[2];

        for (var j = 0; j < xAttack.length; j++) {
            if (Global.isValidIndex(xAttack[j], yAttack)) {
                var attackIndex = yAttack * boardSize + xAttack[j];

                if (Global.isCellPossibleOccupied(pieceModel, attackIndex)) {
                    var attackPiece = Global.getPossiblePieceByIndex(pieceModel, attackIndex);

                    if (!Global.isSameColor(attackPiece.color, color)
                            && attackPiece.piece === 'pawn') {
                        return true;
                    }
                }
            }
        }

        var attackPieces = [['bishop', 'queen'], ['rook', 'queen'], ['knight'], ['king']];
        for (var i = 0; i < attackPieces.length; i++) {
            pieceRules = moveRules[attackPieces[i][0]];

            // TODO: change 'j'
            for (var j = 0; j < pieceRules.length; j++)
            for (var k = 1; k <= pieceRules[j][0]; k++) {
                var x = xCell + k * pieceRules[j][1];
                var y = yCell + k * pieceRules[j][2];

                if (!Global.isValidIndex(x, y)) {
                    break;
                }

                var newIndex = y * boardSize + x;

                if (Global.isCellPossibleOccupied(pieceModel, newIndex)) {
                    var otherPiece = Global.getPossiblePieceByIndex(pieceModel, newIndex);

                    // Cell is occupied with enemy
                    if (!Global.isSameColor(otherPiece.color, color)) {
                        for (var p = 0; p < attackPieces[i].length; p++) {
                            if (otherPiece.piece === attackPieces[i][p]) {
                                return true;
                            }
                        }
                    }
                    break;
                }
            }
        }
        return false;
    }

    function isMoveSafeForKing(newIndex, piece) {
        var possibleModel = [];
        for (var i = 0; i < pieceModel.count; i++) {
            possibleModel.push({"pieceIndex": pieceModel.get(i).pieceIndex,
                                  "color": pieceModel.get(i).color,
                                  "piece": pieceModel.get(i).piece});
        }

        // Check if this is king move on attacked field
        if (piece.piece === 'king') {
            return isKingMoveSafe(possibleModel, newIndex, piece);
        }

        // Other pieces cannot make king 'open' for attack
        var kingIndex = Global.getPieceIndex(pieceModel, 'king', piece.color);
        for (var j = 0; j < possibleModel.length; j++) {
            if (possibleModel[j].pieceIndex === piece.pieceIndex) {
                possibleModel[j].pieceIndex = newIndex;
            }
        }

        if (isCellAttacked(possibleModel, kingIndex, piece.color)) {
            return false;
        }

        return true;
    }

    function isKingMoveSafe(possibleModel, index, piece) {
        if (isCellAttacked(possibleModel, index, piece.color)) {
            return false;
        }

        for (var i = 0; i < possibleModel.length; i++) {
            if (possibleModel[i].pieceIndex === piece.pieceIndex) {
                possibleModel[i].pieceIndex = index;
            }
        }
        var kingIndex = Global.getPossiblePieceIndex(possibleModel, 'king', piece.color);
        if (isCellAttacked(possibleModel, kingIndex, piece.color)) {
            return false;
        }

        return true;
    }
}


