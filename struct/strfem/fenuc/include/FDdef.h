#ifndef FDdef_included
#define FDdef_included

/* *****************************H H H H H******************************* */
/* Doc: FDdef.h

   Abstract: This header file defines feature descriptor definitions.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      07-23-87	kk		Creation
      04-12-89	ahs		Added #defines for match_fd message
      10-26-91	kk	2.0.0	Upgrade
      10/04/93	kk/raj	2.4.0	Added #defines for non-uniform definitions.
      08-05-96  Ramarao    	1-d mesh enhancements
*/
/* *****************************H H H H H******************************* */

/*	----------------------------------------------------------
 *	The following contains the definitions for the bit positions
 */

#define FD_IS_UNIFORM_DIST	0x0001	/* All fd data is spatially uniform */
#define FD_IS_ELEM_BASED	0x0002  /* FD can be element based ONLY	    */
#define FD_COORD_SYS_USED	0x0004	/* A coord sys is connected and used*/
#define FD_IS_END1_USED		0x0008  /* Introduced for tapered beams.
					 * Stored with FEfdorient to indicate
					 * if end1 of tapered beam is at zero
					 * end of the edge. - Ramarao 08/05/96
					 */

/*	----------------------------------------------------------
 *	The Following are Bit Settings Used for 'match_mask' Argument in
 *	FEfd.match_fd message
 */

#define	FD_CAT	0x01
#define	FD_TYP	0x02
#define	FD_LID	0x04
#define	FD_DIM	0x08
#define	FD_PRP	0x10
#define	FD_UNF	0x20
#define	FD_VAR	0x40
#define	FD_ALL	FD_CAT | FD_TYP | FD_LID | FD_DIM | \
			FD_PRP | FD_UNF | FD_VAR

/*	----------------------------------------------------------
 *	Define "Invalid" or "NULL" values
 */

#define	UNDEFINED_DBL		-1.E100	/* Undefined double value		*/
#define	NULL_FDCASE_ID		-1	/* FD case ID for Feature Descriptors	*/

#define	FD_MAX_FDCNAME_SIZE	17	/* Size of names for fd cases 		*/

/*	----------------------------------------------------------
 *	Define nominal zeros
 */
	
#define 	EFFECTIVE_ZERO 1e-30
#define 	RELATIVE_ZERO  1e-10

/*	----------------------------------------------------------
 *	Modes of Non-uniform definition
 */

#define	FD_TABLE		1	/* 1-D				*/
#define	FD_CURVE		2	/* 1-D				*/
#define	FD_SURFACE		3	/* 2-D				*/
#define	FD_EXPRESSION		4	/* 1-D, 2-D			*/
#define	FD_FIELD		5	/* All-D			*/
#define	FD_COONS		6	/* 2-D, 3-D			*/

/*
**  Modes for FD_TABLE
*/
#define	FD_RELATIVE		1	/* Independent variable : 0 - 1	*/
#define	FD_ABSOLUTE		2	/* Take as absolute		*/

/*
**  Modes for FD_CURVE
*/
#define	FD_NORMAL_PLANE		1	/* Define with normal plane	*/
#define	FD_PARL_PLANE		2	/* Define with parallel plane	*/
#define	FD_CURV_ISOPARAM	3	/* Define with isopar pts	*/

#define	FD_FORWARD		1	/* Forward direction on curve	*/
#define	FD_BACKWARD		2	/* Backward direction on curve	*/

/*
**  Modes for FD_SURFACE
*/
#define	FD_NORMAL_LINE		1	/* Define with normal line	*/
#define	FD_PARL_LINE		2	/* Define with parallel line	*/
#define	FD_SURF_ISOPARAM	3	/* Define with isopar pts	*/

#endif
