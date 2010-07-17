/* $Id: VSbevel.h,v 1.2 2001/01/16 23:53:16 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/include/VSbevel.h
 *
 * Description: created for bevel macros: Bevel, EJ_Bevel, VA_Bevel
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevel.h,v $
 *      Revision 1.2  2001/01/16 23:53:16  ramarao
 *      *** empty log message ***
 *
 * Revision 1.3  2000/05/22  21:20:48  pinnacle
 * ylong
 *
 * Revision 1.2  2000/04/27  23:07:38  pinnacle
 * Replaced: struct/include/VSbevel.h for:  by rchennup for Service Pack
 *
 * Revision 1.1  2000/04/24  21:40:26  pinnacle
 * ylong
 *
 * Revision 1.4  2000/04/05  12:57:52  pinnacle
 * Replaced: include/VSbevel.h for:  by impd252 for struct
 *
 * Revision 1.2  2000/02/29  16:36:48  pinnacle
 * ylong
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/14/00        ylong           Creation
 *      02/29/00        ylong           Added MAX_ATTRf and MAX_TEMPf
 *	04/18/00	ylong		modified for cmd Modify Bevel Attributes
 *	05/22/00	ylong		added some prototypes
 * -------------------------------------------------------------------*/

#ifndef VSbevel_include
#define VSbevel_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/******************************************************************
 * Definintions for command CObevel and CObevelMod 
 *
 ******************************************************************/

/*
 * define form VSbevel.frm
 */

/* general gadgets */
#define FORM_TITLE      11
#define MESSAGE_BAR     12
#define MACRO_TYPE      14
#define BEVEL_TEXT      23
#define BEVEL_TYPE      24
#define PROCESS_TEXT    25
#define PROCESS_TYPE    26
#define OFFSET_TEXT     27
#define OFFSET_VALUE    28
#define STOCK_TEXT      29
#define STOCK_VALUE     30
#define SHOW_BEVEL_BTN  33
#define	FONT_TEXT	51
#define	FONT_SIZE	52

/* gadet defininaton for "1 plate" csae, EJ_Bevel	*/
#define EJ_PLATE_BTN    34
#define EJ_PLATE_FLD    35
#define EJ_CURVE_BTN    36
#define EJ_CURVE_FLD    37
#define EJ_THICK_TEXT   38
#define EJ_TOGGLE_INPUT 39
#define EJ_THICK_IN     40
#define EJ_ADJPLATE_BTN 41
#define EJ_PLATE_IN     42
#define EJ_POINT_BTN    43

/* gadet defininaton for "2 plates" csae, Bevel	*/
#define PLATE1_BTN      15
#define PLATE1_FLD      16
#define PLATE2_BTN      17
#define PLATE2_FLD      18
#define EDGE1_BTN       19
#define EDGE1_FLD       20
#define EDGE2_BTN       21
#define EDGE2_FLD       22
#define POINT1_BTN      31
#define POINT2_BTN      32

/* gadet defininaton for "variabel plate" csae, VA_Bevel	*/
#define VA_PLATE_BTN    44
#define VA_PLATE_FLD    45
#define VA_BASE_CRV_BTN 46
#define VA_BASE_CRV_FLD 47
#define VA_OFF_CRV_BTN  48
#define VA_OFF_CRV_FLD  49
#define VA_POINT_BTN    50

/*
 * define constants for command CObevel and CObevelMod
 */
#define GAP_TOL         5.      // Define gap tolerance. Have to set base
                                // tolerance to 5 to get overlap between
                                // two edges with max gap 4 mm.
#define MAX_ATTRS	20	// the greatest number of atributes
#define MAX_ATTRf	4	// input attribute number for macro Fab_Stock 
#define MAX_ATTR1	7	// input attribute number for macro EJ_Bevel
#define MAX_ATTR2	6	// input attribute number for macro Bevel
#define MAX_ATTRv	6	// input attribute number for macro VA_Bevel

#define MAX_TEMPS	7	// the greatest number of templates
#define MAX_TEMPf	4       // attrs, plt,  crv,  pnt
#define MAX_TEMP1	4       // attrs, plt,  crv,  pnt
#define MAX_TEMP2	7       // attrs, plt1, plt2, edg1, edg2, pnt1, pnt2
#define MAX_TEMPv	5       // attrs, plt,  crv1, crv2, pnt


/* define enumerate for EJ_Beve/Fab_Stock input objects	*/
enum  TEMP1_INDEX  { E_ATTR, E_PLATE, E_CURVE, E_POINT } ;

