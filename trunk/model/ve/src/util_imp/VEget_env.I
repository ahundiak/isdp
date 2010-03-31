
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"

#include "godef.h"
#include "go.h"
#include "dpstruct.h"

#include "grdpbdef.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "bs.h"

#include "msdef.h"

#include "madef.h"

#include "EMSdatumdef.h"
#include "EMdtmacros.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "EFretpln.h"

#include "matypemx.h"
#include "mainvmx.h"
#include "mamulmx.h"

#define ONE_OVER_SQRT_THREE  0.5773502691896  /* 1.0 / sqrt( 3.0 ) */

/* External - global variables */
extern struct VEenv_info         *VEenv_list;
extern struct VEwindow_info      VEwin_info;
extern struct VEexecution_status VEexec_status;
extern struct GRmd_env           VEmaster_env;
extern struct VEresults_info     VEoutput_data;

from OMObjSpace import get_status;

/*---- VEget_environment_info ------------------------------------------------*/

#if defined(__STDC__)
struct VEenv_info *VEget_environment_info( IGRint          osnum,
					   IGRmatrix       mat,
					   IGRshort        mat_type,
					   struct GRmd_env *mod_env,
					   IGRboolean      batch_copy,
					   struct GRmd_env *batch_env )
#else
struct VEenv_info *VEget_environment_info( osnum, mat, mat_type, mod_env, batch_copy, batch_env )

	IGRint          osnum;
	IGRmatrix       mat;
	IGRshort        mat_type;
	struct GRmd_env *mod_env;
	IGRboolean      batch_copy;
	struct GRmd_env *batch_env;
