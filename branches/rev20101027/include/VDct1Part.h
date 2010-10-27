/* $Id: VDct1Part.h,v 1.2 2001/02/11 17:30:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Part.h
 *
 * Description: Standard Parts Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Part.h,v $
 *      Revision 1.2  2001/02/11 17:30:40  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/09 22:17:57  art
 *      ah
 *
 * Revision 1.14  2000/12/07  18:14:24  pinnacle
 * ah
 *
 * Revision 1.13  2000/12/07  17:33:08  pinnacle
 * ah
 *
 * Revision 1.12  2000/08/24  14:50:24  pinnacle
 * js
 *
 * Revision 1.11  2000/08/23  17:19:00  pinnacle
 * js
 *
 * Revision 1.10  2000/08/23  14:47:54  pinnacle
 * ah
 *
 * Revision 1.9  2000/07/17  19:06:28  pinnacle
 * ah
 *
 * Revision 1.8  2000/07/17  14:14:02  pinnacle
 * Replaced: vds/include/VDct1Part.h for:  by jdsauby for Service Pack
 *
 * Revision 1.7  2000/07/13  12:31:06  pinnacle
 * Replaced: vds/include/VDct1Part.h for:  by jdsauby for Service Pack
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/23/00  ah      Creation
 * 07/17/00  ah      Move ris stuff to VDct1Ris.h
 * 12/07/00  ah      c friendlf
 ***************************************************************************/

#ifndef VDct1Part_include
#define VDct1Part_include

#ifndef   VDrisc_include
#include "VDrisc.h"
#endif

#ifndef   VDct1Ris_include
#include "VDct1Ris.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Char used in delimited text files
 */
#define VDCT1_PART_DELIM_CHAR '|'

/* -----------------------------------------------
 * Some useful defaults
 */
#define VDCT1_DEFAULT_CAGE_CODE "1CC97"
#define VDCT1_DEFAULT_PROJ_CODE "LPOFA"

/* -----------------------------------------------
 * Main Part structure
 */
#define VDCT1_PART_FLD_LEN_PART_ID                     19

/* The isdp part-cage_num format really messes things up
 * It needs to be 31 characters for worse case (matches node_name)
 * But the ops and copics numbers are 25.
 * For now, set to 31 and see what happens
 *
 * Keep the part_num at 19 for now since only the isdp
 * string needs the extra characters and we don't do much with
 * the isdp_part_num anyways
 */
#define VDCT1_PART_FLD_LEN_PART_CAGE_NUM               31
#define VDCT1_PART_FLD_LEN_PART_CAGE_CODE               5
#define VDCT1_PART_FLD_LEN_PART_NUM                    19
#define VDCT1_PART_FLD_LEN_PART_REV                     2
#define VDCT1_PART_FLD_LEN_CUR_REV                      1
#define VDCT1_PART_FLD_LEN_PART_FAMILY                  4
#define VDCT1_PART_FLD_LEN_NOUN_NAME                   25
#define VDCT1_PART_FLD_LEN_TYPE                        25
#define VDCT1_PART_FLD_LEN_MODIFIER                    25
#define VDCT1_PART_FLD_LEN_MATERIAL                    25
#define VDCT1_PART_FLD_LEN_PART_SIZE                   40
#define VDCT1_PART_FLD_LEN_UNIT_OF_MEASURE              2
#define VDCT1_PART_FLD_LEN_PART_STATUS                 19
#define VDCT1_PART_FLD_LEN_REV_APPROVED                 8
#define VDCT1_PART_FLD_LEN_SUPERSEDED_BY               19
#define VDCT1_PART_FLD_LEN_ASSEMBLY_REQUIRED            1
#define VDCT1_PART_FLD_LEN_CFE_GFE                      3
#define VDCT1_PART_FLD_LEN_MAKE_BUY                     4
#define VDCT1_PART_FLD_LEN_ILS_WORTHY                   1
#define VDCT1_PART_FLD_LEN_SHOCK_GRADE                  1
#define VDCT1_PART_FLD_LEN_NATIONAL_STOCK_NUMBER       30
#define VDCT1_PART_FLD_LEN_HAZARDOUS_MATERIAL           1
#define VDCT1_PART_FLD_LEN_PRODUCTION_MATERIAL          1
#define VDCT1_PART_FLD_LEN_ADDITIONAL_DESCRIPTION     256
#define VDCT1_PART_FLD_LEN_CREATION_DATE               19
#define VDCT1_PART_FLD_LEN_CREATOR_ID                   8
#define VDCT1_PART_FLD_LEN_CHANGE_DATE                 19
#define VDCT1_PART_FLD_LEN_CHANGE_ID                    8
#define VDCT1_PART_FLD_LEN_CHANGE_DESCRIPTION         256
#define VDCT1_PART_FLD_LEN_INTERCHANGEABILITY_AFFECTED 22
#define VDCT1_PART_FLD_LEN_COPICS_SHORT_DESCRIPTION    25
#define VDCT1_PART_FLD_LEN_PRESSURE                    20
#define VDCT1_PART_FLD_LEN_COPICS_LONG_DESCRIPTION    800
#define VDCT1_PART_FLD_LEN_ISDP_STATUS                  2
#define VDCT1_PART_FLD_LEN_GRADE                       25
#define VDCT1_PART_FLD_LEN_LENGTH                      25
#define VDCT1_PART_FLD_LEN_VOLTAGE                     25
#define VDCT1_PART_FLD_LEN_WIDTH                       25
#define VDCT1_PART_FLD_LEN_DISCIPLINE                   2
#define VDCT1_PART_FLD_LEN_CLASSIFICATION               2
#define VDCT1_PART_FLD_LEN_FAMILY1                      3
#define VDCT1_PART_FLD_LEN_FAMILY2                      3
#define VDCT1_PART_FLD_LEN_FAMILY3                      3
#define VDCT1_PART_FLD_LEN_UPDATEBY                     8
#define VDCT1_PART_FLD_LEN_UPDATEDATE                  19

