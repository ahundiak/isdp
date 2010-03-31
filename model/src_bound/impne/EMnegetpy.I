/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide flexible access to the
    edges "active" geometry in a polyline format. If the edge is internally
    represented in the B-spline curve format, it is stroked out with
    appropriate chord-height tolerance and converted to a polyline
    geometry.

    Random access to the spans of the edge polyline geometry is possible. The 
    geometry can be obtained either reversed or as is. In this implementation
    there is necessarily only one span. If "from_spaninx" is greater than
    zero, an error condition is returned.

    If the caller nulls out the "points" field in the output IGRpolyline 
    structure, this method mallocs the memory. Else it assumes sufficient
    memory is present. The pointer "pygeom" should always point to a valid
    IGRpolyline structure on input.
*/

class implementation EMSnatedge;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgetpygeom (IGRlong *msg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRpolyline *pygeom; struct EMSpartolbasis
                    *partolbasis; IGRushort options)
{
  IGRint stat_OM, inx, modloc, loc;
  IGRdouble *points, val;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (from_spaninx > 0, *msg, EMS_I_OutOfBounds, ret_end);

  /*
   * Malloc output memory if not sent in by
   * the user.
   */

  if (!pygeom->points)
    {
    pygeom->points = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
    EMerr_hndlr (!pygeom->points, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  pygeom->num_points = 2;
  points = pygeom->points;

  /*
   * Making use of the fact that constant in U
   * and constant in V are represented
   * by even and odd "location" respectively and the fact
   * that a "location" equal to 1 or 2 represents
   * the 1.0 isoparametric line ("location" 0 or 3
   * represents the 0.0 isoparametric line), these
   * constant values for the points can be established 
   * thusly:
   */

  loc = (IGRint) (ME.EMSnatedge->location & 0x3);
  inx = loc % 2;
  val = (loc % 3 ? 1.0 : 0.0);
  points[inx] = val;
  points[inx+2] = val;

  /*
   * Processing from here on is to correctly return
   * the other two values in the "points" array.
   * If the entire edge is to be returned, these values
   * are 0 and 1 going into appropriate slots. Else,
   * these are values defined in the "partinfo"-structure.
   */

  inx = (inx + 1) % 2;
  if (partinfo)
    {
    if (loc > 1)
      {
      points[inx] = 1.0 - partinfo->edbdry[reverse ? 1 : 0].param;
      points[inx+2] = 1.0 - partinfo->edbdry[reverse ? 0 : 1].param;
      }
    else
      {
      points[inx] =  partinfo->edbdry[reverse ? 1 : 0].param;
      points[inx+2] = partinfo->edbdry[reverse ? 0 : 1].param;
      }
    }
  else
    {
    reverse = ME.EMSedge->ed_props & EMED_REVERSED ? 
               (reverse ? FALSE : TRUE) :
               (reverse ? TRUE : FALSE);
    modloc = loc + (reverse ? 2 : 0);
    val = (modloc % 4) / 2;
    points[inx] =  val;
    points[inx+2] = (val == 0.0 ? 1.0 : 0.0);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSnatedge.EMgetpygeom");
  return (stat_OM);
}

end implementation EMSnatedge;

