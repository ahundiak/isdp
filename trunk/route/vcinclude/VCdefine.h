
/* $Id: VCdefine.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCdefine.h
 *
 * Description:
 *
 *      Constants defined for VC cabling system
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCdefine.h,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.24  1997/07/25  18:11:00  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.23  1997/07/21  21:12:24  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.22  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.21  1997/05/19  12:58:52  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.20  1997/05/12  16:58:06  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.19  1997/05/10  15:11:58  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.18  1997/05/07  13:40:58  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.17  1997/05/02  16:58:08  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.16  1997/04/28  21:41:38  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.15  1997/03/25  16:21:00  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.14  1997/03/19  14:44:56  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.13  1997/03/14  18:17:34  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.12  1997/03/06  22:10:54  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.10  1997/03/05  14:39:02  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.9  1997/01/31  13:39:06  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.8  1997/01/30  20:10:32  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.7  1997/01/20  20:07:56  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.6  1997/01/17  21:54:02  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/01/03  14:07:54  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.4  1996/10/14  19:46:58  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.3  1996/09/18  20:27:52  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/08/29  22:15:26  pinnacle
 * Replaced: vcinclude/VCdefine.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:46:54  pinnacle
 * Created: vcinclude/VCdefine.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

/*     start with the public stuff     */

#include "vc_public.h"
#include "bsvalues.h"

#ifndef	VCdefine_include
#define VCdefine_include

/************************************************************************/
/***                 PRODUCT DEFINITION NAMES                         ***/
/************************************************************************/

#define  VC_PROD_NAME            "Cable"
#define  VC_PROD_LOGO            "I/CABLE"

/************************************************************************/
/****            ADDED CONSTANTS TE EXTEND REPRESENTATION           *****/
/*              Define here until route and vds are in step             */
/************************************************************************/

extern    IGRboolean   VC_test_pidact();
extern    IGRboolean   VC_test_2dact();

#define   VC_2D_REP_NAME          "$2D"
#define   VC_3D_REP_NAME          "$3D"
#define   VC_ENV_REP_NAME         "$ENV"
#define   VC_PID_REP_NAME         "$PID"

#define   VC_PID_REP     0x6     /* internal value */

#define   bVC_IS_PID(rep) (((rep)&AC_VDS_REP) == VC_PID_REP)
#define   bVC_IS_2D(rep)  \
((((rep)&AC_VDS_REP)==VC_PID_REP)||(((rep)&AC_VDS_REP)==AC_2D_REP))

#define   bVC_IS_PID_ACTIVE       VC_test_pidact()
#define   bVC_IS_2D_ACTIVE        VC_test_2dact()

/***********************************************************************/

/*    angle transformations                     */

#define  VC_RAD_DEG(rad)    (rad*180.0/M_PI)
#define  VC_DEG_RAD(deg)    (deg*M_PI/180.0)

/***********************************************************************/

/*    dummy name for a crossfile connector      */

#define  VC_REF_CONNECTOR         "*REFCON*"

/*    database table for PID macros             */

#define VC_PID_SYM_TAB      "PID_SYM_CODE"

/*    size of short int.......                  */

#define VC_MAX_SHORT  16348

/*    relation types            */

#define VCP_TYPE_NONE     0
#define VCP_TYPE_PARENT   1
#define VCP_TYPE_CHILD    2

#define VC_ERROR_SYMBOL         "?"

#define VC_REQ_ALL_CPT          ((IGRshort)(-1))

/***********************************************************************/
/*    general status bitwise flags     */

#define VC_STATUS_INIT      0x0000     /*General (no action) nullmask    */
#define VC_STATUS_RESET     0xff00     /*Reset high order recompute bits */

#define VC_ERROR            0x0001     /*  error status        */
#define VC_PID_ONLY         0x0002     /*  PID only component  */

#define VC_XFORM_ONLY       0x0004
#define VC_DUMB_DEL         0x0008

#define VCCB_BEGCONNECTED   0x0010
#define VCCB_ENDCONNECTED   0x0020

#define VC_CLONE            0x0040

#define VC_TRACED           0x0080

/*   (re)compute status for cables   */

#define VC_CB_SECTCOMPUTE   0x1000     /* recompute by sectionflags   */
#define VC_CB_FULLCOMPUTE   0x2000     /* recompute full cable         */
#define VC_CB_INITCOMPUTE   0x4000     /* initial compute full cable   */

/*   section status flags for cables */

#define VC_CBS_UPTODATE      0x0000     /* section recompute done       */
#define VC_CBS_STRCHG        0x0100     /* recompute string section     */
#define VC_CBS_PARCHG        0x0200     /* recompute for changed guide  */
#define VC_CBS_PARDEL        0x0400     /* recompute for deleted parent */
#define VC_CBS_PARADD        0x0800     /* recompute for added parent   */

/***********************************************************************/
/*    general type bitwise flags       */

#define VC_TYPE_INIT        0x0000     /*General (no action) nullmask  */

/*    0. General       */
#define VC_GEN_TERM         0x1000     /*  Terminal         */
#define VC_GEN_CABLE        0x2000     /*  Cable            */
#define VC_GEN_GUIDE        0x4000     /*  Guide            */
#define VC_GEN_BKSHLL       0x8000     /*  Backshell        */

#define VC_GEN_VIRTUAL      0x0001     /*  virtual entity                */
#define VC_GEN_BITERM       0x0002     /*  Builtin term                  */
#define VC_GEN_OWNED        0x0004     /*  owned (terminal in eq macro)  */
#define VC_GEN_EXTERN       0x0008     /*  externalized from VCembed     */

