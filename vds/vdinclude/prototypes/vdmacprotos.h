/* $Id: vdmacprotos.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdinclude/prototypes/vdmacprotos.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmacprotos.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/10/29  16:49:10  pinnacle
 * Place Equipment API
 *
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/96	i-paris		creation date
 *
 ***************************************************************************/


#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* Collector.I */
IGRlong VDcstCollRow __((IGRlong *msg, struct VDcollector *Col));
IGRlong VDcstCollector __((IGRlong *msg, IGRint cnt, struct VDcollector **Col));
IGRlong VDgetCollRow __((IGRlong *msg, struct VDcollector *Col, IGRchar *Nam, struct GRid *Obj, struct GRmd_env *Env, IGRdouble *Val, IGRchar *Txt, struct OM_sd_classlist **Cla, IGRboolean public));
IGRlong VDgetCollector __((IGRlong *msg, IGRint idx, struct VDcollector *Col, IGRchar *Nam, struct GRid *Obj, struct GRmd_env *Env, IGRdouble *Val, IGRchar *Txt, struct OM_sd_classlist **Cla, IGRboolean public));
void VDgetClassID __((IGRchar *nam, struct VDcollector *Col));
IGRlong VDtypeToClass __((IGRlong *msg, struct VDcollector *Col));
IGRlong VDsetCollRow __((IGRlong *msg, struct VDcollector *Col, IGRchar *Nam, struct GRid *Obj, struct GRmd_env *Env, IGRdouble *Val, IGRchar *Txt, IGRint *Typ, IGRboolean public));
IGRlong VDsetCollector __((IGRlong *msg, IGRint idx, struct VDcollector *Col, IGRchar *Nam, struct GRid *Obj, struct GRmd_env *Env, IGRdouble *Val, IGRchar *Txt, IGRint *Typ, IGRboolean public));
void VDoutCollRow __((IGRint idx, struct VDcollector *Col, IGRboolean public));
IGRlong VDoutCollector __((IGRint cnt, struct VDcollector *Col, IGRchar *msg, IGRboolean public));
IGRlong VDenvCollector __((IGRint idx, struct VDcollector *Col, struct GRmd_env *Env));
IGRlong VDmakCollRow __((IGRlong *msg, struct VDcollector *Col));
IGRlong VDmakCollector __((IGRlong *msg, IGRint cnt, struct VDcollector *Col));
IGRlong VDexpCollRow __((IGRlong *msg, struct VDcollector *Col, IGRushort prop));
IGRlong VDexpCollector __((IGRlong *msg, IGRint cnt, struct VDcollector *Col));
IGRlong VDchkCollRow __((IGRlong *msg, struct VDcollector *Col));
IGRlong VDchkCollector __((IGRlong *msg, IGRint cnt, struct VDcollector *Col));

/* EquipDef.I */
IGRlong VDisConnected __((IGRlong *msg));
IGRlong VDconstructStaticBox __((IGRlong *msg, struct VDdescriptor *Desc, IGRint num, struct ACrg_coll att[], struct ACrg_coll mac));
IGRlong VDgetEquipDescription __((IGRlong *msg, IGRchar *CatName, IGRchar *PartNum, IGRchar *RevName, GRspacenum ActiveOS, enum ACm_poss_hdr HdrTyp, struct VDdescriptor *Desc));
IGRlong VDgetCollectorFromEquipDef __((IGRlong *msg, IGRchar *CatName, IGRchar *PartNum, IGRchar *RevName, IGRint *TplNum, struct VDcollector **TplCol, IGRint *DynNum, struct VDcollector **DynCol));
IGRlong VDgetCollectorFromEquipOcc __((IGRlong *msg, struct VDcollector *OccCol, IGRint *TplNum, struct VDcollector **TplCol, IGRint *DynNum, struct VDcollector **DynCol));

