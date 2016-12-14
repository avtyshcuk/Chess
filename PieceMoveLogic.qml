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

    function getMoves(pieces, index)
    {
        var name = pieces[index].piece;
        var color = pieces[index].color;

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
            rules[0][0] = pieces[index].wasMoved ? 1 : 2;
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
                    var pawnY = y + rules[i][2];

                    var attacks = [ ];
                    if (Global.isValidIndex(x + 1, pawnY)) {
                        attacks.push(pawnY * boardSize + (x + 1));
                    }

                    if (Global.isValidIndex(x - 1, pawnY)) {
                        attacks.push(pawnY * boardSize + (x - 1));
                    }

                    for (var k = 0; k < attacks.length; k++) {
                        if (Global.isSquareOccupied(pieces, attacks[k])) {
                            if (hasAttackMove(pieces, attacks[k], color)) {
                                moves[attacks[k]] = 'attack';
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

    function isCellUnderAttack(piecesCopy, index, color)
    {
        var pieces = JSON.parse(piecesCopy);

        var attackPieces = [['bishop', 'queen'], ['rook', 'queen'], ['knight'], ['king'], ['pawn']];
        for (var i = 0; i < attackPieces.length; i++) {
            pieces[index] = {
                'piece': attackPieces[i][0],
                'color': color,
                'wasMoved': true
            }

            var moves = getMoves(pieces, index);

            for (var field in moves) {
                if (moves[field] === 'attack') {
                    // Same type of piece we can attack, also can attack us
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
        for (var k in pieces) {
            if (pieces[k].color === color && pieces[k].piece === 'king') {
                var piecesCopy = JSON.stringify(pieces);
                if (isCellUnderAttack(piecesCopy, k, color)) {
                    return true;
                }
            }
        }

        return false;
    }

    function pseudoPieceMove(pieces, index, newIndex)
    {
        var pseudoPieces = JSON.parse(pieces);
        var piece = pseudoPieces[index];

        delete pseudoPieces[index];
        pseudoPieces[newIndex] = piece;

        return pseudoPieces;
    }

    function removeKingUnsafeMoves(pieces, index, moves)
    {
        for (var move in moves) {
            if (moves[move] === 'current') {
                continue;
            }

            var pseudoPieces = pseudoPieceMove(JSON.stringify(pieces), index, move);

            if (isKingUnderAttack(pseudoPieces, pieces[index].color)) {
                delete moves[move];
            }
        }

        return moves;
    }

    function isNextMovePossible(pieces, color)
    {
        for (var index in pieces) {
            if (pieces[index].color !== color) {
                continue;
            }

            var moves = getMoves(pieces, index);

            var safeMoves = removeKingUnsafeMoves(pieces, index, moves);
            if (Object.keys(safeMoves).length > 1) {
                return true;
            }
        }

        return false;
    }
}


