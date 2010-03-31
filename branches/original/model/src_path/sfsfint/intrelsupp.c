/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "OMminimum.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "ma.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"


/* Prototypes */
#include "bsdotp.h"
#include "bscrossp.h"
#include "maidmx.h"
#include "bssfeval.h"
#include "bsgeom_cvsf.h"
#include "bssfarrevn.h"
#include "bssfevaln.h"
#include "bsmdistptsf.h"
#include "bssf_copy.h"
#include "bsallocsf.h"
#include "bsfreesf.h"
#include "bschgdeppar.h"
#include "maang2vc.h"
#include "bsvalues.h"
#include "bstrplprod.h"
#include "bssfarrevmc.h"
#include "bsmdistptsf.h"

#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "igrdp.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"

#include "EMSpwapi.h"

#include "PWapi/sfgeom.h"
#include "PWapi/eded.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/edgeom.h"
#include "PWapi/cvgeom.h"
#include "PWapi/mdstptgm.h"

#include "PWapi/ambivec.h"
#include "PWapi/edintpts.h"
#include "PWapi/inttan.h"
#include "PWapi/detrev.h"
#include "PWapi/sortvec.h"
#include "PWapi/partol.h"
#include "PWapi/intobjrels.h"
#include "PWapi/edptproj.h"
#include "PWapi/ptpargm.h"
#include "PWapi/dotp.h"
#include "PWapi/intcvpts.h"
#include "PWapi/changedata.h"

/* Defines */

#define  PLUS      1
#define  MINUS     -1
#define  LTB       1
#define  RTB       2
#define  LTA       3
#define  RTA       4
#define  LTA_ON    -3
#define  RTA_ON    -4

/* Externs */

extern  OMuword   OPP_GRcurve_class_id;

struct  IntInfo
{
   struct IGRbsp_surface  *p_sfgeom;
   PWpoint2d              uvpt;
   PWvector               normvec;
};

#include "PWapi/intrelsupp.h"

/* Static declarations */

static void IncrementAmbi
( 
  int numambi,
  int  *p_ambi_indices
);

static void SwapIntInfo
(
  struct IntInfo  *p_info1,
  struct IntInfo  *p_info2
);

static  void      FillNewListB
(
  int , 
  int , 
  int *, 
  int * 
);

static  PWresult   ArrangeList
( 
  int, 
  int, 
  int * 
);

static  void     SwapVecs
(
  double *, 
  double *
);

static  void    VecCopy
(
  double *, 
  int sign, 
  double * 
);

static  void    SetIntRels
(
  int *, 
  struct EMSintobj * 
);

static void  CorrectAmbiVecs
(
  int *p_numambi,
  int *p_ambi_indices,
  int *p_sort_indices,
  int *p_surevec
);


static  PWresult   GetCurvaturePull
(
  PWvector   dirvec,
  PWvector   tanvec,
  PWvector   cv,
  PWboolean  *p_pull
);

static double  FindActCurv
(
  double    c1,
  double    c2,
  PWvector  dir1,
  PWvector  dir2,
  PWvector  tanvec
);

static PWresult  GetCurvVec
(
  struct IntInfo    *p_intinfo,
  double            curvature,
  PWvector          cvec,
  double            *p_radius
);

static PWresult   SortAmbiguousVecs
(
  int                    numambi,
  int                    *p_ambi_indices,
  PWvector               *vecs,
  struct IntInfo         *p_intinfo,
  PWvector               dirvec,
  double                 xyztol
);

static  PWresult        CompareCurvaturePull
(
  PWvector     dirvec,
  PWvector     tanvec,
  PWvector     cv1,
  PWvector     cv2,
  double       radius1,
  double       radius2,
  double       xyztol,
  PWboolean    *p_cw,
  PWboolean    *p_on
);

static PWresult  GetLtRtSfNorm
(
  struct EMSintobj       *p_intcv,
  double                  u,
  double                  v,
  double                  xyztol,
  PWvector                rtnorm,
  PWvector                ltnorm
);

/*
 *   Application Function : pwComputeIntRels().
 *
 *   Description
 *   -----------
 *   This function actually finds the containment information for the input
 *   intersection data.
 *
 *   Input
 *   -----
 *   struct EMSintobj        *p_intcv      * 
 *                                         * intobj node which is to be
 *                                         *  classified
 *                                         *
 *   double                  xyztol 
 *
 *   Output
 *   ------
 *   'p_intcv->classification' 
 *   and 'p_intcv->other_inobj_node->classification     
 *   field should contain the the
 *   classification.
 */


