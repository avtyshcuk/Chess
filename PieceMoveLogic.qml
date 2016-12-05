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

    function hasAttackMove(pieces, index, color)
    {
        var piece = Global.getPiece(pieces, index);

        // Cell is occupied with enemy
        if (piece.color !== color) {
            return true;
        }

        return false;
    }

    function updateCaptionField(pieces, captureIndex, color, index, newIndex)
    {
        var pawnPiece = {
            'pieceIndex': captureIndex,
            'color': Global.invertedColor(color),
            'piece': 'pawn'
        }

        if (Global.isPieceOnCell(pieces, pawnPiece)) {
            captureField = {
                'index': index,
                'color': color,
                'captureIndex': newIndex
            }
        }
    }

    function getMoves(pieces, piece)
    {
        var index = piece.pieceIndex;
        var name = piece.piece;
        var color = piece.color;

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

                            // Update 'capture' field for enemy pawn move
                            var captureIndex = attacks[k] + rules[i][2] * boardSize;
                            var pawnIndex = pawnY * boardSize + x;
                            updateCaptionField(pieces, captureIndex, color, pawnIndex, newIndex);
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
        var attackPieces = [['bishop', 'queen'], ['rook', 'queen'], ['knight'], ['king'], ['pawn']];
        for (var i = 0; i < attackPieces.length; i++) {
            var piece = {
                'pieceIndex': index,
                'piece': attackPieces[i][0],
                'color': color,
                'wasMoved': true
            };

            var moves = getMoves(pieces, piece);

            for (var field in moves) {
                if (moves[field] === 'attack') {
                    // Same piece type we can attack, also can attack us
                    var attackPiece = Global.getPiece(pieces, field);

                    if (attackPieces[i].indexOf(attackPiece.piece) !== -1) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function isKingUnderAttack(pieces, color)
    {
        for (var i = 0; i < pieces.length; i++) {
            if (pieces[i].color === color && pieces[i].piece === 'king') {
                if (isCellUnderAttack(pieces, pieces[i].pieceIndex, color)) {
                    return true;
                }
            }
        }
        return false;
    }

    function pseudoPieceMove(pieces, piece, newIndex)
    {
        var pseudoPieces = JSON.parse(pieces);
        for (var i = 0; i < pseudoPieces.length; i++) {
            if (pseudoPieces[i].pieceIndex === Number(newIndex)) {
                pseudoPieces.splice(i, 1);
            }

            if (pseudoPieces[i].pieceIndex === piece.pieceIndex) {
                pseudoPieces[i].pieceIndex = Number(newIndex);
            }
        }
        return pseudoPieces;
    }

    function removeKingUnsafeMoves(pieces, piece, moves)
    {
        for (var move in moves) {
            if (moves[move] === 'current') {
                continue;
            }

            var pseudoPieces = pseudoPieceMove(JSON.stringify(pieces), piece, move);

            if (isKingUnderAttack(pseudoPieces, piece.color)) {
                delete moves[move];
            }
        }
        return moves;
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
//        var kingIndex = Global.getPieceIndex(pieceModel, 'king', color);
//        return isCellModelAttacked(pieceModel, kingIndex, color)
    }
}


