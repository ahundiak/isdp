/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *
 * NOTES
 *
 */

class implementation EMSedge;

/* Includes */

#include <stdio.h>
#include <alloca.h>         /* SYSTEM */
#include <math.h>

#include "bs.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"    /* BS */
#include "bsvalues.h"

#include "OMminimum.h"
#include "OMprimitives.h"   /* OM */
#include "OMmacros.h"
#include "igetypedef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"          /* GRNUC */
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "EMSmsgdef.h"      
#include "emsdef.h"
#include "EMSprop.h"        /* MODEL */
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsedgedef.h"     

#include "PWminimum.h"
#include "PWerror.h"        /* PATHWAY */
#include "PWgmdata.h"

/* Prototypes */

#include "bscvtgeomcv.h"
#include "bssfeval.h"

#include "PWapi/edcons.h"
#include "PWapi/clsid.h"
#include "PWapi/objcons.h"
#include "PWapi/edprops.h"
#include "PWapi/samepts.h"
#include "PWapi/isopts.h"
#include "PWapi/partol.h"
#include "PWapi/ptpargm.h"
#include "channel.h"
#include "objconn.h"
#include "PWapi/objdel.h"

/* Static Functions */

%safe
static PWobjid create_part_edge 
(
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type,
  PWboolean is_dummy
);
%endsafe

/* Extern Variables */

extern OMuword  OPP_EMSnatedge_class_id, OPP_EMSptedge_class_id, 
                OPP_EMSlinedge_class_id, OPP_EMSbsedge_class_id,
                OPP_EMSpartedge_classid, OPP_EMSdumedge_class_id;

/* Imports */

from EMSpartedge import EMpeinit;

/*
  ABSTRACT

    Given the edge geometry, it creates an edge of right class and posts 
    the geometry and sets the properties which can be derived from the 
    input geometry. 

  NOTES

    If an iso-edge need to be created, input geometry must contain only 
    two points which are the bounds of the iso-edge. This routine always 
    honours the incoming geometry. No tolerance check is done to find the
    iso ness of the surface.
*/

