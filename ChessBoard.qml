import QtQuick 2.0

Item {
    id: root
    anchors.fill: parent
    property int boardSize: 8

    Grid {
        id: chessGrid
        anchors.fill: parent
        columns: boardSize
        rows: boardSize

        Repeater {
            model: boardSize * boardSize

            Rectangle {
                id: rect
                width: chessGrid.width / boardSize
                height: chessGrid.height / boardSize

                property bool isFirstCellWhite: Math.floor(index / boardSize) % 2
                property bool indexParity: index % 2
                color: isFirstCellWhite ? (indexParity ? "white" : "black") :
                                          (indexParity ? "black" : "white")
            }
        }
    }
}

