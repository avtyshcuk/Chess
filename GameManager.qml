import QtQuick 2.0

StateGroup {
    id: gameManager

    state: 'initState'
    states: [
        State {
            name: 'initState'
            StateChangeScript {
                script: {
                    gameManager.moveColor = gameManager.moveColor === 'white' ? 'black' : 'white';
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
    property var pieceModel: []
    property var possibleMoves: logic.possibleMoves
    property var attackMoves: logic.attackMoves

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
