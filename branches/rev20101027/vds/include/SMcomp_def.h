/* $Id: SMcomp_def.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMcomp_def.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMcomp_def.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1998/04/24  17:05:34  pinnacle
 * TR179801040
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/24/98  ah      TR179801040 Raise number of volumes from 10 to 30
 * -------------------------------------------------------------------*/

#ifndef SMcomp_def_include
#define SMcomp_def_include

/**********************************************/
/*
/* 	Definition of the constants used
/* 	for compartment.
/*
/**********************************************/


#define SM_COMPARTMENT	 	1
#define SM_VOLUME	 	2

/* Maximum number of allowed volumes defining an compartment */
#define SM_MAX_ALLOW_VOL	30

#define ALLOC_INCR     	 	15

/* used for SMvol_type message */
#define SPHERE_TYPE 		1
#define BLOCK_TYPE 		2
#define CYLINDR_TYPE 		3
#define POLYHEDRIC_TYPE 	4
#define COMPLEX_TYPE		5		


/*   Compartment properties  						      */
#define SM_CMP_DSP_CMP_COG_PT		0x0001	/* Display compart cog point  */
#define SM_CMP_DSP_CMP_COG_NAME		0x0002	/* Display compart name	      */
#define SM_CMP_DSP_RT_COG_PT		0x0100  /* Display volumes cog points */
#define SM_CMP_DSP_RT_COG_NAME		0x0200  /* Display names with cogs    */

#define SM_CMP_CAL_VOLS			0x1000  /* Compute all volumes	      */
#define SM_CMP_VRF_OVER			0x2000  /* Verify overlapp	      */

#define SM_CMP_X_POS			0x0010  /*  X name justification      */
#define SM_CMP_X_NEG			0x0020  /* -X name justification      */
#define SM_CMP_Y_POS			0x0040  /*  Y name justification      */
#define SM_CMP_Y_NEG			0x0080  /* -y name justification      */

#endif













