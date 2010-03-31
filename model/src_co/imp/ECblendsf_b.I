/* ******          SURFACE BLEND       **********************
              creation date  11/16/93 - geb               
**************************************************************


  --- INPUT PARAMETER -------------------------------------------------------
    
 data for first surface :

 *env_sf1       struct GRmd_env  Module environment information for
                                 getting the abstract geometry
                                 associated with surface object with
                                 GRid sf1_GRid.
 sf1_GRid       struct GRid      Object id and the object space number.
 *env_cv1       struct GRmd_env  Module environment information for
                                 getting the abstract geometry
                                 associated with surface object with
                                 GRid cv1_GRid.
 cv1_GRid       struct GRid      Object id and the object space number.
 cv1_flag       IGRint           0: The is curve on sf1, where the blend starts
                                    is the curve with cv1_GRid
                                 1: The curve is an iso-parametric curve of
                                    sf1, 1. sf1-parameter constant.
                                            blend at v-min edge
                                 2: ...  2. sf1-parameter constant.
                                            blend at u-min edge
                                 3: The curve is an iso-parametric curve of
                                    sf1, 1. sf1-parameter constant.
                                            blend at v-max edge
                                 4: ...  2. sf1-parameter constant.
                                            blend at u-max edge
 cont1          IGRint           1: for tangency only
                                 2: for curvature,too
 approx_mode1                    approximation mode
                                 0: exact
                                 1: approximative 
 approx_fact1                    degree of approximation if approx_mode1 != 0
                                 0....1 (0 is exact)

 new_tangent_flag1[3]  IGRint    currently only [1] used
                                 <0 : Tangent lenght determined by the
                                      function.
                                 1: related to derivatives at blend curve
                                 2: relative factor to reduce/augment
                                    tangent lengths
                                 -n:  corresponding cases, but output only 
 new_ratio1[3]  IGRdouble        Ratio for tangent length.
                                 currently only [1] used

 pariso1        IGRdouble        If (cv1_flag != 0) the iso-parameter
 par_cv1[2]     IGRdouble        Start and end parameter at blend curve cv1,
                                 which is located on sf1.
 dir1_flag      IGRint           surface direction
                                 1: u-direction
                                 2: v-direction
                                 3: to opposite curve (ruled direction)
                                 4: direction dir1_vec[0] , forced
                                 5: perpendicular to cv1
                                 6: direction dir1_vec[0] , dynamic ( = 4)
                                -n: opposite direction
 dir1_vec        IGRvector[2]    Unit vector for direction at start and end
                                 if a direction is user input 
                 
 data for 2. surface ......................................................
                                 like above
 blend_order                     the blend surface order in blend direction
                                 >2 and (>3 for curvature)
                                 < cont1 + cont2 + 2
 tolarr[3]                       [0]  same point tolerance
                                 [1]  same angle tolerance
                                 [2]  degeneracy of derivatives



 *construct_list struct          construction information for the blend
                                 GRvg_construct  curve object

 --- OUTPUT PARAMETER ------------------------------------------------------

 the blend curve is constructed by om$construct but not displayed

 new_ratio1[ ]                  if (tangent_flag1[ ] <= 0)
 new_ratio2[ ]                  if (tangent_flag2[ ] <= 0)
 *blend_srf     struct GRid      id and object space number of constructed  
                                 blend surface
 *msg           IGRlong          completion code
 
                                 Possible completion codes:

                                 MSSUCC  -  if the method was
				 	    successful in determining the
					    blend curve stucture and in
					    updating the instance data of
					    the object
                                 
                                 MSFAIL  -  if the method was unsuccessful
                                            in determining the blend surface
                                            structure. OM_S_SUCCESS is 
                                            returned if there was only a 
                                            failure in the math routine    
    
**************************************************************************/


class implementation ECblendsf;



# include "VCdef.h"              /*... test  ...*/

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
#include "OMerrordef.h"   /* OM error definitions */
#include "msmacros.h"           
#include "emsmacros.h"

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif


#include "bs.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsprintbsps.h"  

# define VCdebug_return   1                 /*... test on ...*/


