
/* $Id: VDdrwlo.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/VDdrwlo.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.6  1998/03/31  02:44:26  pinnacle
 * Replaced: include/VDdrwlo.h for:  by mdong for vds
 *
 * Revision 1.5  1997/12/02  08:26:24  pinnacle
 * Replaced: include/VDdrwlo.h for:  by vgnair for vds
 *
 * Revision 1.3  1997/11/24  14:55:28  pinnacle
 * Replaced: include/VDdrwlo.h for:  by mdong for vds
 *
 * Revision 1.2  1997/10/21  03:41:02  pinnacle
 * Replaced: include/VDdrwlo.h for:  by ksundar for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
# Revision 1.8  1996/04/12  19:25:46  pinnacle
# Replaced: include/VDdrwlo.h for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/25  23:18:20  pinnacle
# Replaced: include/VDdrwlo.h for:  by sundar for vds.240
#
# Revision 1.6  1995/09/18  21:23:58  pinnacle
# Replaced: include/VDdrwlo.h for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/08  19:20:08  pinnacle
# Replaced: include/VDdrwlo.h for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/11  19:06:20  pinnacle
# Replaced: include/VDdrwlo.h for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:32:36  pinnacle
# Replaced: include/VDdrwlo.h for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:15:58  pinnacle
# Replaced: include/VDdrwlo.h for:  by hverstee for vds.240
#
 * Revision 1.5  1995/05/24  14:46:20  pinnacle
 * Replaced: include/VDdrwlo.h by hverstee r#
 *
 * Revision 1.4  1995/05/15  21:59:38  pinnacle
 * Replaced: include/VDdrwlo.h by rmanem r#
 *
 * Revision 1.3  1995/04/25  21:16:08  pinnacle
 * Replaced: include/VDdrwlo.h by hverstee r#
 *
 * Revision 1.1  1995/04/18  21:28:40  pinnacle
 * Created: include/VDdrwlo*.h by tdumbach r#
 * rno
 *
 * Revision 1.5  1995/04/11  14:45:10  pinnacle
 * Replaced: include/VDdrwlo.h by hverstee r#
 *
 * Revision 1.4  1995/03/25  15:28:30  pinnacle
 * Replaced: include/VDdrwlo.h by hverstee r#
 *
 * Revision 1.3  1995/03/13  23:06:34  pinnacle
 * Replaced: include/VDdrwlo.h by hverstee r#
 *
 * Revision 1.2  1995/03/08  15:07:36  pinnacle
 * Replaced: include/VDdrwlo.h by hverstee r#
 *
 * Revision 1.1  1995/03/03  20:56:20  pinnacle
 * Created: include/VDdrwlo.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            include file to define DRWlo constants
 *                                       and communication record layouts
 *	05/15/95	R. Manem	Added VDdrwlo_qtyExp structure
 *
 *	13/10/97	Sundar		Added VDdrwexp_tab & VDdrwexp_data
 *					structures
 * 	11/27/97	vini		added cell and library
 * -------------------------------------------------------------------*/

#include "parametric.h"

#ifndef  VDdrwlo_h

#define  VDdrwlo_h

#define VD_DRWLO_NODB_MSG  "Database does not support OPE tables"

/*       PUBLIC   interface                                          */

#define VD_DRWLO_CHR_IDFLD         13
#define VD_DRWLO_CHR_DESC          80
#define VD_DRWLO_CHR_TEXT         250
#define VD_DRWLO_CHR_TSTP          30
#define VD_DRWLO_CHR_ATTRNAM       24
#define VD_DRWLO_CHR_BUFFER       260      /*   max input buffer size.   */

#define VD_DRWLO_TXT_DEFFONT       "default"

#define VD_DRWLO_EN_ALL            -1

#define VD_DRWLO_EN_DESCEND         0
#define VD_DRWLO_EN_ASCEND          1

