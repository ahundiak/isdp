/*
** include file for ECtpanalyz
*/

/*
 * definition of states for execute method
 */
#define STATE_START             0
#define STATE_INVOKE            1
#define STATE_SETUP_FORM        2
#define STATE_ADD_SURFACES      3
#define STATE_DELETE_SURFACES   4

#define STATE_IDENTIFY_SURFACE  3
#define STATE_ACCEPT_SURFACE    4
#define STATE_CONTINUE_DELTE    5
#define STATE_IDENTIFY_EDGE     7
#define STATE_ACCEPT_EDGE       8
#define STATE_SETUP_FORM2       9
#define STATE_ACCEPT_2_EDGE    10

/*
 * status values for form1_visible 
 */
#define FORM1_DOES_NOT_EXISTS 0
#define FORM1_VISIBLE         1
#define FORM1_INVISIBLE       2


/*
 * definitions corresponding to forms
 */
#define TOP_FORM1	1

/* Gadgets (as generated from fb) */

#define FIELD1        18	/* Current Function */
#define TOGGLE1       58	/* Graphic Permanent/Temporary */

#define GROUP_ADD_DEL 73
#define BUTTON1       12	/* Add Surface Set */
#define BUTTON2       45	/* Delete Surface Set */

#define BUTTON3       66	/* Recalculate Set */
#define BUTTON4       20	/* Drop Set */

#define GROUP_ANALYZE 40        /* Analyze Adjacency */
#define CHLIST_A1     17	/* Outer Boundary */
#define FIELD_A1_TO   41
#define FIELD_A1_LY   33
#define FIELD_A1_CO   78
#define FIELD_A1_WT   74
#define FIELD_A1_ST   34
#define CHLIST_A2     44	/* Distance */
#define FIELD_A2_TO   79
#define FIELD_A2_LY   80
#define FIELD_A2_CO   76
#define FIELD_A2_WT  100
#define FIELD_A2_ST  103
#define CHLIST_A3     37	/* Normal */
#define FIELD_A3_TO   75
#define FIELD_A3_LY   81
#define FIELD_A3_CO   98
#define FIELD_A3_WT  101
#define FIELD_A3_ST  104
#define CHLIST_A4     46	/* Radius */	
#define FIELD_A4_TO   77
#define FIELD_A4_LY   89
#define FIELD_A4_CO   99
#define FIELD_A4_WT  102
#define FIELD_A4_ST  105
#define GROUP_RAMIF   85	/* Ramifications -- Not implemented yet */
#define CHLIST_A5     47	/* Ramifications */	
#define FIELD_A5_LY   87
#define FIELD_A5_CO   90
#define FIELD_A5_WT   91
#define FIELD_A5_ST   92
#define TOGGLE_A1     63 	/* Radius Diagnosis Option */
#define TOGGLE_A2     59	/* Interior of Composite Surfaces */
#define FIELD_A_NOP   62	/* Number of Points */

#define GROUP_INVEST  14        /* Investigate Edge Match */
#define CHLIST_I1     26	/* Distance */	
#define FIELD_I1_TO   43
#define FIELD_I1_LY   13
#define FIELD_I1_CO   29
#define FIELD_I1_WT   32
#define CHLIST_I2     15	/* Normal */	
#define FIELD_I2_TO   51
#define FIELD_I2_LY   49
#define FIELD_I2_CO   54
#define FIELD_I2_WT   55
#define CHLIST_I3     21	/* Radius */	
#define FIELD_I3_TO   52
#define FIELD_I3_LY   64
#define FIELD_I3_CO   67
#define FIELD_I3_WT   68
#define TOGGLE_I1     24 	/* Radius Diagnosis Option */
#define FIELD_I_NOP   69	/* Number of Points */
#define FIELD_I_FILE  82	/* File Name for results */
#define FIELD_I_HEAD  94	/* Header Line for Result File */

#define TEXT1         31	/* Current Function */

/* highlight mode for selected elements */
/* see file grmacros.h for explanation */
#define HIGHLIGHT_MODE GRhhd 
/* #define HIGHLIGHT_MODE GRhd */

