/* $Id: VDsaProto.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDbt.h
 *
 * Description: Master building tree include
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaProto.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/04/07  14:39:54  pinnacle
 * ah
 *
 * Revision 1.2  1998/04/02  21:24:50  pinnacle
 * ah
 *
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      03/31/98  ah      Creation
 *
 ***************************************************************************/

#ifndef VDsaProto_include
#define VDsaProto_include

#ifndef   VDsa_include
#include "VDsa.h"
#endif

// Usual c++ stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// -----------------------------------------------------------
// Base Functions
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------
 * Transient Cache Interface
 */
extern IGRstar VDsaGetCacheMgr   __((TGRid *objID));
extern IGRstar VDsaGetCacheMisc  __((TGRid *objID));
extern IGRstar VDsaGetCacheTbls  __((TGRid *objID));
extern IGRstar VDsaGetCacheRecs  __((TGRid *objID));
extern IGRstar VDsaGetCacheCats  __((TGRid *objID));
extern IGRstar VDsaGetCacheFiles __((TGRid *objID));
extern IGRstar VDsaGetCacheSets  __((TGRid *objID));
extern IGRstat VDsaDeleteCache   __(());

extern IGRstar VDsaGetCache
__((IGRint trace,
    TGRid *mgrID,
    TGRid *miscID,
    TGRid *tblsID,
    TGRid *recsID,
    TGRid *catsID,
    TGRid *filesID,
    TGRid *setsID
));

#omdef vdsa$GetCache
(
 trace   = 0,
 mgrID   = NULL,
 miscID  = NULL,
 tblsID  = NULL,
 recsID  = NULL,
 catsID  = NULL,
 filesID = NULL,
 setsID  = NULL
)

VDsaGetCache((trace),(mgrID),(miscID),(tblsID),(recsID),
             (catsID),(filesID),(setsID))
#endomdef

#omdef vdsa$DeleteCache
(
)

VDsaDeleteCache()
#endomdef

/* --------------------------------------------
 * Gets dynamic table or family
 */
extern IGRstar VDsaGetDynTable
__((TGRobj_env *objOE,
    TGRid      *objID,
    IGRchar    *i_family,
    IGRchar    *o_tableName,
    IGRchar    *o_family
));

#omdef vdsa$GetDynTable
(
 objOE     = NULL,
 objID     = NULL,
 i_family  = NULL,
 family    = NULL,
 tableName = NULL
)

VDsaGetDynTable((objOE),(objID),(i_family),(tableName),(family))
#endomdef

// --------------------------------------------
extern IGRstar VDsaGetTableObj
__((IGRchar *tableName, 
    TGRid   *tableID
));

#omdef vdsa$GetTableObj
(
 tableName,
 tableID 
)

VDsaGetTableObj((tableName),(tableID))
#endomdef

// --------------------------------------------
extern IGRstar VDsaGetTableRec
__((TGRobj_env  *objOE,
    TGRid       *objID,
    IGRchar     *tableName,
    TGRid       *recID
));

#omdef vdsa$GetTableRec
(
 objOE     = NULL,
 objID     = NULL,
 tableName,
 recID
)

VDsaGetTableRec((objOE),(objID),(tableName),(recID))
#endomdef

// --------------------------------------------
extern IGRstar VDsaGetTableAttr
__((TGRobj_env  *objOE,
    TGRid       *objID,
    IGRchar     *tableName,
    IGRchar     *attrName,
    Tret_struct *attrData
));


#omdef vdsa$GetTableAttr
(
 objOE     = NULL,
 objID     = NULL,
 tableName,
 attrName,
 attrData
)

VDsaGetTableAttr((objOE),(objID),(tableName),(attrName),(attrData))
#endomdef

/* --------------------------------------------
 * Wrapper to PDM Info
 */
extern IGRstar VDsaGetPDM
__((TGRobj_env *objOE,
    TGRid      *objID,

    IGRchar    *fileName,
    IGRchar    *assembly_cat,
    IGRchar    *assembly_nam,
    IGRchar    *assembly_ver,
    IGRchar    *seqno,
    IGRchar    *all
));

#omdef vdsa$GetPDM
(
 objOE        = NULL,
 objID        = NULL,
 fileName     = NULL,
 assembly_cat = NULL,
 assembly_nam = NULL,
 assembly_ver = NULL,
 seqno        = NULL,
 all          = NULL
)

VDsaGetPDM((objOE),(objID),(fileName),(assembly_cat),(assembly_nam),(assembly_ver),(seqno),(all))
#endomdef

/* ---------------------------------------------
 * Individual give struct routines
 */
extern IGRstar VDsaGiveStructureAST
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructureSET
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructureTBL
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructureDYN
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructureEXP
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructurePPL
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructurePDM
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

extern IGRstar VDsaGiveStructureVDS
__((TGRobj_env  *obOE,
    IGRchar     *attrName,
    Tret_struct *attrData));

// ---------------------------------------------
#if defined(__cplusplus)
}
#endif

#endif











