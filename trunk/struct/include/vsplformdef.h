/*
	I/STRUCT
	Gadget labels of plate form.
*/
#ifndef vsplformdef_include
#	define vsplformdef_include

/*
 * Control bar.
 */
#	define VS_K_pl_Dismiss_Execute	 	1
#	define VS_K_pl_Execute		 	2
#	define VS_K_pl_Revert		 	3
#	define VS_K_pl_Dismiss		 	4
#	define VS_K_pl_Roll_Through		71

/*
 * Form titles.
 */
#	define VS_K_pl_Placement		11
#	define VS_K_pl_Modification		41

/*
 * Message field.
 */
#	define VS_K_pl_Message			10

/*
 * Definition.
 */
#	define VS_K_pl_Material_Type		19
#	define VS_K_pl_Material_Grade		20
#	define VS_K_pl_Plate_Type		21

/*
 * Plate Manipulation.
 */
#	define VS_K_pl_Thickness		33
#	define VS_K_pl_Cut_Off			34
#	define VS_K_pl_Offset			36
#	define VS_K_pl_Orientation		32
#	define VS_K_pl_Copy_Params		48

/*
 * Default gadgets.
 */
#	define VS_K_pl_Directory		22
#	define VS_K_pl_Name			23
#	define VS_K_pl_Number_Of_Plates		43
#	define VS_K_pl_Comments			69

/*
 * MTO gadgets.
 */
#	define VS_K_pl_Stock_Number		29
#	define VS_K_pl_Source			30
#	define VS_K_pl_Fireproofing		58
#	define VS_K_pl_Approval_Status 		49
#	define VS_K_pl_Construction_Status	51
#	define VS_K_pl_Member_Class		56
#	define VS_K_pl_Member_Type		57
#	define VS_K_pl_Change_Number		70

/*
 * User Attributes.
 */
#	define VS_K_pl_Mcf_User_Attributes	60

/*
 * Control Sub-form.
 */
#	define VS_K_pl_Definition 		42
#	define VS_K_pl_Plate_Manipulation	44
#	define VS_K_pl_Material_Take_Off	45
#	define VS_K_pl_User_Attributes		59

/*
 * Gadget Group.
 */
#	define VS_K_pl_Grp_Comments		80
#	define VS_K_pl_Grp_Def_Gadget		12
#	define VS_K_pl_Grp_Manip_Gadget		46
#	define VS_K_pl_Grp_MTO_Gadget		18
#	define VS_K_pl_Grp_User_Attributes	66
#	define VS_K_pl_Grp_Definition		VS_K_pl_Definition 	    +100
#	define VS_K_pl_Grp_Manipulation		VS_K_pl_Plate_Manipulation  +100
# 	define VS_K_pl_Grp_MTO			VS_K_pl_Material_Take_Off   +100
#	define VS_K_pl_Grp_UA			VS_K_pl_User_Attributes     +100

/* This following define isn't a gadget, it's just to known there is no group
   actif ( display ) */ 
   
#	define VS_K_pl_Grp_Default		80

#endif