PWresult       pwComputeIntRels
(
  struct EMSintobj   *p_intcv, 
  double             xyztol
)
{
  long                    rc;
  unsigned int            retval;
  int                     ambi_indices[6], numambi=0, sort_indices[4],
                          i, newlistA[4], newlistB[4];
  struct IGRbsp_surface   *p_this_surf=NULL, *p_other_surf=NULL;
  struct IntInfo          intinfo[4];
  PWobjid                 this_sfobj, other_sfobj, commEdid=PW_K_NullObjid;
  PWosnum                 this_sfos, other_sfos;
  PWpoint2d               sampleptuv;
  PWpoint                 sampleptxyz;
  PWvector                T, TT, vecs[4];
  struct PWcvdata         loc_uvcvdata;
  struct PWcvpt           loc_uvcvpt;
  PWboolean               free_uvcvdata=FALSE, is_reversed=FALSE;
  double                  dotp=0.0;
  unsigned short          mattyp;
  double                  mat[16];
  int                     surevec[2];
  double                  this_uvtol=0.0, other_uvtol=0.0;
  PWboolean               aflag=0;
  struct GRmd_env         rfenv;
  
  /* 
   * Intialize the intersection info 
   */
  for (i=0; i<4; i++)
  {
    intinfo[i].p_sfgeom = NULL;
  }
  if ((p_intcv->props & EMSintobj_uvdegenerate) || 
      (p_intcv->props & EMSintobj_xyzdegenerate) ||
      (p_intcv->other_intobj_node->props & EMSintobj_uvdegenerate) ||
      (p_intcv->other_intobj_node->props & EMSintobj_xyzdegenerate))
  {
    retval = SetSuccess (PW_K_Orientation, PW_K_Degenerate);
    goto wrapup;
  }
  /*
   *  Initialize
   */
  memset (surevec, -1, 2*sizeof(int));
  loc_uvcvdata.datatype = PWcvdata_null;
  loc_uvcvpt.p_attrib = NULL;
  p_intcv->classification = 0;
  p_intcv->other_intobj_node->classification = 0;
  p_intcv->reversed = 0;
  p_intcv->other_intobj_node->reversed = 0;

  this_sfobj = p_intcv->this_obj_node->this_obj.objid;
  this_sfos  = p_intcv->this_obj_node->this_obj.osnum;
  other_sfobj = p_intcv->other_intobj_node->this_obj_node->this_obj.objid;
  other_sfos  = p_intcv->other_intobj_node->this_obj_node->this_obj.osnum;

  /*
   *  Get this and other surface geometry
   */
  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    mattyp = 2;
    MAidmx (&rc, mat);
    OnErrorState (rc != MSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  if (p_intcv->this_obj_node->more_info)
  {
    p_this_surf = (struct IGRbsp_surface*)p_intcv->this_obj_node->more_info;
  }
  else
  {
    retval = PW_GetSfBspsfStack (this_sfobj, this_sfos, mattyp, mat,
                                 p_this_surf);
    OnErrorCode (retval, wrapup);
  }
  if (p_intcv->other_intobj_node->this_obj_node->more_info)
  {
    p_other_surf = (struct IGRbsp_surface*)p_intcv->other_intobj_node->
                                             this_obj_node->more_info;
  }
  else
  {
    retval = PW_GetSfBspsfStack (other_sfobj, other_sfos, mattyp, mat,
                                 p_other_surf);
    OnErrorCode (retval, wrapup);
  }
  /*
   * Get the uvtolerance 
   */
   this_uvtol = pwGetParTolSf (p_this_surf, xyztol);
   other_uvtol = pwGetParTolSf (p_other_surf, xyztol);
  /*
   * Convert the input dataselect structure for this_uvintobj into a 
   * PWcvdata.
   */
  retval = pwChangeEMSCvdata (&p_intcv->this_uvintobj, &loc_uvcvdata, mattyp,
                              mat, &free_uvcvdata);
  OnErrorCode (retval, wrapup);
  /* 
   * Get an internal uv-point on the input intobj and store it in
   * sampleptuv
   */
  retval = pwGetInternalCvPts (&loc_uvcvdata, 1, PWtopopos_middle, &loc_uvcvpt);
  OnErrorCode (retval, wrapup);
  memcpy (sampleptuv, loc_uvcvpt.pt, 2*sizeof (double));

  /*
   * Get the corresponding xyzpoint and store it in sampleptxyz
   */
  BSsfeval (p_this_surf, sampleptuv[U], sampleptuv[V], 0, &sampleptxyz, &rc);
  OnErrorState (rc != BSSUCC, retval, 
                SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  /*
   *  Get the left and right tangents as well as the left and right
   * surface geometry at sampleptxyz for operand A
   */
  retval = pwGetIntPropsAtPt (p_intcv, sampleptxyz, xyztol, TRUE, T, &vecs[2],
                              &intinfo[2]);
  OnErrorCode (retval, wrapup);
  /*
   * Get the left and right tangents as well as left and right surface
   * geometry pointers at sampleptxyz on operand B surface. This is
   * based on oriented normal.
   */
  retval = pwGetIntPropsAtPt (p_intcv->other_intobj_node, sampleptxyz,
                               xyztol, FALSE, TT, &vecs[0], &intinfo[0]);
  OnErrorCode (retval, wrapup);

  /*
   * Check whether the coincident edge of the intersection has a common
   * edge. If common edge is NULL then we have to do some special processing.
   */
  if (p_intcv->coinced != PW_K_NullObjid)
  {
    commEdid = pwGetCommonEd (p_intcv->coinced, this_sfos);
    if (commEdid == PW_K_NullObjid)
    {
      /*
       * Check whether this intersection flows in the same or opposite
       * direction to the coincident edge.
       */
      is_reversed = pwDetIntReversal (p_intcv->coinced, p_intcv, this_uvtol);
      
      /*
       * If intobj is reversed then LTA is the tangent vector on which we
       * cannot apply curvature sorting. ie we have to depend on angle sort
       * only. If angle sort returns ambiguous condition then we will make
       * it on.
       */
      if (is_reversed)
      {
        surevec[0] = RTA;
      }
      else
      {
        surevec[0] = LTA;
      }
    }
  }
  if (p_intcv->other_intobj_node->coinced != PW_K_NullObjid)
  {
    commEdid = pwGetCommonEd (p_intcv->other_intobj_node->coinced, other_sfos);
    if (commEdid == PW_K_NullObjid)
    {
      /*
       * Check whether this intersection flows in the same or opposite
       * direction to the coincident edge.
       */
      is_reversed = pwDetIntReversal (p_intcv->other_intobj_node->coinced, 
                                      p_intcv->other_intobj_node, other_uvtol);

      /*
       * If intobj is reversed then LTA is the tangent vector on which we
       * cannot apply curvature sorting. ie we have to depend on angle sort
       * only. If angle sort returns ambiguous condition then we will make
       * it on.
       */
      if (is_reversed)
      {
        if (p_other_surf->pos_orient)
        {
          surevec[1] = RTB;
        }
        else 
        {
          surevec[1] = LTB;
        }
      }
      else
      {
        if (p_other_surf->pos_orient)
        {
          surevec[1] = LTB;
        }
        else
        {
          surevec[1] = RTB;
        }
      }
    }
  }
    
  /*
   * Check if TIA and TIB are flowing in the same direction. If they flow
   * in the same dirction then we use the same data as output by
   * pwGetIntPropsAtPt. Otherwise we reverse the LTB & RTB information in
   * 'vecs' as well as 'sfpt' list. This is done because our aim is to
   * sort the vectors about intersection flow dirction of oprand A.
   */
  dotp = BSdotp (&rc, T, TT);
  OnErrorState (rc != BSSUCC, retval,
                SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  if (dotp != fabs(dotp))
  {
    SwapVecs (vecs[0], vecs[1]);
    SwapIntInfo(&intinfo[0], &intinfo[1]);
  }
  /* The four vectors obtained above are stored in  array ( PWvector vecs[4] )
   * in the order LTB RTB LTA RTA. Also the four surface pointers
   * are stored in ( IGRbspsurface (*sfpt)[4] ) in the order
   * LTBsf RTBsf LTAsf RTAsf :
   *
   * Sort the four vectors in an anti-clockwise direction about the tangent
   * vector TIA. (angle sort)
   */
  retval = pwSortVec (4, vecs, T, sort_indices);
  OnErrorCode (retval, wrapup);

  if (GetCodeType (retval) == PW_K_Success)
  {
    /* 
     * The output 'sort_indices' is already sorted. So interpret the
     * result and fill the 'p_intobj->classification' field appropriately.
     */
    for (i=0; i<4; i++)
    {
      sort_indices[i] = sort_indices[i]+1;
    }
    SetIntRels (sort_indices, p_intcv);
    memcpy (newlistA, sort_indices, 4*sizeof(int));
  }
  else
  {
    retval =pwGetAmbiguousVecs (4, vecs, T, sort_indices, 
                                &numambi, ambi_indices);
    OnErrorCode (retval, wrapup);
    IncrementAmbi (numambi, ambi_indices);
    for (i=0; i<4; i++)
    {
      sort_indices[i] = sort_indices[i] +1;
    }

    CorrectAmbiVecs (&numambi, ambi_indices, sort_indices, surevec);
    /* 
     * Sort ambiguous vectors using curvature and radius of curvature
     * information.
     */
    retval = SortAmbiguousVecs (numambi, ambi_indices, vecs, 
                                intinfo, T, xyztol);
    OnErrorCode (retval, wrapup);
    /* 
     * Make a new list of sorted vectors with no ambiguity
     */
    pwMergeAmbiguousVecs (numambi, ambi_indices, 4, sort_indices,
                          newlistA);
    /*
     *  Rearrange List
     */
    ArrangeList (LTB, 4, newlistA);
    /* 
     * Interpret the result and fill 'p_intcv->classification' field
     */
    SetIntRels (newlistA, p_intcv);
  }
  /* Compute the rels for the "other" intersection using the 'newlist'
   * output for "this" intobj.
   */
  if (((dotp > 0.0 ) && p_other_surf->pos_orient) ||
       ((dotp < 0.0 ) && !(p_other_surf->pos_orient)))
  {
    FillNewListB (LTA, LTB, newlistA, newlistB);
    FillNewListB (RTA, RTB, newlistA, newlistB);
  }
  else
  {
    FillNewListB (LTA, RTB, newlistA, newlistB);
    FillNewListB (RTA, LTB, newlistA, newlistB);
  }
  if (p_this_surf->pos_orient)
  {
    FillNewListB (LTB, LTA, newlistA, newlistB);
    FillNewListB (RTB, RTA, newlistA, newlistB);
  }
  else
  {
    FillNewListB (LTB, RTA, newlistA, newlistB);
    FillNewListB (RTB, LTA, newlistA, newlistB);
  }
  /*
   * Arrange newlistB to start from LTB
   */
  retval = ArrangeList (LTB, 4, newlistB);
  OnErrorCode (retval, wrapup);
  /* 
   * Interpret the result and fill the "other" intobj classification
   * field.
   */
  SetIntRels (newlistB, p_intcv->other_intobj_node);
  wrapup:

  for (i=0; i<4; i++) 
  {
    if (intinfo[i].p_sfgeom)
    {
      free (intinfo[i].p_sfgeom);
    }
  }
  if (free_uvcvdata)
  {
    switch (loc_uvcvdata.datatype)
    {
      case PWcvdata_py2d:
        free (loc_uvcvdata.data.py2d.p_pts);
        break;
      case PWcvdata_py:
        free (loc_uvcvdata.data.py.p_pts);
        break;
      case PWcvdata_bspcv:
        free (loc_uvcvdata.data.p_bspcv);
        break;
      case PWcvdata_gmbspcv:
        free (loc_uvcvdata.data.p_gmbspcv->bspcv);
        free (loc_uvcvdata.data.p_gmbspcv);
        break;
      default:
        break;
    }/* end of switch */
  }/* if free_uvcvdata */
      

  PW_Wrapup (retval, "Function: pwComputeIntRels ");
  return (retval);
}/* end of function pwComputeIntRels */




/*
 *   Application Function: pwGetIntPropsAtPt().
 *   ------------------------------------------
 * 
 *   Description
 *   -----------
 *   This function is called to get RTA, LTA tangents and surface geometries
 *   given an intersection and the xyz point at which the tangents are to be
 *   constructed. Left & Right tangents and surfaces are decided by looking
 *   at the intersection curve from the volume nomal side or the natural
 *   normal side.
 *
 *   Input
 *   -----
 *   struct EMSintobj    *p_intcv                   *
 *                                                   * Intersection data on
 *                                                   * on the input surface.
 *                                                   *
 *   PWpoint            sampleptxyz                  *
 *                                                   * XYZ point on  input
 *                                                   * surface at which tangents
 *                                                   * are to be constructed.
 *                                                   *
 *   PWboolean         option                       *
 *                                                   * This is set to True
 *                                                   * if user wants to output
 *                                                   * tangent vectors based
 *                                                   * on input surface natural
 *                                                   * normal. It is set to
 *                                                   * FALSE if tangent vectors
 *                                                   * based on oriented normal
 *                                                   * is required.
 *                                                   *
 *   Output
 *   ------
 *   PWvector           T                          * Tangent to the
 *                                                   * intersection curve
 *                                                   * at sampleptxyz
 *                                                   *
 *  double              (* p_vecs)[3]                *
 *                                                   * It will contain output
 *                                                   * tangents LTA,  RTA
 *						     * or LTB, RTB.
 *                                                   *
 *
 *   struct IGRbsp_surface    **p_Sfptr             *
 *                                                   * It will point to the
 *                                                   * LTAsf & RTAsf surface
 *                                                   * geometry.
 *                                                   *
 *
 */

PWresult    pwGetIntPropsAtPt 
(
  struct EMSintobj         *p_intcv, 
  PWpoint                  sampleptxyz,
  double                   xyztol,
  PWboolean                option, 
  PWvector                 T, 
  PWvector                 *vecs,
  struct IntInfo           *p_intinfo 
)
{
  long                         rc;
  unsigned long                retval;
  PWboolean                    REV_CON, REVERSED, aflag=0;
  PWobjid                      sfobj, commEdid, commLpid, commSfid, coincEdid;
  PWosnum                      sfos;
  PWpoint2d                    uvpt1, uvpt2;
  PWpoint                      temp_pt;
  double                       temp_dist=0.0;
  struct IGRbsp_surface        *p_Sfgeom=NULL, *p_commSfgeom=NULL;
  PWvector                     N1, N2, CVEC1, CVEC2;
  struct PWcvpt                projpt, loc_cvpt;
  struct PWid                  loc_edid;
  unsigned short               mattyp;
  double                       mat[16], this_uvtol, other_uvtol;
  struct GRmd_env              rfenv;

  projpt.p_attrib = NULL;
  loc_cvpt.p_attrib = NULL;

  sfobj = p_intcv->this_obj_node->this_obj.objid;
  sfos  = p_intcv->this_obj_node->this_obj.osnum; 
  loc_edid.osnum = p_intcv->this_obj_node->this_obj.osnum;

  /* 
   * Get the surface geometry
   */
  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    mattyp = 2;
    MAidmx (&rc, mat);
    OnErrorState (rc != MSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  retval = PW_GetSfBspsfHeap (sfobj, sfos, mattyp, mat, p_Sfgeom);
  OnErrorCode (retval, wrapup);
  /*
   *  Get uvtol from xyztol for this surface 
   */
  this_uvtol = pwGetParTolSf (p_Sfgeom, xyztol);
  /*
   *  Get 'sampleptuv' from 'sampleptxyz' on the surface 
   */
  BSmdistptsf (&rc, p_Sfgeom, sampleptxyz, &uvpt1[U], &uvpt1[V],
               temp_pt, &temp_dist);
  OnErrorState (rc != BSSUCC, retval,
                SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  /*
   * Check if the intersection runs along a seam edge on this surface.
   * If this is the case then project the uvpt1 obtained above on to the
   * coincident edge to obtain the correct uvpt.
   */
  coincEdid = p_intcv->coinced; 
  if (!(coincEdid == PW_K_NullObjid))
  {
    if (pwIsEdSeam( coincEdid, sfos ))
    {
      loc_edid.objid = coincEdid; 
      retval = pwEdPtProject (&loc_edid, 1, &uvpt1, this_uvtol,
                              &loc_cvpt);
      OnErrorCode (retval, wrapup);
      memcpy (uvpt1, loc_cvpt.pt, 2*sizeof(double));
      if (loc_cvpt.p_attrib)
      {
        pwFreeAttribList (loc_cvpt.p_attrib);
        loc_cvpt.p_attrib = NULL;
      }
    }
  }
  /* 
   * Get tangent to xyz intersection curve at sampleptxyz : T
   */
  retval = pwGetXyzTanAtIntPt (mattyp, mat, &(p_intcv->this_xyzintobj), 
                               sampleptxyz, xyztol, &projpt, T);
  OnErrorCode (retval, wrapup);
  if (coincEdid != PW_K_NullObjid)
  {
    /*
     * Get surface natural normal N1 at sampleptuv
     */
    BSsfarrevn (&rc, p_Sfgeom, 1, &uvpt1[U], 1, &uvpt1[V], temp_pt, N1);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    /*
     *  Find the cross-product T X N1 and call it CVEC1.
     */
    BScrossp (&rc, T, N1, CVEC1);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    REV_CON = pwIsEdRevConn (coincEdid, sfos);
    /*
     *  Get the common edge of 'coincEdid'
     */
    commEdid = pwGetCommonEd (coincEdid, sfos);
    /*
     * If the commEdid is a PW_K_NullObjid then it means that the given
     * object is not a surface and the intersection runs along an edge.
     * in such a case we need to put some default classification.
     */
    if (commEdid != PW_K_NullObjid)
    {
      /* 
       * Get the common edge surface.
       */
      commLpid = pwGetLpOfEd (commEdid, sfos);
      commSfid = pwSfOfLp (commLpid, sfos);
      /*
       * Get common edge surface geometry.
       */
      retval = PW_GetSfBspsfHeap (commSfid, sfos, mattyp, mat, p_commSfgeom);
      OnErrorCode (retval, wrapup);
      /* 
       * Get the uvtol
       */
      other_uvtol = pwGetParTolSf (p_commSfgeom, xyztol);
      /*
       * Check if the other surface is same as this surface. This can
       * happen in case of seam edge.
       */
      if (commSfid == sfobj)
      {
        loc_edid.objid = commEdid;
        retval = pwEdPtProject (&loc_edid, 1, &uvpt1, other_uvtol, &loc_cvpt);
        OnErrorCode (retval, wrapup);
        memcpy (uvpt2, loc_cvpt.pt, 2*sizeof(double));
        if (loc_cvpt.p_attrib)
        {
          pwFreeAttribList (loc_cvpt.p_attrib);
          loc_cvpt.p_attrib = NULL;
        }
      }
      else
      {
        /*
         * Get 'uvpt2' from 'sampleptxyz' on the surface
         */
        BSmdistptsf (&rc, p_commSfgeom, sampleptxyz, &uvpt2[U], 
                     &uvpt2[V], temp_pt, &temp_dist);
        OnErrorState (rc != BSSUCC, retval,
                      SetError (PW_K_BspMath, PW_K_Internal), wrapup);
        /*
         * Project this uvpoint on to the common edge to make sure that
         * the parameters obtained are correct.
         */
        loc_edid.objid = commEdid;
        retval = pwEdPtProject (&loc_edid, 1, &uvpt2, other_uvtol, &loc_cvpt);
        OnErrorCode (retval, wrapup);
        memcpy (uvpt2, loc_cvpt.pt, 2*sizeof(double));
        if (loc_cvpt.p_attrib)
        {
          pwFreeAttribList (loc_cvpt.p_attrib);
          loc_cvpt.p_attrib = NULL;
        } 
      }
      /*
       * Get surface natural normal N2 at sampleptuv
       */
      BSsfarrevn (&rc, p_commSfgeom, 1, &uvpt2[U], 1, &uvpt2[V], temp_pt, N2);
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
      /***
      retval = GetAvgSfNorm (p_commSfgeom, sampleptuv[U], sampleptuv[V], 
                             other_uvtol, temp_pt, N2);
      OnErrorCode (retval, wrapup);
      ****/
      /*
       * Find the cross-product T X N2 where N2 is the natural normal
       * to common edge surface at sampleptxyz. Call it CVEC2.
       */
      BScrossp (&rc, T, N2, CVEC2);
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    } /* end of else if commEdid != PW_K_NullObjid */

    /*
     * Check if intersection curve is reversed with respect to coincEdid
     */
    REVERSED = pwDetIntReversal (coincEdid, p_intcv, this_uvtol);
    if (REVERSED)
    {
      VecCopy (CVEC1, MINUS, vecs[0]);
      p_intinfo[0].p_sfgeom = p_Sfgeom;
      memcpy (p_intinfo[0].uvpt, uvpt1, 2*sizeof(double));
      memcpy (p_intinfo[0].normvec, N1, 3*sizeof(double));

      if (commEdid == PW_K_NullObjid)
      {
        VecCopy (vecs[0], MINUS, vecs[1]);
        /*
         * Get  another copy of 'p_Sfgeom'
         */
        retval=PW_GetSfBspsfHeap (sfobj, sfos, mattyp, mat, 
                                  p_intinfo[1].p_sfgeom);
        OnErrorCode (retval, wrapup);
        memcpy (p_intinfo[1].uvpt, uvpt1, 2*sizeof(double));
        memcpy (p_intinfo[1].normvec, N1, 3*sizeof(double));
      }
      else
      {
        if (REV_CON)
        {
          VecCopy (CVEC2, PLUS, vecs[1]);
          p_intinfo[1].p_sfgeom = p_commSfgeom;
          memcpy (p_intinfo[1].uvpt, uvpt2, 2*sizeof(double));
          memcpy (p_intinfo[1].normvec, N2, 3*sizeof(double));
        }
        else
        {
          VecCopy (CVEC2, MINUS, vecs[1]);
          p_intinfo[1].p_sfgeom = p_commSfgeom;
          memcpy (p_intinfo[1].uvpt, uvpt2, 2*sizeof(double));
          memcpy (p_intinfo[1].normvec, N2, 3*sizeof(double));
        }
      }/* end of if (commEdid != PW_K_NullObjid) */
    }
    else
    {
      VecCopy (CVEC1, PLUS, vecs[1]);
      p_intinfo[1].p_sfgeom = p_Sfgeom;
      memcpy (p_intinfo[1].uvpt, uvpt1, 2*sizeof(double));
      memcpy (p_intinfo[1].normvec, N1, 3*sizeof(double));

      if (commEdid == PW_K_NullObjid)
      {
        VecCopy (vecs[1], MINUS, vecs[0]);
        /*
         * Get  another copy of 'p_Sfgeom'
         */
        retval=PW_GetSfBspsfHeap (sfobj, sfos, mattyp, mat, 
                                  p_intinfo[0].p_sfgeom);
        OnErrorCode (retval, wrapup);
        memcpy (p_intinfo[0].uvpt, uvpt1, 2*sizeof(double));
        memcpy (p_intinfo[0].normvec, N1, 3*sizeof(double));
      }
      else
      {
        if (REV_CON)
        {
          VecCopy (CVEC2, MINUS, vecs[0]);
          p_intinfo[0].p_sfgeom = p_commSfgeom;
          memcpy (p_intinfo[0].uvpt, uvpt2, 2*sizeof(double));
          memcpy (p_intinfo[0].normvec, N2, 3*sizeof(double));
        }
        else
        {
          VecCopy (CVEC2, PLUS, vecs[0]);
          p_intinfo[0].p_sfgeom = p_commSfgeom;
          memcpy (p_intinfo[0].uvpt, uvpt2, 2*sizeof(double));
          memcpy (p_intinfo[0].normvec, N2, 3*sizeof(double));
        }
      }/* end of if (commEdid != PW_K_NullObjid) */
    }
  }/* if not PW_K_NullObjid */
  else
  {
    retval = GetLtRtSfNorm (p_intcv, uvpt1[U], uvpt1[V], xyztol, N1, N2);
    OnErrorCode( retval, wrapup );
    /*
     *  Find the cross-product T X N1 and call it CVEC1.
     */
    BScrossp (&rc, T, N1, CVEC1);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    /*
     *  Find the cross-product T X N2 and call it CVEC2.
     */
    BScrossp (&rc, T, N2, CVEC2);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    VecCopy (CVEC1, PLUS, vecs[1]);
    VecCopy (CVEC2, MINUS, vecs[0]);
    p_intinfo[0].p_sfgeom = p_Sfgeom;
    memcpy (p_intinfo[0].uvpt, uvpt1, 2*sizeof(double));
    memcpy (p_intinfo[0].normvec, N2, 3*sizeof(double));
    /*
     * Get  another copy of 'p_Sfgeom'
     */
    retval=PW_GetSfBspsfHeap (sfobj, sfos, mattyp, mat, p_intinfo[1].p_sfgeom);
    OnErrorCode (retval, wrapup);
    memcpy (p_intinfo[1].uvpt, uvpt1, 2*sizeof(double));
    memcpy (p_intinfo[1].normvec, N1, 3*sizeof(double));
  }
  if (!option)
  {
    if (!(p_Sfgeom->pos_orient))
    {
      SwapVecs (vecs[0], vecs[1]);
      SwapIntInfo (&p_intinfo[0], &p_intinfo[1]);
    }
  }
  wrapup:
  PW_Wrapup (retval, "Function: pwGetIntPropsAtPt ");
  return (retval);
}/* end of function pwGetIntPropsAtPt */



/*
 *   Application Function : FillNewListB().
 *   --------------------------------------
 *
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Output
 *   ------
 *
 */

static  void    FillNewListB
( 
  int vecinx1, 
  int vecinx2, 
  int *newlistA, 
  int *newlistB 
)
{
  int         i;
  PWboolean   on=FALSE;
  
  for (i=0; i<4; i++)
  {
    if (vecinx2 == fabs (newlistA[i]))
    {
      if (vecinx2 != newlistA[i])
      {
        on = TRUE;
      }
      break;
    }
  }
  if (on)
  {
    newlistB[i] = -vecinx1;
  }
  else
  {
    newlistB[i] = vecinx1;
  }
}/* end of function FillNewListB */
   


/*
 *   Application Function : ArrangeList().
 *   -------------------------------------
 *
 *   Description
 *   ------------
 *   Input
 *   -----
 *   Output
 *   ------
 */

static  PWresult    ArrangeList
( 
  int   vec, 
  int   size, 
  int   *list 
)
{
  int i, j;
  unsigned int retval;
  int *temp_list=NULL;
   
  retval = PW_K_Success;

  temp_list = (int *)alloca (size * sizeof(int));
  OnErrorState (!temp_list, retval, 
                SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);
  for (i=0; i<size; i++)
  {
    if (vec == fabs( list[i]))
    {
      break;
    }
  }
  for (j=0; j<size; j++)
  {
    temp_list[j] = list[(i+j)%size];
  }
  for (j=0; j<4; j++)
  {
    list[j] = temp_list[j];
  }
  wrapup:
  PW_Wrapup (retval, " Function : ArrangeList ");
  return (retval);
}/* end of function ArrangeList */


/*
 *   Application Function : SwapVecs().
 *   ----------------------------------
 *
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Output
 *   ------
 *
 */

static  void   SwapVecs
( 
  double *vec1, 
  double *vec2
)
{
  int     i;
  double  temp;

  for (i=0; i<3; i++)
  {
    temp = vec1[i];
    vec1[i] = vec2[i];
    vec2[i] = temp;
  }
}/* end of function SwapVecs */




/*
 *   Application Function: VecCopy().
 *   --------------------------------
 * 
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Output
 *   ------
 */


static  void   VecCopy
( 
  double    *vec1, 
  int       sign, 
  double    *vec2 
)
{
  int i;

  for (i=0; i<3; i++)
  {
    vec2[i] = sign * vec1[i];
  }
}/* end of function VecCopy */




/*
 *   Application Function: SetIntRels
 *   --------------------------------
 *
 *   Description
 *   -----------
 *   This function takes in the sorted list of vector indices array as
 *   input. It first goes through the list to look for any 'ON'
 *   classification. This will be indicated by a negative vector index.
 *   After getting a 'ON' classification the respective orientation is
 *   set. For the non 'ON' cases the list is again traversed from LTB to
 *   RTB. If a vector index appears between LTB and RTB then it is 'IN'
 *   oterwise it is 'OUT'.
 *
 *   Example
 *   -------
 *   Let the sort_indices contain :- LTB | RTA | RTB | LTA
 *                                          |
 *                                          on
 *
 *   After looking for 'ON' it found that Right on, Left ___
 *   After the second traversal we get  Right on, Left out.
 * 
 *   Input
 *   -----
 *   int          *indices                * This contains the sorted vector
 *                                        * indices which are to be classified.
 *                                        *
 *   Output
 *   ------
 *   struct EMSintobj  *p_intcv           * Classification field of this  
 *                                        * intobj will contain the output
 *                                        * information.
 *   Example
 *   -------
 *   For the above example fild bits will be set as follows
 *
 *   0000 0000 0000 0000 0000 0000 0000 1110
 *                                       | |
 *                                       R L
 *
 */


static  void       SetIntRels
( 
  int               *indices, 
  struct EMSintobj  *p_intcv 
)
{
  int   i, rtb_pos=0 ;
 
  for (i=1; i<4; i++)
  {
    if (fabs (indices[i]) == RTB)
    {
      rtb_pos = i;
      continue;
    }
    if (indices[i] < 0)
    {
      if (indices[i] == LTA_ON)
      {
        SetContainIntobj (p_intcv, LEFT, PWcontain_on);
      }
      else if (indices[i] == RTA_ON)
      {
        SetContainIntobj (p_intcv, RIGHT, PWcontain_on);
      }
    }
  }
  for (i=1; i<4; i++)
  {
    if (indices[i] > 0)
    {
      if (i< rtb_pos)
      {
        if (indices[i] == LTA)
        {
          SetContainIntobj (p_intcv, LEFT, PWcontain_in);
        }
        else if (indices[i] == RTA)
        {
          SetContainIntobj (p_intcv, RIGHT, PWcontain_in);
        }
      }
      else if (i>rtb_pos)
      {
        if (indices[i] == LTA)
        {
          SetContainIntobj (p_intcv, LEFT, PWcontain_out);
        }
        else if (indices[i] == RTA)
        {
          SetContainIntobj (p_intcv, RIGHT, PWcontain_out);
        }
      }
    }
  }
}/* end of function SetIntRels */


/*
 *   Application function name : SortAmbiguousVecs().
 *
 *   Destription
 *   -----------
 *   This function is called when the angle sort cannot resolve the ambiguity
 *   between some or all the tangent vectors in the input list. This
 *   happens if the angle between the vectors are within the tolerance angle
 *   value. This function takes as input the number of ambiguous set
 *   in the vector list, number of vectors in each ambiguous set, and the
 *   vector indices in each ambiguous set.
 *
 *   Ambiguity is resolved by first comparing the curvature sign and then
 *   the radius of curvature value. If the sign and the radius of curvatures
 *   are same within tolerance then the vectors are marked as 'ON'.
 *
 *   Inputs required for getting the curvature vector sign and the radius of
 *   curvature at the given point are the surface geometry corresponding to
 *   each tangent vector, sample point at which the curvature is required,
 *   the dirction vector ( tangent to the intersection )
 *
 *   Output will be a list of unambiguous set of vectors.
 *
 *   Input
 *   -----
 *   int        numambi               *
 *                                    * Number of ambiguous set of input
 *                                    * vectors where angle sort failed to
 *                                    * resolve the ambiguity.
 *                                    *
 *
 *   int      *ambi_indices           *
 *                                    * This contains the number of vector
 *                                    * and the vector indices for each
 *                                    * ambiguous set of vectors.
 *                                    *
 *   Example
 *   -------
 *   If there are 2 ambiguous sets each having 2 vectors, first set having
 *   RTA LTB and the second set having LTA and RTB then 'ambi_indices'
 *   contains :
 *   ambi_indices[0] = 2
 *   ambi_indices[1] = RTA
 *   ambi_indices[2] = LTB
 *
 *   ambi_indices[3] = 2
 *   ambi_indices[4] = LTA
 *   ambi_indices[5] = RTB
 *
 *   IGRdouble      (*vecs)[3]         * This contains a set of four tangent
 *                                     * vectors arranged in the order
 *                                     * LTB RTB LTA RTA
 *                                     *
 *
 *   IGRbsp_surface (*sfptr)[4]        * This points to the geometry of
 *                                     * of surfaces to which the tangent
 *                                     * vectors LTB RTB LTA RTA belong
 *                                     *
 *
 *   PWvector       dirvec             * This is the tangent to the intersection
 *                                     * curve at the sample point about
 *                                     * which the sorting is done.
 *                                     *
 *
 *  Ppoint         sample_pt           * xyz point at which curvature vector
 *                                     * is to be determined.
 *                                     *
 *   double        xyztol
 *
 *   Output
 *   ------
 *   int      *ambi_indices            * This will now contain the list
 *                                     * of sorted vector in each ambiguous
 *                                     * set of vector
 *                                     *
 */

static PWresult     SortAmbiguousVecs
(
  int                        numambi, 
  int                        *p_ambi_indices, 
  PWvector                   *vecs,
  struct IntInfo             *p_intinfo, 
  PWvector                   dirvec,
  double                     xyztol
)
{
  int                 i, j, k, *ptr=NULL, num_ambivec=0, 
                      tanvec_num=0, tmp_var=0;
  unsigned long       retval;
  long                rc;
  double              *tanvec, radius[4], c1, c2, curvature, tmpradius=0.0;
  PWvector            cv[4];
  PWpoint             temp_pt;
  PWvector            dir1, dir2;
  PWboolean           cw, on;

  retval = PW_K_Success;

  for (i=0, ptr=p_ambi_indices ; i<numambi; ptr += *ptr + 1, i++)
  {
    /*
     *  Get the number of vectors in the ambiguous sequence
     */
    num_ambivec = *ptr;
    /* 
     * Get the first vector index in this sequence
     */
    tanvec_num = *(ptr+1)-1;
    /*
     * Get the vector by looking at the 'vecs' array
     */
    tanvec = vecs[ *(ptr+1) -1];  /* (check) */
    for (j=1 ; j<=num_ambivec; j++)
    {
      /*  
       * Get the curvature vector ( IGRvector cv[4] ) and the radius of
       * curvature (IGRdouble radius[4] )
       * BSsfarrevmc( Sfptr[ *(ptr + j)], tanvec, sampleptxyz, cv[j-1],
       *            &radius[j-1], &rc );
       */
      if ((p_intinfo[*(ptr+j)-1].p_sfgeom->u_order == 2) &&
          (p_intinfo[*(ptr+j)-1].p_sfgeom->v_order == 2))
      {
        /* 
         * Normal to the surface at the uv point is taken as the 
         * curvature vector and radius of curvature is equal to 
         * MAXDOUBLE
         */
        if (p_intinfo[*(ptr+j)-1].p_sfgeom->pos_orient)
        {
          VecCopy (p_intinfo[*(ptr+j)-1].normvec, PLUS, cv[j-1]);
          /******
          retval = GetAvgSfNorm (Sfptr[*(ptr + j)], sampleptuv[U], 
                                 sampleptuv[V], (double)0.0001,
                                 temp_pt, cv[j-1]);
          OnErrorCode( retval, wrapup );
          *******/
        }
        else
        {
          VecCopy (p_intinfo[*(ptr+j)-1].normvec, MINUS, cv[j-1]);
        }
        radius[j-1] = MAXDOUBLE;
        continue;
      }
      BSsfarrevmc (p_intinfo[*(ptr+j)-1].p_sfgeom, 
                   1, &(p_intinfo[*(ptr+j)-1].uvpt[U]),
                   1, &(p_intinfo[*(ptr+j)-1].uvpt[V]),
                   FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, temp_pt,
                   NULL,  NULL,  &c1, &c2, NULL, dir1, dir2, NULL, &rc);
      OnErrorState (rc != BSSUCC, retval, 
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
      /*
       * Decide which curvature to take. This will be decided by the
       * angle which tanvec makes with dir1 and dir2
       */
      curvature = FindActCurv (c1, c2, dir1, dir2, tanvec);
      /*
       * Construct the curvature vector with this output using the
       * surface normal at the uvpoint
       */
      GetCurvVec (&p_intinfo[*(ptr+j)-1], curvature, cv[j-1], 
                  &radius[j-1]);
    } 
    /*
     * For deciding the ordering between two vectors do
     */
    for (j=1; j<num_ambivec; j++)
    {
      for (k=j+1; k<=num_ambivec; k++)
      {
        retval = CompareCurvaturePull (dirvec, tanvec, cv[j-1], cv[k-1], 
                                       radius[j-1], radius[k-1], 
                                       xyztol, &cw, &on);
        OnErrorCode (retval, wrapup);
        if (on)
        {
          *(ptr + j) = -fabs( *(ptr + j));
          *(ptr + k) = -fabs( *(ptr + k));
        }
        else if (!cw)
        {
          tmp_var = *(ptr+j);
          *(ptr+j) = *(ptr+k);
          *(ptr+k) = tmp_var;
          SwapVecs (cv[j-1], cv[k-1]);
          tmpradius = radius[j-1];
          radius[j-1]= radius[k-1];
          radius[k-1]= tmpradius;
        }
      }/* end of for k */
    }/* end of for j */
  }/* for i (loop over num_ambi_indices) */
  wrapup:
  PW_Wrapup (retval, "Function: pwSortAmbiguousVecs ");
  return (retval);
}/* end of function pwSortAmbiguousVecs */

    
/*  Application function: CompareCurvaturePull()
 *  ----------------------------------------------
 *
 *  Description
 *  -----------
 *
 *
 *
 *  Input
 *  -----
 *  IGRvector         dirvec                         * Intersection direction
 *                                                    *
 *  IGRvector         tanvec                         * Tangent direction
 *                                                    * (common tangent)
 *                                                    *
 *  IGRvector         cv1                            * Curvature vector for
 *                    cv2                             * input operands
 *                                                    *
 *  double            radius1                        * Radius of curvature
 *                    radius2                         * for input oprands
 *                                                    *
 *  double            xyztol
 *  Output
 *  ------
 *  Pboolean          *p_cw                           * It is positive if
 *                                                     * the first vector in
 *                                                     * the input list comes
 *                                                     * before the second
 *                                                     * vector in anti
 *                                                     * clockwise ordering. ie
 *                                                     * first vector is more
 *                                                     * clockwise.
 *                                                     *
 *   PWboolean        *p_on                            *
 *						       * it is set to 1
 *						       * if the input pair of
 *						       * vectors are on.
 */

static  PWresult        CompareCurvaturePull
( 
  PWvector     dirvec, 
  PWvector     tanvec, 
  PWvector     cv1,
  PWvector     cv2, 
  double       radius1, 
  double       radius2,
  double       xyztol,
  PWboolean    *p_cw, 
  PWboolean    *p_on 
)
{
  unsigned int       retval;
  PWboolean          pull1, pull2;

  retval = PW_K_Success;
  *p_on = FALSE;

  /*
   * Get curvature pull for vector1. Clockwise pull is '+'(1)ve anticlockwise
   * pull is '-'( output is 0)ve.
   */
  retval = GetCurvaturePull (dirvec, tanvec, cv1, &pull1);
  OnErrorCode (retval, wrapup);
  /*
   * Get curvature pull for vector2
   */
  retval = GetCurvaturePull (dirvec, tanvec, cv2, &pull2);
  OnErrorCode (retval, wrapup);
  if (pull1 != pull2)
  {
    if (pull1) 
    {
      *p_cw = TRUE;
    }
    else
    {
      *p_cw = FALSE;
    }
    if (radius1==MAXDOUBLE && radius2==MAXDOUBLE)
    {
      *p_on = TRUE;
    }
  }
  else if (!pull1)
  {
    if (fabs (radius1) > fabs (radius2) + xyztol) /* (check) what is tol val?*/
    {
      *p_cw = TRUE;
    }
    else if (fabs (radius1) < fabs (radius2) -xyztol)
    {
      *p_cw = FALSE;
    }
    else
    {
      *p_on = TRUE;
    }
  }
  else
  {
    if (fabs (radius1) < fabs (radius2) - xyztol) /* (check) tol value */
    {
      *p_cw = TRUE;
    }
    else if (fabs (radius1) > fabs (radius2) + xyztol)
    {
      *p_cw = FALSE;
    }
    else
    {
      *p_on = TRUE;
    }
  }
  wrapup:
  return (retval);
}/* End of function CompareCurvaturePull */


/*
 *   Application function: GetCurvaturePull().
 *   -----------------------------------------
 *
 *   Description
 *   -----------
 *
 *
 *   Input
 *   -----
 *   IGRvector     dirvec                        * Intersection direction
 *                                                *
 *
 *   IGRvector     tanvec                        * Tangent direction (common
 *                                                * tangent ).
 *                                                *
 *
 *   IGRvector     cv                            * Curvature vector
 *                                                *
 *   Output
 *   ------
 *   IGRboolean    *p_pull                       *  It will be '+'ve for
 *                                                * clockwise pull and '-'ve
 *                                                * for anti-clockwise pull
 *                                                *
 */

static  PWresult   GetCurvaturePull
( 
  PWvector   dirvec, 
  PWvector   tanvec, 
  PWvector   cv,
  PWboolean  *p_pull 
)
{
  unsigned int    retval;
  long            rc;
  double          product;

  retval = PW_K_Success;

  BStrplprod (&rc, dirvec, cv, tanvec, &product);
  OnErrorState (rc != BSSUCC, retval, 
                SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  /* 
   * Get the sign of the curvature vector by doing a triple product 
   * between the 'dirvec', 'cv' and 'tanvec'. Store the sign value (+1 or
   * -1) in 'p_pull'. '*p_pull' is zero for negative pull.
   */
  *p_pull = product > 0 ? 1 : 0;
  wrapup:
  PW_Wrapup (retval, "Function : GetCurvaturePull ");
  return (retval);
}/* end of function GetCurvaturePull */


static double  FindActCurv
( 
  double    c1, 
  double    c2, 
  PWvector  dir1, 
  PWvector  dir2, 
  PWvector  tanvec 
)
{
  long       rc;
  double     curvature, angle1[3], angle2[3];
  PWboolean  val;

  /*
   * Get the angle between tanvec and dir1
   */
  val = MAang2vc (&rc, tanvec, dir1, angle1);
  if (angle1[0] > M_PI)
  {
    angle1[0] = 2*M_PI -angle1[0];
  }
  if (angle1[0] > M_PI/2.0)
  {
    angle1[0] = M_PI - angle1[0];
  }
  val = MAang2vc (&rc, tanvec, dir2, angle2);
  if (angle2[0]  > M_PI)
  {
    angle2[0] = 2*M_PI -angle2[0];
  }
  if (angle2[0] > M_PI/2.0)
  {
    angle2[0] = M_PI - angle2[0];
  }

  if (angle1[0] < angle2[0])
  {
    curvature = c1;  
  }
  else 
  {
    curvature = c2;
  }
  return (curvature);
}/* end of function FindActCurv */




static PWresult  GetCurvVec
( 
  struct IntInfo    *p_intinfo, 
  double            curvature, 
  PWvector          cvec,
  double            *p_radius 
)
{  
  int              i;
  unsigned int     retval;
  long             rc;
  double           chktol;
   
  retval = PW_K_Success;

  for (i=0; i<3; i++)
  {
    cvec[i] = curvature*p_intinfo->normvec[i];
  }

  /*
   * For cases where the curvature value is very less if we not set the
   * radius of curvature value equal to MAXDOUBLE it causes problem in
   * the detection of ON cases. The tolerance used to detect that the
   * curvature value is near zero is the active zero-length tolerance.
   */
  BSEXTRACTPAR (&rc, BSTOLLENVEC, chktol);
  if ( fabs (curvature) > chktol )
  {
    *p_radius = 1.0/fabs(curvature); 
  }
  else
  {
    *p_radius = MAXDOUBLE;
  }
  return (retval);
}/* end of function GetCurvVec */


/*
 *   Application Function: GetLtRtSfNorm().
 *   -------------------------------------
 *   Description
 *   -----------
 *   Input
 *   -----
 *   Ouptput
 *   -------
 */

static PWresult  GetLtRtSfNorm
(
  struct EMSintobj       *p_intcv,
  double                  u,
  double                  v,
  double                  xyztol,
  PWvector                rtnorm,
  PWvector                ltnorm
)
{
   unsigned long             retval;
   int                       i, numnorms;
   long                      rc;
   double                    basis_tol, dist_loc=0;
   PWpoint                   loc_pt,loc_pt1, tmp_minpt;
   PWvector                  inttangent;
   PWboolean                 bssts, u_param_match=FALSE, v_param_match=FALSE;
   struct PWcvdata           intdata;
   struct PWcvparam          intparam;
   PWobjid                   sfobj;
   PWosnum                   sfos;
   unsigned short            mattyp;
   double                    mat[16], dot_udir, dot_vdir;
   double                    uvtol, knot_tol,  u_dir[2], v_dir[2];
   struct IGRbsp_surface     *p_sfgeom=NULL;
   PWboolean                 free_intdata=FALSE, aflag=0;
   struct GRmd_env           rfenv;

   retval = PW_K_Success;
   loc_pt[0] = u;
   loc_pt[1] = v;
   loc_pt[2] = 0.0;
   loc_pt1[0] = u;
   loc_pt1[1] = v;
   loc_pt1[2] = 0;
   sfobj = p_intcv->this_obj_node->this_obj.objid;
   sfos  = p_intcv->this_obj_node->this_obj.osnum;

   inttangent[0]=0.0; inttangent[1]=0.0; inttangent[2]=0.0;

   /*
    * Get the surface geometry
    */
   if(aflag = pwIsActivationOn())
   {
     pwGetActiveModuleEnv(&rfenv);
     memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
     mattyp = rfenv.md_env.matrix_type;
   }
   else
   {
     mattyp = 2;
     MAidmx( &rc, mat );
     OnErrorState( rc != MSSUCC, retval,
                   SetError( PW_K_BspMath, PW_K_Internal), wrapup);
   }

   if( p_intcv->this_obj_node->more_info )
      p_sfgeom = (struct IGRbsp_surface*)p_intcv->this_obj_node->more_info;
   else
   {
      retval = PW_GetSfBspsfStack (sfobj, sfos, mattyp, mat, p_sfgeom );
      OnErrorCode( retval, wrapup );
   }

   /*
    * Get the uvtol from xyz tol for this surface
    */
   uvtol = pwGetParTolSf( p_sfgeom, xyztol );
   
   bssts = BSEXTRACTPAR( &rc, BSTOLBASIS, basis_tol );
   OnErrorState( !bssts, retval,
                      SetError( PW_K_BspMath, PW_K_Internal), wrapup);

   BSchgdeppar( uvtol, &rc );
   OnErrorState( rc != BSSUCC, retval,
                      SetError( PW_K_BspMath, PW_K_Internal), wrapup);

   /*
    * Get the knot tolerance for the input surface.
    */
   BSsfkttol2( p_sfgeom->u_order, p_sfgeom->v_order, p_sfgeom->u_knots,
               p_sfgeom->v_knots, p_sfgeom->u_num_poles, p_sfgeom->v_num_poles,
               p_sfgeom->poles, p_sfgeom->weights, &knot_tol, &rc );
   OnErrorState( rc != BSSUCC, retval,
                      SetError( PW_K_BspMath, PW_K_Internal), wrapup);

   BSchgdeppar( basis_tol, &rc );
   OnErrorState( rc != BSSUCC, retval,
                    SetError( PW_K_Pathway, PW_K_Internal), wrapup);

   /*
    * Check whether the input u, v value is equal to any of the knot values
    * in u and v direction within knot_tol. If found to be equal then 
    * the corresponding value is made equal to the knot value and the surface
    * normal is evaluated at the corresponding point.
    */

   for( i= p_sfgeom->u_order; i <= p_sfgeom->u_num_poles; i++)
   {
      if( (( p_sfgeom->u_knots[i] - knot_tol ) <= u ) &&
          (( p_sfgeom->u_knots[i] + knot_tol ) >= u ) )
      {
         loc_pt[0] = p_sfgeom->u_knots[i];
         u_param_match = TRUE;
      }
   }

   for( i= p_sfgeom->v_order; i <= p_sfgeom->v_num_poles; i++)
   {
      if( (( p_sfgeom->v_knots[i] - knot_tol ) <= v ) &&
          (( p_sfgeom->v_knots[i] + knot_tol ) >= v ) )
      {
         loc_pt[1]  = p_sfgeom->v_knots[i];
         v_param_match = TRUE;
      }
   }

   /*
    *  Find the flow direction of the input intersection in the uv space
    *  to determine the correct left and right tangent
    *  a) Get the intersection  geometry
    *  b) Find the parameter corresponding to the input point.
    *  c) Get the tangent to the intersection at the given point.
    */
   retval = pwChangeEMSCvdata (&p_intcv->this_uvintobj, &intdata, mattyp, 
                               mat, &free_intdata);
   OnErrorCode( retval, wrapup );

   dist_loc = pwMinDistSqPtCvdata (loc_pt1, &intdata, tmp_minpt, &intparam);
   /******
   retval = pwParAtPtCvdata( &intdata, loc_pt1, uvtol, tmp_minpt, &intparam );
   OnErrorCode( retval, wrapup );
   ******/
   retval = pwGetTangentCvdata (&intdata, &intparam, FALSE, 
                                (double*)inttangent);
   OnErrorCode (retval, wrapup); 

   /*
    * Construct uv tangent along the positive 'u' and positive 'v' direction
    */
   u_dir[0] = 1.0; 
   u_dir[1] = 0.0;
   v_dir[0] = 0.0;
   v_dir[1] = 1.0;

   /*
    *  Now do a dotproduct between the above three tangents to determine
    *  the flow of the Natural intersection
    */
   dot_udir = pwDot2d (u_dir, inttangent);
   dot_vdir = pwDot2d (v_dir, inttangent);

   /*
    * Depending upon the dot product sign select the appropriate left and
    * right surface normal.
    */

   if( (dot_udir > 0.0) && (dot_vdir >= 0.0) )
   {
      /*
       * Get the ( uright, vleft ) tangent as the right tangent and 
       * ( uleft, vright) tangent as the left tangent.
       */
      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 2, &numnorms, 
                 tmp_minpt, (double (*)[3])rtnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 3, &numnorms, tmp_minpt, 
                 (double (*)[3])ltnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
   }   
   else if ((dot_udir <= 0.0) && (dot_vdir > 0.0))
   {
      /*
       * Get the (uright, vright) tangent as the right tangent and 
       * (uleft, vleft) tangent as the left tangent.
       */
      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 4, &numnorms,
                 tmp_minpt, (double (*)[3])rtnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);  

      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 1, &numnorms, tmp_minpt,
                 (double (*)[3])ltnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
   }
   else if ((dot_udir >= 0.0) && (dot_vdir < 0.0))
   {
      /*
       * Get the (uleft, vleft) tangent as the right tangent and
       * (uright, vright) tangent as the left tangent.
       */
      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 1, &numnorms,
                 tmp_minpt, (double (*)[3])rtnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 4, &numnorms, tmp_minpt,
                 (double (*)[3])ltnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
   }
   else if ((dot_udir < 0.0) && (dot_vdir <= 0.0))
   {
      /*
       * Get the (uleft, vright) tangent as the right tangent and
       * (uright, vleft) tangent as the left tangent.
       */
      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 3, &numnorms,
                 tmp_minpt, (double (*)[3])rtnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      BSsfevaln (p_sfgeom, loc_pt[0], loc_pt[1], 2, &numnorms, tmp_minpt,
                 (double (*)[3])ltnorm, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
   }

   
   wrapup:
   return (retval);
} /* end of function GetLtRtSfNorm  */



static void SwapIntInfo
(
   struct IntInfo  *p_info1,
   struct IntInfo  *p_info2
)
{
  struct IGRbsp_surface  *tmp_sfptr=NULL;
  PWvector               tmpvec;
  PWpoint2d              tmpuvpt;

  memcpy (tmpuvpt, p_info1->uvpt, 2*sizeof(double));
  memcpy (p_info1->uvpt, p_info2->uvpt, 2*sizeof(double));
  memcpy (p_info2->uvpt, tmpuvpt, 2*sizeof(double));

  memcpy (tmpvec, p_info1->normvec, 3*sizeof(double));
  memcpy (p_info1->normvec, p_info2->normvec, 3*sizeof(double));
  memcpy (p_info2->normvec, tmpvec, 3*sizeof(double));

  tmp_sfptr = p_info1->p_sfgeom;
  p_info1->p_sfgeom = p_info2->p_sfgeom;
  p_info2->p_sfgeom = tmp_sfptr;
 
}/* end of function SwapIntInfo */


static void IncrementAmbi
(
  int numambi, 
  int  *p_ambi_indices
)
{
  int  *ptr, i, j, num_ambivec;

  for (i=0, ptr=p_ambi_indices ; i<numambi; ptr += *ptr + 1, i++)
  {
    /*
     * Get the number of vectors in the ambiguous sequence
     */
    num_ambivec = *ptr;
    for (j=1 ; j<=num_ambivec; j++)
    {
      *(ptr+j) = *(ptr+j) +1;
    }
  }
}/* end of function IncrementAmbi */


static void  CorrectAmbiVecs
(
  int *p_numambi,
  int *p_ambi_indices,
  int *p_sort_indices,
  int *p_surevec
)
{
  int  gvec[6];
  int  *grpvec;
  int  *ptr=NULL;
  int  i, j, k, l, m=0;
  int  loc_numambi=0;
  int  num_ambivec=0;

  memset (gvec, 0, 6*sizeof(int));
  grpvec = gvec;
  loc_numambi = *p_numambi;

  for (i=0, ptr=p_ambi_indices; i<*p_numambi; ptr += *ptr+1 ,m++,i++)
  {
    num_ambivec = *ptr;
    for (j=1; j<=num_ambivec; j++)
    {
      if ((*(ptr+j) != p_surevec[0]) && (*(ptr+j) != p_surevec[1]))
      {
        (*grpvec)++;
         *(grpvec + (*grpvec))= *(ptr+j);
      }
      else 
      {
        /* Got a match */
        for (k=0; k<4; k++)
        {
          for (l=1; l<=num_ambivec; l++)
          {
            if (p_sort_indices[k] == *(ptr+l))
            {
              p_sort_indices[k] = -p_sort_indices[k];
            }
          }
        }
        if (((num_ambivec -j) + *grpvec) <=1)
        {
          *grpvec=0;
        }
      }
    }
    if (*grpvec<2)
    {
      loc_numambi--;
      *grpvec=0;
    }
    else
    {
      if (m<1)
      {
        grpvec += *grpvec +1;
        *grpvec=0;
      }
    }
  }
  for (i=0; i<6; i++)
  {
    p_ambi_indices[i] = gvec[i];
  }
  *p_numambi = loc_numambi;
}
  
