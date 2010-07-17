#ifndef PO_define
#define PO_define

/*****************************************************************************

   Doc: POdef.h

   Abstract: This file contains the commonly used POST system #defined
	values.

   History:

	Date		Who		Why
	---------	------		----------------------------------
	28 Jan 88	am		Creation
	23 Feb 89	msl		Update for 1.2
	10 May 89	msl		Added 1D,2D,3D,ALL_ELEM CATAGORIES
	23 Oct 89	msl		Added PO_nD_TYPE for dimension masks
	 2 Nov 89	msl		Added display types
	28 Nov 89	msl		Added Post Elem types
	18 Sep 90	msl		Added Shape Definitions
	16 May 91	msl		Changed NUM_PO_DEFS from 5 to 11
						(2.0 database change )
	22 Dec 91	qxn		Added Post Mesh types (MODEL or ARCHIVE)
	30 Dec 91	qxn		Added CONTOUR_SEC, FILLED_CONTOUR_SEC
	02 Jan 92	qxn		Changed NUM_PO_DEFS from 11 to 13	
	28 Sep 92	qxn		defined attribute dins ATT_...
	19 May 94	qxn		defined bit patterns for results set types
 ****************************************************************************/

#define	UNDEFINED_DBL	-1.E100 	/* Undefined double value  */
#define MAXDOUBLE	1.79769313486231470e+308
#define MINDOUBLE	.22250738585072027e-307
#define BIGMINUS	-1.0000000000000000e+306

#define CAT_MATCH( cat, cat2 ) ( cat==-1 || cat==ALL_CATEGORY || cat==cat2 || \
	    (cat == ALL_ELEM_CATEGORY && ( cat2 == ELEM_1D_CATEGORY ||	\
					   cat2 == ELEM_2D_CATEGORY ||	\
					   cat2 == ELEM_3D_CATEGORY ) ) )

/* --- Post Product types --- */
#define DS_PROD		3001	/* product supports deformed shape (ex. FEM) */
#define NO_DS_PROD	3002	/* product does NOT support deformed shape (FLOW) */


/* --- Post Data Operation types --- */

#define	NUM_PO_DEFS		13
#define	DEFORMED_SHAPE		0
#define	NODAL_VECTOR		1
#define	ELEMENT_VECTOR		2
#define	CONTOUR			3
#define	COLOR_CODE		4
#define NODE_LABEL		5
#define ELEMENT_LABEL		6
#define FILLED_CONTOUR		7
#define DEFLECTION_ANIM		8
#define TIME_HIST_ANIM		9
#define TIME_HIST_ANIM_CON	10
#define	CONTOUR_SEC		11
#define	FILLED_CONTOUR_SEC	12
#define DEFORMED_SHAPE_SEC	13

#define STRESS_XSFORM		20
#define STRAIN_XSFORM		21
#define LDCS_CMBN		22
#define GRAF_HISTORY		23
#define GRAF_NODE		24
#define AVERAGE_ELEM		25
#define DEF_ANIM_CON		26
#define PRINCIPAL_STRESS	27
#define REVIEW_BY_NAME		28

/* --- Data categories --- */

#define NODE_CATEGORY		0
#define ELEM_1D_CATEGORY	1
#define ELEM_2D_CATEGORY	2
#define ELEM_3D_CATEGORY	3
#define ALL_ELEM_CATEGORY	4	
#define OTHER_CATEGORY		5
#define ALL_CATEGORY		6


/* --- Display Types (for POgrgrp's, Deformed Shapes, Contours, etc) --- */

#define PO_WFRAME	1
#define PO_SHADED	2


/* --- Types of POcvt's and POgrp_crit's --- */

#define PO_ABSOLUTE	0	/* val = val				*/
#define PO_REL_TO_RNG	1	/* val = data_min + (val/100 * range)	*/
#define PO_REL_TO_MAX	2	/* val = val/100 * data_max		*/
				/*	range = data_max - data_min	*/


/* --- Region definitions --- */

#define PO_INSIDE	0
#define PO_OUTSIDE	1

/* --- Post mesh types --- */

#define ARCHIVE_MESH 	0
#define DEFAULT_PMAN 	0xffffffff	/* ( -1 ) */
#define MODEL_MESH 	0x00000001
#define PO_MODAL_RS	0x00000002      /* modal dynamic vs. static */
#define PO_THERMAL_RS	0x00000004	/* thermal vs. structural */

/* analysis type bits */

#define DEF_CONFIG	3

/* attribute dins */
#define ATT_XCOORD  	-10
#define ATT_YCOORD	-11
#define ATT_ZCOORD	-12
#define ATT_UID		-13	/* node/element uid */
#define ATT_THICK	-14	/* plate thickness */
#define ATT_SHAPE	-15	/* element shape factor */
#define ATT_FORCE	-16 	/* force magnitude */

#define POMAX_EL_ATT	5	/* total # of element attributes supported now */
#define POMAX_ND_ATT	4	/* total # of node attributes supported now */
#endif
