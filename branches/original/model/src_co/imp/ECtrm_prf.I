 

/*---       
  HISTORY :

    07/12/95 - Horst Bernhardt


  DISCLAIMER :

*  check for profile object and handle it 
*
*  IGRlong ECtrm_prf (IGRint              task,             - input  -
*                                                 3 = trim both elements
*                                                 1 = trim 1st only
*                                                 2 = trim 2nd only
*                     struct GRparms      *geom_parms,      - input  - 
*                     struct GRmd_env     *ori_mdenv,       - input  -
*                     struct GRid         *grid_1,          - input  - 
*                     IGRboolean          closed_1,         - input  - 
*                     struct GRid         *grid_2,          - input  -
*                                                 must be profile/comp crv type
*                     IGRboolean          closed_2,         - input  -    
*                     IGRpoint            appar,            - input  -  
*                     IGRint              *control,         - output -  
*                                          1 = 1st  element  successful trimmed
*                                          2 = 2nd  element  successful trimmed
*                                          3 = both elements successful trimmed
*                     struct GRid         *new_grid_1       - output -  
*                     struct GRid         *new_grid_2)      - output -
*                     IGRpoint            s_i_point,        - output -
*                     IGRpoint            s_E_point,        - output -
*                     struct GRid         *saved_grid_1,    - output -  
*                     struct GRid         *saved_grid_2)    - output -  
---*/

class implementation ECtrim2;

#include   "VCdef.h"               /*  test  */              

#include   <math.h>
#include   "igrtypedef.h"
#include   "OMminimum.h"
#include   "OMDB.h"
#include   "igetypedef.h"
#include   "OMlimits.h"
#include   "igr.h"
#include   "gr.h"
#include   "exdef.h"
#include   "ex.h"
#include   "exmacros.h"
#include   "igrdef.h"
#include   "OMmacros.h"
#include   "msdef.h"
#include   "msmacros.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "igrdef.h"
#include   "dpdef.h"
#include   "dpmacros.h"
#include   "igrdp.h"
#include   "godef.h"
#include   "go.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "maerr.h"
#include   "igrmacros.h" 
#include   "grmacros.h"
#include   "comiscmac.h"
#include   "dp.h"
 #include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "coimport.h"
#include   "grmessage.h"
#include   "bserr.h"
#include   "bsparameters.h"
#include   "bsconic.h"
#include   "codebug.h"
#include   "ECcmd_def.h"
#include   "SKmacros.h"
#include   "SKdef.h"
#include   "comisc.h"

#include   "grgsmacros.h"     /* gr$gsdisplay */
#include   "emserr.h"
#include   "grerr.h"
#include   "EMSmsgdef.h"
#include   "EMSutlmacros.h"   /*  get_construction_info_from_id  */

#include   "ectrm_del.h"      /*  function prototype  */
#include   "ectrm_cpb.h"      /*  function prototype  */

#include   "bscveval.h"       /*  function prototype  */
#include   "bsdotp.h"         /*  function prototype  */
#include   "bslenvec.h"       /*  function prototype  */


#define CV_START_PARAM  0.0     /*  curve start parameter  */ 
#define CV_END_PARAM    1.0     /*  curve end parameter    */
#define WRAP            CV_END_PARAM-CV_START_PARAM

#define NR_PRE_INT 2  
#define NR_PRE_OVL 2 


#define REM_R_TREE  0              /*  remove from r_tree               */
#define ADD_R_TREE -1              /*  add to r_tree                    */
#define REAL_DEL    1              /*  real delete (with members)       */
#define REM_HIGHL   2              /*  remove highlight (with members)  */


# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) > (y) ? (y) :(x))
# define ABS(x)      ((x) < 0 ? -(x) : (x))


#define VCdebug_return    1            /*  test  */


/* imported messages */
from GRvg       import GRgetsize,
                       GRgetgeom,
                       GRgeomprops;
 
from GRcurve     import GRptextend;
from GRgraphics  import GRconstruct;
from GRgraphics  import GRdisplay;
from GRgraphics  import GRdelete;
from GRgraphics  import GRptproject;             

from GRcompcurve import EMmakecomp;

from SKgeometry  import SKgetmgr;
from SKmgr       import GRremove_components;




extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_SKcompcurve_class_id;
extern GRclassid OPP_SKmgr_class_id;
extern GRclassid OPP_DMdim_class_id;
extern GRclassid OPP_DMannot_class_id;
extern GRclassid OPP_DMtxldr_class_id;
extern GRclassid OPP_SKgeometry_class_id;
extern GRclassid OPP_GR3dtext_class_id;

extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_GR3dcirarc_class_id;
extern GRclassid OPP_GR3dcircle_class_id;
extern GRclassid OPP_GR3dellarc_class_id;
extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;

extern GRclassid OPP_SKline_class_id;
extern GRclassid OPP_SKarc_class_id;
extern GRclassid OPP_SKcircle_class_id;
extern GRclassid OPP_SKbspline_class_id;
extern GRclassid OPP_SKdumpt_class_id;
extern GRclassid OPP_SKpoint_class_id;
extern GRclassid OPP_SKexplicit_class_id;

extern IGRboolean  EFisAncestryValid();





/*  check for profile object and handle it  */

IGRlong ECtrm_prf (IGRint              task,              /*  input   */
                   struct GRparms      *geom_parms,       /*  input   */
                   struct GRmd_env     *ori_mdenv,        /*  input   */
                   struct GRid         *grid_1,           /*  input   */
                   IGRboolean          closed_1,          /*  input   */
                   struct GRid         *grid_2,           /*  input   */
                   IGRboolean          closed_2,          /*  input   */
                   IGRpoint            appar,             /*  input   */  
                   IGRint              *control,          /*  output  */  
                   struct GRid         *new_grid_1,       /*  output  */ 
                   struct GRid         *new_grid_2,       /*  output  */ 
                   IGRpoint            s_i_point,         /*  output  */
                   IGRpoint            s_E_point,         /*  output  */
                   struct GRid         *saved_grid_1,     /*  output  */  
                   struct GRid         *saved_grid_2)     /*  output  */  

