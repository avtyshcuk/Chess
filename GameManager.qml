import QtQuick 2.0
import "Global.js" as Global

StateGroup {
    id: gameManager

    state: 'initState'
    states: [
        State {
            name: 'initState'
            StateChangeScript {
                script: {
                    moveColor = Global.invertedColor(moveColor);
                    moves = { };
                }
            }
        },
        State {
            name: 'firstClickState'
            StateChangeScript {
                script: {

                }
            }
        }
    ]

    // Initial color 'black' will be reverted in init state
    property string moveColor: 'black'
    property int firstClickIndex: -1
    property int secondClickIndex: -2
    property var currentPiece: null
    property var pieceModel: []
    property var moves: ({})
    property var captureField: {'index': -1, 'captureIndex': -1}
    property var inCaptionPawns: []
    property var castlingFields: [{'kingIndex': -1, 'oldRookIndex': -1, 'newRookIndex': -1}]

    function hasPieceMoves()
    {
        // At least one 'move' or 'attack' must be present
        return (Object.keys(moves).length > 1);
    }

    function isCorrectMove(index)
    {
        if (index in moves) {
            var move = moves[index];
            if (move === 'move' || move === 'attack') {
                return true;
            }
        }
        return false;
    }

    function getMoves(pieces, index)
    {
        moves = logic.getMoves(pieces, index);

        checkPawnCaptionField(index);

        var kingsideCastling = checkKingCastling(index, 3, 1);
        if (kingsideCastling !== -1) {
            castlingFields.push(kingsideCastling);
            moves[kingsideCastling.kingIndex] = 'move';
        }

        var queensideCastling = checkKingCastling(index, 4, -1);
        if (queensideCastling !== -1) {
            castlingFields.push(queensideCastling);
            moves[queensideCastling.kingIndex] = 'move';
        }

        // Check king safety
        moves = logic.removeKingUnsafeMoves(pieces, index, moves);
    }

    function checkKingCastling(index, shift, direction)
    {
        if (currentPiece.piece !== 'king' || currentPiece.wasMoved) {
            return -1;
        }

        // For checking on corectness we have to check
        // Rooks haven't been moved, fields are not attacked
        var x = index % Global.boardSize;
        var y = Math.floor(index / Global.boardSize);
        var pieces = Global.getPiecesFromModel(pieceModel);

        var rookIndex = y * Global.boardSize + x + direction * shift;
        var checkedRook = {'piece': 'rook', 'color': moveColor};
        if (Global.isPieceOnCell(pieces, checkedRook, rookIndex)) {
            checkedRook = Global.getPiece(pieces, rookIndex);
            if (checkedRook.wasMoved) {
                return -1;
            }

            if (logic.isKingUnderAttack(pieces, moveColor)) {
                return -1;
            }

            for (var i = 1; i < shift; i++) {
                var verticalIndex = y * Global.boardSize + (x + direction * i);

                if (Global.isSquareOccupied(pieces, verticalIndex)) {
                    return -1;
                }

                if (logic.isCellUnderAttack(JSON.stringify(pieces), verticalIndex, moveColor)) {
                    return -1;
                }
            }

            var kingIndex = y * Global.boardSize + (x + 2 * direction);
            var oldRookIndex = rookIndex;
            var newRookIndex = y * Global.boardSize + (x + direction);

            return {'kingIndex': kingIndex, 'oldRookIndex': oldRookIndex, 'newRookIndex': newRookIndex};
        }

        return -1;
    }

    function checkPawnCaptionField(index)
    {
        // Pawn can make 'in passing capture', add this field to attack
        if (currentPiece.piece === 'pawn' && inCaptionPawns.indexOf(index) !== -1) {
            moves[captureField.index] = 'attack';
        }
        inCaptionPawns = [];
    }

    function isKingMate()
    {
        var pieces = Global.getPiecesFromModel(pieceModel);
        if (logic.isKingUnderAttack(pieces, moveColor)) {

            // If King in check and no moves possible - mate
            if (!logic.isNextMovePossible(pieces, moveColor)) {
                return false;
            }
        }
        return true;
    }

    property var logic: PieceMoveLogic {
        pieceModel: gameManager.pieceModel
    }
}
