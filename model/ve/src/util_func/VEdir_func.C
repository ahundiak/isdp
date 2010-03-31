
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"
#include "gr.h"

#include "godef.h"
#include "go.h"

#include "msdef.h"
#include "msmacros.h"

#include "bs.h"
#include "bsparameters.h"

#include "vedef.h"
#include "ve.h"
#include "veerr.h"
#include "vemsg.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

/* #include "DPstring.h" - include when prototype is stable */

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEget_env_objects_from_dir __((
					IGRchar    *dir_name,
					IGRchar    *env,
					OM_S_OBJID *clip_diag_id,
					OM_S_OBJID *color_id,
					OM_S_OBJID *style_id,
					OM_S_OBJID *weight_id ));


#if defined(__cplusplus)
}
#endif

#undef __

/* External global variables */
extern struct GRmd_env VEmaster_env;


/*--- VEcreate_default_directory ----------------------------------*/

IGRboolean VEcreate_default_directory( IGRshort invis_os )

/*
NAME
	VEcreate_default_directory

DESCRIPTION
	This function creates the default root directory used by VE in
	batch.  TRUE is returned if the directory was created, FALSE
	is returned if an error occurred.

PARAMETERS
	inivis_os (IN) - object space number of invisible batch object space

GLOBALS USED
	none

HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong  sts;

	sts = di$mkdir( dirname = "batch_edges",
	                osnum   = invis_os );

	if ( sts != DIR_S_SUCCESS )
	   return( FALSE );
	
	return( TRUE );
	} /* VEcreate_default_directory */


/*--- VEcreate_env_directories ------------------------------------*/


void VEcreate_env_directories(  IGRshort invis_os,
				IGRshort attach_id )

/*
NAME
	VEcreate_env_directories

DESCRIPTION
	This function creates the directories required for an environment
	in the invisible batch object space.
	
PARAMETERS
	invis_os (IN) - object space number of the invisible batch object space
	attach_id (IN) - unique identifier for the environment whose directories
	                 are to be created
GLOBALS USED
	none
	
HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong sts;
	IGRchar env[10];
	IGRchar dir_name[DI_PATH_MAX];

	sprintf( env, "env%d", attach_id );
	DIstmocpy( dir_name, "batch_edges", env, NULL, invis_os );

	sts = di$mkdir( dirname = dir_name );

	if ( sts != DIR_S_SUCCESS )
	   {
	   di$report_error( sts = sts,
	                    comment = "ERROR CREATING DIRECTORY" );
	   }

	DIstmcat( dir_name, "objects", NULL );

	sts = di$mkdir( dirname = dir_name );

	if ( sts != DIR_S_SUCCESS )
	   {
	   di$report_error( sts = sts,
	                    comment = "ERROR CREATING DIRECTORY" );
	   }
	
	} /* VEcreate_env_directories */


/*--- VEadd_env_objects_to_dir ----------------------------------------*/

void VEadd_env_objects_to_dir(  IGRshort invis_os,
				IGRshort attach_id,
				IGRlong  clip_diag_id,
				IGRlong  color_id,
				IGRlong  style_id,
				IGRlong  weight_id )

/*
NAME
	VEadd_env_objects_to_dir

DESCRIPTION
	This function adds the object ids of the clipping diagonal line segment,
	the color override point, the style override point and the weight override
	point to the appropriate environment directory.  The color, style and
	weight id's will be NULL_OBJID if no override is in effect.

PARAMETERS
	invis_os (IN) - object space number of the invisible batch object space
	attach_id (IN) - unique identifier for the environment whose directories
	                 are to be created
	clip_diag_id (IN) - object id of the linestring representing the clipping
	                    diagonal of the environment
	color_id (IN) - object id of the the object whose color represents the
	                override color for the environment
	style_id (IN) - object id of the the object whose style represents the
	                override color for the environment
	weight_id (IN) - object id of the the object whose weight represents the
	                 override color for the environment

GLOBALS USED
	none

HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong sts;
	IGRchar env[10];
	IGRchar obj_name[DI_PATH_MAX];

	sprintf( env, "env%d", attach_id );
	DIstmocpy( obj_name, "batch_edges", env, "clip_diag", NULL, invis_os );

	sts = di$add_name( objname = obj_name, objid = clip_diag_id );

	if ( sts != DIR_S_SUCCESS )
	   {
	   di$report_error( sts = sts,
	                    comment = "ERROR ADDING NAME - CLIPPING DIAGONAL" );
	   }
	
	if ( color_id != NULL_OBJID )
	   {
	   DIstmocpy( obj_name, "batch_edges", env, "color", NULL, invis_os );
	   sts = di$add_name( objname = obj_name, objid = color_id );
	   }

	if ( style_id != NULL_OBJID )
	   {
	   DIstmocpy( obj_name, "batch_edges", env, "style", NULL, invis_os );
	   sts = di$add_name( objname = obj_name, objid = style_id );
	   }

	if ( weight_id != NULL_OBJID )
	   {
	   DIstmocpy( obj_name, "batch_edges", env, "weight", NULL, invis_os );
	   sts = di$add_name( objname = obj_name, objid = weight_id );
	   }

	} /* VEadd_env_objects_to_dir */
	

