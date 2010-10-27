/* $Id: VDgetMVlist.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmdlv/func / VDgetMVlist.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgetMVlist.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  18:49:48  pinnacle
# UnInit Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/08/23  23:39:18  pinnacle
# Replaced: vdmdlv/func/*.I for:  by tlbriggs for vds.240
#
 *
 * History:
 *  	11-03-1994  Raju   	Creation
 *    	08/23/95    tlb		Modified to use _MALLOC, _FREE
 *	10/31/97    ah          UnInit warnings
 *
 *************************************************************************/
class implementation Root;

/*+fe
Function   VDgetMVlist()

Abstract
  This function gives list of model views defined in active
  and reference files ( including nested reference files).

Arguments
  IGRlong               *msg          O    return status
  int			*num_mdlv     O    number of model views found.
  struct GRid		**mdlv_ids    O    list of model view ids.
					   = NULL, if not needed.
  struct GRmd_env	**mdlv_env    O    list of mod env of model views.
					   = NULL, if not needed.
  char			***mdlv_names O    list of names of model views.
					   = NULL, if not needed.
  char			***mdlv_desc  O    list of desc of model views.
					   = NULL, if not needed.
IMPORTANT
  This function allocates memory for mdlv_ids, mdlv_env, mdlv_names
  and mdlv_desc. These should be freed by caller ( see following program).

     _FREE (mdlv_ids);
     _FREE (mdlv_env);
     if ( mdlv_names )
	vd$free_str_list ( str_list = mdlv_names,
			   num_str  = num_mdlv    );

     if ( mdlv_desc )
	vd$free_str_list ( str_list = mdlv_desc,
			   num_str  = num_mdlv    );
Return status
  same as OM return status

Return message
  MSFAIL - failure

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

#include "vdmemmacros.h"
#include "vderrmacros.h"
#include "vdrefmacros.h"
#include "VDmem.h"

#include "vdmdlvwdef.h"

#define  VD_STEP_SIZE   30


from  VDmdlview  import  VDmv_give_name_desc;


long VDgetMVlist (
  long			*msg,
  int			*num_mdlv,
  struct GRid		**mdlv_ids,
  struct GRmd_env	**mdlv_env,
  char			***mdlv_names,
  char			***mdlv_desc
)
{
long			sts;
struct GRmd_env		mod_env,
			*RefEnvList = NULL,
			*loc_env = NULL;

// No longer used
// struct GRmd_env	solid_env;
// struct GRid		solid;

OMuint			count;
int			NbOs,
			ListSize, loc_num,
			ii, jj,	ii1, sizbuf,
			NoBytesRet;
GRspacenum		*OsList = NULL;
struct GRid		*loc_ids = NULL,
			MdlvMgr;
OM_S_OBJECT_LINKAGE	*mdlvs = NULL;

char			**loc_names = NULL,
			**loc_desc  = NULL,
			tmp_name[VD_MAX_MV_NAME_LEN],
			tmp_desc[VD_MAX_MV_DESC_LEN];
OM_S_CHANSELECT		to_components;


   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   loc_num = 0;		// Used by wrapup

   sizbuf = sizeof( struct GRmd_env );
   gr$get_module_env (  msg       = msg,
			sizbuf    = &sizbuf,
			buffer    = &mod_env,
			nret      = &NoBytesRet );

   /* Initialization */
   ListSize = VD_STEP_SIZE;
   if ( mdlv_ids ) {
        loc_ids = _MALLOC ( ListSize, struct GRid );
	_CheckMem (loc_ids, sts, *msg, wrapup);
	}
   if ( mdlv_env ) {
        loc_env = _MALLOC ( ListSize, struct GRmd_env );
	_CheckMem (loc_env, sts, *msg, wrapup);
	}
   if ( mdlv_names )
   {
     sts = vd$malloc_str_list ( str_list  = &loc_names,
				num_str   = ListSize,
				str_size  = VD_MAX_MV_NAME_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   if ( mdlv_desc )
   {
     sts = vd$malloc_str_list ( str_list  = &loc_desc,
				num_str   = ListSize,
				str_size  = VD_MAX_MV_DESC_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   loc_num = 0;  // Should have been made sooner

   sts = om$make_chanselect (   channame = "GRcmpowner.to_components",
				p_chanselect = &to_components );

   /*
    * get model views in active file
    */
   sts = VDget_mdlvw_mgr ( NULL, &MdlvMgr );
   if ( !(sts&1) )
   {
      /* No view vol manager in active file. Means no model views.
       * Look in the reference files.
       */
      goto PROCESS_REF_FILES;
   }

   sts = om$get_channel_count(  objid		=   MdlvMgr.objid,
				osnum		=   MdlvMgr.osnum,
				p_chanselect	=   &to_components,
				count		=   &count );
   __DBGpr_int( "No. of model views", count );
   if ( count == 0 ) goto PROCESS_REF_FILES;

   mdlvs = _MALLOC ( count,  OM_S_OBJECT_LINKAGE );
   _CheckMem (mdlvs, sts, *msg, wrapup);

   sts = om$get_channel_objects(  objid		=  MdlvMgr.objid,
				  osnum		=  MdlvMgr.osnum,
				  p_chanselect	=  &to_components,
				  list		=  mdlvs,
				  size		=  count,
				  count		=  &count );

   for ( ii=0; ii < count; ii++ )
   {
      if ( loc_num == ListSize )
      {
	ListSize += VD_STEP_SIZE;
	if ( mdlv_ids )
	  loc_ids = _REALLOC ( loc_ids, ListSize, struct GRid);

	if ( mdlv_env )
	  loc_env = _REALLOC ( loc_env, ListSize, struct GRmd_env);
	if ( mdlv_names )
	{
	   loc_names = _REALLOC ( loc_names, ListSize, char* );
	   for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++) {
	        loc_names[ii1] = _MALLOC ( VD_MAX_MV_NAME_LEN, char); 
		_CheckMem (loc_names[ii1], sts, *msg, wrapup);
		}
	}

	if ( mdlv_desc )
	{
	   loc_desc = _REALLOC ( loc_desc, ListSize, char* );
	   for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++){
		loc_desc[ii1] = _MALLOC ( VD_MAX_MV_DESC_LEN, char);
		_CheckMem (loc_desc[ii1], sts, *msg, wrapup);
		}
	}
      }

      if ( mdlv_ids )
      {
	     loc_ids[loc_num].objid = mdlvs[ii].S_objid;
             loc_ids[loc_num].osnum = mdlvs[ii].osnum;
      }
      if ( mdlv_env )
	     loc_env[loc_num] = mod_env;
      if ( mdlv_names || mdlv_desc )
      {
	sts = om$send ( msg = message VDmdlview.VDmv_give_name_desc (
						msg,
						tmp_name,
						tmp_desc   ),
		       senderid = NULL_OBJID,
		       targetid = mdlvs[ii].S_objid,
		       targetos = mdlvs[ii].osnum );
	VDS_ERR_RPT("VDmdlview.VDmv_give_name_desc", sts, *msg, VD_VERBOSE );

	if ( mdlv_names )
	  strcpy( loc_names[loc_num], tmp_name );

	if ( mdlv_desc )
	  strcpy( loc_desc[loc_num], tmp_desc );
      }
      loc_num++;
   }

   _FREE ( mdlvs ); 

PROCESS_REF_FILES:
   /*
    * get model views in reference files
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
	printf("Osnum[%d] = [%d]\n", ii, OsList[ii]);
#endif

   for(ii=0; ii<NbOs; ii++)
   {
	/*
	 * get model view manager in reference file
	 */
	__DBGpr_int("Processing OS", OsList[ii]);

	sts = VDget_mdlvw_mgr ( &OsList[ii], &MdlvMgr );
	if ( !(sts&1) ) /* there is no moel view manager in reference file */
	{
	     sts = OM_S_SUCCESS;
	     continue;
	}
	__DBGpr_obj("Mdlv Mgr Obj", MdlvMgr);

	sts = om$get_channel_count(  objid		=   MdlvMgr.objid,
				     osnum		=   MdlvMgr.osnum,
				     p_chanselect	=   &to_components,
				     count		=   &count );
	__DBGpr_int( "No. of mdlvs", count );
	if ( count == 0 ) continue;

	mdlvs = _MALLOC( count,  OM_S_OBJECT_LINKAGE );
	_CheckMem (mdlvs, sts, *msg, wrapup);

	sts = om$get_channel_objects(  objid		=  MdlvMgr.objid,
				       osnum		=  MdlvMgr.osnum,
				       p_chanselect	=  &to_components,
				       list		=  mdlvs,
				       size		=  count,
				       count		=  &count );
	for ( jj=0; jj<count; jj++ )
	{

	  if ( loc_num == ListSize )
	  {
	    ListSize += VD_STEP_SIZE;
	    if ( mdlv_ids )
	       loc_ids = _REALLOC ( loc_ids, ListSize, struct GRid);

	    if ( mdlv_env )
	       loc_env = _REALLOC ( loc_env, ListSize, struct GRmd_env);

	    if ( mdlv_names )
	    {
	       loc_names = _REALLOC ( loc_names, ListSize, char* );
	       for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++) {
		loc_names[ii1] = _MALLOC ( VD_MAX_MV_NAME_LEN, char);
		_CheckMem (loc_names[ii1], sts, *msg, wrapup);
		}
	    }
	    if ( mdlv_desc )
	    {
	       loc_desc = _REALLOC ( loc_desc, ListSize, char*);
	       for ( ii1=ListSize - VD_STEP_SIZE; ii1<ListSize; ii1++){
		loc_desc[ii1] = _MALLOC ( VD_MAX_MV_DESC_LEN, char);
		_CheckMem (loc_desc[ii1], sts, *msg, wrapup);
		}
	    }
	  } /* if ( loc_num == ListSize ) */

	  if ( mdlv_ids )
	  {
	     loc_ids[loc_num].objid = mdlvs[jj].S_objid;
	     loc_ids[loc_num].osnum = mdlvs[jj].osnum;
	  }
	  if ( mdlv_env )
	     loc_env[loc_num] = RefEnvList[ii];
	  if ( mdlv_names || mdlv_desc )
	  {
	     sts = om$send ( msg = message VDmdlview.VDmv_give_name_desc (
						msg,
						tmp_name,
						tmp_desc   ),
		       senderid = NULL_OBJID,
		       targetid = mdlvs[jj].S_objid,
		       targetos = mdlvs[jj].osnum );
	    VDS_ERR_RPT("VDmdlview.VDmv_give_name_desc", sts,*msg, VD_VERBOSE );

	    if ( mdlv_names )
	       strcpy( loc_names[loc_num], tmp_name );

	    if ( mdlv_desc )
	      strcpy( loc_desc[loc_num], tmp_desc );
	  } /* if ( mdlv_names || mdlv_desc ) */
          loc_num++;

	} /* for ( jj=0; jj<count; jj++ ) */

	_FREE ( mdlvs ); 
   } /* for(ii=0; ii<NbOs; ii++) */

wrapup:
   *num_mdlv = loc_num;
   if ( mdlv_ids ) *mdlv_ids = loc_ids;
   if ( mdlv_env ) *mdlv_env = loc_env;
   if ( mdlv_names ) *mdlv_names = loc_names;
   if ( mdlv_desc ) *mdlv_desc = loc_desc;

   _FREE ( OsList );
   _FREE ( RefEnvList );

   __DBGpr_int( "No. of View volumes found", *num_mdlv );

#ifdef VDS_DBG
   if ( mdlv_ids )
     for ( ii=0; ii< *num_mdlv; ii++)
       printf(" Model view obj id[%d] : [%d,%d]\n", ii, (*mdlv_ids)[ii].osnum,
						(*mdlv_ids)[ii].objid  );
   if ( mdlv_names )
     for ( ii=0; ii< *num_mdlv; ii++)
       printf(" Model View name[%d] : [%s]\n", ii, (*mdlv_names)[ii] );
      
#endif
   return sts;
}

end implementation Root;
