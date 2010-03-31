/* ###################   APOGEE COMPILED   ################## */
/* 
Notes
   Given an edge parameter, this function computes the new parameter based
   on the new polyline geometry. It takes in the information regarding
   the point index in the old geometry before which geometry was
   inserted/removed, the geometry inserted/removed, and the result geometry 
   after insertion/removal.
   Geometry can be either removed or inserted. Both operations simultaneously
   are not allowed.
History
	SM	01-Apr-88		Creation.
	SM	28-Sep-88		Added arguments remove_poly and options
					to handle removal of geometry.
					'options' are for future use and
					meaningless right now. Changed the
					name of the function from
					'EMedgebound_update' to
					'EMpartedgebound_update'.
*/
class implementation EMSpartedge;

#include "EMS.h"
#define DEBUG	0

#if DEBUG
#define BUF	1
#else
#define BUF	20
#endif


#include "OMmacros.h"

#if DEBUG
#include <stdio.h>
#endif

IGRint	EMpartedgebound_update(EMmsg, before_ptinx, insert_poly, remove_poly, 
		new_geom, num_old_bdrys, old_bdrys, new_bdrys, lentol, options)
  IGRlong		*EMmsg;
  IGRint		before_ptinx;
  struct IGRpolyline	*insert_poly, *remove_poly, *new_geom;
  IGRint		num_old_bdrys;
  struct EMSedgebound	*old_bdrys, *new_bdrys;
  IGRdouble		lentol;
  IGRushort	options;
{
  IGRlong		sts, i;
  IGRint		from_spaninx, spans_mod, startinx, endinx, to_spaninx;
  struct EMSpypoint	*pyprojpt, pyspace;
  void			EMcnvtpypts(), EMcnvtedpar();
  struct IGRpolyline	proj_poly, *chg_poly;
  IGRdouble		pts[BUF], mindist, old_uv[2], *pt1, *pt2;
  IGRboolean		proj_poly_ready = FALSE;
  struct EMSedgebound	part[2], loc_bnd;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 proj_poly.points = NULL;
 chg_poly = (struct IGRpolyline *) insert_poly ? insert_poly : remove_poly;

 EMerr_hndlr(insert_poly && remove_poly, *EMmsg, EMS_E_InvalidArg, wrapup);

 from_spaninx = before_ptinx - 1;
 to_spaninx = remove_poly ? from_spaninx - remove_poly->num_points : 0;
 spans_mod = chg_poly->num_points;
 pyprojpt = &pyspace;
 proj_poly.num_points = insert_poly ? insert_poly->num_points + 2 : 2;
 proj_poly.points = (proj_poly.num_points * 2 > BUF) ? NULL : pts;

 for(i=0; i<num_old_bdrys; i++)
  {
   OM_BLOCK_MOVE(&old_bdrys[i], &new_bdrys[i], sizeof(struct EMSedgebound));
   loc_bnd = old_bdrys[i];

   if(old_bdrys[i].span_inx < (insert_poly ? from_spaninx : to_spaninx)) 
    continue;
   else if(old_bdrys[i].span_inx > from_spaninx)
    new_bdrys[i].span_inx = insert_poly ? new_bdrys[i].span_inx + spans_mod
					: new_bdrys[i].span_inx - spans_mod;
   else
    {
     /* Since the geometry modification has affected the part edge bound
        in a way more than mere span index translation, project the old uv 
        onto the new geometry. The old geometry can be recreated easily here
        (needed to get the old uv), knowing the new geometry and the
	geometry inserted or removed.
      */

     if(!proj_poly.points)
	 proj_poly.points = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) *
			proj_poly.num_points * 2);
     EMerr_hndlr(!proj_poly.points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     if(!proj_poly_ready)
      {
       if(insert_poly)
        {
         startinx = (before_ptinx - 1) * 2;
         endinx = (insert_poly->num_points + 2) * 2;
	
         OM_BLOCK_MOVE(&new_geom->points[startinx], proj_poly.points, 
				sizeof(IGRdouble) * endinx);
	}
       else
	 OM_BLOCK_MOVE(&new_geom->points[to_spaninx * 2], proj_poly.points, 
			4 * sizeof(IGRdouble));
       proj_poly_ready = TRUE;
      }

     if(remove_poly)
      {
        if(loc_bnd.span_inx == to_spaninx)
         {
	  pt1 = &new_geom->points[to_spaninx * 2];
	  pt2 = remove_poly->points;
         }
        else if(loc_bnd.span_inx == from_spaninx)
         {
	  pt1 = &remove_poly->points[remove_poly->num_points * 2 - 2];
	  pt2 = &new_geom->points[to_spaninx * 2 + 2];
         }
        else
         {
	  pt1 = &(remove_poly->points[(loc_bnd.span_inx - to_spaninx -1) * 2]);
	  pt2 = pt1 + 2;
	 }
      }
     else
      {
        pt1 = proj_poly.points;
        pt2 = &proj_poly.points[proj_poly.num_points*2 - 2];
      }

      old_uv[0] = pt1[0] + loc_bnd.param * (pt2[0] - pt1[0]);
      old_uv[1] = pt1[1] + loc_bnd.param * (pt2[1] - pt1[1]);
	
      /* Project the old uv onto the relevant portion of the proj polyline.
      */

      EMcnvtpypts(EMmsg, &proj_poly, 2, 1, old_uv, lentol, pyprojpt, 
		  &mindist);
      if(!(1&*EMmsg)) goto wrapup;

      /* Convert the bounds into the bounds with reference to the full 
	 new geometry.
      */
      if(insert_poly)
       {
        part[0].span_inx = before_ptinx - 1;
        part[0].param = 0.0;
        part[1].span_inx = part[0].span_inx + insert_poly->num_points;
        part[1].param = 1.0;
       }
      else
       {
	part[0].span_inx = to_spaninx;
	part[0].param = 0.0;
	part[1].span_inx = to_spaninx;
	part[1].param = 1.0;
       }

      loc_bnd.span_inx = pyprojpt->span_inx;
      loc_bnd.param = pyprojpt->param;
      EMcnvtedpar(EMmsg, part, &part[1], &loc_bnd, &new_bdrys[i]);
      if(!(1&*EMmsg)) goto wrapup;

    } /* if(old_bdrys[i].span_inx == from_spaninx) */

  } /* for(i=0; i<num_old_bdrys; i++) */


#if DEBUG
 fprintf(stderr, "%s", "\nIn EMedgebound_update\n");
 fprintf(stderr, "Before Ptinx- %d, Num Pts Inserted %d\n", before_ptinx, 
		insert_poly->num_points);
 fprintf(stderr, "Bdrys Converted- %d\n", num_old_bdrys);
 for(i=0; i<num_old_bdrys; i++)
    fprintf(stderr, "%d )) %d %9lf, %d %9lf\n", i, old_bdrys[i].span_inx, 
		old_bdrys[i].param, new_bdrys[i].span_inx, new_bdrys[i].param);
#endif

wrapup:
 if(proj_poly.points && (proj_poly.points != pts))
   om$dealloc(ptr = proj_poly.points);
 EMWRAPUP(*EMmsg, sts, "In EMpartedgebound_update");
 return(sts);

}

end implementation EMSpartedge;