PWobjid pwCreateEdge
(
  PWosnum os,
  struct PWcvdata *p_edgeom,
  int edprops,
  int edxyz_type
)
{
  PWresult PWsts=PW_K_Success;
  long OMsts=OM_S_SUCCESS;
  PWobjid edobj=PW_K_NullObjid;
  enum PWcvdatatype edtype=PWcvdata_null;

  edtype = p_edgeom->datatype;

  OnErrorState (edtype != PWcvdata_pt2d && edtype != PWcvdata_py2d &&
                edtype != PWcvdata_bspcv && edtype != PWcvdata_gmbspcv, PWsts,
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  switch (edtype)
  {
    case PWcvdata_pt2d : 
    {
      /*
       * Point edge. Create an object of "point edge" and post the geometry.
       */
      edobj = omCreateObjFromClassid (os, OPP_EMSptedge_class_id);
      OnErrorState (edobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway,
                    PW_K_Internal), wrapup); 
 
      OMsts = om$send (msg = message EMSedge.EMpostgeom 
                                     ((char *) p_edgeom->data.pt2d),
                       senderid = edobj, targetid = edobj, targetos = os);
      
      /*
       * Set all the default properties on this edge.
       */
      pwSetEdDegen (edobj, os);
      pwSetEdClosedXYZ (edobj, os);
    }
    break;

    case PWcvdata_py2d :
    {
      /*
       * Natural/Linear Edge.
       */

      int natloc=0, isodir=0;
      char c_natloc=0, *p_geom=NULL;
      PWboolean is_nated=FALSE, natrev=FALSE, is_iso=FALSE;
      struct PWpoly2d *p_py=NULL;

      p_py = &p_edgeom->data.py2d;

      if (p_py->num_pts == 2)
      {
        if (is_nated = pwGetNatLocation (p_py->p_pts, 0.0, 1.0, 0.0, 1.0, 
                                         &natloc, &natrev)) 
        {
          c_natloc = (char) natloc;
        } 
        else if (pwIsUvPtsIso (2, p_py->p_pts, MINDOUBLE, &isodir))
        {
          is_iso = TRUE;  
        }
      }

      if (is_nated)
      {
        edobj = omCreateObjFromClassid (os, OPP_EMSnatedge_class_id);
      }
      else
      {
        edobj = omCreateObjFromClassid (os, OPP_EMSlinedge_class_id);
      }
      OnErrorState (edobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway,
                    PW_K_Internal), wrapup); 
   
      if (is_nated)
        p_geom = (char *) &c_natloc;
      else
        p_geom = (char *) p_py;

      OMsts = om$send (msg = message EMSedge.EMpostgeom (p_geom),
                       senderid = edobj, targetid = edobj, targetos = os);
      OnErrorState (IsError (OMsts), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
                      
      if (is_nated)
      {
        pwSetEdNatural (edobj, os);
        pwSetEdCompatible (edobj, os);
        pwSetEdOpen (edobj, os);
        if (natrev)
          pwSetEdRev (edobj, os);
      }
      else
      {
        if (is_iso)
          pwSetEdIso (edobj, os);

        if (!pwIsSamePt2d (p_py->p_pts[0], p_py->p_pts[p_py->num_pts - 1], 
                           MINDOUBLE))
          pwSetEdOpen (edobj, os);
      }
    }
    break;

    case PWcvdata_bspcv :
    case PWcvdata_gmbspcv :
    {
      struct IGRbsp_curve *p_cv=NULL;

      p_cv = edtype == PWcvdata_bspcv ? p_edgeom->data.p_bspcv : 
                                        p_edgeom->data.p_gmbspcv->bspcv;

      edobj = omCreateObjFromClassid (os, OPP_EMSbsedge_class_id);
      OnErrorState (edobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway,
                    PW_K_Internal), wrapup); 

      OMsts = om$send (msg = message EMSedge.EMpostgeom ((char *) p_cv),
                       senderid = edobj, targetid = edobj, targetos = os);

      if (p_cv->phy_closed)
        pwSetEdClosedXYZ (edobj, os);
      else
        pwSetEdOpen (edobj, os);
    }
    break;

    default : 
      OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                    wrapup);
  }

  pwSetEdCvType (edobj, os, edxyz_type);

  if (edprops & EMED_XYZ_CLOSED)
    pwSetEdClosedXYZ (edobj, os);
  if (edprops & EMED_SEAM)
  {
    pwSetEdSeam (edobj, os);
    pwSetEdRevConn (edobj, os);
  } 
  if (edprops & EMED_OPEN)
    pwSetEdOpen (edobj, os);
  if (edprops & EMED_SUBORDINATE)
    pwSetEdSubordinate (edobj, os);
  if (edprops & EMED_TANGENT)
    pwSetEdTangent (edobj, os);
  if (edprops & EMED_DEGENERATE)
  {
    pwSetEdDegen (edobj, os);
    if (pwIsEdIso (edobj, os))
      pwUnsetEdIso (edobj, os);
  }
 
wrapup : 

  PW_Wrapup (PWsts, "pwCreateEdge");

  if (IsError (PWsts))
    return PW_K_NullObjid;
  else
    return edobj;
}

/*
  ABSTRACT

  This function creates a "Dummy edge". A dummy edge is similar to "part edge"
  and serves as an intermediate creator. Finally in the database there will not
  be any dummy edges.

  NOTES

  None.

  HISTORY

  Sanjay  11/14/95  Creation 
*/

PWobjid pwCreateDummyEdge
(
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type
)
{
  return create_part_edge (full_edobj, os, p_edbnds, edprops, edxyz_type, 
                           TRUE);
}

/*
  ABSTRACT

  Given an edge id, bounds it crates a part edge pointing to the input edge.

  NOTES

  None.

  HISTORY

  Sanjay  11/14/95  Creation 
*/

PWobjid pwCreatePartEdge
(
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type
)
{
  return create_part_edge (full_edobj, os, p_edbnds, edprops, edxyz_type,
                           FALSE);
}

