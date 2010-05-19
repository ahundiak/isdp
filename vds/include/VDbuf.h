/* $Id: VDbuf.h,v 1.5 2001/08/14 19:06:56 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDbuf.h
 *
 * Description: XML Buffer Macro Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDbuf.h,v $
 *      Revision 1.5  2001/08/14 19:06:56  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/28 17:30:33  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/07/23 16:01:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/22 15:00:37  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/14 18:47:19  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/14/01  ah      Created
 * 07/16/01  ah      More functions
 ***************************************************************************/

#ifndef VDvalBuf_include
#define VDvalBuf_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDbufGetInternalData __((TGRobj_env *bufOE, IGRchar **data));
extern IGRstat VDbufSetTxtData      __((TGRobj_env *bufOE, IGRchar  *data));

extern IGRstat VDbufSetCompressedTxtData __((TGRobj_env *bufOE, IGRchar  *data));
extern IGRstat VDbufGetCompressedTxtData __((TGRobj_env *bufOE, IGRchar **data));

extern void VDbufGetDomTree __((TGRobj_env *bufOE, TGRid *treeID));
extern void VDbufSetDomTree __((TGRobj_env *bufOE, TGRid *treeID));
  
  
extern IGRstat VDbufPlaceMacro __((IGRchar    *libName,
				   IGRchar    *macName,
				   IGRchar    *name,
				   IGRchar    *data,
				   TGRid      *treeID,
				   TGRobj_env *macOE));

extern IGRstat VDbufPlaceMacro2 __((IGRchar    *libName,
				    IGRchar    *macName,
				    IGRchar    *name,
				    IGRchar    *data,
				    TGRid      *treeID,
				    IGRint      tplCnt,
				    TGRobj_env *tplOEs,
				    TGRobj_env *macOE));

extern IGRstat VDbufCreateDrawingGeometry __((VDosnum osnum,  IGRint size, TGRid *drwGmID));
extern IGRstat VDbufCreateCollector       __((VDosnum osnum,  TGRid *colID));
extern IGRstat VDbufAddGeometryChild      __((TGRid *drwGmID, TGRid *childID));

extern IGRstat VDbufCreateGraphicGroup __((TGRmd_env *env, TGRid *groupID));
  
extern void GRgrpSetDoNotFlatten __((IGRint  flag));
extern void GRgrpGetDoNotFlatten __((IGRint *flag));
  
  
/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif

#endif
