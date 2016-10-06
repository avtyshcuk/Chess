import QtQuick 2.4

Item {
    id: piece

    property alias source: pieceImage.source

    Image {
        id: pieceImage
        anchors.fill: parent
    }

    NumberAnimation on x {
        id: xAnimation
        running: false
    }
}



