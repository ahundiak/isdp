/*
  OVERVIEW

  This file contains the API for composite curve trimming with respect to the
  face boundaries in the model-space of the surface. Even though, this function
  is specially written for Add/Remove Feature, it can be viewed as a general 
  function can be useful in Curve Boolean.

  NOTES

  Even though for the time-being this serves only Add/Remove feature, it can
  be made more generic so that it can be used by other functionalities such as
  3D Planar-Curve Boolean.

  HISTORY

  Sanjay         11/06/95          Creation

*/


/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>          /* System */
#include <alloca.h>
#include <malloc.h>

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "madef.h"

#include "PWminimum.h"
#include "PWgmdata.h"        /* Pathway */
#include "PWgmint.h"        
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWerror.h"

/* Prototypes */

#include "bsxln.h"
#include "bsprptonln.h"
#include "bssfnormal.h"
#include "bsxlnln.h"
#include "bsalloccv.h"
#include "bscv_copy.h"

#include "PWapi/clxyzcvfc.h"
#include "PWapi/cluvcvfc.h"

#include "PWapi/sfgeom.h"
#include "PWapi/cvgeom.h"

#include "PWapi/mapcvonsf.h"
#include "PWapi/mapcvonpln.h"
#include "PWapi/mx.h"
#include "PWapi/normvec.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/dotp.h"
#include "PWapi/crossp.h"
#include "PWapi/ptpargm.h"
#include "PWapi/mkvec.h"
#include "PWapi/memfunc.h"
#include "PWapi/partol.h"
#include "PWapi/revgm.h"
#include "PWapi/gmdatamem.h"
#include "PWapi/partgm.h"
#include "PWapi/lpprops.h"
#include "PWapi/sflp.h"
#include "PWapi/revvec.h"


static PWresult get_extvec_in_uv
(
  struct PWcvdata *p_xyzcv,
  PWvector extvec,
  PWboolean atstart,
  struct IGRbsp_surface *p_sfgeom,

  double lentol,

  PWvector2d uv_extvec
);


/*
  ABSTRACT

  Given a model-space composite curve, it maps it to the parametric space of 
  the surface and  trims the input curve with the face boundaries. If the 
  input curve is short enough so that it cannot be trimmed it extends the 
  input curve and then trims the curve. It forms closed loops out of the 
  trimmed curve and the boundaries and returns them.

  DESCRIPTION

  ARGUMENTS

  NOTES

  KEYWORDS

  Internal API

  HISTORY

*/

