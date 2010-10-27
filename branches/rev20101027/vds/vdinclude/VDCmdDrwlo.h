
/* $Id: VDCmdDrwlo.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdDrwlo.h
 *
 * Description:
 *
 *      include file to define DRWlo Command gadgets
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDrwlo.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/02/11  22:17:04  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/07/30  20:06:10  pinnacle
 * (No comment)
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/12/02  08:24:26  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by vgnair for vds
 *
 * Revision 1.2  1997/11/24  14:54:44  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.13  1995/11/10  21:18:52  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.12  1995/09/22  13:52:00  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.11  1995/09/20  21:56:52  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.10  1995/09/08  19:24:42  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.9  1995/09/05  22:52:14  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.8  1995/08/29  20:22:22  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.7  1995/08/15  23:37:46  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.6  1995/08/11  19:13:46  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.5  1995/08/03  20:52:32  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.4  1995/07/06  14:55:42  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/06/19  19:39:52  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h for:  by hverstee for vds.240
 *
 * Revision 1.1  1995/06/07  21:13:02  pinnacle
 * Created: vdinclude/VDCmdDrwlo.h by tdumbach for vds.240
 *
 * Revision 1.3  1995/05/17  14:19:10  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h by hverstee r#
 *
 * Revision 1.2  1995/04/29  16:30:16  pinnacle
 * Replaced: vdinclude/VDCmdDrwlo.h by hverstee r#
 *
 * Revision 1.1  1995/04/13  13:48:46  pinnacle
 * Created: vdinclude/VDCmdDrwlo.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/15/95          HV            New
 *	12/02/97	  vini		Added cell
 *
 * -------------------------------------------------------------------*/

#ifndef  VDCmdDrwlo_h

#define  VDCmdDrwlo_h

#define VD_DLO_CELL_CONFIG_RELPATH "config/cell"

/*       error messages             */

#define VD_DLO_EMSG_MEM    "Memory allocation error, terminated"
#define VD_DLO_EMSG_INV    "Invalid input"
#define VD_DLO_EMSG_QTE    "Invalid character in id-field"
#define VD_DLO_EMSG_CRE    " - Created"
#define VD_DLO_EMSG_PAR    "Parameter out of range"
#define VD_DLO_EMSG_NCOL   "Define column layout first"
#define VD_DLO_EMSG_NTAB   "Define table name first"
#define VD_DLO_EMSG_NLAY   "Layout <%s> does not exist"
#define VD_DLO_EMSG_LCPY   "Layout <%s> copied to <%s>"
#define VD_DLO_EMSG_NFLD   "Fieldname <%s> does not exist"
#define VD_DLO_EMSG_FCPY   "Field <%1d:%s> copied to <%1d:%s>"
#define VD_DLO_EMSG_NTYP   "Type <%s> does not exist"
#define VD_DLO_EMSG_NACT   "Layout <%s> active, save or reset first"

#define VD_DLO_CMSG_MCOL   "CALC -- minimum column width  %f"
#define VD_DLO_CMSG_MROW   "CALC -- minimum row height %f"

#define VD_DLO_CMSG_NLIN   "CALC -- maximum number of lines %d"
#define VD_DLO_CMSG_LSPC   "CALC -- maximum linespacing %f"

#define VD_DLO_CMSG_NCHR   "CALC -- maximum number of characters %d"
#define VD_DLO_CMSG_CHGT   "CALC -- maximum character height %f"
#define VD_DLO_CMSG_CWDT   "CALC -- maximum character width %f"
#define VD_DLO_CMSG_CSPC   "CALC -- maximum character spacing %f"

#define VD_DLO_DSP_EMPTY   "NONE"

/*       form numbers                                     */

#define VD_DLO_MAINFORM             0
#define VD_DLO_FILLFORM             1
#define VD_RLO_MAINFORM             2
#define VD_RLO_FILLFORM             3

/*       form names                                        */

#define VDN_DLO_MAINFORM            "VDDlo_main"
#define VDN_DLO_FILLFORM            "VDDlo_fill"
#define VDN_RLO_MAINFORM            "VDDlo_rmain"
#define VDN_RLO_FILLFORM            "VDDlo_rfill"

/*       display codes (active state)                      */

#define VD_DLO_DSP_TAB              0
#define VD_DLO_DSP_COL              1
#define VD_DLO_DSP_HTF              2

/*       command types                                     */

#define VD_DLO_CMD_EDIT             0
#define VD_DLO_CMD_REVIEW           1

/*       special return codes                 */

#define VD_DLO_RETC_SUB          2111

/*       trick gadgets                        */

#define VD_DLO_GDG_ONOFF           33
#define VD_DLO_GDG_REPORT          15

/* --------------------------------------------------------- */
/*       Gadgets for VDDlo_main form                         */
/* --------------------------------------------------------- */

/*       Group numbers                                    */

#define VD_DLOM_GRP_BOTH           43
#define VD_DLOM_GRP_COL            59
#define VD_DLOM_GRP_HTF           165
#define VD_DLOM_GRP_COLNO          70
#define VD_DLOM_GRP_HTFNO          69

