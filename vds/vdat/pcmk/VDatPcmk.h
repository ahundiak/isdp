/* $Id: VDatPcmk.h,v 1.1 2002/04/18 16:31:28 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatPcmk.h
 *
 * Description:	Piece mark specific stuff
 *              
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPcmk.h,v $
 *      Revision 1.1  2002/04/18 16:31:28  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/09 22:03:39  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/11/27  16:29:20  pinnacle
 * ah
 *
 * Revision 1.2  2000/06/27  17:35:30  pinnacle
 * ah
 *
 * Revision 1.1  2000/05/15  14:38:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/03/31  17:10:42  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 * 01/09/01  ah      sp merge
 ***************************************************************************/
#ifndef VDatPcmk_include
#define VDatPcmk_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDatClass_include
#include "VDatClass.h"
#endif

#ifndef   VDat_include
#include "VDat.h"
#endif

#ifndef   VDgeom_include
#include "VDgeom.h"
#endif

#ifndef   VDefp_include
#include "VDefp.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------
 * Piece Mark Data Structures
 */
typedef struct 
{
  IGRchar   family  [40];
  IGRchar   part_num[40];
  IGRchar   material[40];
  IGRchar   grade   [40];
    
  union 
  {    
    struct {  
      IGRdouble area;
      IGRdouble thickness;
      IGRint    isPlanar;
    } plate;

    struct 
    {
      IGRchar   et0[40],et1[40]; // End Treatment
      IGRchar   ei0[40],ei1[40]; // End Treatment Info
      
      IGRdouble length;
      IGRdouble height;

    } beam;
  } type;
  
  
} TVDatPcmkAttrInfo;
  
typedef struct
{
  TGRid      leafID;

  TGRobj_env pieceOE;
  IGRchar   *pieceName;     // Piece Name (Points to piecePath)  
  IGRchar    piecePath[80]; // Piece Path (past :usr: 
  IGRint     pieceType;     // 1 = plate, 2 = beam
  
  IGRint     pcmk1;
  IGRint     pcmk2;

  IGRint     notLike;

  TGRobj_env unwrapOE;      // If one exists
  
} TVDatPcmkLeafInfo;


typedef struct
{
  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;
  TVDefpTranInfo    *tran;
} TVDatPcmkInfo;

typedef struct
{
  IGRint             max;
  IGRint             cnt;
  TVDatPcmkInfo     *infos;
  TVDatPcmkLeafInfo *leafs;
  TVDatPcmkAttrInfo *attrs;
} TVDatPcmkInfos;

#define VDAT_PCMK_INFO_PIECE_TYPE_PLATE 1
#define VDAT_PCMK_INFO_PIECE_TYPE_BEAM  2

#define VDAT_ATTR_PCMK "pcmk"

#define VDAT_PCMK_STD_MIN 9000
#define VDAT_PCMK_STD_UNK 9999

#define VDAT_PCMK_MAX_LIKE_PLATE_AREA  300000
#define VDAT_PCMK_MAX_LIKE_BEAM_HEIGHT    250

#define VDAT_LIKE_PART_TOL  1.0
#define VDAT_PLATE_AREA_TOL 4.0

/* ----------------------------------------------------
 * vdat/pcmk/VDatStd.I
 */
extern IGRstat VDatGetStandardPcmkInfos __((TVDatPcmkInfos *infos));
extern IGRstat VDatGetStandardPcmkInfo  __((TVDatPcmkInfo *info));

/* ----------------------------------------------------
 * vdat/pcmk/VDatLeaf.I
 */
extern IGRstat VDatGetPcmkLeafInfos __((TGRid          *nodeID,
					TVDatPcmkInfos *infos));

extern IGRstat VDatGetPcmkLeafInfo  __((TGRid *leafID, 
					TVDatPcmkLeafInfo *leaf));

extern IGRstat VDatGetPcmkPlateAttrInfo __((TVDatPcmkInfo *info));
extern IGRstat VDatGetPcmkBeamAttrInfo  __((TVDatPcmkInfo *info));

/* ----------------------------------------------------
 * vdat/pcmk/VDatAttr.I
 */
extern IGRstat VDatGetPcmkAttrInfos __((TVDatPcmkInfos *infos));
extern IGRstat VDatGetPcmkAttrInfo  __((TVDatPcmkInfo  *info));

/* ----------------------------------------------------
 * vdat/pcmk/VDatInfo.I
 */
extern IGRstat VDatGetPcmkInfos        __((TGRid          *treeID,  
					   TVDatPcmkInfos *infos));

extern IGRstat VDatGetPcmkNotLikeInfos __((TVDatPcmkInfos *infos));
extern IGRstat VDatGetPcmkNotLikeInfo  __((TVDatPcmkInfo  *info));

extern IGRstat VDatPrintPcmkInfos      __((TVDatPcmkInfos *infos));
extern IGRstat VDatPrintPcmkInfo       __((TVDatPcmkInfo  *info));

extern IGRstat VDatFreePcmkInfos       __((TVDatPcmkInfos *infos));

extern IGRstat VDatTestPcmksForSetName  __((IGRint test, IGRchar *setName));
extern IGRstat VDatTest1PcmksForNode    __((IGRint test, TGRid   *nodeID));
extern IGRstat VDatTest2PcmksForNode    __((IGRint test, TGRid   *nodeID));
extern IGRstat VDatTest3PcmksForNode    __((IGRint test, TGRid   *nodeID));
extern IGRstat VDatTest4PcmksForNode    __((IGRint test, TGRid   *nodeID));

/* ----------------------------------------------------
 * vdat/pcmk/VDatSort.I
 */
extern IGRint VDatSortPcmkInfo1 __((const void *info1, const void *info2));
extern IGRint VDatSortPcmkInfo2 __((const void *info1, const void *info2));

/* ----------------------------------------------------
 * vdat/pcmk/VDatBlob.I
 */
extern IGRstat VDblobGetBlobData      __((TGRid *blobID, IGRint *dataLen, IGRchar **data));
extern IGRstat VDblobSaveToFile       __((TGRid *blobID, IGRchar *fileName));
extern IGRstat VDblobLoadFromFile     __((TGRid *blobID, IGRchar *fileName));
extern IGRstat VDblobGetBlobObject    __((TVDosnum osnum, IGRchar *name, TGRid *blobID));
extern IGRstat VDblobCreateBlobObject __((TVDosnum osnum, IGRchar *name, TGRid *blobID));

/* ----------------------------------------------------
 * vdat/pcmk/VDatXml.I
 */
extern IGRstat VDatWritePcmkInfosToXmlFile  __((IGRchar        *fileName, 
						TVDatPcmkInfos *infos));

extern IGRstat VDatLoadPcmkInfosFromXml     __((IGRchar *fileName, 
						IGRchar *blobName, 
						TVDatPcmkInfos *infos));

extern IGRstat VDatGetNumLeafsInXmlFile     __((IGRchar *fileName, IGRint *cnt));

extern IGRstat VDatLoadPcmkInfosFromXmlFile __((IGRchar *fileName, 
						TVDatPcmkInfos *infos));








/* ----------------------------------------------------
 * Toss in
 */
extern IGRboolean IGEstop __(());

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
