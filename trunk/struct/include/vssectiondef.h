/* $Id: vssectiondef.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:       include/vssectiondef.h
 *
 * Description: Beam profile definations
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vssectiondef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/18  17:23:38  pinnacle
 * Added Beam Faces
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	02/18/98   ah		Added 34 additional beam faces
 *************************************************************************/

#ifndef vssectiondef_include
#define vssectiondef_include

/*
 * Names of meaningful parameters of cross-section.
 */
#define VS_K_scHeight		"height"
#define VS_K_scWidth		"width"
#define VS_K_scFlgThk		"flgThickness"
#define VS_K_scWebThk		"webThickness"
#define VS_K_scFltRad		"fltRadius"

/*
 * Names of different representations of cross-section.
 */
#define	VS_K_WFilletCv		"with_fillet"
#define VS_K_WoFilletCv		"without_fillet"
#define VS_K_SchematicCv	"schematic"
#define	VS_K_EnvelopeCv		"interference"

/*
 * Codes for beams faces/section components (sc).
 * Key :	F : flange
 *		W : web
 *		S : superior
 *		I : inferior
 *		i : interior
 *		e : exterior
 *		L : left
 *		R : right
 */
#define	VS_K_sc_FlgSupR		0
#define	VS_K_sc_FlgSupE		1
#define	VS_K_sc_FlgSupL		2
#define	VS_K_sc_FlgSupILS	3
#define	VS_K_sc_FlgSupILF	4
#define	VS_K_sc_WebL		5
#define	VS_K_sc_FlgInfILF	6
#define	VS_K_sc_FlgInfILS	7
#define	VS_K_sc_FlgInfL		8
#define	VS_K_sc_FlgInfE		9
#define	VS_K_sc_FlgInfR		10
#define	VS_K_sc_FlgInfIRS	11
#define	VS_K_sc_FlgInfIRF	12
#define	VS_K_sc_WebR		13
#define	VS_K_sc_FlgSupIRF	14
#define	VS_K_sc_FlgSupIRS	15
#define	VS_K_sc_Circle		16
/*
 * Additional beams faces.
 */
#define	VS_K_sc_FlgSupR_2	17
#define	VS_K_sc_FlgSupE_2	18
#define	VS_K_sc_FlgSupL_2	19
#define	VS_K_sc_FlgSupILS_2	20
#define	VS_K_sc_FlgSupILF_2	21
#define	VS_K_sc_WebL_2		22
#define	VS_K_sc_FlgInfILF_2	23
#define	VS_K_sc_FlgInfILS_2	24
#define	VS_K_sc_FlgInfL_2	25
#define	VS_K_sc_FlgInfE_2	26
#define	VS_K_sc_FlgInfR_2	27
#define	VS_K_sc_FlgInfIRS_2	28
#define	VS_K_sc_FlgInfIRF_2	29
#define	VS_K_sc_WebR_2		30
#define	VS_K_sc_FlgSupIRF_2	31
#define	VS_K_sc_FlgSupIRS_2	32
#define	VS_K_sc_Circle_2	33

#define	VS_K_sc_FlgSupR_3	34
#define	VS_K_sc_FlgSupE_3	35
#define	VS_K_sc_FlgSupL_3	36
#define	VS_K_sc_FlgSupILS_3	37
#define	VS_K_sc_FlgSupILF_3	38
#define	VS_K_sc_WebL_3		39
#define	VS_K_sc_FlgInfILF_3	40
#define	VS_K_sc_FlgInfILS_3	41
#define	VS_K_sc_FlgInfL_3	42
#define	VS_K_sc_FlgInfE_3	43
#define	VS_K_sc_FlgInfR_3	44
#define	VS_K_sc_FlgInfIRS_3	45
#define	VS_K_sc_FlgInfIRF_3	46
#define	VS_K_sc_WebR_3		47
#define	VS_K_sc_FlgSupIRF_3	48
#define	VS_K_sc_FlgSupIRS_3	49
#define	VS_K_sc_Circle_3        50

#define	VS_K_sc_FlgSupR_4	51
#define	VS_K_sc_FlgSupE_4	52
#define	VS_K_sc_FlgSupL_4	53
#define	VS_K_sc_FlgSupILS_4	54
#define	VS_K_sc_FlgSupILF_4	55
#define	VS_K_sc_WebL_4		56
#define	VS_K_sc_FlgInfILF_4	57
#define	VS_K_sc_FlgInfILS_4	58
#define	VS_K_sc_FlgInfL_4	59
#define	VS_K_sc_FlgInfE_4	60
#define	VS_K_sc_FlgInfR_4	61
#define	VS_K_sc_FlgInfIRS_4	62
#define	VS_K_sc_FlgInfIRF_4	63
#define	VS_K_sc_WebR_4		64
#define	VS_K_sc_FlgSupIRF_4	65
#define	VS_K_sc_FlgSupIRS_4	66
#define	VS_K_sc_Circle_4        67

#define VS_K_sc_MAXFACES	68

/*
 * Internal names corresponding to above-defined indices.
 */