{

   IGRlong     msg, sts;
   IGRlong     rc;
   IGRlong     ii, jj, kk, ij;

   IGRboolean  crv1_comp;             /*  true if curve 1 is composite  */
   IGRboolean  crv2_comp;             /*  true if curve 2 is composite  */

   OMuword     trim_ele_1_classid, trim_ele_2_classid, trim_ele_w_classid;
   OMuword     cur_classid;
   OMuword     cur1_classid, cur2_classid,
               object_classid;

   IGRlong     size_t1, size_t2;
 
   IGRint      member1_cnt;
   IGRint      real_cnt1;
   IGRint      real_cnt2;
   IGRint      cur_max_loop;
   IGRint      num_segs;

   IGRdouble   tw;

   struct GRid      trim_ele_1, trim_ele_2;
   struct GRid      cur1_grid, cur2_grid;
   struct GRid      wrk_grid, act_grid, old_grid, new_grid;
   struct GRid      trim_ele_w;

   OM_S_CHANSELECT        to_ch_ptr;
   OMuint                 chan1_count, chan2_count;
   OM_S_OBJECT_LINKAGE    *chan1_list, *chan2_list;  
   OM_S_OBJECT_LINKAGE    *chanx_list;  
   OM_S_OBJECT_LINKAGE    chan0_list;  

   struct GRlc_info *buf_ptr;
   struct GRmd_env  wrk_env;

   struct GRprops   props_t1,             /*  geom properties  */
                    props_t2;             /*  geom properties  */

   struct GRparms   parm_int;

   struct IGRbsp_curve
                                          /*          om$malloc:            */
               *curve_t1_work,            /*  work t1                       */
               *curve_t2_work,            /*  work t2                       */
               *curve_t1,                 /*  work t1                       */
               *curve_t2,                 /*  work t2                       */
               *space_tr1,                /*  t1 ptr for return (work)      */
               *space_tr2,                /*  t2 ptr for return (work)      */
                                          /*          BSalloccv:            */
               *space_tx1,                /*  t1 ptr for return (work)      */
               *space_tx2,                /*  t2 ptr for return (work)      */
  
               *curve_cur;                /*  current t1/2 ptr              */

   IGRchar   *ptr;                        /*  abstract geometry pointer  */

   /* intersection region values  */
   IGRint     n_int, n_ovl,
              best1,
              best1_loop, best2_loop;

   IGRboolean out_int_alloc, out_ovl_alloc,
              intersect_found,
              closed_w;

   IGRdouble  ipar1[NR_PRE_INT], ipar2[NR_PRE_INT];
   IGRdouble  opar1[NR_PRE_OVL], opar2[NR_PRE_OVL];
   IGRpoint   int_pts[NR_PRE_INT];
   IGRpoint   ovl_pts[NR_PRE_INT];
   IGRpoint   *xint_pts, *xovl_pts;
   IGRpoint   point1;

   IGRdouble  *xipar1, *xipar2;
   IGRdouble  *xopar1, *xopar2;

   IGRdouble parm_t1, parm_t2;

   IGRdouble dist_best_sq, dist_sq,
             dist_best_all;

   IGRpoint  intersect_point_1, intersect_point_2;
   IGRpoint  Endpoint        = { 0.0, 0.0, 0.0 };
   IGRpoint  intersect_point = { 0.0, 0.0, 0.0 };
   IGRpoint  Strpoint        = { 0.0, 0.0, 0.0 };
   IGRpoint  pntxxx          = { 0.0, 0.0, 0.0 };
   IGRpoint  w_i_point       = { 0.0, 0.0, 0.0 };
   IGRpoint  w_E_point       = { 0.0, 0.0, 0.0 };

   struct GRparms  geom_parms_w;
   IGRchar         *buf_x;

   /*  comp curve reconstruct  */
   IGRlong                wrk_msg;
   struct GRmd_env        c_wrk_env;
   struct GRid            new_crv_id;

   /*  make comp curve */
   struct GRvg_construct  construct_list;

   GRobjid               compcrv_id;
   IGRint                jj_start, jj_end, indx;
   IGRlong               err_crv_num;
   IGRboolean            assoc_flag;

   struct IGRdisplay     c_wrk_dis;
   struct IGResintx      c_old_attr;

   struct GRid  trim_ele_s;

   IGRdouble      dot;
   IGRdouble      leng_e, leng_i;
   IGRdouble      dpt;
   IGRvector      vec_wrk_e;
   IGRvector      vec_wrk_i;
   IGRvector      ptdiff; 
   IGRpoint       eval_s[2], eval_e[2];
   IGRpoint       evali_1[2], evali_2[2];
   IGRdouble      eps;


   /*---  start of executable code  ---*/

   /*  make compiler happy  */
   real_cnt1 = NULL;
   best1 = NULL;
   parm_t1 = parm_t2 = NULL;
   chanx_list = NULL;

   *control = NULL;
   buf_x = NULL;
   xint_pts = xovl_pts = NULL;
   chan1_list =
   chan2_list = NULL;
   trim_ele_1 = *grid_1;
   trim_ele_2 = *grid_2;
   saved_grid_1->objid =                   /*  clear at start  */
   saved_grid_2->objid = NULL_OBJID;       /*  clear at start  */

   /*  reset curve data space pointer */
   curve_t1  = curve_t2  = 
   space_tr1 = space_tr2 = 
   space_tx1 = space_tx2 = 
   curve_t1_work = curve_t2_work = NULL;

   /*  get basis tolerance value  eps  */
   sts = BSEXTRACTPAR(&msg, BSTOLBASIS, eps);
   if (msg)  Goto (wrapup);

