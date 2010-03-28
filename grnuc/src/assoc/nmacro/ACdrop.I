class implementation ACconst;

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "grownmacros.h"
#include "asbox.h"
#include <alloca.h>

#define AS_DEBUG

from ACmacro_defn import ACgive_feet_desc, ACgive_name;
from ACexpand import ACmplace;
from ACpretend import ACrebind;
from ACcomplex import ACget_other;

/*
 * Method :
 *
 *      GRdrop
 *
 * Abstract :
 *
 *      This routine drops a macro.
 *
 * Arguments :
 *
 *      *msg        IGRlong         return code.
 *      *mod_env    struct GRmd_env module environment.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      ????                ????     Creation.
 *      Jay Wallingford     10/15/93 Added PDM Delete Hooks.
 *
 */
method GRdrop(IGRlong *msg; struct GRmd_env *md_env)
{
 int status;
 struct GRid *buffer;

 struct GRid *parents;
 int nb_parents;

 int i_body;

 struct GRid my_grid, mac_grid, def_obj, occ_obj, new_occ_obj;

 OM_S_OBJID expand;

 char name[DI_PATH_MAX],
      new_name[1];
 int dir_name_len;

 int i_feet,index,nb_feet;
 struct myfeet *feet_desc;

 int		nb_other;
 OM_S_OBJID	*other_list;

 struct NDcp_struct cp_info;
 struct GRsymbology symb;
 IGRlong	sts, loc_msg;
 GRclassid	target_cl,def_cl;
 extern GRclassid OPP_ACcond_def_class_id;
 struct GRid macro_id;
 
 macro_id.objid = my_id;
 macro_id.osnum = OM_Gw_current_OS;
 
 /*
  * If this isn't a NULL module environment...
  */
  if (md_env->md_id.objid != NULL_OBJID)
  {
      /*
       * Make sure it's ok with PDM to delete the macro.
       */
      if (!PDMpre_delete (&macro_id, md_env))
      {
          return OM_E_ABORT;
      }
  }


/* If root macro does the parent implementation drop */

 if(me->STATE & ncpx_root)
  {
   status = om$send(msg = message ACncpx.GRdrop(msg,md_env),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   return (status);
  }


/* Init */

 *msg = MSSUCC;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 cp_info.list = NULL;
 cp_info.nb_obj = 0;


/* get and store the parents */

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
				      NULL,0,&buffer,0,OM_K_MAXINT,&nb_parents),
		  targetid = my_id);

 if(nb_parents <= 0)
  {
   status = om$send(msg = message ACncpx.GRdrop(msg,md_env),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   return (status);
  }

/* On conditional, just get the non asosciative component */

 status = om$send( msg = message ACcpx.find_macro(&mac_grid),
                    targetid = my_id);
 as$status(action = GOTO_VALUE, value = wrapup);

 om$get_classid(objid = mac_grid.objid, osnum = mac_grid.osnum,
		p_classid = &def_cl);
 if(om$is_ancestry_valid(superclassid = OPP_ACcond_def_class_id,
			 subclassid = def_cl) == OM_S_SUCCESS) 
  {
#if 0
   status = om$send(msg = message ACncpx.GRdrop(msg,md_env),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   return (status);
#endif

   /*
    * conditionals don't drop (119221829)
    */
   return OM_S_SUCCESS; 
  }

 parents = (struct GRid *) alloca(nb_parents*sizeof(struct GRid));
 if(parents == NULL) return(OM_W_ABORT);
 OM_BLOCK_MOVE(buffer,parents,nb_parents*sizeof(struct GRid));
   

/* Get my name, remove it from directory, create a corresponding directory */

   dir_name_len = 0;
   status = di$untranslate(objid = my_id,
			   osnum = OM_Gw_current_OS,
			   objname = name);
   if(!(status&1)) name[0] = '\0';
   else
     {
      new_name[0] = '\0';
      status = om$send(msg = message GRvg.GRchgname(msg,md_env,new_name),
		       targetid = my_id);
      status = di$mkdir(dirname = name);
      if(status&1)
       {
        dir_name_len = strlen(name);
        name[dir_name_len++]=':';
       }
     }
			  

/* Place instead the macro in "expand mode" */

 status =   om$construct(classid = OPP_ACexpand_class_id,
                         osnum     = OM_Gw_current_OS,
                         p_objid   = &expand);
 as$status(action = GOTO_VALUE, value = wrapup);

 status = om$send( msg      = message ACcpx.ACload_macro(mac_grid),
                   targetid = expand);
 as$status(action = GOTO_VALUE, value = wrapup);
		
 status = om$send( msg      = message ACexpand.ACmplace( (int *)msg,
                                          AChdr_nodisplay, NULL, nb_parents,
                                          parents, &cp_info, md_env),
                            targetid = expand);
 /*
  * ACmplace set the count but not the list when something goes wrong.
  * HGB (07/21/93)
  */
 if (cp_info.list == 0) cp_info.nb_obj = 0;
 as$status(action = GOTO_VALUE, value = wrapup);


/* get description of the feet and the macro body */
  
  status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
                                                         (&nb_feet,&feet_desc),
                    targetid = mac_grid.objid,
                    targetos = mac_grid.osnum);
  as$status(action = GOTO_VALUE, value = wrapup);

  status = om$send( msg = message ACcomplex.ACget_other
				( msg, &nb_other, &other_list ),
			targetid = mac_grid.objid,
			targetos = mac_grid.osnum);
  as$status(action = GOTO_VALUE, value = wrapup);


/* replace non associative foot by associative foot */

  for (i_feet=0;i_feet<nb_feet;i_feet = i_feet+1)
   {
    /* get the object in the definition corresponding to the foot */

    if((feet_desc[i_feet].chan&3) != feet_in_graphic) 
      { printf("%s is not in body\n",feet_desc[i_feet].name);continue;}
    index = feet_desc[i_feet].chan >>2;

    if( index >= nb_other ) continue;

    def_obj.objid	= other_list[index];
    def_obj.osnum	= mac_grid.osnum;

    /* get the corresponding object in the expand macro */
    
    for(i_body=0;i_body<cp_info.nb_obj;i_body=i_body+1)
      {
       if(def_obj.objid == cp_info.list[i_body].original) break;
      }
    
    if(i_body >= cp_info.nb_obj) 
      { printf("%s is not found \n",feet_desc[i_feet].name);continue;}
    new_occ_obj.objid = cp_info.list[i_body].clone;
    new_occ_obj.osnum = OM_Gw_current_OS;

    /* get previous non associative foot, move channel to object in expand */

    status = om$get_objid_at_index(objid = my_id,
				   p_chanselect = &AS_to_comp,
				   index = feet_desc[i_feet].pos,
				   osnumaddr = &occ_obj.osnum,
				   objidaddr = &occ_obj.objid);
    as$status();
    if(!(status&1)) continue;

/*
   Doesn't use move channel since placed element could already have some
   owner (dimension in associative profile
*/
   
      status = om$get_index(objid_c = my_id,
			    p_chanselect = &AS_to_comp,
			    indexaddr = (OMuint *) &index,
			    objid = occ_obj.objid);
				 
      if(!(status&1)) continue;
			    

      status = om$send(msg = message Root.disconnect(AS_to_owner,
                                        my_id,OM_Gw_current_OS,
                                        AS_to_comp),
                     targetid = occ_obj.objid,
                     targetos = occ_obj.osnum);

      status = om$send(msg = message Root.connect(AS_to_owner,index,
					my_id,OM_Gw_current_OS,
					AS_to_comp,OM_K_MAXINT),
		     targetid = new_occ_obj.objid,
		     targetos = new_occ_obj.osnum);
    as$status();

    /* give a name to the new foot */

    if(dir_name_len)
     {
      strcpy(name+dir_name_len,feet_desc[i_feet].name);
      status = om$send(msg = message GRvg.GRchgname(msg,md_env,name),
		          targetid = new_occ_obj.objid,
		          targetos = new_occ_obj.osnum);
      as$status();
     }

	/*| transfert symbology */
	sts = om$get_classid(	objid	= new_occ_obj.objid,
				osnum	= new_occ_obj.osnum,
				p_classid = &target_cl );
	as$status( sts = sts );

	if( om$is_ancestry_valid(
				subclassid	= target_cl ,
				superclassid	= OPP_ACcpx_class_id ) 
		!= OM_S_SUCCESS ){

		sts = om$send( msg = message GRvg.GRgetsymb( &loc_msg, &symb ),
				targetid = occ_obj.objid,
				targetos = occ_obj.osnum);
		if( sts & loc_msg & 1 ){

			sts = om$send( msg = message GRvg.GRputsymb( &loc_msg, &symb ),
			          	targetid = new_occ_obj.objid,
			          	targetos = new_occ_obj.osnum);
			as$status( sts = sts );
		}

	} else {

		/*| foot is a macro use context compute */
		sts = ACcontext_compute_component
					(&loc_msg,&new_occ_obj,&occ_obj,
					 &new_occ_obj,md_env);
	  }

    /*  delete the old non associative  foot */

    status = om$send(msg = message GRgraphics.GRdelete(msg,md_env),
		     targetid = occ_obj.objid,
		     targetos = occ_obj.osnum);
    as$status();
			
   }

/* delete the ACexpand header */
 
 status = om$send(msg = message Root.delete(1),
		  targetid = expand);
 as$status();

/* remove if ncessary my bit del_no_children 
   because last dependent disconnecting will change my component to
   non displayable
*/
 
 status = om$send(msg = message  NDnode.NDchg_state(ND_DEL_NO_CH,0),
		  targetid = my_id);

/* reconnect dependency */

 status = om$send(msg = message ACpretend.ACrebind( (int *)msg,&my_grid),
           p_chanselect = &ND_children);
 as$status();


/* Disconnect my component and drop the complex */

{
status = om$send(msg = message Root.wild_disconnect(AS_to_comp),
           targetid = my_id);
as$status();
}

status = nd$wait_batch(type = GR_DELETED,
                 nb_obj = 1,
                 l_object = &my_grid);

/*
 * If this isn't a NULL module environment...
 */
if ((status & 1) && (md_env->md_id.objid != NULL_OBJID))
{
    /*
     * Notify PDM that the macro has been deleted.
     */
    PDMpost_delete (&macro_id, md_env);
}

    
/* clean up */

wrapup :
 if(cp_info.list) om$dealloc(ptr = cp_info.list);

return( OM_S_SUCCESS );
}

