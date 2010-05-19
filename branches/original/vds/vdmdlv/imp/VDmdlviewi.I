class implementation VDmdlview;

/*+mi
Doc

 This file contains overridden methods of VDmdlview

 NDplace :  When a model view is created.
 NDcompute_node : when parent is modified.
 NDparent_deleted

-mi*/

#include "nddef.h"
#include "vderrmacros.h"
#include "exmacros.h"

#include "igrdp.h"
#include "parametric.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gocmacros.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"


extern  struct GRid   NULL_GRID;
extern  OMuword	      OPP_VDquery_class_id,
		      OPP_VDviewvol_class_id,
		      OPP_EMSslboolean_class_id,
		      OPP_EMSsolid_class_id,
		      OPP_ASsourcein_class_id,
		      OPP_ACpretendin_class_id;

from  EMSsfboolean	import  EMboolean;
from  EMSsurface	import  EMgetactiveid;
from  EMSdpr		import  EMmake_primitive1;


method  NDplace (
  struct GRas		*asso_lis;
  struct GRmd_env	*mod_env;
  char			*go_cnst_lis
)
{
long		sts, loc_msg;
struct GRid	*parent_list = NULL,
		my_grid,
		MdlvwMgr;
IGRlong		index, flag;
int		ii;


   __DBGpr_com("VDmdlviewi.I : Entered NDplace");
   sts = OM_S_SUCCESS;

   if ( asso_lis->num_parents == 0 )
   {
	printf("VDmdlview.NDplace : num of parents = 0\n" );
	sts = OM_E_ABORT;
	goto wrapup;
   }

   parent_list = (struct GRid *) malloc( sizeof(struct GRid) *
					 asso_lis->num_parents);
   if ( parent_list == NULL )
   {
	sts = OM_E_ABORT;
	goto wrapup;
   }

   for ( ii=0; ii< asso_lis->num_parents; ii++ )
   {
      parent_list[ii].objid = asso_lis->parents[ii].objid;
      parent_list[ii].osnum = asso_lis->parents[ii].osnum;
   }

   /*
    * compute node
    */
   sts = om$send( msg = message NDnode.NDcompute_node(	&loc_msg,
							0,
							asso_lis->num_parents,
							parent_list,
							mod_env),
		 targetid = my_id);
   VDS_ERR_HNDLR ( "NDnode.NDcompute_node", sts, loc_msg, VD_VERBOSE, wrapup );

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
    * get model view manager and connect myself to it
    */
   sts = VDget_mdlvw_mgr ( &(mod_env->md_id.osnum), &MdlvwMgr );
   VDS_ERR_HNDLR("VDget_mdlvw_mgr", sts, 1, VD_VERBOSE, wrapup);

   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;

   flag = 1;
   index = OM_K_MAXINT;
   sts = om$send( msg = message GRconnector.GRflexconn( &loc_msg, &flag,
					   &MdlvwMgr, &index, &index ),
		  senderid = NULL_OBJID,
		  targetid = my_id,
		  targetos = OM_Gw_current_OS );
   VDS_ERR_HNDLR("GRconnector.GRflexconn", sts, loc_msg, VD_VERBOSE, wrapup);


wrapup:
   if ( parent_list ) free ( parent_list );
   __DBGpr_com("VDmdlviewi.I : Leaving NDplace");
   return sts;

}

method  NDcompute_node ( IGRlong	 *msg;
			 IGRint		 cn_type;
			 int		 count;
			 struct GRid	 *list;
			 struct GRmd_env *mod_env )
{
long			sts;
struct GRid		solbool_old,
			solbool,
			my_grid,
			par_go_id,
			active_id, top_lm_id, tmp_id;
GRobjid			*solid_list = NULL;
struct GRmd_env	  	par_go_env, cp_env;
OM_S_CHANSELECT   	to_components,
		  	to_owners;
IGRlong		  	index;
struct GRvg_construct	cst;
int			nb_vvol, overlap,
			jj, numberOfBytes,
			BytesReceived, cnt;
OMuword			parent_classid, par_go_classid;
IGRshort		level;
struct IGRdisplay	disp;
OM_S_OBJECT_LINKAGE	*compLinkage = NULL;
long			ii;
IGRshort		action, props;