// My Addition
#define VDCT1_PART_FLD_LEN_BR                           4
#define VDCT1_PART_FLD_LEN_ITEM_TYPE                    1

// Sort order for attributes table
#define VDCT1_PART_FLD_IDX_PART_ID                      0
#define VDCT1_PART_FLD_IDX_PART_CAGE_NUM                1
#define VDCT1_PART_FLD_IDX_PART_CAGE_CODE               2
#define VDCT1_PART_FLD_IDX_PART_NUM                     3
#define VDCT1_PART_FLD_IDX_PART_REV                     4
#define VDCT1_PART_FLD_IDX_CUR_REV                      5
#define VDCT1_PART_FLD_IDX_PART_FAMILY                  6
#define VDCT1_PART_FLD_IDX_NOUN_NAME                    7
#define VDCT1_PART_FLD_IDX_TYPE                         8
#define VDCT1_PART_FLD_IDX_MODIFIER                     9
#define VDCT1_PART_FLD_IDX_MATERIAL                    10
#define VDCT1_PART_FLD_IDX_PART_SIZE                   11
#define VDCT1_PART_FLD_IDX_UNIT_OF_MEASURE             12
#define VDCT1_PART_FLD_IDX_PART_STATUS                 13
#define VDCT1_PART_FLD_IDX_REV_APPROVED                14
#define VDCT1_PART_FLD_IDX_SUPERSEDED_BY               15
#define VDCT1_PART_FLD_IDX_ASSEMBLY_REQUIRED           16
#define VDCT1_PART_FLD_IDX_CFE_GFE                     17
#define VDCT1_PART_FLD_IDX_MAKE_BUY                    18
#define VDCT1_PART_FLD_IDX_ILS_WORTHY                  19
#define VDCT1_PART_FLD_IDX_SHOCK_GRADE                 20
#define VDCT1_PART_FLD_IDX_NATIONAL_STOCK_NUMBER       21
#define VDCT1_PART_FLD_IDX_HAZARDOUS_MATERIAL          22
#define VDCT1_PART_FLD_IDX_PRODUCTION_MATERIAL         23
#define VDCT1_PART_FLD_IDX_ADDITIONAL_DESCRIPTION      24
#define VDCT1_PART_FLD_IDX_CREATION_DATE               25
#define VDCT1_PART_FLD_IDX_CREATOR_ID                  26
#define VDCT1_PART_FLD_IDX_CHANGE_DATE                 27
#define VDCT1_PART_FLD_IDX_CHANGE_ID                   28
#define VDCT1_PART_FLD_IDX_CHANGE_DESCRIPTION          29
#define VDCT1_PART_FLD_IDX_INTERCHANGEABILITY_AFFECTED 30
#define VDCT1_PART_FLD_IDX_COPICS_SHORT_DESCRIPTION    31
#define VDCT1_PART_FLD_IDX_PRESSURE                    32
#define VDCT1_PART_FLD_IDX_COPICS_LONG_DESCRIPTION     33
#define VDCT1_PART_FLD_IDX_ISDP_STATUS                 34
#define VDCT1_PART_FLD_IDX_GRADE                       35
#define VDCT1_PART_FLD_IDX_LENGTH                      36
#define VDCT1_PART_FLD_IDX_VOLTAGE                     37
#define VDCT1_PART_FLD_IDX_WIDTH                       38
#define VDCT1_PART_FLD_IDX_DISCIPLINE                  39
#define VDCT1_PART_FLD_IDX_CLASSIFICATION              40
#define VDCT1_PART_FLD_IDX_FAMILY1                     41
#define VDCT1_PART_FLD_IDX_FAMILY2                     42
#define VDCT1_PART_FLD_IDX_FAMILY3                     43
#define VDCT1_PART_FLD_IDX_UPDATEBY                    44
#define VDCT1_PART_FLD_IDX_UPDATEDATE                  45