/*--- VEadd_to_objects_dir ----------------------------------------*/

void VEadd_to_objects_dir( IGRshort invis_os,
			   IGRshort attach_id,
			   IGRlong  objid )

/*
NAME
	VEadd_to_objects_dir

DESCRIPTION
	This function adds an object id to the "objects" directory of
	a given environment.

PARAMETERS
	invis_os (IN) - object space number of the invisible batch object space
	attach_id (IN) - unique identifier for the environment whose directories
	                 are to be created
	objid (IN) - object id of object to be added to the "objects" directory

GLOBALS USED
	none

HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong sts;
	IGRchar env[10];
	IGRchar dir_name[DI_PATH_MAX];

	sprintf( env, "env%d", attach_id );
	DIstmocpy( dir_name, "batch_edges", env, "objects", NULL, invis_os );

	sts = di$add_index( dirname = dir_name, objid = objid );

	if ( sts != DIR_S_SUCCESS )
	   {
	   di$report_error( sts = sts,
	                    comment = "ERROR ADDING BY INDEX" );
	   }
	
	} /* VEadd_to_objects_dir */
	

/*--- VEget_env_objects_from_dir ---------------------------------------------------*/

static void VEget_env_objects_from_dir( dir_name, env,
	                                clip_diag_id, color_id, style_id, weight_id )

	IGRchar    *dir_name;
	IGRchar    *env;
	OM_S_OBJID *clip_diag_id;
	OM_S_OBJID *color_id;
	OM_S_OBJID *style_id;
	OM_S_OBJID *weight_id;

/*
NAME
	VEget_env_objects_from_dir (static)

DESCRIPTION
	This function gets the object ids of the clipping diagonal line segment,
	the color override point, the style override point and the weight override
	point from the appropriate environment directory.  The color, style and
	weight override points will only exist if a symbology override was in effect
	for this environment.  If an override point doesn't exist, the corresponding
	parameter is set to NULL_OBJID.

PARAMETERS
	dir_name (IN) - the top level directory name
	env (IN) - name of the environment
	clip_diag_id (IN) - object id of the linestring representing the clipping
	                    diagonal of the environment
	color_id (OUT) - object id of the the object whose color represents the
	                 override color for the environment
	style_id (OUT) - object id of the the object whose style represents the
	                 override color for the environment
	weight_id (OUT) - object id of the the object whose weight represents the
	                  override color for the environment

GLOBALS USED
	none

HISTORY
	08/02/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong sts;
	IGRchar obj_name[DI_PATH_MAX];


	/* get the clipping diagonal id */
	DIstmcpy( obj_name, dir_name, env, "clip_diag", NULL );
	sts = di$translate( objname = obj_name, p_objid = clip_diag_id );

	if ( sts != DIR_S_SUCCESS )
	   {
	   *clip_diag_id = NULL_OBJID;
	   di$report_error( sts = sts,
	                    comment = "ERROR GETTING CLIP DIAG" );
	   }
	else
	   {
	   /* delete the clipping diagonal from directory */
	   sts = di$rm_name( regexp = obj_name );
	   }

	/* get the color override point id */
	DIstmcpy( obj_name, dir_name, env, "color", NULL );
	sts = di$translate( objname = obj_name, p_objid = color_id );

	if ( sts != DIR_S_SUCCESS )
	   {
	   *color_id = NULL_OBJID;
	   }
	else
	   {
	   /* delete the color override point from directory */
	   sts = di$rm_name( regexp = obj_name );
	   }

	/* get the style override point id */
	DIstmcpy( obj_name, dir_name, env, "style", NULL );
	sts = di$translate( objname = obj_name, p_objid = style_id );

	if ( sts != DIR_S_SUCCESS )
	   {
	   *style_id = NULL_OBJID;
	   }
	else
	   {
	   /* delete the style override point from directory */
	   sts = di$rm_name( regexp = obj_name );
	   }

	/* get the weight override point id */
	DIstmcpy( obj_name, dir_name, env, "weight", NULL );
	sts = di$translate( objname = obj_name, p_objid = weight_id );

	if ( sts != DIR_S_SUCCESS )
	   {
	   *weight_id = NULL_OBJID;
	   }
	else
	   {
	   /* delete the weight override point from directory */
	   sts = di$rm_name( regexp = obj_name );
	   }

	}  /* VEget_env_objects_from_dir */


