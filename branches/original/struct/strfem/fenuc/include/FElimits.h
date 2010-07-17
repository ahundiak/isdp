#ifndef	FElimits_included
#define FElimits_included

/* *****************************H H H H H******************************* */
/* Doc: FElimits.h

   Abstract: Hardcoded limits.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      1987	kk	1.0	Creation
*/
/* *****************************H H H H H******************************* */

#define		MAX_DOF_PER_NODE	6	/* Always			*/
#define		MAX_DOF_PER_ELEM	120	/* for hx20			*/
#define		MAX_EK_BUFFER		14400	/* 120 * 120 = 14400 for hx2048 */
#define		MAX_MAP_BUFFER		20	/* for hx20			*/

#define 	EFFECTIVE_ZERO 1e-30		/* Used in the solver		*/
#define 	RELATIVE_ZERO  1e-10		/* Used in the solver		*/

#define 	FE_MAX_MPNAME_SIZE	41	/* For names from "Intersect"	*/

#endif
