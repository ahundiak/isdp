/*
	I/STRUCT
	Gadget labels of "Review Structural Part Definition" forms.
*/
#ifndef vsptformdef_include
#	define vsptformdef_include

#define VS_K_PLDEF_MASTER_FORM	"VSplPartDef.fm"
#define VS_K_BMDEF_MASTER_FORM	"VSbmPartDef.fm"
#define VS_K_USRATTR_FORM	"VSusrAttrib.fm"

#define VS_K_MASTER_LABEL	1
#define VS_K_UATTR_LABEL	101
/*----------------------------------------------------------------------------*/
/*			Same gadgets for the two forms			      */
/*----------------------------------------------------------------------------*/

			/*~~~	Field 	~~~*/
		
#	define VS_K_pt_Part_Name		12
#	define VS_K_pt_Material_Type		14
#	define VS_K_pt_Material_Grade		15
#	define VS_K_pt_Part_Type		16
#	define VS_K_pt_Part_Number		17
#	define VS_K_pt_Path			66

			/*~~~ Scroll Bar ~~~*/
			
#	define VS_K_pt_Scroll_Bar		33

			/*~~~ 	Group	~~~*/
			
#	define VS_K_pt_Grp_to_Scroll		90
 
			/*~~~	Button	~~~*/
			
#	define VS_K_pt_CopyBtn			65
#	define VS_K_pt_Faces			63
#	define VS_K_pt_PutQueue			68
#	define VS_K_pt_UsrAttr			69


/*----------------------------------------------------------------------------*/
/* 			Beam and Stiffener form				      */
/*----------------------------------------------------------------------------*/

			/*~~~	Field 	~~~*/
		
#	define VS_K_pt_bm_Section_Length	18
#	define VS_K_pt_bm_Section_Area		43
#	define VS_K_pt_bm_Rotation		45
#	define VS_K_pt_bm_X_Offset		46
#	define VS_K_pt_bm_Y_Offset		47
#	define VS_K_pt_bm_Section_Parameters	51

			/*~~~ 	Bezel 	~~~*/
			
#	define VS_K_pt_bm_Symmetry		28 
#	define VS_K_pt_bm_Reference_Point	28
#	define VS_K_pt_bm_Section		52

			/*~~~ Rectangle ~~~*/
			
#	define VS_K_pt_bm_Area			54

			/*~~~ 	Symbol 	~~~*/ 
			
#	define VS_K_pt_bm_X_Sym			38
#	define VS_K_pt_bm_Y_Sym			39
#	define VS_K_pt_bm_XY_Sym		40
#	define VS_K_pt_bm_No_Sym		41

#	define VS_K_pt_bm_Top_Left		30
#	define VS_K_pt_bm_Top_Middle		31
#	define VS_K_pt_bm_Top_Right		32
#	define VS_K_pt_bm_Center_Left		59
#	define VS_K_pt_bm_Center_Middle		29
#	define VS_K_pt_bm_Center_Right		34
#	define VS_K_pt_bm_Bot_Left		35
#	define VS_K_pt_bm_Bot_Mid		36
#	define VS_K_pt_bm_Bot_Right		37

			/*~~~	Group	~~~*/

#	define VS_K_pt_bm_Grp_Txt_Stiffener	56
#	define VS_K_pt_bm_Grp_Txt_Beam		57
#	define VS_K_pt_bm_Grp_Ref_Point		60
#	define VS_K_pt_bm_Grp_Sym		61
#	define VS_K_pt_bm_Grp_Sect_Param	62

/*----------------------------------------------------------------------------*/
/* 				Plate form				      */
/*----------------------------------------------------------------------------*/

			/*~~~	Field 	~~~*/
		
#	define VS_K_pt_pl_Cut_Off		13
#	define VS_K_pt_pl_Plate_Offset		18

			/*~~~	Toggle	~~~*/

#	define VS_K_pt_pl_Natural_Normal	31
#	define VS_K_pt_pl_Reverse_Normal	32

/*----------------------------------------------------------------------------*/
/*			Gadget label of sub-form of user attributes	      */
/*----------------------------------------------------------------------------*/
#	define VS_K_UATTR_FLD			12

#endif
