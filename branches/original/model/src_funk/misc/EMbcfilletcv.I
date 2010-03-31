/* ###################   APOGEE COMPILED   ################## */
class implementation GRcurve;

/*
  Arguments

    assumptions :
    - open and not closed curves
    - curves are intersecting at one point at which fillet is to be placed

  History
    sjv  09/02/88    creation
                     adapted from the function CO_ni_place_fillet 
                     written by Brad Robbins.
    dhm  03/18/88    added coded to get tangent points at the radius
                     distance along the elements.
    dhm  03/30/88    added code to delete lc_info objects and fillet
                     objects on an error.
    dhm  03/31/88    added checks for radius being too large and fillet
                     curves overlapping.
    SS   04/11/89    The characteristics of GRptalong changed (now, the 
                     curve is first extended before the measurement, hence
                     possibly yielding a point off the end-point of the curve
                     itself). This method call is now replaced by the direct
                     call to the math function BSptsdlcv().
    rlw 06/09/89     Modified such that original symbology of curves
                     is preserved.
    TAPADIA 1st Feb. 91 -  To check for collinear segments when filleting 
                        & assign a radius of 0.0.
    pp  07/05/91     Fixed a minor bug introduced by tapadia
    Sudha07/08/93    Modified for BSprototypes ansification

*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "msdef.h"
#include "EMSfillet.h"
#include "OMmacros.h"
#include "bsptsdlcv.h"
#include "bsnorvec.h"
#include "bslenvecsq.h"
#include "bsfillet.h"
#include "bscveval.h"
#include "bscrossp.h"

from GRcompcurve import EMmakecomp;

extern OMuword OPP_GRcompcurve_class_id, OPP_GR3dcirarc_class_id;

/*
 *  do_not_fillet():  returns TRUE if the two curves are tangent at
 *  the specified parms.  This is one test used to determine if a a fillet
 *  should be constructed between the curves.  If TRUE, it should not.
 */
static IGRboolean do_not_fillet( msg, 
                                 p_md_env, 
                                 p_obj1, 
                                 p_parm1, 
                                 p_obj2, 
                                 p_parm2 )
   IGRlong          *msg;
   struct GRmd_env  *p_md_env;
   GRobjid          *p_obj1;
   IGRdouble        *p_parm1;
   GRobjid          *p_obj2;
   IGRdouble        *p_parm2;
{
   IGRboolean              brc = TRUE;      /* return code          */
   IGRlong                 rc;              /* for functions called */
   IGRlong                 status;          /* for functions called */
   IGRint                  size;
   IGRdouble               cross_sq_tol, len;
   IGRdouble               tan_vec1[6], tan_vec2[6];
   IGRvector               xprod;
   struct IGRbsp_curve    *p_geom1, *p_geom2;

   /*
    * get bs geometry of curve 1 -> p_geom1 
    */
   status = om$send(msg = message GRvg.GRgetsize( &rc, 
                                                  &p_md_env->md_env.matrix_type,
                                                   p_md_env->md_env.matrix, 
                                                  (IGRlong *)&size),
                    senderid =  NULL_OBJID,
                    targetid = *p_obj1,
                    targetos =  p_md_env->md_id.osnum);
   if (!(rc & status & 1)) goto quit;

   p_geom1 = (struct IGRbsp_curve *)om$malloc(size = size );
   if (!p_geom1) 
   {
      brc = FALSE;
      goto quit;
   }

   status = om$send(msg = message GRvg.GRgetgeom( &rc,
                                                  &p_md_env->md_env.matrix_type,
                                                   p_md_env->md_env.matrix, 
                                                   (IGRchar *)p_geom1),
                    senderid =  NULL_OBJID,
                    targetid = *p_obj1,
                    targetos =  p_md_env->md_id.osnum);
   if (!(rc & status & 1)) goto quit;

   /*
    * get bs geometry of curve 2 -> p_geom2 
    */
   status = om$send(msg = message GRvg.GRgetsize( &rc, 
                                                  &p_md_env->md_env.matrix_type,
                                                   p_md_env->md_env.matrix, 
                                                  (IGRlong *)&size),
                    senderid =  NULL_OBJID,
                    targetid = *p_obj2,
                    targetos =  p_md_env->md_id.osnum);
   if (!(rc & status & 1)) goto quit;

   p_geom2 = (struct IGRbsp_curve *)om$malloc(size = size );
   if (!p_geom2) 
   {
      brc = FALSE;
      goto quit;
   }

   status = om$send(msg = message GRvg.GRgetgeom( &rc,
                                                  &p_md_env->md_env.matrix_type,
                                                   p_md_env->md_env.matrix, 
                                                   (IGRchar *)p_geom2),
                    senderid =  NULL_OBJID,
                    targetid = *p_obj2,
                    targetos =  p_md_env->md_id.osnum);
   if (!(rc & status & 1)) goto quit;
    
   BSEXTRACTPAR( &rc, BSTOLSQCOLLINVEC, cross_sq_tol);

   BScveval(p_geom1, *p_parm1, 1, (IGRpoint *)tan_vec1, &rc);
   if (rc != BSSUCC) { *msg=MSFAIL; brc=FALSE; goto quit;}

   BScveval(p_geom2, *p_parm2, 1, (IGRpoint *)tan_vec2, &rc);
   if (rc != BSSUCC) { *msg=MSFAIL; brc=FALSE; goto quit;}
   
   brc = BSnorvec( &rc, &tan_vec1[3] );
   if (brc == 0 || rc != BSSUCC) { *msg=MSFAIL; goto quit;}

   brc = BSnorvec( &rc, &tan_vec2[3] );
   if (brc == 0 || rc != BSSUCC) { *msg=MSFAIL; goto quit;}

   BScrossp(&rc, &tan_vec1[3], &tan_vec2[3], xprod);
   if (rc != BSSUCC) { *msg=MSFAIL; brc=FALSE; goto quit;}
   
   len = BSlenvecsq( &rc, xprod );
   if (rc != BSSUCC) { *msg=MSFAIL; brc=FALSE; goto quit;}
   
   *msg=1;
   brc = (len < cross_sq_tol);
quit:
   return brc;
}