/* ========================================================================= */
 
/*
 * Method :
 *
 *      ACdrop
 *
 * Abstract :
 *
 *      This routine drops a macro. This override will call the
 *      PDM hooks for delete.
 *
 * Arguments :
 *
 *      *mod_env    struct GRmd_env module environment.
 *
 * History :
 *
 *      Jay Wallingford     10/15/93 Creation.
 *
 */
method ACdrop (struct GRmd_env * mod_env)
{
    IGRlong om_msg = OM_S_SUCCESS;
    struct GRid macro_id;

    /*
     * If this isn't a delete of a dynamic copy ...
     */
    if (mod_env->md_id.objid != NULL_OBJID)
    {
        macro_id.objid = my_id;
        macro_id.osnum = OM_Gw_current_OS;
        
        /*
         * Make sure it's ok with PDM to delete this macro.
         */
        if (!PDMpre_delete (&macro_id, mod_env))
        {
            om_msg = OM_E_ABORT;
        }
    }

    if (om_msg & 1)
    {
        /*
         * Drop the macro.
         */
        om_msg = om$send (msg = message ACcpx.ACdrop (mod_env),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        /*
         * If this isn't a delete of a dynamic copy ...
         */
        if (mod_env->md_id.objid != NULL_OBJID)
        {
            /*
             * Notify PDM that the macro has been deleted.
             */
            PDMpost_delete (&macro_id, mod_env);
        }
    }
    
    return om_msg;
}

end implementation ACconst;
