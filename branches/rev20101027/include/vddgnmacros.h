/* $Id: vddgnmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/vddgnmacros.h
 *
 * Description:
 *	macro is used for design setup parameter commands.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddgnmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/07/08  17:26:18  pinnacle
 * Created: include/vddgnmacros.h by yzhu for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/01/97	yzhu		create
 * -------------------------------------------------------------------*/


#ifndef vddgnmacros_include
#define vddgnmacros_include

/*
 * 	This file depends on the following files :
 *	
 *		$VDS/include/vdidgnmacros.h
 */

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDgetDgnStParam __((	IGRlong			*msg,
				IGRint			index,
				VD_dgnStInfo		*info ));

#if defined(__cplusplus)
}
#endif


/*---------------------------------------------------------------------------
  
  MACRO
	vd$dgn_setup_info(	msg	= &msg,
				index	= VD_K_dgnSt_****,
				info	= &drwInfo );

  ABSTRACT
	Given a design type index, this macro returns the support information 
	for design setups.

  ARGUMENTS

	data type	argument	I/O	description

	IGRlong		*msg		O :	Completion code
	IGRint          index           I :	index
        VD_drwLoInfo	*info		O :	Found information.


  EXAMPLE

  ------------------------------------------------------------------------*/

#omdef vd$dgn_setup_info(	msg,
                                index,
                                info )

	VDgetDgnStParam (	(msg), (index), (info ));

#endomdef

#endif