PWresult pwCloseXyzCompCvWithFaceBounds
(
  int num_xyzcv,
  struct PWcvdata *p_xyzcvs,

  PWobjid fcobj,
  PWosnum os,
  PWboolean reverse,

  PWvector startextvec,
  PWvector stopextvec,
  PWboolean ignoremidcvs,

  double lentol,

  PWboolean *start_extended,
  PWboolean *stop_extended,

  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
)
{
  PWresult PWsts=PW_K_Success;

  PWobjid sfobj=PW_K_NullObjid;
  struct IGRbsp_surface *p_sfgeom=NULL;
  struct PWsfdata sfdata;
  short mattyp=MAIDMX;
  PWmatrix idmx;

  int cv=0, num_uvcv=0, *p_uvcv_props=NULL, *p_xyzcv_type=NULL;
  struct PWcvdata *p_uvcvs=NULL, *p_uvcv=NULL;
  PWvector2d startvec, stopvec;

  struct PWgeomloop *p_uvloops=NULL, *p_uvnode=NULL, *p_xyznode=NULL;

  OnErrorState (!pwIsLpFace (fcobj, os), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  /*
   * Determine whether the loop need to be reversed or not.
   */
  sfobj = pwSfOfLp (fcobj, os);
  OnErrorState (sfobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, pwIdMx (idmx), p_sfgeom);
  OnErrorCode (PWsts, wrapup);
  OnErrorState (!p_sfgeom->planar, PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  OnErrorState (!pwIsLinearMapOkOnPlane (p_sfgeom, lentol), PWsts,
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  /*
   * Map the xyz curves to the UV of the surface.
   */
  p_uvcvs = (struct PWcvdata *) alloca (num_xyzcv * sizeof (struct PWcvdata));
  OnErrorState (!p_uvcvs, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory), 
                wrapup);

  sfdata.datatype = PWsfdata_bspsf;
  sfdata.data.p_bspsf = p_sfgeom;

  for (cv=0; cv<num_xyzcv; cv++)
  {
    /*
     * Map the xyz curve to Uv of surface.
     */
    PWsts = pwMapXyzCvToUvOfSf (&p_xyzcvs[cv], &sfdata, lentol, &num_uvcv,
                                &p_uvcv, &p_uvcv_props, &p_xyzcv_type);
    OnErrorCode (PWsts, wrapup);

    memcpy (&p_uvcvs[cv], p_uvcv, sizeof (struct PWcvdata));
    if (p_uvcv) free (p_uvcv);  p_uvcv=NULL;
    if (p_uvcv_props) free (p_uvcv_props); p_uvcv_props = NULL;
    if (p_xyzcv_type) free (p_xyzcv_type); p_xyzcv_type = NULL;
  }

  /*
   * Map the extension vectors to get the extension vectors at the ends.
   */
  PWsts = get_extvec_in_uv (&p_xyzcvs[0], startextvec, TRUE, p_sfgeom, 
                            lentol, startvec);
  OnErrorCode (PWsts, wrapup);

  PWsts = get_extvec_in_uv (&p_xyzcvs[num_xyzcv-1], stopextvec, FALSE, 
                            p_sfgeom, lentol, stopvec);
  OnErrorCode (PWsts, wrapup);

  /*
   * Trim the curves in UV domain of the surface.
   */
  PWsts = pwCloseUvCompCvWithFaceBounds (num_xyzcv, p_uvcvs, fcobj, os, reverse,
            startvec, stopvec, ignoremidcvs, lentol, start_extended, 
            stop_extended, num_loops, num_edges_loop, &p_uvloops);
  OnErrorCode (PWsts, wrapup);

  /*
   * Remap the uv curves to the xyz curves.
   */
  p_uvnode = p_uvloops;

  while (p_uvnode)
  {
    p_xyznode = pwCreateGeomloop (p_loops);
    OnErrorState (!p_xyznode, PWsts, SetError (PW_K_Pathway, PW_K_Memory),
                  wrapup);

    p_xyznode->p_attrib = p_uvnode->p_attrib;
    p_uvnode->p_attrib = NULL;
    
    /*
     * Map the xyz curve to Uv of surface.
     */
    PWsts = pwMapUvCvToXyzOfSf (&p_uvnode->edge, &sfdata, lentol, 
                                &p_xyznode->edge);
    OnErrorCode (PWsts, wrapup);

    p_uvnode = p_uvnode->p_next;
  }

wrapup : 

  if (p_uvloops) pwFreeGeomloop (p_uvloops);

  PW_Wrapup (PWsts, "pwCloseXyzCompCvWithFaceBounds");
  return PWsts;
}

/* ------------------------ Static Functions Listing ------------------------ */

/*
  ABSTRACT

  NOTES
*/

static PWresult get_extvec_in_uv
(
  struct PWcvdata *p_xyzcv,
  PWvector extvec,
  PWboolean atstart,
  struct IGRbsp_surface *p_sfgeom,
  
  double lentol,

  PWvector2d uv_extvec
)
{
  PWresult PWsts=PW_K_Success;

  int knt=0;
  PWvector loc_extvec;
  struct PWcvpt cvpt;
  struct PWcvdata xyzcvdata, uvcvdata;
  PWpoint2d uvln[2];
  PWpoint  xyzln[2];

  pwGetEndCvptCvdata (p_xyzcv, FALSE, !atstart, &cvpt);
  memcpy (xyzln[0], cvpt.pt, sizeof (PWpoint));

  if (!extvec)
  {
    PWsts = pwGetTangentCvdata (p_xyzcv, &cvpt.cvparam, FALSE, loc_extvec);
    OnErrorCode (PWsts, wrapup);
  }
  else
  {
    memcpy (loc_extvec, extvec, sizeof (PWvector));
  }

  pwNormVec (loc_extvec, loc_extvec);
  if (!extvec && atstart)
    pwRevVec (loc_extvec, loc_extvec);

  for (knt=0; knt<3; knt++)
  {
    xyzln[1][knt] = xyzln[0][knt] + loc_extvec[knt];
  }

  xyzcvdata.datatype = PWcvdata_py;
  xyzcvdata.data.py.num_pts = 2;
  xyzcvdata.data.py.p_pts = xyzln;
  uvcvdata.data.py2d.p_pts = uvln;

  PWsts = pwLinearMapXyzCvToUvOfInfPlane (&xyzcvdata, p_sfgeom, lentol, 
                                          &uvcvdata);
  OnErrorCode (PWsts, wrapup);

  pwMakeVec2d (uvln[0], uvln[1], uv_extvec);
  pwNormVec2d (uv_extvec, uv_extvec);

wrapup :

  PW_Wrapup (PWsts, "get_extvec_in_uv");
  return PWsts;
}

/*
 * Generate the rectangular face.
 */

#include "bssfnormal.h"
#include "bsbx2.h"
#include "bsallocsf.h"
#include "bsplptnorrg.h"

static PWresult generate_new_surface
(
  struct IGRbsp_surface *p_sfgeom,
  PWobjid fcobj,
  PWosnum os
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWrange rngbx;
  long num_poles=0;
  PWvector sfnormal;
  PWboolean inrange=FALSE;

  struct IGRbsp_surface *p_plngeom=NULL;

  fcobj = fcobj;
  os = os;

  /*
   * Get a new planar surface from the poles.
   */


  num_poles = p_sfgeom->u_num_poles * p_sfgeom->v_num_poles;

  BSbx2 (&BSmsg, &num_poles, (IGRpoint *) &p_sfgeom->poles[0], NULL, rngbx[0], 
         rngbx[1]);
  OnErrorState (!BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  BSsfnormal (p_sfgeom, sfnormal, &BSmsg);
  OnErrorState (!BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  BSallocsf ((short) 2, (short) 2, (long) 2, (long) 2, FALSE, 0, &p_plngeom,
             &BSmsg);
  OnErrorState (!BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, PW_K_Memory), 
                wrapup);

  BSplptnorrg (rngbx[0], rngbx[1], &p_sfgeom->poles[0], sfnormal, 1.0, 
               &inrange, p_plngeom, &BSmsg);
  OnErrorState (!BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  /*
   * 
   */

wrapup :

  return PWsts;
}

