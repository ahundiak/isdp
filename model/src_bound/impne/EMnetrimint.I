/*
  Abstract:

  This method computes the "area" intersection between a 2-dimensional 
  polyline and this edge bounding this area. The intersection computation
  is sensitive to the area that the edge is considered to be boundary of
  (area on the right-hand-side with a natural traversal). An intersection
  results if and only if the input line string has any part common with the 
  INTERIOR bounded by the edge.

  If the input polyline just "grazes" the edge, no intersection is output;
  if the polyline intersects the edge at one of it's vertex points, only one
  intersection is output; etc.

  At the endpoints of this object, ambiguity can arise as to extent to which
  the interior fans out. For this purpose a "previous" and a "subsequent"
  point are obtained, from it's previous and subsequent edges which now
  define the interior at the start and the endpoints, respectively.

  Theoretically, this is an n-squared algorithm, but practically it
  works out cheaper as there are two stages wherin non-intersections
  are trivially rejected.

  The output is a linked list of EMSpypoint  and EMintsfedge structures that
  stand for the intersections on the polyline. If output pointers (*polyinters
  and/or *myinters) are not NULL, this method assumes an existing linked-list
  and attaches it's output to the tail.

  This edge being a natural edge, the assumption is made that the entire
  "inpoly" lies towards the area side of this edge when this edge has no
  boundary being imposed on it.

  NOTES

    See also EMletrimint.I. See emsinterdef.h for options

  HISTORY

    SS  :  10/13/87  :  Modified the code to do the trimming through 
                        a single function call.
    SS  :  03/27/89  :  Passing the parametric length tolerance to the
			'get-adjacent-span' function in the 'geninfo'
			field.
*/

class implementation EMSnatedge;

#include "bserr.h"
#include "bsparameters.h"
#include "emsinterdef.h"
#include "emsmacros.h"

#define X 0
#define Y 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMedpytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                      IGRdouble *inpoly_range; 
                      struct EMSpartolbasis *partol_basis;
                      struct EMSpartedinfo *partinfo;
                      IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters; 
                      struct EMSpypoint  **polyinters)
{
  IGRboolean stat_func, reverse;
  IGRuchar location;
  IGRushort edgeprops;
  IGRshort ptinx;
  IGRint num_cpts;
  IGRint stat_OM;
  IGRlong msg_loc;
  IGRdouble val, lentol, chttol, uvlentol, wpts[4], *cpts;
  GRobjid sender_edge, dumid;
  struct EMSgetadjgeom adjgeom_info;
  IGRboolean EM2dpycutint();
  IGRint EMadjedpy();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!partol_basis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info
               (&msg_loc, &dumid, partol_basis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  if (options & EMS_INTER_USECHTTOL)
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    uvlentol = partol_basis->tol * (chttol / lentol);
    EMadjust_paramtol (&msg_loc, NULL, uvlentol, &uvlentol);
    }
  else
    uvlentol = partol_basis->tol;

  /*
   * Making use of the fact that constant in U
   * and constant in V are represented
   * by even and odd "location" respectively and the fact
   * that a "location" equal to 1 or 2 represents
   * the 1.0 isoparametric line, "location" 0 or 3
   * represents the 0.0 isoparametric line, these
   * iso-values for the points can be established 
   * thusly:
   */

  location = ME.EMSnatedge->location & 0x3;
  ptinx = location % 2;
  val = (location % 3 ? 1.0 : 0.0);
  wpts[ptinx] = val;
  wpts[ptinx+2] = val;

  /*
   * Following is to correctly return
   * the other two values in the "wpts" array.
   * If the entire edge is to be returned, these values
   * are 0 and 1 going into appropriate slots. Else,
   * these values are obtained from the "partinfo"-
   * structure.
   *
   * The geometry is derived in the direction it is stored. If the
   * property-word indicates that it has to be reversed, this fact
   * is made known to the lower level function and is thus taken
   * care of.
   */

  ptinx = (ptinx + 1) % 2;
  if (partinfo)
    {
    sender_edge = partinfo->edid;
    edgeprops = partinfo->edprops;
    reverse = edgeprops & EMED_REVERSED;
    if (location > 1)
      {    
      wpts[ptinx] = 1.0 - partinfo->edbdry[reverse ? 1 : 0].param;
      wpts[ptinx+2] = 1.0 - partinfo->edbdry[reverse ? 0 : 1].param;
      }
    else
      {    
      wpts[ptinx] = partinfo->edbdry[reverse ? 1 : 0].param;
      wpts[ptinx+2] = partinfo->edbdry[reverse ? 0 : 1].param;
      }
    }
  else
    {
    sender_edge = my_id;
    edgeprops = ME.EMSedge->ed_props;
    val = location > 1 ? 1.0 : 0.0;
    wpts[ptinx] = val;
    wpts[ptinx+2] = 1.0 - val;
    }

  num_cpts = inpoly->num_points;
  cpts = (IGRdouble *) inpoly->points;

  /*
   * Call the trimming function that will do the interesection
   * computations. If no output is requested and an intersection
   * has been found, return the code that will stop further search.
   * Set the 'geninfo' to point to the parametric length tolerance.
   */

  adjgeom_info.geninfo = (IGRchar *) &uvlentol;
  stat_func = EM2dpycutint (&msg_loc, 2, wpts, edgeprops, NULL, num_cpts,
               cpts, inpoly_range, options, uvlentol, EMadjedpy, 
               &adjgeom_info, sender_edge, partinfo, num_inters, myinters,
               polyinters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
  if (!polyinters && !myinters && (msg_loc == EMS_I_Intersect))
    {
    *num_inters = TRUE;
    stat_OM = OM_I_STOP_SENDING;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSlinedge.EMedpytrimint");
  return (stat_OM);
}

end implementation EMSnatedge;

