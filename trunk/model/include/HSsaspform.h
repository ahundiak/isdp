
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSsaspform_include
#define HSsaspform_include 1

/*
	Defines for the gadget lables on the Change
	Active Shading Style Form
*/

#define HELP            6     /* Help button                  */
#define SAVE           1      /* Save button                  */
#define CANCEL         4      /* Cancel button                */
#define STATUS1	       10     /* Status field		      */
#define SMOOTH_BOX     12     /* Smooth shading check box     */
#define CONST_BOX      13     /* Constant shading check box   */
#define RAST_BOX       14     /* Raster hidden line check box */
#define RVRAST_BOX     15     /* Filled raster check box      */
#define AFILL_BOX      16     /* Area fill check box          */
#define SMOOTH_CYL     17     /* Smooth Shading cylinder      */
#define CONST_CYL      18     /* Constant Shading cylinder    */
#define RAST_CYL       19     /* Raster hiiden line cylinder  */
#define RVRAST_CYL     20     /* Filled raster cylinder       */
#define AFILL_CYL      21     /* Area Fill cylinder           */
#define CVRT_TO_WINDOW 5      /* Convert to window button     */

#define TRANS_GRID	26	/* Toggle WIDE/NARROW translucency grid */

#define HIDDEN_EDGES	39	/* Show hidden edges toggle */
#define SHADE_TOL	25	/* Shading tolerance field  */

#define SHADE_TOL_LOWER	0.25
#define SHADE_TOL_UPPER	16.0

#define TRANS_SLIDER		31	/* 0 - 100	*/
#define REFLECTANCE_SLIDER	32	/* 0 - 100	*/
#define FINISH_SLIDER		33	/* 0 - 255	*/

/* Groups and single gadgets used to distinguish two integrated forms */

#define COPY_SHADING_PARAMETERS_GROUP	57
#define SET_ACTIVE_PARAMETERS_GROUP	58
#define CSP_TITLE			54
#define SASP_TITLE			11
#define TRANS_TOGGLE			42
#define REFLECTANCE_TOGGLE		51
#define FINISH_TOGGLE			52
#define STYLE_TOGGLE			53
#define STORED_PER_ELEMENT		22

#define TO_ORIGINAL_TOGGLE		46
#define TO_OTHERS_TOGGLE		47
#define TO_ACTIVE_TOGGLE		48

#endif