#define VD_DRWLO_EN_DATA            0
#define VD_DRWLO_EN_HEADER          1
#define VD_DRWLO_EN_TRAILER         2
#define VD_DRWLO_EN_BRKHDR          3
#define VD_DRWLO_EN_BRKTRLR         4

#define VD_DRWLO_EN_ASCII           0
#define VD_DRWLO_EN_NUMERIC         1

#define VD_DRWLO_EN_LEFT            0
#define VD_DRWLO_EN_RIGHT           1

#define VD_DRWLO_EN_COUNT           0
#define VD_DRWLO_EN_EXPRESS         1

#define VD_DRWLO_EN_TEXT            0
#define VD_DRWLO_EN_ATTRIBUTE       1
#define VD_DRWLO_EN_EXPRESSION      2
#define VD_DRWLO_EN_USERDEFINED     3
#define VD_DRWLO_EN_OVERFLOW        4
#define VD_DRWLO_EN_FORMTEXT        5
#define VD_DRWLO_EN_ITEMNO          6
#define VD_DRWLO_EN_QUANTITY        7
#define VD_DRWLO_EN_EXPR_TABLE      8

#define VD_DRWLO_EN_CELL            9
#define VD_DRWLO_EN_SYMBOL          10


#define VD_DRWLO_EN_AUTOWRAP      100
#define VD_DRWLO_EN_LINE          101

/*
**       Expression   interface
*/

#define VD_DRWEXP_PROG_RWFLD        62
#define VD_DRWEXP_CHR_NAME          21
#define VD_DRWEXP_PARA_NAME         31
#define VD_DRWEXP_EN_APPEND         0
#define VD_DRWEXP_EN_OVERWRITE      1
#define VD_DRWEXP_EN_ASCII          0
#define VD_DRWEXP_EN_NUMERIC        1
#define VD_DRWEXP_EN_INSERT         1

/* For expression table begin*/
#define VD_CREXP_CHR_TYPE  13
#define VD_CREXP_CHR_NAME  13
#define VD_CREXP_CHR_STAMP 25
#define VD_CREXP_CHR_IDFLD 13
#define VD_CREXP_CHR_DESC  81
 
#define VD_CREXP_CHR_INFO  241
#define VD_CREXP_CHR_GRP  5
/* For expression table end*/


/*    (maybe some additional types)     */

/* ----------------------------------------------------------------------- */

/*   PUBLIC   communications structures for Expression Table Begin        */

struct   VDdrwexp_tab      {
  IGRchar      Tabtyp[VD_CREXP_CHR_TYPE];      /* Expression type      */
  IGRchar      Tabnam[VD_CREXP_CHR_NAME];      /* Expression name      */
  IGRchar      Timest[VD_CREXP_CHR_STAMP];     /* date last change     */
  IGRchar      Userid[VD_CREXP_CHR_IDFLD];     /* user id last change  */
  IGRchar      Shdesc[VD_CREXP_CHR_DESC];      /* short description    */
  IGRshort     data_type;                       /* data_type            */
 
  IGRshort     LcUnit;                          /* design file units    */
  IGRboolean   Local;                           /* changed local copy   */
};

struct   VDdrwexp_data    {
  IGRchar      Datnam[VD_CREXP_CHR_NAME];      /* Expression name      */
  IGRchar      Datgrp[VD_CREXP_CHR_GRP];      /* Expression group      */
  IGRshort     Datsegn;                         /* data_type            */
  IGRchar      Datinfo[VD_CREXP_CHR_INFO];     /* Expression Info      */
};

/*
**      Structure for storing expression function
*/
struct VDdrwexp_func
{
  IGRshort     catnum;
  IGRchar      expcat[VD_DRWEXP_CHR_NAME];
  IGRchar      expfnam[VD_DRWEXP_CHR_NAME];
  IGRchar      expfsym[VD_DRWEXP_CHR_NAME];
};

/*
**      Structure for sorting expression types and names
*/
struct   VDdrwexp_temp 
{
  IGRchar      Datstr[VD_CREXP_CHR_DESC];
};