IGRlong EMfilletcv(msg, p_const_list, closed_crvs, num_crvs, fil_crv_info,
                   p_compcrv_id, bad_index)
IGRlong                 *msg;
struct GRvg_construct   *p_const_list;
IGRboolean              closed_crvs;
IGRint                  num_crvs;
struct fil_crv_info_sd  *fil_crv_info;
GRobjid                 *p_compcrv_id;
IGRint                  *bad_index;

{

 struct fil_info_sd *fil_info;
 struct GRlc_info   *lc_info; /* for EMmakecomp */
 struct GRparms            start_parms, end_parms;
 struct GRid        crv_GRid1, crv_GRid2;
 struct GRmd_env    *p_md_env;
 struct IGRbsp_curve    fil_geom, *crv1, *crv2;
 struct IGResbc         fil_class_attr;
 enum EMSdatatype        dumtype;
 IGRshort                matrix_type;
 IGRint     crv_num1, crv_num2;
 IGRlong    msg_loc, status, seg_num, num_segs, err_crv_num;
 IGRdouble  fil_pars[2], fil_poles[7][3], fil_knots[10], fil_weights[7];
 IGRdouble  length1, length2, *matrix, from_par, *dir_point;
 IGRpoint   center_pt, tan_pt1, tan_pt2, fil_origin;
 GRobjid    pcrv_id, crvobj1, crvobj2;
 GRspacenum md_osnum; /* module object space number */
 IGRboolean b_status, is_errfil;
 extern IGRlong EMgetvggeom();
 struct  GRvg_construct construct_list;
 IGRint  temp_inx;
 /*
  * Initialize
  */

 *msg = MSSUCC;
 crv1 = NULL;
 crv2 = NULL;
 fil_info = NULL;
 lc_info = NULL;
 is_errfil = FALSE;
 seg_num = 0;

 p_md_env = p_const_list->env_info;
 matrix_type = p_md_env->md_env.matrix_type;
 matrix = p_md_env->md_env.matrix;

 md_osnum = p_md_env->md_id.osnum;

 crv_GRid1.osnum = md_osnum;
 crv_GRid2.osnum = md_osnum;

 start_parms.leaf_id.osnum = md_osnum;
 end_parms.leaf_id.osnum = md_osnum;

 /*
  * Allocate fil_info and fill in the structure.
  */

 fil_info = (struct fil_info_sd *) om$malloc(size = num_crvs *
                                   sizeof(struct fil_info_sd));
 EMerr_hndlr(!fil_info, *msg, MSNOMEM, wrapup);

 for (crv_num1 = 0; crv_num1 < num_crvs; crv_num1++)
 {
   fil_info[crv_num1].start_par = 0.0;
   fil_info[crv_num1].end_par = 1.0;

   status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                          &matrix_type, matrix,
                          fil_info[crv_num1].start_pt,
                          fil_info[crv_num1].end_pt),
                    senderid = NULL_OBJID,
                    targetid = fil_crv_info[crv_num1].subcrv_id,
                    targetos = md_osnum);
   EMerr_hndlr(EMSerror(msg_loc & status), *msg, MSFAIL, wrapup);

   /*
    * Fix for TR 92n1202. Code added to do a proper test for 
    * tangency (instead or coliniarity).  Curves are NOT always 
    * linear segments! Shelley Heard
    */
   if(crv_num1 < (num_crvs -1)) 
      temp_inx = crv_num1+1;
   else 	
      temp_inx = 0;

   if ( fil_crv_info[crv_num1].subcrv_id != fil_crv_info[temp_inx].subcrv_id )
   {
      b_status = do_not_fillet( &msg_loc,
                                 p_md_env,
                                &fil_crv_info[crv_num1].subcrv_id,
                                &fil_info[crv_num1].start_par,
                                &fil_crv_info[temp_inx].subcrv_id,
                                &fil_info[temp_inx].start_par );
 
      if(b_status & msg_loc & 1) 
         fil_crv_info[crv_num1].radius = 0.0; 
   }
   else
      fil_crv_info[crv_num1].radius = 0.0; 
}

 /*
  * Fillet curve elements.
  */

 fil_class_attr.is_curvedis = TRUE;
 fil_class_attr.is_polydis = FALSE;
 p_const_list->class_attr = (IGRchar *)&fil_class_attr;

 num_segs = num_crvs;
 for (crv_num1 = 0, crv_num2 = 1; crv_num1 < num_crvs; crv_num1++,
                                                       crv_num2++)
 {
   /*
    * Skip if no fillet between curves.
    */

   if (fil_crv_info[crv_num1].radius IS 0)
     continue;

   /*
    * Last & 1st curve to be filleted.
    */

   if (closed_crvs AND (crv_num2 IS num_crvs))
     crv_num2 = 0;

   /*
    * Initialize
    */

   crvobj1 = fil_crv_info[crv_num1].subcrv_id;
   crvobj2 = fil_crv_info[crv_num2].subcrv_id;

   /*
    * Check to be sure the radius isn't too big.
    */

   status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                          &matrix_type, matrix,
                          &length1),
                    senderid = NULL_OBJID,
                    targetid = crvobj1,
                    targetos = md_osnum);
   EMerr_hndlr(EMSerror(msg_loc & status), *msg, MSFAIL, wrapup);

   status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                          &matrix_type, matrix,
                          &length2),
                    senderid = NULL_OBJID,
                    targetid = crvobj2,
                    targetos = md_osnum);
   EMerr_hndlr(EMSerror(msg_loc & status), *msg, MSFAIL, wrapup);

   if ( (length1 < fil_crv_info[crv_num1].radius) ||
        (length2 < fil_crv_info[crv_num1].radius) )
   {
     *msg = EMS_RadiusTooBig;
     *bad_index = crv_num1;
     goto wrapup;
   }

   /*
    * Get the geometry of the 2 curves.
    */

   crv_GRid1.objid = crvobj1;
   status = EMgetvggeom (&msg_loc, &matrix_type, matrix, &crv_GRid1, &crv1,
             &dumtype);
   EMerr_hndlr (EMSerror (status & msg_loc), *msg, MSFAIL, wrapup);

   crv_GRid2.objid = crvobj2;
   status = EMgetvggeom (&msg_loc, &matrix_type, matrix, &crv_GRid2, &crv2,
             &dumtype);
   EMerr_hndlr (EMSerror (status & msg_loc), *msg, MSFAIL, wrapup);

   /*
    * Get the tangent points and find center point.
    */

   from_par = fil_info[crv_num1].end_par;
   dir_point = fil_info[crv_num1].start_pt;
   status = BSptsdlcv (&msg_loc, crv1, &from_par, dir_point,
             &fil_crv_info[crv_num1].radius, tan_pt1);
   EMerr_hndlr (!status || msg_loc != BSSUCC, *msg, MSFAIL, wrapup);

   from_par = fil_info[crv_num2].start_par;
   dir_point = fil_info[crv_num2].end_pt;
   status = BSptsdlcv (&msg_loc, crv2, &from_par, dir_point,
             &fil_crv_info[crv_num1].radius, tan_pt2);
   EMerr_hndlr (!status || msg_loc != BSSUCC, *msg, MSFAIL, wrapup);

   center_pt[0] = (tan_pt1[0] + tan_pt2[0]) / 2;
   center_pt[1] = (tan_pt1[1] + tan_pt2[1]) / 2;
   center_pt[2] = (tan_pt1[2] + tan_pt2[2]) / 2;
        
   /*
    * Call the math routine.  On error, set bad_index.
    */

   fil_geom.poles = (IGRdouble *)&fil_poles[0][0]; 
   fil_geom.knots = (IGRdouble *)&fil_knots[0];
   fil_geom.weights = (IGRdouble *)&fil_weights[0]; 

   b_status = BSfillet(&msg_loc, crv1, crv2, tan_pt1, tan_pt2, center_pt,
                       &fil_crv_info[crv_num1].radius,
                       &fil_geom, fil_origin, fil_pars);
   if (msg_loc ISNT BSSUCC)
   {
     *msg = EMS_ErrorFillet;
     *bad_index = crv_num1;
     goto wrapup;
   }

   /*
    * Need to check for overlaps between each consecutive
    * pair.
    */

   if (fil_pars[0] <= fil_info[crv_num1].start_par)
   {
     *msg = EMS_OverlapCurves;
     *bad_index = crv_num1;
     goto wrapup;
   }
   else if (crv_num2 == 0)  /* closed curve, at last pair */
   {
     if (fil_pars[1] >= fil_info[crv_num2].end_par)
     {
       *msg = EMS_OverlapCurves;
       *bad_index = crv_num1;
       goto wrapup;
     }
   }

   /*
    * Construct circular fillet curve.
    * Fillup class attributes for fillet, display element only
    */

   p_const_list->geometry = (IGRchar *)&fil_geom;
   status = om$construct(classid = OPP_GR3dcirarc_class_id,
                         obj_osnum = NULL,
                         osnum = p_md_env->md_id.osnum,
                         p_objid = &fil_crv_info[crv_num1].fil_id,
                         msg = message GRgraphics.GRconstruct(
                               p_const_list));
   if (EMSerror (status))
     goto wrapup;

   /*
    * Update u parameter value for curve 1 & curve 2
    */

   fil_info[crv_num1].end_par = fil_pars[0];
   fil_info[crv_num2].start_par = fil_pars[1];

   ++num_segs;

   if (crv1)  om$dealloc(ptr = crv1);
   crv1 = NULL;
   if (crv2)  om$dealloc(ptr = crv2);
   crv2 = NULL;

 };  /* end for loop */

 /*
  * Allocate lc_info.
  */

 lc_info = (struct GRlc_info *) om$malloc(size = num_segs * 
                                sizeof(struct GRlc_info));
 EMerr_hndlr(!lc_info, *msg, MSNOMEM, wrapup);

 /*
  * Extract part of curve from the curves and prepare info
  * for EMmakecomp.
  */

 crv_num1 = 0;

 p_const_list->class_attr = NULL;
 p_const_list->geometry = NULL;
 construct_list = *p_const_list;
 construct_list.display = NULL;
 while (seg_num < num_segs)
 {
   start_parms.u = fil_info[crv_num1].start_par;
   start_parms.leaf_id.objid = fil_crv_info[crv_num1].subcrv_id;

   end_parms.u = fil_info[crv_num1].end_par;
   end_parms.leaf_id.objid = fil_crv_info[crv_num1].subcrv_id;
   status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                          &matrix_type, matrix,
                          &construct_list, &start_parms, NULL, &end_parms,
                          &pcrv_id),
                    senderid = NULL_OBJID,
                    targetid = fil_crv_info[crv_num1].subcrv_id,
                    targetos = md_osnum );
   EMerr_hndlr(EMSerror(msg_loc & status), *msg, MSFAIL, wrapup);

   /* fill lc_info with part of curve & fillet arc */
   lc_info[seg_num].located_obj.objid = pcrv_id;
   lc_info[seg_num].located_obj.osnum = md_osnum;
   lc_info[seg_num].module_info = *p_md_env;
   ++seg_num;

   if (fil_crv_info[crv_num1].fil_id)
   {
     lc_info[seg_num].located_obj.objid = fil_crv_info[crv_num1].fil_id;
     lc_info[seg_num].located_obj.osnum = md_osnum;
     lc_info[seg_num].module_info = *p_md_env;
     ++seg_num;
   };

   ++crv_num1;

 };  /* end while */

 /*
  * Create composite curve shell if there is not one 
  * already and make the composite.
  */

 if ( (*p_compcrv_id) == NULL_OBJID )
 {
   status = om$construct(classid = OPP_GRcompcurve_class_id,
                         osnum = md_osnum,
                         p_objid = p_compcrv_id,
                         msg = message GRgraphics.GRconstruct(
                               p_const_list));
   if (EMSerror (status))
     goto wrapup;
 }

 status = om$send(msg = message GRcompcurve.EMmakecomp(&msg_loc,
                        p_md_env, num_segs, lc_info, &err_crv_num),
                  senderid = NULL_OBJID,
                  targetid = *p_compcrv_id,
                  targetos = md_osnum);
 EMerr_hndlr(EMSerror(msg_loc & status), *msg, MSFAIL, wrapup);

 
