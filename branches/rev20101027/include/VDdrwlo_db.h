
/* $Id: VDdrwlo_db.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/VDdrwlo_db.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_db.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/21  03:43:08  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by ksundar for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.7  1995/08/25  15:00:46  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by hverstee for vds.240
 *
 * Revision 1.6  1995/08/11  19:06:46  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by hverstee for vds.240
 *
 * Revision 1.5  1995/07/27  21:51:52  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by hverstee for vds.240
 *
 * Revision 1.4  1995/07/26  19:25:52  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by hverstee for vds.240
 *
 * Revision 1.3  1995/07/06  14:33:02  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/06/19  19:16:28  pinnacle
 * Replaced: include/VDdrwlo_db.h for:  by hverstee for vds.240
 *
 * Revision 1.3  1995/05/24  14:58:48  pinnacle
 * Replaced: include/VDdrwlo_db.h by hverstee r#
 *
 * Revision 1.2  1995/04/25  21:19:44  pinnacle
 * Replaced: include/VDdrwlo_db.h by hverstee r#
 *
 * Revision 1.1  1995/04/18  21:28:40  pinnacle
 * Created: include/VDdrwlo*.h by tdumbach r#
 * rno
 *
 * Revision 1.5  1995/03/25  15:29:48  pinnacle
 * Replaced: include/VDdrwlo_db.h by hverstee r#
 *
 * Revision 1.3  1995/03/09  21:09:40  pinnacle
 * Replaced: include/VDdrwlo_db.h by hverstee r#
 *
 * Revision 1.2  1995/03/08  15:09:36  pinnacle
 * Replaced: include/VDdrwlo_db.h by hverstee r#
 *
 * Revision 1.1  1995/03/03  21:04:22  pinnacle
 * Created: include/VDdrwlo_db.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            include file to define DRWlo DB
 *                                       interface
 *
 *	13/10/97	Sundar		Added expression tables info
 * -------------------------------------------------------------------*/

#ifndef VDdrwlo_db_h

#define VDdrwlo_db_h

#define VD_DLO_NEW_DB

/*     cache directory and structure       */

#define  VDDRWLO_DB_CACHE "table_layouts"
#define  VDCRSRT_DB_CACHE "sort_criteria"
#define  VDCRSUM_DB_CACHE "summ_criteria"
#define  VDADSYM_DB_CACHE "ad_symbols"
#define	 VDCREXP_DB_CACHE "expr_criteria"

struct   VDdrwlo_index {
  IGRchar      Tabnam[VD_DRWLO_CHR_IDFLD];     /*    layout name           */
  IGRchar      Tabtyp[VD_DRWLO_CHR_IDFLD];     /*    layout type           */
  IGRchar      Desc[VD_DRWLO_CHR_DESC];        /*    short desc            */
  struct GRid  LocId;                          /*    local loaded as       */
  IGRboolean   bInDB;                          /*    present in database   */
                       };

struct   VDSSC_index   {
  IGRchar      Tabnam[VD_DRWLO_CHR_IDFLD];     /*    layout name           */
  IGRchar      Desc[VD_DRWLO_CHR_DESC];        /*    short desc            */
  struct GRid  LocId;                          /*    local loaded as       */
  IGRboolean   bInDB;                          /*    present in database   */
                       };

struct   VDcrexp_index   {
  IGRchar      Tabtyp[VD_CREXP_CHR_TYPE];     /*    expression type       */
  IGRchar      Tabnam[VD_CREXP_CHR_NAME];     /*    expression name       */
  IGRchar      Desc[VD_CREXP_CHR_DESC];       /*    short desc            */
  struct GRid  LocId;                         /*    local loaded as       */
  IGRboolean   bInDB;                         /*    present in database   */
                       };


/*     general database key (all tables)   */

#define  VDDRWLO_DB_KEY   "table_name"

/*     general information table   */

#define  VDDRWLO_NAM_TAB    "ope_fmt_table"

