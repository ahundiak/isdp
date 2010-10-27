/* $Id: VDobj2.h,v 1.13 2002/05/01 19:54:00 ahundiak Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDobj2.h
 *
 * Description: Low Level Object Routines
 *
 *
 * Dependencies: VDtypedef.h or VDtypedefc.h
 *
 * Revision History:
 *    $Log: VDobj2.h,v $
 *    Revision 1.13  2002/05/01 19:54:00  ahundiak
 *    ah
 *
 *    Revision 1.12  2002/04/18 16:31:49  ahundiak
 *    ah
 *
 *    Revision 1.11  2002/03/08 17:00:14  ahundiak
 *    ah
 *
 *    Revision 1.10  2002/01/03 14:57:10  ahundiak
 *    ah
 *
 *    Revision 1.9  2001/11/09 14:17:55  ahundiak
 *    ah
 *
 *    Revision 1.8  2001/08/24 19:58:34  ahundiak
 *    ah
 *
 *    Revision 1.7  2001/08/02 15:34:09  ahundiak
 *    ah
 *
 *    Revision 1.6  2001/06/03 14:40:53  ahundiak
 *    ah
 *
 *    Revision 1.5  2001/05/02 14:51:47  ahundiak
 *    ah
 *
 *    Revision 1.4  2001/04/03 17:10:35  ahundiak
 *    ah
 *
 *    Revision 1.3  2001/02/22 23:00:44  ahundiak
 *    ah
 *
 *    Revision 1.2  2001/01/14 16:11:38  art
 *    sp merge
 *
 *    Revision 1.1  2001/01/10 15:55:49  art
 *    sp merge
 *
 * Revision 1.3  2000/12/08  15:32:34  pinnacle
 * ah
 *
 * Revision 1.2  2000/12/07  17:33:08  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  13:52:48  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION 
 * 11/28/00  ah      Created
 * 01/12/01  ah      sp17 merge, added some more gets
 * 04/02/01  ah      More gets
 * -------------------------------------------------------------------*/
#ifndef VDobj2_include
#define VDobj2_include

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

extern IGRstat VDobjGetRep       __((TGRobj_env *objOE, TGRid *objID, IGRuchar *rep));
extern IGRstat VDobjGetName      __((TGRobj_env *objOE, TGRid *objID, IGRchar  *name));
extern IGRstat VDobjGetPath      __((TGRobj_env *objOE, TGRid *objID, IGRchar  *path));
extern IGRstat VDobjGetClassName __((TGRobj_env *objOE, TGRid *objID, IGRchar  *className));
extern IGRstat VDobjGetMacroName __((TGRobj_env *objOE, TGRid *objID, IGRchar  *macroName));
extern IGRstat VDobjGetSymbology __((TGRobj_env *objOE, TGRid *objID, TGRsymbology *symb));

#define VDobjGetMacName(objOE,objID,macName) VDobjGetMacroName(objOE,objID,macName)

// Utility routines
extern IGRstat VDobjGetID __((TGRobj_env *objOE, TGRid *objID, TGRid      *theID));
extern IGRstat VDobjGetOE __((TGRobj_env *objOE, TGRid *objID, TGRobj_env *theOE));

/* ---------------------------------------------
 * Need an easy way to get a single attribute from an object
 * Obsolete, use VDctx stuff
 *
 * Maybe, maybe not.  The VDctx stuff does work now but when you know
 * you have a om object then calling these directly saves the overhead
 * of discovering what type of object you have
 *
 * Keep using them for now.
 */
extern IGRstat VDobjGetTxtAtr __((TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRchar   *value));
extern IGRstat VDobjGetDblAtr __((TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRdouble *value));

extern void VDcnvDblToTxt __((IGRdouble val, IGRchar *buf));

#define VDoeGetTxtAtr(objOE,name,value) VDobjGetTxtAtr(objOE,NULL,name,value)
#define VDoeGetDblAtr(objOE,name,value) VDobjGetDblAtr(objOE,NULL,name,value)
#define VDidGetTxtAtr(objID,name,value) VDobjGetTxtAtr(NULL,objID,name,value)
#define VDidGetDblAtr(objID,name,value) VDobjGetDblAtr(NULL,objID,name,value)

/* ----------------------------------------------------
 * Validate ancestor with either class id or class name
 */
