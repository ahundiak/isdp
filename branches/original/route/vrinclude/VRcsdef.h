/*********************************************************************

Author	:	momo

Creation:	November 16rd, 1990


		This file contains the definition of all segment constants.
		
	
Change History :


		  date	|  name	|	modification's description
		--------+-------+-----------------------------------

*********************************************************************/

#ifndef	vr_cs_def_include
#define vr_cs_def_include


	/* -- number of maximum predefined component support -- */

#define	VR_NB_CMP_SUPPORTS	4

	/* -- number of predefined segment planes  -- */

#define	VR_NB_DEP_PLANES	3
#define	VR_NB_SEG_PLANES	4

	/* -- number of components on segment  -- */

#define	VR_NB_CMPS		2

	/* -- define to manipulate segment length == */

#define VR_INIT_LENGTH		0x0001
#define	VR_UPDATE_LENGTH	0x0010
#define	VR_GET_LENGTH		0x0100

	/* -- define to manipulate segment constrain type */

#define	VR_INIT_TYPE		0x0001
#define	VR_UPDATE_TYPE		0x0010
#define	VR_GET_TYPE		0x0100

	/* -- define to manipulate segment state */

#define VR_UNKNOWN		-1
#define	VR_UPDATE_COR		0x0001
#define	VR_EVALUATE_CONST	0x0001

#define	VR_MAINTAIN_CONNECT	0x0001

#endif