   /*  get trim element 1 class_id  */
   om$get_classid(objid     = grid_1->objid,
                  osnum     = grid_1->osnum,
                  p_classid = &trim_ele_1_classid);

   /*  get trim element 2 class_id  */
   om$get_classid(objid     = grid_2->objid,
                  osnum     = grid_2->osnum,
                  p_classid = &trim_ele_2_classid);

   if ( trim_ele_2_classid == OPP_GRcompcurve_class_id
     || trim_ele_2_classid == OPP_SKcompcurve_class_id
     || trim_ele_2_classid == OPP_SKmgr_class_id)       crv2_comp = TRUE;
   else                                                 crv2_comp = FALSE;

   /*  remove highlight (with members) from old  */
   if (1&task)  sts = ECtrm_del(REM_HIGHL, *grid_1, ori_mdenv);

   /*  remove highlight (with members) from old  */
   if (2&task)  sts = ECtrm_del(REM_HIGHL, *grid_2, ori_mdenv);


   if ( trim_ele_1_classid == OPP_GRcompcurve_class_id
     || trim_ele_1_classid == OPP_SKcompcurve_class_id
     || trim_ele_1_classid == OPP_SKmgr_class_id)
   {
     sts =  om$make_chanselect (channame     = "GRcmpowner.to_components",
                                p_chanselect = &to_ch_ptr);
     if (!(1&sts))  Goto (wrapup);

     chan1_count = NULL;
     sts = om$get_channel_count(osnum        = grid_1->osnum,
                                objid        = grid_1->objid,
                                p_chanselect = &to_ch_ptr,
                                count        = &chan1_count);
     if (chan1_count <= NULL)  Goto (wrapup);

     chan1_list = NULL;
     chan1_list = (OM_S_OBJECT_LINKAGE *) malloc(chan1_count * sizeof(OM_S_OBJECT_LINKAGE));
     if (!chan1_list)  Goto (wrapup);

     sts = om$get_channel_objects(osnum = grid_1->osnum,
                                  objid = grid_1->objid,
                                  p_chanselect = &to_ch_ptr,
                                  list  = chan1_list,
                                  size  = chan1_count,
                                  count = &chan1_count);
     if (!(sts&1)) Goto (wrapup);

     member1_cnt = real_cnt1 = chan1_count;

     for (ii=0; ii<chan1_count; ii++)
     {
       cur1_grid.objid = chan1_list[ii].S_objid;
       cur1_grid.osnum = chan1_list[ii].osnum;

       /*  extract element class_id  */
       sts = om$get_classid(objid     = cur1_grid.objid,
                            osnum     = cur1_grid.osnum,
                            p_classid = &cur1_classid);
       if (cur1_classid == OPP_GR3dpoint_class_id
        || cur1_classid == OPP_SKpoint_class_id   )
       {
         real_cnt1--;
       if (ii == chan1_count-1)  chan1_count--;
       }
     }    /*  for (ii=0; ii<chan1_count...  */

     crv1_comp = TRUE;
   }
   else
   {
     /*  fill 1st channel list with single element values  */
     chan1_list = &chan0_list;  
     chan1_count = 1;
     chan1_list[0].S_objid = grid_1->objid;
     chan1_list[0].osnum   = grid_1->osnum;
     crv1_comp = FALSE;
   }




   sts =  om$make_chanselect (channame     = "GRcmpowner.to_components",
                              p_chanselect = &to_ch_ptr);
   if (!(1&sts))  Goto (wrapup);

   chan2_count = NULL;
   sts = om$get_channel_count(osnum        = grid_2->osnum,
                              objid        = grid_2->objid,
                              p_chanselect = &to_ch_ptr,
                              count        = &chan2_count);

   chan2_list = NULL;
   chan2_list = (OM_S_OBJECT_LINKAGE *) malloc(chan2_count * sizeof(OM_S_OBJECT_LINKAGE));
   if (!chan2_list)  Goto (wrapup);

   sts = om$get_channel_objects(osnum        = grid_2->osnum,
                                objid        = grid_2->objid,
                                p_chanselect = &to_ch_ptr,
                                list         = chan2_list,
                                size         = chan2_count,
                                count        = &chan2_count);
   if (!(sts&1)) Goto (wrapup);

   real_cnt2 = chan2_count;

   for (ii=0; ii<chan2_count; ii++)
   {
     cur2_grid.objid = chan2_list[ii].S_objid;
     cur2_grid.osnum = chan2_list[ii].osnum;

     /*  extract element class_id  */
     sts = om$get_classid(objid     = cur2_grid.objid,
                          osnum     = cur2_grid.osnum,
                          p_classid = &cur2_classid);
     if (cur2_classid == OPP_GR3dpoint_class_id
      || cur2_classid == OPP_SKpoint_class_id   ) 
     {
       real_cnt2--;
       if (ii == chan2_count-1)  chan2_count--;
     }
   }    /*  for (ii=0; ii<chan1_count...  */



   best1_loop = -1;                  /*  preset  */
   best2_loop = -1;                  /*  preset  */
                       
   dist_best_all = GRDGNLIMITS_MAX_D * GRDGNLIMITS_MAX_D;  /*  preset for min */


   member1_cnt = chan1_count;

   /*-------------------------------------------*/
   /*------- element 1 loop --------------------*/
   /*-------------------------------------------*/ 

