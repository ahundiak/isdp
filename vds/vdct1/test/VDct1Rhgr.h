/* $Id: VDct1Rhgr.h,v 1.2 2001/02/11 17:48:21 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Rhgr.h
 *
 * Description: Standard Parts Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Rhgr.h,v $
 *      Revision 1.2  2001/02/11 17:48:21  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.1  2000/09/14  20:36:46  pinnacle
 * Created: vds/vdct1/test/VDct1Rhgr.h by jdsauby for Service Pack
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/11/00  js      Creation
 ***************************************************************************/

#ifndef VDct1Rhgr_include
#define VDct1Rhgr_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDrisc_include
#include "VDrisc.h"
#endif

#ifndef VDct1Ris_include
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
#define VDCT1_RHGR_DELIM_CHAR '|'

/* -----------------------------------------------
 * Some useful defaults
 */
#define VDCT1_DEFAULT_CAGE_CODE "1CC97"

/* -----------------------------------------------
 * Feild lengths, from text file
 */


#define VDCT1_RHGR_FLD_LEN_OPS_ID       19

// Hanger Mino = assembly
#define VDCT1_RHGR_FLD_LEN_MINO         19

#define VDCT1_RHGR_FLD_LEN_PARTNUM      40
#define VDCT1_RHGR_FLD_LEN_TYPE         19
#define VDCT1_RHGR_FLD_LEN_COMP_CODE     6
#define VDCT1_RHGR_FLD_LEN_MATERIAL     19
#define VDCT1_RHGR_FLD_LEN_MAT_ABB       4
#define VDCT1_RHGR_FLD_LEN_WIDTH_1      12
#define VDCT1_RHGR_FLD_LEN_WIDTH_1M     12
#define VDCT1_RHGR_FLD_LEN_NO_TIERS     12
#define VDCT1_RHGR_FLD_LEN_DP           12
#define VDCT1_RHGR_FLD_LEN_DP_M         12
#define VDCT1_RHGR_FLD_LEN_DP1          12
#define VDCT1_RHGR_FLD_LEN_DP1_M        12
#define VDCT1_RHGR_FLD_LEN_DP2          12
#define VDCT1_RHGR_FLD_LEN_DP2_M        12

// Product Structure information
#define VDCT1_RHGR_FLD_LEN_MINO_DC      19
#define VDCT1_RHGR_FLD_LEN_MINO_CT      19
#define VDCT1_RHGR_FLD_LEN_MINO_BOLT    19
#define VDCT1_RHGR_FLD_LEN_MINO_NUT     19
#define VDCT1_RHGR_FLD_LEN_QTY_DC       12
#define VDCT1_RHGR_FLD_LEN_QTY_CT       12
#define VDCT1_RHGR_FLD_LEN_QTY_BOLT     12
#define VDCT1_RHGR_FLD_LEN_QTY_NUT      12

// wieghts
#define VDCT1_RHGR_FLD_LEN_WT_DC        12
#define VDCT1_RHGR_FLD_LEN_WT_CT        12
#define VDCT1_RHGR_FLD_LEN_WEIGHT       12

#define VDCT1_RHGR_FLD_LEN_MTHD_NO      19
#define VDCT1_RHGR_FLD_LEN_MTHD_TYPE    12
#define VDCT1_RHGR_FLD_LEN_CAGE          6
#define VDCT1_RHGR_FLD_LEN_DESCRIPTION 200 

// adding cage-mino
#define VDCT1_RHGR_FLD_LEN_CAGE_MINO    25


// Field Names
#define VDCT1_RHGR_FLD_NAME_OPS_ID       "ops_id"

// Hanger Mino = assembly
#define VDCT1_RHGR_FLD_NAME_MINO         "mino"

#define VDCT1_RHGR_FLD_NAME_PARTNUM      "partnum"
#define VDCT1_RHGR_FLD_NAME_TYPE         "type"
#define VDCT1_RHGR_FLD_NAME_COMP_CODE    "comp_code"
#define VDCT1_RHGR_FLD_NAME_MATERIAL     "material"
#define VDCT1_RHGR_FLD_NAME_MAT_ABB      "mat_abb"
#define VDCT1_RHGR_FLD_NAME_WIDTH_1      "width_1"
#define VDCT1_RHGR_FLD_NAME_WIDTH_1M     "width_1m"
#define VDCT1_RHGR_FLD_NAME_NO_TIERS     "no_tiers"
#define VDCT1_RHGR_FLD_NAME_DP           "dp"
#define VDCT1_RHGR_FLD_NAME_DP_M         "dp_m"
#define VDCT1_RHGR_FLD_NAME_DP1          "dp1"
#define VDCT1_RHGR_FLD_NAME_DP1_M        "dp1_m"
#define VDCT1_RHGR_FLD_NAME_DP2          "dp2"
#define VDCT1_RHGR_FLD_NAME_DP2_M        "dp2_m"