#endif
/*
NAME
	VEget_environment_info

DESCRIPTION
	Search the global environment list to see if a matrix equal to mat
	is there.  If one isn't there, add the new entry to the environment
	list.

PARAMETERS
	osnum (IN) - object space of environment
	mat (IN) - matrix for environment
	mat_type (IN) - matrix type for 'matrix'
	mod_env (IN) - module environment for environment
	batch_copy (IN) - TRUE, if in the process of submitting a batch job
	batch_env (IN) - module environment of invisible batch object space

GLOBALS USED
	VEenv_list
	VEwin_info
	VEexec_status

RETURN VALUES
	A pointer to the environment structure is returned

HISTORY
	05/04/87    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRboolean        is_master;
	IGRshort          rot_mat_type;
	IGRlong           sts, msg, rc;
	IGRdouble         x,y,z;
	IGRdouble         det;
	struct VEenv_info *cur_env;
	OM_S_OSSTATUS     os_status;
        GRspacenum        GRspacenum_osnum;

	/* search environment list to see if this environment already exists */
	cur_env = VEenv_list;
	while ( cur_env  )
	   {
	   if ( (osnum == cur_env->osnum) &&
	        (! memcmp( mat, cur_env->matrix, sizeof(IGRdouble) * 16 ) ) )
	      {
	      return( cur_env );
	      }
	   cur_env = cur_env->next;
	   }

	/* this environment isn't there yet, so add one to the beginning of the list */
	cur_env = (struct VEenv_info *) malloc( sizeof( struct VEenv_info ) );
	cur_env->matrix_type = mat_type;
	cur_env->attach_id   = VEexec_status.VEattach_count++;
	cur_env->osnum       = osnum;
	cur_env->flags       = 0;
	memcpy( &cur_env->md_env, mod_env, sizeof( struct GRmd_env ) );

	/* copy matrix passed in to the module environment because it  */
	/* may be different in the case of an environment for a symbol */
	memcpy( cur_env->md_env.md_env.matrix, mat, sizeof( IGRdouble ) * 16 );
	cur_env->md_env.md_env.matrix_type = mat_type;

	memcpy( cur_env->matrix, mat, sizeof( IGRdouble ) * 16 );

	/* determine the uniform scale contained in the matrix by  */
	/* applying the matrix to a vector of unit length and then */
	/* calculating the length of the transformed vector        */
	x = (mat[0] + mat[1] + mat[2]) * ONE_OVER_SQRT_THREE;
	y = (mat[4] + mat[5] + mat[6]) * ONE_OVER_SQRT_THREE;
	z = (mat[8] + mat[9] + mat[10]) * ONE_OVER_SQRT_THREE;
	cur_env->to_world_scale = sqrt( x*x + y*y + z*z );
	
	/* see if the environment matrix contains a mirror transformation */
	/* (i.e., the determinant < 0).                                   */
	det = (mat[5]*mat[10] - mat[6]*mat[9]) * mat[0] -
	      (mat[4]*mat[10] - mat[6]*mat[8]) * mat[1] +
	      (mat[4]*mat[9]  - mat[5]*mat[8]) * mat[2];

	if ( det < 0 )
	   cur_env->flags |= VE_ENV_MIRROR_TRANS;

	cur_env->ref_symb.flags |= (DPB_USE_ORIG_COLOR | DPB_USE_ORIG_STYLE | DPB_USE_ORIG_WEIGHT);

        GRspacenum_osnum = osnum;
	sts = VEgetreflevels( &msg, &mat_type, mat, &GRspacenum_osnum, 
                                                            cur_env->layers );

	/* determine the read/write status of the object space */
	os_status.stattype = OM_OS_STATUS_MISC;
	sts = om$send( msg = message OMObjSpace.get_status( &os_status ),
	               senderid = NULL_OBJID,
	               targetid = 0,  /* Object Space Object is always object 0 */
	               targetos = cur_env->osnum );

	   OM_ERRCHK( sts, "VEget_environment_info: OMObjSpace.get_status send failed" );

	cur_env->flags |= (os_status.stat.misc.OSflags & OM_e_loados_ro) ? VE_READ_ONLY_ENV : 0;
	cur_env->num_surfs = cur_env->num_curves = 0;

	is_master = FALSE;
	if ( (msg != MSSUCC) || (sts != OM_S_SUCCESS) )
	   {
	   /* this is the master file environment */
	   is_master = TRUE;
	   memcpy( cur_env->layers, VEwin_info.VEmaster_layers, sizeof( IGRint ) * 32 );
	   }
	else
	   {
	   /* get reference file override symbology, if it exists */
	   }
	
	/* get the clipping planes for this environment */
	VEdetermine_clipping_planes( cur_env, is_master );
	
	if ( batch_copy )
	   {
	   VEcreate_env_directories( batch_env->md_id.osnum, cur_env->attach_id );

	   /* construct line segment object the represents clipping      */
	   /* range and symbology override points if symbology overrides */
	   /* are in effect for this environment.                        */
	   VEconstruct_env_objects( cur_env, batch_env );
	   }

	/* get a reference plane for this environment */
	MAtypemx( &rc, (IGRdouble *)VEwin_info.VErot_matrix, &rot_mat_type );

	if ((!(cur_env->flags & VE_READ_ONLY_ENV)) || ( VEoutput_data.output_curves ))
           {
	   /* writable environement or running cve => create ref. plane there */
	   ems$get_reference_plane_for_given_orientation( msg          = &msg,
	                                                  env_info     = &cur_env->md_env,
	                                                  refpln_mxtyp = &rot_mat_type,
	                                                  refpln_mx    = (IGRdouble *)VEwin_info.VErot_matrix,
	                                                  pln_GRid     = &cur_env->ref_plane );
	   }
	else
	   {
	   /* rean-only environment => see if ref. plane exists in it already */
	   ems$get_reference_plane_for_given_orientation( msg          = &msg,
	                                                  /*options      = EMS_OPT_DO_NOT_CREATE,*/
	                                                  env_info     = &cur_env->md_env,
	                                                  refpln_mxtyp = &rot_mat_type,
	                                                  refpln_mx    = (IGRdouble *)VEwin_info.VErot_matrix,
	                                                  pln_GRid     = &cur_env->ref_plane );


	   if ( cur_env->ref_plane.objid == NULL_OBJID )
	      {
	      /* couldn't find ref plane in environment -> create one in the master environment */
	      ems$get_reference_plane_for_given_orientation( msg          = &msg,
	                                                     env_info     = &VEmaster_env,
	                                                     refpln_mxtyp = &rot_mat_type,
	                                                     refpln_mx    = (IGRdouble *) VEwin_info.VErot_matrix,
	                                                     pln_GRid     = &cur_env->ref_plane );
	      }
	   }

	cur_env->next = VEenv_list;
	VEenv_list = cur_env;

	return( cur_env );

	}  /* VEget_environment_info */