   for (ij=0; ij<chan1_count; ij++)
   {
     cur1_grid.objid = chan1_list[ij].S_objid;
     cur1_grid.osnum = chan1_list[ij].osnum;

     /*  extract element class_id  */
     sts = om$get_classid(objid     = cur1_grid.objid,
                          osnum     = cur1_grid.osnum,
                          p_classid = &cur1_classid);
     if (cur1_classid == OPP_GR3dpoint_class_id
      || cur1_classid == OPP_SKpoint_class_id   )   member1_cnt--;
     if (cur1_classid == OPP_GR3dpoint_class_id
      || cur1_classid == OPP_SKpoint_class_id   )   continue;  /* loop1 end  */

     /*  return all allocated curve space  */
     if (curve_t1)   {  om$dealloc(ptr = curve_t1);   curve_t1  = NULL;  }
     if (space_tr1)  {  om$dealloc(ptr = space_tr1);  space_tr1 = NULL;  }
     if (space_tx1)  {  BSfreecv(&rc, space_tx1);     space_tx1 = NULL; }

     /*  prepare element 1  data  (original and extendable)  */  
     sts = ECtrm_alc(&msg, 1, cur1_grid, &ori_mdenv->md_env,
                                         &curve_t1, &props_t1, &size_t1);
     if (!(1&(sts&msg)))  Goto (wrapup);
 
     sts = ECtrm_alc(&msg, 0, cur1_grid, &ori_mdenv->md_env,
                                            &space_tr1, &props_t1, &size_t1);
     if (!(1&(sts&msg)))  Goto (wrapup);  
     curve_t1_work = space_tr1;

     /*  end of elemenet 1 preparation  */


     /*-------------------------------------------*/
     /*------- element 2 loop --------------------*/
     /*-------------------------------------------*/ 

     for (ii=0; ii<chan2_count; ii++)
     {
       xint_pts = xovl_pts = NULL;

       cur2_grid.objid = chan2_list[ii].S_objid;
       cur2_grid.osnum = chan2_list[ii].osnum;

       /*  extract element class_id  */
       sts = om$get_classid(objid     = cur2_grid.objid,
                            osnum     = cur2_grid.osnum,
                            p_classid = &cur2_classid);

       if (cur2_classid == OPP_GR3dpoint_class_id
        || cur2_classid == OPP_SKpoint_class_id   )   continue;  /*  loop 2 end */

       /*  return all allocated curve space  */
       if (curve_t2)   {  om$dealloc(ptr = curve_t2);   curve_t2  = NULL;  }
       if (space_tr2)  {  om$dealloc(ptr = space_tr2);  space_tr2 = NULL;  }
       if (space_tx2)  {  BSfreecv(&rc, space_tx2);     space_tx2 = NULL;  }

       /*  prepare element 2  data  (original and extendable)  */  
       sts = ECtrm_alc(&msg, 1, cur2_grid, &ori_mdenv->md_env,
                                           &curve_t2, &props_t2, &size_t2);
       if (!(1&(sts&msg)))  Goto (wrapup);
 
       sts = ECtrm_alc(&msg, 0, cur2_grid, &ori_mdenv->md_env,
                                           &space_tr2, &props_t2, &size_t2);
       if (!(1&(sts&msg)))  Goto (wrapup);  
       curve_t2_work = space_tr2;


       if (  !closed_1 
        &&  ( real_cnt1 < 2  || (ij == 0  || ij == chan1_count-1)) )
       {
         props_t1.phy_closed = FALSE;                  /*... !!! ...*/
         props_t1.closed     = FALSE;                  /*... !!! ...*/

         if (cur1_classid == OPP_GR3dcirarc_class_id 
          || cur1_classid == OPP_GR3dellarc_class_id
          || cur1_classid == OPP_SKarc_class_id)
         {
           if (space_tx1)  { BSfreecv(&rc, space_tx1); space_tx1 = NULL; }
           /*   allocate arc_space 7poles/ 7weights/ 10 knots  */
           BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, 0, &space_tx1, &rc);
           if (rc)  Goto (wrapup);
           curve_t1_work = space_tx1;

           BSfullarc(&rc, curve_t1, curve_t1_work); 
           if (rc)  Goto (wrapup);
         }
       }

       if (  !closed_2 
        &&  ( real_cnt2 < 2  || (ii == 0  || ii == chan2_count-1)) )
       {
         props_t2.phy_closed = FALSE;                  /*... !!! ...*/
         props_t2.closed     = FALSE;                  /*... !!! ...*/

         if (cur2_classid == OPP_GR3dcirarc_class_id 
          || cur2_classid == OPP_GR3dellarc_class_id
          || cur2_classid == OPP_SKarc_class_id)
         { 
           if (space_tx2)  { BSfreecv(&rc, space_tx2); space_tx2 = NULL; }
           /*   allocate arc_space 7poles/ 7weights/ 10 knots  */
           BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, 0, &space_tx2, &rc);
           if (rc)  Goto (wrapup);
           curve_t2_work = space_tx2;

           BSfullarc(&rc, curve_t2, curve_t2_work); 
           if (rc)  Goto (wrapup);
         }
       }


       if ( (cur1_classid == OPP_GR3dlineseg_class_id
          || cur1_classid == OPP_SKline_class_id ) 
        &&  !closed_1 
        &&  ( real_cnt1 < 1  || (ij == 0  || ij == chan1_count-1) )  )

       {  
         props_t1.phy_closed = FALSE;                  /*... !!! ...*/
         props_t1.closed     = FALSE;                  /*... !!! ...*/

         /*  extend line 1  */
         sts = GR2bcisectutil(&msg,                         
                              &space_tr1,       /* ext array-1         */
                              &space_tr2,       /* ext array-2         */
                              geom_parms,       /* param-1             */
                              geom_parms,       /* param-2             */
                              &props_t1,        /* properties-1        */
                              &props_t2,        /* properties-2        */
                              space_tr1,        /* b-spline-1 expanded */
                              space_tr2);       /* b-spline-2 expanded */
         if (!(1&msg))   Goto (wrapup);
         curve_t1_work = space_tr1;
       }


       if ( (cur2_classid == OPP_GR3dlineseg_class_id
          || cur2_classid == OPP_SKline_class_id ) 
        &&  !closed_2 
        &&  ( real_cnt2 < 1  || ii == 0  || ii == chan2_count-1  )  )

