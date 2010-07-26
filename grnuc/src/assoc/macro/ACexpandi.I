/*
  ACexpandi.I
  robert patience
  21_jul_86
*/
class implementation ACexpand;

#include <sys/types.h>
#include "ASmacroi.h"
#include "macro.h"
#include "AS_status.h"
#include <alloca.h>
#include "igrtypedef.h"

#define AS_DEBUG

from ACmacro_defn import ACgive_upscan, ACgive_temp_desc, ACinit_map_ptr;
from ACsym    	  import ACmplace;

/* ========================================================================= */

method ACciplace(int *suc, prop; 	char *macro_name;
		 int num_temp; 		OM_S_OBJID *temp_l )
{
  struct GRid 		*temp_list = NULL;
  int 			i, status, msg;
  IGRlong 		S1, S2;
  struct GRmd_env	md_env;

  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
  as$status(action = RET_STATUS );

  *suc=1;
  if(num_temp) 
  {
    temp_list =(struct GRid *) om$malloc(size=(num_temp*sizeof(struct GRid)) );
    if(temp_list == NULL) *suc=0; return(1);
  }

  for(i=0;i<num_temp;i++)
  {
    temp_list[i].objid=temp_l[i];
    temp_list[i].osnum=OM_Gw_current_OS;
  }

  status = om$send( msg = message ACexpand.ACmplace(suc,prop,macro_name,
					num_temp,temp_list, NULL, &md_env),
	 	    targetid = my_id );
  as$status( action=CONTINUE);

  if(num_temp) om$dealloc(ptr=temp_list); 
  return(status);
}

/* ========================================================================= */

