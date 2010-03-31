/* ###################   APOGEE COMPILED   ################## */
/* set the tabstop = 4 for proper intentation */

class implementation  EMSsfboolean;

%safe
#include <math.h>
%endsafe

#include "OMminimum.h"
#include "OMprimitives.h"
#include "EMS.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "emssfintdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

extern OMuword OPP_EMSsfboolean_class_id;
extern OMuword OPP_EMSslboolean_class_id;


IGRlong EFre_execute_bool_tree( EMmsg, my_env,tree_node_id )
IGRlong *EMmsg;
struct GRmd_env *my_env;
struct GRid tree_node_id;
/* History :- 
  
   Inasu : Mar 28, 91 : Creation 
*/
{
 IGRushort options;
 IGRlong OM_stat,msg;
 IGRint num, buff_size,display_count,invoke_count;
 GRobjid *display_ids = NULL, *elem_set = NULL;
 struct GRid *active_states;
 IGRint i;
 IGRchar status_ptr[54];
 IGRboolean delete_me;
 OMuword bool_classid;

 OM_stat = OM_S_SUCCESS;
 delete_me = FALSE;

 strcpy(status_ptr,"Processing");
 num = buff_size = display_count = invoke_count = 0;
 active_states = NULL;

 /* set the options to get the actives states and do not delete me */

 options = EMS_UNDO_DELETE | EMS_UNDO_DONTDELME |
				EMS_GET_ACTIVE_STATES | EMS_DO_DISPLAY;

 /* Undo myself */

 OM_stat = om$send (msg = message EMSdpr.EMundo (&msg, &options, my_env,
						 &active_states, &num,
						 &buff_size,
						 &display_ids,
						 &display_count,
						 &invoke_count),
				senderid = NULL_OBJID,
				targetid = tree_node_id.objid,
				targetos = tree_node_id.osnum);
 if(!(OM_stat & msg & 1)) { *EMmsg = msg ; goto wrapup; } 

   /* For each ative state returned, check if it is a global boolean. If
      yes call the funtion recursively, else do nothing */

   for(i=0; i < num; i++)
   {
	OM_stat = om$get_classid ( osnum = active_states[i].osnum,
					   objid = active_states[i].objid,
					   p_classid = &bool_classid);
       	if(!(1&OM_stat)) {*EMmsg = EMS_E_OMerror;  goto wrapup;} 

        if(bool_classid == OPP_EMSsfboolean_class_id || 
			bool_classid == OPP_EMSslboolean_class_id )
	{
  	 OM_stat = EFre_execute_bool_tree(&msg, my_env, active_states[i]);
       	 if(!(msg & 1)){*EMmsg = msg; delete_me = TRUE;} 
		
	}
    }
    /* If one of the sub-trees failed to re-execute, then exit */

     if(delete_me) goto wrapup;
	
    /* If all the children succeeded, perfom the the boolean again */
    {
     enum EMSbooltype type;
     struct GRsymbology symbology;
     struct GRvg_construct construct_list;
     IGRushort optionsEMboolean;


     elem_set = (GRobjid *) om$malloc(size = num * sizeof( GRobjid ));
     if( !elem_set ) { *EMmsg = EMS_E_OMerror; goto wrapup; } 
   
     for(i = 0; i < num ; i++) elem_set[i] = active_states[i].objid;


     construct_list.msg = &msg;
     construct_list.env_info = my_env,
     construct_list.newflag = FALSE;
     construct_list.geometry = NULL;
     construct_list.class_attr = NULL;
     construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     construct_list.name = NULL;

     optionsEMboolean = EMSsfbool_opt_display | EMSsfbool_opt_retryDisjoint;
   
    /*get the operation type */

     OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(&msg,
					NULL,NULL,&type,NULL,NULL,NULL,NULL,
					NULL,NULL,NULL,NULL),
				targetid = tree_node_id.objid,
				targetos = tree_node_id.osnum,
				senderid = NULL_OBJID);
     if(!(OM_stat & msg & 1)) { *EMmsg = msg; goto wrapup;}


    /* re do the boolean operation  */

    OM_stat = om$send(msg = message EMSsfboolean.EMboolean ( &msg,
					&my_env->md_env.matrix_type,
					my_env->md_env.matrix,
					elem_set[0],num - 1,
 					&elem_set[1],
					&construct_list,
					type,
					optionsEMboolean,
					status_ptr,NULL,
					NULL,NULL,NULL),
			targetid = tree_node_id.objid,
			targetos = tree_node_id.osnum,
			senderid = NULL_OBJID);
    if(!(OM_stat & msg & 1)) { *EMmsg = msg;  delete_me = TRUE; goto wrapup;}
    }



wrapup:
    /* If the re-execute failed anywhere down the tree, then delete myself */

     ex$message(msgnumb = EMS_I_ClearStatusField)
     if( delete_me )
	 OM_stat = om$send(msg = message Root.delete(NULL),
					targetid = tree_node_id.objid,
					targetos = tree_node_id.osnum,
					senderid = NULL_OBJID);

     if(active_states) om$dealloc (ptr = active_states);
     if(elem_set) om$dealloc (ptr = elem_set);
    
 return(OM_stat);
}
end implementation EMSsfboolean;
