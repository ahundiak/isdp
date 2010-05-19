#ifndef vdvvolmacro_include
#define vdvvolmacro_include

/* I/VDS
 *
 * File:        ~VDS/include/vdvvolmacros.h
 *
 * Description: This file contains macros for getting info about
 *		view volumes
 *
 * History:
 *      11/07/94        Raju MSB
 *
 */

/*============================================================================*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern long VDgetVVolList __((
  long			*msg,
  int			*num_vvol,
  struct GRid		**vvol_ids,
  struct GRmd_env	**vvol_env,
  char			***vvol_names,
  char			***vvol_desc
));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* -----------------------------------------------------------------------------

Macro
  vd$get_vvol_list();

Abstract
  This macro gives list of view volumes defined in active
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
  MSSUCC - success
  MSFAIL - failue

  EXAMPLE
  long			msg;
  int			num_vvol;
  struct GRid		*vvol_ids = NULL;
  struct GRmd_env	*vvol_envs = NULL;
  char			**vvol_names = NULL;
  char			**vvol_desc = NULL;


  sts = vd$get_vvol_list (  	msg       =  &msg,
				num_vvol  =  &num_vvol,
				vvol_ids  =  &vvol_ids,
				vvol_envs =  &vvol_envs,
				vvol_names=  &vvol_names,
				vvol_desc =  &vvol_desc );
  if ( vvol_ids ) free (vvol_ids);
  if ( vvol_envs ) free (vvol_envs);
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

  ------------------------------------------------------------------------- */

#omdef	vd$get_vvol_list ( msg,
			   num_vvol,
			   vvol_ids = NULL,
			   vvol_env = NULL,
			   vvol_names = NULL,
			   vvol_desc = NULL )

	VDgetVVolList( (msg), (num_vvol), (vvol_ids), (vvol_env),
						(vvol_names), (vvol_desc) )

#endomdef


#endif
