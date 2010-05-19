/* $Id: VDxmlPDM.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDxml.h
 *
 * Description: pdm specific xml prototypes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxmlPDM.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/04/21  19:51:14  pinnacle
 * PDM XML
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/99  ah      Created
 *
 ***************************************************************************/

#ifndef VDxmlPDM_include
#define VDxmlPDM_include

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

/* Info to write to form if keyword match is found */
typedef struct 
{
  IGRchar  catName [128];
  IGRchar  catDesc [128];
  IGRchar  partName[128];
  IGRchar  partRev [128];
  IGRchar  partDesc[128];
  IGRchar  fileName[128];
} TVDxmlPDMInfo;

#define VDXML_PDM_FORM_FILES    12
#define VDXML_PDM_FORM_SEARCH   16
#define VDXML_PDM_FORM_GENERATE 14
#define VDXML_PDM_FORM_LIST     17

#define VDXML_IN_PDM_SYSTEM       "ingr_pdm"
#define VDXML_IN_PDM_ROOT         "ingro_pdm_root"

#define VDXML_IN_PDM_CATALOG      "ingro_pdm_catalog"
#define VDXML_IN_PDM_CATALOGS     "ingro_pdm_catalogs"
#define VDXML_IN_PDM_CATALOG_NO   "ingra_pdm_catalog_no"
#define VDXML_IN_PDM_CATALOG_NAME "ingra_pdm_catalog_name"
#define VDXML_IN_PDM_CATALOG_DESC "ingra_pdm_catalog_desc"

#define VDXML_IN_PDM_PART         "ingro_pdm_part"
#define VDXML_IN_PDM_PARTS        "ingro_pdm_parts"
#define VDXML_IN_PDM_PART_NO      "ingra_pdm_part_no"
#define VDXML_IN_PDM_PART_NAME    "ingra_pdm_part_name"
#define VDXML_IN_PDM_PART_DESC    "ingra_pdm_part_desc"
#define VDXML_IN_PDM_PART_REV     "ingra_pdm_part_rev"

#define VDXML_IN_PDM_FILE         "ingro_pdm_file"
#define VDXML_IN_PDM_FILES        "ingro_pdm_files"
#define VDXML_IN_PDM_FILE_NO      "ingra_pdm_file_no"
#define VDXML_IN_PDM_FILE_NAME    "ingra_pdm_file_name"
#define VDXML_IN_PDM_FILE_DESC    "ingra_pdm_file_desc"

extern IGRstar VDxmlPDMSearchFile 
__((Form form));

extern IGRstar VDxmlPDMSearchFileLine 
__((IGRchar *buf,
    IGRchar *searchStr));

extern IGRstar VDxmlPDMQueryCatsParts __(());

extern IGRstat VDxmlPDMQueryParts
__((TVDxmlFileInfo *fileInfo,
    IGRchar        *catName,
    IGRint         *partCnt,
    IGRint         *fileCnt));

// -------------------------
#if defined(__cplusplus)
}
#endif

#endif

