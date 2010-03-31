
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "GRtypedef.h"

/*#include "igetypedef.h"*/
#include "igrtypedef.h"
#include "igr.h"

#include "gr.h"

#include "bs.h"

#include "HStl_element.h"
#include "HStl_window.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hsurferrpriv.h"

#include "msdef.h"

#include "madef.h"

#include "HSpr_render.h"


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HRget_env.c */
static void HRdetermine_clipping_range __((
		   struct HRenv_record *env, 
			    IGRboolean is_master_env));
			    

#if defined(__cplusplus)
}
#endif


#undef __



/* External HS Functions */
extern struct HRenv_record *HRalloc_env_record();


#define EQUAL_MATRICES( mat1, mat2 )        \
                                            \
	( ( mat1[0]  == mat2[0]  ) &&       \
	  ( mat1[1]  == mat2[1]  ) &&       \
	  ( mat1[2]  == mat2[2]  ) &&       \
	  ( mat1[3]  == mat2[3]  ) &&       \
	  ( mat1[4]  == mat2[4]  ) &&       \
	  ( mat1[5]  == mat2[5]  ) &&       \
	  ( mat1[6]  == mat2[6]  ) &&       \
	  ( mat1[7]  == mat2[7]  ) &&       \
	  ( mat1[8]  == mat2[8]  ) &&       \
	  ( mat1[9]  == mat2[9]  ) &&       \
	  ( mat1[10] == mat2[10] ) &&       \
	  ( mat1[11] == mat2[11] ) &&       \
	  ( mat1[12] == mat2[12] ) &&       \
	  ( mat1[13] == mat2[13] ) &&       \
	  ( mat1[14] == mat2[14] ) &&       \
	  ( mat1[15] == mat2[15] ) )        \


/*--- HRdetermine_clipping_range -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRdetermine_clipping_range( struct HRenv_record *env,
							 IGRboolean is_master_env )
#else
	static void HRdetermine_clipping_range( env, is_master_env )

	struct HRenv_record *env;
	IGRboolean          is_master_env;
#endif
	
/*
DESCRIPTION
	This function determines the clipping range for an environment.

HISTORY
	S.P. Rogers  01/04/89  Creation Date
*/

	{
	IGRlong        msg;
	IGRint         i;
	GRspacenum     osnum;

	if ( is_master_env )
	   {
	   /* this is the master environment => set clipping range */
	   /* to be the dit clip range of the window               */
	   for ( i = 0; i < 6; i++ )
	      env->clip_range[i] = active_window->dit_clip_range[i];
	   
	   }
	else
	   {
	   /* not the master environment => get the nested clipping planes */
	   /* for this environment and take the intersection of them with  */
	   /* the window clipping range                                    */
	   osnum = env->osnum;
	   GRgetrefrange( &msg,
	                  &osnum,
	                  &env->matrix_type,
	                  env->matrix,
	                  active_window->dit_clip_range,
	                  active_window->transform_matrix,
	                  env->clip_range );
	   	                
	      MSG_ERRCHK( msg, "HRdetermine_clipping_range: GRgetrefrange failed" );
	   }

	}  /* HRdetermine_clipping_range */

	
/*---- HRget_environment_info ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HRenv_record *HRget_environment_info( IGRint osnum,
						  IGRmatrix mat,
						   IGRshort mat_type,
						     IGRint *master_layers )
#else
	struct HRenv_record *HRget_environment_info( osnum, mat, mat_type, master_layers )

	IGRint          osnum;
	IGRmatrix       mat;
	IGRshort        mat_type;
	IGRint          *master_layers;
#endif

/*
DESCRIPTION
	Search the global matrix list to see if a matrix equal to mat is there.
	If one is, return a pointer to it.  If one isn't there, add the new entry
	to the matrix list and return a pointer to it.

HISTORY
	S.P. Rogers  07/09/89  Creation Date
*/

	{
	IGRboolean          is_master;
	IGRlong             sts;
	IGRlong             msg;
	IGRint              i;
	IGRdouble           det;
	struct HRenv_record *cur_env;

	/* search environment list to see if this environment already exists */
	cur_env = rendering_globals.env_list;
	while ( cur_env  )
	   {
	   if ( (osnum == cur_env->osnum) && (EQUAL_MATRICES( mat, cur_env->matrix )) )
	      {
	      return( cur_env );
	      }
	   cur_env = cur_env->next;
	   }

	/* this environment is there yet, so add one to the beginning of the list */
	cur_env = HRalloc_env_record();
	cur_env->matrix_type = mat_type;
	cur_env->osnum       = osnum;
	
	for ( i = 0; i < 16; i++ )
	   cur_env->matrix[i] = mat[i];

	/* see if the environment matrix has a mirror in it */
	det = (mat[5]*mat[10] - mat[6]*mat[9]) * mat[0] -
	      (mat[4]*mat[10] - mat[6]*mat[8]) * mat[1] +
	      (mat[4]*mat[9]  - mat[5]*mat[8]) * mat[2];
	cur_env->mirror_transform = ( det < 0 );
	   
	sts = GRgetreflevels( &msg, &mat_type, mat, &osnum, cur_env->layers );

	is_master = FALSE;
	
	if ( (msg != MSSUCC) || (sts != OM_S_SUCCESS) )
	   {
	   /* this is the master file environment */
	   is_master = TRUE;
	   for ( i = 0; i < 32; i++ )
	      cur_env->layers[i] = master_layers[i];
	   }
	
	/* get the clipping range for this environment */
	HRdetermine_clipping_range( cur_env, is_master );
	
	/* add to environment list */
	cur_env->next = rendering_globals.env_list;
	rendering_globals.env_list = cur_env;

	return( cur_env );

	}  /* HRget_environment_info */
