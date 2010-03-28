/* NDnode implementation file

jla dec - 87

*/

class implementation NDnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "exmacros.h"
#define AS_DEBUG
#include "madef.h"
#include <alloca.h>


/*
   Just call wait_batch. 
*/

method NDchange_node (struct GRmd_env *not_used)
{
 struct GRid my_grid;
 extern IGRboolean ASbroadcast_in_progress;

 if(!ASbroadcast_in_progress)
  {
   my_grid.osnum = OM_Gw_current_OS;
   my_grid.objid = my_id;

   nd$wait_batch(type = GR_GEOM_POSTED,
  		 l_object = &my_grid, nb_obj =1);
  }
 
return(OM_S_SUCCESS);
}

/* delete the object */

method NDdelete(struct GRmd_env *md_env)
{
 IGRint status;

 status = om$send(msg = message Root.delete(1),
		  targetid = my_id);
 as$status(action = RET_STATUS);
 return(status);
}

method NDget_state ( IGRchar *n_state )
{
 *n_state = 0;
 return(OM_S_SUCCESS);
}

method NDchg_state ( IGRchar mask,n_state )
{
 return(OM_S_SUCCESS);
}

/* transform the object to non associative 
   when one of the parent is deleted 
*/

method NDparent_deleted(IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted [];
                           struct GRid *new_obj; struct GRmd_env *md_env)
{
 long status;
/*^{int i;
    for(i=0;i<count_deleted;i++) printf("%d %d \n",
			list_deleted[i].objid,list_deleted[i].osnum);
    printf("md_id %d %d\n",md_env->md_id.objid,md_env->md_id.osnum);
  }*/

 status = om$send(msg = message NDnode.NDmove_to_root (msg, new_obj, md_env),
		  targetid = my_id);
 return status;
}

/* At this level just disconnect from root */

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
		       /*IGRint src_del; */struct GRmd_env *md_env )
{
 IGRint status;
 struct GRid  my_grid;
 IGRchar my_state;

 status = om$send(msg = message NDnode.NDget_state(&my_state),
                  targetid = my_id);
 if((status&1) && my_state&ND_DONT_MVRT)
   {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    src_grid->objid = NULL_OBJID;

    nd$wait_batch(type = GR_DELETED,
                   nb_obj = 1,
                   l_object = &my_grid);
    return(OM_S_SUCCESS);
   }
 else
   {
    status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
		     targetid = my_id);
    as$status(action = RET_STATUS);
    src_grid->osnum = my_id;
    src_grid->osnum = OM_Gw_current_OS;
    return(status); 
   }
}

method NDchildren_deleted(IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted []; 
                           struct GRid *new_obj; struct GRmd_env *md_env)
{
 long status;
 struct GRid  my_grid;
 IGRchar my_state;
 int i,j,n_ch;
 struct GRid *children;

/* Is the element support only ? */

 new_obj->objid = my_id;
 new_obj->osnum = OM_Gw_current_OS;

 status = om$send(msg = message NDnode.NDget_state(&my_state),
                  targetid = my_id);
 if(!(status&1) || !(my_state&ND_DEL_NO_CH)) return OM_S_SUCCESS;

/* Get its children */

 status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                                         NULL,0,&children,0,OM_K_MAXINT,&n_ch),
                 targetid = my_id);
 as$status(action = RET_STATUS);

/* Are there deleted as well */

 for(i=0;i<n_ch;i++)
  {
   for(j=0;j<count_deleted;j++)
    {
     if(  children[i].objid == list_deleted[j].objid 
	&&children[i].osnum == list_deleted[j].osnum) break; 
    }
   if(j>=count_deleted){/*| Not all deleted */ return OM_S_SUCCESS;}
  }


/*| all the children are deleted --> the element can be deleted */

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    nd$wait_batch(type = GR_DELETED,
                   nb_obj = 1,
                   l_object = &my_grid);
    return(OM_S_SUCCESS);
}

