/*
  ACm_dn_const.I
  robert patience
  1 sept 1989
*/
class implementation ACmacro_defn;

#include "ASmacroi.h"
#include "macro.h"
#include "batch.h"
#include "nddef.h"
#include "acmacros.h"
#include <alloca.h>

#define AS_DEBUG

from ACncpx import ACchange_feet;
from ACcpx import ACload_macro;

extern GRclassid OPP_ACconst_class_id,
		 OPP_ACsym_class_id,
		 OPP_ci_macro_class_id;
method ACcreate_default
    (int *msg; GRspacenum osnum; struct GRid *feet_list; struct GRid *def_macro)
{
 
 long status,loc_msg;
 int i,index,index1,nb_other;
 OM_S_OBJID *other;
 struct GRmd_env fr_env,to_env;
 struct GRid mac;
 GRclassid obj_class;
 int cp_type;
 struct GRid *clone_list;
 int nb_clone;

/* Init */

 to_env.md_id.osnum = OM_Gw_current_OS;
 to_env.md_id.objid = NULL_OBJID;
 to_env.md_env.matrix_type = MAIDMX;
 MAidmx(msg,to_env.md_env.matrix);
 fr_env = to_env;
 
 *msg = MSFAIL;
 status = OM_S_SUCCESS;
 clone_list = (struct GRid *) alloca(me->feet_num * sizeof(struct GRid));
 if(!clone_list) return OM_W_ABORT;
 nb_clone = 0;

/* Get the feet from the macro occurence if not define in argument */

 if(!feet_list)
  {
   status=om$send(msg=message ACcomplex.ACget_other(&loc_msg,&nb_other,&other),
                  targetid = my_id);
   as$status(action = RET_STATUS);

   for(i=0;i<me->feet_num;i++) clone_list[i].objid = NULL_OBJID;

   for(i=0;i<me->feet_num;i++)
    {
     if((me->myfeet[i].chan & 3) == feet_in_graphic )
     {
      index = me->myfeet[i].pos;
      index1 = me->myfeet[i].chan >> 2;

      clone_list[index].objid	= other[index1];
      clone_list[index].osnum	= OM_Gw_current_OS;
      nb_clone = (index+1)>nb_clone ? (index+1) : nb_clone;
     }
    }
    cp_type = ND_FROM_MACRO;
  }
 else
  {
   for(i=0;i<me->feet_num;i++)
    {
     if((me->myfeet[i].chan &3) != feet_in_template)
	clone_list[nb_clone++] = feet_list[i];
    }
    cp_type = 0;
   }


/* copy them to Groot */
 for(i=0;i<nb_clone;i++)
   {
     if(clone_list[i].objid == NULL_OBJID) continue;

     /* Kludge to support nesting of old macros /*
     /* WARNING nci_macro is sub class of ci_macro ...*/
     status = om$get_classid(objid = clone_list[i].objid,
     			     osnum = clone_list[i].osnum,
			     p_classid = &obj_class);
     if((om$is_ancestry_valid(superclassid = OPP_ACsym_class_id,
			     subclassid = obj_class) == OM_S_SUCCESS) ||
	obj_class == OPP_ci_macro_class_id)
      {
       struct GRid holder;
       status = om$construct( classname = "ACpl_hold",
        		      p_objid = &holder.objid,
			      osnum=to_env.md_id.osnum);
       holder.osnum = to_env.md_id.osnum;
       as$status( );
       ACtrans_symb(clone_list[i],holder);
       clone_list[i] = holder;
      }
     else
      {
       fr_env.md_id.osnum = clone_list[i].osnum;
       status = om$send(msg = message NDmacro.ACcopy_to_Groot(&loc_msg,cp_type,
						&fr_env,&to_env,&clone_list[i]),
		      targetid = clone_list[i].objid,
		      targetos = clone_list[i].osnum);
       if(!(status&loc_msg&1)) clone_list[i].objid = NULL_OBJID;
       else *msg = MSSUCC;
      }
  }

/*nothing in default occurence ---> don't create*/

 if(*msg != MSSUCC) goto wrapup;

/* create the occurence */

 status = om$construct(osnum = OM_Gw_current_OS,
		       classid = OPP_ACconst_class_id,
		       p_objid = &def_macro->objid);
 def_macro->osnum = OM_Gw_current_OS;
 as$status(action = GOTO_VALUE,
	   value = wrapup);

 mac.objid = my_id;
 mac.osnum = OM_Gw_current_OS;
 status = om$send(msg = message ACcpx.ACload_macro(mac),
		  targetid = def_macro->objid,
		  targetos = def_macro->osnum);
 status = om$send(msg = message ACncpx.ACchange_feet
					(nb_clone,clone_list,&to_env),
		  targetid = def_macro->objid,
		  targetos = def_macro->osnum);
 as$status();

/*That's all folks */
/*" created default %d %d\n",def_macro->objid,def_macro->osnum */
wrapup :
 return status;

}
 
method ACreturn_default
        (int *msg;struct GRid *placement_options,*def_values,*def_macro)
{
 return OM_W_ABORT;
}
 
method ACcopy_definition (long *msg;char *new_name;
		          struct GRmd_env *fr_env,*to_env; struct GRid *new_def)
{
 long loc_msg,status;

