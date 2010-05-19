/* $Id: VDct1Copics.h,v 1.1 2001/01/09 22:17:56 art Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDct1Copics.h
 *
 * Description: Copics Translator
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDct1Copics.h,v $
 *	Revision 1.1  2001/01/09 22:17:56  art
 *	ah
 *	
 * Revision 1.3  2000/10/24  14:03:28  pinnacle
 * js
 *
 * Revision 1.2  2000/10/11  20:32:50  pinnacle
 * js
 *
 * Revision 1.1  2000/07/17  19:20:28  pinnacle
 * ah
 *
 *
 * History:
 * 07/06/00 ah  Created
 *
 * -------------------------------------------------------------------*/
#ifndef VDct1Copics_include
#define VDct1Copics_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDvlaInfo_include
#include "VDvlaInfo.h"
#endif

/* -------------------------------------------------------------------
 * Usual BS
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Try to keep translatore more or less
 * independent of the actual tree
 */
#define XML_COP_GROUP     "GROUP"
#define XML_COP_ENG_ASSY2 "ENG_ASSY2"
#define XML_COP_STD_ASSY2 "ASSY_TYPE2"
#define XML_COP_PART      "PART"


#define XML_COP_NODE_NAME  "node_name"
#define XML_COP_COMM_CODE  "comm_code"
#define XML_COP_ZONE_NUM   "zone_num"
#define XML_COP_UNIT_NUM   "unit_num"
#define XML_COP_COMPT_NUM  "compt_num"
#define XML_COP_UM         "unit_measure"
#define XML_COP_QTY        "qty"
#define XML_COP_COPICS_NUM "copics_num"
#define XML_COP_PCT_MINO   "pct_mino"

#define XML_COP_PALLET           "PALLET"
#define XML_COP_CONTRACT_JOB_NUM "contracthull"
#define XML_COP_DWG_NUM          "drawing_no"
#define XML_COP_HULL_NUM         "avhull"

typedef struct 
{
  IGRchar contract_job_num[32];
  IGRchar dwg_num         [32];
  IGRchar hull_num        [32];
  IGRchar pallet_code     [32];
  
  IGRchar node_name [32];
  IGRchar comm_code [16];
  IGRchar zone_num  [16];
  IGRchar unit_num  [16];
  IGRchar compt_num [32];
  IGRchar copics_num[32];
  
  IGRchar um      [4];
  IGRchar qty     [32];
  IGRchar pct_mino[32];
  
  IGRchar type[4];
  IGRchar desc[32];

  TVDvlaInfo parts;
  
} TVDct1CopItemInfo;

typedef struct 
{
  IGRchar node_name [32];
  IGRchar comm_code [16];
  IGRchar zone_num  [16];
  IGRchar unit_num  [16];
  IGRchar compt_num [32];
  IGRchar copics_num[32];
  

  IGRchar um      [4];
  IGRchar pct_mino[32];
  IGRchar type    [4];
  IGRchar desc    [32];

  TVDvlaInfo parts;
  
} TVDct1CopAssyInfo;

typedef struct 
{
  IGRchar node_name [32];
  IGRchar comm_code [16];
  IGRchar copics_num[32];
  
  IGRchar qty     [32];
  IGRchar um      [4];
  IGRchar pct_mino[32];
  
} TVDct1CopPartInfo;

/* -----------------------------------------------
 * Master Copics Structure for Engineering Assys
 */
typedef struct 
{
  struct 
  {
    FILE *err;
    FILE *cop;
  } file;

  TVDvlaInfo assys;
  TVDvlaInfo parts;
  
  // To make parsing a bit easier, these get set to
  // The current part or assy node
  TVDct1CopAssyInfo *assyx;
  TVDct1CopPartInfo *partx;

  // If the parser says so
  IGRint fatalError;
  
} TVDct1CopEngInfo;

/* -----------------------------------------------
 * Master Copics Structure for Palleting Assys
 */
typedef struct 
{
  struct 
  {
    FILE *err;
    FILE *cop;
  } file;

  TVDvlaInfo items;

  // To make parsing a bit easier, these get set to
  // The current part or assy node
  TVDct1CopItemInfo *itemx;

  // Holds current pallet_code
  IGRchar pallet_code[32];

  // If the parser says so
  IGRint fatalError;
  
} TVDct1CopPalInfo;

/* ----------------------------------------------
 * Command Interface
 */
extern IGRstat VDct1InitViewCopInfo __(());

/* -----------------------------------------------
 * Engineering assemblies from xml file
 */
extern IGRstat VDct1CopAssyGenerateCopics __((IGRchar          *xmlFileName,
					      IGRchar          *outFileName,
					      TVDct1CopEngInfo *info));

extern IGRstat VDct1CopAssySaxCallback __((TVDxmlParseInfo *parseInfo));

extern IGRstat VDct1CopEngAssySaxCallback __((TVDxmlParseInfo *parseInfo));

extern IGRstat VDct1CopStdAssySaxCallback __((TVDxmlParseInfo *parseInfo));

extern IGRstat VDct1CopPartSaxCallback __((TVDxmlParseInfo *parseInfo));

extern IGRstat VDct1CopAssyWriteCopics    __((TVDct1CopEngInfo *info));

extern IGRint VDct1SortCopPart __((const void *p1, const void *p2));

extern IGRint VDct1SortCopAssy __((const void *p1, const void *p2));


/* -----------------------------------------------
 * Pallet info from xml file
 */
extern IGRstat VDct1CopPalGenerateCopics __((IGRchar           *xmlFileName,
					     IGRchar           *theFileName,
					     TVDct1CopPalInfo  *info));

extern IGRstat VDct1CopPalSaxCallback    __((TVDxmlParseInfo *parseInfo));

extern IGRstat VDct1CopPalWriteCopics    __((TVDct1CopPalInfo *info));

extern IGRint  VDct1SortCopItem          __((const void *p1, const void *p2));

extern IGRint  VDct1SortCopPal           __((const void *p1, const void *p2));


/* -----------------------------------------------
 * Drop the cage code
 * Probable check for dups as well
 */
extern IGRstat VDct1CopProcessNodeName __((IGRchar *i_node_name, IGRchar *o_node_name));

/* ----------------------------------------------
 * attributes need changing around
 * qty and um derived from pct mino, node_name derived from copics_num
 */
extern IGRstat VDct1CopPartSwapAttr __((TVDct1CopPartInfo *part));

extern IGRstat VDct1CopItemSwapAttr __((TVDct1CopItemInfo *item));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif




