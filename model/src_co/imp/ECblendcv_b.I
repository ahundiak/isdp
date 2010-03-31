 
/******************   CURVE BLEND    **********************/
/***********************************************************

  --- INPUT PARAMETER
    
 data for 1. curve :

 *env1		struct GRmd_env	 Module environment information for
				 getting the abstract geometry 
                                 associated with curve object with
                                 GRid cv1_GRid.
 cv1_GRid	struct GRid	 Object id and the object space number.
 cont1          IGRint           1: for tangency only
                                 2: for curvature,too
 tangent_flag1  IGRint           - : Tangent lenght determined by the function.
                                 1: ratio1 = (tangent length/distance of
                                    blend points).
                                 2: ratio1 = (tangent length/ tangent length of
                                    cv1 at blend point). 
                                 -1 , -2  corresponding cases, but output 
 *ratio1        IGRdouble        Ratio for tangent length.
 par_cv1        IGRdouble        Parameter at blend point.
 dir_cv1        IGRint           1: tangent for blend at blend point has the
                                    same direction as the derivative in resp.
                                    to the curve parameter
                                -1: opposite direction
 data for 2. curve : similar
 
 blend_order                     Order of the blend curve
                                 0 not determined by caller
                                 3...MAX_BLEND_ORDER (s. EMSblend_end_condition)
  *construct_list struct          construction information for the blend
 		 GRvg_construct  curve object

 --- OUTPUT PARAMETER

 the blend curve is constructed by om$construct but not displayed

 *ratio1                         if (tangent_flag1 <= 0)
 *ratio2                         if (tangent_flag2 <= 0)
 *blend_cv      struct GRid      id and object space number of constructed  
                                 blend curve
 *msg           IGRlong  	 completion code
				 
				 Possible completion codes:

				 MSSUCC  -  if the method was
				 	    successful in determining the
					    blend curve stucture and in
					    updating the instance data of
					    the object

				 MSFAIL  -  if the method was unsuccessful
					    in determining the blend curve
					    structure. OM_S_SUCCESS is
					    returned if there was only a 
					    failure in the math routine 
					    
        creation date  09/15/93 - GEB
   
*************************************************************************/

class implementation ECblendcv;

#include "VCdef.h"                     /*... test ...*/

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
#include "OMerrordef.h"   /* OM error definitions */
#include "msmacros.h"           
#include "emsmacros.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
/*#include "grdef.h"*/
#include "bserr.h"
#include "bsparameters.h"

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

#ifndef TRUE
#define TRUE 1
#endif


#include "EMSblend_cv.h"

#include "bsalloccv.h"         /*  proto type  */
#include "bsfreecv.h"          /*  proto type  */
#include "bscveval.h"          /*  proto type  */
#include "bsblndcrvg2.h"       /*  proto type  */

#define VCdebug_return    0                /*... test on ...*/

/* messages  */

from GRvg       import GRgetsize,
                       GRgetgeom,
                       GRconstruct; 



/**************************************************************
           The method definition (as a function)
 **************************************************************/       

   void  EMblendcv (IGRlong *msg,
                    struct GRmd_env *env1,
                    struct GRid cv1_GRid,
                    IGRint  cont1,
                    IGRint  tangent_flag1,
                    IGRdouble *ratio1,
                    IGRdouble par_cv1,
                    IGRint  dir_cv1,
                    struct GRmd_env *env2,
		    struct GRid cv2_GRid,
                    IGRint  cont2,
                    IGRint  tangent_flag2,
                    IGRdouble *ratio2,
                    IGRdouble par_cv2,
                    IGRint  dir_cv2,
                    IGRint  blend_order,
		    struct GRvg_construct *construct_list,
                    struct GRid *blend_cv)

{
   
  IGRshort  blnd_order;                 /* for allocation by BSalloccv  */
  IGRlong   blnd_num_poles;
  IGRshort  blnd_rat;
  IGRshort  blnd_num_bound;
 
  IGRdouble tolarr[3];                  /*  [0]  same point tolerance       */
                                        /*  [1]  same angle tolerance       */
                                        /*  [2]  degeneracy of derivatives  */

  IGRlong   status;			/* OM return status */
  IGRlong   rc;			        /* BS return code */
  IGRlong   num_bytes;		        /* used for allocation of memory
					   purposes */

  struct IGRbsp_curve  *cv1;            /* pointer to the abstract geometry
					   of curve object 1 */
  struct IGRbsp_curve  *cv2;            /* pointer to the abstract geometry
					   of curve object 2 */
  struct IGRbsp_curve  *blndcrv;        /* pointer to the blend curve */

  IGRdouble    blend_pt_par[2]; 
  IGRint       direction[2]; 
  IGRint       tangent_flag[2];
  IGRdouble    tangent_value[2];
  IGRint       curvature[2];  
  IGRint       info;
  
  struct EMSblend_cv_end_condition  start_cond;
  struct EMSblend_cv_end_condition  end_cond;



    

  /**********************/
  /*   Initialisation   */
  /**********************/

  *msg = BSSUCC;
  status = OM_S_SUCCESS;
  cv1 = cv2 =
  blndcrv   = NULL;