// My Addition
#define VDCT1_PART_FLD_IDX_BR                          47
#define VDCT1_PART_FLD_IDX_ITEM_TYPE                   46

#define VDCT1_PART_FLD_IDX_LAST                        47

#if 0
#define VDCT1_PART_FLD_LEN_
#endif
     
// The Names
#define VDCT1_PART_FLD_NAME_PART_ID                     "item_id"
#define VDCT1_PART_FLD_NAME_PART_CAGE_NUM               "item_cage_num"
#define VDCT1_PART_FLD_NAME_PART_CAGE_CODE              "item_cage_code"
#define VDCT1_PART_FLD_NAME_PART_NUM                    "item_num"
#define VDCT1_PART_FLD_NAME_PART_REV                    "item_rev"
#define VDCT1_PART_FLD_NAME_CUR_REV                     "item_cur_rev"
#define VDCT1_PART_FLD_NAME_PART_FAMILY                 "part_family"
#define VDCT1_PART_FLD_NAME_NOUN_NAME                   "noun_name"
#define VDCT1_PART_FLD_NAME_TYPE                        "type"
#define VDCT1_PART_FLD_NAME_MODIFIER                    "modifier"
#define VDCT1_PART_FLD_NAME_MATERIAL                    "material"
#define VDCT1_PART_FLD_NAME_PART_SIZE                   "part_size"
#define VDCT1_PART_FLD_NAME_UNIT_OF_MEASURE             "unit_of_measure"
#define VDCT1_PART_FLD_NAME_PART_STATUS                 "part_status"
#define VDCT1_PART_FLD_NAME_REV_APPROVED                "rev_approved"
#define VDCT1_PART_FLD_NAME_SUPERSEDED_BY               "superseded_by"
#define VDCT1_PART_FLD_NAME_ASSEMBLY_REQUIRED           "assembly_required"
#define VDCT1_PART_FLD_NAME_CFE_GFE                     "cfe_gfe"
#define VDCT1_PART_FLD_NAME_MAKE_BUY                    "make_buy"
#define VDCT1_PART_FLD_NAME_ILS_WORTHY                  "ils_worthy"
#define VDCT1_PART_FLD_NAME_SHOCK_GRADE                 "shock_grade"
#define VDCT1_PART_FLD_NAME_NATIONAL_STOCK_NUMBER       "national_stock_number"
#define VDCT1_PART_FLD_NAME_HAZARDOUS_MATERIAL          "hazardous_material"
#define VDCT1_PART_FLD_NAME_PRODUCTION_MATERIAL         "production_material"
#define VDCT1_PART_FLD_NAME_ADDITIONAL_DESCRIPTION      "additional_description"
#define VDCT1_PART_FLD_NAME_CREATION_DATE               "creation_date"
#define VDCT1_PART_FLD_NAME_CREATOR_ID                  "creator_id"
#define VDCT1_PART_FLD_NAME_CHANGE_DATE                 "change_date"
#define VDCT1_PART_FLD_NAME_CHANGE_ID                   "change_id"
#define VDCT1_PART_FLD_NAME_CHANGE_DESCRIPTION          "change_description"
#define VDCT1_PART_FLD_NAME_INTERCHANGEABILITY_AFFECTED "interchangeability_affected"
#define VDCT1_PART_FLD_NAME_COPICS_SHORT_DESCRIPTION    "copics_short_description"
#define VDCT1_PART_FLD_NAME_COPICS_SHORT_DESC_RIS       "copics_short_desc"
#define VDCT1_PART_FLD_NAME_PRESSURE                    "pressure"
#define VDCT1_PART_FLD_NAME_COPICS_LONG_DESCRIPTION     "copics_long_description"
#define VDCT1_PART_FLD_NAME_ISDP_STATUS                 "isdp_status"
#define VDCT1_PART_FLD_NAME_GRADE                       "grade"
#define VDCT1_PART_FLD_NAME_LENGTH                      "length"
#define VDCT1_PART_FLD_NAME_VOLTAGE                     "voltage"
#define VDCT1_PART_FLD_NAME_WIDTH                       "width"
#define VDCT1_PART_FLD_NAME_DISCIPLINE                  "discipline"
#define VDCT1_PART_FLD_NAME_CLASSIFICATION              "classification"
#define VDCT1_PART_FLD_NAME_FAMILY1                     "family1"
#define VDCT1_PART_FLD_NAME_FAMILY2                     "family2"
#define VDCT1_PART_FLD_NAME_FAMILY3                     "family3"
#define VDCT1_PART_FLD_NAME_UPDATEBY                    "updateby"
#define VDCT1_PART_FLD_NAME_UPDATEDATE                  "updatedate"

