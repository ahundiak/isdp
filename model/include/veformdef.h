
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef veformdef_include
#define veformdef_include 1

/****** Defines for the field sizes of the Visible Edges Forms ******/

/* Size of hidden and visible level fields */
#define LEVEL_FIELD_SIZE	10

/* Size of symbology fields */
#define SYMB_FIELD_SIZE	8

/* Defines Common to all sub-forms */
#define CHECK_BUTTON	1
#define X_BUTTON	4
#define STATUS_FIELD   10


/***
Defines for the gadget labels of the Main Visible Edges Form

	Define prefix:  MN
***/
	
#define MN_HIDDEN_LAYER_GROUP	46	/* Gadgets associated with hidden layer */
#define MN_BACKGROUND_GROUP	47	/* Gadgets associated with background mode */
#define MN_GVE_GROUP		32	/* Gadgets associated with Vis Edges */

#define MN_SAVE_AND_RUN  2      	/* Save and run button      */
#define MN_CVRT_TO_WIN   8      	/* Convert to window button */

#define MN_GHE_TOG          20      	/* Do/Don't generate hidden edges toggle */
#define MN_TRACE_TOG        28      	/* Do/Don't trace toggle                 */
#define MN_REF_DISP_TOG     30      	/* Reference file display toggle         */
#define MN_FENCE_CLIP_TOG   34      	/* Fence clipping toggle                 */
#define MN_EXEC_MODE_TOG    39   	/* batch/interactive toggle              */
#define MN_RESULTS_FIELD    41      	/* Server results file name              */
#define MN_SERVER_FIELD     43      	/* Server name field                     */
#define MN_START_TIME_FIELD 35		/* start time field                      */

#define MN_WINDOW_FIELD     17      	/* Window name field               */
#define MN_VIS_LEVEL_FIELD  23     	/* Visible output level field      */
#define MN_HID_LEVEL_FIELD  25      	/* Hidden output level field       */

#define MN_TITLE_TEXT       11		/* Title text gadget of the form */


/***
Defines for the gadget labels of the Symbology Sub-Form

	Define prefix:  SYM
***/

#define SYM_VIS_GROUP	70	/* Visible symbology fields (except first row) */
#define	SYM_HID_GROUP_1	71	/* First row of hidden symbology fields */
#define	SYM_HID_GROUP_2	72	/* Second though sixth rows of hidden symbology fields */

#define SYM_VIS_FIELDS_START	34	/* Starting number of sequential visible symb fields */
#define SYM_HID_FIELDS_START	52	/* Starting number of sequential hidden symb field */
#define SYM_SYMBOLOGY_TEXT	22	/* Text to adjust when going from all to diff symb */

#define SYM_OPTION_TOG       12      		/* Overall/By edge type symbology toggle */

#define SYM_NATURAL_VIS_COLOR     34     	/* Natural edge visible color field   	   */
#define SYM_NATURAL_VIS_STYLE     35     	/* Natural edge visible style field    	   */
#define SYM_NATURAL_VIS_WEIGHT    36     	/* Natural edge visible weight field       */
#define SYM_BOUNDARY_VIS_COLOR    37     	/* Boundary edge visible color field   	   */
#define SYM_BOUNDARY_VIS_STYLE    38     	/* Boundary edge visible style field   	   */
#define SYM_BOUNDARY_VIS_WEIGHT   39     	/* Boundary edge visible weight field  	   */
#define SYM_PARTING_VIS_COLOR     40     	/* Parting line visible color field        */
#define SYM_PARTING_VIS_STYLE     41     	/* Parting line visible style field        */
#define SYM_PARTING_VIS_WEIGHT    42     	/* Parting line visible weight field       */
#define SYM_SHARP_VIS_COLOR       43     	/* Sharp edge visible color field          */
#define SYM_SHARP_VIS_STYLE       44     	/* Sharp edge visible style field          */
#define SYM_SHARP_VIS_WEIGHT      45     	/* Sharp edge visible weight field         */
#define SYM_RULE_VIS_COLOR        46     	/* Rule line visible color field           */
#define SYM_RULE_VIS_STYLE        47     	/* Rule line visible style field           */
#define SYM_RULE_VIS_WEIGHT       48     	/* Rule line visible weight field          */
#define SYM_WIREFRAME_VIS_COLOR   49    	/* Wireframe element visible color field   */
#define SYM_WIREFRAME_VIS_STYLE   50    	/* Wireframe element visible style field   */
#define SYM_WIREFRAME_VIS_WEIGHT  51    	/* Wireframe element visible weight field  */