/*   PUBLIC   communications structures for Expression Table End        */

/*   PUBLIC   communications structures         */

struct   VDdrwlo_tab      {
  IGRchar      Tabnam[VD_DRWLO_CHR_IDFLD];     /*    layout name           */
  IGRchar      Tabtyp[VD_DRWLO_CHR_IDFLD];     /*    layout type           */
  IGRchar      Timest[VD_DRWLO_CHR_TSTP];      /*    date last change      */
  IGRchar      Userid[VD_DRWLO_CHR_IDFLD];     /*    user id last change   */
  IGRchar      Shdesc[VD_DRWLO_CHR_DESC];      /*    short description     */
  IGRchar      SumFil[VD_DRWLO_CHR_IDFLD];     /*    summarization file    */
  IGRchar      SortFil[VD_DRWLO_CHR_IDFLD];    /*    sortkeys file         */
  IGRshort     direct;                         /*    direction             */
    /*   VD_DRWLO_EN_DESCEND/ASCEND                                        */
  IGRshort     LcUnit;                         /*    design file units     */
  IGRboolean   Local;                          /*    changed local copy    */
                          };

struct   VDdrwlo_sstab    {
  IGRchar      Tabnam[VD_DRWLO_CHR_IDFLD];     /*    sort/summ table name  */
  IGRchar      Timest[VD_DRWLO_CHR_TSTP];      /*    date last change      */
  IGRchar      Userid[VD_DRWLO_CHR_IDFLD];     /*    user id last change   */
  IGRchar      Shdesc[VD_DRWLO_CHR_DESC];      /*    short description     */
  IGRshort     LcUnit;                         /*    design file units     */
  IGRboolean   Local;                          /*    changed local copy    */
                          };

struct   VDdrwlo_extrec   {
  IGRshort     excol;       /*  column to extend         */
  IGRshort     exlin;       /*  number of extra lines    */
                          };

struct   VDdrwlo_line     {
  IGRdouble    x1;          /*  line x begin   */
  IGRdouble    y1;          /*  line y begin   */
  IGRdouble    x2;          /*  line x end     */
  IGRdouble    y2;          /*  line y end     */
                          };

struct   VDdrwlo_text    {
  IGRdouble    xcor;                       /*  textpoint x           */
  IGRdouble    ycor;                       /*  textpoint y           */
  IGRshort     colno;                      /*  column number         */
  IGRshort     lineno;                     /*  line number           */
  IGRshort     justif;                     /*  text justification    */
  IGRdouble    ch_wdt;                     /*  character width       */
  IGRdouble    ch_hgt;                     /*  character height      */
  IGRdouble    ch_spc;                     /*  character spacing     */
  IGRchar      font[VD_DRWLO_CHR_IDFLD];   /*  character font        */
  IGRshort     numchr;                     /*  number of characters  */
  IGRchar      Text[VD_DRWLO_CHR_TEXT];    /*  textstring            */
                          };

struct   VDdrwlo_apifix   {
  IGRshort            rectyp;              /* VD_DRWLO_EN_LINE/TEXT  */
  struct GRsymbology  symb;

  union    {
             struct   VDdrwlo_line     ln;
             struct   VDdrwlo_text     tx;
           } VD;
                          };