// My Addition
#define VDCT1_PART_FLD_NAME_BR                          "br"
#define VDCT1_PART_FLD_NAME_ITEM_TYPE                   "item_type"

#if 0
#define VDCT1_PART_FLD_NAME_          ""
#define VDCT1_PART_FLD_NAME_          ""
#define VDCT1_PART_FLD_NAME_          ""
#define VDCT1_PART_FLD_NAME_          ""
#endif

// The fields
typedef IGRchar TVDct1_part_fld_part_id                    [1+VDCT1_PART_FLD_LEN_PART_ID];
typedef IGRchar TVDct1_part_fld_part_cage_num              [1+VDCT1_PART_FLD_LEN_PART_CAGE_NUM];
typedef IGRchar TVDct1_part_fld_part_cage_code             [1+VDCT1_PART_FLD_LEN_PART_CAGE_CODE];
typedef IGRchar TVDct1_part_fld_part_num                   [1+VDCT1_PART_FLD_LEN_PART_NUM];
typedef IGRchar TVDct1_part_fld_part_rev                   [1+VDCT1_PART_FLD_LEN_PART_REV];
typedef IGRchar TVDct1_part_fld_cur_rev                    [1+VDCT1_PART_FLD_LEN_CUR_REV];
typedef IGRchar TVDct1_part_fld_part_family                [1+VDCT1_PART_FLD_LEN_PART_FAMILY];
typedef IGRchar TVDct1_part_fld_noun_name                  [1+VDCT1_PART_FLD_LEN_NOUN_NAME];
typedef IGRchar TVDct1_part_fld_type                       [1+VDCT1_PART_FLD_LEN_TYPE];
typedef IGRchar TVDct1_part_fld_modifier                   [1+VDCT1_PART_FLD_LEN_MODIFIER];
typedef IGRchar TVDct1_part_fld_material                   [1+VDCT1_PART_FLD_LEN_MATERIAL];
typedef IGRchar TVDct1_part_fld_part_size                  [1+VDCT1_PART_FLD_LEN_PART_SIZE];
typedef IGRchar TVDct1_part_fld_unit_of_measure            [1+VDCT1_PART_FLD_LEN_UNIT_OF_MEASURE];
typedef IGRchar TVDct1_part_fld_part_status                [1+VDCT1_PART_FLD_LEN_PART_STATUS];
typedef IGRchar TVDct1_part_fld_rev_approved               [1+VDCT1_PART_FLD_LEN_REV_APPROVED];
typedef IGRchar TVDct1_part_fld_superseded_by              [1+VDCT1_PART_FLD_LEN_SUPERSEDED_BY];
typedef IGRchar TVDct1_part_fld_assembly_required          [1+VDCT1_PART_FLD_LEN_ASSEMBLY_REQUIRED];
typedef IGRchar TVDct1_part_fld_cfe_gfe                    [1+VDCT1_PART_FLD_LEN_CFE_GFE];
typedef IGRchar TVDct1_part_fld_make_buy                   [1+VDCT1_PART_FLD_LEN_MAKE_BUY];
typedef IGRchar TVDct1_part_fld_ils_worthy                 [1+VDCT1_PART_FLD_LEN_ILS_WORTHY];
typedef IGRchar TVDct1_part_fld_shock_grade                [1+VDCT1_PART_FLD_LEN_SHOCK_GRADE];
typedef IGRchar TVDct1_part_fld_national_stock_number      [1+VDCT1_PART_FLD_LEN_NATIONAL_STOCK_NUMBER];
typedef IGRchar TVDct1_part_fld_hazardous_material         [1+VDCT1_PART_FLD_LEN_HAZARDOUS_MATERIAL];
typedef IGRchar TVDct1_part_fld_production_material        [1+VDCT1_PART_FLD_LEN_PRODUCTION_MATERIAL];
typedef IGRchar TVDct1_part_fld_additional_description     [1+VDCT1_PART_FLD_LEN_ADDITIONAL_DESCRIPTION];
typedef IGRchar TVDct1_part_fld_creation_date              [1+VDCT1_PART_FLD_LEN_CREATION_DATE];
typedef IGRchar TVDct1_part_fld_creator_id                 [1+VDCT1_PART_FLD_LEN_CREATOR_ID];
typedef IGRchar TVDct1_part_fld_change_date                [1+VDCT1_PART_FLD_LEN_CHANGE_DATE];
typedef IGRchar TVDct1_part_fld_change_id                  [1+VDCT1_PART_FLD_LEN_CHANGE_ID];
typedef IGRchar TVDct1_part_fld_change_description         [1+VDCT1_PART_FLD_LEN_CHANGE_DESCRIPTION];
typedef IGRchar TVDct1_part_fld_interchangeability_affected[1+VDCT1_PART_FLD_LEN_INTERCHANGEABILITY_AFFECTED];
typedef IGRchar TVDct1_part_fld_copics_short_description   [1+VDCT1_PART_FLD_LEN_COPICS_SHORT_DESCRIPTION];
typedef IGRchar TVDct1_part_fld_pressure                   [1+VDCT1_PART_FLD_LEN_PRESSURE];
typedef IGRchar TVDct1_part_fld_copics_long_description    [1+VDCT1_PART_FLD_LEN_COPICS_LONG_DESCRIPTION];
typedef IGRchar TVDct1_part_fld_isdp_status                [1+VDCT1_PART_FLD_LEN_ISDP_STATUS];
typedef IGRchar TVDct1_part_fld_grade                      [1+VDCT1_PART_FLD_LEN_GRADE];
typedef IGRchar TVDct1_part_fld_length                     [1+VDCT1_PART_FLD_LEN_LENGTH];
typedef IGRchar TVDct1_part_fld_voltage                    [1+VDCT1_PART_FLD_LEN_VOLTAGE];
typedef IGRchar TVDct1_part_fld_width                      [1+VDCT1_PART_FLD_LEN_WIDTH];
typedef IGRchar TVDct1_part_fld_discipline                 [1+VDCT1_PART_FLD_LEN_DISCIPLINE];
typedef IGRchar TVDct1_part_fld_classification             [1+VDCT1_PART_FLD_LEN_CLASSIFICATION];
typedef IGRchar TVDct1_part_fld_family1                    [1+VDCT1_PART_FLD_LEN_FAMILY1];
typedef IGRchar TVDct1_part_fld_family2                    [1+VDCT1_PART_FLD_LEN_FAMILY2];
typedef IGRchar TVDct1_part_fld_family3                    [1+VDCT1_PART_FLD_LEN_FAMILY3];
typedef IGRchar TVDct1_part_fld_updateby                   [1+VDCT1_PART_FLD_LEN_UPDATEBY];
typedef IGRchar TVDct1_part_fld_updatedate                 [1+VDCT1_PART_FLD_LEN_UPDATEDATE];

