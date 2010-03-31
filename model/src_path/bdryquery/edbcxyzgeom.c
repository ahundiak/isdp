#include <stdio.h>
#include <math.h>
#include <alloca.h>
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

#include "PWapi/edgeom.h"
#include "PWapi/edprops.h"
#include "PWapi/sfgeom.h"
#include "PWapi/lped.h"
#include "PWapi/sflp.h"
#include "PWapi/aligngm.h"


#define   CONSTANT_U  1
#define   CONSTANT_V  2

/*
 * BS-code for non-planar set of points after the call to
 * BSptlnplan().
 */

#define NON_PLANAR 4

static PWresult GetIsoEdGeomXyz
(
   PWobjid		  ed,
   PWosnum		  os,
   struct IGRbsp_surface  *p_sfgeom,
   struct IGRbsp_curve    **p_bspcv
);

static  PWboolean  MapUvToXyzForPlanes
(
   struct IGRbsp_surface  *surface,
   int                    np,
   PWpoint2d              *uv,
   PWpoint                *xyz
);

static PWboolean  Rot_ele
(
   short        *ele_typ,
   PWboolean    *forward,
   double       q[][3],
   PWpoint      pzero,
   short        *np,
   int          ptr
);

static  PWresult  GetNatEdGeomXyz
(
   PWobjid		      ed,
   PWosnum		      os,
   struct IGRbsp_surface      *p_sfgeom,
   struct IGRbsp_curve        **p_bspcv
);

/*
 *   Assumption *p_bspcv = NULL
 */

