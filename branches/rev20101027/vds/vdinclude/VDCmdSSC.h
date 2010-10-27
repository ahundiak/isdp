
/* $Id: VDCmdSSC.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdinclude/VDCmdSSC.h
 *
 * Description:
 *
 *      include file to define SSC Command gadgets
 *       (drawing layout sort/summarization edit commands)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdSSC.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.5  1998/03/31  02:22:22  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by mdong for vds
 *
 * Revision 1.4  1998/03/31  01:19:04  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by mdong for vds
 *
 * Revision 1.3  1998/01/23  16:29:04  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by mdong for vds
 *
 * Revision 1.2  1997/11/11  02:42:46  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.6  1996/03/06  15:40:42  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by yzhu for vds.240
 *
 * Revision 1.5  1995/09/22  13:52:54  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by hverstee for vds.240
 *
 * Revision 1.4  1995/08/29  20:22:44  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by hverstee for vds.240
 *
 * Revision 1.3  1995/08/15  23:38:08  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/08/04  00:38:32  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h for:  by hverstee for vds.240
 *
 * Revision 1.1  1995/06/07  21:13:26  pinnacle
 * Created: vdinclude/VDCmdSSC.h by tdumbach for vds.240
 *
 * Revision 1.2  1995/05/24  14:45:38  pinnacle
 * Replaced: vdinclude/VDCmdSSC.h by hverstee r#
 *
 * Revision 1.1  1995/04/29  16:31:36  pinnacle
 * Created: vdinclude/VDCmdSSC.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

#ifndef  VDCmdSSC_h

#define  VDCmdSSC_h

/*       error messages             */

#define VD_SSC_EMSG_MEM    "Memory allocation error, terminated"
#define VD_SSC_EMSG_INV    "Invalid input"
#define VD_SSC_EMSG_QTE    "Invalid character in id-field"
#define VD_SSC_EMSG_CAT    "Invalid category <%s>"
#define VD_SSC_EMSG_SUB    "Set Category before subcategory"
#define VD_SSC_EMSG_PAR    "Parameter out of range"
#define VD_SSC_EMSG_NSV    "Invalid entry found, not saved"
#define VD_SSC_EMSG_CRE    " - Created"
#define VD_SSC_EMSG_NTAB   "Define table name first"

#define VD_CRSRT_EMSG_NSYM "Sort Criterion <%s> does not exist"
#define VD_CRSRT_EMSG_NCPY "Sort Criterion <%s> copied to <%s>"
#define VD_CRSRT_EMSG_NACT "Sort Criterion active, save or reset first"

#define VD_CRSUM_EMSG_NSYM "Summarization Criterion <%s> does not exist"
#define VD_CRSUM_EMSG_NCPY "Summarization Criterion <%s> copied to <%s>"
#define VD_CRSUM_EMSG_NACT "Summarization Criterion active, save or reset first"
#define VD_CRSUM_EMSG_NDEL "Last Match attribute, use delete cat/subcat"

#define VD_CREXP_EMSG_NSYM "Expression <%s> does not exist"
#define VD_CREXP_EMSG_NCPY "Expression <%s> overwrites <%s>"
#define VD_CREXP_EMSG_NAPP "Expression <%s> appended to <%s>"
#define VD_CREXP_EMSG_NACT "Expression active, save or reset first"
#define VD_CREXP_EMSG_NKIN "Define expression name first"
#define VD_CREXP_EMSG_TKIN "Define expression type first"
#define VD_CREXP_EMSG_NNAM "No corresponding expression names exist"
#define VD_CREXP_EMSG_KFIL "Key in a file name for writing first"
#define VD_CREXP_EMSG_NLDB "Please login to database first"
#define VD_CREXP_EMSG_WNDB "Warning: User Not Logged into the Database"
#define VD_CREXP_EMSG_STAB "Please select a table name first"
#define VD_CREXP_EMSG_NTAB "Table is not found"
#define VD_CREXP_EMSG_NPAR "Parameter does not exist"
#define VD_CREXP_EMSG_NCOL "Table column does not exist"

/*       form numbers                                     */

#define VD_SSC_SORTFORM            0
#define VD_SSC_SUMMFORM            1
#define VD_SSC_EXPRFORM            2

/*       command types                                     */

#define VD_CMD_SRT_EDIT          0
#define VD_CMD_SUM_EDIT          1
#define VD_CMD_SRT_REV           2
#define VD_CMD_SUM_REV           3
#define VD_CMD_EXP_EDIT		 4
#define VD_CMD_EXP_REV		 5

/*       stringlengths etc                 */

#define VD_CRSUM_STL_COMPAR        6
#define VD_CRSUM_STL_CAT          30

#define VD_CRSUM_NUM_COMPAR        6

/* --------------------------------------------------------- */
/*       Gadgets for VDCSS_sort form                         */
/* --------------------------------------------------------- */

