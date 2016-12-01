import QtQuick 2.0
import Qt.labs.settings 1.0

Settings {
    id: storage
    property var initialPosition: {
        'white': {
            'a1':'rook', 'a2':'pawn',
            'b1':'knight', 'b2':'pawn',
            'c1':'bishop', 'c2':'pawn',
            'd1':'queen', 'd2':'pawn',
            'e1':'king', 'e2':'pawn',
            'f1':'bishop', 'f2':'pawn',
            'g1':'knight', 'g2':'pawn',
            'h1':'rook', 'h2':'pawn'
        },
        'black': {
//            'a8':'rook', 'a7':'pawn',
//            'b8':'knight', 'b7':'pawn',
//            'c8':'bishop', 'c7':'pawn',
            'd8':'queen', 'd7':'pawn',
            'e8':'king', 'e7':'pawn',
            'f8':'bishop', 'f7':'pawn',
            'g8':'knight', 'g7':'pawn',
            'h8':'rook', 'h7':'pawn'
        }
    }
}
