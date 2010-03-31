/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <string.h>
#include <memory.h>

#include "PWminimum.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWgmdata.h"
#include "PWerror.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bscvarreval.h"

#include "PWapi/edgeom.h"

static void Convt3dto2d
( 
  double *, 
  int ,
  double * 
);


PWresult   pwEdInternalPts
(
  PWobjid edobj,
  PWosnum os,
  int num,
  PWpoint2d *pts
)
{
   unsigned int           retval;
   long                   rc;
   int                    dim, num_points, i, j, inx, size;
   short                  order;
   double                 *points=NULL, delta, param, *knots=NULL, 
                          *val=NULL, *loc_pts=NULL,
                          initval;
   enum  PWcvdatatype     edgeomtype;
   struct PWcvdata        cvdata;
   struct IGRbsp_curve    *curve=NULL;
 
   retval = PW_K_Success;

   /* Get the edge geometry type
    */
   edgeomtype = pwGetEdGeomType( edobj, os );

   /* Get the edge geometry size
    */
   size = pwGetEdGeomSize( edobj, os );

   switch ( edgeomtype )
   {
      case PWcvdata_py2d:
         /* Allocate memory to hold the 2d points
          */
         cvdata.data.py2d.p_pts = (PWpoint2d *)alloca( size );
         OnErrorState( !(cvdata.data.py2d.p_pts) , retval,
                       SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
         break;
      case PWcvdata_bspcv:
         /* Allocate memory to hold the bspcv pointer
          */
         cvdata.data.p_bspcv = (struct IGRbsp_curve *)alloca( size );
         OnErrorState( !(cvdata.data.p_bspcv) , retval,
                       SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
         break;
    }
    
    retval = pwGetEdGeom( edobj, os, &cvdata );
    OnErrorCode( retval, wrapup );

    switch( cvdata.datatype)
    {
       case PWcvdata_py2d:
          num_points = cvdata.data.py2d.num_pts;
          points = (double *)(cvdata.data.py2d.p_pts);
          loc_pts = (double *)pts;
          dim = 2;
         
          delta = (double)(num_points - 1)/(double)( num + 1);
          for( i=1; i<num+1; i++)
          {
             inx = i*delta;
             param = i*delta - inx;
             inx *= dim;
             for( j=0; j<dim; j++)
                loc_pts[j] = points[inx+j] + 
                         param*(points[inx+j+dim] - points[inx+j]);
             loc_pts +=dim;
          }
          loc_pts = NULL;
          break;
       case PWcvdata_bspcv:
          curve = cvdata.data.p_bspcv;
          num_points = curve->num_poles;
          knots = curve->knots;
          order = curve->order;
          val = (IGRdouble *)alloca( num*sizeof(double));
          OnErrorState( !val, retval,
                        SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
          loc_pts = (IGRdouble *)alloca( num*3*sizeof(double));
          OnErrorState( !loc_pts, retval,
                        SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);
          delta = (knots[num_points] - knots[order -1])/(num + 1);
          initval = knots[order-1];
          for( i=0; i<num; i++ )
             val[i] = initval + (i+1) * delta;

          BScvarreval( &rc, curve, val, num, 0, loc_pts);
          OnErrorState( rc !=BSSUCC, retval, 
                         SetError( PW_K_BspMath, PW_K_Internal ), wrapup);
          Convt3dto2d( loc_pts, num, (double *)pts );
          break;
    }
      
    wrapup:     

    return (retval);
}


static void Convt3dto2d
(
   double   *pt3d,
   int      num,
   double   *pt2d
)
{
   int i;
  
   for( i=0; i<num; i++ )
     memcpy( &(pt2d[i*2]), &(pt3d[i*3]), 2*sizeof(double));
}/* end of function Convt3dto2d */