extern IGRstat VDobjIsAncestryValid __((TGRobj_env *objOE, 
					TGRid      *objID,
					VDclassid   classID,
					IGRchar    *className));

extern IGRstat VDobjGetFoot __((TGRobj_env *objOE, 
				TGRid      *objID,
				IGRchar    *footName,
				TGRobj_env *footOE));

extern IGRstat VDobjIsConsumed  __((TGRobj_env *objOE,TGRid *objID));

/* ------------------------------------------------------------------------
 * Specialized routine for retrieving parents through sources
 * Avoid using this, it was really for a special case
 */
extern IGRstat VDobjGetParent __((TGRobj_env *objOE,
				  TGRid      *objID,
				  IGRint      nth,
				  TGRid      *parentID,
				  TGRid      *sourceID,
				  TGRid      *pretendID));

// Note objID is not yet implemented
extern IGRstat VDobjGetTemplate __((TGRobj_env *objOE,
				    TGRid      *objID,
				    IGRint      nth,
				    TGRobj_env *templateOE));

extern IGRstat VDmacGet __((TGRobj_env *macOE,
			    TGRid      *macID,
			    IGRchar    *footName,
			    IGRchar    *defName,
			    TGRid      *defID,
			    TGRid      *footID));

#define VDmacGetFoot(macID,footName,footID) \
        VDmacGet(NULL,macID,footName,NULL,NULL,footID)


/* ----------------------------------------------------
 * Print an object for debugging
 */
extern IGRstat VDobjPrint2 __((TGRobj_env *objOE,TGRid *objID));

/* ---------------------------------------------------
 * An easy way to set the matrix and stuff for an object
 */
extern void VDobjResetOE __((TGRobj_env *objOE));

extern IGRstat VDobjGetObjectByPath __((IGRchar *path, TGRobj_env *objOE));

extern IGRstat VDobjGetConsumingChild __((TGRobj_env *parentOE, TGRobj_env *childOE));


/* ---------------------------------------------------
 * Testing for final objects
 * VDobj3.I
 */
extern IGRstat VDobjIsFinal      __((TGRobj_env *objOE, TGRid *objID, IGRint verbose));
extern IGRstat VDobjIsFinalEqp   __((TGRobj_env *objOE, TGRid *objID, IGRint verbose));
extern IGRstat VDobjIsFinalBeam  __((TGRobj_env *objOE, TGRid *objID, IGRint verbose));
extern IGRstat VDobjIsFinalPlate __((TGRobj_env *objOE, TGRid *objID, IGRint verbose));

extern IGRstat VDobjIsFinalMacro __((IGRchar	*macName,
				     TGRobj_env	*objOE, 
				     TGRid	*objID, 
				     IGRint	 verbose));


extern IGRstat VDobjGetEqps   __((VDosnum osnum, IGRint *eqpCnt, TGRid **listIDs));
extern IGRstat VDobjGetPieces __((VDosnum osnum, IGRint *plateCnt, IGRint *beamCnt, TGRid **listIDs));

extern IGRstat VDobjIsFinalRouteComponent __((TGRobj_env *objOE, TGRid *objID, IGRint verbose));
extern IGRstat VDobjGetRouteComponents    __((VDosnum osnum, IGRint *objCnt, TGRid **listIDs));

extern IGRstat VDobjGetEqpRouteComponents __((VDosnum osnum, IGRint *a_objCnt, TGRid **a_listIDs));

extern IGRstat VDobjGetNamedMacros        __((VDosnum osnum, IGRchar *macName, 
					      IGRint *macCnt, TGRid **a_listIDs));

extern IGRstat VDobjGetBevels __((VDosnum osnum, 
				  IGRint *bevelCnt, 
				  IGRint *ej_bevelCnt,
				  IGRint *fab_stockCnt,
				  IGRint *va_bevelCnt,
				  TGRid	**a_listIDs));

extern IGRstat VDobjGetPenPcg __((VDosnum osnum, 
 				  IGRint *penCnt, 
				  IGRint *pcgCnt,
				  TGRid **a_listIDs));

/* -----------------------------------------------
 * Sneak in reference functions here VDref.I
 */
extern void VDrefGetOSs __((IGRint *cnt, VDosnum **osnums));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif

