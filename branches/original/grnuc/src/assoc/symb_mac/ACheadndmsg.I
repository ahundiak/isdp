/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACheader;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grerr.h"
#include "exmacros.h"
#include "grsymdef.h"

#include "nddef.h"
#include "ndmacros.h"

#include "acrepdef.h"
#include "acrepmacros.h"
#include "alloca.h"

#define	AS_DEBUG

from	ACmodel_mgr	import	ACreturn_model;
from	ACmodel		import	ACdisconnect_head;

/* *************** MSG NDdelete () ************************************	*/

method NDdelete( struct GRmd_env *md_env )

{
IGRlong		sts, msg;
struct	GRid	my_grid;
struct	GRid	model;
OM_S_OBJID	save_id;


	/*| initialization */
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );

	if( msg & 1 ) {

		/*" disconnect header (%d/%d) from models (%d/%d)\n", my_id, OM_Gw_current_OS, model.objid, model.osnum */
		sts = om$send(	msg	 = message ACmodel.ACdisconnect_head(
						&msg,
						&my_grid,
						md_env ),
				targetid = model.objid,
				targetos = model.osnum );
		as$status( sts = sts, msg = "Error in msg ACdisconnect_head" );
	}

	/*| put header out R-tree */
	if( md_env->md_id.objid != NULL_OBJID ) {

		/*| take off header of range */
		sts = om$send(	msg	 = message GRgraphics.GRremwrng
						( &msg, md_env ),
				targetid = my_id );
/*^		as$status( sts = sts ); */
	}

	/*| delete header */
	save_id 	= md_env->md_id.objid;
	md_env->md_id.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message ACconst.NDdelete( md_env ),
			mode 	 = OM_e_wrt_message,
			targetid = my_id );
	md_env->md_id.objid = save_id;
	as$status( sts = sts, msg = "Error in msg NDdelete" );

return	OM_S_SUCCESS;
}

/* *************** MSG NDcopy () **************************************	*/

method NDcopy( IGRlong *rc; IGRint cp_type; 
		struct GRmd_env *obj_env, *new_env; struct GRid *new_obj )

{
IGRlong			sts, msg;
struct	GRid		new_model;
struct	GRid		new_model_mgr;
IGRint			nb_temp;
struct	GRid		*temp;
struct	GRid		*temp_buf;
struct	GRid		mac_def;
IGRchar			def_name[DI_PATH_MAX];
IGRint			i;
struct	GRpost_info	info;
struct	IGRlbsys	lbs;
IGRshort		new_type;
struct	GRid		occ_def;

	/*| initialization */
	*rc	= OM_S_SUCCESS;
	temp	= NULL;
	def_name[0]	= '\0';
	new_obj->objid	= NULL_OBJID;	
	new_obj->osnum	= new_env->md_id.osnum;

/*^
	printf(" obj_env : id/os = (%d/%d)\n", obj_env->md_id.objid, obj_env->md_id.osnum ); 
	pr_mat(" obj_mat", 4, 4, obj_env->md_env.matrix);

	printf(" new_env : id/os = (%d/%d)\n", new_env->md_id.objid, new_env->md_id.osnum ); 
	pr_mat(" new_mat", 4, 4, new_env->md_env.matrix);
*/

	/*| set instance data with mac_def */
	sts = om$send(	msg	 = message ACcpx.find_macro
					( &mac_def ),
			targetid = my_id );
	as$status( sts = sts );
	/*" mac_def : id/os = (%d/%d)\n", mac_def.objid, mac_def.osnum */

	if( OM_Gw_current_OS != new_env->md_id.osnum ){

		OM_S_OBJID mod_id, super_id;
		/*| Doesn't use md_id.objid in argument because of dynamics */

		/*| create a super object befor copy in new env */
		sts = ex$get_modid(	mod_osnum	= new_env->md_id.osnum,
					mod_id		= &mod_id);

		if( sts&1 )	sts = ex$get_super(	
					mod_id		= mod_id,
					mod_osnum	= new_env->md_id.osnum,
					super_name	= "super_para",
					create		= TRUE,
					super_class	= "super_para",
					super_id	= &super_id);
		as$status( sts = sts );
	}

	sts = om$construct_and_copy(	object	= me,
					osnum	= new_obj->osnum,
					p_objid	= &new_obj->objid );
	as$status( sts = sts, msg = "Error in mc construct_and_copy", 
			action	= RET_STATUS );
	/*" new_obj : id/os = (%d/%d)\n", new_obj->objid, new_obj->osnum */

	/*| get old geom */
	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					&obj_env->md_env.matrix_type,
					obj_env->md_env.matrix,
					&new_type,
					lbs.matrix ),
			targetid = my_id );
	as$status( sts = sts );
