/*
 *   define all the forms we will process
 */
#define MEASURE_DISTANCE_FORM     "MeasDist"
#define MEASURE_ANGLE_FORM        "MeasAngle"
#define MEASUREMENT_FORM          STATUS_FORM

/*
 * define all output fields for the forms
 */
#define DIST_PREV_TO_CURR_FLD     14
#define DIST_BASE_TO_CURR_FLD     13
#define DIST_CUMULATIVE_FLD       12
#define BASE_POINT_X_FLD          21 
#define BASE_POINT_Y_FLD          22
#define BASE_POINT_Z_FLD          23
#define CURRENT_POINT_X_FLD       24
#define CURRENT_POINT_Y_FLD       25
#define CURRENT_POINT_Z_FLD       26
#define BASE_TO_CURRENT_X_FLD     42
#define BASE_TO_CURRENT_Y_FLD     43
#define BASE_TO_CURRENT_Z_FLD     44
#define PREV_TO_CURRENT_X_FLD     45
#define PREV_TO_CURRENT_Y_FLD     46
#define PREV_TO_CURRENT_Z_FLD     47
#define MEASURE_ANGLE_FLD         14
#define COMPLEMENT_ANGLE_FLD      13

/*
 * define check list for line place, line display or no draw
 * checklist
 */
#define DRAW_LINE                 60
#define PLACE_LINE                61
#define NO_DRAW                   62

/*
 * define application toggles and buttons on the forms
 */
#define READOUT_BUTTON            51
#define ACTIVE_REF_TOGGLE         31
#define TRUE_APPARENT_TOGGLE      30
#define SET_ACTIVE_ANGLE          65
#define CLOCKWISE_TOGGLE          66
#define ABS_LOCAL_TOGGLE          50 

/*
 * define window buttons on the forms
 */
#define PUSH_EVENT_BUTTON         48
#define CUT_VALUE_BUTTON          49
         
#define HELP_BUTTON                4
#define ACCEPT_BUTTON              3
#define STANDARD_HELP_BUTTON      99
#define STANDARD_ACCEPT_BUTTON     1

/*
 * define message field on the forms
 */
#define MSG_FLD                 10

/*
 * define how many fields are on each for we will process
 */
#define NUM_DISTANCE_OUTPUT_FLDS  15
#define NUM_ANGLE_OUTPUT_FLDS      2
#define NUM_DISTANCE_TOGGLES       5 /* app flag, ref files, abs_loc flag */
#define NUM_ANGLE_TOGGLES          2 /* apparent flag, reference files,
                                        angle set, clockwise flag */
#define NUM_CURSOR_OUTPUT_FLDS   11


#define CURRENT_MEAS_IND          0
#define DIST_BASE_TO_CURR_IND     1
#define COMPLEMENT_ANGLE_IND      1
#define CUMULATIVE_MEAS_IND       2

#define BASE_POINT_X_IND          3 
#define BASE_POINT_Y_IND          4
#define BASE_POINT_Z_IND          5

#define CURR_POINT_X_IND          6
#define CURR_POINT_Y_IND          7
#define CURR_POINT_Z_IND          8

#define DELTA_BASE_TO_CURR_X_IND  9
#define DELTA_BASE_TO_CURR_Y_IND  10
#define DELTA_BASE_TO_CURR_Z_IND  11

#define DELTA_PREV_TO_CURR_X_IND  12
#define DELTA_PREV_TO_CURR_Y_IND  13
#define DELTA_PREV_TO_CURR_Z_IND  14

/*
 *  Stuff specific to COmeasure methods. (added in GR240)
 */

#define GR_COMEAS_NUM_EVENTS                     ( 7)
#define GR_COMEAS_FIELD_SIZE                     (80)
#define GR_COMEAS_FIELD_DIM                      (30)

#define GR_COMEAS_DISPLAY_BASE_EVENT             0x01
#define GR_COMEAS_DISPLAY_CURRENT_EVENT          0x02
#define GR_COMEAS_DISPLAY_DELTA_BASE_CURRENT     0x04
#define GR_COMEAS_DISPLAY_DELTA_PREV_CURRENT     0x08
#define GR_COMEAS_DISPLAY_BASE_CURRENT_DISTANCE  0x10
#define GR_COMEAS_DISPLAY_CURRENT_DISTANCE       0x20



