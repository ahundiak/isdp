

/*---       
  HISTORY :

    07/12/95 - Horst Bernhardt


  DISCLAIMER :

*  check for Smart Sketch object and replace it by basic data object 
*
*  IGRlong ECtrm_SK (struct GRid old_grid,           - input  -  
*                    struct GRid *new_grid,          - output - 
*                                             is basic geom or comp_crv 
*                    IGRint      *member_cnt,        - output - 
*                    IGRboolean  *crv_closed,        - output - 
*                    struct GRid *main_obj )         - output -
*                                     if old_grid == comp and only one real
*                                     member, this contains the real member
---*/

class implementation ECtrim1;

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

#include   "grgsmacros.h"     /* gr$gsdisplay */
#include   "emserr.h"
#include   "EMSmsgdef.h"
#include   "EMSutlmacros.h"   /*  get_construction_info_from_id  */





# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) > (y) ? (y) :(x))
# define ABS(x)      ((x) < 0 ? -(x) : (x))

#define VCdebug_return    1            /*  test  */


/* imported messages */
from GRvg       import GRgetsize,
                       GRgetgeom,
                       GRgeomprops; 

from GRgraphics import GRconstruct;






extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_SKmgr_class_id;
extern GRclassid OPP_DMdim_class_id;
extern GRclassid OPP_DMannot_class_id;
extern GRclassid OPP_DMtxldr_class_id;
extern GRclassid OPP_SKgeometry_class_id;
extern GRclassid OPP_SKcompcurve_class_id;
extern GRclassid OPP_GR3dtext_class_id;

extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_GR3dcirarc_class_id;
extern GRclassid OPP_GR3dcircle_class_id;
extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GRbspline_class_id;

extern GRclassid OPP_SKline_class_id;
extern GRclassid OPP_SKarc_class_id;
extern GRclassid OPP_SKcircle_class_id;
extern GRclassid OPP_SKbspline_class_id;
extern GRclassid OPP_SKdumpt_class_id;
extern GRclassid OPP_SKpoint_class_id;

extern IGRboolean  EFisAncestryValid();








/*  check for Smart Sketch object and replace it by basic data object  */

IGRlong ECtrm_SK (struct GRid old_grid,           /*  input   */
                  struct GRid *new_grid,          /*  output  */ 
                  IGRint      *member_cnt,        /*  output  */ 
                  IGRboolean  *crv_closed,        /*  output  */
                  struct GRid *main_obj)          /*  output  */
{

   IGRlong                msg;
   IGRlong                wrk_msg;
   IGRlong                num_bytes, sts;

   IGRint                 ii;

   OMuword                wrk_classid, n_cl_id; 
   OMuword                cur_classid, init_classid; 
 
   OM_S_CHANSELECT        to_ch_ptr;
   OMuint                 chan_count = 0;
   OM_S_OBJECT_LINKAGE    *chan_list;  

   IGRchar                *buf_x;

   struct GRid            skgrid;
   struct GRid            wrk_grid; 
   struct GRid            comp_id;
   struct GRid            member_grid;

   struct GRmd_env        wrk_env;
   struct GRvg_construct  wrk_cnst;
   struct IGRdisplay      wrk_dis;
   struct IGResintx       old_attr;
   struct GRprops         geomprops;




   /*---  start of executable code  ---*/

   buf_x     = NULL;
   chan_list = NULL;

   *member_cnt = NULL;
   wrk_grid = old_grid;
   *new_grid = old_grid;
   main_obj->objid = NULL_OBJID;

   sts = gr$get_module_env(msg = &msg, buffer = &wrk_env);

   /*  get element class_id  */
   sts = om$get_classid(objid     = wrk_grid.objid,
                        osnum     = wrk_grid.osnum,
                        p_classid = &wrk_classid); 
   init_classid = wrk_classid;

   if ( wrk_classid == OPP_SKdumpt_class_id
     || wrk_classid == OPP_SKpoint_class_id
     || wrk_classid == OPP_GR3dpoint_class_id )
    { 
     new_grid->objid = NULL_OBJID;
     goto good_end;
   }



  comp_id.objid = NULL_OBJID;