method ACplace(	int *suc  ,prop; char *macro_name;
		int numb_obj; 	 struct GRid *uplist )
{
  int			status, msg;
  struct GRmd_env	md_env;
  IGRlong 		S1,S2;

  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
  as$status(action = RET_STATUS );
  status = om$send (msg = message ACexpand.ACmplace(suc ,prop, macro_name,
				numb_obj, uplist, NULL, &md_env),
		    targetid = my_id);
  as$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method ACmplace(	int *suc  ,prop; char *macro_name;
		int numb_obj; 	 struct GRid *uplist;
		struct NDcp_struct *cp_info;
		struct GRmd_env *md_env )
{
  extern GRclassid	OPP_ACpretend_class_id;
  int 			tot_up, msg;
  OMuint		tot_root;
  int			tot_temp,min_1;
  int 			i,index,mac_prop;
  int 			status;
  struct sup 		*dsup;
  struct stemp          *dtemp;
  struct GRid 		my_grid, mac_def, *flist, *tlist,w_sym, *to_compute;
  struct ret_struct 	rst;
  struct GRmd_env	emp_env;
  struct GRmd_env	def_env;
  struct NDcp_struct    clone_info;
  int nb_to_compute;
  int cn_type;
  struct GRid tmp_clone,*new_clone;
  IGRushort h_index;


  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  clone_info.list = NULL;
  flist = NULL;
  tlist = NULL;
 
if(macro_name != NULL)
 {
  status = om$send (msg = message ACexpand.ACattach(suc,macro_name),
		    targetid = my_id);
  as$status(action = RET_STATUS);
  if(*suc!=1)return(OM_S_SUCCESS);
 }
else *suc = 1;

  /* Get macro definition */

  status = om$send(msg = message ACexpand.find_macro(&mac_def),
        	   targetid =  my_id);
  as$status(action = RET_STATUS);

  def_env = *md_env;
  def_env.md_id.osnum=mac_def.osnum;

  status= om$send ( msg = message ACmacro_defn.ACgive_upscan(&tot_up,
				&mac_prop,&dsup),
		    targetid = mac_def.objid,
		    targetos = mac_def.osnum);
  as$status( action = RET_STATUS );
  if(tot_up!=numb_obj)
  	{ printf("ACmacro_defn.copy bad template size\n");
    	  *suc = 0; return(1); }


  status=om$send(msg = message ACmacro_defn.ACgive_temp_desc(&tot_temp,&dtemp),
		    targetid = mac_def.objid,
		    targetos = mac_def.osnum);
  as$status( action = RET_STATUS );

/* Map macro definition to the correct set of parents */
  status=om$send(msg = message ACmacro_defn.ACinit_map_ptr
					((long *)&msg,uplist,numb_obj),
		 targetid = mac_def.objid,
		 targetos = mac_def.osnum);
  as$status(action = RET_STATUS);
		 

  if(!(mac_prop&ACcant_place_sym))
    {
    status=om$construct( classid = OPP_ACsym_class_id, 
  		       p_objid = &w_sym.objid );
    as$status( action = RET_STATUS );
    status = om$send(msg = message ACsym.ACmplace(suc,AChdr_norange,macro_name,
    		numb_obj,uplist,md_env),
	 	   targetid = w_sym.objid );
    as$status(action = RET_STATUS );
    }
	
  /* make my roots subclass of node if not */

   for( i=0;i<numb_obj;i++ )
     as$make_source(   go_grid = uplist[i],
		       as_os = uplist[i].osnum,
		       as_grid = &uplist[i] );

  /*| get the def graph (ACmacro_def included) */

  status = om$get_channel_count(objid 		= mac_def.objid,
				osnum 		= mac_def.osnum, 
				p_chanselect 	= &AC_template_chns,
				count 		= &tot_root );
  as$status( action = GOTO_VALUE, value = WRAPUP );

/*
   allocate space to store the roots of the original graph and of the
   target graph
*/

  tlist = (struct GRid *) alloca((tot_root) * sizeof(struct GRid ));
  flist = (struct GRid *) alloca((tot_root) * sizeof(struct GRid ));

/*
   from my roots find the roots of the the graph I represant ( They could be
   different if the macro has been edited : One of my roots can be
   used severals time with different down_scan definitions to give several
   roots of the graph )
*/ 

  for(i=0;i<tot_temp;i++)
  {
   index = dtemp[i].back;

   if(dtemp[i].down_scan[0] == '.')
   {
    /*"root %d of the graph is my root %d",i,index */
    tlist[i] =  uplist[index];
   }

   else
   {
    /*"root %d of graph is feet %s of my roots %d",i,dtemp[i].down_scan,index*/
      
      {
       /* my root only knows is definition --> pretend has to be created */
       min_1=-1;
       status = om$send(msg = message ACcpx.ACgive_structure(suc,
					  &min_1,
					  dtemp[i].down_scan,&rst, md_env),
		     targetid = uplist[index].objid,
		     targetos = uplist[index].osnum);
       as$status(action = GOTO_VALUE, value = WRAPUP);
        

       if(!(*suc))
        { printf("Invalid template definition \n");
  	  goto WRAPUP; }

       status = om$send(msg = message ACcpx.ACconnect_pretend
				( &msg,dtemp[i].down_scan,&tlist[i] ),
                       targetid = uplist[index].objid,
		    targetos = uplist[index].osnum );
       as$status( action = GOTO_VALUE, value = WRAPUP );

       tlist[i].osnum = OM_Gw_current_OS;
      }
    }
    /*"tlist  %d is %d",i,tlist[i].objid */
  }

  for(i=tot_temp;i<tot_root;i++) tlist[i].objid = NULL_OBJID;

 

  ACread(mac_def, &AC_template_chns, flist,  tot_root);

  status = nd$get_graph( p_root = flist ,        	nb_root = tot_root,
                	 p_tip  = &mac_def,  	nb_tip = 1);
  as$status( action = GOTO_VALUE, value = WRAPUP );

  status = nd$copy_graph(cp_type = ND_FROM_MACRO, 
			 type_graph = ND_CON_TIP_LIST | ND_COPY_EXT,
			 p_root = tlist,        nb_root = tot_root,
                 	 p_tip  = &my_grid,   nb_tip  = 1,
                 	 from_info = &def_env,   to_info = &emp_env,
			 p_clone = &clone_info );
  as$status( action = GOTO_VALUE, value = WRAPUP );

  if(prop&AChdr_nocompute) goto WRAPUP;

  /* Retains only body elements in the copy graph */

  to_compute = (struct GRid *) alloca(clone_info.nb_obj*sizeof(struct GRid));
  nb_to_compute = 0;
  for(i=0;i<clone_info.nb_obj;i++)
   {
    if(!(clone_info.list[i].position & ND_BODY)) continue;
    to_compute[nb_to_compute].objid = clone_info.list[i].clone;
    to_compute[nb_to_compute++].osnum = emp_env.md_id.osnum;
   }

  /*| getting the compute graph */

  status = nd$get_graph(p_root = to_compute,
			nb_root = nb_to_compute);
  as$status( action = GOTO_VALUE, value = WRAPUP );

  /* 
      because element id change during recompute, store them by index
      in the p_graph structure
  */

  tmp_clone.osnum = emp_env.md_id.osnum;
  for(i=0;i<clone_info.nb_obj;i++)
   {
    if(!(clone_info.list[i].position & ND_BODY)) continue;
    tmp_clone.objid = clone_info.list[i].clone;
    GMh_give_content((char *) &tmp_clone,ND_graph.p_hcode,NULL,&h_index);
    clone_info.list[i].clone = h_index;
   }


  /*| update it  */

  cn_type = ND_COMP_FROM_MACRO | ND_COMP_NO_ERASE | ND_COMP_NO_REM_RT;
  emp_env.md_id.objid = md_env->md_id.objid;

  if(prop&AChdr_norange)
   { emp_env.md_id.objid = NULL_OBJID;
     cn_type |= ND_COMP_NO_ADD_RT;
   }
  if(prop&AChdr_nodisplay) cn_type |= ND_COMP_NO_DISPLAY;
  status = nd$update_graph(cn_type = cn_type,
			   root_compute = ND_UPT_ROOT,
			   md_env = &emp_env);

  /* get back objid from index in the p_graph structure */

  for(i=0;i<clone_info.nb_obj;i++)
   {
    if(!(clone_info.list[i].position & ND_BODY)) continue;
    h_index = clone_info.list[i].clone;
    new_clone = (struct GRid *) GMh_key(ND_graph.p_hcode,h_index);
    if(new_clone) clone_info.list[i].clone = new_clone->objid;
    else	  clone_info.list[i].clone = NULL_OBJID;
   }


  /*| should change cp_list.clone with the new nodes if nodes change id */
  if(!(status&1)) 
    { status = nd$broadcast_graph( p_msg = message NDnode.NDdelete( &emp_env));
      goto WRAPUP;
    }

  *suc=1;
  WRAPUP : 
    if(cp_info == NULL)
     {
      if(clone_info.list != NULL) om$dealloc(ptr = clone_info.list);
     }
    else
     {
      *cp_info = clone_info;
     }
  
  if(!(mac_prop&ACcant_place_sym))
    {
    status = om$send(msg = message NDnode.NDdelete(&emp_env),
	 	   targetid = w_sym.objid );
    as$status(action = RET_STATUS );
    }

  return(OM_S_SUCCESS);
}
 
end implementation ACexpand;
