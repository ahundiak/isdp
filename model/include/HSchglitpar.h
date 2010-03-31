
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:56 $
$Locker:  $
*/

#ifndef HSchglitpar_include
#define HSchglitpar_include 1
/*
 * Defines for the Change Light Parameters command object.
 */

/*
 * State control values - odd numbers because COB doesn't like
 * it when you set *sts to even numbers
 */

#define GET_ORIGIN	4001
#define GET_TARGET	4003
#define GET_RADIUS	4005
#define GET_ANGLE	4007
#define FINISHED_SAVE   4009
#define FINISHED	4011
#define AMBIENT		4013
#define SAVE_AMBIENT	4015
#define LIGHT_SOURCE	4017
#define BAD_LIGHT_NUM	4019
#define PROCESS_FORM	4021
#define GET_LIGHT	4023
#define GET_WINDOW	4025

/*
 * Form control gadget id's.
 */

#define CANCEL          4     /* Cancel button                          */
#define CVRT_TO_WINDOW	5     /* Convert-to-window button		*/
#define SAVE            1     /* Save button                            */

/* Subform gadgets */
#define DIRECTIONAL_VIEW_ICON	11
#define DIRECTIONAL_DB_ICON	13
#define PEN_ICON		12
#define POINT_ICON		14
#define SPOT_ICON		15

#define DIRECTIONAL_VIEW_TEXT	19
#define DIRECTIONAL_DB_TEXT	20
#define PEN_TEXT		21
#define POINT_TEXT		22
#define SPOT_TEXT		23

/* Subform groups */
#define DIRECTIONAL_VIEW_GRP	16
#define DIRECTIONAL_DB_GRP	17
#define POINT_GRP		18
#define PEN_GRP			24
#define SPOT_GRP		25

/*
 * Light source gadget id's.
 */
#define	R_KEYIN		18	/* Field keyins for R,G,B	*/
#define G_KEYIN		19	/*  				*/
#define	B_KEYIN		20	/*				*/

#define HUE_KEYIN	21
#define LUMINANCE_KEYIN	22
#define	SATURATION_KEYIN 23

#define	R_SLIDER	27    /* Red color component slider */
#define	G_SLIDER	26    /* Green color component slider */
#define	B_SLIDER	25    /* Blue color component slider */

#define	HUE_SLIDER	  24	/*  */
#define	LUMINANCE_SLIDER  28	/*  */
#define SATURATION_SLIDER 29	/*  */

#define AMB_GADG	40    /* Ambient light gadget */
#define NON_AMBIENT_GRP 43    /* Self-explanatory */
#define	SCALE_TOGGLE	44    /* Toggle to change from percent scale to absolute scale */
#define LIGHT_TYPE_SELECT	45

#define LIGHT_TYPE_ICON 37

#define DIRECTIONAL_VIEW_SYM	70
#define DIRECTIONAL_DB_SYM	71
#define PEN_SYM			69
#define POINT_SYM		72
#define SPOT_SYM		73

#define STATUS1         10    /* Status field 1                         */
#define RED_KEYIN       18    /* Red keyin field                     */
#define GREEN_KEYIN     19    /* Green keyin field                   */
#define BLUE_KEYIN      20    /* Blue keyin field                    */

#define LIGHT_TYPE_FIELD	30
#define LIGHT_COLOR_SQUARE	31
#define LIGHT_ON_OFF_TOGGLE	33
#define LITE_NUM_KEYIN  38    /* Light number keyin                     */

#define PLACE_MOD_TEXT	11
#define MOD_AMB_TEXT	34

/* Scale options */
#define	PERCENTAGE	0
#define	ABSOLUTE	1

/* Global light source types */
#define DIRECTIONAL_VIEW	0
#define DIRECTIONAL_DB		1
#define POINT			2
#define PEN			3
#define SPOT			4

#endif
