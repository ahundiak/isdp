/* $Id: VDdoom.h,v 1.7 2001/11/16 14:25:43 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDdoom.h
 *
 * Description: DOM-OM Objects
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdoom.h,v $
 *      Revision 1.7  2001/11/16 14:25:43  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/09/04 13:31:47  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/16 18:58:25  jdsauby
 *      Modified for File Ops and Database Ops on Rev Snapshot form
 *
 *      Revision 1.4  2001/03/13 00:15:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Created
 * 09/04/01  ah      Remove the VDctx include to preclude include order problems
 ***************************************************************************/

#ifndef VDdoom_include
#define VDdoom_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDdoomGetDoomPathOS __((VDosnum getOS, IGRchar *path));
extern IGRstat VDdoomGetNextNameOS __((VDosnum osnum, IGRchar *name));
extern IGRstat VDdoomListObjectsOS __((VDosnum osnum));

extern IGRstat VDdoomGetDoomObjectByNameOS __((VDosnum osnum, IGRchar *name, TGRid *doomID));
extern IGRstat VDdoomCreateDoomObjectOS    __((VDosnum osnum, IGRchar *name, TGRid *doomID));
extern IGRstat VDdoomGetNthObjectOS        __((VDosnum osnum, IGRint   nth,  TGRid *doomID));
extern void    VDdoomGetCntOS              __((VDosnum osnum, IGRint  *cnt));

extern IGRstat VDdoomSetData __((TGRid *doomID, IGRint  dataLen, IGRchar  *data));
extern IGRstat VDdoomGetData __((TGRid *doomID, IGRint *dataLen, IGRchar **data));

extern IGRstat VDdoomLoadFile __((IGRint mode, TGRid *doomID, IGRchar *fileName));
extern IGRstat VDdoomSaveFile __((IGRint mode, TGRid *doomID, IGRchar *fileName));

extern IGRstat VDdoomTest1 __(());

#define VDdoomGetDoomPath(path) \
        VDdoomGetDoomPathOS(OM_K_NOT_AN_OS,(path))

#define VDdoomGetNextName(name) \
        VDdoomGetNextNameOS(OM_K_NOT_AN_OS,(name))

#define VDdoomListObjects() \
        VDdoomListObjectsOS(OM_K_NOT_AN_OS)

#define VDdoomGetDoomObjectByName(name,doomID) \
	VDdoomGetDoomObjectByNameOS(OM_K_NOT_AN_OS,(name),(doomID))

#define VDdoomCreateDoomObject(name,doomID) \
	VDdoomCreateDoomObjectOS(OM_K_NOT_AN_OS,(name),(doomID))

#define VDdoomGetNthObject(nth,doomID) \
	VDdoomGetNthObjectOS(OM_K_NOT_AN_OS,(nth),(doomID))

#define VDdoomGetCnt(cnt) \
	VDdoomGetCntOS(OM_K_NOT_AN_OS,(cnt))

void VDdoomCreateFromTree __((TGRid *treeID, TGRid *doomID));
void VDdoomCreateTree     __((TGRid *doomID, IGRint rootOnly, TGRid *treeID));
  
typedef struct 
{
  TGRid doomID;
  TGRid rootID;
  TGRid treeID;
  
  TVDctxBaseInfo baseInfo;
  IGRchar        ts[32];
  
} TVDdoomInfo;

extern void VDdoomInitDoomInfo __((TVDdoomInfo *info));
extern void VDdoomFreeDoomInfo __((TVDdoomInfo *info));
extern void VDdoomFillDoomInfo __((TGRid *doomID, IGRint treeFlag, TVDdoomInfo *info));

extern IGRint VDdoomCompareDoomInfo __((const void *v1, const void *v2));
  
extern IGRstat VDdoomGetNthTS __((IGRchar     *i_treeType,
				  IGRchar     *i_treeName,
				  IGRint       i_nth,
				  TGRid       *o_doomID,
				  TGRid       *o_rootID,
				  TGRid       *o_treeID));
  

/* -------------------------------------------------
 * Parses an xml file to get the root node
 * **/
extern IGRstat VDdoomXmlParseFileForRoot __((IGRchar *filename,
                                             TGRid   *rootID));

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif



