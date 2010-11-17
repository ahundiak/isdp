/* ========================================
 * 11/17/10 ah   SOL10 Ref limit raised to 500
 */
class implementation  Root;

/*+fe
Function   VDget_ref_os_list

Abstract
  Gives list of all  currently active reference OSs and mod_envs.
  If one OS is attached twice with different mod envs, the list contains
  both the entries.
  If one OS is attached twice with the same mod env, only one entry will
  be there in the list.

  The output module environment matrix for a reference object space is
  the transformation matrix from the reference object space to 
  master object space.

Arguments
  IGRlong               *msg          O    return status
  struct GRid		*mod_id       I	   Object id of the module.
					   This function gives list of unique
					   OSs and module envs which are
					   connected to (*mod_id).
  int			*NbOs         O    Number of unique reference OSs
  GRspacenum		**osList      O    List of reference OSs.
					   = NULL, if not needed.
  struct GRmd_env	**modEnvList  O    List of envs. Each module env
					   is transformation matrix from
					   reference OS to the
					   input OS ( mod_id.osnum )
					   = NULL, if not needed.
Notes
  This function allocates memory for osList and modEnvList which
  should be freed by the caller.

Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   11-03-1994  Raju   Creation
-fe*/

#include "OMindex.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "madef.h"
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "refdef.h"
#include "ref.h"

#include "vderrmacros.h"

from   Super_rfmgr   import  GRget_channel_count;
from   Super_rfmgr   import  GRget_channel_objects;
from   GRreffile     import  GRinquireref;
from   GRreffile     import  GRgetenvironment;

/*
 * the following static variables are used for only
 * creating a list of ref object spaces and mod_envs.
 * The static lists is cleared by the function.
 */


static   int			NoOfAllOs;
static   int			ListSize;
static   struct  GRmd_env 	*AllModEnv;
static   GRspacenum 		*AllOsNums;
static	 int			ref_os_count;
static	 GRspacenum		ref_os_listx[500];
static	 GRspacenum	       *ref_os_list;



/*+fe
Function   VDadd_to_os_list

Abstract
   This function adds a OS to the static lists

History
   11-03-1994  Raju   Creation
-fe*/

static long  VDadd_to_os_list (
 long *msg,			/* O - return status */
 struct GRmd_env *mod_env	/* I - mod env to be added */
)
{
long   sts;

   sts = OM_S_SUCCESS;
   *msg = MSSUCC;

   if ( NoOfAllOs == ListSize )
   {
	ListSize += 10;
	
	AllModEnv = (struct GRmd_env *) realloc ( AllModEnv,
					   sizeof (struct GRmd_env) * ListSize);
	AllOsNums = (GRspacenum *) realloc ( AllOsNums,
					   sizeof (GRspacenum) * ListSize);
   }

   AllModEnv[NoOfAllOs] = *mod_env;
   AllOsNums[NoOfAllOs] = mod_env->md_id.osnum;

   NoOfAllOs++;

 return sts;
}

static 	AddModEnvToList( struct GRmd_env	*mod_env )
{
IGRint		i;

   for( i=0; i<ref_os_count; ++i )
	if( ref_os_list[i] == mod_env->md_id.osnum ) break;

   if( i == ref_os_count ) ref_os_list[ref_os_count++] = mod_env->md_id.osnum;
}

static IGRint	CheckRefOSIndex( struct GRmd_env        *mod_env )
{
IGRint          i;

    for( i=0; i<ref_os_count; ++i )
        if( ref_os_list[i] == mod_env->md_id.osnum ) return 1;

    return 0;
}

/*+fe
Function   VDget_ref_os

Abstract
   This function gets all the reference OSs attached to a OS

History
   11-03-1994  Raju   Creation
-fe*/