#define VD_CRSRT_FORM_NAME         "VDCSS_sort"

#define VD_CRSRT_FLD_MSG             9
#define VD_CRSRT_FLD_TABNAM        131
#define VD_CRSRT_FLD_COPY           41
#define VD_CRSRT_FLD_DESCR          21
#define VD_CRSRT_FLD_SEQNO          68
#define VD_CRSRT_FLD_ATTR           86
#define VD_CRSRT_FLD_TIMEST         24
#define VD_CRSRT_FLD_USERID         16
#define VD_CRSRT_FLD_LOCAL          26

#define VD_CRSRT_BTN_UP             84
#define VD_CRSRT_BTN_DOWN           82
#define VD_CRSRT_BTN_INSERT         37
#define VD_CRSRT_BTN_DELETE         11

#define VD_CRSRT_TGG_SEQ            13
#define VD_CRSRT_TGG_TYP            12

#define VD_CRSRT_TXT_REVTITLE       17
#define VD_CRSRT_TXT_EDTITLE        33
#define VD_CRSRT_TXT_COPY           38

#define VD_CRSRT_FLD_REVSEQ         18
#define VD_CRSRT_FLD_REVTYP         19

/* --------------------------------------------------------- */
/*       Gadgets for VDCSS_summ form                         */
/* --------------------------------------------------------- */

#define VD_CRSUM_FORM_NAME         "VDCSS_summ"

#define VD_CRSUM_FLD_MSG             9
#define VD_CRSUM_FLD_TABNAM        131
#define VD_CRSUM_FLD_COPY           41
#define VD_CRSUM_FLD_DESCR          21
#define VD_CRSUM_FLD_CAT            12
#define VD_CRSUM_FLD_SUBCAT         14
#define VD_CRSUM_FLD_TIMEST         24
#define VD_CRSUM_FLD_USERID         16
#define VD_CRSUM_FLD_LOCAL          26

#define VD_CRSUM_GDG_GROUP          32

#define VD_CRSUM_TGG_QTYP           13
#define VD_CRSUM_TGG_ATYP           19

#define VD_CRSUM_FLD_QEXP           86
#define VD_CRSUM_FLD_MSEQ           68
#define VD_CRSUM_FLD_MATT           30
#define VD_CRSUM_FLD_MREL           25
#define VD_CRSUM_FLD_MEXP           28

#define VD_CRSUM_BTN_UP             84
#define VD_CRSUM_BTN_DOWN           82
#define VD_CRSUM_BTN_INSERT         37
#define VD_CRSUM_BTN_DELETE         11
#define VD_CRSUM_BTN_DELCAT         34

#define VD_CRSUM_TXT_QEXP           45

#define VD_CRSUM_TXT_REVTITLE       35
#define VD_CRSUM_TXT_EDTITLE        33
#define VD_CRSUM_TXT_COPY           38

#define VD_CRSUM_FLD_QTYP           40
#define VD_CRSUM_FLD_ATYP           42

#define VD_CRSUM_FLD_MREL_REW       43

/* --------------------------------------------------------- */
/*       Gadgets for VDCSS_expr form                         */
/* --------------------------------------------------------- */

#define VD_CREXP_FORM_NAME         "VDCSS_expr"

#define VD_CREXP_FLD_MSG            10
#define VD_CREXP_FLD_EXPTYPE        18
#define VD_CREXP_FLD_EXPNAM        131
#define VD_CREXP_FLD_COPY           41
#define VD_CREXP_FLD_DESCR          21
#define VD_CREXP_FLD_CAT            13
#define VD_CREXP_FLD_FUNC           31
#define VD_CREXP_FLD_TIMEST         24
#define VD_CREXP_FLD_USERID         16
#define VD_CREXP_FLD_LOCAL          26
#define VD_CREXP_FLD_PROG           86
#define VD_CREXP_FLD_PARA           30
#define VD_CREXP_FLD_TABNAM         29
#define VD_CREXP_FLD_TABCOL         28
#define VD_CREXP_FLD_TABSEL         40
#define VD_CREXP_FLD_COLSEL         42
#define VD_CREXP_FLD_FILNAM         35

#define VD_CREXP_BTN_OBJECT         25
#define VD_CREXP_BTN_TEST           27
#define VD_CREXP_BTN_WRITE          37
#define VD_CREXP_BTN_TABNAM         34
#define VD_CREXP_BTN_TABCOL         32
#define VD_CREXP_BTN_RESET          45
#define VD_CREXP_BTN_PARSE          44

#define VD_CREXP_TGG_CPYTYP	    19
#define VD_CREXP_TGG_OUTTYP         23
#define VD_CREXP_TGG_INSTYP         46

#define VD_CREXP_TXT_EDTITLE        33
#define VD_CREXP_TXT_REVTITLE       43
#define VD_CREXP_TXT_COPY           38
#define VD_CREXP_TXT_FUNC           14

#endif