/*^	pr_mat(" old geom ", 4, 4, lbs.matrix ); */ 

	/*| set geometry */
	for( i=0; i<3; i++ ){
		lbs.diag_pt1[i]	= 0.;
		lbs.diag_pt2[i]	= 0.;
	}

	/*| modify geometry --> postabs to the copy  no more xform */
	info.construct_flag	= TRUE;
	sts = om$send(	msg	= message ACheader.GRpostabsg(
					&msg,
					new_env,
					&info,
					(IGRchar *) &lbs,
					&new_obj->objid ),
			targetid = new_obj->objid,
			targetos = new_obj->osnum );
	as$status( sts = sts );

	/*| connect copy to model */
	new_model.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message ACheader.ACfind_model
						( &msg, &new_model ),
			targetid = my_id );
	as$status( sts = sts );
	/*" new_model : id/os = (%d/%d)\n", new_model.objid, new_model.osnum */

	if( new_obj->osnum == OM_Gw_current_OS && (msg&1) ){

		/*" copy in same os : %d\n", OM_Gw_current_OS */

		/*| connection copy to model */
		sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						0,
						new_obj->objid,
						new_obj->osnum,
						AS_to_comp,
						OM_K_MAXINT ),
				targetid = new_model.objid,
				targetos = new_model.osnum );
		as$status( sts = sts, msg = "Error in msg connect" );

	} else {

		/*| get parent of old model */
		sts = om$send(	msg	 = message NDnode.NDget_objects(
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&temp_buf,
						0,
						OM_K_MAXINT,
						&nb_temp ),
				targetid = new_model.objid,
				targetos = new_model.osnum );
		as$status( sts = sts );
		/*" nb_temp : %d\n", nb_temp */
/*^
		for( i=0; i<nb_temp; i++ )
			printf(" temp_buf[%d] : id/os = (%d/%d)\n", i,
					temp_buf[i].objid, temp_buf[i].osnum );
*/

		temp = (struct GRid *) om$malloc (
			size	= sizeof(struct GRid) * nb_temp );
		if( temp == NULL && nb_temp !=0 ){
			printf(" Error not enought memory to allocate temp \n");
			*rc	= OM_E_ABORT;
			return	OM_E_ABORT;
		}

		for( i=0; i<nb_temp; i++ )	temp[i] = temp_buf[i];

		/*| get full path name of mac def from directory */
		sts = di$untranslate(	objname	= def_name,
					objid	= mac_def.objid,
					osnum	= mac_def.osnum );
		as$status( sts = sts );
		/*" def_name : %s\n", def_name */

		/*" os of new model : %d\n", new_env->md_id.osnum */
		/*| find model mgr */
		sts = om$send(	msg	 = message ACheader.ACget_model_mgr
						( &msg, &new_model_mgr ),
				targetid = new_obj->objid,
				targetos = new_obj->osnum );
		as$status( sts = sts, msg = "Error in msg ACget_model_mgr" );
		/*" new_model_mgr : id/os = (%d/%d)\n", new_model_mgr.objid, new_model_mgr.osnum */

		occ_def = new_model;
		sts = om$send(	msg	 = message ACmodel_mgr.ACreturn_model(
						&msg,
						AChdr_norange | AChdr_nodisplay,
						AC_NO_REP,
						def_name,
						nb_temp,
						temp,
						&occ_def,
						new_env,
						&new_model ),
				targetid = new_model_mgr.objid,
				targetos = new_model_mgr.osnum );
		as$status( sts = sts );
		/*" new_model : id/os = (%d/%d)\n", new_model.objid, new_model.osnum */
		if( ! (sts&1)){
			printf(" Can't find a model for the copy \n");
			*rc	= MSFAIL;
			goto	wrapup;
		}

		/*| connection copy to model */
		sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						0,
						new_obj->objid,
						new_obj->osnum,
						AS_to_comp,
						OM_K_MAXINT ),
				targetid = new_model.objid,
				targetos = new_model.osnum );
		as$status( sts = sts, msg = "Error in msg connect" );

	  }/*end os diff*/

wrapup :

	/*| free memory */
	if( temp != NULL )	om$dealloc( ptr	= temp );

return	OM_S_SUCCESS;
}

/* Copy geometry when assoc is removed */

method NDrm_assoc(long *msg; struct GRid *new_object; struct GRmd_env *md_env)
{
 long status;
 int comp_number,i_comp;
 struct GRid *component;
 struct GRmd_env cmp_env;
 short set,props;

/* If support only, get rid of it */

  if(me->state & ND_DEL_NO_CH)
  {
   status = om$send(msg = message GRgraphics.GRremwrng(msg,md_env),
                    targetid = my_id);

   status = om$send(msg = message ACconst.NDrm_assoc(msg,new_object,md_env),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   return status;
  }



/* Init */

 set = 0;
 props = GR_RIGID_RELATIONSHIP;


/* Get component */
  
 comp_number = 0;
 component = NULL;

 status = om$send(msg = message ACheader.ACget_share_feet_list
                                      (msg,comp_number,component,&comp_number),
		  targetid = my_id);

 if(!comp_number || !(status&*msg&1)) return status;

 component =(struct GRid *) alloca(comp_number*sizeof(struct GRid));
 status = om$send(msg = message ACheader.ACget_share_feet_list
                                      (msg,comp_number,component,&comp_number),
		  targetid = my_id);
 as$status(action = RET_STATUS); 

/* Get my transformation matrix */ 

  status = om$send(msg = message ACheader.GRget_context
                                        (msg,md_env,&cmp_env),
		  targetid = my_id);
 as$status(action = RET_STATUS); 


/* Copy the components */

  for(i_comp=0 ; i_comp<comp_number ; i_comp=i_comp+1)
    {
     status = om$send(msg = message GRgraphics.GRcopy (msg,&cmp_env,md_env,
                                                      &component[i_comp].objid),
                        targetid = component[i_comp].objid,
                        targetos = component[i_comp].osnum);
     status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,&props),
                        targetid = component[i_comp].objid,
                        targetos = component[i_comp].osnum);
     status = om$send(msg = message NDnode.NDrm_assoc(msg,new_object,md_env),
                      targetid = component[i_comp].objid,
                      targetos = component[i_comp].osnum);
     as$status();
    }

 return OM_S_SUCCESS;
}
end implementation ACheader;