static long  VDget_ref_os(
 long *msg,			/*  O - return status  */
 struct GRmd_env *mod_env	/*  I - mod env for which ref OS and env to
					be found */
)
{

struct GRmd_env	mod_env1;
long		sts;
OM_S_OBJID	Super_id;
IGRshort	count_nested;
GRobjid		*objlist = NULL;
GRspacenum	*oslist = NULL;
IGRint		ii;
IGRlong		count;
IGRulong	prop_mask;
struct GRinquire_list   inquire_requests[2] ;
int		which_error;
IGRboolean              pass_to_other_spaces,
                        reference_file_found ;


  sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  /*
   * Get id of ref manager
   */
  sts = ex$get_objid_from_NOD(
                        NODname         = "IGENOD",
                        objname         = "Ref Mgr",
                        pobjid          = &Super_id,
                        modid           = mod_env->md_id.objid,
                        mod_osnum       = mod_env->md_id.osnum);
  if(!(sts&1)) goto wrapup ;

  AddModEnvToList( mod_env );

  /*| Get count of reference file */
  prop_mask = 0;
  count_nested = 0;
  sts =
  om$send(msg	   = message Super_rfmgr.GRget_channel_count
                                   ( msg, &prop_mask, &count_nested, &count),
	  senderid = NULL_OBJID,
	  targetid = Super_id,
	  targetos = mod_env->md_id.osnum );
  if(!(sts&1)) goto wrapup ;
  if ( count == 0 ) goto wrapup;

  /*| Get reference file objects */
  objlist = om$calloc( num = (int) count, structure = GRobjid );
  oslist  = om$calloc( num = (int) count, structure = GRspacenum );

  prop_mask = 0; count_nested = 0;
  sts =
  om$send(msg      = message Super_rfmgr.GRget_channel_objects
                                     ( msg, &prop_mask, &count_nested, &count,
                                      objlist, oslist, &count),
	  senderid = NULL_OBJID,
	  targetid = Super_id,
	  targetos = mod_env->md_id.osnum );
  if(!(sts&1)) goto wrapup ;


  inquire_requests[0].var                 = REFERENCE_FILE_FOUND ;
  inquire_requests[0].var_ptr             = (char *)&reference_file_found ;
  inquire_requests[0].num_requested       = sizeof reference_file_found ;
  inquire_requests[1].var                 = END_REPORT_REQUEST ;

  pass_to_other_spaces = FALSE ;

  for(ii=0; ii<count; ii++)
  {

    sts = om$send(  msg     = message GRreffile.GRinquireref(
							msg,
							mod_env,
							inquire_requests,
							&which_error,
							&pass_to_other_spaces,
							NULL ),
			senderid        = NULL_OBJID,
 			targetid        = objlist[ii],
 			targetos        = oslist[ii] );
    VDS_ERR_HNDLR ( "GRreffile.GRinquireref", sts, *msg, VD_VERBOSE, wrapup );


    if ( reference_file_found )
    {
	sts = om$send(  msg     = message GRreffile.GRgetenvironment(
							msg,
							mod_env,
							&mod_env1 ),
			senderid        = NULL_OBJID,
 			targetid        = objlist[ii],
 			targetos        = oslist[ii] );
	VDS_ERR_HNDLR ( "GRreffile.GRgetenvironment", sts, *msg,
			VD_VERBOSE, wrapup );

	sts = VDadd_to_os_list ( msg, &mod_env1 );

	if ( mod_env->md_id.osnum != mod_env1.md_id.osnum  
	     && ! CheckRefOSIndex( &mod_env1 ) )
		sts = VDget_ref_os ( msg, &mod_env1 );
    }
  }


wrapup:

  if ( objlist ) free (objlist);
  if ( oslist )  free ( oslist);
  return 1;

}