struct   VDdrwlo_data    {
  IGRshort     grptyp;                     /*  group type                 */
  /*  VD_DRWLO_EN_DATA/HEADER/TRAILER/BRKHDR/BRKTRLR                      */
  IGRshort     rectyp;                     /*  line (record)type          */
  /*  VD_DRWLO_EN_ATTRIBUTE/EXPRESSION/USERDEFINED/OVERFLOW/AUTOWRAP      */
  IGRshort     datatyp;                    /*  data type                  */
  /*  VD_DRWLO_EN_ASCII/NUMERIC                                           */
  IGRshort     colno;                      /*  column number     -or-     */
  IGRchar      fldid[VD_DRWLO_CHR_IDFLD];  /*  header fieldid             */
  IGRshort     lineno;                     /*  line number                */
  IGRdouble    xcor;                       /*  textpoint x                */
  IGRdouble    ycor;                       /*  textpoint y                */
  IGRshort     justif;                     /*  text justification         */
  IGRdouble    ch_wdt;                     /*  character width            */
  IGRdouble    ch_hgt;                     /*  character height           */
  IGRdouble    ch_spc;                     /*  character spacing          */
  IGRshort     numchr;                     /*  max number of characters   */
  IGRshort     decplace;                   /*  number of decimal places   */
  IGRchar      font[VD_DRWLO_CHR_IDFLD];   /*  character font        */
  IGRshort     weight;                     /*  character weight           */
  IGRchar      Text[VD_DRWLO_CHR_TEXT];    /*  default text string        */
  IGRchar      ExAtt[VD_DRWLO_CHR_DESC];   /*  expression/attribute name  */
                          };

struct   VDdrwlo_sort    {
  IGRshort     nsIndex;                    /*  sequence number            */
  IGRshort     nsSeq;                      /*  sort sequence              */
  /*  VD_DRWLO_EN_DESCEND/ASCEND                                          */
  IGRshort     nsTyp;                      /*  attribute type             */
  /*  VD_DRWLO_EN_ASCII/NUMERIC                                           */
  IGRchar      szAtt[VD_DRWLO_CHR_ATTRNAM];/*  attribute name             */
                          };

struct   VDdrwlo_sqty    {
  IGRchar      szCat[VD_DRWLO_CHR_IDFLD];  /*  category name              */
  IGRchar      szSub[VD_DRWLO_CHR_IDFLD];  /*  sub-category name          */
  IGRshort     nSflag;                     /*  type flag                  */
  /*  VD_DRWLO_EN_COUNT/EXPRESSION                                        */
  IGRchar      szExp[VD_DRWLO_CHR_DESC];   /*  expression                 */
                          };

struct   VDdrwlo_qtyExp   {
  IGRshort     nSflag;                     /*  type flag                  */
  /*  VD_DRWLO_EN_COUNT/EXPRESSION                                        */
  IGRchar      szExp[VD_DRWLO_CHR_DESC];   /*  expression                 */
                          };

struct   VDdrwlo_smatch   {
  IGRchar      szCat[VD_DRWLO_CHR_IDFLD];  /*  category name              */
  IGRchar      szSub[VD_DRWLO_CHR_IDFLD];  /*  sub-category name          */
  IGRshort     nsIndex;                    /*  sequence number            */
  IGRchar      szAtt[VD_DRWLO_CHR_ATTRNAM];/*  attribute name             */
  IGRshort     nnREL;                      /*  enumerated relation        */
  IGRshort     nDattyp;                    /*  datatype                   */
  /*  VD_DRWLO_EN_ASCII/NUMERIC                                           */
  IGRchar      szExp[VD_DRWLO_CHR_DESC];   /*  expression                 */
                          };

struct   VDadsym_rec      {
  IGRchar      Symbol[VD_DRWLO_CHR_IDFLD]; /*  symbol character string    */
  IGRchar      szAtt[VD_DRWLO_CHR_ATTRNAM];/*  attribute name             */
  IGRshort     nDattyp;                    /*  datatype                   */
  /*  VD_DRWLO_EN_ASCII/NUMERIC                                           */
  IGRshort     nnREL;                      /*  enumerated relation        */
  IGRdouble    dAttval;                    /*  attribute value if numeric */
  IGRchar      szAttval[VD_DRWLO_CHR_DESC];/*  attribute value if ASCII   */