/* define enumerate for Bevel input objects	*/
enum  TEMP2_INDEX  { ATTRIN, PLATE1,  PLATE2,  EDGE1, EDGE2, POINT1, POINT2 } ;

/* define enumerate for VA_Bevel input objects 	*/
enum  TEMPv_INDEX  { V_ATTR, V_PLATE, V_BASE_CRV, V_OFF_CRV, V_POINT } ;

/* define attrinute index	*/
enum  ATTRIBUTES 
  {macro_type, bevel_type, process_type, stock_value, offset_value, label_flag};

enum  EJ_ATTRIBUTES 
  {E_macro_type, E_bevel_type, E_process_type, E_stock_value, E_offset_value, 
   E_adjacent_plate, E_label_flag } ;

enum  VA_ATTRIBUTES 
  {V_macro_type, V_bevel_type, V_process_type, V_stock_value, V_offset_value, 
   V_label_flag} ;

enum  FAB_ATTRIBUTES 
  {F_macro_type, F_process_type, F_stock_value, F_offset_value, F_label_flag };



/*****************************************************************
 * Definitioins for Modify Bevel Attributes
 *
 *****************************************************************/

/* -----------------------------------------------
 * Buffer Lengths
 */
#define MAX_BEVELS		100  /* Max edges expected in a fence 	     */
#define MAX_FLD_LEN		128  /* Extra chars for any future extension */
#define MAX_PICKLIST_ENTRIES	20   /* Max values for individual attribute  */
				     /*   in edge_setup file                 */


/* ------------------------------------------------
 * Instance Data
 */
typedef struct {
  Form		form;
  IGRint	displayForm;
  
  IGRint	gadget;
  IGRint	col;
  IGRint	row;

  TGRid		plateID;
  TGRid		adjPlateID;
  TGRobj_env	bevelOE;
  TACrg_coll	attr[10] ;
  
} TVSbevelInfo;


/* ---------------------------------------
 * Prototypes
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong VSbvlMac_FillMCF
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_Fence_FillMCF
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_ReadSetupFile
  __((Form form, 
      IGRint gadget));

extern IGRlong VSbvlMac_PickedMCF
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_PickedList
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_PickedUpdButton
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_Attrs
  __((IGRint         objId,
      IGRchar       *name,
      IGRint         type,
      IGRchar       *value,
      TVSbevelInfo *info));

extern IGRlong VSbvlMac_ModAttrs
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_ResetForm
  __((TVSbevelInfo *info));

extern IGRlong VSbvlMac_GetAttrs
  __((TGRid          objID,
      IGRint        *attCnt,
      TACrg_coll   **attList));

extern IGRlong VSbvlMac_PutAttrs
  __((TGRid         *attrID,
      IGRint         cnt,
      TACrg_coll    *attrs));

extern IGRlong VSbvlMac_CreateColl
  __((TVSbevelInfo *info,
      TGRid	    *oldID,
      TGRid         *collID));


extern IGRlong VSbvlMacCMD_ModInit   __((TVSbevelInfo *info));
extern IGRlong VSbvlMacCMD_ModSleep  __((TVSbevelInfo *info));
extern IGRlong VSbvlMacCMD_ModWakeup __((TVSbevelInfo *info));
extern IGRlong VSbvlMacCMD_ModDelete __((TVSbevelInfo *info));
extern IGRlong VSbev_ReadSetupProcessSpec __((Form, IGRint, IGRint)) ;
extern IGRlong VSbev_ReadSetupFile __((Form)) ;

extern IGRstat VSgetBevelThicknessOld __((TGRid*, IGRdouble*));
extern IGRstat VSgetBevelAttributeOld __((TGRid*,IGRchar*,IGRchar*,IGRdouble*));
extern IGRstar VSgetBevelAttribute __((TGRid*, IGRchar*, IGRchar*, IGRdouble*));
extern IGRlong VScreateEJ_BevelFromVSedge3Datt __((TGRid*));
extern IGRlong VStransAllEdgesToEJ_Bevel __(()) ;
#if defined(__cplusplus)
}
#endif

/* -----------------------------------------------
 * Form Gadgets
 */

#define VSMOD_BVL_MCF     	12
#define VSMOD_BVL_FLD_LIST	14
#define VSMOD_BVL_FLD_LIST1	22
#define VSMOD_BVL_FLD_BTN	21

#endif

