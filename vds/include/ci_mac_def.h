/* $Id: ci_mac_def.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include/ci_mac_def.h
 *
 * Description:
 *	ci_macro definition
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ci_mac_def.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1997/04/18  13:20:14  pinnacle
 * Created: include/ci_mac_def.h by v241_int for vds.241
 *
 *
 * History:
 *	3/18/97	    adz		Copy from GRNUC.
 *
 *************************************************************************/

/* */
/*---------------------------------------------------------------------------
/*      This macro  is used to create a ci_macro definition. It is
/*	the only message nessary to create a macro definition
/*	The user does not need to do an edit template if no special
/*	mapping is necessary between the definition templates and
/*	the one that will be required at placement of an ocurence.
/*
/*      Argument description :
/*      --------------------
/*
/*      IGRint *status       	O  : the returned status
/*                                      OM_S_SUCCESS : successfull operation
/*                                      OM_E_ABORT   : fatal error
/*
/*	IGRint prop		I :
/*		
/*      IGRchar  *cpx_name	I : by default a file with .u(or .e if allready 
/*				compiled) suffix is used to dynamic load. 
/*				the name of the ci file implementing the macro
/*				can be changed by the message ACchange_ci_name.
/*				this ci file must at least implement the
/*				functions :
/*
/*					place ()
/*					compute()
/*
/*				it can too implements :
/*
/*					NDdelete()
/*					GRxform()
/*					NDmove_to_root()
/*
/*    	IGRchar  *int_name 	I : name of the internal structure variable
/*				that will be declared in the ci file 
/*				implementing the macro.This variable can
/*				be used to save flag or non graphic information
/*				that will be used for the internal computation
/*				and not be referenced by other macros 
/*				connecting to this one.
/*
/*	IGRint int_size 	I : size of the internal structure in bytes.
/*
/*	IGRint temp_num 	I : number of templates.
/*
/*	IGRchar **temp_name 	I : templates names
/*
/*	IGRint temp_feet_num 	I : number of templates that are also named feet.
/*
/*	IGRint temp_types 	I : define the type of object accepted
/*				at the placement of an occurence
/*				(line_generic..). These types are defined in
/*				parametric.h
/*				if NULL means any type is OK.
/*
/*	IGRint temp_feet_index  I : index in the templates of the templates
/*				that are also named feet.
/*
/*	IGRchar **temp_feet_names : their names as feet
/*
/*	IGRint intern_feet_num 	I : feet stored in the ci as pointer 
/*				to returned structure	.
/*
/*	IGRchar **intern_feet_name 
/*				I : their names
/*
/*	IGRint *intern_feet_types 
/*				I : define the type of internal feet
/*   	
/*
/*      IGRint extern_feet_num 	I : number of feet existing as real objects
/*				on the to components channels. All objects
/*				on this channel are named feet.
/*
/*	IGRchar **extern_feet_name 
/*				I : their name
/*
/*	IGRint *extern_types 	I : define the type of external feet
/*
/*	IGRint *feet_order 	I :
/*
/*      FOR SIMPLICITY :
/*      ================
/*
/*
/*---------------------------------------------------------------------------
/* */

extern struct GRid 	AC_construct_id;
#omdef ac$cimacdef( cimacdef,
		status, 		
		prop=0,			name,
		int_name="",		int_size=0,
		temp_num, 		temp_names,
		temp_types=0,	
		temp_feet_num=0,	
		temp_feet_index=0,	temp_feet_names=0,
		intern_feet_num=0,	intern_feet_names=0,
		intern_feet_types=0,
		extern_feet_num=0,	extern_feet_names=0,
		external_feet_types=0,
		feet_order=0 )
{
	ci$send( msg = message ci_mac_def.ACplace(
			(status), 		
			(prop),			(name),
			(int_name),		(int_size),
			(temp_num), 		(temp_names),
			(temp_types),	
			(temp_feet_num),	
			(temp_feet_index),	(temp_feet_names),
			(intern_feet_num),	(intern_feet_names),
			(intern_feet_types),
			(extern_feet_num),	(extern_feet_names),
			(external_feet_types),
			(feet_order) ),
		 targetid = (cimacdef) ,targetos=AC_construct_id.osnum);
}
	
#endomdef

/* 
   ABSTRACT
   ARGUMENTS
*/