/* copy the element in the object space defined by new_info */

method NDcopy_graph(IGRlong *msg;IGRint cp_type;
                 struct GRmd_env *fr_env,*to_env;
                 struct NDcp_list *copied_element; int copied_size;
                 int index)
{
 int status;
 struct GRid newobjid;

/* If the element is already copied or taken from argument return success */

/*"index %d original %d clone %d\n",index,copied_element[index].original,copied_element[index].clone*/

if(copied_element[index].clone != NULL_OBJID) return OM_S_SUCCESS;


if(copied_element[index].position & ND_BODY)
 {
  /*| NDcopy */
  status = om$send(msg = message NDnode.NDcopy
					  (msg,cp_type,fr_env,to_env,&newobjid),
		   targetid = my_id);
 }
else
 {
  /*| NDcopy to root */
  status = om$send(msg = message NDnode.NDcopy_to_root
					  (msg,cp_type,fr_env,to_env,&newobjid),
		   targetid = my_id);
  if(copied_element[index].position & ND_EXTERN)
  {
   GRclassid obj_class;
   extern GRclassid OPP_dim_param_class_id;
   /***** DURTY TMP KLUDGE */
   status = om$get_classid(objid = newobjid.objid,
			   osnum = newobjid.osnum,
			   p_classid = &obj_class);
   if(om$is_ancestry_valid(subclassid = obj_class,
		 superclassid = OPP_dim_param_class_id) != OM_S_SUCCESS)
   status = om$send(msg = message NDnode.NDchg_state(ND_SUP_ONLY,ND_SUP_ONLY),
		    targetid = newobjid.objid,
		    targetos = newobjid.osnum);
  }
  
 }

if(status & *msg & 1)  copied_element[index].clone = newobjid.objid;
/*" status %x msg %x newid %d %d\n",status,*msg,newobjid.objid,newobjid.osnum */

return status;
}


method NDcopy(IGRlong *msg; IGRint cp_type;
	      struct GRmd_env *obj_env,*new_env;
	      struct GRid *newobjid)
{
 IGRint status;
 *msg = MSFAIL;
 newobjid->osnum = new_env->md_id.osnum;
 status = om$construct_and_copy(object = me,
				osnum  = new_env->md_id.osnum,
				p_objid = &newobjid->objid);
 as$status(action = RET_STATUS);
 *msg = MSSUCC;
 return(status);
}

method NDcopy_to_tmp_root(IGRlong *msg;IGRint cp_type;
                         struct GRmd_env *md_env,*new_info;
                         struct GRid *newobjid)
{
 return om$send(msg = message NDnode.NDcopy_to_root
					(msg,cp_type,md_env,new_info,newobjid),
		targetid = my_id);
}
method NDcopy_to_root(IGRlong *msg;IGRint cp_type;
                         struct GRmd_env *md_env,*new_info;
                         struct GRid *newobjid)
{
 return om$send(msg = message NDnode.NDcopy
					(msg,cp_type,md_env,new_info,newobjid),
		targetid = my_id);
}


