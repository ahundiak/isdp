class implementation VDmdlview;

#include "exmacros.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"

#include "vdmemmacros.h"
#include "vderrmacros.h"
#include "vdsollocdef.h"
#include "vdmdlvwdef.h"
#include "vdvvoldef.h"
#include "vdqrydef.h"

extern  OMuword   OPP_ASsourcein_class_id,
		  OPP_VDviewvol_class_id,
		  OPP_VDquery_class_id,
		  OPP_ACpretendin_class_id;

extern  struct GRid	NULL_GRID;

from  VDviewvol  import  VDvv_give_name_desc;
from  ACrg_collect  import  ACget_named_attribute;
from  ACpretend  import  ACfind_parent;

/*+mi
Method   VDmv_give_name_desc

Abstract
  This method gives name and description of a model view.

Arguments
  IGRlong       *msg		O    return status
  char		*mv_name;	i - name of model view
			 	    = NULL if not needed
  char		*mv_desc;      i - description of model view
			 	    = NULL if not needed
Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/

method VDmv_give_name_desc(
 long		*msg;		/* o - Return status            */
 char		*mv_name;      /* i - name for model view
			 	       = NULL if not needed     */
 char		*mv_desc;      /* i - description of model view
			 	       = NULL if not needed     */
)
{

   *msg = MSSUCC;

   if ( mv_name )   strcpy ( mv_name, me^^VDmdlview.name );
   if ( mv_desc )   strcpy ( mv_desc, me^^VDmdlview.desc );

   return OM_S_SUCCESS;

}

/*+mi
Method   VDmv_set_name_desc

Abstract
  This method gives name and description of a model view.

Arguments
  IGRlong       *msg		O    return status
  char		*mv_name;	i - name for model view
			 	    = NULL if need not set
  char		*mv_desc;      i - description of model view
			 	    = NULL if need not set

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
method VDmv_set_name_desc(
 long            *msg;		/* o - Return status            */
 char            *mv_name;	/* i - name for model view
				       = NULL if need not set   */
 char            *mv_desc;     /* i - description of model view
				       = NULL if need not set   */
)
{
long sts;
int  len;
char loc_str[256];

   *msg = MSSUCC;

   if ( mv_name )
   {
	strcpy( loc_str, mv_name );
	len = strlen ( loc_str ) + 1;
	if ( len > VD_MAX_MV_NAME_LEN )
	{
	   len = VD_MAX_MV_NAME_LEN;
	   loc_str[len-1] = '\0';
	}
	sts = om$vla_set_dimension ( varray = me^^VDmdlview.name,
				     size   = len );
	strcpy ( me^^VDmdlview.name, loc_str );
   }


   if ( mv_desc )
   {
	strcpy( loc_str, mv_desc );
	len = strlen ( loc_str ) + 1;
	if ( len > VD_MAX_MV_DESC_LEN )
	{
	   len = VD_MAX_MV_DESC_LEN;
	   loc_str[len-1] = '\0';
	}
	sts = om$vla_set_dimension ( varray = me^^VDmdlview.desc,
				     size   = len );
	strcpy ( me^^VDmdlview.desc, loc_str );
   }

   return OM_S_SUCCESS;

}

