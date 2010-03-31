/*
  OVERVIEW
 
  This file consists of functions related to Surface geometry. 
*/ 

class implementation EMSsubbs;

#include <math.h>

#include "OMmacros.h"
#include "bs.h"
#include "bsgeom_cvsf.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "bssftgeomsf.h"
#include "PWapi/sfgeom.h" 

/*
  ABSTRACT

  Obtain the given surface's geometry in a B-spline format. The transformation
  matrix that needs to be applied to the stored geometry is also supplied. 
  The caller inputs the pointer to a B-spline surface structure that has
  it's poles/weights and knots pointers pointing to valid and sufficient 
  memory.
*/

PWresult pwGetSfAsBspline
(
  PWobjid sfobj, 
  PWosnum os,
  short mattyp,
  PWmatrix matrix,
  struct IGRbsp_surface *p_sfgeom
)
{
  long msg=EMS_S_Success;
  PWresult result=PW_K_Success;

  OnErrorState (!p_sfgeom, result, SetError (PW_K_Pathway, PW_K_Memory),
   wrapup);

  result = om$send (msg = message GRvg.GRgetgeom (&msg, &mattyp, matrix,
            (IGRchar *) p_sfgeom), senderid = sfobj, targetid = sfobj,
            targetos = os);
  OnErrorState (IsError (result & msg), result, PW_K_Error, wrapup);

wrapup:
  PW_WrapupId (result, "GetSfAsBsp", sfobj);
  return (result);
}


/*
  ABSTRACT

  Obtain the given surface's geometry's B-spline format's size in bytes. 
  This includes the size for the IGRbsp_surface structure + the memory needed
  to hold the poles/knots/weights + any padding necessary to get 8-bute
  alignment.
*/

int  pwGetSfSize 
(
  PWobjid  sfobj,
  PWosnum  os
)
{
  short mattyp=MAIDMX;
  long msg=EMS_S_Success;
  PWresult result=PW_K_Success;
  long size=0; 
  IGRmatrix idmx;

  pwIdMx (idmx);
  result = om$send (msg = message GRvg.GRgetsize (&msg, &mattyp, idmx, &size),
           senderid = sfobj, targetid = sfobj, targetos = os);
  OnErrorState (IsError (result & msg) || !size, result, PW_K_Error, wrapup);

wrapup:
  PW_WrapupId (result, "GetSfSize", sfobj);
  return (size);
}


/*
  ABSTRACT

  Inputs a surface object and it's B-spline representation and correctly
  initializes the BSgeom_bsp_surf that corresponds to this surface. User
  needs to provide this structure.
*/

PWresult pwSfAsGeomBspline
(
  PWobjid sfobj,
  PWosnum os,
  struct IGRbsp_surface *bspsf,
  struct BSgeom_bsp_surf *gmbspsf
)
{
  PWresult result=PW_K_Success;
  PWrange2d uvrng;

  OnErrorState (!bspsf || !gmbspsf, result, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  gmbspsf->geom_prop = FALSE;
  gmbspsf->bspsf = bspsf;
  gmbspsf->type = pwSfType (sfobj, os);
  gmbspsf->bounded = TRUE;
  gmbspsf->sfgen_cv = NULL;

  pwGetSfUvRng (sfobj, os, uvrng);
  gmbspsf->urange[0] = uvrng[MINIMUM][U];
  gmbspsf->urange[1] = uvrng[MAXIMUM][U];
  gmbspsf->vrange[0] = uvrng[MINIMUM][V];
  gmbspsf->vrange[1] = uvrng[MAXIMUM][V];

wrapup:
  PW_WrapupId (result, "SfAsGmbsp", sfobj);
  return (result); 
}

/*
  ABSTRACT

  Inputs a plane definition and correctly initializes the BSgeom_bsp_surf that
  corresponds to this definition. User needs to provide this structure. There
  is NO B-spline surface defined in this case. The geometry-definition will
  carry the 'infinite' flag.
*/

PWresult pwPlAsGeomBspline
(
  struct PWplane *plane,
  struct BSgeom_bsp_surf *gmbspsf
)
{
  PWresult result=PW_K_Success;

  OnErrorState (!plane || !gmbspsf, result, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  gmbspsf->geom_prop = TRUE;
  gmbspsf->bspsf = NULL;
  gmbspsf->type = BSINF_PLANE;
  gmbspsf->bounded = FALSE;
  gmbspsf->sfgen_cv = NULL;
  memcpy (gmbspsf->pt1, plane->pt, sizeof (PWpoint));
  memcpy (gmbspsf->vec1, plane->normal, sizeof (PWvector));

wrapup:
  PW_Wrapup (result, "PlAsGmbsp");
  return (result); 
}

/*
  ABSTRACT

  Inputs a surface data definition and correctly initializes the 
  BSgeom_bsp_surf that corresponds to this definition. User needs to provide 
  this structure. This structure (BSgeom_bsp_surf) is NEVER FREED by the
  user as it may contain copies of pointers to memory that it has not created.
*/

PWresult pwSfdataAsGeomBspline
(
  struct PWsfdata *sfdata,
  struct BSgeom_bsp_surf *gmbspsf
)
{
  PWresult result=PW_K_Success;

  OnErrorState (!sfdata || !gmbspsf, result, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  if (sfdata->datatype == PWsfdata_bspsf)
  {
    pwSfAsGeomBspline (PW_K_NullObjid, OS, sfdata->data.p_bspsf, gmbspsf);
  }
  else if (sfdata->datatype == PWsfdata_plane)
  {
    pwPlAsGeomBspline (&sfdata->data.plane, gmbspsf);
  }
  else if (sfdata->datatype == PWsfdata_gmbspsf)
  {
    *gmbspsf = *sfdata->data.p_gmbspsf;
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
    goto wrapup;
  }

wrapup:
  PW_Wrapup (result, "SfdataAsGmbsp");
  return (result); 
}

end implementation EMSsubbs;