       {  
         props_t2.phy_closed = FALSE;                  /*... !!! ...*/
         props_t2.closed     = FALSE;                  /*... !!! ...*/

         /*  extend line 2  */
         sts = GR2bcisectutil(&msg,                         
                              &space_tr1,       /* ext array-1         */
                              &space_tr2,       /* ext array-2         */
                              geom_parms,       /* param-1             */
                              geom_parms,       /* param-2             */
                              &props_t1,        /* properties-1        */
                              &props_t2,        /* properties-2        */
                              space_tr1,        /* b-spline-1 expanded */
                              space_tr2);       /* b-spline-2 expanded */
         if (!(1&msg))   Goto (wrapup);
         curve_t2_work = space_tr2;
      }


   
       /*  intersect curves  */
       BScvcvint(curve_t1_work,    /* first element to intersect */  
                 curve_t2_work,    /* second element to intersect */
                 TRUE,             /* remove duplicate intersect points */
                 NR_PRE_INT,       /* number of prealloc. intersect points */
                 NR_PRE_OVL,       /* number of prealloc. overlap points */
                 int_pts,          /* preallocated intersection points */
                 ipar1,            /* preallocated intersect par curve1 */
                 ipar2,            /* preallocated intersect par curve2 */
                 ovl_pts,          /* preallocated overlap points */
                 opar1,            /* preallocated overlap par curve1 */
                 opar2,            /* preallocated overlap par curve2 */
                 &n_int,           /* number of intersection points found */
                 &n_ovl,           /* number of overlappoints found */
                 &out_int_alloc,   /* are int points in xint_pts (TRUE) */
                 &out_ovl_alloc,   /* are overlaps in xovl_pts (TRUE) */
                 &xint_pts,        /* intersection points alloc by the math */
                 &xipar1,          /* intersection paramaters alloc by math */
                 &xipar2,          /* intersection paramaters alloc by math */
                 &xovl_pts,        /* overlap points alloc by the math */
                 &xopar1,          /* overlap paramaters alloc by math */
                 &xopar2,          /* overlap paramaters alloc by math */
                 &rc);             /* error return code */
       if (rc)  Goto (wrapup);
 
       intersect_found = (n_int > 0  ||  n_ovl > 0);
       if (intersect_found)
       {
         best1 = NULL;      
         /*  find the nearest point in intersect array */
         dist_best_sq = GRDGNLIMITS_MAX_D * GRDGNLIMITS_MAX_D;

         for (jj=0; jj<n_int; jj++)
         {
           /*  calculate squared distance to accept_point  */
           if (out_int_alloc)  sts = MA2pt2dis(&msg, xint_pts[jj], appar, &dist_sq);
           else                sts = MA2pt2dis(&msg, int_pts[jj],  appar, &dist_sq);
           if (dist_sq < dist_best_sq) { dist_best_sq = dist_sq; best1 = jj+1; }
         }

         /*  find the nearest point in overlay array */
         for (jj=0; jj<n_ovl; jj++)
         {
           /*  calculate squared distance to accept_point  */
           if (out_ovl_alloc)  sts = MA2pt2dis(&msg, xovl_pts[jj], appar, &dist_sq);
           else                sts = MA2pt2dis(&msg, ovl_pts[jj],  appar, &dist_sq);
           if (dist_sq < dist_best_sq) { dist_best_sq = dist_sq; best1 = -(jj+1); }                            
         }

         if (dist_best_sq < dist_best_all)
         { 
           dist_best_all = dist_best_sq;
           best1_loop = ij; 
           best2_loop = ii;
           wrk_grid = cur2_grid;
           /*  save point1  */
           for (jj=0; jj<3; jj++)  
           {
             if (best1 > 0) 
             {  if (out_int_alloc)  point1[jj] = xint_pts[best1-1][jj];
                else                point1[jj] =  int_pts[best1-1][jj];   }
             else
             {  if (out_ovl_alloc)  point1[jj] = xovl_pts[-best1-1][jj];
                else                point1[jj] =  ovl_pts[-best1-1][jj];  }
           }

           /*  copy parameters  */
           if (best1 > 0) 
           { if (out_int_alloc)
                   {  parm_t1 = xipar1[best1-1];  parm_t2 = xipar2[best1-1];  }
             else  {  parm_t1 =  ipar1[best1-1];  parm_t2 =  ipar2[best1-1];  }
           }
           else 
           { if (out_ovl_alloc)
                   {  parm_t1 = xopar1[-best1-1];  parm_t2 = xopar2[-best1-1];  }
             else  {  parm_t1 =  opar1[-best1-1];  parm_t2 =  opar2[-best1-1];  }
           }

         }   /*  if (dist_best_sq < dist_best_all... */

       }   /*  if (intersect_found... */

