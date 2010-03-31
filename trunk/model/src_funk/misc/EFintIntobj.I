class implementation  Root;
/*
 * The following function is to intersect two intersection objects and obtain 
 * the intersection point.  This function is primarily writtern for finding
 * intersection point of intersection objects created for rounding. It finds
 * and return only the first intersection foundi during processing.
 *  Function return TRUE if there is an intersection else FALSE.
 * Inputs:-

     options        - usual options argument, Not used.
     env_info       - module info;
     intobj_first   - first intersection object.
     intobj_second  - second intersection object.

 * Outputs :-

     EMmsg          - Return code.   
     num_ints       - number of intersections will be 0 or 1.
     intedpar1      - intersection info of intobj_first ( caller must 
                      allocate memmory for one structure)
     intedpar2      - intersection info of intobj_second ( caller must 
                      allocate memmory for one structure)
     xyz_pt         - Corresponding xyz -intersection point. If not wanted
                      pass NULL( This is not returne for the time being).
 * Notes :-
  
     Both intedpar1 and intedpar2 must be NON-NULL.

 * History :-

   Inasu: Feb 10, 92  : Creation.
   Sudha  07/09/93    : Modified for BSprototypes anisfication
 */

#include "EMS.h"
#include <math.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bsxlnln2d.h"
#include "bsparameters.h"
#include "bsmdstptcv.h"
#include "bsdptseg2.h"
#include "bsdistptpt.h"

from GRvg     import   EMptatpr;

IGRboolean EFintersect_intobjs( EMmsg, options, env_info, intobj_first, 
                         intobj_second, num_ints,intedpar1, intedpar2, xyz_pt)
IGRlong *EMmsg;
IGRushort options;
struct GRmdenv_info *env_info;
struct EMSintobj *intobj_first, *intobj_second;
IGRint *num_ints;
struct EMSsfintedpar *intedpar1, *intedpar2;
IGRdouble *xyz_pt;
{
 IGRlong om_stat, msg;
 IGRboolean sts = FALSE;
 struct EMSdataselect *data_first=NULL, *data_second=NULL,*data_ptr=NULL;
 IGRdouble range_first[4], range_second[4];
 IGRdouble *poly1_pts = NULL, *poly2_pts = NULL, *polypts = NULL;
 IGRint    num1_pts = 0, num2_pts = 0, num=0,ii,jj,kk; 
 IGRdouble par1[2], par2[2], intpts[2][2], min_dist, cht_tol, delta,
	   line1[2][2], line2[2][2];
 IGRpoint base_pt, xyz_endpts[4];

   *EMmsg = EMS_S_Success;
   om_stat= OM_S_SUCCESS;

    /* First check the type of uv intersection data. The intersection is
     * done only if both are of the type EMSdata_poly2d.
     */

     options   = NULL;
     *num_ints = 0;

     if( ! intedpar1 || ! intedpar2 ) goto wrapup;

     BSEXTRACTPAR(&msg, BSTOLCHRDHT,cht_tol);

     /* initialise the output structures */

     intedpar1->intloc = intedpar2->intloc = EMScvint_unknown;
     intedpar1->info = intedpar2->info = NULL;
     intedpar1->next = intedpar2->next = NULL;

     data_first  = &intobj_first->this_uvintobj;
     data_second = &intobj_second->this_uvintobj;

     /* if either of them is not the type EMSdata_poly2d just exit */

     if((data_first->datatype != EMSdata_poly2d) || 
                            (data_second->datatype != EMSdata_poly2d))
     goto wrapup;
     
     for( ii = 0; ii < 2; ii++ )
     {
       om_stat = EMgetendpts_xyz(&msg,
                    &env_info->matrix_type,
                    env_info->matrix,
                    (ii ? &intobj_second->this_xyzintobj
                        : &intobj_first->this_xyzintobj),
                    FALSE,
                    1,
                    xyz_endpts[2*ii],
                    xyz_endpts[2*ii+1]);
       EMerr_hndlr( !(1 & om_stat & msg), *EMmsg, msg, wrapup);
     }


     num1_pts = data_first->data.poly->num_points;
     num2_pts = data_second->data.poly->num_points;

     poly1_pts = data_first->data.poly->points;
     poly2_pts = data_second->data.poly->points;

     EM2dbx( num1_pts, poly1_pts, range_first);

     EM2dbx( num2_pts, poly2_pts, range_second);

     /* Shrink the range boxes by delat= 1e-6 */
  
     delta = 1.0e-6;

     range_first[0] += delta; 
     range_first[1] += delta; 
     range_first[2] -= delta; 
     range_first[3] -= delta; 

     range_second[0] += delta; 
     range_second[1] += delta; 
     range_second[2] -= delta; 
     range_second[3] -= delta; 

     /*
      *If the poly lines intersect  get the intersection point and all other
      *relevant informations.Please note,it finds only the first interisection.
      *Once it hits, the function simply exit. 
      */

     if( EM2dbxbxint( range_first, range_second ))
     {
      IGRdouble seg1_range[4], seg2_range[4];

        for(ii = 0; ii < (num1_pts - 1); ii++)
        {
          EM2dbx(2,&poly1_pts[2 * ii], seg1_range);
          
          if( ! EM2dbxbxint(seg1_range, range_second) ) continue;

          for( jj = 0; jj < (num2_pts - 1); jj++ )
          {
            EM2dbx(2, &poly2_pts[2*jj], seg2_range); 
            
            if(! EM2dbxbxint( seg1_range, seg2_range)) continue;
           
            line1[0][0] = poly1_pts[2*ii];
            line1[0][1] = poly1_pts[2*ii+1];
            line1[1][0] = poly1_pts[2*ii+2];
            line1[1][1] = poly1_pts[2*ii+3];


            line2[0][0] = poly2_pts[2*jj];
            line2[0][1] = poly2_pts[2*jj+1];
            line2[1][0] = poly2_pts[2*jj+2];
            line2[1][1] = poly2_pts[2*jj+3];

            BSxlnln2d( line1/*&poly1_pts[2*ii]*/, line2/*&poly2_pts[2*jj]*/, &num,intpts, 
                            par1, par2,&msg);
            if( num )
            {
              *num_ints           = 1;

              intedpar1->point[0] = intpts[0][0];
              intedpar1->point[1] = intpts[0][1];
              intedpar1->edgepar.span_inx = ii;
              intedpar1->edgepar.param   = par1[0];
               
              intedpar2->point[0] = intpts[0][0];
              intedpar2->point[1] = intpts[0][1];
              intedpar2->edgepar.span_inx = jj;
              intedpar2->edgepar.param   = par2[0];

              om_stat = om$send( msg = message GRvg.EMptatpr( &msg,
                                        &(env_info->matrix_type),
                                        env_info->matrix,
                                        intedpar1->point,2,base_pt),
              senderid = NULL_OBJID,
              targetid = intobj_first->this_obj_node->this_obj.objid,
              targetos = intobj_first->this_obj_node->this_obj.osnum);

             
              sts = TRUE;
              break;
            }
          }
          if( sts ) break;
        }
     }
      
     /* 
        Look for the touching intersections. If yes, get this touching 
        intersection. (The following part could have been part of "else"
        of the above "if" but I could find cases when the range boxes 
        intersected, the math did not for touching cases. -Inasu) 
      */

     if( ! *num_ints )
     {
       delta = 0.01;

       for( ii = 0; ii < 2; ii++)
       {
        IGRpoint uv_endpts[2];

         om_stat = EMgetendpts_uv(&msg,
                    (ii ? data_second : data_first),
                    FALSE,
                    1,
                    uv_endpts[0],
                    uv_endpts[1]);
         EMerr_hndlr( !(1 & om_stat & msg), *EMmsg, msg, wrapup);

         uv_endpts[0][2] = uv_endpts[1][2] = 0.0;

         num = ii ? data_first->data.poly->num_points
                  : data_second->data.poly->num_points; 

         for( jj=0; jj < 2; jj++ )
         {
          IGRpoint point, min_pt;
          IGRdouble dist, par, min_par;
          IGRint   mdist_inx = 0;
          IGRpoint lnseg[2];

          dist = min_dist = MAXDOUBLE;

          polypts = ii ? data_first->data.poly->points
                       : data_second->data.poly->points;
           
          for(kk = 0; kk < (num - 1); kk++)
          {

            lnseg[0][0] = polypts[2*kk];
            lnseg[0][1] = polypts[2*kk+1];
            lnseg[0][2] = 0.0;

            lnseg[1][0] = polypts[2*kk+2];
            lnseg[1][1] = polypts[2*kk+3];
            lnseg[1][2] = 0.0;

            BSdptseg2( uv_endpts[jj],lnseg[0], lnseg[1], 
                       point, &par, &dist, &msg);
            EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
          
            if( dist < min_dist )
            { 
              min_dist  = dist;
              OM_BLOCK_MOVE(point, min_pt, sizeof(IGRpoint));
              mdist_inx = kk;
              min_par   = par;
            }
          }

          /* The minimum distance we have here is prametric space. Check 
           * wheather this is within twice the chord height tolerance.
           * This is done only if min_dist is less than delta which is
           * taken as 0.01 */

          if( min_dist < delta )
          {
            data_ptr = ii ? &intobj_first->this_xyzintobj 
                          : &intobj_second->this_xyzintobj;

            min_dist = MAXDOUBLE;
         
            switch( data_ptr->datatype )
            {
              case EMSdata_poly3d:
                 
                 polypts = data_ptr->data.poly->points;
                 for( kk = 0; kk < 3; kk++ )
         	 base_pt[kk] = polypts[3*mdist_inx+kk]*(1.0 - min_par)
                                    + polypts[3*(mdist_inx+1) + kk] * min_par;
                 min_dist = BSdistptpt(&msg, base_pt, xyz_endpts[2*ii+jj]);
                 break;

              case EMSdata_curve3d:

                 BSmdstptcv( data_ptr->data.curve,xyz_endpts[2*ii+jj], &par,
                                     base_pt,&min_dist, &msg);
                 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);
                 break;

              default:

                 break;
            }

            /* Now get the model space minimum distance between this two 
               parametric points. If it is greater than the twice the
               chord height tolerace. Proceed with next end point in line.
             */ 

            if( min_dist > 2 * cht_tol) continue;

            sts = TRUE;
            *num_ints = 1;

         /*pull the end point of respective poly line to the intersection pt*/

            if( ii )
            {
              intpts[0][0] = poly1_pts[2*mdist_inx] * (1.0 - min_par)+
                                       poly1_pts[2*mdist_inx+2] * min_par ; 
              intpts[0][1] = poly1_pts[2*mdist_inx+1]*(1.0 - min_par)+
                                       poly1_pts[2*mdist_inx+3] * min_par ;

              poly2_pts[2 *jj*(num2_pts-1)]  = intpts[0][0];
              poly2_pts[2*jj*(num2_pts-1)+1] = intpts[0][1]; 

              intedpar1->intloc   = EMScvint_unknown;
              intedpar1->edgepar.span_inx = mdist_inx;
              intedpar1->edgepar.param = min_par;
              
              intedpar2->intloc   = jj ? EMScvint_rtend : EMScvint_lfend;
              intedpar2->edgepar.span_inx = jj ? (num2_pts - 2) : 0; 
              intedpar2->edgepar.param = jj ? 1.0 : 0.0; 
            }
            else
            {
              intpts[0][0] = poly2_pts[2*mdist_inx] * (1.0 - min_par)+
                                       poly2_pts[2*mdist_inx+2] * min_par ; 
              intpts[0][1]  = poly2_pts[2*mdist_inx+1]*(1.0 - min_par)+
                                       poly2_pts[2*mdist_inx+3] * min_par ;

              poly1_pts[2 *jj*(num1_pts-1)] = intpts[0][0]; 
              poly1_pts[2*jj*(num1_pts-1)+1] = intpts[0][1]; 

              intedpar1->intloc   = jj ? EMScvint_rtend : EMScvint_lfend;
              intedpar1->edgepar.span_inx = jj ? (num1_pts - 2) : 0;
              intedpar1->edgepar.param = jj ? 1.0 : 0.0;

              intedpar2->intloc   = EMScvint_unknown;
              intedpar2->edgepar.span_inx = mdist_inx;
              intedpar2->edgepar.param = min_par;
            }

            intedpar1->point[0] = intedpar2->point[0] = intpts[0][0];
            intedpar1->point[1] = intedpar2->point[1] = intpts[0][1];

           break;
          }
         }
        if(sts) break;
       }
     }

     if( !sts ) goto wrapup;

     if( intedpar1->intloc == EMScvint_unknown )
     {
      intedpar1->intloc  = EMScvint_middle;

      if( intedpar1->edgepar.span_inx == 0 || 
                      intedpar1->edgepar.span_inx == (num1_pts - 2) )
      {
         if( num1_pts == 2 )
          polypts = intedpar1->edgepar.param > 0.5?xyz_endpts[1]:xyz_endpts[0];
         else
          polypts = intedpar1->edgepar.span_inx ? xyz_endpts[1]:xyz_endpts[0];

         min_dist = BSdistptpt(&msg, polypts, base_pt);

         if( min_dist < 2 * cht_tol)
           if( num2_pts == 2 )
            intedpar1->intloc = (intedpar1->edgepar.param > 0.5) 
                                       ? EMScvint_rtend : EMScvint_lfend;
            else
            intedpar1->intloc = intedpar1->edgepar.span_inx ? EMScvint_rtend
                                                            : EMScvint_lfend ;
      }
     } 

     if( intedpar2->intloc == EMScvint_unknown )
     {
       intedpar2->intloc  = EMScvint_middle;

       if( intedpar2->edgepar.span_inx == 0 ||
                      intedpar2->edgepar.span_inx == (num2_pts - 2) )
       {
         if( num2_pts == 2 )
          polypts = intedpar2->edgepar.param > 0.5?xyz_endpts[3]:xyz_endpts[2];
         else
          polypts = intedpar2->edgepar.span_inx ? xyz_endpts[3]:xyz_endpts[2];

         min_dist = BSdistptpt(&msg,polypts,base_pt);

         if( min_dist < 2 * cht_tol)
           if( num2_pts == 2 )
            intedpar2->intloc = (intedpar2->edgepar.param > 0.5) 
                                       ? EMScvint_rtend : EMScvint_lfend;
            else
            intedpar2->intloc = intedpar2->edgepar.span_inx ? EMScvint_rtend
                                                            : EMScvint_lfend ;
       }
     }

    if( xyz_pt && sts) OM_BLOCK_MOVE(base_pt, xyz_pt, sizeof(IGRpoint));

wrapup:

   EMWRAPUP( *EMmsg, om_stat, "EFinteresect_intobjs");

  return(sts);
}
end implementation Root;
