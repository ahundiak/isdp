#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>
#include <malloc.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfptseval.h"
#include "bsptlnplan.h"
#include "bsconstprcv.h"
#include "bspartofcv.h"
#include "bsunwght_p.h"
#include "bsrev_cv.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsgeom_cvsf.h"
#include "PWaligngm.h"
#include "PWapi/edgeom.h"
#include "PWapi/edprops.h"
#include "PWapi/sfgeom.h"
#include "PWapi/lped.h"
#include "PWapi/sflp.h"

#include "PWapi/partol.h"
#include "PWapi/degengm.h"
#include "PWapi/isopts.h"
#include "PWapi/mapcvonpln.h"
#include "PWapi/edcons.h"

#define   CONSTANT_U  1
#define   CONSTANT_V  2

/*
 * BS-code for non-planar set of points after the call to
 * BSptlnplan().
 */

#define NON_PLANAR 4

static PWresult GetIsoCvGeomXyz
(
   struct PWcvdata 	  *p_uvcv,
   struct IGRbsp_surface  *p_sfgeom,
   int                    isodir,
   double                 xyztol,
   struct PWcvdata        *p_xyzcv
);

static  PWresult  GetNatCvGeomXyz
(
   struct PWcvdata            *p_uvcv,
   int                        location,
   PWboolean                  is_degen,
   double                     xyztol,
   struct IGRbsp_surface      *p_sfgeom,
   struct PWcvdata            *p_xyzcv
);


PWresult pwMapUvCvToXyzOfSfOld
(
  struct PWcvdata   *p_uvcv,
  struct PWsfdata   *p_sfdata,
  double            xyztol,
  struct PWcvdata   *p_xyzcv
)
{  
  unsigned long           retval;
  struct IGRbsp_surface   *p_sfgeom=NULL;
  struct IGRbsp_curve     *p_bspcv=NULL;
  enum PWcvdatatype       edgeomtyp;
  int                     size;
  PWboolean               is_degen=FALSE;
  long                    rc;
  double                   uvtol=0;
  int                     natloc=0;
  int                     is_iso=0, isodir=0;
  PWboolean               is_natural=FALSE;

  retval = PW_K_Success;
   
  /*
   * Get the surface geometry of the incoming curve.
   */

  if (p_sfdata->datatype == PWsfdata_plane)
      OnErrorState (TRUE, retval, SetError(PW_K_Pathway, PW_K_InvalidArg),
                    wrapup);

  p_sfgeom = p_sfdata->datatype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf :
                                           p_sfdata->data.p_gmbspsf->bspsf;

  uvtol = pwGetParTolSf (p_sfgeom, xyztol);
  /*
   *  Get the edge geometry type
   */
  edgeomtyp = p_uvcv->datatype; 

  if (edgeomtyp == PWcvdata_py2d &&
      pwIsDegenPy2d (p_uvcv->data.py2d.num_pts, p_uvcv->data.py2d.p_pts,
                     uvtol))
  {
    is_degen = TRUE;
  }

  switch( edgeomtyp )
  {
    case PWcvdata_bspcv:
      /*
       *  make sure that the surface satisfies the linear mapping
       *  criterion. If not something is messed up.
       */
      if (!pwIsLinearMapOkOnPlane (p_sfgeom, uvtol))
      {
        retval = SetError( PW_K_Pathway, PW_K_InvalidArg);
        goto wrapup;
      }
      PW_ALIGN_CVSIZE (p_uvcv->data.p_bspcv->num_poles, 
                       p_uvcv->data.p_bspcv->order, 
                       p_uvcv->data.p_bspcv->rational, 0, size);
      p_bspcv = (struct IGRbsp_curve *) malloc (size);
      PW_ALIGN_CVGEOM (p_uvcv->data.p_bspcv->num_poles,
                       p_uvcv->data.p_bspcv->order, 
                       p_uvcv->data.p_bspcv->rational, 0, p_bspcv);
      /*
       * Set the output structure
       */
      p_xyzcv->datatype = PWcvdata_bspcv;
      p_xyzcv->data.p_bspcv = p_bspcv;

      retval = pwLinearMapUvCvToXyzOfPlane (p_uvcv, p_sfgeom, xyztol,
                                            p_xyzcv);
      OnErrorCode (retval, wrapup);

      /**
      BScv_copy (&rc, p_uvcv->data.p_bspcv, p_bspcv);
      **/
      break;

    case  PWcvdata_py2d:
      /*
       *  If this is an iso-curve, get the geometry through the special
       *  processing
       */
      is_iso = pwIsUvPtsIso (p_uvcv->data.py2d.num_pts, 
                             p_uvcv->data.py2d.p_pts, uvtol, &isodir);

      if (is_iso && p_uvcv->data.py2d.num_pts == 2)
      {
        PWboolean natrev;

        is_natural = pwGetNatLocation (p_uvcv->data.py2d.p_pts, 0.0, 1.0, 
                                       0.0, 1.0, &natloc, &natrev);
        if (is_natural)
          is_iso = FALSE;
      }

      if (is_iso)
      {
        retval = GetIsoCvGeomXyz (p_uvcv, p_sfgeom, isodir, xyztol, p_xyzcv);
        goto wrapup;
      }
      /*
       * If this is a natural edge get the geometry through special
       * processing.
       */
      if (is_natural) 
      {
        retval = GetNatCvGeomXyz (p_uvcv, natloc, is_degen, xyztol,
                                  p_sfgeom, p_xyzcv );
        goto wrapup;
      }
      /*
       *  Convert these points from parametric space to model space poles.
       */
      if (is_degen)
      {
        p_xyzcv->datatype = PWcvdata_py;
        p_xyzcv->data.py.num_pts = 1;
        p_xyzcv->data.py.p_pts = (PWpoint *)malloc (p_uvcv->data.py2d.num_pts *
                                                    sizeof (PWpoint));
      }
      else
      {
        p_xyzcv->datatype = PWcvdata_py;
        p_xyzcv->data.py.num_pts = p_uvcv->data.py2d.num_pts;
        p_xyzcv->data.py.p_pts = (PWpoint *)malloc (p_uvcv->data.py2d.num_pts *
                                                    sizeof (PWpoint));
      }

      BSsfptseval (p_sfgeom, p_xyzcv->data.py2d.num_pts, 
                   (double *)p_uvcv->data.py2d.p_pts, 
                   (double *)p_xyzcv->data.py.p_pts, &rc);
      OnErrorState (rc !=BSSUCC, retval,
                    SetError( PW_K_BspMath, PW_K_Internal), wrapup );
      break;
    default:
      break;
  }
  wrapup:
  return retval;
}/* end of function  pwGetEdbcXyzGeom */


