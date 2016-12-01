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
        'white_pawn': [[2, 0, -1]],
        'black_pawn': [[2, 0, 1]],
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

    function hasAttackMove(pieces, index, color) {
        var piece = Global.getPiece(pieces, index);

        // Cell is occupied with enemy
        if (piece.color !== color) {
            return true;
        }

        return false;
    }

    function getMoves(piece)
    {
        var index = piece.pieceIndex;
        var name = piece.piece;
        var color = piece.color;

        var pieces = Global.getPiecesFromModel(pieceModel);
        var x = index % boardSize;
        var y = Math.floor(index / boardSize);

        // Possible moves: 'current', 'move', 'attack'
        var moves = { };
        moves[index] = 'current';

        // Logic for pawns is quite different
        var isPawn = name === 'pawn';
        name = isPawn ? color + '_' + name : name;

        var rules = moveRules[name];

        if (isPawn) {
            rules[0][0] = piece.wasMoved ? 1 : 2;
        }

        for (var i = 0; i < rules.length; i++) {
            for (var j = 1; j <= rules[i][0]; j++) {
                var newX = x + j * rules[i][1];
                var newY = y + j * rules[i][2];

                if (!Global.isValidIndex(newX, newY)) {
                    break;
                }

                var newIndex = newY * boardSize + newX;

                // pawn 'delta', check possible pawn attack fields
                if (isPawn && rules[0][0] === j) {

                    // Pawn can make 'in passing capture', add this field to attack
                    if (captureField.index !== -1) {
                        moves[captureField.index] = 'attack';
                    }

                    var pawnY = y + rules[i][2];
                    var attacks = [pawnY * boardSize + (x + 1), pawnY * boardSize + (x - 1)];
                    for (var k = 0; k < attacks.length; k++) {
                        if (Global.isSquareOccupied(pieces, attacks[k])) {
                            if (hasAttackMove(pieces, attacks[k], color)) {
                                moves[attacks[k]] = 'attack';
                            }
                        }

                        // If move is long "in passing capture" is possible
                        if (!piece.wasMoved) {
                            var captureIndex = attacks[k] + rules[i][2] * boardSize;

                            if (Global.isCellOccupied(pieces, captureIndex)) {
                                var capturePiece = Global.getPiece(pieces, captureIndex);

                                if (capturePiece.color !== color
                                        && capturePiece.piece === 'pawn') {
                                    captureField.index = pawnY  * boardSize + x;
                                    captureField.color = color;
                                    captureField.captureIndex = newIndex;
                                }
                            }
                        }
                    }
                }

                // Move is 'attack' move, enemy piece on the way
                if (Global.isSquareOccupied(pieces, newIndex)) {
                    if (hasAttackMove(pieces, newIndex, color)) {

                        // Again pawn 'delta', pawns don't attack straight forward
                        if (!isPawn) {
                            moves[newIndex] = 'attack';
                        }
                    }
                    break;
                }

                // Move is possible and no 'attack'
                moves[newIndex] = 'move';
            }
        }

        return moves;
    }

    function isCellUnderAttack(pieces, index, color)
    {
        var attackColor = color === 'white' ? 'black' : 'white';
        var attackPieces = [['bishop', 'queen'], ['rook', 'queen'], ['knight'], ['king'], ['pawn']];
        for (var i = 0; i < attackPieces.length; i++) {
            var piece = {
                'pieceIndex': index,
                'piece': attackPieces[i][0],
                'color': attackColor,
                'wasMoved': true
            };

            var moves = getMoves(piece);
            for (var fields in moves) {
                if (moves[fields] === 'attack') {
                    var attackPiece = Global.getPiece(pieces, fields);
                    if (attackPieces[i].indexOf(attackPiece.piece) !== -1) {
                        return true;
                    }
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

    function isNextMovePossible(color) {
        var possibleModel = [];
        for (var i = 0; i < pieceModel.count; i++) {
            possibleModel.push({"pieceIndex": pieceModel.get(i).pieceIndex,
                                  "color": pieceModel.get(i).color,
                                  "piece": pieceModel.get(i).piece});
        }

        for (var k = 0; k < possibleModel.length; k++) {
            if (possibleModel[k].color === color) {

                var pieceX = possibleModel[k].pieceIndex % Global.boardSize;
                var pieceY = Math.floor(possibleModel[k].pieceIndex / Global.boardSize);


                var pieceName = possibleModel[k].piece === 'pawn' ? color + '_' + possibleModel[k].piece :
                                                                        possibleModel[k].piece;
                var pieceRules = moveRules[pieceName];

//                if (piece.piece === 'pawn') {
//                    return getPawnMoves(pieceX, pieceY, piece, pieceRules);
//                }

                for (var i = 0; i < pieceRules.length; i++) {
                    for (var j = 1; j <= pieceRules[i][0]; j++) {
                        var x = pieceX + j * pieceRules[i][1];
                        var y = pieceY + j * pieceRules[i][2];

                        if (!Global.isValidIndex(x, y)) {
                            break;
                        }

                        var newIndex = y * boardSize + x;

                        if (!isMoveSafeForKing(newIndex, possibleModel[k])) {
                            break;
                        }

                        return true;
                    }
                }
            }
        }

        return false;
    }


    function isKingInCheck(color) {
        var kingIndex = Global.getPieceIndex(pieceModel, 'king', color);
        return isCellModelAttacked(pieceModel, kingIndex, color)
    }
}


