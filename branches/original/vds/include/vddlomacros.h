/* $Id: vddlomacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/vddlomacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddlomacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/04/03  16:47:40  pinnacle
 * Replaced: include/vddlomacros.h by azuurhou r#
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


#ifndef vddlomacros_include
#define vddlomacros_include

/*
 * 	This file depends on the following files :
 *	
 *		$VDS/include/vddlodef.h
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

extern int VDgetDwgLOparam __((	IGRlong			*msg,
				IGRint			type,
				IGRchar			*rep,
				VD_drwLoInfo		*info ));

#if defined(__cplusplus)
}
#endif


/*---------------------------------------------------------------------------
  
  MACRO
	vd$drw_layout_info(	msg	= &msg,
				type	= VD_K_drwLO_****,
				rep	= &RepName,
				info	= &drwInfo );

  ABSTRACT
	Given a drawing layout type and a object representation (if needed)
	this macro returns the support information for drawing setups.

  ARGUMENTS

	data type	argument	I/O	description

	IGRlong		*msg		O :	Completion code

	IGRint          type            I :	options (vddrawdef.h)

        IGRchar		*rep            I :	Object representation name

        VD_drwLoInfo	*info		O :	Found information.


  EXAMPLE

  ------------------------------------------------------------------------*/

#omdef vd$drw_layout_info(	msg,
                                type,
                                rep	= NULL,
                                info )

	VDgetDwgLOparam (	(msg), (type), (rep), (info ));

#endomdef

/*---------------------------------------------------------------------------*/

#endif

