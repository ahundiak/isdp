class implementation Root;

/*+fe
Function   VDgetVVolList()

Abstract
  This function gives list of view volumes defined in active
  and reference files ( including nested reference files).

Arguments
  IGRlong               *msg          O    return status
  int			*num_vvol     O    number of view vols found.
  struct GRid		**vvol_ids    O    list of view vol ids.
					   = NULL, if not needed.
  struct GRmd_env	**vvol_env    O    list of mod env of view vols.
					   = NULL, if not needed.
  char			***vvol_names O    list of names of view vols.
					   = NULL, if not needed.
  char			***vvol_desc  O    list of desc of view vols.
					   = NULL, if not needed.
IMPORTANT
  This function allocates memory for vvol_ids, vvol_env, vvol_names
  and vvol_desc. These should be freed by caller ( see following program).

     if ( vvol_ids ) free (vvol_ids);
     if ( vvol_env ) free (vvol_env);
     if ( vvol_names )
     {
	for(ii=0; ii<num_vvol; ii++) free( vvol_names[ii] );
	free ( vvol_names );
     }
     if ( vvol_desc )
     {
	for(ii=0; ii<num_vvol; ii++) free( vvol_desc[ii] );
	free ( vvol_desc );
     }

Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   11-03-1994  Raju   Creation
-fe*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vdvvoldef.h"
#include "vdmemmacros.h"
#include "vderrmacros.h"
#include "vdrefmacros.h"

#define  VD_STEP_SIZE   30


from  VDviewvol  import  VDvv_give_solid;
from  VDviewvol  import  VDvv_give_name_desc;


long VDgetVVolList (
  long			*msg,
  int			*num_vvol,
  struct GRid		**vvol_ids,
  struct GRmd_env	**vvol_env,
  char			***vvol_names,
  char			***vvol_desc
)
{
long			sts;
struct GRmd_env		mod_env,
			*RefEnvList = NULL,
			*loc_env = NULL,
			solid_env;
OMuint			count;
int			NbOs,
			ListSize, loc_num = 0,
			ii, jj,	ii1, sizbuf,
			NoBytesRet;
GRspacenum		*OsList = NULL;
struct GRid		*loc_ids = NULL,
			VolMgr,
			solid;
OM_S_OBJECT_LINKAGE	*vvols = NULL;

char			**loc_names = NULL,
			**loc_desc  = NULL,
			tmp_name[VD_MAX_VOL_NAME_LEN],
			tmp_desc[VD_MAX_VOL_DESC_LEN];
OM_S_CHANSELECT		to_components;


   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   sizbuf = sizeof( struct GRmd_env );
   gr$get_module_env (  msg       = msg,
			sizbuf    = &sizbuf,
			buffer    = &mod_env,
			nret      = &NoBytesRet );

   /* Initialization */
   ListSize = VD_STEP_SIZE;
   if ( vvol_ids )
      loc_ids = (struct GRid *) malloc ( sizeof(struct GRid) * ListSize );
   if ( vvol_env )
      loc_env = 
	(struct GRmd_env *) malloc ( sizeof(struct GRmd_env) * ListSize );
   if ( vvol_names )
   {
     sts = vd$malloc_str_list ( str_list  = &loc_names,
				num_str   = ListSize,
				str_size  = VD_MAX_VOL_NAME_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   if ( vvol_desc )
   {
     sts = vd$malloc_str_list ( str_list  = &loc_desc,
				num_str   = ListSize,
				str_size  = VD_MAX_VOL_DESC_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   loc_num = 0;

   sts = om$make_chanselect (   channame = "GRcmpowner.to_components",
				p_chanselect = &to_components );

   /*
    * get view volumes in active file
    */

   sts = VDget_vol_mgr ( NULL, &VolMgr );
   if ( !(sts&1) )
   {
      /* No view vol manager in active file. Means no view vols.
       * Look in the reference files.
       */
      goto PROCESS_REF_FILES;
   }

   sts = om$get_channel_count(  objid		=   VolMgr.objid,
				osnum		=   VolMgr.osnum,
				p_chanselect	=   &to_components,
				count		=   &count );
   __DBGpr_int( "No. of vvols", count );
   if ( count == 0 ) goto PROCESS_REF_FILES;

   vvols = (OM_S_OBJECT_LINKAGE *) malloc( count *
					   sizeof(OM_S_OBJECT_LINKAGE) );

   sts = om$get_channel_objects(  objid		=  VolMgr.objid,
				  osnum		=  VolMgr.osnum,
				  p_chanselect	=  &to_components,
				  list		=  vvols,
				  size		=  count,
				  count		=  &count );

   for ( ii=0; ii < count; ii++ )
   {
      sts = om$send ( msg = message VDviewvol.VDvv_give_solid (
						msg,
						&solid,
						&solid_env ),
		      senderid = NULL_OBJID,
		      targetid = vvols[ii].S_objid,
		      targetos = vvols[ii].osnum );
      /* if ( !(sts&1) ) -> solid is in reference file to this
       *		    file. The reference file is not active.
       */
      if ( !(sts&1) ) continue;

      if ( loc_num == ListSize )
      {
	ListSize += VD_STEP_SIZE;
	if ( vvol_ids )
	  loc_ids = (struct GRid *) realloc ( loc_ids,
					sizeof(struct GRid) * ListSize );

	if ( vvol_env )
	  loc_env = (struct GRmd_env *) realloc ( loc_env,
					sizeof(struct GRmd_env) * ListSize );
	if ( vvol_names )
	{
	   loc_names = (char **) realloc ( loc_names,
					sizeof(char *) * ListSize );
	   for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++)
	     loc_names[ii1] =
		    (char *) malloc ( sizeof(char) * VD_MAX_VOL_NAME_LEN);
	}
	if ( vvol_desc )
	{
	   loc_desc = (char **) realloc ( loc_desc,
					sizeof(char *) * ListSize );
	   for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++)
		loc_desc[ii1] =
			(char *) malloc ( sizeof(char) * VD_MAX_VOL_DESC_LEN);
	}
      }

      if ( vvol_ids )
      {
	     loc_ids[loc_num].objid = vvols[ii].S_objid;
             loc_ids[loc_num].osnum = vvols[ii].osnum;
      }
      if ( vvol_env )
	     loc_env[loc_num] = mod_env;
      if ( vvol_names || vvol_desc )
      {
	sts = om$send ( msg = message VDviewvol.VDvv_give_name_desc (
						msg,
						tmp_name,
						tmp_desc   ),
		       senderid = NULL_OBJID,
		       targetid = vvols[ii].S_objid,
		       targetos = vvols[ii].osnum );
	VDS_ERR_RPT("VDviewvol.VDvv_give_name_desc", sts, *msg, VD_VERBOSE );

	if ( vvol_names )
	  strcpy( loc_names[loc_num], tmp_name );

	if ( vvol_desc )
	  strcpy( loc_desc[loc_num], tmp_desc );
      }
      loc_num++;
   }

   if ( vvols ) { free ( vvols ); vvols = NULL; }

PROCESS_REF_FILES:
   /*
    * get view volumes in reference files
    */

   /* get list of reference spaces that are active */
   sts =  vd$get_ref_os_list (	msg		= msg,
				main_os		= &mod_env.md_id.osnum,
				num_ref_os	= &NbOs,
				ref_os_list	= &OsList,
				ref_env_list	= &RefEnvList );

   __DBGpr_int("No. of distinct reference files connected", NbOs);
#ifdef  VDS_DBG
   for(ii=0; ii<NbOs; ii++)
   {
      printf("Osnum[%d] = [%d]\n", ii, OsList[ii]);
   }
#endif

   for(ii=0; ii<NbOs; ii++)
   {
      /*
       * get view vol manager in reference file
       */

       __DBGpr_int("Processing OS", OsList[ii]);

       sts = VDget_vol_mgr( &OsList[ii], &VolMgr);
       if ( !(sts&1) ) /* there is no view vol manager in reference file */
       {
	     sts = OM_S_SUCCESS;
	     continue;
       }
       __DBGpr_obj("Mgr Obj", VolMgr);

	sts = om$get_channel_count(  objid		=   VolMgr.objid,
				     osnum		=   VolMgr.osnum,
				     p_chanselect	=   &to_components,
				     count		=   &count );
	__DBGpr_int( "No. of vvols", count );
	if ( count == 0 ) continue;

	vvols = (OM_S_OBJECT_LINKAGE *) malloc( count *
					   sizeof(OM_S_OBJECT_LINKAGE) );

	sts = om$get_channel_objects(  objid		=  VolMgr.objid,
				       osnum		=  VolMgr.osnum,
				       p_chanselect	=  &to_components,
				       list		=  vvols,
				       size		=  count,
				       count		=  &count );

	for ( jj=0; jj < count; jj++ )
	{
	  sts = om$send ( msg = message VDviewvol.VDvv_give_solid (
						msg,
						&solid,
						&solid_env ),
		       senderid = NULL_OBJID,
		       targetid = vvols[jj].S_objid,
		       targetos = vvols[jj].osnum );
	 /* if ( !(sts&1) ) -> solid is in reference file to this
	  *		    file. The reference file is not active.
	  */
	  if ( !(sts&1) )
	  {
	     sts = OM_S_SUCCESS;
	     continue;
	  }

	  if ( loc_num == ListSize )
	  {
	    ListSize += VD_STEP_SIZE;
	    if ( vvol_ids )
	       loc_ids = (struct GRid *) realloc ( loc_ids,
					sizeof(struct GRid) * ListSize );

	    if ( vvol_env )
	       loc_env = (struct GRmd_env *) realloc ( loc_env,
					sizeof(struct GRmd_env) * ListSize );
	    if ( vvol_names )
	    {
	       loc_names = (char **) realloc ( loc_names,
					sizeof(char *) * ListSize );
	       for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++)
	         loc_names[ii1] =
		    (char *) malloc ( sizeof(char) * VD_MAX_VOL_NAME_LEN);
	    }
	    if ( vvol_desc )
	    {
	       loc_desc = (char **) realloc ( loc_desc,
					sizeof(char *) * ListSize );
	       for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++)
		 loc_desc[ii1] =
			(char *) malloc ( sizeof(char) * VD_MAX_VOL_DESC_LEN);
 	    }
          }

          if ( vvol_ids )
	  {
	     loc_ids[loc_num].objid = vvols[jj].S_objid;
             loc_ids[loc_num].osnum = vvols[jj].osnum;
	  }
	  if ( vvol_env )
	     loc_env[loc_num] = RefEnvList[ii];
	  if ( vvol_names || vvol_desc )
          {
	     sts = om$send ( msg = message VDviewvol.VDvv_give_name_desc (
						msg,
						tmp_name,
						tmp_desc   ),
		       senderid = NULL_OBJID,
		       targetid = vvols[jj].S_objid,
		       targetos = vvols[jj].osnum );
	    VDS_ERR_RPT("VDviewvol.VDvv_give_name_desc", sts,*msg, VD_VERBOSE );

	    if ( vvol_names )
	       strcpy( loc_names[loc_num], tmp_name );

	    if ( vvol_desc )
	      strcpy( loc_desc[loc_num], tmp_desc );
	  }
	  loc_num++;
	}

	if ( vvols ) { free ( vvols ); vvols = NULL; }
   }

wrapup:
   *num_vvol = loc_num;
   if ( vvol_ids ) *vvol_ids = loc_ids;
   if ( vvol_env ) *vvol_env = loc_env;
   if ( vvol_names ) *vvol_names = loc_names;
   if ( vvol_desc ) *vvol_desc = loc_desc;

   if ( OsList ) free ( OsList );
   if ( RefEnvList ) free ( RefEnvList );

   __DBGpr_int( "No. of View volumes found", *num_vvol );
#ifdef VDS_DBG
   if ( vvol_ids )
     for ( ii=0; ii< *num_vvol; ii++)
       printf(" Vol obj id[%d] : [%d,%d]\n", ii, (*vvol_ids)[ii].osnum,
						(*vvol_ids)[ii].objid  );
   if ( vvol_names )
     for ( ii=0; ii< *num_vvol; ii++)
       printf(" Vol name[%d] : [%s]\n", ii, (*vvol_names)[ii] );
      
#endif
   return sts;

}

end implementation Root;
