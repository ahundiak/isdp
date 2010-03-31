/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>
#include "alloca.h"

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsvalues.h"
#include "maidmx.h"

#include "emsdef.h"

#include "PWminimum.h"            /* Pathway */
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWattrib.h"

/* Prototypes */

#include "PWapi/fchlsf.h"
#include "PWapi/sflp.h"
#include "channel.h"
#include "objconn.h"
#include "PWapi/lpprops.h"
#include "PWapi/lscons.h"
#include "PWapi/lsgetprops.h"
#include "PWapi/lssetprops.h"

#include "PWapi/lped.h"
#include "PWapi/edintpts.h"
#include "PWapi/mx.h"
#include "PWapi/sfgeom.h"
#include "PWapi/sfptloc.h"
#include "PWapi/lpintpt.h"

/*
  ABSTRACT

  NOTES
*/

PWresult pwAddFaceToSf
(
  PWobjid sfobj,
  PWosnum os,
  PWobjid faceobj
)
{
  PWresult PWsts=PW_K_Success;
  OM_S_CHANSELECT to_loopset, to_loops, to_outer;
  PWobjid lsobj=PW_K_NullObjid;

  /*
   * If the incoming loop is not a face error out.
   */

  OnErrorState (!pwIsLpFace (faceobj, os), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  /*
   * get all the channel info.
   */

  EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  EMmake_chanselect (EMSloop_to_outter, &to_outer);

  if (omNumObjsOnChannel (sfobj, os, &to_loopset))
  {
    /*
     * Loopset exists on the surface which means already some loops are 
     * existing on the surface.
     */

    BSrc BSmsg=BSSUCC;
    int num_edges=0, num_pts=0, pt=0;
    PWpoint2d *p_pts=NULL;
    enum PWptloctype ptpos=PWptloc_unknown; 
    struct PWcvpt bdrypt;
    PWobjid bdry_contain_elem=PW_K_NullObjid;
    double bastol=0;
    struct PWgeomid sfgmid;
    unsigned short  mattyp;
    PWmatrix        mat;
    struct IGRbsp_surface *p_sfgeom=NULL;
    struct PWsfdata   sfdata;


    mattyp = 2;
    MAidmx (&BSmsg, mat);
    sfdata.datatype = PWsfdata_bspsf;

    BSEXTRACTPAR (&BSmsg, BSTOLBASIS, bastol);

    /*
     * Get the surface geometry on the stack
     */
    PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, mat, p_sfgeom);
    OnErrorCode (PWsts, wrapup);

    sfdata.data.p_bspsf = p_sfgeom;

    omGetObjsOnChannel (sfobj, os, &to_loopset, &lsobj);

    num_edges = pwNumEdsOfLp (faceobj, os);
    OnErrorState (!num_edges, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                  wrapup);

    num_pts = num_edges;
    p_pts = (PWpoint2d *) alloca (num_pts * sizeof (PWpoint2d));
    OnErrorState (!p_pts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup)

    PWsts = pwLpInternalPts (faceobj, os, &sfdata, bastol, 1, num_pts, p_pts);
    OnErrorCode (PWsts, wrapup);
    /*****    
    PWsts = pwLpInternalPts (faceobj, os, num_pts, p_pts);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    *****/

    /*
     * For each point do a point locate.
     */
    sfgmid.id.objid = sfobj; sfgmid.id.osnum = os;
    sfgmid.mattyp = 2; pwIdMx (sfgmid.mat);

    for (pt=0; pt<num_pts; pt++)
    {
      memset (&bdrypt, 0, sizeof (struct PWcvpt));

      PWsts = pwSfPtLocate (&sfgmid, NULL, p_pts[pt], bastol, &ptpos, 
                            &bdry_contain_elem, &bdrypt);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

      /**
      OnErrorState ((ptpos == PWptloc_outside), PWsts, SetError (PW_K_Pathway, 
                    PW_K_InvalidArg), wrapup);
      **/

      if (ptpos == PWptloc_inarea || ptpos == PWptloc_inhole || ptpos == PWptloc_outside)
        break;

      if (bdrypt.p_attrib) pwFreeAttribList (bdrypt.p_attrib);
    }

    OnErrorState ((ptpos != PWptloc_inarea && ptpos != PWptloc_inhole && 
                   ptpos != PWptloc_outside), PWsts,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);

    if (ptpos == PWptloc_inarea)
    {
      OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway,PW_K_NotImplemented), 
                    wrapup);

      if (!pwIsLpFace (bdry_contain_elem, os))
      {
        OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, 
                      PW_K_NotImplemented), wrapup);

        /*
        if (IsLpContainsLp (bdry_contain_elem, faceobj, os, &sfdata)) 
        {
          OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_NotImplemented), wrapup);
        }
        else
        {
          PWsts = omConnectObjectAtIndex (lsobj, os, &to_outer, 0, faceobj, os,
                                          &to_loops, 0);
          OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
        } 
        */

      }
      else 
      {
        /*
         * This is some thing invalid at this stage. But, as the caller does
         * not have knowledge about the sequence of the calls, I am allowing
         * it.
         */
     
        if (pwGetDebugLevel () >= PW_K_DebugWarning)
          pwDebugLine (PW_K_DebugWarning, "Nest : Invalid nesting.\n");

        PWsts = omConnectObjectAtIndex (lsobj, os, &to_outer, 0, faceobj, os,
                                        &to_loops, 0);
        OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
		pwUnsetLsNatural (lsobj, os);
      }
    }
    else 
    {
      if (((ptpos == PWptloc_outside) ? TRUE : 
           pwIsLpFace (bdry_contain_elem, os)))
      {
        PWsts = omConnectObjectAtIndex (lsobj, os, &to_outer, 0, faceobj, os,
                                        &to_loops, 0);
        OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

        pwSetLpOuter (faceobj, os);

        pwUnsetLsNatural (lsobj, os);
      }
      else
      {
        OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, 
                      PW_K_NotImplemented), wrapup);
      }
    }
  }
  else
  {
    /*
     * First time a face is being connected to the surface. Construct the 
     * loopset and connect it to the surface and add the face to the loopset.
     */

    lsobj = pwCreateLoopset (sfobj, os);
    OnErrorState (lsobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway,
                  PW_K_Internal), wrapup);

    PWsts = omConnectObjectAtIndex (lsobj, os, &to_outer, 0, faceobj, os,
                                    &to_loops, 0);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    /*
     * As only one face is existing set the EXTERNAL BIT for it.
     */    
    pwSetLpOuter (faceobj, os);

    if (pwIsLpNatural (faceobj, os))
      pwSetLsNatural (lsobj, os);
  }

