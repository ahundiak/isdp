/*
  FILE DESCRIPTION

  This file contains the source for the function dealing with query on a
  surface entity's boundary elements -- (vertices), edges, loops.
*/

class implementation EMSedge;

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"

#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "prototypes/bsconstprcv.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"
#include "PWapi/sfbnds.h"
#include "PWapi/cvgeom.h"
#include "PWapi/edgeom.h"
#include "PWapi/sfgeom.h"
#include "PWapi/degengm.h"
#include "PWapi/sfdntrav.h"

%safe
struct s_sfedges
{
  PWboolean is_dominant;
  PWboolean is_not_degenerate;
  PWboolean is_not_tangent;
  
  int *num_edges;
  PWobjid **edges;
};

static PWresult getsfedges
(
  PWobjid edobj,
  PWosnum,
  void *d_sfedges
);
%endsafe

/*
  DESCRIPTION

  Returns whether the natural boundaries of the given surface are degenerate
  in xyz or not. Four boolean flags will be returned corresponds to 4 bound-
  aries of the surface.


  NOTES

  For any surface there will be 4 natural boundaries corresponding to :
  u=0 - U-Iso Curve, u=1 - U-Iso Curve
  v=0 - V-Iso Curve, v=1 - V-Iso Curve


  HISTORY

  Sanjay  09/12/95  Creation
*/

PWresult pwGetDegenNatBdrysOfSf
(
  struct IGRbsp_surface *p_sf,
  double lentol,

  PWboolean *degen_u0,
  PWboolean *degen_u1,
  PWboolean *degen_v0,
  PWboolean *degen_v1
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE, tst_plan=FALSE, phy_closed=FALSE;
  struct IGRbsp_curve u_cv, v_cv, *p_cv=NULL;
  int dir=0, degen[2][2], inx=0;
  short opt=0;
  double par=0;

  memset (&u_cv, 0, sizeof (struct IGRbsp_curve));
  memset (&v_cv, 0, sizeof (struct IGRbsp_curve));

  PWsts = PW_AllocBspCvStack (p_sf->v_num_poles, p_sf->v_order, p_sf->rational,
                              u_cv);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  PWsts = PW_AllocBspCvStack (p_sf->u_num_poles, p_sf->u_order, p_sf->rational, 
                              v_cv);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  for (dir=U; dir<=V; dir++)
  {
    if (dir == U)
    {
      phy_closed = p_sf->u_phy_closed;
      p_cv = &u_cv; opt = 1;
    }
    else
    {
      phy_closed = p_sf->v_phy_closed;
      p_cv = &v_cv; opt = 2;
    }

    for (inx=0, par = 0.0; inx < 2; inx++, par += 1.0)
    {
      if (phy_closed && inx)
      {
        degen[dir][inx] = degen[dir][inx-1];
      }
      else
      {
        BSsts = BSconstprcv (&BSmsg, p_sf, &opt, &par, &tst_plan, p_cv);
        OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath,
                      PW_K_Internal), wrapup);

        degen[dir][inx] = pwIsCvDegen (p_cv, lentol);
      }
    }
  }

  *degen_u0 = degen[0][0]; *degen_u1 = degen[0][1];
  *degen_v0 = degen[1][0]; *degen_v1 = degen[1][1];

wrapup :

  PW_Wrapup (PWsts, "pwGetDegenNatBdrysOfSf");
  return PWsts;
}



/*
  DESCRIPTION

  The following function returns all the edges on a given surface that
  satisfy the criteria specified by the input Boolean flags. Each of 
  the flags set to TRUE, must be satisfied by the edge being returned. The
  flag that is set to FALSE is ignored as a criterion. 

  is_dominant -- if TRUE, each of the edges returned must be the dominant
                 of the pair (if it has a common edge). If it is a single edge
                 it is dominant by definition.
  is_not_degenerate -- if TRUE, each of the edges being returned must have a 
                 length greater than the currently active chord-height 
                 tolerance in XYZ space.
  is_not_tangent -- if TRUE, each of the edges being returned should have
                 a non-tangent continuity with it's common edge. An edge
                 that does not have a common edge is automatically non-tangent.

  By setting all of the above flags to be TRUE, one can obtain a unique set
  of all the non-zero length edges of a surface-entity which have a non-C1
  continuity.


  HISTORY

  SS  :  03/09/96  :  Creation
*/

PWresult pwGetSfEds
(
  PWobjid sfobj,
  PWosnum os,
  PWboolean is_dominant,
  PWboolean is_not_degenerate,
  PWboolean is_not_tangent,
  int *num_edges,
  PWobjid **edges
)
{
  PWresult result=PW_K_Success;
  struct s_sfedges d_sfedges;

  *num_edges = 0;
  *edges = NULL;

  d_sfedges.is_dominant = is_dominant;
  d_sfedges.is_not_degenerate = is_not_degenerate;
  d_sfedges.is_not_tangent = is_not_tangent;
  d_sfedges.num_edges = num_edges;
  d_sfedges.edges = edges;

  result = pwTraverseSfEds (sfobj, os,
            (PWresult (*)()) getsfedges, (void *) &d_sfedges);
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "pwGetSfEds");
  return (result);
}


