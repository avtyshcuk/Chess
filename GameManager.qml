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
    property var attackMoves: logic.attackMoves
    property var captureField: logic.captureField
    property bool isKingInCheck: false

    function hasPieceMoves() {
        // At least one 'move' or 'attack' must be present
        return (Object.keys(moves).length > 1);
    }

    function isCorrectMove(index) {
        if (index in moves) {
            var move = moves[index];
            if (move === 'move' || move === 'attack') {
                return true;
            }
        }
        return false;
    }

    function getMoves(piece) {
        var pieces = Global.getPiecesFromModel(pieceModel);
        moves = logic.getMoves(pieces, piece);

        // Check king safety
        moves = logic.removeKingUnsafeMoves(pieces, piece, moves);
    }

    property var logic: PieceMoveLogic {
        pieceModel: gameManager.pieceModel
    }
}
