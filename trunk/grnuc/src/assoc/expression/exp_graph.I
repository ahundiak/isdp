class implementation expression;

#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmsg.h"
#define AS_DEBUG

method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
*msg = MSSUCC;
return(OM_S_SUCCESS);
}

method GRaddwrng(IGRlong *msg; struct GRmd_env *md_env)
{
  *msg = MSSUCC;
  return(OM_S_SUCCESS);
}



method GRremwrng(IGRlong *msg;struct  GRmd_env *md_env)
 {
*msg = MSSUCC;
  return(OM_S_SUCCESS);
 }

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
     	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 int status;
 IGRshort my_props;
 *msg = MSFAIL;
 
 my_props = me->properties;
 me->properties = me->properties & (~GR_RIGID_RELATIONSHIP) | GRIS_NEW;

 status = om$construct_and_copy(object = me,
				osnum  = new_dsenv->md_id.osnum,
				p_objid = newobjid);
 me->properties = my_props;
 as$status(action = RET_STATUS);
 /*"--> %d\n",*newobjid */
 *msg = MSSUCC;
 return(status);
}

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; struct IGRline *line;
        IGRpoint ln_pt,proj_pt; IGRdouble *t;
        struct GRparms *proj_parms)
{*msg = MSSUCC;return(OM_S_SUCCESS);}


method GRxform( IGRlong *msg; struct GRmd_env *md_env;
                IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{*msg = MSSUCC;return(OM_S_SUCCESS);}


method GRdelete( IGRlong *msg; struct GRmd_env *md_env)
{
 IGRlong status;
 struct GRid  my_grid;
 short action;
 IGRint mod_batch;
 short mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
 extern IGRboolean ASbroadcast_in_progress;

 /*"mod %d, %d matrix %d\n",md_env->md_id.objid,md_env->md_id.osnum,md_env->md_env.matrix_type */

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 /* put the deleted element in the batch queue   */

if(!ASbroadcast_in_progress)
 {
    nd$wait_batch(type = GR_DELETED,
		  nb_obj = 1,
		  l_object = &my_grid);

 /*
    If batch mode is deffer, change go properties to non locatable and non
    displayable 
 */

    nd$mod_batch(request = ND_INQ,
		 p_ret_mode = &mod_batch);


    if(mod_batch == ND_DEFER)
      {
       /*| Change the properties if necessary  */
       action=0;
       status = om$send(msg      = message GRvg.GRchgprops(msg,&action,&mask),
                        targetid = my_id);
       as$status();
      }
  }
 else
  {
   status = om$send( msg = message Root.delete(1),
                   targetid = my_id);
   as$status();
  }

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message (buff=info->type,msgnumb=AS_I_Exp);
     return(OM_S_SUCCESS);
    }
end implementation expression;
