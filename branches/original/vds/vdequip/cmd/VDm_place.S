/* $Id: VDm_place.S,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/cmd / VDm_place.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_place.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/29  18:09:10  pinnacle
# Replaced: vdequip/cmd/VDm_place.S for:  by kddinov for vds
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
/*  VDm_place.S
/*  ludovic Le Corvec
/*  15_sept_90
/*
/*  Abstract
/*	New class of CO to place an occurence of equipment.
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification VDm_place (0:1) of COm_place;

#include "ACdb_info.h"

#define FORM_ACCEPT 1
#define EQUIP_LIB 13
#define FAMILY 16 
#define PART 19
#define ATTRIBUTES 14

#define VD_DYNAMICS 1

#define OBID_LEN	26

instance VDm_place
{
	struct ACdb_info db_info;
	variable int 	template_type[macro_MAX]; 
	int 		equip_lib_index;
	int 		family_index;
	int 		part_index;

	struct	GRid	stat_box;
	struct	GRid	dyn_box;

	IGRint		nb_tot_dyn;
	struct	sup	*dyn_dup;

	char		*Preloaded_items_form;
	IGRchar		PMobid[OBID_LEN];

/*----------------------------- 
* 12-97 KDD	
*  PIDUsrAttr		Dyn (VDequipment) or Usr (VREquipment) attr of
*			the located template to be used instead of DB.
*			I allocate and free the memory.
*
*  NumPIDUsrAttr	Number of PIDUsrAttr.
*
*  PIDAddAttr		Usr (VDequipment) or Add (VREquipment) attributes of 
*			the located template. I allocate and free the memory.
*
*  PIDNumAddAttr	number of PIDAddAttr.
*
*  LocatedPID		ID of the located template.
-----------------------------*/
	struct ACrg_coll   	*PIDUsrAttr, *PIDAddAttr;
	IGRint			PIDNumUsrAttr, PIDNumAddAttr;
	struct GRid		LocatedPID;
};

override
	get_form_name,
	init,
	wakeup,
	sleep,
	delete,
	prompt_macro,
	form_notification,
	write_form,
	place_macro,
	get_default_template,
	pro_template;

message VDppl_post_placement(); /* should be defined and imnplement in  */
                                /* COm_place .... but to late now       */


message VDm_display_select();
message VDm_read_pdu_part();

message init_pme_buffer();
message VDPsetSelectedPart( IGRlong *msg; IGRchar *CatalogName; IGRchar *PartNumber; IGRchar *PartRev; IGRchar *PMobid );

end specification VDm_place;
