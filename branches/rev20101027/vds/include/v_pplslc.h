/* $Id: v_pplslc.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        include/v_pplslc.h
 *
 * Description: Includes all definitions and macros for 
 *	        'exec-ppl-func' keyword functionality.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: v_pplslc.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/11/25  06:19:22  pinnacle
 * Replaced: include/v_pplslc.h for:  by rchennup for vds
 *
 * Revision 1.1  1997/11/19  08:47:28  pinnacle
 * Created: include/v_pplslc.h by rchennup for vds
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/19/97   Rama Rao     File Creation
 *************************************************************************/

#ifndef v_pplslc_include
#define v_pplslc_include

#define	INPUT_INFO	0
#define	OUTPUT_INFO	1
#define	GLOBAL_INFO	2

extern long
VDppl_GetSize	__((	IGRint          which_info,
			IGRint		*size   	));

#omdef vd$ppl_get_size(  which_info,
			 size	 	)

	VDppl_GetSize( (which_info), (size) )

#endomdef

extern long
VDppl_SetSize   __((    IGRint          which_info,
                        IGRint          size   		));

#omdef vd$ppl_set_size(  which_info,
                         size    	)

        VDppl_SetSize( (which_info), (size) )

#endomdef

extern long
VDppl_FreeGlobal  __((  IGRint          which_info ));

#omdef vd$ppl_free_args( which_info )

	VDppl_FreeGlobal( (which_info) )

#endomdef

extern long
VDppl_GetArg_AtIndex	__((	IGRint		which_info,
				IGRint		index,
				IGRint          *type,
				void            *value ));

#omdef vd$ppl_getarg_at_index( 	which_info,
				index,
				type 	= NULL,
				value 	= NULL   )

	VDppl_GetArg_AtIndex( (which_info), (index), (type), (value) )

#endomdef

extern long
VDppl_SetArg_AtIndex	__((	IGRint		which_info,
				IGRint		index,
				IGRint          type,
				void            *value ));

#omdef vd$ppl_setarg_at_index( 	which_info,
				index,
				type,
				value 	)

	VDppl_SetArg_AtIndex( (which_info), (index), (type), (value) )

#endomdef

extern long
VDppl_exec		__((    IGRchar		*file_name,
				IGRchar		*func_name,
				IGRint		nb_args,
				VD_execRes	*args_list   ));

#omdef vd$ppl_exec(  file_name,
		     func_name = "main",
		     nb_args   = 0,
		     args_list = NULL	 )

	VDppl_exec( (file_name), (func_name), (nb_args), (args_list) )

#endomdef

extern long
VDobj_ppl_exec		__((    IGRchar		*file_name,
				IGRchar		*func_name,
				struct GRid	*object,
				struct GRmd_env *module_info,
				IGRint		IN_count,
				VD_execRes	*IN_args,
				IGRint		*OUT_count,
				VD_execRes	**OUT_args  ));

#omdef vd$obj_ppl_exec( file_name,
		     	func_name   = "main",
		     	object      = NULL,
		     	module_info = NULL,
		     	IN_count    = 0,
		     	IN_args     = NULL,
		     	OUT_count   = NULL,
		     	OUT_args    = NULL	)

	VDobj_ppl_exec( (file_name), (func_name), (object), (module_info),
			(IN_count), (IN_args), (OUT_count), (OUT_args) )

#endomdef

#endif