#define SYM_NATURAL_HID_COLOR     52     	/* Natural edge hidden color field    	   */
#define SYM_NATURAL_HID_STYLE     53     	/* Natural edge hidden style field    	   */
#define SYM_NATURAL_HID_WEIGHT    54     	/* Natural edge hidden weight field        */
#define SYM_BOUNDARY_HID_COLOR    55     	/* Boundary edge hidden color field   	   */
#define SYM_BOUNDARY_HID_STYLE    56     	/* Boundary edge hidden style field   	   */
#define SYM_BOUNDARY_HID_WEIGHT   57     	/* Boundary edge hidden weight field  	   */
#define SYM_PARTING_HID_COLOR     58     	/* Parting line hidden color field         */
#define SYM_PARTING_HID_STYLE     59     	/* Parting line hidden style field         */
#define SYM_PARTING_HID_WEIGHT    60     	/* Parting line hidden weight field        */
#define SYM_SHARP_HID_COLOR       61     	/* Sharp edge hidden color field           */
#define SYM_SHARP_HID_STYLE       62     	/* Sharp edge hidden style field           */
#define SYM_SHARP_HID_WEIGHT      63     	/* Sharp edge hidden weight field          */
#define SYM_RULE_HID_COLOR        64     	/* Rule line hidden color field            */
#define SYM_RULE_HID_STYLE        65     	/* Rule line hidden style field            */
#define SYM_RULE_HID_WEIGHT       66     	/* Rule line hidden weight field           */
#define SYM_WIREFRAME_HID_COLOR   67    	/* Wireframe element hidden color field    */
#define SYM_WIREFRAME_HID_STYLE   68    	/* Wireframe element hidden style field    */
#define SYM_WIREFRAME_HID_WEIGHT  69    	/* Wireframe element hidden weight field   */


/***
Defines for the gadget labels of the Edge Calculation Sub-Form

	Define prefix:  EC
***/

#define EC_PARTING_TOG    14      	/* Parting line calculation toggle       */
#define EC_SHARP_TOG      15      	/* Sharp edge calculation toggle         */


/***
Defines for the gadget labels of the Edge Marking Sub-Form

	Define prefix:  EC
***/

#define EM_NATURAL_TOG   12      	/* Natural edge marking toggle 	   */
#define EM_BOUNDARY_TOG  13      	/* Boundary edge marking toggle    */
#define EM_PARTING_TOG   14      	/* Parting line marking toggle     */
#define EM_SHARP_TOG     15      	/* Sharp edge marking toggle       */
#define EM_RULE_TOG      16      	/* Rule line marking toggle        */
#define EM_WIREFRAME_TOG 17      	/* Wireframe element marking toggle */


/***
Defines for the gadget labels of the Edge Tolerance Sub-Form

	Define prefix:  TOL
***/

#define TOL_GAPPING_GROUP   28  /* Group of gadgets for gapping */
    
#define TOL_TRACE_TOL_FIELD 15  /* Tracing Tolerance field         */

#define TOL_GAPPING_TOG        25	/* Gapping toggle */
#define TOL_GAPPING_DIST_FIELD 27	/* Gapping distance field */


/***
Defines for the gadget labels of the Retrieve Results From Server Form

	Define prefix:  RET
***/

#define RET_JOB_LIST   13   /* Outstanding Job List */
#define RET_ATTACH_TOG 16   /* Attach results toggle */

#endif