/*       Single gadgets - ungrouped header                */

#define VD_DLOM_FLD_MSG             9
#define VD_DLOM_FLD_USERID         16
#define VD_DLOM_FLD_DESCR          21
#define VD_DLOM_FLD_TIMEST         24
#define VD_DLOM_FLD_LOCAL          26
#define VD_DLOM_FLD_TABTYP         40
#define VD_DLOM_FLD_COPY           41
#define VD_DLOM_FLD_GREDIT         81
#define VD_DLOM_FLD_TABNAM        131
#define VD_DLOM_FLD_SUMM           27
#define VD_DLOM_FLD_SORT           34

#define VD_DLOM_TGG_DISPSEQ        17

#define VD_DLOM_BTN_SHOW           42
#define VD_DLOM_BTN_COPY           38

/*        Grouped gadgets - common group               */

#define VD_DLOB_FLD_NLINES        114
#define VD_DLOB_FLD_LINSPC         79
#define VD_DLOB_FLD_NUMCHR         85
#define VD_DLOB_FLD_CHRHGT        107
#define VD_DLOB_FLD_CHRSPC        108
#define VD_DLOB_FLD_CHRWDT        109

#define VD_DLOB_FLD_BLST           52
#define VD_DLOB_FLD_BLSB           56
#define VD_DLOB_FLD_BLSL           90
#define VD_DLOB_FLD_BLSR          100

#define VD_DLOB_FLD_BLWT           55
#define VD_DLOB_FLD_BLWB           77
#define VD_DLOB_FLD_BLWL           99
#define VD_DLOB_FLD_BLWR           35

#define VD_DLOB_BTN_C_NLIN         46
#define VD_DLOB_BTN_C_LINSPC       97
#define VD_DLOB_BTN_C_NCHR        101
#define VD_DLOB_BTN_C_CHRWDT      110
#define VD_DLOB_BTN_C_CHRHGT      111
#define VD_DLOB_BTN_C_CHRSPC      112

#define VD_DLOB_BTN_FILL           18
#define VD_DLOB_BTN_DEFAULT       130

#define VD_DLOB_CKL_BL_TR          23
#define VD_DLOB_CKL_TL_BR          47

/*        Grouped gadgets - data column group             */

#define VD_DLOC_TXT_COLWDT         44
#define VD_DLOC_TXT_COLHGT         45

#define VD_DLOC_FLD_COLNUM         68
#define VD_DLOC_FLD_COLWDT         86
#define VD_DLOC_FLD_COLHGT         50

#define VD_DLOC_BTN_DELCOL         11
#define VD_DLOC_BTN_INSCOL         37
#define VD_DLOC_BTN_COLDN          82
#define VD_DLOC_BTN_COLUP          84

#define VD_DLOC_BTN_C_COLHGT       98
#define VD_DLOC_BTN_C_COLWDT      103

/*        Grouped gadgets - header/trailer group            */

#define VD_DLOH_FLD_FLDID          14
#define VD_DLOH_FLD_COPY          147
#define VD_DLOH_FLD_OFFSET        148
#define VD_DLOH_FLD_FLDWDT        124
#define VD_DLOH_FLD_FLDHGT         51
#define VD_DLOH_FLD_ALGMOD         65

#define VD_DLOH_FLD_ALGT          161
#define VD_DLOH_FLD_ALGB          162
#define VD_DLOH_FLD_ALGL          157
#define VD_DLOH_FLD_ALGR          158

#define VD_DLOH_BTN_DELFLD        164
#define VD_DLOH_BTN_DELALG         63
#define VD_DLOH_BTN_COPY           71

#define VD_DLOH_TXT_ALGMOD         66
#define VD_DLOH_TXT_ALGADD         64

#define VD_DLOH_TXT_ALGT          159
#define VD_DLOH_TXT_ALGB          160
#define VD_DLOH_TXT_ALGL          155
#define VD_DLOH_TXT_ALGR          156

/* --------------------------------------------------------- */
/*       Gadgets for VDDlo_fill form                         */
/* --------------------------------------------------------- */

#define VD_DLOF_FLD_MSG             9
#define VD_DLOF_FLD_MAXCHAR        14
#define VD_DLOF_FLD_FONT           18
#define VD_DLOF_FLD_WEIGHT         20
#define VD_DLOF_FLD_EXPATT        170
#define VD_DLOF_FLD_TEXT          171
#define VD_DLOF_FLD_LINENO        175
#define VD_DLOF_FLD_FILL          178
#define VD_DLOF_FLD_DTYPE         179
#define VD_DLOF_FLD_JUST          183
#define VD_DLOF_FLD_DEC           184
#define VD_DLOF_FLD_EXTYP         23
#define VD_DLOF_FLD_EXNAM         22
#define VD_DLOF_FLD_EXPRESS       26

#define VD_DLOF_FLD_LIBRY         27
#define VD_DLOF_FLD_CELLS         29