static PWresult GetIsoCvGeomXyz
( 
  struct  PWcvdata        *p_uvcv,
  struct  IGRbsp_surface  *p_sfgeom, 
  int                     isodir,
  double                  xyztol,
  struct  PWcvdata        *p_xyzcv 
)
{
  unsigned long              retval;
  struct IGRbsp_curve        *p_iso_crv=NULL;
  PWboolean                  status, tst_planar;
  struct IGRbsp_curve        *p_bspcv=NULL;
  PWboolean                  reverse;
  double                     iso_par, beg_par, mid_par, end_par, temp_par;
  double                     uvtol=0.0;
  PWboolean                  whole_iso;
  short                      option, num_poles, order;
  long                       rc;
  int                        size, num_pts=0;

  /* 
   * Initialize 
   */
  retval = PW_K_Success;
  
  reverse = FALSE;
  uvtol = pwGetParTolSf (p_sfgeom, xyztol);
  num_pts = p_uvcv->data.py2d.num_pts;

  if (isodir == U)
  {
    option = CONSTANT_U;
    iso_par = (p_uvcv->data.py2d.p_pts[0][0] +
               p_uvcv->data.py2d.p_pts[1][0])/2.0;
    beg_par = p_uvcv->data.py2d.p_pts[0][1];
    end_par = p_uvcv->data.py2d.p_pts[num_pts - 1][1];
  }
  else
  {
    option = CONSTANT_V;
    iso_par = (p_uvcv->data.py2d.p_pts[0][1] +
               p_uvcv->data.py2d.p_pts[1][1])/2.0;
    beg_par = p_uvcv->data.py2d.p_pts[0][0];
    end_par = p_uvcv->data.py2d.p_pts[num_pts - 1][0]; 
  }

  if (beg_par > end_par)
  {
    temp_par = beg_par;
    beg_par = end_par;
    end_par = temp_par;
    reverse = TRUE;
  }

  if (beg_par != 0.0 || end_par != 1.0)
  {
    whole_iso = FALSE;
  }
  else
  {
    whole_iso = TRUE;
  }
  
  if (option == CONSTANT_U)
  {
    num_poles = p_sfgeom->v_num_poles;
    order = p_sfgeom->v_order;
  }
  else
  {
    num_poles = p_sfgeom->u_num_poles;
    order = p_sfgeom->u_order;
  }

  PW_ALIGN_CVSIZE (num_poles, order, (p_sfgeom->rational), 0, size);
  p_iso_crv = (struct IGRbsp_curve *) malloc (size);
  OnErrorState (!(p_iso_crv),retval,
                SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

  PW_ALIGN_CVGEOM (num_poles, order, (p_sfgeom->rational), 0, p_iso_crv);

  if (whole_iso)
  {
    p_bspcv = p_iso_crv;
  }

  /*
   * extract b_spline curve from the surface
   */
  tst_planar = TRUE;
  status = BSconstprcv (&rc, p_sfgeom, &option, &iso_par, &tst_planar,
                        p_iso_crv);
  OnErrorState (rc !=BSSUCC, retval,
                SetError( PW_K_BspMath, PW_K_Internal), wrapup);

  /*
   * extract part of the iso curve if required.
   */
  if (!whole_iso)
  {
     if (p_iso_crv->phy_closed)
     {
       mid_par = (beg_par + end_par)/2.0;
     }
     else 
     {
       mid_par = 0.0;
     }

     num_poles = num_poles + 2*order - 1;

     if (!p_bspcv)
     {
       PW_ALIGN_CVSIZE (num_poles, order, (p_sfgeom->rational), 0, size);
       p_bspcv = (struct IGRbsp_curve *) malloc (size);
       OnErrorState (!p_bspcv, retval,
                     SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
     }

     PW_ALIGN_CVGEOM (num_poles, order, (p_sfgeom->rational), 0, p_bspcv);

     status = BSpartofcv (&rc, p_iso_crv, beg_par, mid_par, end_par,
                          p_bspcv);
     OnErrorState (rc !=BSSUCC, retval, SetError( PW_K_BspMath, PW_K_Internal),
                   wrapup );

   }/* if (!whole_iso) */

   if (p_bspcv->rational && p_bspcv->order == 2)
   {
     /*
      * Some of the methods in the IGE-system do not take kindly
      * to having an order-2 curve which is rational. So change the
      * curve to non-rational.
      */
     BSunwght_p (&rc, p_bspcv->poles, p_bspcv->weights, 
                 &p_bspcv->num_poles, p_bspcv->poles);
     OnErrorState (rc !=BSSUCC, retval,
                   SetError( PW_K_BspMath, PW_K_Internal), wrapup );
     p_bspcv->rational = FALSE;
   }

   if (reverse)
   {
     status = BSrev_cv (&rc, p_bspcv);
     OnErrorState (rc !=BSSUCC, retval,
                   SetError( PW_K_BspMath, PW_K_Internal), wrapup);
   }

   if (pwIsDegenCvdata (p_uvcv, uvtol))
   {
     if (p_bspcv->rational)
     {
       BSunwght_p (&rc, p_bspcv->poles, p_bspcv->weights, 
                   &p_bspcv->num_poles, p_bspcv->poles);
       OnErrorState (rc !=BSSUCC, retval,
                     SetError( PW_K_BspMath, PW_K_Internal), wrapup);
     }
     p_bspcv->periodic = FALSE;
     p_bspcv->non_uniform = FALSE;
     p_bspcv->order = 2;
     p_bspcv->num_poles = 2;
     p_bspcv->num_knots = 4;
     p_bspcv->knots[0] = p_bspcv->knots[1] = 0.0;
     p_bspcv->knots[2] = p_bspcv->knots[3] = 1.0;
     p_bspcv->rational = FALSE;
     p_bspcv->planar = TRUE;
     p_bspcv->phy_closed = TRUE;

     retval = SetInfo (PW_K_Pathway, PW_K_Degenerate);
   }

   /*
    * Fill the output structure with the geometry obtained above
    */
   if (!(p_bspcv->rational) && (p_bspcv->order==2))
   {
     /*
      * We need to send the output as a polyline
      */
     p_xyzcv->datatype = PWcvdata_py;
     p_xyzcv->data.py.num_pts = p_bspcv->num_poles;
     p_xyzcv->data.py.p_pts=NULL;
     p_xyzcv->data.py.p_pts = (PWpoint *)malloc (p_bspcv->num_poles *
                                                 sizeof (PWpoint));
     OnErrorState (!(p_xyzcv),retval,
                   SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

     memcpy (p_xyzcv->data.py.p_pts, p_bspcv->poles, p_bspcv->num_poles *
             sizeof (PWpoint));
     free (p_bspcv); 
     p_bspcv=NULL;
   } 
   else
   {
     p_xyzcv->datatype = PWcvdata_bspcv;
     p_xyzcv->data.p_bspcv = p_bspcv;
     p_bspcv = NULL;
   }
     
wrapup:
   
   if (!whole_iso)
   {
     if(p_iso_crv)
     {
       free(p_iso_crv); 
       p_iso_crv=NULL;
     }
   }

   PW_Wrapup( retval, "Function: GetIsoEdGeomXyz ");
   return retval;

}/* end of function GetIsoEdGeomXyz */
 

static  PWresult  GetNatCvGeomXyz
(  
   struct PWcvdata            *p_uvcv,
   int                        location,
   PWboolean                  is_degen,
   double                     xyztol,
   struct IGRbsp_surface      *p_sfgeom, 
   struct PWcvdata            *p_xyzcv
)
{
   
   unsigned long          retval;
   struct IGRbsp_curve    *p_natcrv=NULL;
   double                 uv, beg_par=0, mid_par, end_par=0;
   short                  option, num_poles, order;
   PWboolean              status, tst_planar, part_edge; 
   struct IGRbsp_curve    *p_bspcv=NULL;
   long                   rc;
   int                    size;

   retval = PW_K_Success;

   /*
    *  If it is not a part edge then uv value of endpts of the edge should
    *  be either zero or one.
    */
   if( (p_uvcv->data.py2d.p_pts[0][0] == 0.0 || 
        p_uvcv->data.py2d.p_pts[0][0] == 1.0    ) &&
       (p_uvcv->data.py2d.p_pts[0][1] == 0.0 ||
        p_uvcv->data.py2d.p_pts[0][1] == 1.0    ) &&
       (p_uvcv->data.py2d.p_pts[1][0] == 0.0 ||
        p_uvcv->data.py2d.p_pts[1][0] == 1.0    ) &&
       (p_uvcv->data.py2d.p_pts[1][1] == 0.0 ||
        p_uvcv->data.py2d.p_pts[1][1] == 1.0    )    )
   {
     part_edge = FALSE;
   }
   else
   {
     part_edge = TRUE;
   }


   switch( location )
   {
     case 0:
       option = 1;
       uv = 0;
       break;

     case 1:
       option = 2;
       uv = 1;
       break;

     case 2:
       option = 1;
       uv = 1;
       break;

     case 3:
       option = 2;
       uv = 0;
       break;

     default:
       retval = SetError( PW_K_Pathway, PW_K_InvalidArg );
       goto wrapup;
   }/* switch location */

   if (option == 1)
   {
     num_poles = p_sfgeom->v_num_poles;
     order = p_sfgeom->v_order;
   }
   else
   {
     num_poles = p_sfgeom->u_num_poles;
     order = p_sfgeom->u_order;
   }

   PW_ALIGN_CVSIZE (num_poles, order, (p_sfgeom->rational), 0, size);
   p_natcrv = (struct IGRbsp_curve *) malloc (size);
   OnErrorState (!(p_natcrv), retval,
                 SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

   PW_ALIGN_CVGEOM (num_poles, order, (p_sfgeom->rational), 0, p_natcrv);

   if (!part_edge)
   {
      p_bspcv = p_natcrv;
   }

   /*
    *  Extract b_spline curve from the surface
    */
   tst_planar = TRUE;
   status = BSconstprcv (&rc, p_sfgeom, &option, &uv, &tst_planar, p_natcrv);
   OnErrorState (rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);

   /*
    * EDGEU1 and EDGEV0 will have their
    * geometry reversed (poles will be placed
    * reversed to the edge direction). Therefore,
    * in order to have the geometry in the
    * direction of the edge, the poles, knots and weights
    * are reversed
    */

   /*
    * In case of a partedge, extract the partial geometry
    * from the natural edge geometry.
    */
   if (part_edge)
   {
     long  ped_num_poles;

     /*
      *  Get the parameters from the uv curve start and end points
      */
     if (location == 0)
     {
       beg_par = p_uvcv->data.py2d.p_pts[0][1];
       end_par = p_uvcv->data.py2d.p_pts[1][1];
     }
     else if (location == 2)
     {
       beg_par = p_uvcv->data.py2d.p_pts[1][1];
       end_par = p_uvcv->data.py2d.p_pts[0][1];
     }
     else if (location == 1)
     {
       beg_par = p_uvcv->data.py2d.p_pts[0][0];
       end_par = p_uvcv->data.py2d.p_pts[1][0];
     }
     else if (location == 3)
     {
       beg_par = p_uvcv->data.py2d.p_pts[1][0];
       end_par = p_uvcv->data.py2d.p_pts[0][0];
     }

     if (p_natcrv->phy_closed)
     {
       mid_par = (beg_par + end_par)/2.0;
     }
     else
     {
       mid_par = 0.0;
     }

     ped_num_poles = num_poles + 2*order - 1;
     
     PW_ALIGN_CVSIZE (num_poles, order, (p_sfgeom->rational), 0, size);
     p_bspcv = (struct IGRbsp_curve *) malloc (size);
     OnErrorState (!p_bspcv, retval,
                   SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

     PW_ALIGN_CVGEOM (num_poles, order, (p_sfgeom->rational), 0, p_bspcv);

     status = BSpartofcv (&rc, p_natcrv, beg_par, mid_par, end_par, p_bspcv);
     OnErrorState (rc !=BSSUCC, retval,
                   SetError( PW_K_BspMath, PW_K_Internal), wrapup);

   }/* if part_edge */
 
   if (location ==2 || location == 3)
   {
     status = BSrev_cv( &rc, p_bspcv );
     OnErrorState (rc !=BSSUCC, retval,
                   SetError (PW_K_BspMath, PW_K_Internal), wrapup);
   }

  
   if (p_bspcv->rational && p_bspcv->order == 2)
   {
     /*
      * Some of the methods in the IGE-system do not take kindly
      * to having an order-2 curve which is rational. So change the
      * curve to non-rational.
      */

     BSunwght_p (&rc, p_bspcv->poles, p_bspcv->weights, 
                 &p_bspcv->num_poles, p_bspcv->poles);
     OnErrorState (rc !=BSSUCC, retval,
                   SetError( PW_K_BspMath, PW_K_Internal), wrapup );
     p_bspcv->rational = FALSE;
   }
   /*
    * At this point we should check for the non-degenerate uvcurves which
    * which output degenerate xyz geometry. We should send such a geometry
    * in PWcvdata_py format with only one point.
    */
   if (! is_degen)
   {
     is_degen = pwIsCvDegen (p_bspcv, xyztol);
   }

   if (is_degen)
   {
     p_xyzcv->datatype = PWcvdata_py;
     p_xyzcv->data.py.num_pts = 1;
     p_xyzcv->data.py.p_pts = (PWpoint *)malloc (sizeof(PWpoint));
     OnErrorState (!(p_xyzcv),retval,
                   SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
     memcpy (p_xyzcv->data.py.p_pts, p_bspcv->poles, sizeof (PWpoint));
     retval = SetInfo( PW_K_Pathway, PW_K_Degenerate );
     
   }
   else if (!(p_bspcv->rational) && (p_bspcv->order==2))
   {
     /*
      * We need to send the output as a polyline
      */
     p_xyzcv->datatype = PWcvdata_py;
     p_xyzcv->data.py.num_pts = p_bspcv->num_poles;
     p_xyzcv->data.py.p_pts=NULL;
     p_xyzcv->data.py.p_pts = (PWpoint *)malloc (p_bspcv->num_poles *
                                                 sizeof (PWpoint));
     OnErrorState (!(p_xyzcv),retval,
                   SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

     memcpy (p_xyzcv->data.py.p_pts, p_bspcv->poles, p_bspcv->num_poles *
             sizeof (PWpoint));
     free (p_bspcv);
     p_bspcv=NULL;
   }
   else
   {
     p_xyzcv->datatype = PWcvdata_bspcv;
     p_xyzcv->data.p_bspcv = p_bspcv;
     p_bspcv = NULL;
   }

   wrapup:
   if (is_degen)
   {
     if (part_edge)
     {
       if (p_natcrv) 
       {
         free (p_natcrv);
         p_natcrv=NULL;
       }
       if (p_bspcv)
       {
         free (p_bspcv);
         p_bspcv=NULL;
       }
     }
     else
     {
       if (p_bspcv)
       {
         free (p_bspcv);
         p_bspcv=NULL;
         p_natcrv=NULL;
       }
     }
   }/* if is_degen */     
   else if(part_edge)
   {
     if (p_natcrv) free (p_natcrv);
       p_natcrv=NULL;
   }
   return retval;
}/* end of function GetNatCvGeomXyz */

