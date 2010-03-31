#ifndef ASSEMCONSTR_H
#define ASSEMCONSTR_H

/*---------------------------------------------------------------------------+
 |                                                                           |
 | The constants below are the assembly constraints currently                |
 | supported within EMS.                                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/* Define a NULL constraint */
#define	NULL_CONSTR			0xffff


/* Constant for NULL Basis */
#define NULL_BASIS_ID			0

/*
 * The following are assembly constraints
 */
#define		MATE		0x0001
#define		ALIGN		0x0002
#define 	INSERT		0x0004
#define 	GROUND 		0x0008

/*
 * The following are the constant defines for the relative angle between
 * constraints. 
 */
#define		ANG_PERP		0x0001
#define		ANG_PAR			0x0002
#define		ANG_ACUTE	        0x0004

/*
 * The following is the complete enumeration of proper basis to position a part 
 * in space in terms of the constraints that can be incident on 
 * the part and the relative angles between the state vectors 
 * associated with the constraints.
 */

/*
 * ONE constraint incident on the constraint
 */

#define MATE_ONE_CONSTR		1
#define ALIGN_ONE_CONSTR	2
#define GROUND_ONE_CONSTR	3

/*
 * TWO constraints incident on the constraint.
 * The 2 constraints are PERPENDICULAR.
 */

#define MATE_MATE_PERP		20  /* 2 MATEs */
#define MATE_ALIGN_PERP		21  /* 1 MATE, 1 ALIGN */
#define ALIGN_ALIGN_PERP	22  /* 2 ALIGNs */


/*
 * TWO constraints incident on the constraint.
 * The 2 constraints are PARALLEL. The MATE, MATE
 * pair is missing because that is not a feasible combination.
 */

#define MATE_ALIGN_PAR		41  /* 1 MATE, 1 ALIGN */
#define ALIGN_ALIGN_PAR		42  /* 2 ALIGNs */

/*
 * TWO constraints incident on the constraint.
 * The 2 constraints are at an ACUTE ANGLE.
 */

#define MATE_MATE_ANG		60  /* 2 MATEs */
#define MATE_ALIGN_ANG		61  /* 1 MATE, 1 ALIGN */
#define ALIGN_ALIGN_ANG		62  /* 2 ALIGNs */

/*
 * THREE constraints incident on the constraint.
 */

#define MATE_MATE_MATE_PERP_PERP_PERP	80  /* 3 MATEs, all 3 are perpendicular */

#define MATE_MATE_MATE_PERP_PERP_ANG	81  /* 3 MATEs, all angles are perpendicular */
                                            /* except for an acute angle between a pair */
                                            /* of constraints */
#define MATE_MATE_MATE_PERP_ANG_ANG	82  /* 3 MATEs, all angles are acute */
                                            /* except for a perpendicular angle between a pair */
                                            /* of constraints */
#define MATE_MATE_MATE_ANG_ANG_ANG	83  /* 3 MATEs, all 3 are at acute angle */

#define MATE_MATE_ALIGN_PERP_PERP_PAR	84  /* MATE, MATE, ALIGN. The 2 MATEs are perp.   */
                                            /* ALIGN is parallel to 1 MATE.               */
#define MATE_ALIGN_ALIGN_PAR_PAR_PAR	85  /* All 3 constraints are parallel             */




/*
The following constant is the limit on # of constraints
incident on a part.
*/

#define MAX_INCIDENT_CONSTR		16

/*
 * We need to store a unique identity for the surface id 
 * in the reference file so that we can access it again even
 * if the osnum changes and also be aware if the objid gets
 * deleted and re-used
 */

typedef struct feature_id
{
  char osname[OM_K_MAXINTOSNAME_LEN]; /* internal OS name */
  OMuint tag;                         /* tag value of the feature */
} FEATURE_ID;


/********************************************************************/
/* 								    */
/* The following typedefs are for temporary data structures used    */
/* to search the assembly mating graph to find paths to             */
/* underconstrained assembly. If such a path cannot be found, ==>   */
/* than the assembly is overconstrained.                            */
/*								    */
/********************************************************************/

/* The following constant is for the maximum number of levels for the */
/* search of the Assembly Mating Graph.                               */

#define MAX_SEARCH_LEVEL			150

#define NULL_LEVEL 				0xffff
#define NULL_CONSTR_POS				0xffff

/* The following constant is for the maximum number of constr */
/* that can be stored during graph traversal.   	      */

#define MAX_CANDIDATE_CONSTR			600


/* The constants below define bits for a constraint to have been */
/* emanating from the ground, or from an underconstrained part.*/

#define FROM_GROUND			0x1
#define FROM_UNDER_CONSTR		0x2


typedef struct candidate_constr
{
  struct GRid constr_grid;
  unsigned short from_part_kind;
} CANDIDATE_CONSTR;


#endif