/* EquipMod.I */
IGRlong VDmodifyEquip __((IGRlong *msg, struct VDcollector *OccCol, IGRint TplNum, struct VDcollector TplCol[], IGRint DynNum, struct VDcollector DynCol[], IGRint immediate));

/* EquipPla.I */
IGRlong VDconstructDynamicBox __((IGRlong *msg, IGRint DynNum, struct VDcollector DynCol[], struct GRmd_env *Env, struct GRid *dBox));
IGRlong VDplaceEquip __((IGRlong *msg, IGRint TplNum, struct VDcollector TplCol[], IGRint DynNum, struct VDcollector *DynCol, struct VDdescriptor *Desc, IGRint rep, IGRchar *DirPath, IGRchar *RootName, IGRint prop, struct GRobj_env *OccId));

/* MacroDef.I */
IGRlong VDgetMacroDefinition __((IGRlong *msg, IGRchar *MacLib, IGRchar MacDef[], GRspacenum ActiveOS, struct VDdescriptor *Desc));
IGRlong VDgetMacroDescription __((IGRlong *msg, IGRchar *MacLib, IGRchar MacDef[], GRspacenum ActiveOS, enum ACm_poss_hdr Htyp, struct VDdescriptor *Desc));
IGRlong VDgetTemplDescription __((IGRlong *msg, IGRchar *MacLib, IGRchar MacDef[], GRspacenum ActiveOS, IGRint *num, struct stemp **stp));
IGRlong VDgetCollectorFromMacroDef __((IGRlong *msg, IGRchar *MacLib, IGRchar *MacDef, IGRint *TplNum, struct VDcollector **TplCol));
IGRlong VDgetCollectorFromMacroOcc __((IGRlong *msg, struct VDcollector *OccCol, IGRint *TplNum, struct VDcollector **TplCol));

/* MacroMod.I */
IGRlong VDmodifyMacro __((IGRlong *msg, struct VDcollector *OccCol, IGRint TplNum, struct VDcollector TplCol[], IGRint immediate));

/* MacroPla.I */
IGRlong VDfillMacroTemplates __((IGRlong *msg, IGRint TplNum, struct VDcollector TplCol[], struct GRid **TplObj));
IGRlong VDplaceMacroOccurence __((IGRlong *msg, IGRint TplNum, struct GRid TplObj[], struct GRmd_env *Env, struct VDdescriptor *Desc, struct GRsymbology *symb, IGRchar *DirPath, IGRchar *RootName, IGRint prop, struct GRid *OccId));
IGRlong VDplaceMacro __((IGRlong *msg, IGRint TplNum, struct VDcollector TplCol[], struct VDdescriptor *Desc, IGRchar *DirPath, IGRchar *RootName, IGRint prop, struct GRobj_env *OccId));

/* PlaceGen.I */
IGRlong VDbuildCSvectors __((IGRlong *msg, IGRdouble *X, IGRdouble *Y, IGRint Wname, IGRdouble *x, IGRdouble *y, IGRdouble *z));
IGRlong VDcreateCS __((IGRlong *msg, IGRdouble *Cpnt, IGRdouble *Xvec, IGRdouble *Yvec, IGRint Wname, IGRdouble *matrix, IGRchar *name, struct GRobj_env *CS));
IGRlong VDincrementalName __((IGRlong *msg, struct GRid *obj, IGRchar *dir, IGRchar *rot));
IGRlong VDplaceMacroOrEquip __((IGRlong *msg, IGRchar *MacLib, IGRchar *MacDef, IGRchar *CatName, IGRchar *PartNum, IGRchar *RevName, IGRint TplNum, struct VDcollector TplCol[], IGRint DynNum, struct VDcollector *DynCol, enum ACm_poss_hdr Htyp, IGRint rep, IGRint lay, IGRint col, IGRint wgt, IGRint stl, IGRint One, IGRint All, IGRchar *DirPath, IGRchar *RootName, IGRint prop, struct GRid *OccId));

#if defined(__cplusplus)
}
#endif

