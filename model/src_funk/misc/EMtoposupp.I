/*
  CONTENTS
  
    This file contains all the functions that operate on topology
    related information.
*/

class implementation Root;

%safe
#include <math.h>
%endsafe
#include "EMS.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "bserr.h"
#include "bsparameters.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWapi/eded.h"

#define FIRST  0
#define SECOND 1

from GRvg import EMptatpr;
from EMSboundary import EMgetsurface_info;
from EMSedge import EMgetvtxedges, EMget_bcxyz_geom;

IGRboolean EMget_common_sf (ed1, ed2, os)
GRobjid ed1, ed2;
GRspacenum os;
{
  IGRlong msg_loc;
  GRobjid sf1, csf1, sf2, csf2, comm_sf;
  OM_S_CHANSELECT chan_to_common;

  sf1 = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc, &sf1,
   NULL), targetid = ed1, targetos = os, senderid = NULL_OBJID);
  
  sf2 = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc, &sf2,
   NULL), targetid = ed2, targetos = os, senderid = NULL_OBJID);

  if (IF_NULL_OBJID (sf1) || IF_NULL_OBJID (sf2) ||
      sf1 != sf2)
    {
    EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);

    csf1 = NULL_OBJID;
    om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc, &csf1,
     NULL), p_chanselect = &chan_to_common, targetos = os, senderid = ed1);

    csf2 = NULL_OBJID;
    om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc, &csf2,
     NULL), p_chanselect = &chan_to_common, targetos = os, senderid = ed2);
    }

  if (sf1 == sf2 && !IF_NULL_OBJID (sf1))
    comm_sf = sf1;
  else if (sf1 == csf2 && !IF_NULL_OBJID (sf1))
    comm_sf = sf1;
  else if (csf1 == sf2 && !IF_NULL_OBJID (csf1))
    comm_sf = csf1;
  else if (csf1 == csf2 && !IF_NULL_OBJID (csf1))
    comm_sf = csf1;
  else
    comm_sf = NULL_OBJID;

  return (comm_sf);  
}


IGRboolean EMis_onvertex (loc, ed)
enum EMScvinttype loc;
GRobjid ed;
{
  IGRboolean stat_func=FALSE;

  if (IF_NULL_OBJID (ed))
    goto ret_end;
 
  if (loc == EMScvint_rtend || loc == EMScvint_lfend)
    stat_func = TRUE;

ret_end:
  return (stat_func);
}


IGRboolean EMis_samevertex (loc1, ed1, loc2, ed2, os, opts)
enum EMScvinttype loc1, loc2;
GRobjid ed1, ed2;
GRspacenum os;
IGRushort opts;
{
  IGRboolean stat_func=FALSE, *edends;
  IGRint i, num_vtxeds;
  IGRlong msg_loc, stat_OM;
  GRobjid *vtxeds;

  vtxeds = NULL;
  edends = NULL;

  if (!EMis_onvertex (loc1, ed1) || !EMis_onvertex (loc2, ed2))
    goto ret_end;
 
  num_vtxeds = 0;
  stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (&msg_loc,
             !(opts & EMS_O_Global) ? EMSvtxedges_onlythissurf : NULL,
             loc1 == EMScvint_rtend ? TRUE : FALSE, 0,
             &num_vtxeds, &vtxeds, &edends), targetid = ed1, targetos = os,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), stat_func, FALSE, ret_end);

  if (num_vtxeds)
    for (i=0; i<num_vtxeds; i++)
      if (IF_EQ_OBJID (vtxeds[i], ed2) &&
          (edends[i] ? EMScvint_rtend : EMScvint_lfend) == loc2)
        {
        stat_func = TRUE;
        break;
        }

ret_end:
  if (vtxeds)
    om$dealloc (ptr = vtxeds);
  if (edends)
    om$dealloc (ptr = edends);

  return (stat_func);
}


IGRboolean EMis_sametopology (loc1, ed1, loc2, ed2, os, opts)
enum EMScvinttype loc1, loc2;
GRobjid ed1, ed2;
GRspacenum os;
IGRushort opts;
{
  IGRboolean stat_func=FALSE;
  extern IGRboolean EMis_samevertex();

  if (IF_NULL_OBJID (ed1) || IF_NULL_OBJID (ed2))
    goto ret_end;
 
  if (loc1 == EMScvint_middle && loc2 == EMScvint_middle &&
      IF_EQ_OBJID (ed1, ed2))
    stat_func = TRUE;
  else if (EMis_samevertex (loc1, ed1, loc2, ed2, os, opts))
    stat_func = TRUE;

ret_end:
  return (stat_func);
}

/*
  ABSTRACT

    This function returns the position of a given uv-point w.r.t to a 
    given edge on a given surf. The check is made w.r.t to 'chktol'
    in model-space. If the point is off from the edge, the value of this
    function will be EMScvint_unknown. If it is on the edge within 
    'chktol' in model-space then the value will be one of:
    EMScvint_rtend, EMScvint_lfend, EMScvint_middle.

    This function is silent on error. The 'msg' code can be checked to 
    make sure there was no error.
*/