       /*  return space form extra points allocated by intersection  */
       if (xint_pts)  {  free(xint_pts); free(xipar1); free(xipar2);  } 
       if (xovl_pts)  {  free(xovl_pts); free(xopar1); free(xopar2);  }

     }   /*  for (ii=0; ii<chan2_count... */
     /*-------------------------------------------*/
     /*------- element 2 loop end ----------------*/
     /*-------------------------------------------*/ 




     /*  intersection point is ok  */
     for (jj=0; jj<3; jj++)
       intersect_point_1[jj] = intersect_point_2[jj] = point1[jj];
 
   }
   /*-------------------------------------------*/
   /*------- element 1 loop end ----------------*/
   /*-------------------------------------------*/ 





   /*------------------------------------------------------------------*/
   /*--------------  handle intersect point  --------------------------*/
   /*------------------------------------------------------------------*/

   if (best2_loop < 0) goto nix;

   sts = gr$get_module_env(msg = &msg, buffer = &wrk_env); 

   cur_max_loop = 2;

   /*  loop to trim/extend both elements  */
   for (ii=0; ii<cur_max_loop; ii++)
   {
     if (task == 1  &&  (1&ii))  continue;
     if (task == 2  && !(1&ii))  continue;

     if (! (1&ii) )                        /*  1st and 3rd  */
     {
       trim_ele_w.objid = chan1_list[best1_loop].S_objid;
       trim_ele_w.osnum = chan1_list[best1_loop].osnum;
       closed_w = closed_1;
     }
     else
     {
       trim_ele_w.objid = chan2_list[best2_loop].S_objid;
       trim_ele_w.osnum = chan2_list[best2_loop].osnum;
       closed_w = closed_2;
     }

     /*------------------------------------------------------------------*/
     /*  return all allocated curve space  (used curve 2 names)  */
     if (curve_t2)   {  om$dealloc(ptr = curve_t2);   curve_t2  = NULL;  }
     if (space_tr2)  {  om$dealloc(ptr = space_tr2);  space_tr2 = NULL;  }
     if (space_tx2)  {  BSfreecv(&rc, space_tx2);     space_tx2 = NULL; }

     /*  prepare element  data  (original and extendable)  */
  
     /*  get current trim element 2 class_id  */
     om$get_classid(objid     = trim_ele_w.objid,
                    osnum     = trim_ele_w.osnum,
                    p_classid = &trim_ele_w_classid);

     sts = ECtrm_alc(&msg, 1, trim_ele_w, &ori_mdenv->md_env,
                                           &curve_t2, &props_t2, &size_t2);
     if (!(1&(sts&msg)))  Goto (wrapup);
     curve_cur = curve_t2;     
                       
     sts = ECtrm_alc(&msg, 0, trim_ele_w, &ori_mdenv->md_env,
                                            &space_tr2, &props_t2, &size_t2);
     if (!(1&(sts&msg)))  Goto (wrapup);  
     curve_t2_work = space_tr2;

     /*  calculate pick point parameter on this element  */

     om$send(mode = OM_e_wrt_object,
             msg  = message GRgraphics.GRptproject(
                                          &msg,
                                          &ori_mdenv->md_env.matrix_type,  
                                          &ori_mdenv->md_env.matrix[0],
                                          appar, 
                                          pntxxx,
                                          &parm_int),
             senderid = NULL_OBJID,
             targetid = trim_ele_w.objid,
             targetos = trim_ele_w.osnum);
     if (!(1&msg))  Goto (wrapup);
     geom_parms_w.u = parm_int.u; 
     /*--------------------------------------------------------*/


     for (jj=0; jj<3; jj++)
       intersect_point[jj] = intersect_point_2[jj];
   

     if (closed_w) 
     {
        continue;    /*  for (ii=0; ii<cur_max_loop...  */
     }

     /*  calculate t-parameter of intersection point element  */
     om$send(mode = OM_e_wrt_object,
             msg  = message GRgraphics.GRptproject(
                               &msg,
                               &ori_mdenv->md_env.matrix_type,  
                               &ori_mdenv->md_env.matrix[0],
                               intersect_point,
                               pntxxx,
                               &parm_int),
             senderid = NULL_OBJID,
             targetid = trim_ele_w.objid,
             targetos = trim_ele_w.osnum);
     if (!(1&msg))  Goto (wrapup);


     /*  calculate extended intersection parameter  */

     /*  extract element class_id  */
     sts = om$get_classid(objid     = trim_ele_w.objid,
                          osnum     = trim_ele_w.osnum,
                          p_classid = &cur_classid);
     if (  cur_classid == OPP_GR3dlineseg_class_id
        || cur_classid == OPP_SKline_class_id ) 
     {
       leng_e = leng_i = 0.0;
       BScveval( curve_cur, 0.0, 0, eval_s, &rc);
       BScveval( curve_cur, 1.0, 0, eval_e, &rc);
       BScveval( curve_t1_work,  parm_t1, 0, evali_1, &rc);
       BScveval( curve_t2_work,  parm_t2, 0, evali_2, &rc);
       for (kk=0; kk<3; kk++)
       {
         vec_wrk_e[kk] = eval_e[0][kk]       - eval_s[0][kk];
         vec_wrk_i[kk] = intersect_point[kk] - eval_s[0][kk];
         leng_e += vec_wrk_e[kk]*vec_wrk_e[kk];
         leng_i += vec_wrk_i[kk]*vec_wrk_i[kk];
       }
       parm_int.u = sqrt(leng_i) / sqrt(leng_e);
       dot = BSdotp(&rc, vec_wrk_e, vec_wrk_i);
       if (dot < 0)   parm_int.u *= -1;


       /*  avoid zero length result  (line only)  */
       if (parm_int.u < 0.5)
            for (kk=0; kk<3; kk++)
              ptdiff[kk] = eval_s[0][kk] - intersect_point[kk];
       else
            for (kk=0; kk<3; kk++)
              ptdiff[kk] = eval_e[0][kk] - intersect_point[kk];

       dpt = BSlenvec(&rc, ptdiff);
       /*  skip this element if length will be zero  */
       if (dpt < eps)  continue;      /*  for (ii=0; ii<cur_max_loop...  */
     } 


     /*  decide side element to extend  */
     tw = -1;
     if (parm_int.u <= CV_START_PARAM)  tw = CV_START_PARAM; 
     if (parm_int.u >= CV_END_PARAM)    tw = CV_END_PARAM;  
  
      if (tw < 0)
      {    
        if (geom_parms_w.u < parm_int.u)  tw = CV_END_PARAM;
        if (geom_parms_w.u > parm_int.u)  tw = CV_START_PARAM;
        }
          if ( !(1&ii)  &&  (trim_ele_1_classid == OPP_GR3dlineseg_class_id)
           ||   (1&ii)  &&  (trim_ele_2_classid == OPP_GR3dlineseg_class_id) )
        {
        ptr = 0;
        GRabsg_test(&msg,
                    &ori_mdenv->md_env.matrix_type,        
                    ori_mdenv->md_env.matrix,                 
                    &trim_ele_w.osnum,
                    &trim_ele_w.objid,
                    &ptr);
        /*... if (!(1&msg))  goto wrapup;   no real error  */   

        if (!(1&msg) || ptr==NULL)   {  *control = 0;  goto nix;  }
      }

      if (parm_int.u<=0.00001 && curve_cur->order>2 )  
      {
        if (geom_parms_w.u > CV_END_PARAM/2)  tw = CV_END_PARAM;
        else                                  tw = CV_START_PARAM;
      }

      if (tw < 0.5)
      {
        for (jj=0; jj<3; jj++)
        {
          Endpoint[jj] = curve_cur->poles[jj];  
          Strpoint[jj] = curve_cur->poles[(curve_cur->num_poles -1)*3 + jj];
        }
        if (ii == 0)  {  jj_start = best1_loop;  jj_end = chan1_count;  }
        else          {  jj_start = best2_loop;  jj_end = chan2_count;  }
      }
      else
      {
        for (jj=0; jj<3; jj++) 
        {
          Endpoint[jj] = curve_cur->poles[(curve_cur->num_poles -1)*3 + jj];
          Strpoint[jj] = curve_cur->poles[jj];
        } 
        jj_start = 0;
        if (ii == 0)  jj_end = best1_loop + 1;
        else          jj_end = best2_loop + 1;
      }


      /* ----------- trim/extend element --------- */

      sts = MA2pt2dis(&msg, Strpoint, intersect_point, &dist_sq);
      /*  avoid result of closed curve  */
      if (dist_sq < eps  &&  n_int == 2)    
      {
        if (jj == 1)  cur_max_loop = 3;     /*  redo first element  */
        for (kk=0; kk<3; kk++)
          intersect_point_1[kk] = intersect_point_2[kk] = intersect_point[kk] 
                                                        = int_pts[2-best1][kk];                                                      
      }
 
      trim_ele_s.objid = trim_ele_w.objid;
      /*  save intersect/end point for later undo  */
      for (kk=0; kk<3; kk++)
      {
         w_i_point[kk] = intersect_point[kk];   /* pnt to extend to */
         w_E_point[kk] = Endpoint[kk];          /* new end pnt    */
      }

      if (ii == 0  && !crv1_comp)
      {
        /*  dark old element extend / clear highlight  */
        dp$display(msg  = &msg,
                   mode = GRbehe,
                   oids = &trim_ele_w); 
        if (!(1&msg))   Goto (wrapup);


        /*  save intersect/end point for later undo  */
        for (kk=0; kk<3; kk++)
        {
           s_i_point[kk] = intersect_point[kk];   /* pnt to extend to */
           s_E_point[kk] = Endpoint[kk];          /* new end pnt    */
        }
        /*  trim now the object  */

        om$send(mode = OM_e_wrt_object,
                msg  = message GRcurve.GRptextend(
                                   &msg,
                                   ori_mdenv,
                                   Endpoint,          /* pnt to extend    */  
                                   intersect_point,   /* pnt to extend to */
                                   Endpoint ),        /* new end pnt      */
                senderid = NULL_OBJID,
                targetid = trim_ele_w.objid,
                targetos = trim_ele_w.osnum);
        if (!(1&msg))   Goto (wrapup);

        /*  redraw new element    ( not done in previous call )  */
        dp$display(msg  = &msg,
                   mode = GRbd,
                   oids = &trim_ele_w); 
        if (!(1&msg))   Goto (wrapup);
 
        new_grid.objid = NULL_OBJID;               /*  set no new element  */
        new_grid.osnum = trim_ele_w.osnum;
      } 

      else

      {
        /*------------------------------------------*/
        /*--- build new comp crv by partial copy ---*/
        /*------------------------------------------*/

        buf_ptr = NULL;
        buf_ptr = (struct  GRlc_info *) malloc(MAX(chan1_count,chan2_count) *
                                                   sizeof (struct GRlc_info)); 
        if (!buf_ptr)  Goto (wrapup); 

        /*  handle each object  */     
        indx = 0;

        if (ii == 0)   {  chanx_list = chan1_list;  act_grid = *grid_1;  }
        else           {  chanx_list = chan2_list;  act_grid = *grid_2;  }



        for (jj=jj_start; jj<jj_end; jj++)
        {
          sts = om$get_classid(objid     = chanx_list[jj].S_objid,
                               osnum     = chanx_list[jj].osnum,
                               p_classid = &object_classid);
          if (!(1&sts))  Goto (wrapup);

          new_crv_id.objid = NULL_OBJID;  
          new_grid.objid   = NULL_OBJID;

          old_grid.objid = chanx_list[jj].S_objid;
          old_grid.osnum = chanx_list[jj].osnum;
          sts = ECtrm_cpb(old_grid, &new_grid);
          if (!(1&sts))  Goto (wrapup);
          if (new_grid.objid == NULL)    continue;   /*  skip point  */ 
          if (new_grid.objid == NULL_OBJID)    Goto (wrapup);

          if (chanx_list[jj].S_objid == trim_ele_s.objid)
          {

            /*  trim now the object  */
            om$send(mode = OM_e_wrt_object,
                   msg = message GRcurve.GRptextend(
                                &msg,
                                &wrk_env,
                                w_E_point,         /*  pnt to extend     */  
                                w_i_point,         /*  pnt to extend to  */
                                w_E_point ),       /*  new end pnt       */
                   senderid = NULL_OBJID,
                   targetid = new_grid.objid,
                   targetos = new_grid.osnum);
            if (!(1&msg))
            {
              /*...Goto (wrapup);   ...  dont report error  */
              goto nix; 
            }
          } 

          buf_ptr[indx].located_obj.osnum = new_grid.osnum;
          buf_ptr[indx].located_obj.objid = new_grid.objid; 
          buf_ptr[indx].module_info = wrk_env;
          indx++;
        }    /*  for (jj=jj_start; jj<jj_end...  */ 


        /*  make composite curve out of these segments (parts of curve) */

        /*  create composite curve shell  */
        /*  prepare construct  */ 
        construct_list.msg        = &wrk_msg;
        construct_list.env_info   = &c_wrk_env;
        construct_list.geometry   = NULL;       
        construct_list.display    = &c_wrk_dis;
        construct_list.class_attr = (IGRchar *) &c_old_attr; 

        sts = gr$get_module_env(msg = &msg, buffer = &c_wrk_env);
 
        EFget_construction_info_from_id(&msg,
                                        &construct_list,
                                        act_grid.objid,
                                        act_grid.osnum);
        if (! (1&msg))  Goto (wrapup);   

        sts = om$construct(classid   = OPP_GRcompcurve_class_id,
                           obj_osnum = NULL,
                           osnum     = act_grid.osnum,
                           msg       = message GRgraphics.GRconstruct
                                                            (&construct_list),
                           p_objid   = &compcrv_id);
        if (!(1 & sts & msg)) Goto (wrapup);

        num_segs = indx;
        sts = om$send(mode = OM_e_wrt_object,
                      msg  = message GRcompcurve.EMmakecomp(
                                       &msg,           /* *msg          */
                                       &c_wrk_env,     /* *myModuleInfo */
                                       num_segs,       /* num_ent       */
                                       buf_ptr,        /* *entries      */
                                       &err_crv_num),  /* *rotten_one   */
                      senderid = NULL_OBJID,
                      targetid = compcrv_id,
                      targetos = act_grid.osnum);

        if (!(1 & sts & msg))
        {
          new_grid.objid = NULL_OBJID;
          Goto (wrapup);
        }
        new_grid.objid = compcrv_id;
        new_grid.osnum = act_grid.osnum;

        gr$get_associative_flag(buffer = &assoc_flag);

        if (assoc_flag)
        {
          sts = sk$convert_to_profile(msg      = &msg,
                                      options  = SK_CONVERT_VERBOSE,
                                      geometry = new_grid,
                                      module   = &c_wrk_env, 
                                      profile  = &compcrv_id,
                                      automask = SK_AUTO_GEOMETRIC);
          if (!(1&sts))  Goto (wrapup);
          new_grid.objid = compcrv_id;
        }
        sts = ECtrm_del(REM_R_TREE, act_grid, ori_mdenv);

        if (ii == 0) *saved_grid_1 = *grid_1;        /*  used for undo  */
        else         *saved_grid_2 = *grid_2;        /*  used for undo  */

        /*  redraw new element    (not done in previous call)  */
        dp$display(msg  = &msg,
                   mode = GRbd,
                   oids = &new_grid); 
        if (!(1&msg))   Goto (wrapup);


      }     /*   if (ii == 0  &&  !crv1_comp...  */

      if (ii == 0)  *new_grid_1 = new_grid;    /*  new trimmed element  */ 
      else          *new_grid_2 = new_grid;    /*  new trimmed element  */
 
      *control = *control ^ (3&(ii+1));

    }  /*  for (ii =0; ii<cur_max_loop... */

    /*  good end  */



