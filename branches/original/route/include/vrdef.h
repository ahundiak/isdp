/*********************************************************************

Author	:	Bruno Demars (ISDC, Paris)

Creation:	18-Jul-92


		This file contains all needed predefined values
		that can be given as arguments of I/ROUTE programing
		macros.

	
*********************************************************************/
#ifndef	vr_def_include
#define vr_def_include

			/* -------- */
			/* Products */
			/* -------- */

#define VR_HVAC 	0

#define VR_PIPING 	1

#define VR_RWAY		2

#define VR_ELECTRIC     3

#define VR_FIBER        4

#define VR_EQUIPMENT	5



		/* ----------------------------------- */
		/* Connection points attributes values */
		/* ----------------------------------- */

#define		VR_IN		0x0000	/* Flow getting inside the component
					   through the connection point */
#define		VR_OUT		0x0010	/* Flow getting outside the component
					   through the connection point */

#endif
