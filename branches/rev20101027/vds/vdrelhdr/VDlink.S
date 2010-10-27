/* $Id: VDlink.S,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDlink.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDlink.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*  VDlink
/*  ludovic Le Corvec
/*  march_92
/*
/*  Abstract
/*	VDlink is component of an VDrelat_hdr and children of an associtive
/*	object.
/*	VDlink send back to is father all unknow message.
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification VDlink (0:0) of GRconnector, NDnodein;

override	GRdisyourself;
override	GRlnproject;
override	GRlocate;
override	GRgetrang;

override	GRlocaldp,
		GRptproject,
		GRgetobjinfo,
		GRapprojpt,
		GRprismrel,
		GRcopy,
		GRrcopy,
		GRcptform,
		GRdisplay,
		GRgetprops,
		GRgethprops,
		GRgentform,
		GRclip;

// EMS30
override	GRplotyourself,
		GRformatele,
		GRadd_to_display_list,
		GRreport_defaults,
		GRreport,
		GRupdate_gadgets;

override	NDcompute_node,
		NDmove_to_root;

override	ACgive_structure,
		ACreturn_foot;

override	NDdrawing_copy_geom,
		NDdrawing_copy_attr;

override unknown;


reject		GRaddwrng, GRremwrng;
reject		GRxform;

/* ********************************************************************	*/
/*  ACdisconnect_head
/*
/*	disconnect the header pass and kill itself if they are no more
/*	header connect to him
/*
/*	*msg		/* return code */
/*	*header		/* GRid of header to disconnect */
/*	*md_env		/* module environment of header */
/*
/* --------------------------------------------------------------------	*/

message ACdisconnect_head( IGRlong *msg; struct GRid *header; 
						struct GRmd_env *md_env );

/* ********************************************************************	*/
/*  ACget_model_list
/*
/*	Get the set of objects who build the graphic model.
/*	This method is private.
/*
/*	*msg		O  /* return code */
/*	len_list	I  /* length of model list             */
/*	*mo_list	O  /* list of object who build model   */
/*	*model_count	O  /* count of object concern by model */ 
/*
/*	mo_list can be set to NULL if just model_count is desired
/*
/* --------------------------------------------------------------------	*/

message ACget_model_list( IGRlong *msg; IGRint len_list; struct	GRid *mo_list;
				IGRint	*model_count );

end specification VDlink;

