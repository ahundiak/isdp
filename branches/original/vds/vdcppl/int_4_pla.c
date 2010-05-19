/* $Id: int_4_pla.c,v 1.1 2001/01/18 19:05:49 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/cimacros/surface/macros / int_4_pla.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: int_4_pla.c,v $
 *	Revision 1.1  2001/01/18 19:05:49  hans
 *	Merged SP16 modifications
 *	
 * Revision 1.1  2000/05/16  13:24:10  pinnacle
 * Created: vds/vdcppl/int_4_pla.c by jwfrosch for Service Pack
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      05/15/2000      HF              Creation date
 *                                      Fix TR179901482
 * -------------------------------------------------------------------*/

#include "bstypes.h"
#include "bserr.h"
#include "bspl_pl_pl.h"

extern int VDcomment;

void VDintersect_4_planes(plane, pt1, rc)
  struct IGRplane        *plane;	/* I 4 Root-points / Normals */
  IGRdouble              *pt1;		/* O 2 Intersection points   */
  IGRlong                *rc;		/* O return code             */
{

  IGRint                i;
  IGRint                flag;
  IGRpoint              q, r;
  IGRvector             u, v;

  char                  str[80];

  if(VDcomment)
  {
    for(i=0; i < 4; i++)
    {
      printf ("  plane[%d].point  = %lg, %lg, %lg\n", i, plane[i].point [0], plane[i].point [1], plane[i].point [2]);
      printf ("  plane[%d].normal = %lg, %lg, %lg\n", i, plane[i].normal[0], plane[i].normal[1], plane[i].normal[2]);
    }
  }
  /* HF: 05/15/2000 TR 179901482 (KLUDGE !)
   * For whatever reason, the first call to BSpl_pl_pl() fails when the intersecting planes
   * are all infinite planes (such as frame system's), and one of these planes is modified.
   *
   * Actually, it does NOT fail, because the returncode rc = BSSUCC, and the flag indicates
   * that an intersection point has been found, BUT the intersection point is invalid: (-NaN, -NaN, -NaN) !!!!
   * The only way to get it to work properly this far, is to repeat the 1st call to BSpl_pl_pl()
   * a 2nd time, and now we have a valid intersection point ?!?!?!?
   */

/* find the 1st point */
  BSpl_pl_pl( plane[0].point,
              plane[0].normal,
              plane[1].point,
              plane[1].normal,
              plane[2].point,
              plane[2].normal,
              &flag,
              pt1,
              q,
              r,
              u,
              v,
              rc );

  if( *rc != BSSUCC ) return;

  if(VDcomment)
  {
    printf ("  pt1[0,1,2]      = %lg, %lg, %lg, flag = %d\n", pt1[0],  pt1[1],  pt1[2], flag);
  }

  BSpl_pl_pl( plane[0].point,
              plane[0].normal,
              plane[1].point,
              plane[1].normal,
              plane[2].point,
              plane[2].normal,
              &flag,
              pt1,
              q,
              r,
              u,
              v,
              rc );

  if( *rc != BSSUCC ) return;

  if(VDcomment)
  {
    printf ("  pt1[0,1,2]      = %lg, %lg, %lg, flag = %d\n", pt1[0],  pt1[1],  pt1[2], flag);
  }
/* find the 2nd point */

  BSpl_pl_pl( plane[0].point,
              plane[0].normal,
              plane[1].point,
              plane[1].normal,
              plane[3].point,
              plane[3].normal,
              &flag,
              &pt1[3],
              q,
              r,
              u,
              v,
              rc );

  if( *rc != BSSUCC ) return;

  if(VDcomment)
  {
    printf ("  pt1[3,4,5]      = %lg, %lg, %lg, flag = %d\n", pt1[3],  pt1[4],  pt1[5], flag);
  }
}
