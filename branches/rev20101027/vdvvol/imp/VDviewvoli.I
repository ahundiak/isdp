class implementation VDviewvol;

/*+mi
Doc

 This file contains overridden methods of VDviewvol

 NDplace :  When a view volume is created.
 NDcompute_node : when parent is modified.
 NDparent_deleted


-mi*/

#include "nddef.h"
#include "exmacros.h"
#include "vderrmacros.h"
#include "gocmacros.h"

from    EMSdpr          import  EMmake_primitive1;
from    EMSsurface      import  EMgetactiveid;

extern  struct GRid   NULL_GRID;


method  NDplace (
  struct GRas		*asso_lis;
  struct GRmd_env	*mod_env;
  char			*go_cnst_lis
)

{

long		sts, loc_msg;
OMuint		count;
struct GRid	*parent,
		solid_copy,
		my_grid,
		VolMgr, parent_go;
struct GRmd_env parent_go_env;
IGRlong		index, flag;
IGRshort	action, props;


   __DBGpr_com("VDviewvol : Entered NDplace");

   count = asso_lis->num_parents;
   parent = asso_lis->parents;
   __DBGpr_obj ( "parent", *parent );

   sts = om$send ( msg = message NDnode.ASreturn_go (
					&parent_go,
					&parent_go_env.md_env.matrix_type,
					parent_go_env.md_env.matrix ),
			 targetid = parent->objid,
			 targetos = parent->osnum  );
   VDS_ERR_HNDLR("NDnode.ASreturn_go", sts, 1, VD_VERBOSE, wrapup );
   parent_go_env.md_id.osnum = parent_go.osnum;
   ex$get_modid (  mod_osnum = parent_go.osnum,
		   mod_id    = &parent_go_env.md_id.objid );

   solid_copy.osnum = OM_Gw_current_OS;
   sts = om$send ( msg = message GRgraphics.GRcopy (  &loc_msg,
						      &parent_go_env,
						      mod_env,
						      &solid_copy.objid ),
		   targetid = parent_go.objid,
		   targetos = parent_go.osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRcopy", sts, loc_msg, VD_VERBOSE, wrapup );
   __DBGpr_obj ( "solid_copy", solid_copy );

   /*
    *  change properties of copy to non_displayable, non_locatable
    */
   action = 0;
   props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   sts = om$send ( msg = message GRgraphics.GRchgprops ( &loc_msg,
					&action, &props ),
		   targetid = solid_copy.objid,
		   targetos = solid_copy.osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRchgprops", sts, loc_msg, VD_VERBOSE, wrapup );

   /* 
   ** Compress tree ...
   */
   {
     struct GRid        active_id, top_lm_id, tmp_id ;

     sts = om$send( msg      = message EMSsurface.EMgetactiveid(&loc_msg,
                                                                &active_id,
                                                                &top_lm_id),
                    targetid = solid_copy.objid,
                    targetos = solid_copy.osnum );
     if( sts&loc_msg&1 )
     {
       sts = om$send( msg      = message EMSdpr.EMmake_primitive1(&loc_msg,
                                                                  mod_env,
                                                                  &tmp_id),
                      targetid = active_id.objid,
                      targetos = active_id.osnum );
       if( sts&loc_msg&1 ) solid_copy.objid = tmp_id.objid;
     }
   }
   __DBGpr_obj ( "solid_copy", solid_copy );

   /*
    *  connect myself and solid_copy
    */
   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   index = 0; 
   sts = om$send ( msg = message GRconnector.GRrigidconn ( &loc_msg,
							   &my_grid,
							   &index ),
		   targetid = solid_copy.objid,
		   targetos = solid_copy.osnum );
   VDS_ERR_HNDLR ( "GRconnector.GRrigidconn", sts, loc_msg, VD_VERBOSE,wrapup );

   /*
    * add to the graph
    */
   sts = om$send( msg = message NDnode.NDconnect( asso_lis->num_parents,
						 asso_lis->parents,
						 NULL_GRID,
						 ND_NEW),
		 targetid = my_id);
   VDS_ERR_HNDLR ( "NDnode.NDconnect", sts, 1, VD_VERBOSE, wrapup );


   /*
    * get view volume manager and connect myself to it
    */

   sts = VDget_vol_mgr ( &(mod_env->md_id.osnum), &VolMgr );
   VDS_ERR_HNDLR("VDget_vol_mgr", sts, 1, VD_VERBOSE, wrapup);

   flag = 1;
   index = OM_K_MAXINT;
   sts = om$send( msg = message GRconnector.GRflexconn( &loc_msg, &flag,
					   &VolMgr, &index, &index ),
		  senderid = NULL_OBJID,
		  targetid = my_id,
		  targetos = OM_Gw_current_OS );
   VDS_ERR_HNDLR("GRconnector.GRflexconn", sts, loc_msg, VD_VERBOSE, wrapup);


wrapup:
   return sts;

}

method  NDcompute_node ( IGRlong	 *msg;
			 IGRint		 cn_type;
			 int		 count;
			 struct GRid	 *list;
			 struct GRmd_env *mod_env )
{
long		  sts;
struct GRid	  solid_copy;
OM_S_CHANSELECT   to_components,
		  to_owners;
OM_S_OBJECT_LINKAGE  *compLinkage = NULL;
int		  count;
struct GRid	  parent_sol,parent_copy;
struct GRmd_env	  parent_sol_env;
long		  ii;
IGRshort	  action, props;


   __DBGpr_com("VDviewvol : Entered NDcompute_node");

   sts = om$make_chanselect (   channame = "GRcmpowner.to_components",
				p_chanselect = &to_components );

   sts = om$make_chanselect (   channame = "GRconnector.to_owners",
				p_chanselect = &to_owners );

   sts = om$get_objid_at_index (  objid  =  my_id,
				  p_chanselect =  &to_components,
				  index  = 0,
				  objidaddr = &solid_copy.objid,
				  osnumaddr = &solid_copy.osnum  );

   __DBGpr_obj("solid_copy_old", solid_copy );

   /*
    *  Delete components of solid copy
    */
   sts = om$get_channel_count(	osnum = solid_copy.osnum,
				objid = solid_copy.objid,
				p_chanselect = &to_components,
				count = (OMuint *) &count ) ;

   compLinkage = (OM_S_OBJECT_LINKAGE *) malloc(sizeof( OM_S_OBJECT_LINKAGE) *
								count );
   sts = om$get_channel_objects ( osnum		= solid_copy.osnum,
				  objid		= solid_copy.objid,
				  p_chanselect  = &to_components,
				  list		= compLinkage,
				  size		= count,
				  count		= (OMuint *) &count );
   VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );

   for(ii=0; ii<count; ii++)
   {
	sts = om$send ( msg = message GRgraphics.GRdelete ( msg, mod_env ),
		   targetid = compLinkage[ii].S_objid,
		   targetos = compLinkage[ii].osnum );
	VDS_ERR_HNDLR ( "GRgraphics.GRdelete", sts, *msg, VD_VERBOSE, wrapup );
   }

   sts = om$send ( msg = message NDnode.ASreturn_go (
					&parent_sol,
					&parent_sol_env.md_env.matrix_type,
					parent_sol_env.md_env.matrix ),
			 targetid = list[0].objid,
			 targetos = list[0].osnum  );
   VDS_ERR_HNDLR("NDnode.ASreturn_go", sts, 1, VD_VERBOSE, wrapup );
   parent_sol_env.md_id.osnum = parent_sol.osnum;
   ex$get_modid (  mod_osnum = parent_sol.osnum,
		   mod_id    = &parent_sol_env.md_id.objid );

  /* Copy the parent solid to parent_copy */

   parent_copy.osnum = OM_Gw_current_OS;
   sts = om$send ( msg = message GRgraphics.GRcopy (  msg,
						      &parent_sol_env,
						      mod_env,
						      &parent_copy.objid ),
		   targetid = parent_sol.objid,
		   targetos = parent_sol.osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRcopy", sts, *msg, VD_VERBOSE, wrapup );
   __DBGpr_obj ( "parent_copy", parent_copy );

   if ( compLinkage ) free ( compLinkage );
   sts = om$get_channel_count(	osnum = parent_copy.osnum,
				objid = parent_copy.objid,
				p_chanselect = &to_components,
				count = (OMuint *) &count ) ;
   compLinkage = (OM_S_OBJECT_LINKAGE *) malloc(sizeof( OM_S_OBJECT_LINKAGE) *
								count );
   sts = om$get_channel_objects ( osnum		= parent_copy.osnum,
				  objid		= parent_copy.objid,
				  p_chanselect  = &to_components,
				  list		= compLinkage,
				  size		= count,
				  count		= (OMuint *) &count );
   VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );

   /*
    * disconnect the  components of parent_copy and connect them to solid_copy
    */
   for(ii=0; ii<count; ii++)
   {
        sts = om$send ( msg = message GRconnector.GRdisconn (
                                        	 msg, &parent_copy ),
                targetid = compLinkage[ii].S_objid,
                targetos = compLinkage[ii].osnum   );
        VDS_ERR_HNDLR ( "Root.GRdisconn", sts, *msg,  VD_VERBOSE, wrapup );
#if 0
	sts = om$send ( msg = message GRgraphics.GRcopy ( msg,
							  &parent_sol_env,
							  mod_env,
							  &surf_id.objid ),
		targetid = compLinkage[ii].S_objid,
		targetos = compLinkage[ii].osnum );
	VDS_ERR_HNDLR ( "GRgraphics.GRcopy", sts, *msg, VD_VERBOSE, wrapup );
#endif

	/*
	 *  connect solid copy and components
	 */
	sts = om$send ( msg = message GRconnector.GRrigidconn ( msg,
							   &solid_copy,
							   &ii ),
		targetid = compLinkage[ii].S_objid,
		targetos = compLinkage[ii].osnum );
	VDS_ERR_HNDLR ( "GRconnector.GRrigidconn", sts, *msg, VD_VERBOSE,
			wrapup );


   }
   if ( compLinkage ) free ( compLinkage );

   /*  delete copy of parent_solid */

   sts = om$send(msg = message Root.delete(0),
				senderid = NULL_OBJID,
				targetid = parent_copy.objid,
				targetos = parent_copy.osnum ); 

   /*
    *  change properties of copy to non_displayable, non_locatable
    */
   action = 0;
   props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   sts = om$send ( msg = message GRgraphics.GRchgprops ( msg,
					&action, &props ),
		   targetid = solid_copy.objid,
		   targetos = solid_copy.osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );

   /*
   ** Compress tree ...
   */
   {
     struct GRid        active_id, top_lm_id, tmp_id ;

     sts = om$send( msg      = message EMSsurface.EMgetactiveid(msg,
                                                                &active_id,
                                                                &top_lm_id),
                    targetid = solid_copy.objid,
                    targetos = solid_copy.osnum );
     if( sts&*msg&1 )
     {
       sts = om$send( msg      = message EMSdpr.EMmake_primitive1(msg,
                                                                  mod_env,
                                                                  &tmp_id),
                      targetid = active_id.objid,
                      targetos = active_id.osnum );
       if( sts&*msg&1 ) solid_copy.objid = tmp_id.objid;
     }
   }
   __DBGpr_obj ( "solid_copy", solid_copy );

   /* notify objects which are directly connected to me */
   GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

   /* notify objects which are connected to solid_copy */
   {
     IGRlong     ___mask;

     ___mask = GR_GEOM_MODIFIED;
     GRnotifylisteners(msg, &sts, &___mask, OPPmargs, &solid_copy.objid);
   }

wrapup:
   return sts;
}

method NDparent_deleted(IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted [];
                           struct GRid *new_obj;struct GRmd_env *mod_env)
{


   __DBGpr_com("VDviewvol : Entered NDparent_deleted");

   *msg =  MSSUCC;
   return OM_S_SUCCESS;

}


end implementation VDviewvol;
