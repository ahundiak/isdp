/* $Id: VDrelat_hdr.S,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDrelat_hdr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrelat_hdr.S,v $
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
# Revision 1.2  1995/12/29  09:15:58  pinnacle
# Replaced: vdrelhdr/VDrelat_hdr.S for:  by svkadamb for vds.240
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
/*  VDrelat_hdr.S
/*  ludovic Le Corvec
/*  march_91
/*
/*  Abstract
/*	
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification VDrelat_hdr (0:0) of ACheader;

instance VDrelat_hdr 
{
	IGRchar		xtype;
};

override	ACmplace_from_def;     /* use occ symb */

override	ACfind_model,
		ACget_model_mgr,
		ACget_share_feet_list;
override	ACbubble_up,
		ACget_NV_rep;

override	NDupdate,
		NDcompute_node,
		NDdelete,
		NDcopy,
		NDchange_connect,
		NDconnect;

override 	GRget_locate_properties;

override	GRlocate;

/* for drawing to put up on ACheader */
override	NDdrawing_copy_geom,
		NDdrawing_copy_attr;

/* modif to put up on ACheader */
override	GRget_components,
		GRget_number_components,
		GRpass_messg;

/* modif to put up on ACheader */
override	ACreturn_foot;	/* return my_self with matrix of transformation */
override	GRdrop;		/* use make message */

override	unknown;

/* override db checkin mechanism. VDrelat_hdr have the same behaviour than 
its model */
override	ACcheckin_candidate,
		ACadd_to_list,
		ACadd_to_list_1,
		ACget_db_info;

reject		ACset_db_info;

/* **************** ACtransform_type **************************	*/
/*
/*	If action == 1 --> set transformation value
/*	If action == 0 --> get transformation value 
/*
/*	action		I   :	Type of action 
/*	*xtype		I/O :	Value of the transformation
/*
/* ==================================================================	*/

message ACtransform_type( IGRint action; IGRint *xtype );

/* ********************* ACntf_symbol () ******************************	*/
/*
/*	Notify symbol on type of action start perform on model
/*
/*	action_type	I : Action perform on model ( compute, consume ... )
/*	*msg		O : return code 
/*
/* ====================================================================	*/

message ACntf_symbol( IGRlong *msg; IGRint action_type );

override	ACshow_data;

/*
reject		ACconsume, 
		ACunconsume,
*/

override	ACtest_consumed;

reject		ACput_NV_rep,
		ACset_NV_rep;

end specification VDrelat_hdr;

