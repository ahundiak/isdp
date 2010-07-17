/*******************************************************************************
/*
/*	Author	:	momo
/*
/*	Creation:	November 19th, 1990
/*
/*
/*		This file contains the definition of all correction constants.
/*		
/*	
/*	Change History :
/*
/*
/*		  date	|  name	|	modification's description
/*		--------+-------+-----------------------------------
/*
/*
/******************************************************************************/

#ifndef	VRplanedef_include
#define VRplanedef_include

#define	VR_DEP_PLANE		0x1000	/* dependent plane template is a plane 		*/
#define	VR_DEP_REF		0x2000  /* dependent plane template is a referential	*/
#define	VR_DEP_CPT		0x4000  /* dependent plane template is a component	*/


#define	VR_DEP_XY_REF		0x0100  /* dependent plane is an XY plane of the ref.	*/
#define	VR_DEP_XZ_REF		0x0200  /* dependent plane is an XZ plane of the ref.	*/
#define	VR_DEP_YZ_REF		0x0400  /* dependent plane is an YZ plane of the ref.	*/

#define VR_CPT_NUM		0x00ff  /* component cpt number				*/
#define VR_ALL_PLANES		0x0f00  /* to create XY, XZ, YZ referential planes	*/

#endif