/*
  ABSTRACT

  Create's a part/dummy edge.

*/
static PWobjid create_part_edge 
(
  PWobjid full_edobj,
  PWosnum os,
  struct PWcvparam *p_edbnds,
  int edprops,
  int edxyz_type,
  PWboolean is_dummy
)
{
  long OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
  int num_connected=0;
  PWclassid edclass;
  struct EMSedgebound edbnds[2];
  PWobjid edobj=PW_K_NullObjid;
  OM_S_CHANSELECT to_edges, to_owners;

  edclass = is_dummy ? OPP_EMSdumedge_class_id : OPP_EMSpartedge_class_id;
  edbnds[FIRST].span_inx  =  p_edbnds[FIRST].spaninx;
  edbnds[FIRST].param     =  p_edbnds[FIRST].spanpar;
  edbnds[SECOND].span_inx =  p_edbnds[SECOND].spaninx;
  edbnds[SECOND].param    =  p_edbnds[SECOND].spanpar;

  edobj = omCreateObjFromClassid (os, edclass);
  OnErrorState (edobj == PW_K_NullObjid, edobj, PW_K_NullObjid, wrapup); 

  OMsts = om$send (msg = message EMSpartedge.EMpeinit (&OMmsg, 
                                 (unsigned short) edprops, edbnds, 
                                 (unsigned char) edxyz_type),
                   senderid = edobj, targetid = edobj, targetos = os);
  OnErrorCode ((OMsts & OMmsg), wrapup);

  EMmake_chanselect (EMSedge_to_owner, &to_owners);
  EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  num_connected = omNumObjsOnChannel (full_edobj, os, &to_owners);
  OMsts = omConnectObjectAtIndex (full_edobj, os, &to_edges, num_connected,
                                  edobj, os, &to_owners, 0);
  OnErrorCode (OMsts, wrapup);
 
wrapup :

  if (IsError (OMsts & OMmsg) && edobj != PW_K_NullObjid)
  {
    omDeleteObject (edobj, os); 
    edobj = PW_K_NullObjid;
  }

  return edobj;
}

/*
  ABSTRACT

  Given the two points on a natural edge, it returns the natural edge location
  and a bit saying that the given points are flowing in the direction of the
  edge or not.

  NOTES

  Returns FALSE if the given points does not lie on a natural edge.
*/

PWboolean pwGetNatLocation
(
  PWpoint2d edpts[2],
  double u_min,
  double u_max, 
  double v_min,
  double v_max,

  int *natloc,
  PWboolean *natrev
)
{
  PWboolean is_nated=FALSE;
  double u_diff=0, v_diff=0;

  u_diff = u_max - u_min;
  v_diff = v_max - v_min;

  *natloc = 0; *natrev = FALSE;

  if ((fabs(fabs (edpts[0][V] - edpts[1][V]) - v_diff)) <= MINDOUBLE)
  {
    if (fabs (edpts[0][U] - edpts[1][U]) <= MINDOUBLE)
    {
      if (fabs (edpts[0][U] - u_min) <= MINDOUBLE)
      {
        is_nated = TRUE; *natloc = 0;
        if (edpts[0][V] > edpts[1][V])
          *natrev = TRUE;
      }
      else if (fabs (u_max - edpts[0][U]) <= MINDOUBLE)
      {
        is_nated = TRUE; *natloc = 2;
        if (edpts[0][V] < edpts[1][V])
          *natrev = TRUE;
      }
    }
  }
  else if ((fabs(fabs (edpts[0][U] - edpts[1][U]) - u_diff)) <= MINDOUBLE)
  {
    if (fabs (edpts[0][V] - edpts[1][V]) <= MINDOUBLE)
    {
      if (fabs (edpts[0][V] - v_min) <= MINDOUBLE)
      {
        is_nated = TRUE; *natloc = 3;
        if (edpts[0][U] < edpts[1][U])
          *natrev = TRUE;
      }
      else if (fabs (v_max - edpts[0][V]) <= MINDOUBLE)
      {
        is_nated = TRUE; *natloc = 1;
        if (edpts[0][U] > edpts[1][U])
          *natrev = TRUE; 
      }
    }
  }

  return is_nated;
}

end implementation EMSedge;