/*
  DESCRIPTION

  The following function returns the IGRbsp_curve structures corresponding
  to all the edges on a given surface that satisfy the criteria specified by
  the input Boolean flags. Each of the flags set to TRUE, must be satisfied by
  the edge being returned. The flag that is set to FALSE is ignored as a
  criterion. 

  is_dominant -- if TRUE, each of the edges processed must be the dominant
                 of the pair (if it has a common edge). If it is a single edge
                 it is dominant by definition.
  is_not_degenerate -- if TRUE, each of the edges processed must have a 
                 length greater than the currently active chord-height 
                 tolerance in XYZ space.
  is_not_tangent -- if TRUE, each of the edges processed should have
                 a non-tangent continuity with it's common edge. An edge
                 that does not have a common edge is automatically non-tangent.

  By setting all of the above flags to be TRUE, one can obtain a unique set
  of curves corresponding to all the non-zero length edges of a surface-entity
  which have a non-C1 continuity.


  HISTORY

  SS  :  03/09/96  :  Creation
*/

PWresult pwGetSfEdCvs
(
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  PWboolean is_dominant,
  PWboolean is_not_degenerate,
  PWboolean is_not_tangent,
  int *num_cvs,
  struct IGRbsp_curve ***cvs
)
{
  PWresult result=PW_K_Success;
  int i, num_eds;
  PWobjid *eds;
  struct IGRbsp_surface *sf;
  struct PWsfdata sfdata;

  *num_cvs = 0;
  *cvs = NULL;

  result = pwGetSfEds (sfobj, os, 
            is_dominant, is_not_degenerate, is_not_tangent,
            &num_eds, &eds);
  OnErrorCode (result, wrapup);

  if (num_eds)
  {
    result = PW_GetSfBspsfStack (sfobj, os, mattyp, mat, sf);
    OnErrorCode (result, wrapup);
    sfdata.datatype = PWsfdata_bspsf;
    sfdata.data.p_bspsf = sf;

    *cvs = (struct IGRbsp_curve **) malloc (num_eds * sizeof (char *));
    OnErrorState (!*cvs, result, SetError (PW_K_Pathway, PW_K_DynamicMemory),
     wrapup);
    memset (*cvs, NULL, num_eds * sizeof (char *));

    for (i=0; i<num_eds; i++)
    {
      result = pwGetEdbcXyzGeom (eds[i], os, &sfdata, &(*cvs)[i]);
      OnErrorCode (result, wrapup);
    }
    *num_cvs = num_eds;
  }

wrapup:
  PW_Wrapup (result, "pwGetSfEdCvs");
  return (result);
}

/*----------------------  STATIC FUNCTIONS -------------------------------*/

#define EDGE_BUFFER_INCR 10

static PWresult getsfedges
(
  PWobjid edobj,
  PWosnum os,
  void *pd_sfedges
)
{
  PWboolean output_edge=TRUE;
  unsigned short props;
  int num_edges;
  long msg;
  PWresult result=PW_K_Success;
  PWobjid *edges;
  struct s_sfedges *d_sfedges;

  d_sfedges = (struct s_sfedges *) pd_sfedges;

  result = om$send (msg = message EMSedge.EMget_props (&msg, &props),
             targetid = edobj, targetos = os, senderid = PW_K_NullObjid);
  OnErrorCode (result, wrapup);

  if (d_sfedges->is_dominant && props & EMED_SUBORDINATE ||
      d_sfedges->is_not_degenerate && props & EMED_DEGENERATE ||
      d_sfedges->is_not_tangent && props & EMED_TANGENT)
    output_edge = FALSE;

  if (output_edge)
  {
    num_edges = *(d_sfedges->num_edges);
    edges = *(d_sfedges->edges);

    if (! (num_edges % EDGE_BUFFER_INCR))
    {
      if (!num_edges)
        edges = (PWobjid *) malloc (EDGE_BUFFER_INCR * 
                  sizeof (PWobjid));
      else
        edges = (PWobjid *) realloc (edges, 
                 (num_edges + EDGE_BUFFER_INCR) * sizeof (PWobjid));
      OnErrorState (!edges, result, 
       SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);
    }

    edges[num_edges] = edobj;
    num_edges++;

    *(d_sfedges->edges) = edges;
    *(d_sfedges->num_edges) = num_edges;
  }

wrapup:
  return (result);
}

end implementation EMSedge;
