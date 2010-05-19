/* $Id: VDSequipdef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSequipdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSequipdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/12/29  21:25:50  pinnacle
 * Replaced: vdinclude/VDSequipdef.h for:  by kddinov for vds
 *
 * Revision 1.2  1997/11/24  21:02:02  pinnacle
 * Replaced: vdinclude/VDSequipdef.h for:  by kddinov for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/03/01  19:59:56  pinnacle
 * created to maintain the vds clix portion of pme
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

#ifndef VDSequipdef_include
#define VDSequipdef_include


/* These defines are used with the following "stat_dyn" field */
#define STAT_ATTR	0x0001	/* Static  attribute */
#define DYN_ATTR	0x0002	/* Dynamic attribute */
#define TMP_MAC		0x0010  /* Macro template    */

/* Commented because the structure is already defined as VDSatt_family
struct VDSatt_equip
  {
   IGRint		stat_dyn; 
   struct ACrg_coll 	attr;
  };
*/


/* Equipment macro definition */

#define	FEET_STAT_BOX	"stat_attr"
#define	FEET_DYN_BOX	"dyn_attr"
#define	FEET_GRAPHICS	"graphics"

#define READ_PDU		20
#define PRELOADED_EQUIPMENT	25
#define PDU_WARNING     	-2

/* KDD 11-97 New button to select from PID Equipment */
#define FI_SELECT_FROM_PID      18


/*
 * Used by VDREquip  (new equipmnet).
 * 
 * Define the internal status of the object.
 *
 */

#define VD_Eq_Error	0x01	/* Error status.			*/
#define VD_Eq_No_Rt	0x02	/* The equipment does not depend on     *
				 * graphic root.			*/
#define VD_Eq_Xform	0x04	/* Just need to apply an xform		*/


/* Some hard-coded equipment attributes  */

#define VD_Eq_PID_Scale	"pid_scale"	/* PID scale factor		*/
#define VD_Eq_Sys_Name	"system_name"	/* system name			*/
#define VD_Eq_Funct_Id	"functional_id" /* Functionnal identifier	*/
#define VD_Eq_Original  "original"	/* Original or referenced	*/
#define VD_Eq_Loc	"location"	/* location			*/
#define VD_Eq_Rota_Ang  "rotation_angle" /* Rotation angle              */
#define VD_Eq_ApprovStat "apprv_stat"    /* Approval status : NA or A   */
#define VD_Eq_Unit_Numb  "unit_number"  /* Unit number                  */
#define VD_Eq_Id	"tag_number"	/* Identifier 			*/

#define VD_Eq_Categ	"id_category"	/* Category			*/
#define VD_Eq_Behav	"id_behaviour"	/* Id behaviour			*/

#define VD_Eq_Crit	"search_crit"	/* Search crit in user tbl for family */

#define VD_Family	"family_name"	/* family name			*/
#define VD_Part_Num	"part_num"	/* family name			*/
#define VD_Part_Rev	"part_rev"	/* family name			*/
#define VD_Descript	"descript"	/* Description			*/

#define VD_Eq_App_Name	"app_name"	/* Application name		*/
#define VD_Eq_App_Type	"app_type"	/* Application type		*/
#define VD_Eq_App_SType	"app_subtype"	/* Application sub-type		*/
#define VD_Eq_Tbl_Name  "tbl_name"      /* User tbl name                */
#define VD_Eq_Tbl_Crit	"tbl_search"	/* User tbl search criteria	*/
#define VD_Eq_Tbl_Desc	"tbl_desc"	/* User tbl description		*/
#define VD_Eq_Sch_Symb  "sch_symb"      /* Schematic symbol             */

/* Use with the method VDGetCon */
#define VD_Eq_Noz	0x0001		/* Nozzles object		*/
#define VD_Eq_Con	0x0002		/* Connector object		*/


/* Some defined for the tag number management Mode argument of VDMgmTagNum()    */

#define VDTagNumberInit		0x01 /* Intitilize the list.			*/
#define VDTagNumberVerif	0x02 /* Verify the Tag number.			*/
#define VDTagNumberAuto		0x04 /* Select automatically a free tag number.	*/
#define VDTagNumberModif	0x08 /* Existing object, tag number modification*/

#define VDTagNumberModel	0x20 /* Model mode else schematic       	*/

#define VDTagNumberGetNewList   0x100 /* Get a new list (initial_form_notif)	*/

#define VDTagNumberDontFreePrev 0x1000 /* Internal use only			*/

#endif