// Product Structure information
#define VDCT1_RHGR_FLD_NAME_MINO_DC      "mino_dc"
#define VDCT1_RHGR_FLD_NAME_MINO_CT      "mino_ct"
#define VDCT1_RHGR_FLD_NAME_MINO_BOLT    "mino_bolt"
#define VDCT1_RHGR_FLD_NAME_MINO_NUT     "mino_nut"
#define VDCT1_RHGR_FLD_NAME_QTY_DC       "qty_dc"
#define VDCT1_RHGR_FLD_NAME_QTY_CT       "qty_ct"
#define VDCT1_RHGR_FLD_NAME_QTY_BOLT     "qty_bolt"
#define VDCT1_RHGR_FLD_NAME_QTY_NUT      "qty_nut"

// wieghts
#define VDCT1_RHGR_FLD_NAME_WT_DC        "wt_dc"
#define VDCT1_RHGR_FLD_NAME_WT_CT        "wt_ct"
#define VDCT1_RHGR_FLD_NAME_WEIGHT       "weight"

#define VDCT1_RHGR_FLD_NAME_MTHD_NO      "mthd_no"
#define VDCT1_RHGR_FLD_NAME_MTHD_TYPE    "mthd_type"
#define VDCT1_RHGR_FLD_NAME_CAGE         "cage"
#define VDCT1_RHGR_FLD_NAME_DESCRIPTION  "description"

// adding cage-mino
#define VDCT1_RHGR_FLD_NAME_CAGE_MINO    "cage_mino"


// the fields
typedef IGRchar TVDct1_rhgr_fld_ops_id           [1+VDCT1_RHGR_FLD_LEN_OPS_ID];
typedef IGRchar TVDct1_rhgr_fld_mino             [1+VDCT1_RHGR_FLD_LEN_MINO];
typedef IGRchar TVDct1_rhgr_fld_partnum          [1+VDCT1_RHGR_FLD_LEN_PARTNUM];
typedef IGRchar TVDct1_rhgr_fld_type             [1+VDCT1_RHGR_FLD_LEN_TYPE];
typedef IGRchar TVDct1_rhgr_fld_comp_code        [1+VDCT1_RHGR_FLD_LEN_COMP_CODE];
typedef IGRchar TVDct1_rhgr_fld_material         [1+VDCT1_RHGR_FLD_LEN_MATERIAL];
typedef IGRchar TVDct1_rhgr_fld_mat_abb          [1+VDCT1_RHGR_FLD_LEN_MAT_ABB];
typedef IGRchar TVDct1_rhgr_fld_width_1          [1+VDCT1_RHGR_FLD_LEN_WIDTH_1];
typedef IGRchar TVDct1_rhgr_fld_width_1m         [1+VDCT1_RHGR_FLD_LEN_WIDTH_1M];
typedef IGRchar TVDct1_rhgr_fld_no_tiers         [1+VDCT1_RHGR_FLD_LEN_NO_TIERS];
typedef IGRchar TVDct1_rhgr_fld_dp               [1+VDCT1_RHGR_FLD_LEN_DP];
typedef IGRchar TVDct1_rhgr_fld_dp_m             [1+VDCT1_RHGR_FLD_LEN_DP_M];
typedef IGRchar TVDct1_rhgr_fld_dp1              [1+VDCT1_RHGR_FLD_LEN_DP1];
typedef IGRchar TVDct1_rhgr_fld_dp1_m            [1+VDCT1_RHGR_FLD_LEN_DP1_M];
typedef IGRchar TVDct1_rhgr_fld_dp2              [1+VDCT1_RHGR_FLD_LEN_DP2];
typedef IGRchar TVDct1_rhgr_fld_dp2_m            [1+VDCT1_RHGR_FLD_LEN_DP2_M];
typedef IGRchar TVDct1_rhgr_fld_mino_dc          [1+VDCT1_RHGR_FLD_LEN_MINO_DC];
typedef IGRchar TVDct1_rhgr_fld_mino_ct          [1+VDCT1_RHGR_FLD_LEN_MINO_CT];
typedef IGRchar TVDct1_rhgr_fld_mino_bolt        [1+VDCT1_RHGR_FLD_LEN_MINO_BOLT];
typedef IGRchar TVDct1_rhgr_fld_mino_nut         [1+VDCT1_RHGR_FLD_LEN_MINO_NUT];
typedef IGRchar TVDct1_rhgr_fld_qty_dc           [1+VDCT1_RHGR_FLD_LEN_QTY_DC];
typedef IGRchar TVDct1_rhgr_fld_qty_ct           [1+VDCT1_RHGR_FLD_LEN_QTY_CT];
typedef IGRchar TVDct1_rhgr_fld_qty_bolt         [1+VDCT1_RHGR_FLD_LEN_QTY_BOLT];
typedef IGRchar TVDct1_rhgr_fld_qty_nut          [1+VDCT1_RHGR_FLD_LEN_QTY_NUT];
typedef IGRchar TVDct1_rhgr_fld_wt_dc            [1+VDCT1_RHGR_FLD_LEN_WT_DC];
typedef IGRchar TVDct1_rhgr_fld_wt_ct            [1+VDCT1_RHGR_FLD_LEN_WT_CT];
typedef IGRchar TVDct1_rhgr_fld_weight           [1+VDCT1_RHGR_FLD_LEN_WEIGHT];
typedef IGRchar TVDct1_rhgr_fld_mthd_no          [1+VDCT1_RHGR_FLD_LEN_MTHD_NO];
typedef IGRchar TVDct1_rhgr_fld_mthd_type        [1+VDCT1_RHGR_FLD_LEN_MTHD_TYPE];
typedef IGRchar TVDct1_rhgr_fld_cage             [1+VDCT1_RHGR_FLD_LEN_CAGE];
typedef IGRchar TVDct1_rhgr_fld_description      [1+VDCT1_RHGR_FLD_LEN_DESCRIPTION];


