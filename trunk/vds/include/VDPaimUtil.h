/***************************************************************************
 * I/AIM
 *
 * File:        include/VDPaimUtil.h
 *
 * Description: Various AIM Utility Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimUtil.h,v $
 *      Revision 1.1.2.6  2004/02/27 15:02:33  ahundiak
 *      ah
 *
 *      Revision 1.1.2.5  2003/06/11 13:21:06  ahundiak
 *      ah
 *
 *      Revision 1.1.2.4  2003/06/05 16:47:12  ahundiak
 *      ah
 *
 *      Revision 1.1.2.3  2003/06/04 18:15:10  ahundiak
 *      ah
 *
 *      Revision 1.1.2.2  2003/05/27 13:34:43  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/05/16 14:28:50  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/17/03  ah      Creation
 ***************************************************************************/
#ifndef VDPaimUtil_H
#define VDPaimUtil_H

#ifndef VDDOM2_H
#include "VDdom2.h"
#endif

#ifndef   VDpdmDef_include
#include "VDpdmDef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------
 * Some data structures
 */
typedef struct
{
  char user  [50];
  char server[25];
  char env   [15];
} TVDPaimServerInfo;

/* ----------------------------------------------
 * sir/VDPaimUtil.c
 */
extern int 
VDPaimGetServerInfo __((char *user, char *server, char *env));

extern void
VDPaimGetFileTypeDesc __((int fileType, char *desc));

extern int EnablePME(int flag );

extern int IsPmeEnabled();

extern int ConnectAIM(int flag); // Sarts as 3, set to 1 by AIMlogin

extern int WhichAim();

extern IGRstat VDPaimLogin();
extern IGRstat AIMlogin();

/* ----------------------------------------------
 * VDPutil.I
 *
/* ----------------------------------------------
 * sir/VDPaimDadUt.I
 */
extern int 
PDMReadHullApp __((char *catalog, char *partid, char *revision, 
                   char *lpdvalue1[12]));

extern int 
PDMInsertSirTable __((char *Refcat, char *Refpart, char *Refrev));

extern int VDPReconnectDAD __(());

extern void VDPaimChangeMtoDM __(());

extern int VDPaimGetHullApp __((
  char *cat, char *part, char *rev, char *app));

/* ----------------------------------------------
 * Posting routines
 * sir2/VDPaimPost.c
 */
extern IGRstat VDPaimGetNextSirid __((VDosnum osnum, int type, char *sirid));
extern IGRstat VDPaimPostObjects  __((domNode fileInfoNode,
                                      domNode placementsNode,
                                      domNode postObjectsNode));

extern void VDPaimComputeLocation  __((domNode objNode));
extern void VDPaimComputeSirTagNum __((domNode objNode));

extern domNode VDPaimGetPostObjectsData __((VDosnum osnum,
                                            domNode fileInfoNode,
                                            domNode parentNode));

extern IGRstat VDPaimCmdPostObjects 
  __((FILE *logFile, domNode fileInfoNode, int *numPosted, int *numErrors));

extern IGRstat VDPaimUpdatePostTimestamp 
  __((domNode fileInfoNode, int numErrors, int postXmlFile));

extern IGRstat VDPaimCreateDoomFromTree __((domNode treeNode, TGRid *doomID));

/* ----------------------------------------------
 * Master data collection
 * sir2/VDPaimFileInfo.c
 */
extern domNode VDPaimGetFileInfo __((VDosnum osnum));

extern domNode VDPaimCreateAimInfoNode       __((VDosnum osnum, domNode parentNode));
extern domNode VDPaimCreateAimPlacementsNode __((VDosnum osnum, domNode parentNode));

extern domNode VDPaimCreateOccTemplateNode  __((domNode parentNode, char *templateName));
extern domNode VDPaimCreateOccTemplateNodes __((domNode parentNode));

extern domNode VDPaimFIInitFileInfoNode __((VDosnum osnum));
extern void    VDPaimFIFreeFileInfoNode __(());
extern domNode VDPaimFIGetFileInfoNode  __(());