/*--- VEcreate_environment_for_batch ------------------------------------------*/

#if defined(__STDC__)
struct VEenv_info  *VEcreate_environment_for_batch( IGRshort osnum,
						    IGRlong  clip_diag_id,
						    IGRlong  color_id,
						    IGRlong  style_id,
						    IGRlong  weight_id )
#else
struct VEenv_info  *VEcreate_environment_for_batch( osnum,
	                                            clip_diag_id,
	                                            color_id, style_id, weight_id )

	IGRshort osnum;
	IGRlong  clip_diag_id;
	IGRlong  color_id;
	IGRlong  style_id;
	IGRlong  weight_id;
#endif

/*
NAME
	VEcreate_environment_for_batch

DESCRIPTION
	This function creates and initializes an environment structure during
	batch processing.  All the environments in batch have the identity
	matrix and the layer mask from the window.  The only thing that is
	different between environments is the clipping planes which are
	defined by a line segment representing the diagonal of the clipping
	volume and possible symbology overrides which are defined by point
	objects whose symbologies represent the override.

PARAMETERS
	osnum (IN) - object space of environment
	clip_diag_id (IN) - object id of the line-segment representing the
	                    clipping diagonal of the environment
	color_id (IN) - object id of the point whose color represents the
	                override color for the environment
	style_id (IN) - object id of the point whose style represents the
	                override style for the environment
	weight_id (IN) - object id of the point whose weight represents the
	                 override weight for the environment

GLOBALS USED
	VEenv_list
	VEwin_info
	VEexec_status

RETURN VALUES
	A pointer to the environment structure is returned

HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
	02/12/92    S.P. Rogers
	   Added prologue comment
*/

	{
	IGRlong             msg, rc;
	IGRshort            rot_mat_type;
	IGRint              i;
	struct VEenv_info   *cur_env;

	cur_env = (struct VEenv_info *) malloc( sizeof( struct VEenv_info ) );

	cur_env->attach_id = VEexec_status.VEattach_count++;
	cur_env->osnum     = osnum;
	memcpy( &cur_env->md_env, &VEmaster_env, sizeof( struct GRmd_env ) );
	
	/* assign matrix to be the identity */
	cur_env->matrix_type = MAIDMX;

	for ( i = 0; i < 16; i++ )
	   cur_env->matrix[i] = 0.0;

	cur_env->matrix[0] = cur_env->matrix[5] =
	cur_env->matrix[10] = cur_env->matrix[15] = 1.0;

	cur_env->to_world_scale = 1.0;
	
	/* copy layers from the window */
	memcpy( cur_env->layers, VEwin_info.VEmaster_layers, sizeof( IGRint ) * 32 );
	   
	/* get the clipping planes and symbology overrides for this environment */
	VEget_env_info_from_objects( osnum,
	                             clip_diag_id, color_id, style_id, weight_id,
	                             cur_env );

	/* get a reference plane for this environment */
	MAtypemx( &rc, (IGRdouble *)VEwin_info.VErot_matrix, &rot_mat_type );
	ems$get_reference_plane_for_given_orientation( msg          = &msg,
	                                               env_info     = &VEmaster_env,
	                                               refpln_mxtyp = &rot_mat_type,
	                                               refpln_mx    = (IGRdouble *)VEwin_info.VErot_matrix,
	                                               pln_GRid     = &cur_env->ref_plane );

	/* add to environment list */
	cur_env->next = VEenv_list;
	VEenv_list = cur_env;

	return( cur_env );

	}  /* VEcreate_environment_for_batch */

end implementation Root;