/*+mi
Method   VDmv_give_vv_qry

Abstract
  This method gives roots of model view ( view volumes and queries)

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
method VDmv_give_vv_qry(
 long            *msg;		/* o - Return status */
 int		 *nb_tot_root;	/* o - no. of total roots for model view */
 int		 *nb_root_fnd;	/* o - no. of roots found */
 int		 *num_vvol;	/* o - no. of view vols in model view */
 struct GRid	 **vvol_ids;	/* o - view volume object ids.
				       = NULL, if not needed	      */
 struct GRmd_env **vvol_envs;	/* o - view volume envs.
				       = NULL, if not needed	      */
 char		 ***vvol_names;	/* o - view volume names.
				       = NULL, if not needed	      */
 char		 ***vvol_desc;	/* o - view volume desc.
				       = NULL, if not needed	      */
 int		 *num_qry;	/* o - no. of queries in model view   */
 struct GRid	 **qry_ids;	/* o - query ids.
				       = NULL, if not needed	      */
 struct GRmd_env **qry_envs;	/* o - query envs.
				       = NULL, if not needed	      */
 char		 ***qry_names;	/* o - query names.
				       = NULL, if not needed	      */
 char		 ***qry_desc;	/* o - query desc.
				       = NULL, if not needed	      */
)
{
long		sts;
struct GRid	*parents,
		vvol_id,
		sol_copy_id,
		query_id;
int		ii, vvol_cnt = 0, qry_cnt = 0,
		sizbuf, BytesRet;
OMuword		parent_classid;
struct GRmd_env vvol_env,
		mod_env,
		query_env;
char		vol_name[VD_MAX_VOL_NAME_LEN],
		vol_desc[VD_MAX_VOL_DESC_LEN];
struct ACrg_coll att;
OM_S_CHANSELECT to_owners;



  sts = OM_S_SUCCESS;
  *msg = MSSUCC;


  sizbuf = sizeof ( mod_env );
  sts = gr$get_module_env ( msg    =  msg,
			    sizbuf =  &sizbuf,
			    buffer =  &mod_env,
			    nret   =  &BytesRet );

  sts = om$send ( msg = message NDnode.NDget_objects (
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&parents,
						0,
						OM_K_MAXINT,
						nb_tot_root ),
			 targetid = my_id );
  if ( *nb_tot_root == 0 )
  {
    printf("VDmv.I : get mv_info, no. of parents = 0\n");
    goto wrapup;
  }
  /*
   * allocate memory for max possible. Later reallocate.
   */
  if ( vvol_ids )
    *vvol_ids = (struct GRid *) malloc(sizeof(struct GRid) * (*nb_tot_root));
  if ( vvol_envs )
    *vvol_envs = (struct GRmd_env *) malloc(sizeof(struct GRmd_env) *
							(*nb_tot_root));
  if ( vvol_names )
  {
    sts = vd$malloc_str_list (	str_list  = vvol_names,
				num_str   = (*nb_tot_root),
				str_size  = VD_MAX_VOL_NAME_LEN );
    if ( !sts )
    {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
    }
  }
  if ( vvol_desc )
  {
    sts = vd$malloc_str_list (	str_list  = vvol_desc,
				num_str   = (*nb_tot_root),
				str_size  = VD_MAX_VOL_DESC_LEN );
    if ( !sts )
    {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
    }
  }

  if ( qry_ids )
    *qry_ids = (struct GRid *) malloc(sizeof(struct GRid) * (*nb_tot_root));
  if ( qry_envs )
    *qry_envs = (struct GRmd_env *)
			malloc( sizeof( struct GRmd_env) * (*nb_tot_root));
  if ( qry_names )
  {
    sts = vd$malloc_str_list (	str_list  = qry_names,
				num_str   = (*nb_tot_root),
				str_size  = VD_MAX_QRY_NAME_LEN );
    if ( !sts )
    {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
    }
  }
  if ( qry_desc )
  {
    sts = vd$malloc_str_list (	str_list  = qry_desc,
				num_str   = (*nb_tot_root),
				str_size  = VD_MAX_QRY_DESC_LEN );
    if ( !sts )
    {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
    }
  }

  vvol_cnt = 0;
  qry_cnt = 0;
  for ( ii=0; ii< *nb_tot_root; ii++)
  {
	sts = om$get_classid (	objid     = parents[ii].objid,
				osnum     = parents[ii].osnum,
				p_classid = &parent_classid );

	if ( om$is_ancestry_valid ( subclassid  = parent_classid,
				superclassid = OPP_ACpretendin_class_id ) ==
							OM_S_SUCCESS )
	{
	   /* query in reference file */
	   sts = om$send ( msg = message ACpretend.ACfind_parent(
					&query_id,
					&(query_env.md_env.matrix_type),
					query_env.md_env.matrix ),
			 targetid = parents[ii].objid,
			 targetos = parents[ii].osnum  );
	  if ( !(sts&1) ) continue;
	  /* reference file is not in the directory(change of name, deletion)*/

	  if ( qry_ids ) (*qry_ids)[qry_cnt] = query_id;
	  if ( qry_envs ) (*qry_envs)[qry_cnt] = query_env;

	  strcpy( att.name, VD_qry_nmName );
	  sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
		  senderid = NULL_OBJID,
		  targetid = query_id.objid,
		  targetos = query_id.osnum);
	  VDS_ERR_HNDLR("ACrg_collect.ACget_named_attribute",
					sts, *msg, VD_VERBOSE, wrapup );

	  if( att.desc.type == AC_ATTRIB_TEXT )
	  {
	    if ( qry_names )
		strcpy( (*qry_names)[qry_cnt], att.desc.value.att_txt );
	  }
	  else
		printf("VDget_qry_list: Error getting query name\n");
	  qry_cnt++;

	  strcpy( att.name, VD_qry_nmComment );
	  sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
		  senderid = NULL_OBJID,
		  targetid = query_id.objid,
		  targetos = query_id.osnum);
	  if ( !( sts & *msg & 1 ) )
	  {  /* probably there is no comment */
	     sts = OM_S_SUCCESS;
	     *msg = MSSUCC;
	     continue;
	  }

	  if( att.desc.type == AC_ATTRIB_TEXT )
	  {
	     if ( qry_desc )
		strcpy( (*qry_desc)[qry_cnt-1], att.desc.value.att_txt );
	  }
	  else
		printf("VDget_qry_list: Error getting query comment\n");
	}	   
	else if ( om$is_ancestry_valid ( subclassid  = parent_classid,
				superclassid = OPP_ASsourcein_class_id ) ==
							OM_S_SUCCESS )
	{
	   sts = om$send ( msg = message NDnode.ASreturn_go (
					&sol_copy_id,
					&(vvol_env.md_env.matrix_type),
					vvol_env.md_env.matrix ),
			 targetid = parents[ii].objid,
			 targetos = parents[ii].osnum  );
	  if ( !(sts&1) ) continue;
	  /* reference file is not in the directory(change of name, deletion)*/
	  __DBGpr_obj ( "solid_copy :", sol_copy_id );
	  
	  sts = om$make_chanselect (	channame = "GRconnector.to_owners",
					p_chanselect = &to_owners );

	  sts = om$get_objid_at_index ( osnum  =  sol_copy_id.osnum,
					objid  =  sol_copy_id.objid,
					p_chanselect =  &to_owners,
					index  = 0,
					objidaddr = &vvol_id.objid,
					osnumaddr = &vvol_id.osnum  );
	  if ( !(sts&1) ) continue;
	  __DBGpr_obj ( "vvol_id :", vvol_id );


	  if ( vvol_ids ) (*vvol_ids)[vvol_cnt]  = vvol_id;
	  if ( vvol_envs) (*vvol_envs)[vvol_cnt] = vvol_env;
	  vvol_cnt++;

	  sts = om$send ( msg = message VDviewvol.VDvv_give_name_desc
						( msg, vol_name, vol_desc),
			  targetid = vvol_id.objid,
			  targetos = vvol_id.osnum );
	  VDS_ERR_CONTINUE ( "VDviewvol.VDvv_give_name_desc", sts, *msg,
								VD_VERBOSE );
	  if ( vvol_names) strcpy( (*vvol_names)[vvol_cnt-1], vol_name );
	  if ( vvol_desc) strcpy( (*vvol_desc)[vvol_cnt-1],  vol_desc );

	}
	else if ( om$is_ancestry_valid ( subclassid  = parent_classid,
				superclassid = OPP_VDviewvol_class_id ) ==
							OM_S_SUCCESS )
	{
	  if ( vvol_ids ) (*vvol_ids)[vvol_cnt] = parents[ii];
	  if ( vvol_envs) (*vvol_envs)[vvol_cnt] = mod_env;
	  vvol_cnt++;

	  sts = om$send ( msg = message VDviewvol.VDvv_give_name_desc
						( msg, vol_name, vol_desc),
			  targetid = parents[ii].objid,
			  targetos = parents[ii].osnum );
	  VDS_ERR_HNDLR ( "VDviewvol.VDvv_give_name_desc", sts, *msg,
							VD_VERBOSE, wrapup );
	  if ( vvol_names )strcpy( (*vvol_names)[vvol_cnt-1], vol_name );
	  if ( vvol_desc ) strcpy( (*vvol_desc)[vvol_cnt-1],  vol_desc );
	}
	else if ( om$is_ancestry_valid ( subclassid  = parent_classid,
				superclassid = OPP_VDquery_class_id ) ==
							OM_S_SUCCESS )
	{
	  if ( qry_ids ) (*qry_ids)[qry_cnt] = parents[ii];
	  if ( qry_envs ) (*qry_envs)[qry_cnt] = mod_env;

	  strcpy( att.name, VD_qry_nmName );
	  sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
		  senderid = NULL_OBJID,
		  targetid = parents[ii].objid,
		  targetos = parents[ii].osnum);
	  VDS_ERR_HNDLR("ACrg_collect.ACget_named_attribute",
					sts, *msg, VD_VERBOSE, wrapup );

	  if( att.desc.type == AC_ATTRIB_TEXT )
	  {
	    if ( qry_names )
		strcpy( (*qry_names)[qry_cnt], att.desc.value.att_txt );
	  }
	  else
		printf("VDget_qry_list: Error getting query name\n");
	  qry_cnt++;

	  strcpy( att.name, VD_qry_nmComment );
	  sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
		  senderid = NULL_OBJID,
		  targetid = parents[ii].objid,
		  targetos = parents[ii].osnum);
	  if ( !( sts & *msg & 1 ) )
	  {  /* probably there is no comment */
	     sts = OM_S_SUCCESS;
	     *msg = MSSUCC;
	     continue;
	  }

	  if( att.desc.type == AC_ATTRIB_TEXT )
	  {
	     if ( qry_desc )
		strcpy( (*qry_desc)[qry_cnt-1], att.desc.value.att_txt );
	  }
	  else
		printf("VDget_qry_list: Error getting query comment\n");
	}
  }


