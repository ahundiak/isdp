/* $Id: VDSsymb_mac.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSsymb_mac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSsymb_mac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * File:	VDSsymbdef.h
 * Type:	C include file
 * Function:	Definitions for I/VDS representation types and
 *		om macro for call.
 * 
 */

#ifndef VDSsymb_mac_include

#define VDSsymb_mac_include

/*---------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDSsymbology __((	IGRlong	*msg,
				IGRint	operation,
				struct GRid *symb_id,
				struct VDSsymb *symbology ));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------

  MACRO
	vd$symbology(	msg	    = NULL,
			operation   = RETRIEVE,
			symb_id	    = NULL,
			symb	    = NULL  )
			
  ABSTRACT
	This function is designed to perform a store or retreive operation
	on the current active active parameters object. It also returns the  
	objid of the object corresponing to the osnum given by the caller.

  ARGUMENTS

	data type	argument	I/O description

	IGRlong		*msg		O : return code operation in call;
	IGRint		operation	I : Type of operation.
	struct GRid	symb_id		I : Defines the object space for the 
					    symbology.
	struct VDSsymb	symb		O : space for active VDS symbology.

  REMARKS
	operation:  Normally only RETRIEVE used (default).

  STATUS RETURNS

	OM_S_SUCCESS : Success
	OM_E_IVNVARG : Failure

  ------------------------------------------------------------------------- */

#omdef vd$symbology(	msg,
			operation   = RETRIEVE,
			symb_id,
			symb  )
	
VDSsymbology( ( msg ), ( operation ), ( symb_id ), ( symb ) )

#endomdef

/*---------------------------------------------------------------------------*/

#endif

