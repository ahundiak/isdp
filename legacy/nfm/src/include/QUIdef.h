#ifndef QUIDEF_H
#define QUIDEF_H

#ifndef TRUE
#define TRUE  1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#define QUI_MAX_MESSAGE   512

/*  Form label  */

#define QUI_FORM_LABEL    999

/*  Form name  */

#define QUI_FORM          "QUIform"

/*  Message file  */

#define QUI_MESSAGE_FILE  "QUImsg.msg"

/*  Number of 'rows' of field gadgets  */

#define NUMBER_OF_ROWS           8
#define LOGICAL_OPERATORS        7

#define QUI_OPSTR1 "="
#define QUI_OPVAL1  1
#define QUI_OPSTR2 "!="
#define QUI_OPVAL2  2
#define QUI_OPSTR3 "<"
#define QUI_OPVAL3  3
#define QUI_OPSTR4 ">"
#define QUI_OPVAL4  4
#define QUI_OPSTR5 "<="
#define QUI_OPVAL5  5
#define QUI_OPSTR6 ">="
#define QUI_OPVAL6  6
#define QUI_OPSTR7 "><"
#define QUI_OPVAL7  7

#define QUI_CHAR_TYPE       0
#define QUI_SMALLINT_TYPE   1
#define QUI_INTEGER_TYPE    2
#define QUI_DOUBLE_TYPE     3
#define QUI_REAL_TYPE       4
#define QUI_TIMESTAMP_TYPE  5

#define QUI_MAX_ATTR_NUM         50
#define QUI_MIN_VALUE_LEN        19
#define QUI_MAX_GADGET_NUMBER  1000

/*  Possible values for display configuration mask  */

#define DELETE_QUERY_BUTTON_MASK 0x00000001
#define BROWSE_BUTTON_MASK       0x00000002
#define REVISION_TOGGLE_MASK     0x00000004
#define CHECKIN_TOGGLE_MASK      0x00000008
#define BEZEL_MESSAGE_STYLE_MASK 0x00000010
#define USE_LU_TABLE_FORM_MASK   0x00000020
#define USE_CATALOG_FIELD_MASK   0x00000040
#define OWNER_TOGGLE_MASK        0x00000080

/*  Where to read attribute lists from  */

#define QFILE  (short) 1
#define QDB    (short) 2

/*  Global QUI structure  */

extern struct QUIglobal_st QUIglobal;

#endif