// the entire hanger assembly record
typedef struct
{
  TVDct1_rhgr_fld_ops_id      ops_id;
  TVDct1_rhgr_fld_mino        mino;
  TVDct1_rhgr_fld_partnum     partnum;
  TVDct1_rhgr_fld_type        type;
  TVDct1_rhgr_fld_comp_code   comp_code;
  TVDct1_rhgr_fld_material    material;
  TVDct1_rhgr_fld_mat_abb     mat_abb;
  TVDct1_rhgr_fld_width_1     width_1;
  TVDct1_rhgr_fld_width_1m    width_1m;
  TVDct1_rhgr_fld_no_tiers    no_tiers;
  TVDct1_rhgr_fld_dp          dp;
  TVDct1_rhgr_fld_dp_m        dp_m;
  TVDct1_rhgr_fld_dp1         dp1;
  TVDct1_rhgr_fld_dp1_m       dp1_m;
  TVDct1_rhgr_fld_dp2         dp2;
  TVDct1_rhgr_fld_dp2_m       dp2_m;
  TVDct1_rhgr_fld_mino_dc     mino_dc;
  TVDct1_rhgr_fld_mino_ct     mino_ct;
  TVDct1_rhgr_fld_mino_bolt   mino_bolt;
  TVDct1_rhgr_fld_mino_nut    mino_nut;
  TVDct1_rhgr_fld_qty_dc      qty_dc;
  TVDct1_rhgr_fld_qty_ct      qty_ct;
  TVDct1_rhgr_fld_qty_bolt    qty_bolt;
  TVDct1_rhgr_fld_qty_nut     qty_nut;
  TVDct1_rhgr_fld_wt_dc       wt_dc;
  TVDct1_rhgr_fld_wt_ct       wt_ct;
  TVDct1_rhgr_fld_weight      weight;
  TVDct1_rhgr_fld_mthd_no     mthd_no;
  TVDct1_rhgr_fld_mthd_type   mthd_type; 
  TVDct1_rhgr_fld_cage        cage;
  TVDct1_rhgr_fld_description description;
} TVDct1RhgrInfo;

typedef struct 
{
  IGRint max;
  IGRint inc;
  IGRint cnt;
  TVDct1RhgrInfo **rhgrs;
} TVDct1RhgrInfos;

  
// function called from PPL
extern IGRstat VDct1LoadRhgrAssy   __((IGRchar *fileName));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
