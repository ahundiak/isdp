#ifndef vdrefmacro_include
#define vdrefmacro_include

/* I/VDS
 *
 * File:        ~VDS/include/vdrefmacros.h
 *
 * Description: This file contains macros for getting info about
 *		reference files
 *
 * History:
 *      11/04/94        Raju MSB
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

extern long VDget_ref_os_list __((
  long			*msg,
  GRspacenum		*main_os,
  int			*NbRefOs,
  GRspacenum		**RefOsList,
  struct GRmd_env	**RefEnvList
));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* -----------------------------------------------------------------------------

Macro
  vd$get_ref_os_list();

Abstract
  Gives list of all reference OS numbers and thier mod_envs.
  If one OS is attached twice with different mod envs, the list contains
  both the entries.
  If one OS is attached twice with the same mod env, only one entry will
  be there in the list.

  The output module environment matrix for a reference object space is
  the transformation matrix from the reference object space to 
  master object space.

Arguments
  IGRlong               *msg          O    return status
  GRspacenum		*main_os      I	   object space number. Reference OS
					   list of this OS is obtained.
					   = NULL, reference OS list of the
					   active OS is obtained.
  int			*NbRefOs      O    Number of reference OSs
  GRspacenum		**RefOsList   O    List of reference OSs.
					   = NULL, if not needed.
  struct GRmd_env	**RefEnvList  O    List of envs. Each module env
					   is transformation matrix from
					   reference OS to the main OS.
					   = NULL, if not needed.
IMPORTANT
  This function allocates memory for RefOsList and RefEnvList which
  should be freed by the caller.

Return status
  same as OM return status

Return message
  MSFAIL - failue

  EXAMPLE
  long			msg;
  int			NbRefOs;
  GRspacenum		main_os,
			*RefOsList = NULL;
  struct GRmd_env	*RefEnvList = NULL;

    ++  to get reference files attached to os 6 ++
    main_os = 6;

    sts = vd$get_ref_os_list (  msg	      =  &msg,
				main_os       =  &main_os,
				num_ref_os    =  &NbRefOs,
				ref_os_list   =  &RefOsList,
				ref_env_list  =  &RefEnvList );

    if ( RefOsList ) free ( RefOsList );
    if ( RefEnvList ) free ( RefEnvList );

  ------------------------------------------------------------------------- */

#omdef	vd$get_ref_os_list ( msg,
			     main_os,
			     num_ref_os,
			     ref_os_list = NULL,
			     ref_env_list = NULL )

	VDget_ref_os_list( (msg), (main_os), (num_ref_os),
			   (ref_os_list), (ref_env_list) )

#endomdef


#endif
