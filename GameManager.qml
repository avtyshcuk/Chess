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
    property var validMoves: []
}