long  VDget_ref_os_list(
  long			*msg,
  GRspacenum		*main_os,
  int			*NbOs,
  GRspacenum		**osList,
  struct GRmd_env	**modEnvList
)
{
long		  sts, ii, jj, kk;
GRspacenum	  *uniqOsNums = NULL;
struct GRmd_env	  *uniqModEnv = NULL,
		  mod_env;
int		  NoOfUniqOs,
		  sizbuf,
		  BytesRet;
char		  found,
		  same_matrix;

    sts = OM_S_SUCCESS;
    *NbOs = 0;

    if ( main_os )
    {
	char osname[OM_K_MAXOSNAME_LEN];

        /* make sure that the input os is active */
	sts = om$os_number_to_name( osnum   = *main_os,
				    osname  = osname ) ;
	if( !( 1 & sts ) )
	{
	  /* input OS is not active */
	  *msg = MSFAIL;
	  goto wrapup;
	}
	mod_env.md_id.osnum = *main_os;
	ex$get_modid (  mod_osnum = mod_env.md_id.osnum,
			mod_id    = &mod_env.md_id.objid );
	for(ii=0; ii<16; ii++) mod_env.md_env.matrix[ii] = 0;
	mod_env.md_env.matrix[0]  =
	mod_env.md_env.matrix[5]  =
	mod_env.md_env.matrix[10] =
	mod_env.md_env.matrix[15] = 1;
	mod_env.md_env.matrix_type  = MAIDMX;
    }
    else
    {
	sizbuf = sizeof ( struct GRmd_env );
	gr$get_module_env (  msg    =  &msg,
			     sizbuf =  &sizbuf,
			     buffer =  &mod_env,
			     nret   =  &BytesRet );
    }

    /*
     * following two statements are redundant ( only as precaution )
     */
    if ( AllModEnv ) { free ( AllModEnv ); AllModEnv = NULL; }
    if ( AllOsNums  ) { free ( AllOsNums ); AllOsNums = NULL; }

    ListSize = 10;
    NoOfAllOs   = 0;

    AllModEnv = (struct GRmd_env *) malloc ( sizeof (struct GRmd_env) * 
							ListSize);
    AllOsNums = (GRspacenum *) malloc ( sizeof (GRspacenum) * ListSize);

    if ( !AllModEnv || !AllOsNums )
    {
	*msg = MSFAIL;  /* replace by no dynamic memory */
        goto wrapup;
    }

    /* This is controlled by MAX_REF_FILES */
    ref_os_list = (GRspacenum*) malloc ( sizeof (GRspacenum) * EX_MAX_INVIS_MODULES);
    ref_os_count = 0;
    sts = VDget_ref_os ( msg, &mod_env );

#ifdef VDS_DBG
    for ( ii=0; ii<NoOfAllOs; ii++)
       printf(" before uniq Osnum[%d] = [%d]\n", ii, AllOsNums[ii]);
#endif

    if ( NoOfAllOs == 0 )  goto wrapup;

    /*
     * we have the list of all reference object spaces and mod_envs.
     * Below, they are processed for getting a unique list
     * such that os and mod_env are distinct.
     * ( get the unique object spaces and mod_envs )
     */
    uniqModEnv = (struct GRmd_env *) malloc ( sizeof (struct GRmd_env) * 
							NoOfAllOs );
    uniqOsNums = (GRspacenum *) malloc ( sizeof (GRspacenum) * NoOfAllOs );
        
    /*
     * initialize the first uniq os and mod_env
     */

    uniqModEnv[0] = AllModEnv[0];
    uniqOsNums[0] = AllOsNums[0];
    NoOfUniqOs = 1;

    for ( ii=1; ii<NoOfAllOs; ii++)
    {
        /*
         * find if the combination of os and mod_env is already in the list
	 */
	found = FALSE;
	for ( jj=0; jj<NoOfUniqOs; jj++ )
	{
	  same_matrix = TRUE;
	  for ( kk=0; kk<16; kk++)
	    if (  AllModEnv[ii].md_env.matrix[kk] != 
		  uniqModEnv[jj].md_env.matrix[kk] )  same_matrix = FALSE;

	  if ( same_matrix && (AllOsNums[ii] == uniqOsNums[jj]) )
		  found = TRUE;

	  if ( found ) break;

	}

	if ( !found )
	{
	   /*
	    * this combination is not in the list. Add it to the lsit.
	    */
	   uniqOsNums[NoOfUniqOs] = AllOsNums[ii];
	   uniqModEnv[NoOfUniqOs] = AllModEnv[ii];
	   (NoOfUniqOs)++;
	}
    }

    uniqModEnv = (struct GRmd_env *) realloc ( uniqModEnv,
					sizeof (struct GRmd_env)* (NoOfUniqOs));

    uniqOsNums = (GRspacenum *) realloc ( uniqOsNums,
					sizeof (GRspacenum) * (NoOfUniqOs) );

    if ( osList )
       *osList = uniqOsNums;
    else
       if ( uniqOsNums ) free ( uniqOsNums );

    if ( modEnvList )
       *modEnvList = uniqModEnv;
    else
       if ( uniqModEnv ) free ( uniqModEnv );

    *NbOs = NoOfUniqOs;

#ifdef VDS_DBG
    if ( osList )
      for ( ii=0; ii<*NbOs; ii++)
	 printf(" after uniq Osnum[%d] = [%d]\n", ii, (*osList)[ii]);
#endif

wrapup:
    if (AllModEnv  ) { free(AllModEnv );  AllModEnv   = NULL; }
    if (AllOsNums  ) { free(AllOsNums );  AllOsNums   = NULL; }
    if (ref_os_list) { free(ref_os_list); ref_os_list = NULL; }
    NoOfAllOs = 0;
    ListSize = 0;
    return sts;

}

end implementation  Root;