method NDselect_copy(IGRlong *msg;IGRint select_type;
                     struct GRid *selected_obj; int *info;
                     int selected_size, *selected_nb)
{
 if(selected_obj && selected_size >0)
  {
   selected_obj->objid = my_id;
   selected_obj->osnum = OM_Gw_current_OS;
  }
 if(selected_nb) *selected_nb = 1;
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


method NDget_virtual_objects(int type;struct GRid *list;int size;
			 struct GRid **buffer; int ifrom,ito,*count,*virt_count)
{
 int status;
 status =  om$send(msg = message NDnode.NDget_objects
				(type,list,size,buffer,ifrom,ito,count),
		   targetid = my_id);
 *virt_count = *count;
 return(status);
}

/*
  Get the parents of the element and send it a NDcompute_node
*/

method NDs_compute_node(IGRlong *msg;IGRint cn_type;
			struct GRmd_env *md_env)
{
 struct GRid list[5],*p_root;
 IGRint count;
 struct GRmd_env local_env;
 IGRint status;
 IGRchar el_state;

 *msg = MSSUCC;

 /*"md_env %d obj %d\n",md_env->md_id.objid,my_id */

 if(md_env == NULL)
  {
   IGRlong NumberOfBytes, BytesReceived,rt;

   NumberOfBytes = sizeof( local_env );
   gr$get_module_env( msg = &rt,
                      sizbuf = &NumberOfBytes,
                      buffer = &local_env,
                      nret = &BytesReceived );
   md_env = &local_env;
  }


/* get the roots of the element */

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,list,5,NULL,0,4,
						     &count),
		  targetid = my_id);
 as$status(action = GOTO_VALUE, value = wrapup);

 if(count>5)
  {
   p_root=(struct GRid *) alloca(count*sizeof(struct GRid));
   if(p_root == NULL) goto wrapup;

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,p_root,count,
						NULL,0,count-1,&count),
		  targetid = my_id);
   as$status(action = GOTO_VALUE, value = wrapup);
  }
 else p_root = list;

 status = om$send(msg = message NDnode.NDget_state(&el_state),
		  targetid = my_id);
 as$status();

 
 if(el_state & ND_DEGRADED)
 {
  /*" element %d not updated because degraded state\n",my_id */
  status = OM_W_ABORT;
 }
 else
 {
  status = om$send(msg = message NDnode.NDcompute_node(msg,cn_type,
						      count,p_root,
						      md_env),
		  targetid = my_id);
 }

 wrapup : if(!(status&1)) *msg = MSFAIL;

 return(status);
}

/* Test state of the parents to know if the element has to update or not */

NDcontrol_parent_state(count,parent_state,my_state)
int count, *parent_state, *my_state;
{
 int i;

/*
Could return 

ND_COMP_SAME        : parents haven't changed value 
ND_COMP_SUCC        : parent has changed value succesfully
ND_COMP_OUT_OF_DATE : parent is out fo date 
ND_COMP_FAIL        : recompute of  parent failed
*/
  
 if(count) *my_state = ND_COMP_SAME;
 else	   *my_state = ND_COMP_SUCC;

 for(i=0 ; i<count ; i++)
  {
   if(parent_state[i] == ND_COMP_SAME) continue;
   else if(*my_state &1) *my_state = parent_state[i];
   else if(*my_state == ND_COMP_OUT_OF_DATE && parent_state[i] == ND_COMP_FAIL)
         { *my_state = ND_COMP_FAIL; return 1;}
  }
 return 1;
}

/* At this level just send a compute node message to the element */

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
 long status,loc_msg;


 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;

/* Check parent state to know if I have to recompute and if I can */

 NDcontrol_parent_state(count,parent_state,msg);
 if(*msg != ND_COMP_SUCC) return OM_S_SUCCESS;


/* In case of stop, don't update */

 if((cn_type&ND_COMP_TYPE) == ND_COMP_STOPPED)
   {
    *msg = ND_COMP_OUT_OF_DATE;
    return OM_S_SUCCESS;
   }


/* I recompute */
   loc_msg = 0;
   status = om$send(msg = message NDnode.NDcompute_node(&loc_msg,cn_type,
					count,parents,md_env),
 		  targetid = my_id);

   /* make sure that a return code is returned */
   if(status&1)
    { if(loc_msg) *msg = loc_msg;
      else        *msg = ND_COMP_SUCC;
    }
   else	          *msg = ND_COMP_FAIL;
 
   return OM_S_SUCCESS;
}

method NDpossible_parent(IGRint ifrom, ito, *geom_code, *option_code,
			    *nb_tot)
{
 return(OM_S_SUCCESS);
}

