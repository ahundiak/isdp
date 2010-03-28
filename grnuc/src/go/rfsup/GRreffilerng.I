class implementation GRreffile;

#include "grimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "OMDB.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"
#include "dpcodef.h"
#include "dpcomacros.h"
#include "ref.h"
#include "refdef.h"
#include "referr.h"


struct get_rng
{
  OM_p_RTREESTAT  rt_stat;
  IGRint          *ret;
};


/*
   Name

      GRgetreffilerng

   Abstarct

      This function will return the range of the R-tree in the reference
      file.

   Arguments

      IGRlong    *msg          completion code
      struct GRmd_env *md_env  reference file module environment
      IGRdouble  *range        range of the reference file 

   Return values

     -MSSUCC  if successful
     -MSFAIL  if failure

   History

     Gang    05/28/93    Design date.
*/

from module import GRmod_passon;


IGRint GRgetreffilerng ( msg,
                         md_env,
                         range )
IGRlong *msg;            /* O return status  */
struct GRmd_env *md_env; /* I reference file module environment */
IGRdouble *range;        /* O range */
{
  IGRint          sts;
  struct get_rng  rng_arg;
  OM_S_RTREESTAT  rtree_info;
  OM_S_MESSAGE    rng_msg;
  IGRint          beg = 0;
  IGRint          fin = 0;
  IGRint          ret;

  rtree_info.request_type = RTREE_PAGE_STATUS;
  rtree_info.rtree_status.page.level_no = 0;

  rng_arg.rt_stat = &rtree_info;
  rng_arg.ret =     &ret;
  sts = OM_S_SUCCESS;

  /* get the range of the rtree in the reference file */

  sts = om$make_message(classname = "GRrtree",
                        methodname = "get_stat",
                        size = sizeof(struct get_rng),
                        p_arglist = &rng_arg,
                        p_msg = &rng_msg);

  if(sts & 1)
    {
       sts = om$send ( msg = message module.GRmod_passon(msg,&rng_msg,
                                           "module.primary",&beg,&fin),
                       senderid = NULL_OBJID,
                       targetid = md_env->md_id.objid,
                       targetos = md_env->md_id.osnum);
       if(sts & 1)
        {
          if( (ret != DB_I_EMPTYTREE) && (ret == DB_SUCCESS))
           {  
            range[0] = rtree_info.rtree_status.page.page_range.r3ddkey.xmin-1.0;

            range[1] = rtree_info.rtree_status.page.page_range.r3ddkey.ymin-1.0;

            range[2] = rtree_info.rtree_status.page.page_range.r3ddkey.zmin-1.0;

            range[3] = rtree_info.rtree_status.page.page_range.r3ddkey.xmax+1.0;

            range[4] = rtree_info.rtree_status.page.page_range.r3ddkey.ymax+1.0;

            range[5] = rtree_info.rtree_status.page.page_range.r3ddkey.zmax+1.0;

            *msg = MSSUCC;
           }
          else
           {
             *msg = MSFAIL;
           }
       }
      else
       { 
          *msg = MSFAIL;
       }

    }
   else
    {
       *msg = MSFAIL;
    }

   return(sts);
}


end implementation GRreffile;