  IGRshort     nnSide;                     /*  left/right side placement  */
  /*  VD_DRWLO_EN_LEFT/RIGHT                                              */
  IGRdouble    dOffset;                    /*  offsetvalue for place      */
  IGRdouble    dCharhgt;                   /*  character height           */
  IGRdouble    dCharwdt;                   /*  character width            */
  IGRdouble    dCharspc;                   /*  character spacing          */
  IGRshort     nCharwgt;                   /*  character weight           */
  IGRchar      font[VD_DRWLO_CHR_IDFLD];   /*  character font             */
                          };


/* --------------------- Calculation Macros ----------------------------- */

#define VDDLO_CHSP_INC_CHWD
#define VDDLO_LNSP_INC_LNHG

#define VDDLO_DB(nc)   ((IGRdouble)(nc))

/*    remove these defines to revert to the alternate algorithm
      set for spacing factor includes width/height!!!!!!!!            */

#ifdef VDDLO_CHSP_INC_CHWD

/*  character spacing  */
#define VD_DLO_M_CSP(fwd,cwd,nch) \
((fwd - cwd) / (VDDLO_DB(nch) * cwd))

/*  character width  */
#define VD_DLO_M_CWD(fwd,csp,nch) \
(fwd / (VDDLO_DB(nch) * csp + 1))

/*  number of characters  */
#define VD_DLO_M_NCH(fwd,cwd,csp) \
((int)( ((fwd - cwd) / (csp*cwd)) + .5))

/*  field width  */
#define VD_DLO_M_FWD(cwd,csp,nch) \
(VDDLO_DB(nch) * csp * cwd + cwd)

#else

/*  character spacing  */
#define VD_DLO_M_CSP(fwd,cwd,nch) \
((fwd - ((IGRdouble)nch) * cwd) / (((IGRdouble)(nch + 1)) *cwd))

/*  character width  */
#define VD_DLO_M_CWD(fwd,csp,nch) \
(fwd / ((IGRdouble)nch + ((IGRdouble)(nch + 1)) * csp))

/*  number of characters  */
#define VD_DLO_M_NCH(fwd,cwd,csp) \
((int)(((fwd - csp * cwd) / (cwd +csp*cwd)) + .5))

/*  field width  */
#define VD_DLO_M_FWD(cwd,csp,nch) \
((cwd * ((IGRdouble)nch) + ((IGRdouble)(nch + 1)) * csp * cwd))

#endif

#ifdef VDDLO_LNSP_INC_LNHG

/*  absolute distance between lines  */
#define VD_DLO_M_LCL(chg,lsp)  (chg * lsp)

/*  line spacing  */
#define VD_DLO_M_LSP(fhg,chg,nln) \
((fhg - chg) / (VDDLO_DB(nln) * chg))

/*  character height  */
#define VD_DLO_M_CHG(fhg,lsp,nln) \
(fhg / (VDDLO_DB(nln) * lsp + 1))

/*  number of lines  */
#define VD_DLO_M_NLN(fhg,chg,lsp) \
((int)( ((fhg - chg) / (lsp*chg)) + .5))

/*  field height  */
#define VD_DLO_M_FHG(chg,lsp,nln) \
(VDDLO_DB(nln) * lsp * chg + chg)

#else

/*  absolute distance between lines  */
#define VD_DLO_M_LCL (chg, lsp)  (chg * lsp + chg)

/*  line spacing  */
#define VD_DLO_M_LSP(fhg,chg,nln) \
((fhg - ((IGRdouble)nln) * chg) / (((IGRdouble)(nln + 1)) *chg))

/*  character height  */
#define VD_DLO_M_CHG(fhg,lsp,nln) \
(fhg / ((IGRdouble)nln + ((IGRdouble)(nln + 1)) * lsp))

/*  number of lines  */
#define VD_DLO_M_NLN(fhg,chg,lsp) \
((int)(((fhg - lsp * chg) / (chg +lsp*chg)) + .5))

/*  field height  */
#define VD_DLO_M_FHG(chg,lsp,nln) \
((chg * ((IGRdouble)nln) + ((IGRdouble)(nln + 1)) * lsp * chg))

#endif

#endif