method NDmake_source(IGRlong *msg;struct GRid *located_obj,*context;char *path;
		     GRspacenum as_osnum; struct GRid *as)
{
/*"as_osnum %d\n",as_osnum */
 if(as_osnum != OM_Gw_current_OS)
   {
    *msg = MSFAIL;
    as->objid = NULL_OBJID;
    return (OM_W_ABORT);
   }
 else
   {
    *msg = MSSUCC;
    as->objid = my_id;
    as->osnum = OM_Gw_current_OS;
    return (OM_S_SUCCESS);
   }
}

method NDconnect_graph(IGRlong *msg; IGRint cp_type;
                 struct GRmd_env *fr_env,*to_env;
                 struct NDcp_list *copied_element; int copied_size;
                 int nb_root, *root_index;
                 int my_index)
{
 struct GRid *his_root,my_grid;
 int i;
 long status = OM_S_SUCCESS;

 *msg = MSSUCC;
 if(nb_root == 0) return OM_S_SUCCESS;

 /* Get the element I have to connect my clone to */

 /*"nb_root %d\n",nb_root */

 his_root = (struct GRid *) alloca(nb_root*sizeof(struct GRid));
 if(!his_root){*msg = MSFAIL; return OM_W_ABORT;}
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 for(i=0 ; i<nb_root ; i++)
 {
  his_root[i].objid = copied_element[root_index[i]].clone;
  his_root[i].osnum = to_env->md_id.osnum; 
  /*"his root %d %d\n",his_root[i].objid,his_root[i].osnum*/

 }

 status = om$send(msg = message NDnode.NDconnect
					(nb_root,his_root,my_grid,ND_NEW),
		  targetid = copied_element[my_index].clone,
		  targetos = to_env->md_id.osnum);
 as$status();
 if(!(status&1)) *msg = MSFAIL;

 return status;
}

method NDrm_assoc(long *msg; struct GRid *new_obj; struct GRmd_env *md_env)
{
 long status;
 status = om$send(msg = message NDnode.NDmove_to_root(msg,new_obj,md_env),
		  targetid = my_id);
 return status;
}

void ASmake_md_env(osnum, md_env)
GRspacenum osnum;
struct GRmd_env *md_env;
{
 long loc_msg;
 md_env->md_id.osnum = OM_Gw_current_OS;
 md_env->md_env.matrix_type = MAIDMX;
 MAidmx(&loc_msg,md_env->md_env.matrix);
 ex$get_modid( mod_osnum = osnum,
	       mod_id    = &md_env->md_id.objid);
}

/* Control parent type of the element */

method NDctl_parent_type(long *msg;int type; char *info)
{
 struct ret_struct rst;
 struct GRmd_env md_env;
 long status,loc_msg;

 ASmake_md_env(OM_Gw_current_OS, &md_env);

 status = om$send(msg = message NDnode.NDgive_structure
			(&loc_msg,&rst,&md_env), 
		  targetid = my_id);

 if((status&1) && rst.type & type) *msg = MSSUCC;
 else 				   *msg = MSFAIL;
 
 return OM_S_SUCCESS;
 
}

method NDget_parent_type(long *msg;int *type; char *info)
{
 struct ret_struct rst;
 struct GRmd_env md_env;
 long status,loc_msg;

 ASmake_md_env(OM_Gw_current_OS, &md_env);

 status = om$send(msg = message NDnode.NDgive_structure
			(&loc_msg,&rst,&md_env), 
		  targetid = my_id);
 if(status&loc_msg&1) 
  {
   *type = rst.type;
   if(rst.type & macro_generic) 
    {
     strncpy(info,rst.var.macro_st.name,macro_MAX_CHAR);
     info[macro_MAX_CHAR-1] = '\0';
    }
   *msg = MSSUCC;
  }
 else
  {
   *type = 0;
   *msg = MSFAIL;
  }
 return OM_S_SUCCESS;
}
end implementation NDnode;
