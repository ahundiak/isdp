/* $Id: vdpktmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vdpktmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpktmacros.h,v $
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

#ifndef vrpktmacros_include
#define vrpktmacros_include

/*
 * 	I/VDS
 *
 * This file contains a macro to add new icons to the pocket menu.
 *
 *	Dependencies:
 *		vdpktdef.h
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

extern int VDpkt_add_gadgets __((struct VDpktGadgets *gadgets));

extern int VDpkt_del_gadgets __((struct VDpktGadgets *gadgets));

extern int VDpkt_form __((char *pkt_form));

extern int VDpkt_menu __((void));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

  MARCO
	vd$pkt_add_gadgets ( gadgets );

  ABSTRACT
	Add symbol gadgets for a predefined product in the pocket menu.

  ARGUMENTS

	data type	argument	I/O	description

	struct VDpktGadgets *gadgets;	I : Structure containing the 
					    information to construct a icon 
					    (vdpktdef.h). 

  EXAMPLE

	Add the icon Push Hull for I/SMAN.

	sts = vd$pkt_add_gadgets (
			gadgets		= gadget_list );

	where
	    gadget_list[0].type_cmd	= FI_CMD_KEY ;
	    gadget_list[0].cmd		= "SMPlHl" ;
	    gadget_list[0].sym_file	= "SMfrm.sym" ;
	    gadget_list[0].sym_index	= 13 ;

	    gadget_list[1].type_cmd	= VDPKT_ENDLIST;
	
  REMARKS
	MSSUCC			oke
	VD_E_GRP_EXIST		pocket menu group exist
	VD_E_NO_POCKETMENU	no pocketmenu found
	VD_E_NO_DEF_POCKET	def pocket menu not found
	VD_E_ERROR		error in encountered

  ------------------------------------------------------------------------- */

#omdef	vd$pkt_add_gadgets ( gadgets )
#if ( ! om$specified( gadgets ))
#	omerror "Must specify list of gadgets to add "
#else
	VDpkt_add_gadgets( (gadgets) );
#endif

#endomdef

/*-------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

  MARCO
	vd$pkt_del_gadgets ( gadgets );

  ABSTRACT
	Delete symbol gadgets for a predefined product in the pocket menu.

  ARGUMENTS

	data type	argument	I/O description

	struct VDpktGadgets *gadgets;	I : Structure containing the
					    information to construct a icon
					    (vdpktdef.h). 

  EXAMPLE

	Delete the icon Push Hull for I/SMAN.

	sts = vd$pkt_del_gadgets (
			gadgets		= gadget_list );

	where
	    gadget_list[0].type_cmd	= FI_CMD_KEY ;
	    gadget_list[0].cmd		= "SMPlHl" ;
	    gadget_list[0].sym_file	= "SMfrm.sym" ;
	    gadget_list[0].sym_index	= 13 ;

	    gadget_list[1].type_cmd	= VDPKT_ENDLIST;
	
  REMARKS
	MSSUCC			oke
	VD_E_GRP_EXIST		pocket menu group exist
	VD_E_NO_POCKETMENU	no pocketmenu found
	VD_E_NO_DEF_POCKET	def pocket menu not found
	VD_E_ERROR		error in encountered

  ------------------------------------------------------------------------- */

#omdef	vd$pkt_del_gadgets ( gadgets )
#if ( ! om$specified( gadgets ))
#	omerror "Must specify list of gadgets to delete "
#else
	VDpkt_del_gadgets( (gadgets) );
#endif

#endomdef

/*-------------------------------------------------------------------------*/
/* -------------------------------------------------------------------------

  MACRO
	vd$pkt_form( pkt_form );

  ABSTRACT
	Get the pocket menu form pointer.

  ARGUMENTS

	data type	argument	I/O description

	char		*pkt_form;	I : the pocket form pointer.

  EXAMPLE

	vd$pkt_form ( pkt_form = &MS_pkt_menu );
	
  REMARKS
	MSSUCC			oke.
	VD_E_ERROR		error encountered

  -------------------------------------------------------------------------- */

#omdef	vd$pkt_form ( pkt_form )

#if ( ! om$specified( pkt_form ))
#	omerror "Must specify pocket form pointer "
#else
	VDpkt_form( (pkt_form) ); 
#endif

#endomdef

/*-------------------------------------------------------------------------*/
/* -------------------------------------------------------------------------

  MACRO
	vd$pkt_menu( );

  ABSTRACT
	Set the pocket menu form with given gadgets from the created list.

  ARGUMENTS

  EXAMPLE
	
  REMARKS
	MSSUCC			oke.
	VD_E_ERROR		error encountered

  -------------------------------------------------------------------------- */

#omdef	vd$pkt_menu ( )
	VDpkt_menu( ); 
#endomdef

/*-------------------------------------------------------------------------*/

#endif