#define   DEG_TGA        -1
#define   DEG_TGB        -2
#define   DEG_TGAB       -3
#define   DEG_DPT        -4
#define   DEG_POLA       -5
#define   DEG_POLB       -6


#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif
  
#ifndef TRUE
#define TRUE 1
#endif

/* imported messages  */

from GRvg       import GRgetsize,
                       GRgetgeom,
                       GRconstruct; 

extern OMuword  OPP_EMAgenbs_class_id;

#include "EMSblend_sf.h"


#include "bsconstprcv.h"     /*  function prototype  */
#include "bsalloccv.h"       /*  function prototype  */
#include "bsfreecv.h"        /*  function prototype  */
#include "bsallocsf.h"       /*  function prototype  */
#include "bsfreesf.h"        /*  function prototype  */
#include "bsmkcvscp.h"       /*  function prototype  */
#include "bsblndsrfg2.h"     /*  function prototype  */
#include "bscollarsf.h"      /*  function prototype  */


/**************************************************************
           The method definition (as a function)
 **************************************************************/       

   void  EMblendsf ( IGRlong           *msg,
                     struct GRmd_env   *env_sf1,
                     struct GRid       sf1_GRid,
                     struct GRmd_env   *env_cv1,
                     struct GRid       cv1_GRid,
                     IGRint            cv1_flag,
                     IGRint            cont1,
                     IGRint            *approx_mode1,
                     IGRdouble         *approx_fact1,
                     IGRint            new_tangent_flag1[3],
                     IGRdouble         new_ratio1[3],
                     IGRdouble         pariso1,    
                     IGRdouble         par_cv1[2],      
                     IGRint            dir1_flag, 
                     IGRvector         dir1_vec[2], 
                     struct GRmd_env   *env_sf2,
                     struct GRid       sf2_GRid,
                     struct GRmd_env   *env_cv2,
                     struct GRid       cv2_GRid,
                     IGRint            cv2_flag,
                     IGRint            cont2,
                     IGRint            *approx_mode2,
                     IGRdouble         *approx_fact2,
                     IGRint            new_tangent_flag2[3],
                     IGRdouble         new_ratio2[3],
                     IGRdouble         pariso2,    
                     IGRdouble         par_cv2[2],     
                     IGRint            dir2_flag,
                     IGRvector         dir2_vec[2],                         
                     IGRshort          blend_order,
                     IGRdouble         tolarr[3],
                     struct GRvg_construct    *construct_list,
                     struct GRid       *blend_srf          )

{

  #define     ZERO  0.0
  #define     HALF  0.5
  #define     ONE   1.0


  IGRlong     status;			  /* OM return status */
  BSrc        rc;		          /* BS return code */
  IGRlong     num_bytes;	          /* used for allocation of memory
					     purposes */
  IGRint      k;                          /*  loop index  */

  IGRshort u_order, v_order;
  IGRshort num_bound;
  IGRlong  u_num_poles, v_num_poles;

  struct IGRbsp_surface  *sf1;            /* pointer to the abstract geometry
            			             of surface object 1 */
  struct IGRbsp_surface  *sf2;            /* pointer to the abstract geometry
					     of surface object 2 */
  struct IGRbsp_surface  *sf1_orig;       /* original surface data */
  struct IGRbsp_surface  *sf2_orig;       /* original surface data */
  struct IGRbsp_surface  *collar1;        /* pointer to 1. collar surface */
  struct IGRbsp_surface  *collar2;        /* pointer to 2. collar surface */
  struct IGRbsp_surface  *blndsrf;        /* pointer to the blend surface */

  struct IGRbsp_curve    *cv1;            /* pointer to the abstract geometry
					     of curve object 1 */
  struct IGRbsp_curve    *cv2;            /* pointer to the abstract geometry
					     of curve object 2 */
  struct IGRbsp_curve    *cv1_orig;       /* original curve data  */
  struct IGRbsp_curve    *cv2_orig;       /* original curve data  */
  struct IGRbsp_curve    *cv1_iso;        /* iso_curve data  */
  struct IGRbsp_curve    *cv2_iso;        /* iso_curve data  */

  struct IGRbsp_curve    *cv_wrk;         /* work pointer to curve  */


  IGRint ind_dir1, ind_dir2;
  IGRint edge1, edge2;   