wrapup:
  *nb_root_fnd = vvol_cnt + qry_cnt;
  *num_vvol = vvol_cnt;
  *num_qry  = qry_cnt;

  /* free extra memory allocated */
  if ( vvol_ids )
     *vvol_ids = (struct GRid *)
			realloc( *vvol_ids, sizeof(struct GRid) * vvol_cnt);
  if ( vvol_envs )
     *vvol_envs=(struct GRmd_env *) realloc( *vvol_envs,
				sizeof(struct GRmd_env) * vvol_cnt);

  if ( vvol_names )
  {
    for(ii=vvol_cnt; ii< *nb_tot_root; ii++)
     if ( (*vvol_names)[ii] ) free ( (*vvol_names)[ii] );
    *vvol_names = (char **) realloc( *vvol_names, 
				sizeof(char *)* vvol_cnt);
  }
  if ( vvol_desc )
  {
    for(ii=vvol_cnt; ii< *nb_tot_root; ii++)
     if ( (*vvol_desc)[ii] ) free ( (*vvol_desc)[ii] );
    *vvol_desc=(char **) realloc( *vvol_desc, 
				sizeof(char *)* vvol_cnt);
  }

  if ( qry_ids )
    *qry_ids=(struct GRid *) realloc( *qry_ids, sizeof(struct GRid)* qry_cnt);
  if ( qry_names )
  {
    for(ii=qry_cnt; ii< *nb_tot_root; ii++)
      if ( (*qry_names)[ii] ) free ( (*qry_names)[ii] );
    *qry_names=(char **) realloc( *qry_names, 
				sizeof(char *)* qry_cnt);
  }
  if ( qry_desc )
  {
    for(ii=qry_cnt; ii< *nb_tot_root; ii++)
      if ( (*qry_desc)[ii] ) free ( (*qry_desc)[ii] );
    *qry_desc=(char **) realloc( *qry_desc,
				sizeof(char *)* qry_cnt);
  }

  return sts;
}

