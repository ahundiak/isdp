/*
	I/STRUCT
	Gadget labels of beam form.
*/
#ifndef vsbmformdef_include
#	define vsbmformdef_include

/*
 * Control bar.
 */
#	define VS_K_bm_Dismiss_Execute		1
#	define VS_K_bm_Execute		 	2
#	define VS_K_bm_Revert			3
#	define VS_K_bm_Dismiss		 	4
#	define VS_K_bm_Roll_Through		108

/*
 * Form titles.
 */
#	define VS_K_bm_Placement		11
#	define VS_K_bm_Modification		70
#	define VS_K_sf_Placement		84
#	define VS_K_sf_Modification		88

/*
 * Gadget text.
 */
#	define VS_K_bm_txt_Name			17
#	define VS_K_bm_txt_Number_Of_Beams	54
#	define VS_K_bm_txt_Beam_Type		15
#	define VS_K_bm_txt_Rotation		62
#	define VS_K_bm_txt_Y_Offset		52
#	define VS_K_bm_txt_X_Offset		50

/*
 * Message field.
 */
#	define VS_K_bm_Message			10

/*
 * Definition.
 */
#	define VS_K_bm_Material_Type		19
#	define VS_K_bm_Material_Grade		20
#	define VS_K_bm_Shape_Name		21
#	define VS_K_bm_Beam_Length	        123	

/*
 * Default gadgets.
 */
#	define VS_K_bm_Directory		22
#	define VS_K_bm_Name			23
#	define VS_K_bm_Number_Of_Beams		57
#	define VS_K_bm_Comments			69

/*
 * MTO gadget.
 */
#	define VS_K_bm_Stock_Number		29
#	define VS_K_bm_Source			30
#	define VS_K_bm_Fireproofing		31
#	define VS_K_bm_Approval_Status 		94
#	define VS_K_bm_Construction_Status	93
#	define VS_K_bm_Member_Class		91
#	define VS_K_bm_Member_Type		92
#	define VS_K_bm_Change_Number		103

/*
 * Section manipulation.
 */
#	define VS_K_bm_Section_Name		59
#	define VS_K_bm_Display_Ratio		56
#	define VS_K_bm_Copy_Params		55
#	define VS_K_bm_Parameters		72
#	define VS_K_bm_Section_Area		104
#	define VS_K_bm_Section_Length		105

/*
 *		Symmetry buttons.
 */
#	define VS_K_bm_X_Sym			36
#	define VS_K_bm_Y_Sym			37
#	define VS_K_bm_XY_Sym			38
#	define VS_K_bm_No_Sym			39

/*
 *		Reference point buttons.
 */
#	define VS_K_bm_Top_Left			41
#	define VS_K_bm_Top_Middle		42
#	define VS_K_bm_Top_Right		43
#	define VS_K_bm_Center_Left		44
#	define VS_K_bm_Center_Middle		45
#	define VS_K_bm_Center_Right		46
#	define VS_K_bm_Bot_Left			47
#	define VS_K_bm_Bot_Mid			48
#	define VS_K_bm_Bot_Right		49

/*
 *		Section position.
 */
#	define VS_K_bm_X_Offset			60
#	define VS_K_bm_Y_Offset			61
#	define VS_K_bm_Rotation			65
#	define VS_K_sf_Position			24
#	define VS_K_xs_Position			121
#	define VS_K_tws_Rotation		122
/*
 * All these gadgets belong to the `Define Twist Rotation' sub form
 */
#	define VS_K_tws_StAngle			12
#	define VS_K_tws_EdAngle			13
#	define VS_K_tws_StRefType		18
#	define VS_K_tws_EdRefType		19
/*
 * User Attributes.
 */
#	define VS_K_bm_Mcf_User_Attributes	98 

/*
 * Control Sub-form.
 */
#	define VS_K_bm_Definition 		63
#	define VS_K_bm_Section_Manipulation	12
#	define VS_K_bm_Material_Take_Off	18
#	define VS_K_bm_User_Attributes		97

/*
 * Area to draw section on the form.
 */
#	define VS_K_bm_Rectangle		51
#	define VS_K_bm_Area			83

#	define VS_K_bm_AccessToGapDetctGrp	120
/*
 * Group for Gap Detection (stiffeners only). All these gadges belong to
 * grpup `VS_K_bm_Grp_GapDetection'.
 */
#	define VS_K_bm_GapDetectionFrameLine1	28
#	define VS_K_bm_GapDetectionFrameLine2	109
#	define VS_K_bm_GapDetectionFrameLine3	110
#	define VS_K_bm_GapDetectionFrameLine4	111
#	define VS_K_bm_GapDetection_Title	112
#	define VS_K_bm_GapDetection_Toggle	113
#	define VS_K_bm_GapDetection_ValFld	117
#	define VS_K_bm_GapDetection_ValTxt	115
#	define VS_K_bm_GapDetection_MaxFld	116
#	define VS_K_bm_GapDetection_MaxTxt	114
#	define VS_K_bm_GapDetection_Symbol	118

/*
 * Gadget Group.
 */
#	define VS_K_bm_Grp_Comments	   80
#	define VS_K_bm_Grp_Top_Button	   82
#	define VS_K_bm_Grp_Def_Gadget	   64
#	define VS_K_bm_Grp_Manip_Gadget    79
#	define VS_K_bm_Grp_Sym_Gadget	   78
#	define VS_K_bm_Grp_Ref_Gadget	   77
#	define VS_K_bm_Grp_MTO_Gadget	   32
#	define VS_K_bm_Grp_User_Attributes 100
#	define VS_K_bm_Grp_Manipulation	   (VS_K_bm_Section_Manipulation+500)
#	define VS_K_bm_Grp_MTO		   (VS_K_bm_Material_Take_Off   +500)
#	define VS_K_bm_Grp_Definition	   (VS_K_bm_Definition 	    	+500)
#	define VS_K_bm_Grp_UA		   (VS_K_bm_User_Attributes     +500)
#	define VS_K_bm_Grp_GapDetection	   119

/* This following define isn't a gadget, it's just to know there is no active
 *  group ( display )
 */ 

#	define VS_K_bm_Grp_Default		80

/*
 *  Gadget text for stiffener.
 */
#	define VS_K_sf_txt_Number_Of_Stiff  	85
#	define VS_K_sf_txt_Name			86
#	define VS_K_sf_txt_Stiffener_Type	87

#endif