// My field
typedef IGRchar TVDct1_part_fld_br                         [1+VDCT1_PART_FLD_LEN_BR];
typedef IGRchar TVDct1_part_fld_item_type                  [1+VDCT1_PART_FLD_LEN_ITEM_TYPE];

#if 0
typedef IGRchar TVDct1_part_fld_        [1+VDCT1_PART_FLD_LEN_];
#endif

// The record
typedef struct 
{
  TVDct1_part_fld_part_id                      part_id;
  TVDct1_part_fld_part_cage_num                part_cage_num;
  TVDct1_part_fld_part_cage_code               part_cage_code;
  TVDct1_part_fld_part_num                     part_num;
  TVDct1_part_fld_part_rev                     part_rev;
  TVDct1_part_fld_cur_rev                      cur_rev;
  TVDct1_part_fld_part_family                  part_family;
  TVDct1_part_fld_noun_name                    noun_name;
  TVDct1_part_fld_type                         type;
  TVDct1_part_fld_modifier                     modifier;
  TVDct1_part_fld_material                     material;
  TVDct1_part_fld_part_size                    part_size;
  TVDct1_part_fld_unit_of_measure              unit_of_measure;
  TVDct1_part_fld_part_status                  part_status;
  TVDct1_part_fld_rev_approved                 rev_approved;
  TVDct1_part_fld_superseded_by                superseded_by;
  TVDct1_part_fld_assembly_required            assembly_required;
  TVDct1_part_fld_cfe_gfe                      cfe_gfe;
  TVDct1_part_fld_make_buy                     make_buy;
  TVDct1_part_fld_ils_worthy                   ils_worthy;
  TVDct1_part_fld_shock_grade                  shock_grade;
  TVDct1_part_fld_national_stock_number        national_stock_number;
  TVDct1_part_fld_hazardous_material           hazardous_material;
  TVDct1_part_fld_production_material          production_material;
  //Dct1_part_fld_additional_description       additional_description;
  TVDct1_part_fld_creation_date                creation_date;
  TVDct1_part_fld_creator_id                   creator_id;
  TVDct1_part_fld_change_date                  change_date;
  TVDct1_part_fld_change_id                    change_id;
  //Dct1_part_fld_change_description           change_description;
  TVDct1_part_fld_interchangeability_affected  interchangeability_affected;
  TVDct1_part_fld_copics_short_description     copics_short_description;
  TVDct1_part_fld_pressure                     pressure;
  //Dct1_part_fld_copics_long_description      copics_long_description;
  TVDct1_part_fld_isdp_status                  isdp_status;
  TVDct1_part_fld_grade                        grade;
  TVDct1_part_fld_length                       length;
  TVDct1_part_fld_voltage                      voltage;
  TVDct1_part_fld_width                        width;
  TVDct1_part_fld_discipline                   discipline;
  TVDct1_part_fld_classification               classification;
  TVDct1_part_fld_family1                      family1;
  TVDct1_part_fld_family2                      family2;
  TVDct1_part_fld_family3                      family3;
  TVDct1_part_fld_updateby                     updateby;
  TVDct1_part_fld_updatedate                   updatedate;

  // My Own
  TVDct1_part_fld_br                           br;
  TVDct1_part_fld_item_type                    item_type;


} TVDct1PartInfo;

