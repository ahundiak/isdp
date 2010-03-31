 

/*---       
  HISTORY :

    09/07/95 - Horst Bernhardt


  DISCLAIMER :

*  make 'basic geometry copy' of SK element  
*
*  IGRlong ECtrm_prf (struct GRid         old_grid,       - input  - 
*                     struct GRid         *new_grid)      - output -
*                                                 objid = NULL_OBJID = error   
*                                                 objid = NULL = POINT  
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



# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) > (y) ? (y) :(x))
# define ABS(x)      ((x) < 0 ? -(x) : (x))


#define VCdebug_return    1            /*  test  */


/* imported messages */
from GRvg       import GRgetsize,
                       GRgetgeom,
                       GRgeomprops;
 
from GRgraphics  import GRconstruct;

from SKgeometry  import SKgetmgr;




extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_SKcompcurve_class_id;
extern GRclassid OPP_SKmgr_class_id;
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

extern IGRboolean  EFisAncestryValid();





/*  make 'basic geometry copy' of SK element  */

IGRlong ECtrm_cpb (struct GRid         old_grid,      /*  input   */
                   struct GRid         *new_grid)     /*  output  */
{

   IGRlong                msg, sts;

   OMuword                cur_classid;  
   OMuword                n_cl_id; 

   IGRlong                wrk_msg;
   IGRlong                num_bytes;
   IGRchar                *buf_x;

   struct GRvg_construct  wrk_cnst;
   struct IGRdisplay      wrk_dis;
   struct IGResintx       old_attr;
   struct GRmd_env        wrk_env;




   /*---  start of executable code  ---*/

   buf_x = NULL;
   new_grid->objid = NULL_OBJID;
   new_grid->osnum = old_grid.osnum;

   sts = gr$get_module_env(msg    = &msg, 
                           buffer = &wrk_env);

   sts = om$get_classid(objid     = old_grid.objid,
                       osnum     = old_grid.osnum,
                       p_classid = &cur_classid);
   if (!(1&sts))  Goto (wrapup);

   n_cl_id = cur_classid;
   sts = om$is_ancestry_valid(subclassid   = cur_classid,
                              superclassid = OPP_SKgeometry_class_id);

   if (sts == OM_S_SUCCESS)
   {
     /*  switch to basic type  */
     if (cur_classid == OPP_SKline_class_id)    n_cl_id = OPP_GR3dlineseg_class_id;
     if (cur_classid == OPP_SKarc_class_id)     n_cl_id = OPP_GR3dcirarc_class_id;
     if (cur_classid == OPP_SKcircle_class_id)  n_cl_id = OPP_GR3dcircle_class_id;
     if (cur_classid == OPP_SKbspline_class_id) n_cl_id = OPP_GRbcsubbc_class_id;

     if (n_cl_id == cur_classid  &&  n_cl_id == OPP_SKpoint_class_id)
     {
       new_grid->objid = NULL;
       goto nix;
     }
   }

   /*  prepare construct  */ 
   wrk_cnst.msg        = &wrk_msg;
   wrk_cnst.env_info   = &wrk_env;
   wrk_cnst.geometry   = NULL;       
   wrk_cnst.display    = &wrk_dis;
   wrk_cnst.class_attr = (IGRchar *) &old_attr;
 
   EFget_construction_info_from_id(&msg,
                                   &wrk_cnst,
                                   old_grid.objid,
                                   old_grid.osnum);
   if (!(1&msg))  Goto (wrapup);   

   /*  get existing base  */ 
   sts = om$send(mode = OM_e_wrt_object,
                 msg  = message GRvg.GRgetsize(&msg,
                                               &wrk_env.md_env.matrix_type,
                                               wrk_env.md_env.matrix,
                                               &num_bytes ),
                 senderid = NULL_OBJID,
                 targetid = old_grid.objid,
                 targetos = old_grid.osnum);
   if (!(1 & sts & msg)) Goto (wrapup);

   buf_x =  malloc(num_bytes);
   if (!buf_x)  Goto (wrapup);

   sts = om$send(mode = OM_e_wrt_object,
                 msg  = message GRvg.GRgetgeom(&msg,
                                               &wrk_env.md_env.matrix_type,
                                               wrk_env.md_env.matrix,
                                              (IGRchar *) buf_x ),
                 senderid = NULL,
                 targetid = old_grid.objid,
                 targetos = old_grid.osnum);
    if (!(1 & sts & msg)) Goto (wrapup);

    wrk_cnst.geometry = buf_x;

    /*  build element and replace object pointer */
    wrk_cnst.newflag = FALSE;

    sts = om$construct(classid = n_cl_id,
                       osnum   = old_grid.osnum,
                       msg     = message GRvg.GRconstruct(&wrk_cnst),
                       p_objid = &new_grid->objid);
    if (!(1 & sts)) Goto (wrapup);

nix:
wrapup:
   if (buf_x)   free(buf_x);

   return (OM_S_SUCCESS);
}


end implementation ECtrim2;