#define  VDDRWLO_NUM_TAB     8
#define  VDDRWLO_NUM_IDX     3

#define  VDDRWLO_SEL_TAB   \
          "table_type,table_direct,timestamp_0,userid_0,table_desc,sum_file,sort_file,lc_unit"

#define  VDDRWLO_SEL_IDX   \
          "table_name,table_type,table_desc"

/*     alignment table for header/trailer fields    */

#define  VDDRWLO_NAM_ALG    "ope_fmt_align"
#define  VDDRWLO_NUM_ALG     3
#define  VDDRWLO_SEL_ALG   \
          "group_type,align_code,align_value"

struct   VDdrwlo_db_alg  {        /*  DB  alignment table    */
  IGRshort       hdtr_type;
  IGRshort       aligncode;
  IGRdouble      value;
                         };

/*     data columns table     */

#define  VDDRWLO_NAM_COL    "ope_fmt_col"
#define  VDDRWLO_NUM_COL    18
#define  VDDRWLO_SEL_COL   \
          "col_seqno,col_chars,col_wdt,col_hgt,col_charwdt,col_charspc,col_charhgt,col_linspc,ltop_style,ltop_wgt,lbot_style,lbot_wgt,llft_style,llft_wgt,lrgt_style,lrgt_wgt,tl_br,bl_tr"

struct   VDdrwlo_db_col  {         /*   DB   column data    */
  IGRshort        col_seqno;
  IGRshort        col_chars;
  IGRdouble       col_wdt;
  IGRdouble       col_hgt;
  IGRdouble       col_charwdt;
  IGRdouble       col_charspc;
  IGRdouble       col_charhgt;
  IGRdouble       col_linspc;

  IGRshort        ltop_style;
  IGRshort        ltop_wgt;
  IGRshort        lbot_style;
  IGRshort        lbot_wgt;
  IGRshort        llft_style;
  IGRshort        llft_wgt;
  IGRshort        lrgt_style;
  IGRshort        lrgt_wgt;

  IGRshort        tl_br;
  IGRshort        bl_tr;
                         };

/*    header/trailer fields table     */

#define  VDDRWLO_NAM_HTF    "ope_fmt_hdtr"
#define  VDDRWLO_NUM_HTF    21
#define  VDDRWLO_SEL_HTF   \
          "group_type,fieldid,fld_chars,fld_charwdt,fld_charspc,fld_charhgt,fld_linspc,alg_lcol,alg_rcol,alg_top,alg_bot,ltop_style,ltop_wgt,lbot_style,lbot_wgt,llft_style,llft_wgt,lrgt_style,lrgt_wgt,tl_br,bl_tr"

struct   VDdrwlo_db_htf  {          /*  DB   htf data    */

  IGRchar         fieldid[VD_DRWLO_CHR_IDFLD];
  IGRshort        hdtr_type;
  IGRshort        fld_chars;
  IGRdouble       fld_charwdt;
  IGRdouble       fld_charspc;
  IGRdouble       fld_charhgt;
  IGRdouble       fld_linspc;

  IGRshort        align_lcol;
  IGRshort        align_rcol;
  IGRshort        align_top;
  IGRshort        align_bot;

  IGRshort        ltop_style;
  IGRshort        ltop_wgt;
  IGRshort        lbot_style;
  IGRshort        lbot_wgt;
  IGRshort        llft_style;
  IGRshort        llft_wgt;
  IGRshort        lrgt_style;
  IGRshort        lrgt_wgt;

  IGRshort        tl_br;
  IGRshort        bl_tr;
                         };

/*       general field fill table    */

#define  VDDRWLO_NAM_FLD    "ope_fmt_fill"
#ifdef VD_DLO_NEW_DB

#define  VDDRWLO_NUM_FLD    12
#define  VDDRWLO_SEL_FLD   \
          "group_type,lin_seqno,col_seqno,fieldid,fld_type,data_type,dec_places,justif,id_weight,id_font,id_name,id_text"
