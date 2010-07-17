/* $Id: VSbaMod.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	include/VSbaMod.h
 *
 * Description: Modify Stiffener Axis
 *	
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbaMod.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1998/03/22  13:58:10  pinnacle
 * CR179800676
 *
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 03/22/98  ah        CR179800676 Modify Stiffener Axis
 *    ""               CR179800677 Set axis orientation
 ***************************************************************************/

#ifndef VSbaMod_include
#define VSbaMod_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#define VSBA_AXIS_MAX 256

/* ---------------------------------------
 * Instance Data
 */
typedef struct {
  Form form;
  int  displayForm;
  
  int  selInProgress;
  int  gadget;

  TGRmd_env env;

  TGRobj_env    axisOE;
  TGRobj_env   plateOE;
  TGRobj_env supportOE;
  TGRobj_env   startOE;
  TGRobj_env    stopOE;
  TGRobj_env   stiffOE;

  TGRobj_env axisOEs[VSBA_AXIS_MAX];
  IGRint     axisCNT;
  IGRint     axisCUR;
  
  
} TVSbaModInfo;

/* ---------------------------------------
 * Assorted toggles
 */
typedef struct 
{
  IGRint par;       // Paramertization
  IGRint side;      // Plate side
  IGRint ext;       // Old extend
  IGRint ext1,ext2; // Extend to start/stop
} TVSbaToggles;


/* ---------------------------------------
 * Prototypes
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VSbaCMD_ModGetToggles
  __((TVSbaModInfo *info,
      TVSbaToggles *tog));

extern IGRstat VSbaCMD_ModSetToggles
  __((TVSbaModInfo *info,
      TVSbaToggles *tog));

extern IGRstat VSbaCMD_ModExecuteExtend
  __((TVSbaModInfo *info,
      IGRchar       cmdKey,
      TGRid        *axisID));

extern IGRstat VSbaCMD_ModExecuteExt
  __((TVSbaModInfo *info,
      IGRchar       cmdKey,
      TGRid        *axisID));

extern IGRstat VSbaCMD_ModExecuteSide
  __((TVSbaModInfo *info,
      IGRchar       cmdKey,
      TGRid        *axisID));

extern IGRstat VSbaCMD_ModExecutePar
  __((TVSbaModInfo *info,
      IGRchar       cmdKey,
      TGRid        *axisID));

extern IGRstar VSbaCMD_ModExecuteParents
  __((TVSbaModInfo *info,
      IGRchar       cmdKey,
      TGRobj_env   *axisOE));

extern IGRstat VSbaCMD_ModExecute
  __((TVSbaModInfo *info));

extern IGRstat VSbaCMD_ModNotifyToggle
  __((TVSbaModInfo *info));

extern IGRstat VSbaCMD_ModModifyMacro
  __((TVSbaModInfo *info));

extern IGRstat VSbaCMD_ModNotifyToggle
  __((TVSbaModInfo *info));

extern IGRstat VSbaCMD_ModFillStiffAxis 
  __((TVSbaModInfo *info));

extern IGRstat VSbaCMD_ModHiLiteObject  
  __((TVSbaModInfo *info, 
      TGRobj_env *objOE));

extern IGRstat VSbaCMD_ModFillObject
  __((Form form, 
      IGRint gadget, 
      TGRobj_env *objOE));

extern IGRstat VSbaGetBeamAxis 
  __((TGRobj_env *stiffOE, 
      TGRobj_env *axisOE));

extern IGRstat VSbaCMD_ModNotify 
  __((TVSbaModInfo *info));

extern IGRstat VSbaCMD_ModPickedObject 
  __((TVSbaModInfo *info, 
      TGRobj_env *objOE));

extern IGRstat VSbaCMD_ModPickedStiffener 
  __((TVSbaModInfo *info, 
      TGRobj_env *stiffOE));

extern IGRstat VSbaCMD_ModPickedStiffenerFence
  __((TVSbaModInfo *info, 
      TGRobj_env *fenceOE));

extern IGRstat VSbaCMD_ModInit   __((TVSbaModInfo *info));
extern IGRstat VSbaCMD_ModSleep  __((TVSbaModInfo *info));
extern IGRstat VSbaCMD_ModWakeup __((TVSbaModInfo *info));
extern IGRstat VSbaCMD_ModDelete __((TVSbaModInfo *info));

extern IGRstat VDbaCMD_GetClassList __((OM_S_CLASSLIST *classList));

extern IGRstar VDahGetParent 
  __((TGRobj_env *objOE, 
      IGRint i, 
      TGRobj_env *parOE));

#if defined(__cplusplus)
}
#endif

/* -----------------------------------------------
 * Form Gadgets
 */
#define VSBA_FORM_MOD_B_BEAM_AXIS 18
#define VSBA_FORM_MOD_B_PLATE     12
#define VSBA_FORM_MOD_B_SUPPORT   13
#define VSBA_FORM_MOD_B_START     14
#define VSBA_FORM_MOD_B_STOP      15

#define VSBA_FORM_MOD_F_BEAM_AXIS 17
#define VSBA_FORM_MOD_F_PLATE     19
#define VSBA_FORM_MOD_F_SUPPORT   20
#define VSBA_FORM_MOD_F_START     21
#define VSBA_FORM_MOD_F_STOP      22
#define VSBA_FORM_MOD_F_STIFF     23

#define VSBA_FORM_MOD_T_SIDE   24
#define VSBA_FORM_MOD_T_EXT    25
#define VSBA_FORM_MOD_T_EXT1   26
#define VSBA_FORM_MOD_T_EXT2   27
#define VSBA_FORM_MOD_T_PAR    16

#define VSBA_FORM_MOD_G_CUR    28
#define VSBA_FORM_MOD_G_CNT    30
#define VSBA_FORM_MOD_G_CMD    33

#define VSBA_FORM_MOD_B_PREV   32
#define VSBA_FORM_MOD_B_NEXT   31

#define VSBA_FORM_MOD_B_HILITE 34

#endif