/*    1. Terminals     */
/*       Terminals parent settings  */
#define VC_TERM_CS          0x0010     /* placed on coordinate system     */
#define VC_TERM_NO          0x0020     /* No parent                       */
#define VC_TERM_EQ          0x0040     /* placed on equipment (VDS)       */
#define VC_TERM_RE          0x0080     /* placed on equipment (ROUTE PID) */

/*       Terminals offset algorithm values  specs     (can be more than one) */
#define VC_TOFF_COORDS      0x0100     /* offset coordinates                 */
#define VC_TOFF_C_ANG       0x0200     /* Plus angles                        */
#define VC_TOFF_C_VEC       0x0400     /* Plus vectors                       */
#define VC_TOFF_C_FULL      0x0800     /* Full matrix specified              */

/*    2. Cables (also in per_lead status)       */

#define VC_CAB_REGULAR      0x0100     /*  regular lead/cable         */
#define VC_CAB_SPARE        0x0200     /*  spare lead/cable           */
#define VC_CAB_REDUNDANT    0x0400     /*  redundant lead/cable       */
#define VC_CAB_SUB	    0x0800     /*  sub lead/cable	      */

/*               special for per-lead per-end   */

#define VC_CBE_OPEN         0x0010     /*   End open           */
#define VC_CBE_CONNECTED    0x0020     /*   End is connected   */
#define VC_CBE_PASSTHRU     0x0040     /*   End is passthru    */
#define VC_CBE_FROMMAIN	    0x0080     /*   Lead extends through sub-cable */

/*    3. Guides        */

#define VCGD_SPLINE         0x0010     /*   Spline guide       */
#define VCGD_STRING         0x0020     /*   linestring guide   */
#define VCGD_RWAY           0x0040     /*   raceway guide      */
#define VCGD_FIXED_XS       0x0100     /*   fixed crossection  */
#define VCGD_FREED_XS       0x0200     /*   free crossection   */
#define VCGD_SHAPE_ROUND    0x0400     /*   Non-DB shape force */
#define VCGD_SHAPE_SQUARE   0x0800     /*   Non-DB shape force */

/***********************************************************************/

/*    CPm status flags     */

#define VC_CPM_INACTIVE     0
#define VC_CPM_ACTIVE       1

/*      fiberoptic connector/splice selection   */

#define  VCFO_A_UNCHANGED       0
#define  VCFO_A_REMOVE          1
#define  VCFO_A_AUTOASSIGN      2
#define  VCFO_A_MANUAL          3

/*      fiberoptic connection types             */

#define  VCFO_T_NONE            0
#define  VCFO_T_CONNECT         1
#define  VCFO_T_SPLICE          2

/*     guide shapes               */

#define VCGD_SH_R_ST        "ROUND"
#define VCGD_SH_S_ST        "RECTANGULAR"

/*     transition find bitflags            */

#define VCTR_CON_CON       0x0001
#define VCTR_CON_PTHRU     0x0002
#define VCTR_CON_OPEN      0x0004

#define VCTR_TERM_THRU     0x0010
#define VCTR_TERM_FANOUT   0x0020
#define VCTR_TERM_FANIN    0x0040

/*     cable section control indicators    */

#define VCC_FREE_VERTEX         1   /* after detach point   */
#define VCC_FREE_GUIDE          2   /* after detach guide   */
#define VCC_FREE_RWAY           3   /* after detach raceway */

#define VCC_TERM_PARENT        11   /* Terminal parent at end  */
#define VCC_TERM_CHILD         12   /* Terminal child at end   */

#define VCC_POINT_PARENT       21   /* Intermediate point parent  */
#define VCC_GUIDE_PARENT       22   /* Guide parent at guide cpt0 */
#define VCC_RWAY_PARENT        23   /* Raceway entry              */
#define VCC_TERM_PULL          24   /* Dumb pull box              */

#define VCC_POINT_EXTERN       99   /* Intermediate point parent  */
                                    /* external to continue string*/

#define VCC_STRING             30   /* Regular cable string       */

#define VCC_BREAK_ON           51   /* Onpage break               */
#define VCC_BREAK_OFF          52   /* Offpage break              */

#define VCC_SPLIT_BEGIN        71   /* Sub cable split from parent
				       cable's start point */
#define VCC_SPLIT_END          72   /* Sub cable split from parent
				       cable's end point */

/*     cable section operation control indicators    */

#define VCCB_INS_VERTEX         0   /*  Insert vertex                */
#define VCCB_MOV_VERTEX         1   /*  Move vertex                  */
#define VCCB_DEL_VERTEX         2   /*  Delete vertex                */
#define VCCB_ORT_VERTEX         3   /*  Orthogonalize vertex         */
#define VCCB_MOV_SEGMENT        4   /*  Orthogonal move segment      */
#define VCCB_INS_BREAK          5   /*  Make two adjoining vertices  */
                                    /*  into a pair of breaks        */

/*     and special flags for adjusting offsets and connectpoints    */
/*     (communicate from CbFind to CbModify for move/delete vertex) */

#define VCCB_NO_ADJUST          0
#define VCCB_ADJUST_DYNCPT      1
#define VCCB_ADJUST_OFFSET      2
#define VCCB_DELETE_BREAK       3

/*     attribute collection indexes     */

#define    VC_SYSATT            0
#define    VC_USRATT            1

/*     vertex/segment positions         */

#define    VC_VSPOS_BEG         1
#define    VC_VSPOS_END         2
#define    VC_VSPOS_INT         0

#endif