typedef struct 
{
  IGRint max;
  IGRint inc;
  IGRint cnt;
  TVDct1PartInfo **parts;
} TVDct1PartInfos;

typedef struct 
{
  IGRint   idx;
  IGRint   len;
  IGRint   type;

  IGRint   delimFlag;  // Load from delimited file
  IGRint   attrsFlag;  // Save into attributes table
  
  IGRchar  name[32];
  IGRchar  desc[64];
  IGRchar  info[64];
  IGRchar  buf [80];
  
  IGRchar *data;
} TVDct1PartFldInfo;

/* -----------------------------------------------
 * VDct1Read.I
 */
extern IGRstat VDct1DumpPartsTable          __((IGRchar *noun_name, IGRchar *fileName));

extern IGRstat VDct1ReadPartFromAttrsTable  __((IGRchar *part_id,       TVDct1PartInfo *part));

extern IGRstat VDct1ReadPartForPartCageNum  __((IGRchar *part_cage_num, TVDct1PartInfo *part));
extern IGRstat VDct1ReadPartForItemCageNum  __((IGRchar *part_cage_num, TVDct1PartInfo *part));

extern IGRstat VDct1ReadPartIdForPartNum      __((IGRchar *part_num,      IGRchar        *part_id));
extern IGRstat VDct1ReadPartIdForPartCageNum  __((IGRchar *part_cage_num, IGRchar        *part_id));

extern IGRstat VDct1CopyPartFromRisBuf        __((IGRchar **buf,          TVDct1PartInfo *part));

extern IGRstat VDct1ReadCageNumForIsdpCageNum __((IGRchar *isdp_cage_num, IGRchar *part_cage_num));