#define VD_DLOF_TXT_ATTRID        166
#define VD_DLOF_TXT_FIELDID       165
#define VD_DLOF_TXT_EXPID         169
#define VD_DLOF_TXT_DISTXT        167
#define VD_DLOF_TXT_DEFTXT        168
#define VD_DLOF_TXT_EXPRESS        17
#define VD_DLOF_TXT_DEC           180
#define VD_DLOF_TXT_DTYPE         181
#define VD_DLOF_TXT_PARLIST        11
#define VD_DLOF_TXT_FMTSTR         12
#define VD_DLOF_TXT_EXTYP         24
#define VD_DLOF_TXT_EXNAM         25
#define VD_DLOF_TXT_CELLS         30

#define VD_DLOF_BTN_DN            174
#define VD_DLOF_BTN_UP            176
#define VD_DLOF_BTN_DEFAULT        21

/* --------------------------------------------------------- */
/*       Gadgets for VDDlo_rmain form                        */
/* --------------------------------------------------------- */

/*       Group numbers                                    */

#define VD_RLOM_GRP_BOTH           43
#define VD_RLOM_GRP_COL            59
#define VD_RLOM_GRP_HTF           165

/*       Single gadgets - ungrouped header                */

#define VD_RLOM_FLD_TABNAM        131
#define VD_RLOM_FLD_TABTYP         40
#define VD_RLOM_FLD_USERID         16
#define VD_RLOM_FLD_TIMEST         24
#define VD_RLOM_FLD_SUMM           27
#define VD_RLOM_FLD_SORT           34
#define VD_RLOM_FLD_DESCR          21
#define VD_RLOM_FLD_LOCAL          26
#define VD_RLOM_FLD_DISPSEQ        17
#define VD_RLOM_FLD_GREDIT         81
#define VD_RLOM_FLD_MSG             9

#define VD_RLOM_BTN_SHOW           42

/*        Grouped gadgets - common group               */

#define VD_RLOB_FLD_NLINES        114
#define VD_RLOB_FLD_LINSPC         79
#define VD_RLOB_FLD_NUMCHR         85
#define VD_RLOB_FLD_CHRHGT        107
#define VD_RLOB_FLD_CHRSPC        108
#define VD_RLOB_FLD_CHRWDT        109

#define VD_RLOB_FLD_BLST           52
#define VD_RLOB_FLD_BLSB           56
#define VD_RLOB_FLD_BLSL           90
#define VD_RLOB_FLD_BLSR          100

#define VD_RLOB_FLD_BLWT           55
#define VD_RLOB_FLD_BLWB           77
#define VD_RLOB_FLD_BLWL           99
#define VD_RLOB_FLD_BLWR           35

#define VD_RLOB_BTN_FILL           18

#define VD_RLOB_CKL_BL_TR          23
#define VD_RLOB_CKL_TL_BR          47

/*        Grouped gadgets - data column group             */

#define VD_RLOC_FLD_COLNUM         68
#define VD_RLOC_FLD_COLWDT         86
#define VD_RLOC_FLD_COLHGT         50

#define VD_RLOC_BTN_COLDN          82
#define VD_RLOC_BTN_COLUP          84

/*        Grouped gadgets - header/trailer group            */

#define VD_RLOH_FLD_FLDID          14
#define VD_RLOH_FLD_OFFSET        148
#define VD_RLOH_FLD_FLDWDT        124
#define VD_RLOH_FLD_FLDHGT         51

#define VD_RLOH_FLD_ALGT          161
#define VD_RLOH_FLD_ALGB          162
#define VD_RLOH_FLD_ALGL          157
#define VD_RLOH_FLD_ALGR          158

/* --------------------------------------------------------- */
/*       Gadgets for VDDlo_rfill form                        */
/* --------------------------------------------------------- */

#define VD_RLOF_FLD_MSG             9
#define VD_RLOF_FLD_MAXCHAR        14
#define VD_RLOF_FLD_EXPATT        170
#define VD_RLOF_FLD_TEXT          171
#define VD_RLOF_FLD_LINENUM       175
#define VD_RLOF_FLD_FILL          178
#define VD_RLOF_FLD_DTYPE         179
#define VD_RLOF_FLD_JUST          183
#define VD_RLOF_FLD_DEC           184
#define VD_RLOF_FLD_FONT           18
#define VD_RLOF_FLD_WEIGHT         20
#define VD_RLOF_FLD_EXTYP         23
#define VD_RLOF_FLD_EXNAM         22


#define VD_RLOF_TXT_EXPRESS        17
#define VD_RLOF_TXT_DISTXT        167
#define VD_RLOF_TXT_DEFTXT        168
#define VD_RLOF_TXT_ATTRID        166
#define VD_RLOF_TXT_FIELDID       165
#define VD_RLOF_TXT_EXPID         169
#define VD_RLOF_TXT_DEC           180
#define VD_RLOF_TXT_DTYPE         181
#define VD_RLOF_TXT_PARLIST        11
#define VD_RLOF_TXT_FMTSTR         12
#define VD_RLOF_TXT_EXTYP         24
#define VD_RLOF_TXT_EXNAM         25

#define VD_RLOF_BTN_DN            174
#define VD_RLOF_BTN_UP            176

#endif