#define	VS_K_nmFlgSupR		"flg_sup_r"
#define	VS_K_nmFlgSupE		"flg_sup_e"
#define	VS_K_nmFlgSupL		"flg_sup_l"
#define	VS_K_nmFlgSupILS	"flg_sup_ils"
#define	VS_K_nmFlgSupILF	"flg_sup_ilf"
#define	VS_K_nmWebL		"web_____l"
#define	VS_K_nmFlgInfILF	"flg_inf_ilf"
#define	VS_K_nmFlgInfILS	"flg_inf_ils"
#define	VS_K_nmFlgInfL		"flg_inf_l"
#define	VS_K_nmFlgInfE		"flg_inf_e"
#define	VS_K_nmFlgInfR		"flg_inf_r"
#define	VS_K_nmFlgInfIRS	"flg_inf_irs"
#define	VS_K_nmFlgInfIRF	"flg_inf_irf"
#define	VS_K_nmWebR		"web_____r"
#define	VS_K_nmFlgSupIRF	"flg_sup_irf"
#define	VS_K_nmFlgSupIRS	"flg_sup_irs"
#define	VS_K_nmCircle		"circle"
/*
 * Additional beams faces.
 */
#define	VS_K_nmFlgSupR_2	"FLG_SUP_R"
#define	VS_K_nmFlgSupE_2	"FLG_SUP_E"
#define	VS_K_nmFlgSupL_2	"FLG_SUP_L"
#define	VS_K_nmFlgSupILS_2	"FLG_SUP_ILS"
#define	VS_K_nmFlgSupILF_2	"FLG_SUP_ILF"
#define	VS_K_nmWebL_2		"WEB_____L"
#define	VS_K_nmFlgInfILF_2	"FLG_INF_ILF"
#define	VS_K_nmFlgInfILS_2	"FLG_INF_ILS"
#define	VS_K_nmFlgInfL_2	"FLG_INF_L"
#define	VS_K_nmFlgInfE_2	"FLG_INF_E"
#define	VS_K_nmFlgInfR_2	"FLG_INF_R"
#define	VS_K_nmFlgInfIRS_2	"FLG_INF_IRS"
#define	VS_K_nmFlgInfIRF_2	"FLG_INF_IRF"
#define	VS_K_nmWebR_2		"WEB_____R"
#define	VS_K_nmFlgSupIRF_2	"FLG_SUP_IRF"
#define	VS_K_nmFlgSupIRS_2	"FLG_SUP_IRS"
#define	VS_K_nmCircle_2		"CIRCLE"

#define	VS_K_nmFlgSupR_3	"FLg_SUP_R"
#define	VS_K_nmFlgSupE_3	"FLg_SUP_E"
#define	VS_K_nmFlgSupL_3	"FLg_SUP_L"
#define	VS_K_nmFlgSupILS_3	"FLg_SUP_ILS"
#define	VS_K_nmFlgSupILF_3	"FLg_SUP_ILF"
#define	VS_K_nmWebL_3		"WEb_____L"
#define	VS_K_nmFlgInfILF_3	"FLg_INF_ILF"
#define	VS_K_nmFlgInfILS_3	"FLg_INF_ILS"
#define	VS_K_nmFlgInfL_3	"FLg_INF_L"
#define	VS_K_nmFlgInfE_3	"FLg_INF_E"
#define	VS_K_nmFlgInfR_3	"FLg_INF_R"
#define	VS_K_nmFlgInfIRS_3	"FLg_INF_IRS"
#define	VS_K_nmFlgInfIRF_3	"FLg_INF_IRF"
#define	VS_K_nmWebR_3		"WEb_____R"
#define	VS_K_nmFlgSupIRF_3	"FLg_SUP_IRF"
#define	VS_K_nmFlgSupIRS_3	"FLg_SUP_IRS"
#define	VS_K_nmCircle_3		"CIrCLE"

#define	VS_K_nmFlgSupR_4	"FLg_SUP_r"
#define	VS_K_nmFlgSupE_4	"FLg_SUP_e"
#define	VS_K_nmFlgSupL_4	"FLg_SUP_l"
#define	VS_K_nmFlgSupILS_4	"FLg_SUP_ils"
#define	VS_K_nmFlgSupILF_4	"FLg_SUP_ilf"
#define	VS_K_nmWebL_4		"WEb_____l"
#define	VS_K_nmFlgInfILF_4	"FLg_INF_ilf"
#define	VS_K_nmFlgInfILS_4	"FLg_INF_ils"
#define	VS_K_nmFlgInfL_4	"FLg_INF_l"
#define	VS_K_nmFlgInfE_4	"FLg_INF_e"
#define	VS_K_nmFlgInfR_4	"FLg_INF_r"
#define	VS_K_nmFlgInfIRS_4	"FLg_INF_irs"
#define	VS_K_nmFlgInfIRF_4	"FLg_INF_irf"
#define	VS_K_nmWebR_4		"WEb_____r"
#define	VS_K_nmFlgSupIRF_4	"FLg_SUP_irf"
#define	VS_K_nmFlgSupIRS_4	"FLg_SUP_irs"
#define	VS_K_nmCircle_4		"CIrcle"

#endif