wrapup : 

  if (!IsError (PWsts))
  { 
    pwSetLpActive (faceobj, os);
  }
 
  PW_Wrapup (PWsts, "pwAddFaceToSf");
  return PWsts;
}

PWresult pwAddHoleToSf
(
  PWobjid sfobj,
  PWosnum os,
  PWobjid holeobj
)
{
  PWresult PWsts=PW_K_Success;
  OM_S_CHANSELECT to_loopset, to_loops, to_outer, to_inner;
  PWobjid lsobj=PW_K_NullObjid;

  /*
   * If the incoming loop is not a hole error out.
   */

  OnErrorState (pwIsLpFace (holeobj, os), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  /*
   * get all the channel info.
   */

  EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  EMmake_chanselect (EMSloop_to_outter, &to_outer);
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  if (omNumObjsOnChannel (sfobj, os, &to_loopset))
  {
    /*
     * Loopset exists on the surface which means already some loops are
     * existing on the surface.
     */

    BSrc BSmsg=BSSUCC;
    int num_edges=0, num_pts=0, pt=0;
    PWpoint2d *p_pts=NULL;
    enum PWptloctype ptpos=PWptloc_unknown;
    struct PWcvpt bdrypt;
    PWobjid bdry_contain_elem=PW_K_NullObjid;
    double bastol=0;
    struct PWgeomid sfgmid;
    unsigned short  mattyp;
    PWmatrix        mat;
    struct IGRbsp_surface *p_sfgeom=NULL;
    struct PWsfdata   sfdata;

	
    mattyp = 2;
    MAidmx (&BSmsg, mat);
    sfdata.datatype = PWsfdata_bspsf;

    BSEXTRACTPAR (&BSmsg, BSTOLBASIS, bastol);

    /*
     * Get the surface geometry on the stack
     */
    PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, mat, p_sfgeom);
    OnErrorCode (PWsts, wrapup);

    sfdata.data.p_bspsf = p_sfgeom;


    omGetObjsOnChannel (sfobj, os,&to_loopset, &lsobj);

    num_edges = pwNumEdsOfLp (holeobj, os);
    OnErrorState (!num_edges, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                  wrapup);

    num_pts = num_edges;
    p_pts = (PWpoint2d *) alloca (num_pts * sizeof (PWpoint2d));
    OnErrorState (!p_pts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup)

    PWsts = pwLpInternalPts (holeobj, os, &sfdata, bastol, 1, num_pts, p_pts);
    OnErrorCode (PWsts, wrapup);

    /****
    PWsts = pwLpInternalPts (holeobj, os, num_pts, p_pts);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    ******/

    /*
     * For each point do a point locate.
     */
    sfgmid.id.objid = sfobj; sfgmid.id.osnum = os;
    sfgmid.mattyp = 2; pwIdMx (sfgmid.mat);

    for (pt=0; pt<num_pts; pt++) 
    {
      memset (&bdrypt, 0, sizeof (struct PWcvpt));

      PWsts = pwSfPtLocate (&sfgmid, NULL, p_pts[pt], bastol, &ptpos, 
                            &bdry_contain_elem, &bdrypt);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

      OnErrorState ((ptpos == PWptloc_outside), PWsts, SetError (PW_K_Pathway, 
                    PW_K_InvalidArg), wrapup);

      if (ptpos == PWptloc_inarea || ptpos == PWptloc_inhole)
        break;

      if (bdrypt.p_attrib) pwFreeAttribList (bdrypt.p_attrib);
    }

    OnErrorState ((ptpos != PWptloc_inarea && ptpos != PWptloc_inhole), PWsts,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);

    if (ptpos == PWptloc_inarea)
    {
      if (pwIsLpFace (bdry_contain_elem, os))
      {
        PWsts = omConnectObjectAtIndex (bdry_contain_elem, os, &to_outer, 
                                        MAXINT, holeobj, os, &to_inner, 0); 
        OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
		pwUnsetLsNatural (lsobj, os);
      }
      else
      {
        OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_NotImplemented),
                      wrapup);
      }
    }
    else
    {
      OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_NotImplemented),
                    wrapup);
    }
  }
  else
  {
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_NotImplemented),
                  wrapup);
  }