   __DBGpr_com("VDviewvol : Entered NDcompute_node");
   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   /*
    * disconnect old solid bolean( if exists )  from components channel
    */
   sts = om$make_chanselect (   channame = "GRcmpowner.to_components",
				p_chanselect = &to_components );

   sts = om$make_chanselect (   channame = "GRconnector.to_owners",
				p_chanselect = &to_owners );

   sts = om$get_objid_at_index (  objid  =  my_id,
				  p_chanselect =  &to_components,
				  index  = 0,
				  objidaddr = &solbool_old.objid,
				  osnumaddr = &solbool_old.osnum  );
   if ( (sts&1) )
   {
     __DBGpr_obj("solbool_old", solbool_old);

     action = 1;
     props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     sts = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action,
								   &props ),
		   targetid = solbool_old.objid,
		   targetos = solbool_old.osnum );
     VDS_ERR_HNDLR ( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );

     /*
      *  Delete components of old solid boolean
      */
     sts = om$get_channel_count( osnum = solbool_old.osnum,
				 objid = solbool_old.objid,
				 p_chanselect = &to_components,
				 count = (OMuint *) &cnt ) ;

     compLinkage = (OM_S_OBJECT_LINKAGE *) malloc(sizeof( OM_S_OBJECT_LINKAGE) *
								cnt );
     sts = om$get_channel_objects ( osnum	= solbool_old.osnum,
				  objid		= solbool_old.objid,
				  p_chanselect  = &to_components,
				  list		= compLinkage,
				  size		= cnt,
				  count		= (OMuint *) &cnt );
     VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );

     for(ii=0; ii<cnt; ii++)
     {
	sts = om$send ( msg = message GRgraphics.GRdelete ( msg, mod_env ),
		   targetid = compLinkage[ii].S_objid,
		   targetos = compLinkage[ii].osnum );
	VDS_ERR_HNDLR ( "GRgraphics.GRdelete", sts, *msg, VD_VERBOSE, wrapup );
     }
   }
   else
   {
     solbool_old.objid = NULL_OBJID;
   }


   /*
    * construct new solid boolean
    */
   nb_vvol = 0;
   for(ii=0; ii<count; ii++)
   {
      sts = om$get_classid ( objid     = list[ii].objid,
			     osnum     = list[ii].osnum,
			     p_classid = &parent_classid );

      if ( om$is_ancestry_valid ( subclassid   = parent_classid,
				  superclassid = OPP_VDquery_class_id ) ==
							OM_S_SUCCESS )
	continue;

      if ( om$is_ancestry_valid ( subclassid   = parent_classid,
				  superclassid = OPP_ACpretendin_class_id ) ==
							OM_S_SUCCESS )
	continue;  /* query in ref file */


      if ( om$is_ancestry_valid ( subclassid   = parent_classid,
				  superclassid = OPP_VDviewvol_class_id ) ==
							OM_S_SUCCESS )
      {
	nb_vvol++;
	continue;
      }
      else if ( om$is_ancestry_valid ( subclassid   = parent_classid,
				  superclassid = OPP_ASsourcein_class_id ) ==
							OM_S_SUCCESS )
      {
	sts = om$send ( msg = message NDnode.ASreturn_go (
					&par_go_id,
					&(par_go_env.md_env.matrix_type),
					par_go_env.md_env.matrix ),
			targetid = list[ii].objid,
			targetos = list[ii].osnum  );
	VDS_ERR_HNDLR("NDnode.ASreturn_go", sts, 1, VD_VERBOSE, wrapup );

	sts = om$get_classid (	objid     = par_go_id.objid,
				osnum     = par_go_id.osnum,
				p_classid = &par_go_classid );

	if ( om$is_ancestry_valid ( subclassid   = par_go_classid,
				    superclassid = OPP_EMSsolid_class_id ) ==
							OM_S_SUCCESS )
	{
	  nb_vvol++;
	  continue;
	}
      }
   } /* for(ii=0; ii<count; ii++) */

   if ( nb_vvol == 0 )
   {
	sts = OM_E_ABORT;
	*msg = MSFAIL;
	printf("%s[%d] : Invalid arguments\n", __FILE__, __LINE__ );
	goto wrapup;
   }

   solid_list = (GRobjid *) malloc( sizeof(GRobjid) * nb_vvol );

   /* copy the solids of view volumes */
   jj = 0;
   cp_env = *mod_env;
   cp_env.md_id.objid = NULL_OBJID;
   for ( ii=0; ii<count; ii++)
   {
      sts = om$get_classid ( objid     = list[ii].objid,
			     osnum     = list[ii].osnum,
			     p_classid = &parent_classid );

      if ( om$is_ancestry_valid ( subclassid   = parent_classid,
				  superclassid = OPP_VDquery_class_id ) ==
							OM_S_SUCCESS )
	continue;

      if ( om$is_ancestry_valid ( subclassid   = parent_classid,
				  superclassid = OPP_ACpretendin_class_id ) ==
							OM_S_SUCCESS )
	continue; /* query in ref file */


      sts = om$send ( msg = message NDnode.ASreturn_go (
					&par_go_id,
                                        &(par_go_env.md_env.matrix_type),
					par_go_env.md_env.matrix ),
		      targetid = list[ii].objid,
		      targetos = list[ii].osnum  );
      if ( sts == OM_W_REJECTED_METHOD )  /* happens when it is a query and
					 it is in local file */
	  continue;
      VDS_ERR_HNDLR("NDnode.ASreturn_go", sts, 1, VD_VERBOSE, wrapup );

      sts = om$get_classid ( objid     = par_go_id.objid,
			     osnum     = par_go_id.osnum,
			     p_classid = &par_go_classid );

      if ( om$is_ancestry_valid ( subclassid   = par_go_classid,
				  superclassid = OPP_EMSsolid_class_id ) !=
							OM_S_SUCCESS )
		continue;

      par_go_env.md_id.osnum = par_go_id.osnum;
      ex$get_modid ( mod_osnum = par_go_id.osnum,
		     mod_id    = &par_go_env.md_id.objid );

      /* create a copy of the solid */
      sts = om$send(msg = message GRgraphics.GRcopy( msg, &par_go_env,
					&cp_env, &solid_list[jj] ),
		    targetid = par_go_id.objid,
		    targetos = par_go_id.osnum);
      jj++;
   }

   if ( nb_vvol == 1 )
   {
     solbool.objid = solid_list[0];
     solbool.osnum = OM_Gw_current_OS;

     /*
     ** Compress tree ... 
     */
     sts = om$send( msg      = message EMSsurface.EMgetactiveid(msg,
                                                                &active_id,
                                                                &top_lm_id),
                    targetid = solbool.objid,
                    targetos = solbool.osnum );
     if( sts&*msg&1 )
     {
       sts = om$send( msg      = message EMSdpr.EMmake_primitive1(msg,
                                                                  &cp_env,
                                                                  &tmp_id),
                      targetid = active_id.objid,
                      targetos = active_id.osnum );
       if( sts&*msg&1 ) solbool.objid = tmp_id.objid;
     }
     __DBGpr_obj ( "solbool", solbool );

     sts = om$change_class ( objid = solbool.objid,
			     classname = "EMSgensolid" );
     VDS_ERR_HNDLR( "om$change_class", sts, 1, VD_VERBOSE, wrapup );
   }
   else
   {
	enum EMSbooltype	bool_type;
	char			status_str[80];
	unsigned short		option;
	int			indx;
	struct GRid		prev_bool;

	/* create an union solid */

	/* A boolean operation must be done (no RTREE) */
	numberOfBytes = sizeof ( IGRshort );
	gr$get_active_layer(	msg     = msg,
				sizbuf  = &numberOfBytes,
				buffer  = &level,
				nret    = &BytesReceived );

	numberOfBytes = sizeof ( struct IGRdisplay );
	gr$get_active_display(	msg     = msg,
				sizbuf  = &numberOfBytes,
				buffer  = &disp,
				nret    = &BytesReceived );

	cst.msg      = msg;
	cst.env_info = &cp_env;
	cst.display  = &disp;
	cst.geometry = NULL;
	cst.newflag  = FALSE;
	cst.level    = level;
	cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
	cst.class_attr = NULL;
	cst.name       = NULL;

	tmp_id.osnum = cp_env.md_id.osnum;
	sts = om$construct( classid = OPP_EMSslboolean_class_id,
			    osnum   = tmp_id.osnum,
			    p_objid = &tmp_id.objid );
	if(!(sts & 1)) goto wrapup;

	option =  EMSsfbool_opt_retryDisjoint | EMSsfbool_opt_noredraw |
		  EMSsfbool_opt_HandleStop;

	bool_type      =  EMSbool_union;
	status_str[0]  = '\0';

	sts = om$send(msg = message EMSsfboolean.EMboolean( msg, 
		&cp_env.md_env.matrix_type, cp_env.md_env.matrix, 
		solid_list[0], 1, &solid_list[1], &cst,
		bool_type, option, status_str, NULL, NULL, NULL, NULL),
	      targetid = tmp_id.objid,
	      targetos = tmp_id.osnum  );
	if(!(sts & 1))
	{
	  printf("Modelview, error making the boolean union\n");
	  goto wrapup;
	}


	if ( nb_vvol > 2 )
	{
	   prev_bool = tmp_id;
	   for ( indx=2; indx<nb_vvol; indx++ )
	   {
	     tmp_id.objid = NULL_OBJID;
	     sts = om$construct( classid = OPP_EMSslboolean_class_id,
			    osnum   = tmp_id.osnum,
			    p_objid = &tmp_id.objid );
	     if(!(sts & 1)) goto wrapup;

	     sts = om$send(msg = message EMSsfboolean.EMboolean( msg,
		   &cp_env.md_env.matrix_type, cp_env.md_env.matrix,
		   prev_bool.objid, 1, &solid_list[indx], &cst,
		   bool_type, option, status_str, NULL, NULL, NULL, NULL),
		   targetid = tmp_id.objid,
		   targetos = tmp_id.osnum  );
	     if(!(sts & 1))
	     {
		printf("Modelview, error making the boolean union\n");
		goto wrapup;
	     }
	     prev_bool = tmp_id;
	   } /* for ( indx=2; indx<nb_vvol; indx++ ) */
	} /* if ( nb_vvol > 2 ) */

	/* printf("status_str: %s\n", status_str); */
	if(*msg != EMS_I_DisjointElements ||
	   *msg != EMS_I_EmptySet) overlap = 1;
	if(!(*msg&1)) {printf("Boolean union failed\n"); goto wrapup;}

	/* To be sure to get the top dpr */
	sts = om$send(msg = message EMSsurface.EMgetactiveid(msg, 
				&active_id, &top_lm_id),
		   targetid = tmp_id.objid,
		   targetos = tmp_id.osnum);
	if(!(sts & *msg & 1)) 
	{ 
	  printf("Warning getting the top dpr\n");
	  active_id = tmp_id;
	}

	/* This compress the dpr tree and compress the range box */
	sts = om$send(msg = message EMSdpr.EMmake_primitive1(
					 msg, &cp_env, &solbool),
		   targetid = active_id.objid,
		   targetos = active_id.osnum);
	VDS_ERR_HNDLR( "EMSdpr.EMmake_primitive1", sts, *msg, VD_VERBOSE,
		    wrapup );

  }


  /*
   *  change properties of copy to non_displayable, non_locatable
   */
