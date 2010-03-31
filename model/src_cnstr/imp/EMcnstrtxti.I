class implementation EMScnstrtxt;

/*

 History
        Sudha   06/07/93        modified for BSprototype includes
*/

#include "dpdef.h"
#include "dp.h"
#include "emsdef.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "maidmx.h"

from EMSimpcnstr import EMgeomhandle;

method NDupdate ( int               * msg, cn_type, count;
                  struct GRid       * parents;
                  int               * parent_state;
                  struct GRid       * context, * new_objid;
                  struct GRmd_env   * md_env )
{
    IGRlong         om_msg;
    OM_S_CHANSELECT to_owner, to_comps;
    struct GRid     cnstr_id;
    OM_S_OBJID save_md_id;
    IGRshort props,action;
    struct GRsymbology symb;

    save_md_id = md_env->md_id.objid;

    EMmake_chanselect (GRconnector_to_owners, &to_owner);
    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    /*
     * Get the constraint that I represent.
     */
    om_msg = om$get_objid_at_index (object = me,
                                    p_chanselect = &to_owner,
                                    index = 0,
                                    objidaddr = &cnstr_id.objid,
                                    osnumaddr = &cnstr_id.osnum);
    if (om_msg & 1)
    {
        enum GRdpmode mode = GRbehe;

        /*
         * Erase myself.
         */
        om_msg = om$send ( msg = message GRgraphics.GRdisplay ( (long *)msg,
                                                &md_env->md_env.matrix_type,
                                                 md_env->md_env.matrix,
                                                 &mode,
                                                 &md_env->md_id ),
                           targetid = my_id );

        om_msg = om$send(msg = message GRgraphics.GRgetprops((IGRlong *) msg,
                        &props),
                 targetid = my_id);

        om_msg = om$send(msg = message GRvg.GRgetsymb ((IGRlong *) msg, &symb),
                  targetid = my_id);

        /*
         * Delete myself.
         */
        if ((cn_type & ND_COMP_NO_REM_RT) &&
            (save_md_id != NULL_OBJID))
        {
         md_env->md_id.objid = NULL_OBJID;
         om_msg = om$send ( msg = message GRgraphics.GRdelete ((IGRlong *)msg, md_env),
                           targetid = my_id );
         md_env->md_id.objid = save_md_id;
        }
        else
        {
         om_msg = om$send ( msg = message GRgraphics.GRdelete ((IGRlong *)msg, md_env),
                           targetid = my_id );
        } 


        if (om_msg & *msg & 1)
        {
            /*
             * Tell the constraint to recompute/display the geometric handle.
             */
            if ((cn_type & ND_COMP_NO_ADD_RT) &&
                (save_md_id != NULL_OBJID))
             md_env->md_id.objid = NULL_OBJID;
             
            om_msg = om$send ( msg = message EMSimpcnstr.EMgeomhandle ((IGRlong *)msg, 
                                                                       TRUE, 
                                                                 md_env, NULL),
                               targetid = cnstr_id.objid,
                               targetos = cnstr_id.osnum );
            action = 1;


            om_msg = om$send (msg = message GRvg.GRputsymb((IGRlong *) msg, &symb),
                               targetid = cnstr_id.objid,
                               targetos = cnstr_id.osnum );

            om_msg = om$get_objid_at_index (objid = cnstr_id.objid,
                                            p_chanselect = &to_comps,
                                            index = 0,
                                            objidaddr = &new_objid->objid,
                                            osnumaddr = &new_objid->osnum);

            action = -1;
            om_msg = om$send (msg = message GRgraphics.GRchgprops ((IGRlong *)msg,
                                    &action, &props),
                               targetid = new_objid->objid,
                               targetos = new_objid->osnum);
            md_env->md_id.objid = save_md_id;
        }
    }

    return (om_msg);                               
}

method ACbecome_macro(IGRlong *msg; 
                      IGRint position;
		      struct GRmd_env *md_env)

/* ***************************************************************************
Description 
 This object returns the type of macros that can be constructed with this
 object. At this time it is only valid for drop macro placement and hence
 will return a completion code of ND_DROP_MAC.

Notes
 Upon exit the completion code will be one of the following:
  ND_DROP_MAC : If the manager is not a root or an external element
  ND_INVAL_MAC : Otherwise

History
 pp : 07/25/91 : Creation
*************************************************************************** */

{
 *msg = ND_DROP_MAC | ND_CONS_MAC;
 return (OM_S_SUCCESS);
}

method NDdisplay(IGRint dp_type;enum GRdpmode mode;struct GRmd_env *env)
/*
 * This method has been overriden to display the geometric handle if it
 * exists.
 * 
 * History
 * pp: 08/09/91
 */
{
  IGRlong loc_msg;
  IGRint status;
  struct GRid mod_grid;
  IGRshort mat_type;
  IGRmatrix mat_ident;
  IGRdouble *mat;
 
  status = OM_S_SUCCESS;
  loc_msg = MSSUCC;

  if(env == NULL)
   {
    mat_type = MAIDMX;
    MAidmx(&loc_msg,mat_ident);
    mat = mat_ident;
   }
  else
   { 
    mat_type = env->md_env.matrix_type;
    mat = env->md_env.matrix;
   }

   GRfindmod(&mod_grid);
   status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
        		    &mat_type,mat,&mode,&mod_grid),
                    targetid = my_id);
   if (!(1&status&loc_msg)) goto wrapup;

wrapup:
 return(OM_S_SUCCESS);
}

method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)
/*
 * This message is overriden to construct and copy myself and then
 * add to the rtree if applicable.
 *
 * History
 * Creation : PP : 08/10/91
 */
{
 IGRlong status;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 status = om$send (msg = message NDnodein.NDcopy(msg,cp_type,
                         fr_env,to_env, newobjid),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
 if (!(1&status&*msg)) goto wrapup;

 if (to_env->md_id.objid != NULL_OBJID)
 {
   status = om$send (msg = message GRgraphics.GRaddwrng(msg,to_env),
                           targetid = newobjid->objid,
                           targetos = newobjid->osnum);
   if (!(1&status&*msg)) goto wrapup;
 }

wrapup:
 return (status);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env )
{
 str->type = other_generic ;
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
/*
 * This implementation returns itself as the graphic object. 
 * Changing the behaviour of this message may impact a lot of 
 * things.
 * pp 08/21/91
 */
{
 IGRlong         msg;
 struct GRmd_env mod_env;
 IGRint          sizbuf, nret;

 go->objid = my_id;
 go->osnum = OM_Gw_current_OS;


 if (matrix && mat_type)
 {
    sizbuf = sizeof(struct GRmd_env);

    gr$get_module_env ( msg = &msg,
                        sizbuf = &sizbuf,
                        buffer = &mod_env,
                            nret = &nret );

    *mat_type = mod_env.md_env.matrix_type;    

    memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
 }
  return (OM_S_SUCCESS);
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
/*
 * This implementation copies the constraint with the geometric handle
 * if it exists.

 * History
 * pp : 08/10/91 : Creation
 */
{
 IGRlong status;
 
 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;
 status = om$send (msg = message GRgraphics.GRcopy(msg, fr_env,
                         to_env, &newobjid->objid),
                   targetid = my_id);
 if (!(1&status)) goto wrapup;

wrapup:
 return (status);
}
end implementation EMScnstrtxt;

