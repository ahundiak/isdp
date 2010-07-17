/* $Id: VSbevMod.h,v 1.2 2001/02/05 17:12:11 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	include/VSbevMod.h
 *
 * Description: Modify Bevel Attribute
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbevMod.h,v $
 *	Revision 1.2  2001/02/05 17:12:11  jayadev
 *	VSbev_ReadSetupFileOLD() for old bevel command
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.4  1999/12/08  20:44:42  pinnacle
 * tr179900739
 *
 * Revision 1.3  1999/05/31  17:42:02  pinnacle
 * CR_179900195
 *
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 03/31/99  ejm       CR179900195 Creation for Modify Bevel Attribute
 * 05/06/99  ejm       CR179900195 Modify VSbev_CreateColl prototype
 * 05/26/99  ejm       CR179900195 Added VSbev_Fence_FillMCF, dTHK array
 * 07/04/99  Jay/Vin   VSbev_ReadSetupFile() args changed for 
 *                     Modify Bevel Attributes command 
 * 02/05/01  Jayadev   VSbev_ReadSetupFile() -> VSbev_ReadSetupFileOLD()
 *		       for old bevel command 
 ***************************************************************************/

#ifndef VSbevMod_include
#define VSbevMod_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


/* -----------------------------------------------
 * Buffer Lengths
 */
#define MAX_EDGES		100  /* Max edges expected in a fence 	     */
#define MAX_FLD_LEN		128  /* Extra chars for any future extension */
#define MAX_PICKLIST_ENTRIES	20   /* Max values for individual attribute  */
				     /*   in edge_setup file                 */

/* ---------------------------------------
 * Instance Data
 */
typedef struct {
  Form form;
  int  displayForm;
  
  int     gadget;
  int     col;
  int     row;
  double  dTHK[MAX_EDGES]; /* Not saved on form, so save in array */

  TGRid      plateID;
  TGRobj_env edgeOE;
  
} TVSbevModInfo;


/* ---------------------------------------
 * Prototypes
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong VSbev_FillMCF
  __((TVSbevModInfo *info));

extern IGRlong VSbev_Fence_FillMCF
  __((TVSbevModInfo *info));

extern IGRlong VSbev_ReadSetupFileOLD
  __((Form form, 
      IGRint gadget));

extern IGRlong VSbev_PickedMCF
  __((TVSbevModInfo *info));

extern IGRlong VSbev_PickedList
  __((TVSbevModInfo *info));

extern IGRlong VSbev_PickedUpdButton
  __((TVSbevModInfo *info));

extern IGRlong VSbev_Attrs
  __((IGRint         objId,
      IGRchar       *name,
      IGRint         type,
      IGRchar       *value,
      TVSbevModInfo *info));

extern IGRlong VSbev_ModAttrs
  __((TVSbevModInfo *info));

extern IGRlong VSbev_ResetForm
  __((TVSbevModInfo *info));

extern IGRlong VSbev_GetAttrs
  __((TGRid          objID,
      IGRint        *attCnt,
      TACrg_coll   **attList));

extern IGRlong VSbev_PutAttrs
  __((TGRid         *attrID,
      IGRint         cnt,
      TACrg_coll    *attrs));

extern IGRlong VSbev_CreateColl
  __((TVSbevModInfo *info,
      TGRid	    *oldID,
      TGRid         *collID));


extern IGRlong VSbevCMD_ModInit   __((TVSbevModInfo *info));
extern IGRlong VSbevCMD_ModSleep  __((TVSbevModInfo *info));
extern IGRlong VSbevCMD_ModWakeup __((TVSbevModInfo *info));
extern IGRlong VSbevCMD_ModDelete __((TVSbevModInfo *info));

#if defined(__cplusplus)
}
#endif

/* -----------------------------------------------
 * Form Gadgets
 */

#define VSBEV_FORM_MCF     	12
#define VSBEV_FORM_FLD_LIST	14
#define VSBEV_FORM_FLD_BTN	21

#endif