wrapup : 

  if (!IsError (PWsts))
  { 
    pwSetLpActive (holeobj, os);
  }
 
  PW_Wrapup (PWsts, "pwAddHoleToSf");
  return PWsts;
}

PWresult pwRemoveFaceOfSf
(
  PWobjid faceobj,
  PWosnum os
)
{
  PWresult PWsts=PW_K_Success;

  /* TBD */
  /* Supress compiler warning */
  os = os;
  faceobj = faceobj;
  OnErrorState (TRUE, PWsts, SetError (PWsts, PW_K_NotImplemented), wrapup); 
   

wrapup : 
 
  PW_Wrapup (PWsts, "pwRemoveFaceOfsf");
  return PWsts;
}

PWresult pwRemoveHoleOfSf
(
  PWobjid hole,
  PWosnum os
)
{
  PWresult PWsts=PW_K_Success;

  /* TBD */

  /* Supress compiler warning */
  os = os;
  hole = hole;
  OnErrorState (TRUE, PWsts, SetError (PWsts, PW_K_NotImplemented), wrapup); 
   
wrapup : 
 
  PW_Wrapup (PWsts, "pwRemoveHoleOfSf");
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/
/*******
PWresult pwLpInternalPts
(
  PWobjid lpobj,
  PWosnum os,
  int num_pts,
  PWpoint2d *p_pts
)
{
  PWresult PWsts=PW_K_Success;

  int num_edges=0, edge=0, knt=0, pt=0, start=0, low_bound=0, up_bound=0;
  PWobjid *p_edges=NULL;
  int *p_numpts_edge=NULL, incr=0; * Number of points for edge and how the 
                                    * increment should be done per edge basis. 
                                    *

  *
   * Get the edges of the input loop.
   *
  num_edges = pwNumEdsOfLp (lpobj, os);
  OnErrorState (!num_edges, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                wrapup);

  p_edges = (PWobjid  *) alloca (num_edges * sizeof (PWobjid));
  OnErrorState (!p_edges, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory), 
                wrapup);

  num_edges = pwEdsOfLp (lpobj, os, p_edges);
  OnErrorState (!num_edges, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                wrapup);
 
  *
   * Compute the number of points per edge and the edge increment.
   * 

  p_numpts_edge = (int *) alloca (num_edges * sizeof (int));
  OnErrorState (!p_numpts_edge, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  memset (p_numpts_edge, 0, num_edges * sizeof (int));

  incr = 1;
  start = num_edges/2;
  pt = 0;

  if (num_pts < num_edges)
  {
    low_bound = start - (num_pts/2);
    up_bound = start + (num_pts/2);
    if ((up_bound - low_bound + 1) < num_pts)
      low_bound --; 
  }
  else
  {
    low_bound = 0;
    up_bound = num_edges;
  }

  do 
  { 
    for (knt=start; knt>=low_bound; knt--)
    { 
      p_numpts_edge[knt] += 1;
      pt++;
    }

    for (knt=start+1; knt<up_bound; knt++)
    {
      p_numpts_edge[knt] += 1;
      pt++;
    }

  } while (pt < num_pts);

  for (edge=0, pt=0; edge<num_edges; edge += incr)
  {
    PWsts = pwEdInternalPts (p_edges[edge], os, p_numpts_edge[edge], 
                             &p_pts[pt]);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    pt += p_numpts_edge[edge];
  }															    
wrapup :

  PW_Wrapup (PWsts, "pwLpInternalPts");
  return PWsts;
}
************/

