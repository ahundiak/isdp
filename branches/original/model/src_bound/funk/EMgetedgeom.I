/*
  DESCRIPTION

    This function can be used to get the geometry of a given edge formatted as
    an EMSdataselect. The geometry can be obtained as:

    -  PART or FULL (makes sense for part-edges only)
    -  NATURAL or LOGICAL (for all edges)
  
    Options:

    By default, (if options argument is NULL), this function always returns the
    NATURAL (& PART, for part-edges) geometry. If the FULL geometry or LOGICAL
    geometry is needed, the following options are available:

    EMSedgeom_logical 
    EMSedgeom_full  (for part-edges ONLY)

    COMBINATIONS:
    ------------

    FULL & LOGICAL: 

        Part-edges:  The geometry of the full-edge in the logical direction of
                     the part-edge.
        Other edges: Edges own geometry in the logical direction of the edge.

    FULL & NATURAL: 

        Part-edges:  The geometry of the full-edge in the natural direction of
                     the full-edge.
        Other edges: Edges own geometry in the natural direction of the edge.

    PART & LOGICAL: 

        Part-edges:  The geometry of the part-edge in the logical direction of
                     the part-edge.
        Other edges: (same as FULL & LOGICAL)

    PART & NATURAL: 

        Part-edges:  The geometry of the part-edge in the natural direction of
                     the full-edge.
        Other edges: (same as FULL & NATURAL)

    NOTE: For part-edges, natural geometry means the natural geometry of the 
          full-edge on top of which it is defined, while the logical direction
          is in the direction of the stored bounds of the part-edge. Also, the
          stored bounds of the part-edge are with respect to the natural 
          geometry of the full-edge. Since the "REVERSE" bit of the part-edge is
          redundant (it has already been applied by reversing the bounds if
          necessary that are stored in the part-edge), we never check for it.
      
 
  HISTORY 

  ???????   ???   Creation.
  09/22/93  NP    Added options to get FULL/PART and LOGICAL/NATURAL geometry.
                  Added relevant description. Changed function name from 
                  "EMgeteddata" to "EMgetedgeom".
 
*/

class implementation EMSedge;

#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgetgeom.h"

extern OMuword OPP_EMSpartedge_class_id;


IGRint EMgetedgeom (msg, options, edid, eddata)
IGRlong *msg;
IGRushort options;
struct GRid *edid;
struct EMSdataselect *eddata;
{
  IGRushort ed_props, full_ed_props;
  IGRlong msg_loc, stat_OM;
  struct EMSaltdataselect altdata;
  struct IGRpolyline *py;
  struct IGRbsp_curve *cv;
  IGRboolean reverse;
  GRclassid   edclass;
  struct GRid edge;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /* set the defaults */


  eddata->datatype = EMSdata_null;
  eddata->data.poly = NULL;
  eddata->data.curve = NULL;
  eddata->data.surface = NULL;

  altdata.data.poly.points = NULL;
  altdata.data.curve.poles = NULL;
  altdata.data.curve.knots = NULL;
  altdata.data.curve.weights = NULL;


  stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc, &ed_props),
             targetid = edid->objid, targetos = edid->osnum,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  om$get_classid (objid = edid->objid, osnum = edid->osnum,
                   p_classid = &edclass);

  if (om$is_ancestry_valid (subclassid = edclass,
          superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
  {
          if (!(options & EMSedgeom_full))
          {
            edge.objid = edid->objid;
            edge.osnum = edid->osnum;
            reverse = options & EMSedgeom_logical? FALSE : 
                                                   ed_props & EMED_REVERSED;

          }
          else
          {
            edge.osnum = edid->osnum;
            stat_OM = om$send (msg= message EMSedge.EMget_bottom_edge(&msg_loc,
                                        &(edge.objid)),
                               senderid = NULL_OBJID,
                               targetid = edid->objid,
                               targetos = edid->osnum);
            EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_EdgeError, ret_end);
  
            stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc, 
                                      &full_ed_props),
                   targetid = edge.objid, targetos = edge.osnum,
                   senderid = NULL_OBJID);
           EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

            reverse = options & EMSedgeom_logical? 
                      (full_ed_props & EMED_REVERSED? 
                            (ed_props & EMED_REVERSED ? FALSE : TRUE)  :
                            (ed_props & EMED_REVERSED ? TRUE  : FALSE) ) :
                              full_ed_props & EMED_REVERSED;
          }


  }
  else
  {
      edge.objid = edid->objid;
      edge.osnum = edid->osnum;
      reverse = options & EMSedgeom_logical? FALSE : ed_props & EMED_REVERSED;
  }


  stat_OM = om$send (msg = message EMSedge.EMgetgeom (
                  &msg_loc, 0, MAXINT, reverse, NULL, &altdata),
             targetid = edge.objid, targetos = edge.osnum,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (altdata.datatype == EMSdata_poly2d)
    {
    py = (struct IGRpolyline *) om$malloc (size = 
                         sizeof (struct IGRpolyline));
    EMerr_hndlr (!py, *msg, EMS_E_NoDynamicMemory, ret_end);
    
    OM_BLOCK_MOVE (&altdata.data.poly, py, sizeof (struct IGRpolyline));

    altdata.data.poly.points = NULL;
    altdata.data.curve.poles = NULL;
    altdata.data.curve.knots = NULL;
    altdata.data.curve.weights = NULL;

    eddata->datatype = EMSdata_poly2d;
    eddata->data.poly = py;
    }
  else if (altdata.datatype == EMSdata_curve3d)
    {
    cv = (struct IGRbsp_curve *) om$malloc (size = 
                         sizeof (struct IGRbsp_curve));
    EMerr_hndlr (!cv, *msg, EMS_E_NoDynamicMemory, ret_end);
    
    OM_BLOCK_MOVE (&altdata.data.curve, cv, sizeof (struct IGRbsp_curve));

    altdata.data.poly.points = NULL;
    altdata.data.curve.poles = NULL;
    altdata.data.curve.knots = NULL;
    altdata.data.curve.weights = NULL;

    eddata->datatype = EMSdata_curve3d;
    eddata->data.curve = cv;
    }

ret_end:
  if (altdata.data.poly.points)
    om$dealloc (ptr = altdata.data.poly.points);
  if (altdata.data.curve.poles)
    om$dealloc (ptr = altdata.data.curve.poles);
  if (altdata.data.curve.knots)
    om$dealloc (ptr = altdata.data.curve.knots);
  if (altdata.data.curve.weights)
    om$dealloc (ptr = altdata.data.curve.weights);

  EMWRAPUP (*msg, stat_OM, "EMgetedgeom.I");
  return (stat_OM);
}

end implementation EMSedge;

