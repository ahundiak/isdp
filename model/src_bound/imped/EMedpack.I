/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "emsdef.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"

#define EDGE_INCREMENT 10

method EMedgepack(IGRlong *EMmsg; IGRint *num_points; IGRdouble **points;
                  IGRint *size; struct EMSdataselect *surf_data;
		  IGRshort *matrix_type; IGRmatrix matrix; 
		  IGRushort options;
		  struct EMSpartolbasis *ptol)
{
  IGRlong               sts;
  struct IGRpolyline    pygeom;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  pygeom.points = NULL;
  pygeom.num_points = 0;

  /*
   * Get my polyline geometry
   */

   
/*
  sts = BSEXTRACTPAR (&rc, BSTOLCHRDHT, chord_height_tol);

  stroking_tol = 0.01;
  BSchangepar (&rc, BSTOLCHRDHT, stroking_tol);
*/

  if( (ME.EMSedge->ed_props & EMED_ISO) && surf_data)
   {
    sts = om$send(msg = message EMSedge.EMstroke_iso_edge
	(EMmsg, matrix, matrix_type, 
	 surf_data->datatype == EMSdata_object ? surf_data->data.object : NULL,
	 surf_data->datatype == EMSdata_surface ? surf_data->data.surface : 
	 NULL, FALSE, ptol, my_id, &pygeom, FALSE), targetid = my_id);
   }
  else
   {
    sts = om$send(msg = message EMSedge.EMgetpygeom(EMmsg, 0, MAXINT,
                FALSE, NULL, &pygeom, ptol, NULL), targetid = my_id);
   }

  if(! (1 & sts)) goto wrapup;

  /*
   * Make shure there is enough memory
   */
  if( (*size) < 2 * pygeom.num_points)
  {
    IGRint loc_size;

    loc_size = *size + 2 * (*num_points + pygeom.num_points+EDGE_INCREMENT);
    if(*points)
     *points = (IGRdouble *) om$realloc(ptr = (IGRchar *)*points,
               size = loc_size * sizeof(IGRdouble));
    else
     *points = (IGRdouble *) om$malloc(size = loc_size * sizeof(IGRdouble));

    if(! *points)
    {
      *EMmsg = EMS_E_NoDynamicMemory;
      goto wrapup;
    }
    *size = *size + 2*(EDGE_INCREMENT+pygeom.num_points);
  }

  /*
   * Concatenate my points
   */
  {
    IGRint      num_bytes;
    IGRdouble   *move_to, *move_from;

    if(! *num_points)
    {
      /*
       * This is the first edge in the boundary
       */
      move_to = *points;
      move_from = pygeom.points;
      *num_points = pygeom.num_points;
      num_bytes = pygeom.num_points * 2 * sizeof(IGRdouble);
      *size = *size - (2 * pygeom.num_points);
    }
    else
    {
      /*
       * Previous edges were packed: don't use my first point
       */
      move_to = &((*points)[(*num_points)*2]);
      move_from = &pygeom.points[2];
      *num_points = (*num_points) + pygeom.num_points - 1;
      num_bytes = 2 * (pygeom.num_points - 1) * sizeof(IGRdouble);
      *size = *size - (2 * (pygeom.num_points -1));
    }
    OM_BLOCK_MOVE(move_from, move_to, num_bytes);
  }

wrapup:
/*
  BSchangepar (&rc, BSTOLCHRDHT, chord_height_tol);
*/
  if(pygeom.points) om$dealloc(ptr = pygeom.points);
  EMWRAPUP(*EMmsg, sts, "EMSedge.EMedgepack")
  return(sts);
}

end implementation EMSedge;
