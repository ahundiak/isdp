 /*
  ACcreatei.I
  robert patience
  21_jul_86
*/
class implementation ACcreate;

#include "ASmacroi.h"
#include "macro.h"
#include "acmacros.h"

#define AS_DEBUG

extern struct GRid 	AC_construct_id;

from ACmacro_defn import ACbuild_macro,ACedit_template;

/* ========================================================================= */

method ACplace(	int *suc,prop; 	char *macro_name;
		int temp_num; 	OM_S_OBJID *temp_l;	char **temp_name;
		int feet_num; 	OM_S_OBJID *feet_l;	char **feet_name)
{
  IGRint 		status=1, msg;
  struct GRmd_env	md_env;
  IGRlong 		S1,S2;

  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
  as$status(action = RET_STATUS );

  status = om$send(msg = message ACcreate.ACmplace( suc, prop, macro_name,
		  			temp_num, temp_l, temp_name,
		  			feet_num, feet_l, feet_name,
					&md_env),
                   targetid = my_id );
  as$status( action = RET_STATUS );  

  return( OM_S_SUCCESS );
}

/* ========================================================================= */

method ACmplace(	int *suc,prop; 	char *macro_name;
		int temp_num; 	OM_S_OBJID *temp_l;	char **temp_name;
		int feet_num; 	OM_S_OBJID *feet_l;	char **feet_name;
	        struct GRmd_env *md_env)
{
  long loc_msg;
  IGRint 		status=1;
  struct sup 		*dup;
  struct stemp 		*dtemp;
  struct myfeet 	*v_myfeet;
  int 			wcount;
  struct GRid 		*temp_list, *feet_list,source;
  struct ret_struct pardef;

  *suc=1;
  temp_list = NULL;
  dup = NULL;
  dtemp = NULL;
  feet_list = NULL;
  v_myfeet = NULL;

  if(temp_num) 
  {
    temp_list 	= (struct GRid  *)
		  om$malloc( size=(temp_num*sizeof(struct GRid )) );
    dup 	= (struct sup  *)
		  om$malloc( size=(temp_num*sizeof(struct sup )) );
    dtemp 	= (struct stemp  *)
		  om$malloc( size=(temp_num*sizeof(struct stemp )) );
    if(!temp_list || !dup || !dtemp) return OM_W_ABORT;
  }

  if(strlen(macro_name)>=macro_MAX_CHAR)
    {
      printf("ACcreate.place %s is a string too large\n",macro_name);
      *suc=0;
    }

  for(wcount=0;wcount<temp_num;wcount++)
  {
    temp_list[wcount].objid=temp_l[wcount];
    temp_list[wcount].osnum=OM_Gw_current_OS;
    if(strlen(temp_name[wcount])>=macro_MAX_CHAR)
    {
      printf("ACcreate.place %s is a string too large\n",temp_name[wcount]);
      *suc=0; continue;
    }
    strcpy(dup[wcount].prompt,temp_name[wcount]);
    strcpy(dup[wcount].up_scan,".");
    strcpy(dtemp[wcount].down_scan,".");
    strcpy(dtemp[wcount].name,temp_name[wcount]);
    dtemp[wcount].back=wcount;
    status = as$make_source(go_grid = temp_list[wcount],
		   as_os = OM_Gw_current_OS,
		   as_grid = &source);
    as$status(action = RET_STATUS);
    status = om$send(msg =  message NDnode.NDgive_structure( &loc_msg,
                                                        &pardef,md_env ),
                     targetid = source.objid,targetos = source.osnum );
    as$status(action = RET_STATUS );

    dtemp[wcount].type=pardef.type;
    dup[wcount].type=pardef.type;
  }

  if(feet_num)
  {
    feet_list 	= (struct GRid *)om$malloc( 
				size=(feet_num*sizeof(struct GRid )) );
    v_myfeet	= (struct myfeet *)om$malloc( 
				size=(feet_num*sizeof(struct myfeet )) );
    if(!feet_list || ! v_myfeet) return OM_W_ABORT;
  }
  for(wcount=0;wcount<feet_num;wcount++)
  {
    if(strlen(feet_name[wcount])>=macro_MAX_CHAR)
    {
      printf("ACcreate.place %s is a string too large\n",feet_name[wcount]);
      *suc=0;continue;
    }
    feet_list[wcount].objid=feet_l[wcount];
    feet_list[wcount].osnum=OM_Gw_current_OS;
    strcpy(v_myfeet[wcount].name,feet_name[wcount]);
  } 

  if(*suc)
   {
    status = om$send(msg = message ACcreate.ACfull_place
					( suc, prop, macro_name,
		  			temp_num, temp_list,	dup,
		  			temp_num, dtemp,
		  			feet_num, v_myfeet, feet_list,
					md_env),
                   targetid = my_id );
    as$status( );
   }

  if(feet_list) om$dealloc(ptr=feet_list);
  if(v_myfeet)    om$dealloc(ptr=v_myfeet); 

  if(temp_list) om$dealloc(ptr=temp_list);
  if(dup)       om$dealloc(ptr=dup); 
  if(dtemp)     om$dealloc(ptr=dtemp); 

  if(*suc&1) return status;
  else 	     return OM_W_ABORT;
}

/* ========================================================================= */

method ACedit_template(int *suc, num_up, num_down;
		char **up_prompt, **up_scan, **temp_name, **dwnscan;
		int template_to_up[])
{
  int 	status;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACmacro_defn.ACedit_template(suc,
				num_up, num_down, up_prompt, up_scan, 
				temp_name, dwnscan, template_to_up),
		    targetid=mac_def.objid,targetos=mac_def.osnum);
  as$status( action = RET_STATUS );
  return(1);
}

/* ========================================================================= */

method ACfull_place( 
		int *suc, prop; char *macro_name;
		int tot_up; 	struct  GRid *temp_list; struct sup *xdup;
                int tot_temp; 	struct stemp *xdtemp; 
		int feet_num; 	struct myfeet *v_myfeet; 	struct GRid *feet_list;
		struct GRmd_env *md_env)
{
  IGRint 		status, msg;
  struct                GRid 	macro;
  extern GRclassid	OPP_ACmacro_defn_class_id;
  struct GRid		mygrid;

  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  macro.osnum = AC_construct_id.osnum;
  status=om$construct( classid = OPP_ACmacro_defn_class_id, 
  		       p_objid = &macro.objid ,osnum=macro.osnum);
  as$status( action = RET_STATUS );
  me->mac_def=macro;
  status = om$send(msg = message ACmacro_defn.ACbuild_macro
	 				( suc, 		prop, 	macro_name,
	 				tot_up, 	temp_list, xdup,
	 				tot_temp, 	xdtemp,
	 				feet_num, 	v_myfeet, feet_list, 
					mygrid,		md_env),
		    targetid = macro.objid,targetos=macro.osnum);
  as$status( action = RET_STATUS );

  if(*suc == 1)
  {
    status = ac$add_macro_name( osnum 		= macro.osnum,
		   		macro_name 	= macro_name,
		   		macro_defn_id 	= macro.objid );
    if (!(status&1)) *suc=0;
  }
  else
  {
    status = om$send(msg = message ACcomplex.ACmremove_all(&msg, 0, md_env),
		     targetid = macro.objid,targetos=macro.osnum);
    as$status( action = RET_STATUS );
  }
  return(1);
}

end implementation ACcreate;

