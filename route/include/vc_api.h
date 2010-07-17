
/* $Id: vc_api.h,v 1.1.1.1 2001/01/04 21:12:09 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        include/vc_api.h
 *
 * Description:
 *
 *  Public Include file for cabling analysis api
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: vc_api.h,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:09  cvs
 *     Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  04:55:10  pinnacle
 * Created: include/vc_api.h by impd for route
 *
 * Revision 1.3  1997/03/28  23:41:54  pinnacle
 * Replaced: include/vc_api.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/03/19  14:34:36  pinnacle
 * Replaced: include/vc_api.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/03/14  16:49:24  pinnacle
 * Created: include/vc_api.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

#ifndef vc_api_include
#define vc_api_include

#ifndef _STANDARDS_H_
#       include <standards.h>
#endif

/*     analysis select states     */

#define   VC_DEFAN_NONE       0    /*   no select                            */
#define   VC_DEFAN_TERM       1    /*   terminal selected                    */
#define   VC_DEFAN_CABLE      2    /*   cable selected                       */
#define   VC_DEFAN_CBTRAC     3    /*   cable trace (term to term)           */
#define   VC_DEFAN_SIGNAL     4    /*   complete (branched) signal selected  */
#define   VC_DEFAN_PATH       5    /*   partial (point - point) selected     */
#define   VC_DEFAN_ALL       99    /*   analysis for all cases               */

/****************************************************************************/
/*                       DYNAMIC API                                        */

/*     structure to transfer analysis function information     */
struct  VC_anproc
{
   int          Type;       /* Corresponding select state       */
   char        *Desc;       /* Pointer to description string    */   
   int         (*fcn)();    /* Pointer to analysis function     */
};

/*     prototypes of functions                                 */

/*     define the table of functions       */
extern
int         VC_AN_getfunc __((int          select,
                              int         *num,
                       struct VC_anproc   *table));

/*     template for calculation function   */
extern
int VC_AN_execute __((int          *msg));

/****************************************************************************/
/*                           PPL API                                        */
/*            Globals to transfer input information to PPL                  */
/****************************************************************************/

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                               char            VCANGLB_signam[VC_MAX_SIG_ID];

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                               char            VCANGLB_filenam[80];

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                               int             VCANGLB_select;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                               short           VCANGLB_ntrace;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                       struct VC_contrace     *VCANGLB_trac;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                               char            VCANGLB_result[80];

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                       struct GRmd_env         VCANGLB_mdenv;
 
#endif