 int nb_template,nb_other;
 struct GRid *template,*buf;
 OM_S_OBJID *other,*new_other;
 struct NDcp_struct clone_list;
 int cp_type;
 int i,k;
 char full_name[DI_PATH_MAX];

/* 
   verify that a macro does not already exist with this name in the target 
   directory 
*/

   sprintf(full_name,"constructs:%s",new_name);
   status = di$translate(objname = full_name,
			 osnum = to_env->md_id.osnum,
			 p_objid = &new_def->objid);
   if(status&1) return OM_W_ABORT;


/* Get macro template */

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT| ND_IN_BUF,
			    NULL,0,&buf,0,OM_K_MAXINT,&nb_template),
		    targetid = my_id);
   as$status (action = RET_STATUS);

   template = (struct GRid *) alloca(nb_template*sizeof(struct GRid));
   if(!template) return OM_W_ABORT;
   OM_BLOCK_MOVE(buf,template,nb_template*sizeof(struct GRid));

/* initialize map_pointer of macro definition since it's used when associative
   solids copy */

   status = om$send(msg = message ACmacro_defn.ACinit_map_ptr
					(&loc_msg,template,me->tot_up),
		    targetid = my_id);
   as$status(action = RET_STATUS);


   status = nd$get_graph(nb_root = nb_template,
			 p_root  = template);


/* Copy definition graph */

   cp_type = ND_INSIDE_MACRO;
   status = nd$copy_graph(p_clone = &clone_list,
                          from_info = fr_env,
			  to_info = to_env,
			  cp_type = cp_type);

/* Give name to the new macro definition */

   for(i=0;i<clone_list.nb_obj;i++)
    {
     if(clone_list.list[i].original == my_id) break;
    }
   if(i>= clone_list.nb_obj) goto FAILURE;
   new_def->objid = clone_list.list[i].clone;
   new_def->osnum = to_env->md_id.osnum;

 
   status = ac$add_macro_name(macro_name = new_name,
                              osnum = new_def->osnum,
                              macro_defn_id = new_def->objid);


/* Get previous "other" definition */

   status = om$send(msg = message ACcomplex.ACget_other
						    (&loc_msg,&nb_other,&other),
		    targetid = my_id);

   new_other = (OM_S_OBJID *) alloca(nb_other * sizeof(OM_S_OBJID));

/* 
   Get new other definition 
*/

   for(i=0;i<nb_other;i=i+1)
    {
     for(k=0;k<clone_list.nb_obj;k++)
      {
       if(other[i] == clone_list.list[k].original) break;
      }
     if(k>= clone_list.nb_obj) goto FAILURE;
     new_other[i] = clone_list.list[k].clone;
    }
		
   status=om$send(msg = message ACcomplex.ACset_other
						  (&loc_msg,nb_other,new_other),
		    targetid = new_def->objid,
		    targetos = new_def->osnum);
   as$status();

   
   if(clone_list.list) om$dealloc(ptr = clone_list.list);

   *msg = MSSUCC;
   return OM_S_SUCCESS;

FAILURE :
   for(i=0;i<clone_list.nb_obj;i++)
    {
     status = om$send(msg = message NDnode.NDdelete(to_env),
		      targetid = clone_list.list[i].clone,
		      targetos = to_env->md_id.osnum);
    }
   if(clone_list.list) om$dealloc(ptr = clone_list.list);
   *msg = MSSUCC;
   return OM_S_SUCCESS;
}

method ACcopy_default(long *msg; struct GRid *new_definition;
		      struct GRmd_env *fr_env,*to_env;
		      struct GRid  *new_default)
{
 struct GRid old_default,occ;
 long status;
 char full_name[DI_PATH_MAX];

 *msg = MSFAIL;

/* Get original default */ 

 status = di$untranslate(objid = my_id,
                         objname = full_name);
 if(!(status&1)) return OM_W_ABORT;
 strcat(full_name,"$def");

 status = di$translate(objname = full_name,
                       p_objid = &old_default.objid,
		       p_osnum = &old_default.osnum);
 if(!(status&1)) return OM_W_ABORT;
 
 
/*
   verify that the default does not already exist with this name in the target
   directory
*/

   status = di$untranslate(objid = new_definition->objid,
                           osnum = new_definition->osnum,
                           objname = full_name);
   if(!(status&1)) return OM_W_ABORT;

   strcat(full_name,"$def"); 

   status = di$translate(objname = full_name,
                         p_objid = &new_default->objid);
   if(status&1) return OM_W_ABORT;

/* Copy the collection containing the default option */

 status = om$send(msg = message GRgraphics.GRcopy
				  (msg,fr_env,to_env,&new_default->objid),
			    targetid = old_default.objid,
			    targetos = old_default.osnum);
 new_default->osnum = to_env->md_id.osnum;
 as$status();
 if(status&1)
  {
   status = om$send(msg = message GRvg.GRchgname(msg,to_env,full_name),
			    targetid = new_default->objid,
			    targetos = new_default->osnum);
   as$status();
  }
 /*
    If there is a default occurence in the default parameter make it point
    to the copied macro definition
 */
 strcat(full_name,":~~occurence");
 status = di$translate(objname = full_name,
                       p_objid = &occ.objid,
                       p_osnum = &occ.osnum);
 if(status&1)
  { 
   status = om$send(msg = message ACcpx.ACload_macro(*new_definition),
		  targetid =occ.objid,
		  targetos =occ.osnum);
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}
end implementation ACmacro_defn;