  struct EMSblend_sf_end_condition  start_cond;
  struct EMSblend_sf_end_condition  end_cond;

  IGRshort   opt;
  IGRshort   curve_order;
  IGRshort   curve_num_poles;
  IGRboolean tst_plan = FALSE;
  IGRboolean first_try = TRUE;
  IGRint     saved_approx_mode1, saved_approx_mode2;
  IGRdouble  saved_approx_fact1, saved_approx_fact2;
  IGRdouble  edge_par;

  struct IGRbsp_curve *b_curves[2];    
  struct IGRbsp_curve *c_curves[2];
     
  IGRint     boundary_flag[2];
  IGRdouble  blend_pt_par[2][2];
  IGRdouble  pariso[2];
  IGRint     direction[2];
  IGRint     tangent_flag[2];
  IGRdouble  tangent_value[2];
  IGRint     curvature_flag[2];
  IGRint     approx_flag[2];
  IGRdouble  approx_fact[2];
  IGRint     inform;



  /* ---------------- */
  /*  Initialisation  */
  /* ---------------- */

  /*  make compiler happy  */
  ind_dir1 = ind_dir2 = NULL;
  saved_approx_mode1 = saved_approx_mode2 = NULL;
  saved_approx_fact1 = saved_approx_fact2 = NULL;

repeat:
  *msg = BSSUCC;
  status = OM_S_SUCCESS;

  cv1         = cv2 =       NULL;
  cv1_orig    = cv2_orig =  NULL;
  cv1_iso     = cv2_iso  =  NULL;
  c_curves[0] = c_curves[1] = NULL;

  sf1_orig = sf2_orig = 
  collar1  = collar2  =
  blndsrf  = NULL;

  edge1 = cv1_flag; 
  edge2 = cv2_flag; 