extern domNode VDPaimFIGetCatInfoNode     __((domNode fileInfoNode));
extern domNode VDPaimFIGetPdmInfoNode     __((domNode fileInfoNode));
extern domNode VDPaimFIGetDADInfoNode     __((domNode fileInfoNode));
extern domNode VDPaimFIGetSirPdmInfoNode  __((domNode fileInfoNode));
extern domNode VDPaimFIGetOccTemplateNode __((domNode fileInfoNode, IGRchar *asirClassName));

extern domNode VDPaimFIGetAsirPlacementsNode       __((domNode fileInfoNode));
extern domNode VDPaimFIGetAsirPlacementsBeforeNode __((domNode fileInfoNode));
extern domNode VDPaimFIGetAsirPlacementsAfterNode  __((domNode fileInfoNode));

extern domNode VDPaimFIGetPostObjectsFSINode __((domNode fileInfoNode));

extern int     VDPaimFIGetDiagCtl        __((domNode fileInfoNode));
extern int     VDPaimFIGetFileType       __((domNode fileInfoNode));
extern char   *VDPaimFIGetFileTypeDesc   __((domNode fileInfoNode, char *fileTypeDesc));
extern char   *VDPaimFIGetHullApp        __((domNode fileInfoNode, char *hullApp));
extern char   *VDPaimFIGetModelContextID __((domNode fileInfoNode, char *modelContextID));

extern void    VDPaimFIGetPdmInfo       __((domNode fileInfoNode, TVDpdmInfo *pdmInfo));

/* ----------------------------------------------
 * sir2/VDPaimOccTpl.c
 */
extern domNode VDPaimGetOccTemplateNode __((char *name));

/* ----------------------------------------------
 * sir2/VDPaimComp.c
 */
extern IGRstat VDPaimValidateComptNumber     __((domNode objNode));

extern IGRstat VDPaimGetComptNumberForObject __((TGRid *objID, IGRchar *compt_number));

/* ----------------------------------------------
 * Some delete and cleanup routines
 */
extern void VDPaimDeleteItemCache      __(());
extern void VDPaimDeleteFSIExpressions __(());

/* ----------------------------------------------
 * Interface to assorted aim collectors
 * sir2/VDPaimColl.I
 */
extern void VDPaimGetIGENODDirectory       __((VDosnum osnum, char *path));
extern void VDPaimGetSirGlobalDirectory    __((VDosnum osnum, char *path));
extern void VDPaimGetDADCollector          __((VDosnum osnum, int create, TGRid *collID));
extern void VDPaimGetDrawingCollector      __((VDosnum osnum,             TGRid *collID));

extern void 
VDPaimGetEnabledItemListObject __((VDosnum osnum, int create, TGRid *enabledID));

extern void 
VDPaimGetTransactionListObject __((VDosnum osnum, int create, TGRid *transID));

extern void 
VDPaimGetSavedTransactionListObject __((VDosnum osnum, int create, TGRid *transID));

extern domNode 
VDPaimCreateEnabledItemNodeList __((VDosnum osnum, domNode parentNode));

extern domNode
VDPaimCreateTransactionNodeList __((VDosnum osnum, domNode parentNode));

/* ----------------------------------------------
 * Low level collector stuff
 * sir2/VDcoll.I
 */
extern IGRstat VDcollGetTextAttr __((TGRid *collID, IGRchar *name, IGRchar *value));
extern IGRstat VDcollSetTextAttr __((TGRid *collID, IGRchar *name, IGRchar *value));

extern IGRstat VDcollGetIntAttr  __((TGRid *collID, IGRchar *name, IGRint  *value));
extern IGRstat VDcollSetIntAttr  __((TGRid *collID, IGRchar *name, IGRint   value));

extern IGRstat VDcollGetDblAttr  __((TGRid *collID, IGRchar *name, IGRdouble *value));

extern IGRstat VDcollCreate __((VDosnum osnum, IGRchar *path, TGRid *collID));

extern IGRstat 
VDobjSetUserTextAttr __((TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRchar *value));

extern IGRstat 
VDobjGetDbInfoType __((TGRobj_env *a_objOE, TGRid *a_objID, IGRint *dbType));

extern IGRstat VDctxGetCompTagx __((TGRid *objID, IGRchar *buf));
extern IGRstat VDctxGetCompPath __((TGRid *objID, IGRchar *buf));

extern IGRstat VDPaimRunValidatePPL __((TGRid *objID, IGRchar *funcName, IGRchar *txt));

/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif
#endif