wrapup:
 if (NOT(1 & *msg) )
   status = OM_E_ABORT;
 else
 {
   if ( (*msg == EMS_ErrorFillet) || (*msg == EMS_RadiusTooBig) ||
        (*msg == EMS_OverlapCurves) )
   {
      is_errfil = TRUE;
      status = OM_S_SUCCESS;
   }
 }

 if ( !(1&status) || (is_errfil) )
 {
   IGRlong   sts;
   for (crv_num1 = 0; crv_num1 < seg_num; crv_num1++)
   {
     sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                         p_md_env),
                   senderid = NULL_OBJID,
                   targetid = lc_info[crv_num1].located_obj.objid,
                   targetos = lc_info[crv_num1].located_obj.osnum);
     EMerr_hndlr_action(EMis_error(msg_loc), *msg, msg_loc, ;);
   }

   for (crv_num1 = 0; crv_num1 < num_crvs; crv_num1++)
   {
     if (fil_crv_info[crv_num1].fil_id)
     {
       sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                           p_md_env),
                     senderid = NULL_OBJID,
                     targetid = fil_crv_info[crv_num1].fil_id,
                     targetos = md_osnum);
       if ( (sts == OM_E_NOSUCHOBJ) || (sts == OM_W_UNKNOWN_MSG) )
       {
         fil_crv_info[crv_num1].fil_id = NULL;
         continue;
       }
       EMerr_hndlr_action(EMis_error(msg_loc), *msg, msg_loc, ;);
       fil_crv_info[crv_num1].fil_id = NULL;
     }
   }

 }  /* end if ( !(1&status) || (is_errfil) ) */


 if (fil_info)  om$dealloc(ptr = fil_info);
 if (lc_info)   om$dealloc(ptr = lc_info);
 if (crv1)      om$dealloc(ptr = crv1);
 if (crv2)      om$dealloc(ptr = crv2);

 return(status);

}


end implementation GRcurve;
