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
                    moveColor = moveColor === 'white' ? 'black' : 'white';
                }
            }
        },
        State {
            name: 'firstClickState'
        }
    ]

    // Initial color 'black' will be reverted in init state
    property string moveColor: 'black'
    property int firstClickIndex: -1
    property int secondClickIndex: -2
    property var currentPiece: null
    property var pieceModel: []
    property var possibleMoves: logic.possibleMoves
    property var attackMoves: logic.attackMoves
    property var captureField: logic.captureField

    function hasPieceMoves() {
        return possibleMoves.length !== 0 || attackMoves.length !== 0;
    }

    function getPossibleMoves(index, piece) {
        logic.getPossibleMoves(index, piece);
    }

    property var logic: PieceMoveLogic {
        pieceModel: gameManager.pieceModel
    }
}