/*--- VEcollect_elements_in_batch -------------------------------------------*/

void VEcollect_elements_in_batch( fence_grid )

	struct GRid      *fence_grid;

/*
NAME
	VEcollect_elements_in_batch

DESCRIPTION
	This function traverses the environment directory structure built for
	a batch run creating the necessary environments and constructing sort
	records for all objects contained in the structure.

PARAMETERS
	fence_grid (IN) - the object id of the fence object

GLOBALS USED
	VEmaster_env

HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong           sts;
	IGRchar           env[10];
	IGRchar           obj_dir[DI_PATH_MAX], obj_name[DI_PATH_MAX], dir_name[DI_PATH_MAX];
	IGRint            i;
	OM_S_OBJID        clip_diag_id, color_id, style_id, weight_id;
	struct GRid       elem;
	struct VEenv_info *cur_env;

	elem.osnum = VEmaster_env.md_id.osnum;

	DIstmocpy( dir_name, "batch_edges", NULL, VEmaster_env.md_id.osnum );

	/* loop over all environments */
	for ( i = 0; ; i++ )
	   {
	   /* see if an entry exists at index 0 */
	   if ( di$index( dirname = dir_name, index = 0, name = obj_name ) != DIR_S_SUCCESS )
	      break;

	   /* build the directory name of this environment */
	   sprintf( env, "env%d", i );

	   VEget_env_objects_from_dir( dir_name, env,
	                               &clip_diag_id, &color_id, &style_id, &weight_id );

	   cur_env = VEcreate_environment_for_batch( elem.osnum,
	                                             clip_diag_id,
	                                             color_id, style_id, weight_id );

	   /* loop over all the ids in the objects sub-directory */
	   DIstmcpy( obj_dir, dir_name, env, "objects", NULL );
	   for ( ;; )
	      {
	      /* get object at index 0 */
	      if ( di$index( dirname = obj_dir, index = 0,
	                     p_objid = &elem.objid ) != DIR_S_SUCCESS )
	         break;

	      /* classify object and add to sort structure */
	      VEclassify_located_object( &elem, cur_env,
	                                 cur_env->matrix, cur_env->matrix_type, &VEmaster_env,
	                                 NULL, FALSE,
	                                 fence_grid, -1 );

	      /* remove the entry at index ZERO which will cause the remaining */
	      /* entries in this directory to shift down one index             */
	      sts = di$rm_index( dirname = obj_dir, index = 0 );
	      if ( sts != DIR_S_SUCCESS )
	         {
	         di$report_error( sts = sts,
	                          comment = "ERROR DELETING BY INDEX" );
	         break;  /* get out of for loop to avoid infinite loop */
	         }

	      } /* end for ( ;; ) */

	   /* delete objects directory */
	   sts = di$rmdir( dirname = obj_dir );
	   if ( sts != DIR_S_SUCCESS )
	      {
	      di$report_error( sts = sts,
	                       comment = "ERROR DELETING OBJECTS DIR" );
	      }

	   /* remove the envX directory at index ZERO which will cause the */
	   /* remaining entries in this directory to shift down one index  */
	   DIstmcpy( obj_dir, dir_name, env, NULL );
	   sts = di$rmdir( dirname = obj_dir );
	   if ( sts != DIR_S_SUCCESS )
	      {
	      di$report_error( sts = sts,
	                       comment = "ERROR DELETING ENVX DIR" );
	      break;  /* get of of for loop to avoid infinite loop */
	      }

	   }  /* end: for */

	/* delete batch_edges directory */
	sts = di$rmdir( dirname = dir_name );
	if ( sts != DIR_S_SUCCESS )
	   {
	   di$report_error( sts = sts,
	                    comment = "ERROR DELETING BATCH_EDGES DIR" );
	   }

	}  /* VEcollect_elements_in_batch */