/* -----------------------------------------------
 * VDct1Load.I
 */
extern IGRstat VDct1LoadPartsTable         __(());
extern IGRstat VDct1LoadPartsTableRecord   __((TVDct1PartInfo  *part));
extern IGRstat VDct1LoadAttrsTableRecord   __((TVDct1PartInfo  *part, IGRint idx));
extern IGRstat VDct1SetPartsRecordDefaults __((TVDct1PartInfo  *part));

extern IGRstat VDct1EmptyPartsTable __(());

/* ----------------------------------------------
 * VDct1Upd.I
 */
extern IGRstat VDct1UpdatePartsTable             __(());
extern IGRstat VDct1UpdatePartCurRev             __((TVDct1PartInfo  *part,
						     IGRint          curRev));
extern IGRstat VDct1ComparePartsTableRecordInfo  __((TVDct1PartInfo *part,
						     TVDct1PartInfo *partx));
extern IGRstat VDct1DeletePartsTableRecord       __((TVDct1PartInfo *part));

/* -----------------------------------------------
 * VDct1Delim.I
 */
extern IGRstat VDct1LoadPartInfoDelimitedFld __((IGRchar **buf,IGRint len, IGRchar *fld));

extern IGRstat VDct1LoadDelimitedPartFldInfo       __((IGRchar **buf, TVDct1PartInfo *part, IGRint idx));

extern IGRstat VDct1LoadDelimitedPartInfo          __((TVDct1PartInfos *infos, IGRchar *buf, IGRint filter1));
extern IGRstat VDct1LoadDelimitedPartTextRecord    __((FILE *file, IGRchar *buf));

extern IGRstat VDct1LoadDelimitedPartInfos         __((TVDct1PartInfos *infos, IGRint filter1));
extern IGRstat VDct1LoadDelimitedPartInfosFromFile __((TVDct1PartInfos *infos, IGRchar *fileName, IGRint filter1));

extern IGRstat VDct1TestLoadDelimitedPartInfos     __(());

/* -----------------------------------------------
 * VDct1Misc.I
 */
extern IGRstat VDct1InitPartInfos __((TVDct1PartInfos *infos));
extern IGRstat VDct1FreePartInfos __((TVDct1PartInfos *infos));

extern IGRstat VDct1GetNextPartInfo __((TVDct1PartInfos *infos, TVDct1PartInfo **part));
extern IGRstat VDct1AddPartInfo     __((TVDct1PartInfos *infos, TVDct1PartInfo  *part));

extern IGRint  VDct1SortPartsByPartCageNum  __((const void *part1x, const void *part2x));
extern IGRint  VDct1SortPartsByPartNum      __((const void *part1x, const void *part2x));
extern IGRint  VDct1SortPartsByNoun         __((const void *part1x, const void *part2x));
extern IGRint  VDct1SortPartsByCageCode     __((const void *part1x, const void *part2x));

extern IGRstat VDct1IsPartCurrent  __((TVDct1PartInfos *infos, IGRint i));
extern IGRstat VDct1IsNounDistinct __((TVDct1PartInfos *infos, IGRint i));

/* -----------------------------------------------
 * VDct1Data.I
 */
extern IGRstat VDct1GetDataDir __((IGRchar *dir));

extern IGRstat VDct1GetPartNumForModelObject __((
  TGRobj_env *objOE,
  TGRid      *objID,
  TVDct1_part_fld_part_num part_num,
  TVDct1_part_fld_part_id  part_id));

extern IGRstat VDct1GetPartCageNumForModelObject __((
  TGRobj_env *objOE,
  TGRid      *objID,
  TVDct1_part_fld_part_cage_num part_cage_num,
  TVDct1_part_fld_part_id       part_id));

extern IGRstat VDct1ComputePartCageNumForWWayObject __((TGRid   *objID,
							IGRchar *cage_code,
							IGRchar *part_cage_num));

extern IGRstat VDct1GetItemTypeForModelObject __((TGRobj_env *modelOE,
						  IGRchar    *itemType));


/* -----------------------------------------------
 * VDct1Fld.I
 */
extern IGRstat VDct1GetPartFldInfoForName __((IGRchar *name, TVDct1PartInfo *part, TVDct1PartFldInfo *fld));
extern IGRstat VDct1GetPartFldInfoForIdx  __((IGRint   idx,  TVDct1PartInfo *part, TVDct1PartFldInfo *fld));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif

