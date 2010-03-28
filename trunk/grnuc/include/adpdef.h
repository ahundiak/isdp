/*
NAME
        adpdef.h

DESCRIPTION
        This file contains #defines used by the drawing parameters forms code.
         
HISTORY
        WBC     12/03/87    Creation
*/

#ifndef  adpdef_include
#define  adpdef_include

/*
 *  Active Drawing Parameters form label numbers
 */

#define  ADP_FORM_LABEL       0

#define ADP_LINE_LABEL        914111
#define ADP_WEIGHT_LABEL      914112
#define ADP_LAYER_LABEL       914113

/*
 *  Set Active Drawing Parameters form label numbers
 */

#define  SET_ADP_FORM_LABEL       0

#define  SET_ADP_ACCEPT_BUTTON    1
#define  SET_ADP_PERM_WIN_BUTTON  5
#define  SET_ADP_HELP_BUTTON      6
#define  SET_ADP_MSG_FIELD        10
#define  SET_ADP_LAYER_BUTTON     12
#define  SET_ADP_COLOR_BUTTON     13
#define  SET_ADP_WEIGHT_BUTTON    14
#define  SET_ADP_STYLE_BUTTON     15
#define  SET_ADP_LAYER_NUM        16
#define  SET_ADP_LAYER_NAME       17
#define  SET_ADP_COLOR_NUM        18
#define  SET_ADP_COLOR_NAME       19
#define  SET_ADP_WEIGHT_NUM       20
#define  SET_ADP_WEIGHT_NAME      21
#define  SET_ADP_STYLE_NUM        22
#define  SET_ADP_STYLE_NAME       23
#define  SET_ADP_SCALE_NUM        25
#define  SET_ADP_X_SCALE_NUM      27
#define  SET_ADP_Y_SCALE_NUM      29
#define  SET_ADP_Z_SCALE_NUM      31
#define  SET_ADP_ANGLE_NUM        33
#define  SET_ADP_SMART_SKETCH     34

/*
 *  Active Drawing Parameters (used with struct EX_var_list)
 */

#define  MAX_ADP_VAR_LIST         10

#define  ADP_END_LIST             0
#define  ADP_LAYER_NUM            1
#define  ADP_LAYER_NAME           2
#define  ADP_COLOR_NUM            3
#define  ADP_COLOR_NAME           4
#define  ADP_COLOR_PALETTE        5
#define  ADP_WEIGHT_NUM           6
#define  ADP_STYLE_NUM            7
#define  ADP_ANGLE_NUM            8
#define  ADP_SCALE_NUM            9

#define  ADP_DISPLAY_PARAM        0
#define  ADP_LAYER_PARAM          1
#define  ADP_ANGLE_PARAM          2
#define  ADP_SCALE_PARAM          3

/*
 *  color subform label numbers
 */

#define  GRCOLOR_SUBFORM_LABEL    1

/*
 *  weight subform label numbers
 */

#define  GRWEIGHT_SUBFORM_LABEL   2

#define  GRWEIGHT_LINE            12
#define  GRWEIGHT_FIELD           13
#define  GRWEIGHT_SLIDER          14

/*
 *  style subform label numbers
 */

#define  GRSTYLE_SUBFORM_LABEL    3
#define  GRSTYLE_FIRST_CHECKLIST  13

/*
 *  a line gadget's display attribtes
 */

#define  ADP_LINE_COLOR           0
#define  ADP_LINE_WEIGHT          1
#define  ADP_LINE_STYLE           2

/*
 *  Task List button label on the menu bar
 */

#define TASK_LIST_BUTTON        999999

/*
 *  misc. #defines
 */

#define  NUM_ADP_SUBFORMS         2

#define  GRCOLOR_INDEX            0
#define  GRWEIGHT_INDEX           1
#define  GRSTYLE_INDEX            2

#define  ADP_LIST_LENGTH          2
#define  SET_ADP_LIST_LENGTH      13

#define  NULL_CHAR                '\0'

#define  GR_ON_STATE              0x1
#define  GR_OFF_STATE             0x0

#define  DEFAULT_FORM_X_COORD     -1
#define  DEFAULT_FORM_Y_COORD     -1

#define  SET_ADP_FORM_FILENAME    "SetActDrwParm"
#define  ADP_FORM_FILENAME        "ActDrwParm"
#define  GRCOLOR_FORM_FILENAME    "SetADPColor"
#define  GRWEIGHT_FORM_FILENAME   "SetADPWeight"
#define  GRSTYLE_FORM_FILENAME    "SetADPStyle"

#define  ADP_LAYER                0
#define  ADP_WEIGHT               1
#define  ADP_COLOR                2
#define  ADP_STYLE                3

#define GRCOLOR_PUT_QUEUE_BUTTON  12
#define GRCOLOR_BACKGROUND_BUTTON 14
#define GRCOLOR_PALETTE_LABEL     15
#define GRCOLOR_PALETTE_X1        0
#define GRCOLOR_PALETTE_Y1        45
#define GRCOLOR_PALETTE_X2        260
#define GRCOLOR_PALETTE_Y2        272

#define GR_LO_LAYER               0
#define GR_HI_LAYER               1023
#define GR_LO_COLOR               1
#define GR_HI_COLOR               511
#define GR_LO_WEIGHT              0
#define GR_HI_WEIGHT              31
#define GR_LO_STYLE               0
#define GR_HI_STYLE               255
#define GR_LO_SCALE               0
#define GR_MAXDOUBLE              1.79769313486231470e+308

#endif
