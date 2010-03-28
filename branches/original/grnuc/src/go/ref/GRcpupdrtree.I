class implementation GRclippoly;

#include "grimport.h"
#include "godef.h"
#include "ref.h"
#include "refdef.h"
#include "referr.h"
#include "msdef.h"
#include "msmacros.h"
#include "OMmacros.h"

/*
   Name

       GRcpupdrtree

   Abstract

     This method will update the range of the clipping polygon in the R-tree.
     The input curve prism geometry will be posted to the curve prism
     representing the clipping polygon. If the add_rtree is TRUE then the
     clipping polygon will be added to the R-tree with the new range, else
     the clipping polygon will be deleted from the R-tree.

   Arguments
 
      IGRlong    *msg            completion code   
      IGRdouble  *range          range to be added to the R-tree
      struct IGRcv_prism *prism  curve prism geometry
      struct GRmd_env *md_env    object's module environment 
      IGRboolean  add_rtree      R-tree flag, TRUE for add to R-tree
                                 FALSE for remove from R-tree

   Return values

      -MSSUCC if successful
      -MSFAIL if failure

   History

      Gang     05/28/93    Design date.

*/

from GRmodule import GRmdaddwrng;

method GRcpupdrtree( IGRlong *msg; IGRdouble *range;
                     struct IGRcv_prism *prism; struct GRmd_env *md_env;
                     IGRboolean add_rtree) 
{
  IGRint i,sts;
  struct GRpost_info info;
  GRobjid newobjid;
  IGRchar *geometry;

    i = 0;
    sts = 0;

   /* Remove the clipping polygon from the R-tree */

    sts = om$send(msg = message GRgraphics.GRremwrng(msg,md_env),
                  targetid = my_id,
                  senderid = my_id);

    info.construct_flag = TRUE;

    geometry = (IGRchar *)&prism->curve;

    /* post the new geometry of the curve prism */

    sts = om$send(msg = message GRvg.GRpostabsg(msg, md_env,&info,
                                                geometry,&newobjid),
                  targetid = me->cv_objid,
                  targetos = md_env->md_id.osnum);

    me->height = prism->height;
    me->cv_objid = newobjid;

    for(i=0; i < 16; i++)
      {
        me->matrix[i]= prism->matrix[i];
      }
   
    /* Add the clipping polygon  to the R-tree with the new range if
       add_rtree is TRUE */

    if(add_rtree == TRUE)
     {
       sts = om$send(mode = OM_e_wrt_object,
                     msg = message GRmodule.GRmdaddwrng(msg,range,&my_id),
                     senderid = my_id,
                     targetid = md_env->md_id.objid,
                     targetos = md_env->md_id.osnum); 
     }



    return(sts);
}


end implementation GRclippoly;
