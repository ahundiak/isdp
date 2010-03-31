/* Includes */
#include "OMminimum.h"
#include "OMerrordef.h"

#include "bs.h"
#include "bsparameters.h"
#include "madef.h"

#include "emsdef.h"

#include "PWminimum.h"            /* Pathway */
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWattrib.h"

/* Prototypes */

#include "PWapi/fchlcons.h"
#include "PWapi/objcons.h"
#include "objconn.h"
#include "PWapi/objdel.h"        /* Pathway */
#include "PWapi/edprops.h"
#include "PWapi/lpprops.h"
#include "PWapi/edprops.h"

#include "PWapi/sfgeom.h"
#include "PWapi/lpcons.h"
#include "PWapi/fchlcons.h"
#include "PWapi/mx.h"
#include "PWapi/fchlsf.h"

#include "ptclass.h"

extern OMuword OPP_EMSloop_class_id;

/* Internal macros */

#define U_FACTOR  0.3675
#define V_FACTOR  0.7365

/* Static functions */

static PWobjid CreateFaceOrHole
(
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom, 
  PWboolean is_face
);

/*
  ABSTACT

  NOTES
*/ 

PWobjid pwCreateFaceFromEdges
(
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom 
)
{
  return (CreateFaceOrHole (os, num_edges, p_edges, p_sfgeom,
                               (PWboolean) TRUE));
}

/*
  ABSTACT

  NOTES
*/

PWobjid pwCreateHoleFromEdges
(
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom
)
{
  return (CreateFaceOrHole (os, num_edges, p_edges, p_sfgeom, 
                               (PWboolean) FALSE));
}

/*
  ABSTRACT

  NOTES
*/

PWresult pwCreateNaturalFaceOnSf
(
  PWobjid sfobj,
  PWosnum os
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
 
  short mattyp=MAIDMX;
  PWmatrix idmx; 
  struct IGRbsp_surface *p_sfgeom=NULL;

  double bastol=0;
  int num_loops=0;
  PWobjid *p_loops=NULL;

  PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, pwIdMx (idmx), p_sfgeom);
  OnErrorCode (PWsts, wrapup);

  BSEXTRACTPAR (&BSmsg, BSTOLBASIS, bastol);
  PWsts = pwCreateLoopFromEdgeGeoms (0, NULL, NULL, NULL, NULL, p_sfgeom, os,
                                     bastol, &num_loops, &p_loops);
  OnErrorCode (PWsts, wrapup);

  PWsts = pwAddFaceToSf (sfobj, os, p_loops[0]);
  OnErrorCode (PWsts, wrapup);
  
wrapup :

  PW_Wrapup (PWsts, "pwCreateNaturalFaceOnSf");  
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWobjid CreateFaceOrHole
(
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom, 
  PWboolean is_face
)
{
  int ed=0, num_connected=0;
  PWresult PWsts=PW_K_Success;
  PWobjid  lpobj=PW_K_NullObjid;
  PWboolean is_natural=TRUE;
  OM_S_CHANSELECT to_edge, to_loop;

  lpobj = omCreateObjFromClassid (os, OPP_EMSloop_class_id);
  OnErrorState ((lpobj == PW_K_NullObjid), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

   pwSetLpActive (lpobj, os);

  EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
  EMmake_chanselect (EMSedge_to_owner, &to_loop);

  for (ed=0, num_connected=0; ed<num_edges; ed++, num_connected++)
  {
    PWsts = omConnectObjectAtIndex (lpobj, os, &to_loop, ed, p_edges[ed], os,
                                    &to_edge, 0);
    OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Pathway, 
                  PW_K_InvalidArg), wrapup);

    if (is_natural && !pwIsEdNatural (p_edges[ed], os))
      is_natural = FALSE;
  }

  if (is_natural && num_edges)
    pwSetLpNatural (lpobj, os);
  pwSetLpRange (lpobj, os);

  if (is_face)
    pwSetLpFace (lpobj, os);

  if (num_edges && p_edges)
  {  
    BSrc BSmsg=BSSUCC;
    PWrange2d lprng;
    PWpoint2d uvpt;
    double chttol;
    struct PWsfdata sfdata;
    struct PWid lpid;
    enum PWptloctype ptpos; 
    PWobjid bdry_contain_elem=PW_K_NullObjid;
    struct PWcvpt bdrypt;

    /*
     * get a point outside the loop range. 
     */
    pwGetLpRange (lpobj, os, lprng);
       
    uvpt[U] = lprng[MAXIMUM][U] + 
              U_FACTOR * (lprng[MAXIMUM][U] - lprng[MINIMUM][U]); 
    uvpt[V] = lprng[MAXIMUM][V] + 
              V_FACTOR * (lprng[MAXIMUM][V] - lprng[MINIMUM][V]); 

    sfdata.datatype = PWsfdata_bspsf;
    sfdata.data.p_bspsf = p_sfgeom;
    lpid.objid = lpobj;
    lpid.osnum = os;
    BSEXTRACTPAR (&BSmsg, BSTOLCHRDHT, chttol);

    /*
     * Determine the location of this point with respect to this loop.
     */
    PWsts = LpPtClassify (&lpid, uvpt, chttol, &sfdata, &ptpos, 
                            &bdry_contain_elem, &bdrypt);
    if (bdrypt.p_attrib) pwFreeAttribList (bdrypt.p_attrib);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    
    switch (ptpos)
    {
      case PWptloc_inarea :
      case PWptloc_inhole : 
      {
        if (is_face ? (ptpos == PWptloc_inarea) : (ptpos == PWptloc_inhole))
        {
          /*
           * It is a face and the point lies in area region
           *               OR
           * It is a hole and the point lies in hole region
           *
           * So, reverse all the edges of the loop and also reverse the loop
           * to represent the area/hole correctly.
           */ 

          for (ed=0; ed<num_edges; ed++)
          {
            if ( pwIsEdRev (p_edges[ed], os))
            {
              pwUnsetEdRev (p_edges[ed], os);
            }
            else
            {
              pwSetEdRev (p_edges[ed], os);
            }
          }

          pwSetLpRev (lpobj, os); 
        }
      }
      break;

      default : 
      {
        OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                      wrapup);
      }
    } 
  }
  
wrapup :

  PW_Wrapup (PWsts, "CreateFaceOrHole");

  if (IsError (PWsts) && lpobj != PW_K_NullObjid)
  {
    /*
     * Some error occured. Disconnect all the edges from the loop and then
     * delete the construct loop.
     */

    if (num_edges && p_edges)
    {
      OM_S_CHANSELECT to_loop, to_edge;

      EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
      EMmake_chanselect (EMSedge_to_owner, &to_loop);

      for (ed=0; ed<num_edges; ed++)
        omDisconnectObject (lpobj, os, &to_loop, p_edges[ed], os, &to_edge);
    }

    omDeleteObject (lpobj, os);

    lpobj = PW_K_NullObjid;
  }

  return lpobj;
}
