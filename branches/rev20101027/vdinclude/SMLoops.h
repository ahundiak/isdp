/* $Id: SMLoops.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMLoops.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMLoops.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
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
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef SMLoopDef
#define SMLoopDef

#define MAX_CRV_PT	10	/* Maximun number of curve ending to a point */
#define MAX_LP_CRV	20	/* Maximun number of curves composing a loop */

#define ALLOC_LP_INCR		10
#define RIGHT			0x0001
#define LEFT			0x0002

struct SMGrCrv
 {
  struct GRid		CvId;		/* Curve Id			*/
  IGRint		P0;		/* Index to the starting Pt     */
  IGRdouble		TgP0[3];	/* P0 tangent			*/
  IGRint		P1;	 	/* Index to the ending Pt       */
  IGRdouble		TgP1[3];	/* P1 tangent			*/
  IGRshort		RLDef;		/* 0: Not used, 1: Right, 2: Left */
					/* 3: Right & LEFT		*/
 };

/* The tangency vector are always oriented to the outside */

struct SMGrPt
 {
  struct GRid		Pt;		 /* Point Id			 */
  IGRint		NbCrv;		 /* Number of curve ending here  */
  IGRint		Crv[MAX_CRV_PT]; /* Array of index on curves  	 */
 };

struct SMLoop
 {
  IGRint		NbCrv;		 /* Number of curve of the loop	*/
  IGRint		Crv[MAX_LP_CRV]; /* array of index on curves 	*/
  IGRint		Pt[MAX_LP_CRV];  /* array of index on points 	*/
  IGRshort		RLType;		 /* If right of left area	*/
  IGRboolean 		Rev[MAX_LP_CRV]; /* Need to be reversed		*/
 };




#endif