  /* ------------------------------------------------------ */
  /*  Get the abstract geometry of the two surface objects  */
  /* ------------------------------------------------------ */
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetsize ( msg,
                            &env_sf1->md_env.matrix_type, 
			    env_sf1->md_env.matrix, &num_bytes ),
                   senderid = NULL,
                   targetid = sf1_GRid.objid,
                   targetos = sf1_GRid.osnum);

  sf1 = (struct IGRbsp_surface *) malloc(num_bytes);
  if (!sf1)  Goto (wrapup);

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom ( msg,
			    &env_sf1->md_env.matrix_type, 
			    env_sf1->md_env.matrix, (IGRchar *)sf1),
                   senderid = NULL,
                   targetid = sf1_GRid.objid,
                   targetos = sf1_GRid.osnum);

  /*...printf("ECblendsf_b.I---dump sf1-orig--- \n");...*/
  /*...BSprintbsps(NULL, NULL, sf1, FALSE);...*/ 


  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetsize ( msg,
                            &env_sf2->md_env.matrix_type, 
			    env_sf2->md_env.matrix, &num_bytes ),
                   senderid = NULL,
                   targetid = sf2_GRid.objid,
                   targetos = sf2_GRid.osnum);

  sf2 = (struct IGRbsp_surface *) malloc(num_bytes);
  if (!sf2)  Goto (wrapup);

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom ( msg,
			    &env_sf2->md_env.matrix_type, 
			    env_sf2->md_env.matrix, (IGRchar *)sf2),
                   senderid = NULL,
                   targetid = sf2_GRid.objid,
                   targetos = sf2_GRid.osnum);
  /*...printf("ECblendsf_b.I---dump sf2-orig--- \n");...*/
  /*...BSprintbsps(NULL, NULL, sf1, FALSE);...*/ 

  if ( cv1_flag == 0 )
  {
    /* ------------------------------------------- */
    /*  Get the abstract geometry of the 1. curve  */
    /* ------------------------------------------- */
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsize ( msg,
                              &env_cv1->md_env.matrix_type, 
  		 	      env_cv1->md_env.matrix, &num_bytes ),
                     senderid = NULL,
                     targetid = cv1_GRid.objid,
                     targetos = cv1_GRid.osnum);

    cv1 = (struct IGRbsp_curve *)malloc(num_bytes);
    if (!cv1)  Goto (wrapup);
    cv1_orig = cv1;

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetgeom ( msg,
                              &env_cv1->md_env.matrix_type, 
			      env_cv1->md_env.matrix,
                              (IGRchar *)cv1),
                     senderid = NULL,
                     targetid = cv1_GRid.objid,
                     targetos = cv1_GRid.osnum);


    ind_dir1 = ABS(dir1_flag);
    if (ind_dir1 == 6) ind_dir1 = 4;

    ind_dir1--;
    edge1 = 2;
    pariso1 = ZERO;

    if ( cv2_flag != 0 )
    {
      /*  if no associated curve is there extract boundary edge curve  */
      /*  allocate iso_curve buffer if not yet there  */
      if (cv2_flag == 2  ||  cv2_flag == 4)
        {  curve_order = sf2->v_order; curve_num_poles = sf2->v_num_poles;  }
      else
        {  curve_order = sf2->u_order; curve_num_poles = sf2->u_num_poles;  }

      BSalloccv(curve_order, curve_num_poles, sf2->rational, NULL,
                &cv1_iso, &rc );  
      if (BSERROR(rc))  Goto (wrapup);  

      /*  extract iso parametric curves  */
      if (cv2_flag == 1)  {  opt = 2;  edge_par = 0.0; }
      if (cv2_flag == 2)  {  opt = 1;  edge_par = 0.0; }
      if (cv2_flag == 3)  {  opt = 2;  edge_par = 1.0; }
      if (cv2_flag == 4)  {  opt = 1;  edge_par = 1.0; }

      BSconstprcv(&rc, sf2, &opt, &edge_par, &tst_plan, cv1_iso);
      if (BSERROR(rc))  Goto (wrapup);  
      cv2 = cv1_iso;
            
    }
  }


  if ( cv2_flag == 0 )
  {
    /* ------------------------------------------- */
    /*  Get the abstract geometry of the 2. curve  */
    /* ------------------------------------------- */

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsize ( msg,
                              &env_cv2->md_env.matrix_type, 
                              env_cv2->md_env.matrix, &num_bytes ),
                     senderid = NULL,
                     targetid = cv2_GRid.objid,
                     targetos = cv2_GRid.osnum);

    cv2 = (struct IGRbsp_curve *)malloc(num_bytes);
    if (!cv2)  Goto (wrapup);
    cv2_orig = cv2;

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetgeom ( msg,
		   	   &env_cv2->md_env.matrix_type, 
			   env_cv2->md_env.matrix, (IGRchar *)cv2),
                     senderid = NULL,
                     targetid = cv2_GRid.objid,
                     targetos = cv2_GRid.osnum);
     

    ind_dir2 = ABS(dir2_flag);
    if (ind_dir2 == 6) ind_dir2 = 4;
    ind_dir2--;
    edge2 = 2;
    pariso2 = ZERO;

    if ( cv1_flag != 0 )
    {
      /*  if no associated curve is there extract boundary edge curve  */
      /*  allocate iso_curve buffer if not yet there  */
      if (cv1_flag == 2  ||  cv1_flag == 4)
        {  curve_order = sf1->v_order; curve_num_poles = sf1->v_num_poles;  }
      else
        {  curve_order = sf1->u_order; curve_num_poles = sf1->u_num_poles;  }

      BSalloccv(curve_order, curve_num_poles, sf1->rational, NULL,
                &cv2_iso, &rc );  
      if (BSERROR(rc))  Goto (wrapup);  

      /*  extract iso parametric curves  */
      if (cv1_flag == 1)  {  opt = 2;  edge_par = 0.0; }
      if (cv1_flag == 2)  {  opt = 1;  edge_par = 0.0; }
      if (cv1_flag == 3)  {  opt = 2;  edge_par = 1.0; }
      if (cv1_flag == 4)  {  opt = 1;  edge_par = 1.0; }

      BSconstprcv(&rc, sf1, &opt, &edge_par, &tst_plan, cv2_iso);
      if (BSERROR(rc))  Goto (wrapup);  

      cv1 = cv2_iso;    
    }
  }



  if ( cv1_flag == 0 )
  {
    /* ------------------------------ */
    /*   make the 1. collar surface   */
    /* ------------------------------ */
    /*  make curves compatible  */
    b_curves[0] = cv1;
    b_curves[1] = cv2;
    BSmkcvscp(2, b_curves, c_curves, &rc);
    if (rc != BSSUCC)  Goto (wrapup);
    if (cv1_iso)   {  BSfreecv(&rc, cv1_iso);  cv1_iso  = NULL;  }
    if (cv2_iso)   {  BSfreecv(&rc, cv2_iso);  cv1_iso  = NULL;  }
    if (cv1_orig)  {  free(cv1_orig);          cv1_orig = NULL;  }
    if (cv2_orig)  {  free(cv2_orig);          cv2_orig = NULL;  }
    cv1 = c_curves[0];
    cv2 = c_curves[1];

    /*  prepare the 1. collar surface  */
    num_bound = 0;
    u_order     = cont1 + 1;
    u_num_poles = cont1 + 1;
    v_order     = cv1->order;
    v_num_poles = cv1->num_poles;

    BSallocsf (u_order, v_order, u_num_poles, v_num_poles,
               cv1->rational, num_bound, &collar1, &rc );
    if ( rc != BSSUCC ) Goto (wrapup);

    if (ind_dir1 == 2)  cv_wrk = cv2;
    else                cv_wrk = NULL;

    BScollarsf(sf1, cv1, cont1, ind_dir1, cv_wrk,  dir1_vec[0], collar1, &rc);
    if (rc != BSSUCC)
    {
      *msg = MSFAIL;
      status = OM_E_ABORT;
      Goto (wrapup);
    }  
    if (sf1_orig)  {  free(sf1_orig);  sf1_orig = NULL;  } 
    sf1 = collar1;
  }


  if ( cv2_flag == 0 )
  {
    /* ------------------------------ */
    /*   make the 2. collar surface   */
    /* ------------------------------ */
    /*  make curves compatible  */
    b_curves[0] = cv1;
    b_curves[1] = cv2;

    BSmkcvscp(2, b_curves, c_curves, &rc);
    if (rc != BSSUCC)  Goto (wrapup);
    if (cv1_iso)   {  BSfreecv(&rc, cv1_iso);  cv1_iso  = NULL;  }
    if (cv2_iso)   {  BSfreecv(&rc, cv2_iso);  cv1_iso  = NULL;  }
    if (cv1_orig)  {  free(cv1_orig);          cv1_orig = NULL;  }
    if (cv2_orig)  {  free(cv2_orig);          cv2_orig = NULL;  }

    cv1 = c_curves[0];
    cv2 = c_curves[1];

    /*  prepare the 2. collar surface  */
    num_bound = 0;
    u_order     = cont2 + 1;
    u_num_poles = cont2 + 1;
    v_order     = cv2->order;
    v_num_poles = cv2->num_poles;

    BSallocsf (u_order, v_order, u_num_poles, v_num_poles,
               cv2->rational, num_bound, &collar2, &rc );
    if ( rc != BSSUCC ) Goto (wrapup);

    if (ind_dir2 == 2)  cv_wrk = cv1;
    else                cv_wrk = NULL;
 
    BScollarsf(sf2, cv2, cont2, ind_dir2, cv_wrk, dir2_vec[0], collar2, &rc);
    if ( rc != BSSUCC )
    {
      *msg = MSFAIL;
      status = OM_E_ABORT;
      Goto (wrapup);
    }
    if (sf2_orig)  {  free(sf2_orig);  sf2_orig = NULL;  } 
    sf2 = collar2;
  }


  /* ----------------------------------------- */
  /*  fill the start/end condition structures  */
  /* ----------------------------------------- */

  if ( pariso1 == ZERO  ||  pariso1 == ONE )
       start_cond.boundary_flag = edge1;
  else 
       start_cond.boundary_flag = edge1 + 4;

  if ( pariso2 == ZERO  ||  pariso2 == ONE )
       end_cond.boundary_flag = edge2;
  else 
       end_cond.boundary_flag = edge2 + 4;
  boundary_flag[0] = start_cond.boundary_flag;
  boundary_flag[1] = end_cond.boundary_flag;


  start_cond.surface = sf1;
  start_cond.curve   = NULL;
  for (k = 0; k < 3; k++)
  {
    start_cond.tangent_flag[k] = new_tangent_flag1[k];
    start_cond.tangent_value[k] = new_ratio1[k];
  }
  start_cond.pariso = pariso1;
  start_cond.blend_pt_par[0] = par_cv1[0];
  start_cond.blend_pt_par[1] = par_cv1[1];
  start_cond.direction = dir1_flag;
  start_cond.curvature_flag = cont1 - 1;
  start_cond.curvature_value = 1.0;
  start_cond.approx_flag = *approx_mode1;
  if (*approx_mode1 > 0) start_cond.approx_fact = *approx_fact1; 
  else                   start_cond.approx_fact = 0.0; 


  end_cond.surface = sf2;
  end_cond.curve   = NULL;
  for (k = 0; k < 3; k++)
  {
    end_cond.tangent_flag[k] = new_tangent_flag2[k];
    end_cond.tangent_value[k] = new_ratio2[k];
  }
  end_cond.pariso = pariso2;
  end_cond.blend_pt_par[0] = par_cv2[0];
  end_cond.blend_pt_par[1] = par_cv2[1];
  end_cond.direction = dir2_flag;
  end_cond.curvature_flag = cont2 - 1;
  end_cond.curvature_value = 1.0;
  end_cond.approx_flag = *approx_mode2;
  if (*approx_mode2 > 0) end_cond.approx_fact = *approx_fact2; 
  else                   end_cond.approx_fact = 0.0; 

  boundary_flag[0] = start_cond.boundary_flag;
  boundary_flag[1] = end_cond.boundary_flag;
  blend_pt_par[0][0] = start_cond.blend_pt_par[0];
  blend_pt_par[0][1] = start_cond.blend_pt_par[1];
  blend_pt_par[1][0] = end_cond.blend_pt_par[0];
  blend_pt_par[1][1] = end_cond.blend_pt_par[1];
  pariso[0] = start_cond.pariso;
  pariso[1] = end_cond.pariso;
  direction[0] = start_cond.direction;
  direction[1] = end_cond.direction;
  tangent_flag[0] = start_cond.tangent_flag[1];
  tangent_flag[1] = end_cond.tangent_flag[1];
  tangent_value[0] = start_cond.tangent_value[1];
  tangent_value[1] = end_cond.tangent_value[1];
  curvature_flag[0] = start_cond.curvature_flag;
  curvature_flag[1] = end_cond.curvature_flag;
  approx_flag[0] = start_cond.approx_flag;
  approx_flag[1] = end_cond.approx_flag;
  approx_fact[0] = start_cond.approx_fact;
  approx_fact[1] = end_cond.approx_fact;

  XBSblndsrfg2(sf1,                
              sf2,              
              boundary_flag,
              blend_pt_par,
              pariso,
              direction,
              tangent_flag,
              tangent_value,
              curvature_flag,
              approx_flag,
              approx_fact,
              (IGRint )blend_order,
              tolarr,
              &blndsrf,
              &inform,
              &rc);

  if ( rc != BSSUCC )
  {
    if (    inform == DEG_TGA  ||  inform ==  DEG_TGB  ||  inform == DEG_TGAB
        ||  inform == DEG_DPT  ||  inform == DEG_POLA  ||  inform == DEG_POLB )
    {
      if (first_try && *approx_mode1 == 0)
      {
        /*  Deallocate memory  */	
        if (blndsrf) BSfreesf(&rc, blndsrf);
        if (sf1_orig)  free(sf1_orig);
        if (sf2_orig)  free(sf2_orig);
        if (collar1) BSfreesf(&rc, collar1);
        if (collar2) BSfreesf(&rc, collar2);

        if (cv1_iso)   BSfreecv(&rc, cv1_iso);
        if (cv2_iso)   BSfreecv(&rc, cv2_iso);
        if (cv1_orig)  free(cv1_orig);
        if (cv2_orig)  free(cv2_orig);

        if (c_curves[0])  BSfreecv(&rc, c_curves[0]); 
        if (c_curves[1])  BSfreecv(&rc, c_curves[1]);

        blndsrf = NULL;

        cv1         = cv2 = 
        cv1_orig    = cv2_orig =
        cv1_iso     = cv2_iso  =
        c_curves[0] = c_curves[1] = NULL;

        sf1       = sf2 = 
        sf1_orig  = sf2_orig = 
        collar1   = collar2 = NULL;
        

        /*  try blend again with approximation on  */
        first_try = FALSE;
        saved_approx_mode1 = *approx_mode1;
        saved_approx_mode2 = *approx_mode2;
        saved_approx_fact1 = *approx_fact1;
        saved_approx_fact2 = *approx_fact2;
        *approx_mode1 = 1;
        *approx_mode2 = 1;
        *approx_fact1 = 1.0;
        *approx_fact2 = 1.0;
        goto repeat;
      }
      else
      {
        *approx_mode1 = saved_approx_mode1;
        *approx_mode2 = saved_approx_mode1;
        *approx_fact1 = saved_approx_fact1;
        *approx_fact2 = saved_approx_fact2;
      }   
    }
    *msg = MSFAIL;
    status = OM_E_ABORT;
    Goto (wrapup);
  }


  /*...printf("ECblendsf_b.I---dump blndsrf---start \n");...*/
  /*...BSprintbsps(NULL, NULL, blndsrf, FALSE);...*/  
 

  /*  restore tangent length if internal calculated  */
  /*  reserve sign to show direction change  */
  for (k = 0; k < 3; k++)
  {
    if (new_tangent_flag1[k] < 0)
    {
      new_ratio1[k] = start_cond.tangent_value[k];
      if(start_cond.direction < 0)  new_ratio1[k] *= -1.0;
    }
  }
  for (k = 0; k < 3; k++)
  {
    if (new_tangent_flag2[k] < 0) 
    {
      new_ratio2[k] = end_cond.tangent_value[k];
      if(end_cond.direction < 0)  new_ratio2[k] *= -1.0;
    }
  }
  if (rc == BSSUCC)  /* if successful in determining the blend srf struct */
  {
    /* ----------------------------- */
    /*  construct the blend surface  */
    /* ----------------------------- */	
		
    construct_list->geometry = (IGRchar *) blndsrf;
    construct_list->newflag = FALSE;
    blend_srf->osnum = construct_list->env_info->md_id.osnum;

    status = om$construct(classid = OPP_EMAgenbs_class_id,
		          osnum   = construct_list->env_info->md_id.osnum,
                          msg     = message GRvg.GRconstruct(construct_list),
                          p_objid = &blend_srf->objid);
    *msg = MSSUCC;
  }
  else             /* if unsuccessful in determining the blend srf struct */
  {
    *msg = MSFAIL;
  }
 
  /*  Deallocate memory  */
  if (blndsrf) BSfreesf(&rc, blndsrf);

  if (sf1_orig)  free(sf1_orig);
  if (sf2_orig)  free(sf2_orig);
  if (collar1) BSfreesf(&rc, collar1);
  if (collar2) BSfreesf(&rc, collar2);

    if (cv1_iso)   BSfreecv(&rc, cv1_iso);
    if (cv2_iso)   BSfreecv(&rc, cv2_iso);
    if (cv1_orig)  free(cv1_orig);
    if (cv2_orig)  free(cv2_orig);

    if (c_curves[0])  BSfreecv(&rc, c_curves[0]);
    if (c_curves[1])  BSfreecv(&rc, c_curves[1]);

  return;


wrapup:
  if ((*msg != MSSUCC) || (!status))
  if (!status) status = OM_E_ABORT;
  /*  Deallocate memory  */
  if (blndsrf) BSfreesf(&rc, blndsrf);

  if (sf1_orig)  free(sf1_orig);
  if (sf2_orig)  free(sf2_orig);
  if (collar1) BSfreesf(&rc, collar1);
  if (collar2) BSfreesf(&rc, collar2);

    if (cv1_iso)   BSfreecv(&rc, cv1_iso);
    if (cv2_iso)   BSfreecv(&rc, cv2_iso);
    if (cv1_orig)  free(cv1_orig);
    if (cv2_orig)  free(cv2_orig);

    if (c_curves[0])  BSfreecv(&rc, c_curves[0]);
    if (c_curves[1])  BSfreecv(&rc, c_curves[1]);

  return;

}

end implementation ECblendsf;
  
  
