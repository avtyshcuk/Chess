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
//    property var attackMoves: logic.attackMoves
    property var captureField: {'index': -1, 'captureIndex': -1}
    property var inCaptionPawns: []

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

        // Pawn can make 'in passing capture', add this field to attack
        if (currentPiece.piece === 'pawn' && inCaptionPawns.indexOf(index) !== -1) {
            moves[captureField.index] = 'attack';
        }
        inCaptionPawns = [];

        // Check king safety
        moves = logic.removeKingUnsafeMoves(pieces, index, moves);
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
