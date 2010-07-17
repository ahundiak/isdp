
/* $Id: vc_define.h,v 1.3 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        include/vc_define.h
 *
 * Description:
 *
 *      Public Constants defined for VC cabling system
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vc_define.h,v $
 *      Revision 1.3  2002/05/08 15:48:22  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.2  2002/04/09 20:36:41  louis
 *      TR5649-standardize tolerance
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:09  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/09/11  23:01:46  pinnacle
 * Replaced: include/vc_define.h for:  by apazhani for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/11/30  16:24:14  pinnacle
 * Replaced: include/vc_define.h for:  by r250_int for route
 *
 * Revision 1.7  1997/11/14  23:21:50  pinnacle
 * Replaced: include/vc_define.h for:  by onayragu for cabling
 *
 * Revision 1.6  1997/08/11  21:11:26  pinnacle
 * Replaced: include/vc_define.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/07/21  19:37:14  pinnacle
 * Replaced: include/vc_define.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/07/14  21:05:02  pinnacle
 * Replaced: include/vc_define.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/03/28  20:38:18  pinnacle
 * Replaced: include/vc_define.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/03/19  14:34:06  pinnacle
 * Replaced: include/vc_define.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/03/14  16:50:54  pinnacle
 * Created: include/vc_define.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *      09/11/98    Alwin       Increased the size of the Tag Number to 55
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

/*   MAKE SURE PRODUCT NUMBERS ARE THE SAME    */

#include  "vrdef.h"
#include "VRMath.h"

#ifndef	vc_define_include
#define vc_define_include

#define  VC_EQUAL(d1,d2)   ((fabs(d1-d2))<=(fabs(d1*VRGetTol(VR_DIST_TOL))))
/*    defined lengths of character fields       */

#define VC_MAX_CCODE     21     /* chars in compcode              */

/* Changed as per Clark's Request. CR179801070. Increasing the Tag Number
size from 21 -> 55. Alwin */
#define VC_MAX_TAGNO     55     /* chars in tag number            */

#define VC_MAX_CATAL     21     /* chars in catalog number        */
#define VC_MAX_STOCK     21     /* chars in stock number          */

#define VC_MAX_EQ_ID     21     /* chars in equipment id          */
#define VC_MAX_ID        13     /* chars in terminal/cable id     */
#define VC_MAX_SIG_ID    13     /* chars in signal id             */
#define VC_MAX_MARK_ID   22     /* chars in marker attribute      */
#define VC_MAX_FUT1_ID	 128	/* chars in a future attribute 1  */
#define VC_MAX_FUT2_ID	 128	/* chars in a future attribute 2  */
#define VC_MAX_FUT3_ID	 128	/* chars in a future attribute 3  */
#define VC_MAX_FUT4_ID	 128	/* chars in a future attribute 4  */

#define VC_MAX_SDESC     41     /* chars in short description     */
#define VC_MAX_LDESC    241     /* chars in long description      */
#define VC_MAX_MISC      33     /* chars in miscellaneous fields  */
#define VC_MAX_TIMEST    30     /* chars in timestamp             */
#define VC_MAX_NOTES     81     /* chars in component notes       */
#define VC_MAX_TUBEC      5     /* characters in tubecode         */

/*   for internal topology      */

#define VC_MAX_MOD_ID    13     /* chars in connector module id   */
#define VC_MAX_POS_ID    13     /* chars in connector position id */
#define VC_MAX_LEAD_ID   13     /* chars in cable lead id         */

/*    product types             */

#define VC_PROD_NONE      -1
#define VC_PROD_ELEC      VR_ELECTRIC
#define VC_PROD_FO        VR_FIBER

/*    interaction/communication  types   */

#define VC_UNKNOWN        0
#define VC_TERM_TYPE      1
#define VC_CABLE_TYPE     2
#define VC_GUIDE_TYPE     3
#define VC_BKSH_TYPE      4
#define VC_THROUGH_TYPE   5

/***********************************************************************/
/*       Terminal module topology types                                   */

#define VC_TOPO_TRG         1     /* regular terminal                */
#define VC_TOPO_TIC         2     /* interconnect (paired pos)       */
#define VC_TOPO_TST         3     /* star topology                   */
#define VC_TOPO_CAB         4     /* cable type                      */

#define VC_TOPO_CBC         6     /* cable end connected             */
#define VC_TOPO_CBO         7     /* cable end open                  */
#define VC_TOPO_CBP         8     /* cable end passthru              */

#define VC_TOPO_TDUP       10     /* duplicate from previous         */

/*      types                                   */

#define  VCFO_T_NONE            0
#define  VCFO_T_CONNECT         1
#define  VCFO_T_SPLICE          2

/*     for trace table, relation to previous item               */
/*     internal connection type indicators                      */
/*     returned bu GetThru methods                              */

#define VCO_CAB_CON             1   /* cable lead to term position       */
#define VCO_CON_CAB             2   /* term position to cable lead       */
#define VCO_CON_CON             3   /* internal connectivity between pos */
                                    /*   (defined by DB, single thru)    */
#define VCO_CAB_CAB             4   /* regular cable, end to end         */
#define VCO_CON_MCON            5   /* internal connectivity between pos */
                                    /*   (defined by DB, fanout)         */
#define VCO_MCON_CON            6   /* internal connectivity between pos */
                                    /*   (defined by DB, fanin)          */
#define VCO_PASS                7   /* passthrough lead                  */
#define VCO_IN_WIRE             8   /* Internally wired pos              */
                                    /*   (defined by input)              */

/*     trace table management                                   */

#define VCO_BRANCHED           88   /* branched from somewhere else      */
#define VCO_SEPARATE           99   /* Separator for branched traces     */

/*     parameter types                             */

#define VCPT_INTERNAL           1
#define VCPT_SYSTEM             2
#define VCPT_USER               3
#define VCPT_DB                 4
#define VCPT_UNDEFINED          5

/*     make arrays of characterpointers easier     */

typedef  IGRchar  *   CHARPTR;

/*     unified string initialization/test          */

#define  VC_INITSTR(str)       (str[0]='\0')
#define  VC_EMPTYSTR(str)      ((str==NULL)||(str[0]=='\0'))

/*     and FP equality      (close enough)         */

extern double fabs();

/* Tag manager defined values	*/

#define VCTAG_CAT_GENERAL_STR    "General"
#define VCTAG_CAT_ELTERM_STR     "Elec. Term."
#define VCTAG_CAT_FOTERM_STR     "Fiber Term."
#define VCTAG_CAT_ELCABLE_STR    "Elec. Cable"
#define VCTAG_CAT_FOCABLE_STR    "Fiber Cable"
#define VCTAG_CAT_GUIDE_STR      "Guide"


#endif