nix:

wrapup:

   /*  erase highlight at all  */
   if (task == 3) dp$erase_hilite(msg = &msg); 

   /*  return all allocated curve space  */
   if (curve_t1)   {  om$dealloc(ptr = curve_t1);   curve_t1  = NULL;  }
   if (curve_t2)   {  om$dealloc(ptr = curve_t2);   curve_t2  = NULL;  }
   if (space_tr1)  {  om$dealloc(ptr = space_tr1);  space_tr1 = NULL;  }
   if (space_tr2)  {  om$dealloc(ptr = space_tr2);  space_tr2 = NULL;  }

   if (space_tx1)  {  BSfreecv(&rc, space_tx1);  space_tx1 = NULL; }
   if (space_tx2)  {  BSfreecv(&rc, space_tx2);  space_tx2 = NULL; }

   if (buf_x)       free(buf_x); 
   if (chan2_list)  free(chan2_list);
   if (chanx_list)  free(chanx_list);

   return (OM_S_SUCCESS);
}




/*  check for dimension constraint object  */
/*  return value is TRUE for a dimension constraint object  */

IGRboolean ECtrm_isdim (struct GRid   grid_ele)           /*  input   */

{
  IGRlong                sts, msg;
  OM_S_CHANSELECT        to_ch_ptr;
  OM_S_OBJECT_LINKAGE    *chan_list;
  OMuint                 chan_count;
  IGRint                 ii;
  struct GRid            cur_grid;

  /* --- start of executable code --- */

  sts = om$make_chanselect (channame     = "SKmgr.to_constrs",
                            p_chanselect = &to_ch_ptr);
  if (!(1&sts))  Goto (wrapup);

  sts = om$get_channel_count(osnum        = grid_ele.osnum,
                             objid        = grid_ele.objid,
                             p_chanselect = &to_ch_ptr,
                             count        = &chan_count);

  if ((1&sts) && chan_count > NULL) 
  {
    chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
    if (!chan_list)  Goto (wrapup);

    sts = om$get_channel_objects(osnum        = grid_ele.osnum,
                                 objid        = grid_ele.objid,
                                 p_chanselect = &to_ch_ptr,
                                 list         = chan_list,
                                 size         = chan_count,
                                 count        = &chan_count);
    if (!(sts&1))  Goto (wrapup);
 
    /*  handle each object  */     
    for (ii=0; ii<chan_count; ii++)
    {
      cur_grid.objid = chan_list[ii].S_objid;
      cur_grid.osnum = chan_list[ii].osnum;

      /*  SKexplicit  */
      if (EFisAncestryValid(&msg, 
                            chan_list[ii].S_objid,
                            chan_list[ii].osnum,
                            OPP_SKexplicit_class_id, 
                            TRUE) )
      {
        free (chan_list);
        return (TRUE);
      }
    }    /*  for (ii=0; ii<...  */ 
    free (chan_list);
  }    /*   if ((1&sts) && chan_count > NULL...  */

  return (FALSE);

wrapup:
  if (chan_list)  free (chan_list);
  return (FALSE);
}


end implementation ECtrim2;