/*+mi
Method   VDmv_give_objects

Abstract
  This method gives objects having specified relation with model view
solids and which satisfy any of the queries of mv.

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
method VDmv_give_objects(
 long			*msg;		/* o - return status	*/
 char			rln_needed;	/* I - relation with model view.
					       see vdsollocdef.h	*/
 int			*num_obj;	/* I - no. of output objects	*/
 struct GRobj_env	**obj_list;	/* I - list of output object ids
					       = NULL, if not needed	*/
)
{
long			sts;
int			nb_tot_root,
			nb_root_fnd,
			num_vvol,
			num_qry;
struct	GRid		*vvol_ids = NULL,
			*qry_ids = NULL,
			solbool_id;
struct GRmd_env		*vvol_envs = NULL,
			solbool_env;



   sts = om$send ( msg = message VDmdlview.VDmv_give_vv_qry (
						msg,
						&nb_tot_root,
						&nb_root_fnd,
						&num_vvol,
						&vvol_ids,
						&vvol_envs,
						NULL,		/* names */
						NULL,		/* desc  */
						&num_qry,
						&qry_ids,
						NULL,		/* qry_envs */
						NULL,		/* names */
						NULL ),		/* desc  */
			targetid = my_id );
   VDS_ERR_HNDLR ( "VDmdlview.VDmv_give_vv_qry", sts, *msg,
						VD_VERBOSE, wrapup );

   sts = om$send ( msg = message NDnode.ASreturn_go (
					 &solbool_id,
					 &(solbool_env.md_env.matrix_type),
					 solbool_env.md_env.matrix ),
		   targetid = my_id );
   VDS_ERR_HNDLR ( "NDnode.ASreturn_go", sts, 1, VD_VERBOSE, wrapup);

   solbool_env.md_id.osnum = OM_Gw_current_OS;
   ex$get_modid (  mod_osnum = OM_Gw_current_OS,
		   mod_id    = &solbool_env.md_id.objid );

   *num_obj = 0;
   sts = VDlocateWithSolid ( 	  msg,
				  1,
				  &solbool_id,
				  &solbool_env,
				  num_qry,
				  qry_ids,
				  rln_needed,
				  VD_LIST_OF_OBJS,
				  NULL,			/* window id */
				  num_obj,
				  obj_list,
				  "Processing .." );
   VDS_ERR_HNDLR("VDlocateWithSolid", sts, *msg, VD_VERBOSE, wrapup);
   __DBGpr_int( "No. of objects wrt solid", *num_obj );

#if 0
	sts = VDgetMdlvwObjects (  msg,
				   num_vvol,
				   vvol_ids,
				   vvol_envs,
				   num_qry,
				   qry_ids,
				   rln_needed,
				   num_obj,
				   obj_list );
	VDS_ERR_HNDLR ( "VDgetMdlvwObjects", sts, *msg,	VD_VERBOSE, wrapup );

	if ( nb_tot_root != nb_root_fnd ) *msg = VD_MV_FND_LESS_ROOTS;
#endif

wrapup:
  if ( vvol_ids )  free ( vvol_ids );
  if ( vvol_envs )  free ( vvol_envs );
  if ( qry_ids )  free ( qry_ids );
  return sts;


}