  sts =  om$make_chanselect (channame     = "GRconnector.to_owners",
                              p_chanselect = &to_ch_ptr);
  if (1&sts)
  {
    chan_count = NULL;
    sts = om$get_channel_count(osnum        = wrk_grid.osnum,
                               objid        = wrk_grid.objid,
                               p_chanselect = &to_ch_ptr,
                               count        = &chan_count);

    if (chan_count > NULL) 
    {
      chan_list = NULL;
      chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
      if (!chan_list)  Goto (wrapup);
      sts = om$get_channel_objects(osnum = wrk_grid.osnum,
                                   objid = wrk_grid.objid,
                                   p_chanselect = &to_ch_ptr,
                                   list  = chan_list,
                                   size  = chan_count,
                                   count = &chan_count);
      if (!(sts&1)) Goto (wrapup);

      for (ii=0; ii<chan_count; ii++)
      {
        /*  extract element class_id  */
        sts = om$get_classid(objid     = chan_list[ii].S_objid,
                             osnum     = chan_list[ii].osnum,
                             p_classid = &cur_classid);  

        if ( cur_classid == OPP_SKcompcurve_class_id
          || cur_classid == OPP_SKmgr_class_id
          || cur_classid == OPP_GRcompcurve_class_id
                                                  )
        {
          comp_id.objid = chan_list[ii].S_objid;
          comp_id.osnum = chan_list[ii].osnum;
          *main_obj = comp_id;
        }
      }
      if (chan_list)  free(chan_list);   /*  release temporary space  */

    }        /*  if (chan_count >  */  
  

    if ( comp_id.objid != NULL_OBJID)
    {
      sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
                               p_chanselect = &to_ch_ptr);
      if (1&sts)
      {
        chan_count = NULL;
        sts = om$get_channel_count(osnum        = comp_id.osnum,
                                   objid        = comp_id.objid,
                                   p_chanselect = &to_ch_ptr,
                                   count        = &chan_count);

        if (chan_count > NULL) 
        {
          *member_cnt = chan_count;

          wrk_grid = comp_id;
          new_grid->objid = comp_id.objid;

          chan_list = NULL;
          chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
          if (!chan_list)  Goto (wrapup);
          sts = om$get_channel_objects(osnum = comp_id.osnum,
                                       objid = comp_id.objid,
                                       p_chanselect = &to_ch_ptr,
                                       list  = chan_list,
                                       size  = chan_count,
                                       count = &chan_count);
          if (!(sts&1)) Goto (wrapup);

          for (ii=0; ii<chan_count; ii++)
          {
            /*  extract element class_id  */
            sts = om$get_classid(objid     = chan_list[ii].S_objid,
                                 osnum     = chan_list[ii].osnum,
                                 p_classid = &cur_classid);  
            /*  dont count point ( = arc/circle center )  */
            if (cur_classid == OPP_GR3dpoint_class_id)   *member_cnt--;
            else 
            {  
              member_grid.objid = chan_list[ii].S_objid;
              member_grid.osnum = chan_list[ii].osnum; 
            }
          }
          if (chan_list)  free(chan_list);   /*  release temporary space  */

        }        /*  if (chan_count >...  */  
      }       /*  if (1&sts...  */ 
      if (main_obj->objid == old_grid.objid && *member_cnt == 1)
      {
        *main_obj = member_grid; 
      }
       
    }       /*  if ( comp_id.objid != NULL_...  */
  }       /*  if (1&sts...  */

  else

  {
    /*  decide simple type  */
    n_cl_id = wrk_classid;
    if (wrk_classid == OPP_SKline_class_id)    n_cl_id = OPP_GR3dlineseg_class_id;
    if (wrk_classid == OPP_SKarc_class_id)     n_cl_id = OPP_GR3dcirarc_class_id;
    if (wrk_classid == OPP_SKcircle_class_id)  n_cl_id = OPP_GR3dcircle_class_id;
    if (wrk_classid == OPP_SKbspline_class_id) n_cl_id = OPP_GRbcsubbc_class_id;
    /*  prepare construct  */ 
    wrk_cnst.msg        = &wrk_msg;
    wrk_cnst.env_info   = &wrk_env;
    wrk_cnst.geometry   = NULL;       
    wrk_cnst.display    = &wrk_dis;
    wrk_cnst.class_attr = (IGRchar *) &old_attr; 

    EFget_construction_info_from_id(&msg,
                                    &wrk_cnst,
                                    wrk_grid.objid,
                                    wrk_grid.osnum);
    if (! (1&msg) ) Goto (wrapup);   

    /*  get existing base  */ 
    sts = om$send(mode = OM_e_wrt_object,
                  msg  = message GRvg.GRgetsize(&msg,
                                                &wrk_env.md_env.matrix_type,
                                                wrk_env.md_env.matrix,
                                                &num_bytes ),
                  senderid = NULL_OBJID,
                  targetid = wrk_grid.objid,
                targetos = wrk_grid.osnum);
    if (!(1 & sts & msg)) Goto (wrapup);

    buf_x =  malloc(num_bytes);
    if (!buf_x)  Goto (wrapup);

    sts = om$send(mode = OM_e_wrt_object,
                  msg  = message GRvg.GRgetgeom(&msg,
                                                &wrk_env.md_env.matrix_type,
                                                wrk_env.md_env.matrix,
                                                (IGRchar *) buf_x ),
                  senderid = NULL,
                  targetid = wrk_grid.objid,
                  targetos = wrk_grid.osnum);
    if (!(1 & sts & msg)) Goto (wrapup);

    wrk_cnst.geometry = buf_x;

    /*   build element and replace object pointer */
    wrk_cnst.newflag = FALSE;
    new_grid->osnum = wrk_grid.osnum;

    sts = om$construct(classid = n_cl_id,
                       osnum   = wrk_grid.osnum,
                       msg     = message GRvg.GRconstruct(&wrk_cnst),
                       p_objid = &new_grid->objid);
    if (!(sts&1)) Goto (wrapup);

    /*  get owner  */
    sts =  om$make_chanselect (channame     = "GRconnector.to_owners",
                               p_chanselect = &to_ch_ptr);
    if (!(sts&1)) Goto (wrapup);

    sts = om$get_channel_count(osnum        = wrk_grid.osnum,
                               objid        = wrk_grid.objid,
                               p_chanselect = &to_ch_ptr,
                               count        = &chan_count);
    if (!(sts&1)) Goto (wrapup);

    if (chan_count > NULL) 
    {
      chan_list = NULL;
      chan_list = (OM_S_OBJECT_LINKAGE *)
                               malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
      if (!chan_list)  Goto (wrapup);

      sts = om$get_channel_objects(osnum = wrk_grid.osnum,
                                   objid = wrk_grid.objid,
                                   p_chanselect = &to_ch_ptr,
                                   list  = chan_list,
                                   size  = chan_count,
                                   count = &chan_count);
      if (!(sts&1)) Goto (wrapup);

      for (ii=0; ii<chan_count; ii++)
      {
        om$get_classid(objid     = chan_list[ii].S_objid,
                       osnum     = chan_list[ii].osnum,
                       p_classid = &cur_classid); 
          
        if (cur_classid == OPP_SKmgr_class_id)
        {
          skgrid.objid = chan_list[ii].S_objid;
          skgrid.osnum = chan_list[ii].osnum;
          sts = GRdelete_object(&msg, NULL, &skgrid, 1);
          if (!(1&sts))   Goto (wrapup);
        }
      }      /*  for (ii=0... */

    }      /*  if (chan_count > ...   */ 
 }        /*  if (sts == OM_S...   */ 


 /* get geometric properties of the curve, to find open/closed curve */
 sts = om$send(mode = OM_e_wrt_object,
               msg  = message GRvg.GRgeomprops(&msg,
                                               &wrk_env.md_env.matrix_type,
                                               wrk_env.md_env.matrix,
                                               &geomprops),          
               senderid = NULL_OBJID,
               targetid = wrk_grid.objid,
               targetos = wrk_grid.osnum);
 if (!(1&sts))  Goto (wrapup);

 *crv_closed = geomprops.phy_closed;
 /*---------------------------   correct wrong closed info for SKarc  ---*/
 if (init_classid == OPP_SKarc_class_id && *member_cnt == 2)
 {      
   *crv_closed = FALSE;
   *member_cnt = 1;             /*  forget point  */
 }
 /*----------------------------------------------------------------------*/

 if (init_classid == OPP_SKcircle_class_id && *member_cnt == 2)
 {      
   *member_cnt = 1;             /*  forget point  */
 }
 /*-----------------------   correct wrong closed info for SKbspline  ---*/
 if (init_classid == OPP_SKbspline_class_id && *member_cnt == 3)
 {      
   *crv_closed = FALSE;
   *member_cnt = 1;            /*  forget points  */
 }
 /*----------------------------------------------------------------------*/

/*  good end  */
good_end:
wrapup:
   if (buf_x)      free(buf_x);
   if (chan_list)  free(chan_list);

   return (OM_S_SUCCESS);
}


end implementation ECtrim1;