/*  
IGRshort		action, props;
  action = 0;
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  sts = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action, &props ),
		   targetid = tmp_id.objid,
		   targetos = tmp_id.osnum );
  VDS_ERR_HNDLR ( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );
*/

  if ( solbool_old.objid == NULL_OBJID )
  {
    /* add solid boolean to range tree */
    sts = om$send ( msg = message GRgraphics.GRaddwrng ( msg, mod_env ),
		  targetid = solbool.objid,
		  targetos = solbool.osnum );
    VDS_ERR_HNDLR( "GRgraphics.GRaddwrng", sts, *msg, VD_VERBOSE, wrapup );

    /*
     *  connect myself and solid boolean
     */
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    index = 0; 
    sts = om$send ( msg = message GRconnector.GRrigidconn ( msg,
							    &my_grid,
							    &index ),
		   targetid = solbool.objid,
		   targetos = solbool.osnum );
    VDS_ERR_HNDLR ( "GRconnector.GRrigiconn", sts, *msg, VD_VERBOSE, wrapup );

    action = 0;
    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    sts = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action,
								   &props ),
		   targetid = solbool.objid,
		   targetos = solbool.osnum );
    VDS_ERR_HNDLR ( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );
  }
  else
  {
    sts = om$get_channel_count(	osnum = solbool.osnum,
				objid = solbool.objid,
				p_chanselect = &to_components,
				count = (OMuint *) &cnt ) ;

    if ( compLinkage ) free ( compLinkage );
    compLinkage = (OM_S_OBJECT_LINKAGE *) malloc(sizeof( OM_S_OBJECT_LINKAGE) *
								cnt );
    sts = om$get_channel_objects (osnum		= solbool.osnum,
				  objid		= solbool.objid,
				  p_chanselect  = &to_components,
				  list		= compLinkage,
				  size		= cnt,
				  count		= (OMuint *) &cnt );
    VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );

    for(ii=0; ii<cnt; ii++)
    {
      sts = om$send ( msg = message GRconnector.GRdisconn (
					 msg, &solbool ),
		targetid = compLinkage[ii].S_objid,
		targetos = compLinkage[ii].osnum   );
      VDS_ERR_HNDLR ( "Root.GRdisconn", sts, *msg,  VD_VERBOSE, wrapup );

      /*
       *  connect solid boolean and components
       */
      sts = om$send ( msg = message GRconnector.GRrigidconn ( msg,
							      &solbool_old,
							      &ii ),
		targetid = compLinkage[ii].S_objid,
		targetos = compLinkage[ii].osnum   );
      VDS_ERR_HNDLR ( "GRconnector.GRrigidconn", sts, *msg, VD_VERBOSE,
		      wrapup );
    }

    /* add solid boolean to range tree */
    sts = om$send ( msg = message GRgraphics.GRaddwrng ( msg, mod_env ),
		  targetid = solbool_old.objid,
		  targetos = solbool_old.osnum );
    VDS_ERR_HNDLR( "GRgraphics.GRaddwrng", sts, *msg, VD_VERBOSE, wrapup );

    action = 0;
    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    sts = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action,
								   &props ),
		   targetid = solbool_old.objid,
		   targetos = solbool_old.osnum );
    VDS_ERR_HNDLR ( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );

    /* notify objects which are directly connected to me */
    GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

    /* notify objects which are connected to solbool */
    {
      IGRlong     ___mask;

      ___mask = GR_GEOM_MODIFIED;
      GRnotifylisteners(msg, &sts, &___mask, OPPmargs, &solbool_old.objid);
    }

  }

wrapup:
   if ( solid_list ) free ( solid_list );
   if ( compLinkage ) free ( compLinkage );
   return sts;
}

#if 0
method NDparent_deleted(IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted [];
                           struct GRid *new_obj;struct GRmd_env *mod_env)
{


   __DBGpr_com("VDviewvol : Entered NDparent_deleted");

   *msg =  MSSUCC;
   return OM_S_SUCCESS;

}
#endif

end implementation VDmdlview;