PWresult pwGetEdbcXyzGeom
(
   PWobjid		ed,
   PWosnum		os,
   struct PWsfdata      *p_sfdata,
   struct IGRbsp_curve  **p_bspcv
)
{  
    unsigned long           retval;
    struct IGRbsp_surface   *p_sfgeom=NULL;
    enum PWcvdatatype       edgeomtyp;
    struct PWcvdata         cvdata;
    double                  *poles2d=NULL;
    double                  *genptr1=NULL, *genptr2=NULL;
    int                     i, j, k,  planar_code, size;
    PWvector                dum_vec;
    PWboolean               status;
    long                    rc;
    double                  delta;
    double                  *genptr=NULL;

   retval = PW_K_Success;
   
   /*
    * Get the surface geometry of the incoming edge.
    */

   if( p_sfdata->datatype == PWsfdata_plane )
       OnErrorState( TRUE, retval, SetError(PW_K_Pathway, PW_K_InvalidArg),
                      wrapup);

   p_sfgeom = p_sfdata->datatype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf :
                                            p_sfdata->data.p_gmbspsf->bspsf;
   /*****
   lpid = pwGetLpOfEd( ed, os );
   sfid = pwSfOfLp( lpid, os );

   PW_GETSFGEOM_STACK( retval, sfid, os, mattyp, mat, p_sfgeom);
   *******/

   /*
    *  Get the edge geometry type
    */
   edgeomtyp = pwGetEdGeomType( ed, os );

   switch( edgeomtyp )
   {
      case PWcvdata_bspcv:
         /*
          *  make sure that the surface satisfies the linear mapping
          *  criterion. If not something is messed up.
          */
         if (!( (p_sfgeom->u_order == 2) && (p_sfgeom->v_order == 2) &&
                (p_sfgeom->planar) && (!p_sfgeom->rational) ))
         {
            retval = SetError( PW_K_Pathway, PW_K_InvalidArg);
            goto wrapup;
         }
         /*
          *  get (u,v) space geomtery of the edge from heap
          */
         retval = pwGetEdGeomAsBspline( ed, os, p_bspcv );
         OnErrorCode( retval, wrapup );

         /*
          * convert the Poles from (u,v) space to (x,y,z) space
          * Since B-spline edges are placed on the plane,
          * a faster routine is invoked for evaluation.
          */
         poles2d = (double *)alloca( (*p_bspcv)->num_poles * 2 *
                                     sizeof(double));
         OnErrorState( !poles2d, retval,
                       SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

         genptr1 = (*p_bspcv)->poles;
         genptr2 = (*p_bspcv)->weights;
         for (i = 0, j = 0, k = 0; i < (*p_bspcv)->num_poles; i++, j+=2, k+=3)
         {
            poles2d[j] = genptr1[k];
            poles2d[j+1] = genptr1[k+1];

            if ((*p_bspcv)->rational)
            {
               poles2d[j] /= genptr2[i];
               poles2d[j+1] /= genptr2[i];
            }

         } /* for (i = 0; i < p_bspcv->num_poles; i++) */

         status = MapUvToXyzForPlanes( p_sfgeom, (*p_bspcv)->num_poles,
                                       (PWpoint2d *)poles2d, 
                                       (PWpoint *)(*p_bspcv)->poles );
         
         if ((*p_bspcv)->rational)
         {
            genptr1 = (*p_bspcv)->poles;
            genptr2 = (*p_bspcv)->weights;
            for ( i = 0, k = 0; i < (*p_bspcv)->num_poles; i++, k+=3)
               for (j = 0; j < 3; j++)
                  genptr1[k+j] *= genptr2[i];
         }

         if( pwIsEdDegen( ed, os ) )
         {
            retval = SetInfo( PW_K_Pathway, PW_K_Degenerate );
         }
         break;
      case  PWcvdata_py2d:
         /*
          *  If this is an iso-edge, get the geometry through the special
          *  processing
          */
         if( pwIsEdIso( ed, os) )
         {
            retval = GetIsoEdGeomXyz( ed, os, p_sfgeom, p_bspcv );
            goto wrapup;
         }
         /*
          * If this is a natural edge get the geometry through special
          * processing.
          */
         if( pwIsEdNatural( ed, os) )
         {
            retval = GetNatEdGeomXyz( ed, os, p_sfgeom, p_bspcv );
            goto wrapup;
         }
         /*
          * Obtain parametric space geometry of the edge
          */
         retval = PW_GetEdGeomStack (ed, os, cvdata);

         /*
          *  Convert these points from parametric space to model space poles.
          */
      
         size = pwAlignCvSize ((cvdata.data.py2d.num_pts), 2, FALSE, 0);
         *p_bspcv = (struct IGRbsp_curve *) malloc (size);
         OnErrorState( !(*p_bspcv), retval,
                       SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

         pwAlignCvGeom ((cvdata.data.py2d.num_pts), 2, FALSE, 0, (*p_bspcv));

         BSsfptseval (p_sfgeom, cvdata.data.py2d.num_pts, 
                      (double *)cvdata.data.py2d.p_pts, (*p_bspcv)->poles, &rc);
         OnErrorState( rc !=BSSUCC, retval,
                  SetError( PW_K_BspMath, PW_K_Internal), wrapup );

         /*
          * The control information in the rest of the curve structure is filled
          * up here. The knots are determined as uniform.
          */

         (*p_bspcv)->order = 2;
         (*p_bspcv)->periodic = FALSE;
         (*p_bspcv)->non_uniform = FALSE;
         (*p_bspcv)->num_poles = cvdata.data.py2d.num_pts;
         (*p_bspcv)->num_knots = cvdata.data.py2d.num_pts+2;

         delta = 1.0 / ((*p_bspcv)->num_poles-1);
         genptr = (*p_bspcv)->knots;
         genptr[0] = genptr[1] = 0.0;
         genptr[(*p_bspcv)->num_poles] = genptr[(*p_bspcv)->num_poles+1] = 1.0;
         for (i=2; i<(*p_bspcv)->num_poles; i++)
         {
            genptr[i] = genptr[i-1] + delta;
         }
         (*p_bspcv)->rational = FALSE;
         if (p_sfgeom->planar)
         {
            (*p_bspcv)->planar = TRUE;
         }
         else
         {
            BSptlnplan ((*p_bspcv)->num_poles, FALSE, 
                        (PWpoint *)(*p_bspcv)->poles, NULL, &planar_code,
                        dum_vec, &rc);
            OnErrorState( rc !=BSSUCC, retval,
                  SetError( PW_K_BspMath, PW_K_Internal), wrapup );
            (*p_bspcv)->planar = planar_code == NON_PLANAR ? FALSE : TRUE;
         }
         if( pwIsEdClosedXYZ( ed, os ) )
         {
            (*p_bspcv)->phy_closed = TRUE;
         }
         else
         {
            (*p_bspcv)->phy_closed = FALSE;
         }
         (*p_bspcv)->num_boundaries = 0;

         if( pwIsEdDegen( ed, os ) )
         {
            (*p_bspcv)->periodic = FALSE;
            (*p_bspcv)->non_uniform = FALSE;
            (*p_bspcv)->order = 2;
            (*p_bspcv)->num_poles = 2;
            (*p_bspcv)->num_knots = 4;
            (*p_bspcv)->knots[0] = (*p_bspcv)->knots[1] = 0.0;
            (*p_bspcv)->knots[2] = (*p_bspcv)->knots[3] = 1.0;
            (*p_bspcv)->rational = FALSE;
            (*p_bspcv)->planar = TRUE;
            (*p_bspcv)->phy_closed = TRUE;

            retval = SetInfo( PW_K_Pathway, PW_K_Degenerate );
         }
         break;
   } 
   wrapup:
   return retval;
}/* end of function  pwGetEdbcXyzGeom */

/*
 *   Assumption (*p_bspcv) is always NULL
 */

static PWresult GetIsoEdGeomXyz
( 
   PWobjid		  ed,
   PWosnum                os,
   struct IGRbsp_surface  *p_sfgeom, 
   struct IGRbsp_curve    **p_bspcv 
)
{
   unsigned long              retval;
   struct IGRbsp_curve        *p_iso_crv=NULL;
   PWboolean                  status, tst_planar;
   struct PWcvdata            edgeom;
   PWboolean                  reverse;
   double                     iso_par, beg_par, mid_par, end_par, temp_par;
   PWboolean                  whole_iso;
   short                      option, num_poles, order;
   long                       rc;
   int                        size;
   /* Initialize 
    */
   retval = PW_K_Success;
   

   reverse = FALSE;
   /*
    *  Get the input edge geometry
    */
   retval = PW_GetEdGeomStack (ed, os,  edgeom);

   if(fabs(edgeom.data.py2d.p_pts[0][0] - edgeom.data.py2d.p_pts[1][0]) <
      fabs(edgeom.data.py2d.p_pts[0][1] - edgeom.data.py2d.p_pts[1][1]))
   {
      option = CONSTANT_U;
      iso_par = (edgeom.data.py2d.p_pts[0][0] +
                 edgeom.data.py2d.p_pts[1][0])/2.0;
      beg_par = edgeom.data.py2d.p_pts[0][1];
      end_par = edgeom.data.py2d.p_pts[1][1];
   }
   else
   {
      option = CONSTANT_V;
      iso_par = (edgeom.data.py2d.p_pts[0][1] +
                 edgeom.data.py2d.p_pts[1][1])/2.0;
      beg_par = edgeom.data.py2d.p_pts[0][0];
      end_par = edgeom.data.py2d.p_pts[1][0];
   }
   if( beg_par > end_par)
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


   if ( option == CONSTANT_U)
   {
      num_poles = p_sfgeom->v_num_poles;
      order = p_sfgeom->v_order;
   }
   else
   {
      num_poles = p_sfgeom->u_num_poles;
      order = p_sfgeom->u_order;
   }

   size = pwAlignCvSize (num_poles, order, (p_sfgeom->rational), 0);
   p_iso_crv = (struct IGRbsp_curve *) malloc (size);
   OnErrorState( !(p_iso_crv),retval,
                 SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

   pwAlignCvGeom (num_poles, order, (p_sfgeom->rational), 0, p_iso_crv);

   if( whole_iso )
   {
      *p_bspcv = p_iso_crv;
   }

   /*
    * extract b_spline curve from the surface
    */
   tst_planar = TRUE;
   status = BSconstprcv( &rc, p_sfgeom, &option, &iso_par, &tst_planar,
                         p_iso_crv );
   OnErrorState( rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup );

   /*
    * extract part of the iso curve if required.
    */
   if (!whole_iso)
   {
      if( p_iso_crv->phy_closed )
      {
         mid_par = (beg_par + end_par)/2.0;
      }
      else 
      {
         mid_par = 0.0;
      }
      num_poles = num_poles + 2*order - 1;
      

      if( !(*p_bspcv))
      {
         size = pwAlignCvSize (num_poles, order, (p_sfgeom->rational), 0);
         *p_bspcv = (struct IGRbsp_curve *) malloc (size);
         OnErrorState( !(*p_bspcv), retval,
                       SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
      }
      pwAlignCvGeom (num_poles, order, (p_sfgeom->rational), 0, (*p_bspcv));

      status = BSpartofcv (&rc, p_iso_crv, beg_par, mid_par, end_par,
                            *p_bspcv);
      OnErrorState( rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup );
       
   }/* if (!whole_iso) */

   if ((*p_bspcv)->rational && (*p_bspcv)->order == 2)
   {
      /*
       * Some of the methods in the IGE-system do not take kindly
       * to having an order-2 curve which is rational. So change the
       * curve to non-rational.
       */

      BSunwght_p (&rc, (*p_bspcv)->poles, (*p_bspcv)->weights, 
                  &(*p_bspcv)->num_poles, (*p_bspcv)->poles);
      OnErrorState( rc !=BSSUCC, retval,
                    SetError( PW_K_BspMath, PW_K_Internal), wrapup );
      /*** cannot free it
      free( p_bspcv->weights );
      p_bspcv->weights = NULL;
      *********/
      (*p_bspcv)->rational = FALSE;
   }

   if(reverse )
   {
      status = BSrev_cv( &rc, (*p_bspcv) );
      OnErrorState( rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup );
   }

   if( pwIsEdDegen( ed, os ) )
   {
      if ((*p_bspcv)->rational )
      {
         BSunwght_p (&rc, (*p_bspcv)->poles, (*p_bspcv)->weights, 
                     &(*p_bspcv)->num_poles, (*p_bspcv)->poles);
         OnErrorState( rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup );
         /****can't free
         free( p_bspcv->weights);
         p_bspcv->weights = NULL;
         ********/
      }
      (*p_bspcv)->periodic = FALSE;
      (*p_bspcv)->non_uniform = FALSE;
      (*p_bspcv)->order = 2;
      (*p_bspcv)->num_poles = 2;
      (*p_bspcv)->num_knots = 4;
      (*p_bspcv)->knots[0] = (*p_bspcv)->knots[1] = 0.0;
      (*p_bspcv)->knots[2] = (*p_bspcv)->knots[3] = 1.0;
      (*p_bspcv)->rational = FALSE;
      (*p_bspcv)->planar = TRUE;
      (*p_bspcv)->phy_closed = TRUE;

      retval = SetInfo( PW_K_Pathway, PW_K_Degenerate );
   }
   wrapup:
   
   if( !whole_iso)
   {
      if(p_iso_crv) free(p_iso_crv); 
   }
   PW_Wrapup( retval, "Function: GetIsoEdGeomXyz ");
   return retval;
}/* end of function GetIsoEdGeomXyz */
 

static  PWboolean  MapUvToXyzForPlanes
( 
   struct IGRbsp_surface  *surface, 
   int                    np,
   PWpoint2d              *uv, 
   PWpoint                *xyz 
)
{
   PWpoint                  vv[4];
   double                   *q1=NULL, *q2=NULL, *q3=NULL, *q4=NULL;
   double                   us, ud, vs, vd;
   double                   rot[3][3], zz, zl, tol_sq, dist_tol;
   double                   u_ratio, v_ratio, shift_rate;
   int                      low_left, low_right, up_left, up_right;
   int                      k, iii;
   long                     rc, retval;
   short                    kd, j, short_np;
   PWboolean                forward, status=TRUE;

   BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
   BSEXTRACTPAR(&rc, BSTOLSQLENVEC, tol_sq);

   low_left = 0;
   low_right = (surface->u_num_poles - 1) * 3;
   up_left = (surface->u_num_poles * (surface->v_num_poles-1)) * 3;
   up_right = up_left + low_right;

   q1 = &surface->poles[low_left];
   q2 = &surface->poles[low_right];
   q3 = &surface->poles[up_right];
   q4 = &surface->poles[up_left];

   us = surface->u_knots[surface->u_order - 1];
   ud = surface->u_knots[surface->u_num_poles];
   vs = surface->v_knots[surface->v_order - 1];
   vd = surface->v_knots[surface->v_num_poles];

   /*
    *  first check the 4 points
    */
   zl = 0.0;
   zz = 0.0;
   for(k=0;k<3;k++)
   {
      rot[0][k] = q2[k] - q1[k];
      rot[1][k] = q3[k] - q1[k];
      zl += (rot[0][k] * rot[0][k]);
      zz += (rot[1][k] * rot[1][k]);
   }
   if(fabs(zl) < tol_sq)
   {
      zl = 0.0;
      for(k=0;k<3;k++)
      {
         rot[0][k] = q4[k] - q1[k];
         zl += (rot[0][k] * rot[0][k]);
      }
      if(fabs(zl) < tol_sq)
      {
         retval = SetError( PW_K_Pathway, PW_K_InvalidArg );
         goto wrapup;
      }
   }
  
   status = BScrossp(&rc,rot[0],rot[1],rot[2]);
   status = BSnorvec(&rc,rot[2]);
   status = BScrossp(&rc,rot[2],rot[0],rot[1]);
   status = BSnorvec(&rc,rot[0]);
   status = BSnorvec(&rc,rot[1]);

   for(k=0; k<3; k++)
   {
      vv[0][k] = q1[k];
      vv[1][k] = q2[k];
      vv[2][k] = q4[k];
   }

   forward = TRUE;
   kd = 0;
   j = 3;
   status = Rot_ele(&kd,&forward,rot,q1,&j,(int)vv);

   if( (vv[2][1] <= dist_tol) || (vv[1][0] <= dist_tol) )
   {
      retval = SetError( PW_K_Pathway, PW_K_InvalidArg );
      goto wrapup; 
   }

   v_ratio = vv[2][1]  / (vd - vs);
   u_ratio = vv[1][0]/ ( ud - us );
   shift_rate = vv[2][0] / vv[2][1];

   for(iii=0; iii < np; iii++)
   {
      /*
       * perform (u,v) space translation and scaling for y coordinate
       */

      xyz[iii][1] = (uv[iii][1] - vs) * v_ratio;

      /*
       * perform (u,v) space translation, scaling and shearing for
       * x coordinate.
       */

      xyz[iii][0] = (uv[iii][0] - us) * u_ratio + xyz[iii][1] * shift_rate;
      xyz[iii][2] = 0.;

   }

   /*
    * Rotate  and translate to bring it into model space.
    */

   forward = FALSE;
   short_np = np;
   status = Rot_ele(&kd,&forward,rot,q1,&short_np,(int)xyz);

   wrapup:
     return status;
}/* end of function MapUvToXyzForPlanes */


static PWboolean  Rot_ele
(
   short        *ele_typ,
   PWboolean    *forward,
   double       q[][3],
   PWpoint      pzero,
   short        *np,
   int          ptr
)
{
   PWboolean                status,rat=0;
   struct IGRbsp_curve      *curve=NULL;
   struct IGRbsp_surface    *surf=NULL;
   int                      i,j,k,num=0;
   PWpoint                  xyz;
   double                   *p1=NULL,*p2=NULL,*pol=NULL,*wet=NULL;
   double                   *d=NULL;

   status = TRUE;

   if( *ele_typ == 0 )
   {
      pol = (double *) ptr;
      num = *np;
      rat = FALSE;
   }
   if( *ele_typ == 1 )
   {
      curve = (struct  IGRbsp_curve *) ptr;
      num = curve->num_poles;
      rat = curve->rational;
      pol = curve->poles;
      wet = curve->weights;
   }
   if( *ele_typ == 2 )
   {
      surf = (struct IGRbsp_surface *) ptr;
      num = surf->u_num_poles * surf->v_num_poles;
      rat = surf->rational;
      pol = surf->poles;
      wet = surf->weights;
   } 

   d = pol;

   if( rat )
   {
      p1 = pol;
      p2 = wet;
      for(i=0; i < num; i++)
      {
         *p1++ /= *p2;
         *p1++ /= *p2;
         *p1++ /= *p2;
         p2++;
      }
   }

   if( *forward )
   {
      for(i=0; i < num; i++)
      {
         for(k=0; k<3; k++)
         {
            d[i*3 + k] -= pzero[k];
         }
      }
      for(i=0; i < num; i++)
      {
         for(j=0;j < 3; j++)
         {
            xyz[j] = 0.0;
            for(k=0; k<3; k++)
            {
               xyz[j] += (d[i*3 + k] * q[j][k]);
            }
         }
         for(j=0;j < 3; j++)
         {
            d[3*i + j] = xyz[j];
         }
      }
   }
   else
   {
      for(i=0; i < num; i++)
      {
         for(j=0;j < 3; j++)
         {
            xyz[j] = 0.0;
            for(k=0; k<3; k++)
            {
               xyz[j] += (d[3*i + k] * q[k][j]);
            }
         }
         for(j=0;j < 3; j++)
         {
            d[3*i + j] = xyz[j];
         }
      }
      for(i=0; i < num; i++)
      {
         for(k=0; k<3; k++)
         {
            d[3*i + k] += pzero[k];
         }
      }
   }
   
   if( rat )
   {
      p1 = pol;
      p2 = wet;
      for(i=0; i < num; i++)
      {
         *p1++ *= *p2;
         *p1++ *= *p2;
         *p1++ *= *p2;
         p2++;
      }
   }
   return status;
}/* end of function Rot_ele */


static  PWresult  GetNatEdGeomXyz
(  
   PWobjid		      ed,
   PWosnum                    os,
   struct IGRbsp_surface      *p_sfgeom, 
   struct IGRbsp_curve        **p_bspcv 
)
{
   
   unsigned long          retval;
   struct  PWcvdata       edgeom;
   struct IGRbsp_curve    *p_natcrv=NULL;
   double                 uv, beg_par=0, mid_par, end_par=0;
   short                  option, num_poles, order;
   PWboolean              status, tst_planar, part_edge; 
   long                   rc;
   int                    size, location;

   retval = PW_K_Success;
   /*
    *  Get the natural edge location
    */
    pwGetNatEdLocation( ed, os ,&location);

   /*
    *  Detect whether it is a part edge
    */
   retval = PW_GetEdGeomStack (ed, os, edgeom);

   /*
    *  If it is not a part edge then uv value of endpts of the edge should
    *  be either zero or one.
    */
   if( (edgeom.data.py2d.p_pts[0][0] == 0.0 || 
        edgeom.data.py2d.p_pts[0][0] == 1.0    ) &&
       (edgeom.data.py2d.p_pts[0][1] == 0.0 ||
        edgeom.data.py2d.p_pts[0][1] == 1.0    ) &&
       (edgeom.data.py2d.p_pts[1][0] == 0.0 ||
        edgeom.data.py2d.p_pts[1][0] == 1.0    ) &&
       (edgeom.data.py2d.p_pts[1][1] == 0.0 ||
        edgeom.data.py2d.p_pts[1][1] == 1.0    )    )
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


   if ( option == 1)
   {
      num_poles = p_sfgeom->v_num_poles;
      order = p_sfgeom->v_order;
   }
   else
   {
      num_poles = p_sfgeom->u_num_poles;
      order = p_sfgeom->u_order;
   }

   size = pwAlignCvSize (num_poles, order, (p_sfgeom->rational), 0);
   p_natcrv = (struct IGRbsp_curve *) malloc (size);
   OnErrorState( !(p_natcrv), retval,
                 SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

   pwAlignCvGeom (num_poles, order, (p_sfgeom->rational), 0, p_natcrv);

   if( !part_edge )
   {
      *p_bspcv = p_natcrv;
   }

   /*
    *  Extract b_spline curve from the surface
    */
   tst_planar = TRUE;
   status = BSconstprcv( &rc, p_sfgeom, &option, &uv, &tst_planar,
                         p_natcrv );
   OnErrorState( rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup );

   if( pwIsEdClosedXYZ( ed, os ) )
   {
      p_natcrv->phy_closed = TRUE;
   }

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
   if( part_edge )
   {
      long  ped_num_poles;

      /*
       *  Get the parameters from the uv curve start and end points
       */
      if( location == 0 )
      {
         beg_par = edgeom.data.py2d.p_pts[0][1];
         end_par = edgeom.data.py2d.p_pts[1][1];
      }
      else if( location == 2)
      {
         beg_par = edgeom.data.py2d.p_pts[1][1];
         end_par = edgeom.data.py2d.p_pts[0][1];
      }
      else if( location == 1 )
      {
         beg_par = edgeom.data.py2d.p_pts[0][0];
         end_par = edgeom.data.py2d.p_pts[1][0];
      }
      else if( location == 3 )
      {
         beg_par = edgeom.data.py2d.p_pts[1][0];
         end_par = edgeom.data.py2d.p_pts[0][0];
      }

      if( p_natcrv->phy_closed )
      {
         mid_par = (beg_par + end_par)/2.0;
      }
      else
      {
         mid_par = 0.0;
      }

      ped_num_poles = num_poles + 2*order - 1;
     
      size = pwAlignCvSize (num_poles, order, (p_sfgeom->rational), 0);
      *p_bspcv = (struct IGRbsp_curve *) malloc (size);
      OnErrorState( !(*p_bspcv), retval,
                    SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

      pwAlignCvGeom (num_poles, order, (p_sfgeom->rational), 0, (*p_bspcv));

      status = BSpartofcv (&rc, p_natcrv, beg_par, mid_par, end_par,
                            (*p_bspcv));
      OnErrorState( rc !=BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup );

   }/* if part_edge */
 
   if( location ==2 || location == 3)
   {
     status = BSrev_cv( &rc, *p_bspcv );
     OnErrorState (rc !=BSSUCC, retval,
                   SetError( PW_K_BspMath, PW_K_Internal), wrapup );
   }

  
   if ((*p_bspcv)->rational && (*p_bspcv)->order == 2)
   {
      /*
       * Some of the methods in the IGE-system do not take kindly
       * to having an order-2 curve which is rational. So change the
       * curve to non-rational.
       */

      BSunwght_p (&rc, (*p_bspcv)->poles, (*p_bspcv)->weights, 
                  &(*p_bspcv)->num_poles, (*p_bspcv)->poles);
      OnErrorState( rc !=BSSUCC, retval,
                    SetError( PW_K_BspMath, PW_K_Internal), wrapup );
      /***can't free***
      free( p_bspcv->weights );
      p_bspcv->weights = NULL;
      *******/
      (*p_bspcv)->rational = FALSE;
   }

   /*
    *  Check for degeneracy 
    */
   if( pwIsEdDegen( ed, os ) )
   {
      retval = SetInfo( PW_K_Pathway, PW_K_Degenerate );
   }

   wrapup:

     if(part_edge)
     {
        if( p_natcrv )free( p_natcrv);
     }

     return retval;
}/* end of function GetNatEdGeomXyz */