enum EMScvinttype EMchkposonedge (msg, os, edge, uvpt, chktol)
IGRlong *msg;
GRspacenum os;
GRobjid edge;
IGRdouble uvpt[2];
IGRdouble chktol;
{
  IGRshort idmattyp; 
  IGRlong msg_loc;
  IGRdouble xyzmindist;
  IGRpoint xyzpt, start_xyzpt, stop_xyzpt;
  IGRmatrix idmat;
  GRobjid sfobj;
  struct GRmdenv_info mdenv_info;
  struct IGRbsp_curve xyzcv;
  struct IGRpolyline py;
  struct EMSdataselect xyzdata;
  struct EMSpypoint xyzprojpt;
  enum EMScvinttype pos; 
  extern IGRdouble BSdistptpt();

  *msg = EMS_S_Success;
  pos = EMScvint_unknown;

  xyzcv.poles = NULL;
  xyzcv.knots = NULL;
  xyzcv.weights = NULL;
 
  sfobj = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
   &sfobj, NULL), targetid = edge, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (IF_NULL_OBJID (sfobj), *msg, EMS_E_EdgeError, ret_end);

  EMidmatrix (&msg_loc, &idmattyp, idmat);
  mdenv_info.matrix_type = idmattyp;
  OM_BLOCK_MOVE (idmat, mdenv_info.matrix, sizeof (IGRmatrix));
  om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, &mdenv_info,
   NULL, NULL, 0, MAXINT, FALSE, NULL, &xyzcv), targetid = edge,
   targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  if (xyzcv.order == 2)
    {
    xyzdata.datatype = EMSdata_poly3d;
    xyzdata.data.poly = &py;
    py.num_points = xyzcv.num_poles;
    py.points = xyzcv.poles;
    }
  else
    {
    xyzdata.datatype = EMSdata_curve3d;
    xyzdata.data.curve = &xyzcv;
    }
 
  om$send (msg = message GRvg.EMptatpr (&msg_loc, &idmattyp, idmat,
   uvpt, 2, xyzpt), targetid = sfobj, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  EMprojectpt (&msg_loc, &idmattyp, idmat, &xyzdata, 1, xyzpt, chktol,
   &xyzprojpt, &xyzmindist);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (xyzmindist <= chktol)
    {
    EMgetendpts_xyz (&msg_loc, &idmattyp, idmat, &xyzdata, FALSE, 1,
     start_xyzpt, stop_xyzpt);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (EMis_geomequal_3dpt (start_xyzpt, xyzpt, chktol))
      pos = EMScvint_lfend;
    else if (EMis_geomequal_3dpt (stop_xyzpt, xyzpt, chktol))
      pos = EMScvint_rtend;
    else
      pos = EMScvint_middle;
    }

ret_end:
  if (xyzcv.poles)
    om$dealloc (ptr = xyzcv.poles);
  if (xyzcv.knots)
    om$dealloc (ptr = xyzcv.knots);
  if (xyzcv.weights)
    om$dealloc (ptr = xyzcv.weights);

  if (EMSerror (*msg))
    pos = EMScvint_unknown;
  return (pos);
}


/*
  DESCRIPTION

  This function returns the id of the edge that intervenes between two
  topologically defined points. The topological definition of a point is
  simply the edge-id on which it lies and the topo-position of the point
  on the edge (start, middle, stop). In other words, the two points must
  point to points lying on the same edge, and this function returns this
  edge.

  NOTES

  The circumstance in which this function performs a non-trivial task
  is when one or both the topo-defs of the points indicate vertices and
  the vertex definition includes the id of the adjacent edge.
*/

GRobjid EMget_intervening_edge (os, ed1, topo1, ed2, topo2)
GRspacenum os;
enum EMScvinttype topo1, topo2;
GRobjid ed1, ed2;
{
  GRobjid retid=NULL_OBJID;
  GRobjid adjed1=NULL_OBJID, adjed2=NULL_OBJID;
  
  if (ed1 == ed2)
    retid = ed1;
  else
  {
    if (topo1 == EMScvint_rtend)
      adjed1 = pwGetNextEd (ed1, os);
    else if (topo1 == EMScvint_lfend)
      adjed1 = pwGetPrevEd (ed1, os);

    if (adjed1 == ed2)
      retid = ed2;
    else
    {
      if (topo2 == EMScvint_rtend)
        adjed2 = pwGetNextEd (ed2, os);
      else if (topo2 == EMScvint_lfend)
        adjed2 = pwGetPrevEd (ed2, os);

      if (adjed2 == ed1)
        retid = ed1;
      else
      {
        if (adjed1 == adjed2)
          retid = adjed1;
      }
    }
  }

  return (retid);
}

end implementation Root;