/*+mi
Method   VDmv_modify

Abstract
  This method modifies a model view with the given name, desc, view vols and
queries.

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure
-mi*/
method VDmv_modify(
 long		 *msg;		/* o - Return status            */
 char		 *mv_name;	/* i - model view name		*/
 char		 *mv_desc;	/* i - model view desc		*/
 int		 num_vv;	/* i - no. of view vols in model view (new) */
 struct GRid	 *vv_list;	/* i - view volume object ids.  */
 struct GRmd_env *vv_env_list;	/* i - view volume envs.
				       = NULL, if active mod_env      */
 int		 num_qry;	/* i - no. of queries in model view (new) */
 struct GRid	 *qry_list;	/* i - query ids. */
 struct GRmd_env *qry_env_list; /* i - query env list
				       = NULL, if active mod_env      */
)
{
long			sts;
struct	GRid		*src_obj = NULL,
			*ctx_obj = NULL;
struct GRmd_env		mod_env, vv_env, qry_env;
int			numberOfBytes,
			BytesReceived,
			ii, jj ;

  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

  if ( num_vv == 0 )
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  numberOfBytes = sizeof ( struct GRmd_env );
  gr$get_module_env  (	msg     = msg,
			sizbuf  = &numberOfBytes,
			buffer  = &mod_env,
			nret    = &BytesReceived );
  /*
   * allocate memory
   */
  src_obj = (struct GRid *) malloc( sizeof(struct GRid) * (num_vv+num_qry) );
  ctx_obj = (struct GRid *) malloc( sizeof(struct GRid) * (num_vv+num_qry) );
  vv_env = mod_env;
  for ( ii=0; ii<num_vv; ii++)
  {
    if ( vv_env_list ) 	vv_env = vv_env_list[ii];

    sts = as$make_source ( go_grid  =   vv_list[ii],
			   mod_env  =   &vv_env,
			   as_os    =   mod_env.md_id.osnum,
			   as_grid  =   &src_obj[ii] );
    if ( !(sts&1) )
    {
	printf("%s : Line[%d], as$make_source failure\n", __FILE__, __LINE__);
	goto wrapup;
    }
    __DBGpr_obj("src_obj", src_obj[ii] );

    sts = GRfindcontext ( msg,
			  &vv_env.md_env.matrix_type,
			  vv_env.md_env.matrix,
			  &(vv_list[ii].osnum),
			  &ctx_obj[ii] );
    if( !( sts && *msg && 1 ) )  ctx_obj[ii].objid = NULL_OBJID;
  }

  qry_env = mod_env;
  for ( ii=0; ii<num_qry; ii++)
  {
    jj = num_vv + ii;

    if ( qry_env_list ) qry_env = qry_env_list[ii];
    sts = as$make_source ( go_grid  =   qry_list[ii],
			   mod_env  =   &qry_env,
			   as_os    =   mod_env.md_id.osnum,
			   as_grid  =   &src_obj[jj] );
    if ( !(sts&1) )
    {
	printf("%s : Line[%d], as$make_source failure\n", __FILE__, __LINE__);
	goto wrapup;
    }
    __DBGpr_obj("src_obj", src_obj[jj] );

    sts = GRfindcontext ( msg,
			  &qry_env.md_env.matrix_type,
			  qry_env.md_env.matrix,
			  &(qry_list[ii].osnum),
			  &ctx_obj[jj] );
    if( !( sts & *msg & 1 ) )
	ctx_obj[jj].objid = NULL_OBJID;
  }

  sts = om$send ( msg = message NDnode.NDconnect(
				num_vv + num_qry,
				src_obj,
				NULL_GRID,
				ND_FULL ),
		  targetid = my_id );
  VDS_ERR_HNDLR("NDnode.NDconnect", sts, MSSUCC, VD_VERBOSE, wrapup);

  sts = om$send ( msg = message NDnode.NDcompute_node ( msg,
							0,
							num_vv+num_qry,
							src_obj,
							&mod_env ),
		  targetid = my_id );
  VDS_ERR_HNDLR("NDnode.NDcompute_node", sts, *msg, VD_VERBOSE, wrapup);

  sts = om$send ( msg = message VDmdlview.VDmv_set_name_desc (
						msg,
						mv_name,
						mv_desc ),
		  targetid = my_id );
  VDS_ERR_HNDLR("VDmdlview.VDmv_set_name_desc", sts, *msg, VD_VERBOSE, wrapup);

wrapup:
  if ( src_obj ) free ( src_obj );
  if ( ctx_obj ) free ( ctx_obj );
  return sts;
}