  /*  get System Tolerances  */
  BSEXTRACTPAR (&rc,BSTOLBASIS,tolarr[0]); 
  BSEXTRACTPAR (&rc,BSTOLCOLLINVEC,tolarr[1]); 
  BSEXTRACTPAR (&rc,BSTOLLENVEC,tolarr[2]); 


  /********************************************************/
  /*  Get the abstract geometry of the two curve objects  */
  /********************************************************/

  status = om$send(mode     = OM_e_wrt_object,
                   msg      = message GRvg.GRgetsize ( msg,
                                        &env1->md_env.matrix_type, 
			                env1->md_env.matrix, &num_bytes ),
                   senderid = NULL,
                   targetid = cv1_GRid.objid,
                   targetos = cv1_GRid.osnum);
  if (!(1&*msg))  Goto (wrapup);

  cv1 = (struct IGRbsp_curve *)malloc(num_bytes);
  if (!cv1)  Goto (wrapup);

  status = om$send(mode     = OM_e_wrt_object,
                   msg      = message GRvg.GRgetgeom ( msg,
			                &env1->md_env.matrix_type, 
			                env1->md_env.matrix, (IGRchar *)cv1),
                   senderid = NULL,
                   targetid = cv1_GRid.objid,
                   targetos = cv1_GRid.osnum);
  if (!(1&*msg))  Goto (wrapup);

  status = om$send(mode     = OM_e_wrt_object,
                   msg      = message GRvg.GRgetsize ( msg,
                                        &env2->md_env.matrix_type, 
			                env2->md_env.matrix, &num_bytes ),
                   senderid = NULL,
                   targetid = cv2_GRid.objid,
                   targetos = cv2_GRid.osnum);
  if (!(1&*msg))  Goto (wrapup);

  cv2 = (struct IGRbsp_curve *)malloc(num_bytes);
  if (!cv2)  Goto (wrapup);

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom ( msg,
			    &env2->md_env.matrix_type, 
			    env2->md_env.matrix, (IGRchar *)cv2),
                   senderid = NULL,
                   targetid = cv2_GRid.objid,
                   targetos = cv2_GRid.osnum);
  if (!(1&*msg))  Goto (wrapup);

  /*  allocate memory for the blend curve    */

  blnd_order     = 
  blnd_num_poles = cont1 + cont2 + 2;
  blnd_rat = 1;                                   /*  for arcs, ...  */
  blnd_num_bound = 0;
  BSalloccv (blnd_order, blnd_num_poles, blnd_rat, blnd_num_bound,
             &blndcrv, &rc);
  if ( rc != BSSUCC )  Goto (wrapup);



  /*  call the math routine  */

  /*  preset for initial values  */
  start_cond.tangent_value = -1.0;  
  start_cond.blend_pt_par  = -1.0;  
  start_cond.tangent_flag = tangent_flag1;
  if (tangent_flag1 > 0)  start_cond.tangent_value = *ratio1;
  start_cond.curve        = cv1;
  start_cond.blend_pt_par = par_cv1;
  start_cond.direction    = dir_cv1;
  start_cond.curvature    = cont1 - 1;

  /*  preset for initial values  */
  end_cond.tangent_value = -1.0;  
  end_cond.blend_pt_par  = -1.0;   
  end_cond.tangent_flag  = tangent_flag2;
  if (tangent_flag2 > 0)  end_cond.tangent_value = *ratio2;
  end_cond.curve        = cv2;
  end_cond.blend_pt_par = par_cv2;
  end_cond.direction    = dir_cv2;
  end_cond.curvature    = cont2 - 1;
  
  blend_pt_par[0]  = start_cond.blend_pt_par;
  blend_pt_par[1]  = end_cond.blend_pt_par;
  direction[0]     = start_cond.direction; 
  direction[1]     = end_cond.direction;
  tangent_flag[0]  = start_cond.tangent_flag;
  tangent_flag[1]  = end_cond.tangent_flag;
  tangent_value[0] = start_cond.tangent_value;
  tangent_value[1] = end_cond.tangent_value;
  curvature[0]     = start_cond.curvature;
  curvature[1]     = end_cond.curvature;

  BSblndcrvg2 (cv1,
               cv2,
               blend_pt_par,
               direction,
               tangent_flag,
               tangent_value,
               curvature,
               tolarr,
               blndcrv,
               &info,
               &rc);

  if (rc == BSSUCC) /* if successful in determining the blend curve structure */
  {
    /*  construct the blend curve  */
    construct_list->geometry = (IGRchar *) blndcrv;
    construct_list->newflag  = FALSE;
    blend_cv->osnum = construct_list->env_info->md_id.osnum;

    status = om$construct(classname = "GRbcsubbc",
                          msg       = message GRvg.GRconstruct(construct_list),
                          osnum     = construct_list->env_info->md_id.osnum,
                          p_objid   = &blend_cv->objid);
    if (status)  *msg = MSSUCC;
  }

  else  *msg = MSFAIL;  /* if error in determining the blend curve structure */



wrapup:
   if (!status)  *msg = MSFAIL;
   /*  Deallocate memory  */
   if (cv1) free(cv1);
   if (cv2) free(cv2);
   if (blndcrv) BSfreecv(&rc, blndcrv);
}

end implementation ECblendcv;