#else
#define  VDDRWLO_NUM_FLD    11
#define  VDDRWLO_SEL_FLD   \
          "group_type,lin_seqno,col_seqno,fieldid,fld_type,data_type,dec_places,justif,id_font,id_name,id_text"
#endif

struct   VDdrwlo_db_fld  {           /*  DB and INSTANCE  field data  */

  IGRshort        hdtr_type;
  IGRshort        lin_seqno;
  IGRshort        col_seqno;
  IGRshort        fieldtype;
  IGRshort        datatype;
  IGRshort        f_decimal;
  IGRshort        justification;
  IGRshort        id_weight;
  IGRchar         fieldid[VD_DRWLO_CHR_IDFLD];
  IGRchar         id_Font[VD_DRWLO_CHR_IDFLD];
  IGRchar         id_name[VD_DRWLO_CHR_DESC];
  IGRchar         Ftext[VD_DRWLO_CHR_TEXT];
                         };

/*    sort criteria tables    */

#define  VDCRSRT_NAM_TAB   "ope_sort_table"

#define  VDCRSRT_NUM_TAB    3
#define  VDCRSRT_SEL_TAB   "timestamp_0,userid_0,table_desc"

#define  VDCRSRT_NUM_IDX    2
#define  VDCRSRT_SEL_IDX   "table_name,table_desc"

#define  VDCRSRT_NAM_SKY   "ope_sort_keys"
#define  VDCRSRT_NUM_SKY    4
#define  VDCRSRT_SEL_SKY   "sort_index,sort_order,sort_type,sort_attr"

/*    summarization criteria tables    */

#define  VDCRSUM_NAM_TAB   "ope_sum_table"

#define  VDCRSUM_NUM_TAB    3
#define  VDCRSUM_SEL_TAB   "timestamp_0,userid_0,table_desc"

#define  VDCRSUM_NUM_IDX    2
#define  VDCRSUM_SEL_IDX   "table_name,table_desc"

#define  VDCRSUM_NAM_QTY   "ope_sum_qty"
#define  VDCRSUM_NUM_QTY    4
#define  VDCRSUM_SEL_QTY   "table_cat,table_subcat,qty_flag,qty_exp"

#define  VDCRSUM_NAM_MTC   "ope_sum_match"
#define  VDCRSUM_NUM_MTC    7
#define  VDCRSUM_SEL_MTC   \
    "table_cat,table_subcat,table_index,sum_attr,sum_rel,sum_val,sum_exp"

/*    attribute driven symbols tables   */

#define  VDADSYM_NAM_TAB   "ope_ads_table"

#define  VDADSYM_NUM_TAB    4
#define  VDADSYM_SEL_TAB   "timestamp_0,userid_0,table_desc,lc_unit"

#define  VDADSYM_NUM_IDX    2
#define  VDADSYM_SEL_IDX   "table_name,table_desc"

#define  VDADSYM_NAM_REC   "ope_ads_rec"
#define  VDADSYM_NUM_REC    13
#define  VDADSYM_SEL_REC   \
    "ads_symbol,ads_attnam,ads_dattyp,ads_rel,ads_dattval,ads_cattval,ads_side,ads_offset,ads_chhgt,ads_chwdt,ads_chspc,ads_chwgt,ads_font"

/*    expression criteria tables    */
#define  VDCREXP_NAM_TAB   "ope_expr_table"
 
#define  VDCREXP_NUM_TAB    3
#define  VDCREXP_SEL_TAB   "timestamp_0,userid_0,expr_desc"

#define  VDCREXP_NUM_IDX    3
#define  VDCREXP_SEL_IDX   "expr_type,table_name,expr_desc"

#define  VDCREXP_NAM_DAT   "ope_data_table"
#define  VDCREXP_NUM_DAT    4
#define  VDCREXP_SEL_DAT   "table_name,data_group,data_seqn,data_info"

#define  VDCREXP_SEL_GRP   "data_group"
#define  VDCREXP_GRP_VAL   "expr"

#endif