/*+mi
Method   VDmv_display_solid

Abstract
  This method displays boolean solid of the model view.

Arguments
  IGRlong		*msg		O    return status
  enum GRdpmode		*dpmode		I    display mode ( GRhd, GRbdhe )

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

-mi*/
method VDmv_display_solid (
 long		  *msg;
 enum GRdpmode	  *dpmode;
)
{
long		sts;
struct GRid	solbool, md_id;
struct GRmd_env solbool_env;
short		action, props;


  sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  sts = om$send( msg = message NDnode.ASreturn_go (
					&solbool,
					&(solbool_env.md_env.matrix_type),
					solbool_env.md_env.matrix ),
		  targetid = my_id );
  VDS_ERR_HNDLR( "NDnode.ASreturn_go", sts, 1, VD_VERBOSE, wrapup );

  action = 1;
  props = GRIS_DISPLAYABLE;
  sts = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action, &props ),
		   targetid = solbool.objid,
		   targetos = solbool.osnum );
  VDS_ERR_HNDLR( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );

  ex$get_cur_mod(id = &md_id.objid, osnum = &md_id.osnum);
  sts = om$send ( msg = message GRgraphics.GRdisplay (
				msg,
				&(solbool_env.md_env.matrix_type),
				solbool_env.md_env.matrix,
				dpmode,
				&md_id ),
		  targetid = solbool.objid,
		  targetos = solbool.osnum  );

  action = 0;
  props = GRIS_DISPLAYABLE;
  sts = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action, &props ),
		   targetid = solbool.objid,
		   targetos = solbool.osnum );
  VDS_ERR_HNDLR( "GRgraphics.GRchgprops", sts, *msg, VD_VERBOSE, wrapup );

wrapup:
  return sts;

}

end implementation VDmdlview;

