
/* $Id: VCproto.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCproto.h
 *
 * Description:
 *
 *      Function prototypes definitions for cabling programs.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCproto.h,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/10/20  15:41:42  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by apazhani for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/11/30  16:09:10  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by r250_int for route
 *
 * Revision 1.28  1997/11/14  23:21:14  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by onayragu for cabling
 *
 * Revision 1.27  1997/10/14  10:21:08  pinnacle
 * Replaced: vcinclude/VCproto.h for: CR 179701618 by aharihar for cabling
 *
 * Revision 1.26  1997/07/31  19:43:56  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.25  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.24  1997/05/22  12:48:38  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.23  1997/05/19  12:59:04  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.22  1997/05/06  13:16:26  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.21  1997/05/02  16:58:24  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.20  1997/04/28  21:41:22  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.19  1997/03/28  20:43:22  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.18  1997/03/19  14:43:20  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.17  1997/03/12  15:49:48  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.16  1997/03/06  22:10:32  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.14  1997/03/05  14:39:34  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.13  1997/01/23  13:35:28  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.12  1997/01/20  20:06:48  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.11  1997/01/09  17:46:48  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.10  1997/01/03  14:09:08  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.9  1996/12/16  16:44:56  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.8  1996/11/15  18:22:42  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.6  1996/10/25  13:43:30  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.5  1996/10/03  18:05:10  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.4  1996/09/26  20:55:44  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.3  1996/08/30  17:34:48  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/08/29  22:16:28  pinnacle
 * Replaced: vcinclude/VCproto.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:47:38  pinnacle
 * Created: vcinclude/VCproto.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *	10/20/97   Alwin	Modified the Fn VCFOCONlist declaration.
 *
 *************************************************************************/

#ifndef	vc_proto_include
#define vc_proto_include

#ifndef _STANDARDS_H_
#       include <standards.h>
#endif

/*
#include "VRtracer.h"
*/

/*      translate attribute name to number   */
extern
IGRshort   VCDB_AttrNamToNum __((IGRchar     *szAttNam));

extern
IGRchar  * VCDB_AttrNumToNam __((IGRshort     nAttNum));

extern
IGRshort   VCDB_AttrNamToType __((IGRchar     *szAttNam));

extern
IGRshort   VCDB_AttrNumToType __((IGRshort     nAttNum));

/*      create/return  virtual terminal              */
extern
IGRint VCT_virtualize __((IGRlong     *msg,
                          IGRboolean   bCreate,
                   struct GRid        *Conn_in,
                   struct GRmd_env    *In_env,
                   struct GRid        *Conn_out,
                   struct GRmd_env    *md_env));

/*      Remove intermediate coordinates (colinear, mindist)    */

extern
IGRboolean   VC_samept    __((IGRdouble *p1,
                              IGRdouble *p2));
extern
IGRboolean   VCC_ptremove __((IGRdouble       *dPt1,
                              IGRdouble       *dPt2,
                              IGRdouble       *dPt3,
                              IGRdouble        dMin));

/*      Add new different coordinate to buffer                 */

extern
IGRboolean   VCC_addcoord __((IGRdouble       *buff,
                              IGRint          *ctr,
                              IGRdouble       *dPT));

/*      Internal connect/disconnect              */

extern   /*   NOTE: execute AFTER   assoc linkup        */
IGRint VC_Connect __((IGRlong        *msg,
                      IGRboolean      bPassThru,    /*   passthru flag   */
                      IGRshort        nCpTerm,      /*   terminal CP     */
               struct GRid           *TermId,       /*   terminal GRid   */
                      IGRshort        nCpCab,       /*   cable  CP       */
               struct GRid           *CabId,        /*   cable GRid      */
               struct GRmd_env       *md_env));

extern   /*   NOTE: execute BEFORE assoc disconnect     */
IGRint VC_DisConn __((IGRlong        *msg,
               struct GRid           *TermId,       /*   terminal GRid   */
               struct GRid           *CabId,        /*   cable GRid      */
               struct GRmd_env       *md_env));

/*      Access database via cache                */

extern                                          /*   open cache  */
IGRint VCDB_open __((IGRlong       *msg,
                     IGRshort       ElType,
                     IGRshort       Product,
                     GRspacenum     cur_os));

extern                                          /*   clear cache  */
IGRint VCDB_clear __((IGRlong       *msg,
                      GRspacenum     cur_os));

extern                                          /*   Clear type cache */
IGRint VCDB_clprd __((IGRlong       *msg,
                      IGRshort       ElType,
                      IGRshort       Product,
                      GRspacenum     cur_os));

extern                                          /*   close cache  */
IGRint VCDB_close __((IGRlong       *msg));

extern                                          /*   create new entry  */
IGRint VCDB_new  __((IGRlong       *msg,
                     IGRshort       ElType,
                     IGRshort       Product,
                     GRspacenum     cur_os,
                     IGRchar       *Tabnam,
              struct GRid          *ModelId));

extern                                          /*   delete entry   */
IGRint VCDB_del  __((IGRlong       *msg,
                     IGRshort       ElType,
                     IGRshort       Product,
                     GRspacenum     cur_os,
                     IGRchar       *Tabnam));

extern                                          /*   retrieve entry  */
IGRint VCDB_old  __((IGRlong       *msg,
                     IGRshort       ElType,
                     IGRshort       Product,
                     GRspacenum     cur_os,
                     IGRchar       *Tabnam,
              struct GRid          *ModelId));

extern                                          /*   retrieve dirlist  */
IGRint VCDB_list __((IGRlong       *msg,
                     IGRshort       ElType,
                     IGRshort       Product,
                     GRspacenum     cur_os,
                     IGRboolean     bLocal,
                     IGRboolean     bDB,
                     IGRshort      *nCount,
                     IGRchar       *Tabnam,
                     IGRchar       *Tabdes));

/*   compute angle between two vectors      */
extern
IGRdouble VC_compute_angle __((IGRdouble    *vx,
                               IGRdouble    *vy,
                               IGRdouble    *vz));

/*   compute length of (partial) linestring with bendtable    */

extern
IGRdouble VC_compute_strlen __((IGRlong       *msg,
                         struct IGRpolyline   *LineIn,
                                IGRshort       jBeg,
                                IGRshort       jEnd,
                                IGRdouble     *dBtab));

/*   translate offset/orientation of terminal to relative   */
extern
IGRint  VC_to_offset __((IGRdouble   *RefMat,
                         IGRint       Type,
                         IGRshort     nVal,
                         IGRdouble   *dOffIn,
                         IGRdouble   *dOffOut));

/*   translate offset/orientation of terminal to absolute   */
extern
IGRint  VC_to_world  __((IGRdouble   *InMat,
                         IGRint       Type,
                         IGRshort     nVal,
                         IGRdouble   *dOffIn,
                         IGRdouble   *OutMat));

/*   create matrix from a single vector                      */
extern
IGRint   VC_mat_from_vector  __((IGRdouble       *dOrg,
                                 IGRdouble       *dVC,
                                 IGRdouble       *dMat));

/*   normalize matrix                                        */
extern
IGRint   VC_mat_normalize    __((IGRdouble       *dMat));

/*   multiply matrices                                       */
extern
IGRint   VC_mat_multiply     __((IGRdouble       *dMat1,
                                 IGRdouble       *dMat2,
                                 IGRdouble       *dMout));

/*  invert matrix                                            */
extern
IGRint   VC_mat_invert       __((IGRdouble       *dMat1,
                                 IGRdouble       *dMout));

/*   compare connectpositions                                */
extern
IGRboolean   VC_posequal __((struct VCpos    *pos1,
                             struct VCpos    *pos2));

/*   move connectpositions                                  */
extern
IGRint   VC_posmove  __((struct VCpos    *pos1,
                         struct VCpos    *pos2));

/*    Connectors/splices list           */
/* Changing the last argument to single pointer. The caller will allocate
the memory and free. Alwin for TR179801275 */
extern
IGRint   VC_FOCONlist  __((IGRlong         *msg,
                           IGRchar         *szMtc1,
                           IGRchar         *szMtc2,
                           IGRint          *Cnum,
                           IGRchar         *Clist));

/*    Tag numbers control               */

extern
IGRint   VC_TAGList     __((GRspacenum          Osnum,
			IGRint			*NbInList,
			struct VCTagInfo        **TagList));

extern
IGRint   VC_TAGobj     __((IGRlong         *msg,
                    struct GRid            *TagMgr));

extern
IGRint   VC_TAGchk     __((IGRshort        *nST,
                           IGRint           Cat,
                           IGRchar         *szTag));

extern
IGRint   VC_TAGadd     __((IGRshort        *nST,
                           IGRint           Cat,
                           IGRchar         *szTag,
			   struct GRid	   *MyId));

extern
IGRint   VC_TAGdel     __((IGRshort        *nST,
                           IGRint           Cat,
                           IGRchar         *szTag));

extern
void     VC_revcoord   __((IGRint       NumCrd,
                           IGRdouble   *pCoord));

extern
IGRboolean  VC_node_equal __((struct VC_contrace    *TR1,
                              struct VC_contrace    *TR2));

/*
extern
IGRint  VC_con_trace  __((IGRlong         *msg ,
                          IGRint           TransFlags,
                   struct VC_contrace     *ConId,
                   struct VC_contrace     *ConEnd,
                          IGRshort        *nTrac,
                   struct VC_contrace    **TracTab,
                          IGRchar         *SigId));
*/

extern
IGRint  VC_RWthru  __((IGRlong       *msg,
                struct GRid          *CompIn,
                struct GRid          *CompRef,
                       IGRshort      *nNum,
                       IGRshort      *nCPin,
                       IGRshort      *nCPout,
                struct GRid          *CorrOut,
                struct GRid          *CompOut,
                struct GRmd_env      *md_env));

/*
extern
IGRint  VC_rw_trace __((IGRlong        *msg,
                 struct GRid           *ConId,
                 struct GRid           *ConEnd,
                        IGRshort       *nTrac,
                 struct VR_tracerec   **TracTab,
                        IGRboolean     *bBranched,
                 struct GRmd_env       *md_env));
*/

extern
IGRint  VC_setdefpar __((IGRlong        *msg,
                         IGRint          itype,
                         IGRchar        *szName,
                  struct GRid           *CollId,
                  struct GRmd_env       *md_env));

extern
IGRint  VC_Cmd_form_open  __((IGRchar    *fptr,
                              IGRint      indic));

extern
IGRint  VC_Cmd_form_pos   __((IGRchar    *fptr,
                              IGRint      indic));

extern
IGRint  VC_Cmd_form_close __((IGRchar    *fptr,
                              IGRint      indic));

extern
IGRint  VC_AT_getact __((IGRlong     *msg,
                         IGRint       sys_usr,
                         GRspacenum   nOS,
                  struct GRid        *ID));
extern
IGRint  VC_AT_setact __((IGRlong     *msg,
                         IGRint       sys_usr,
                         GRspacenum   nOS,
                  struct GRid        *IDold,
                  struct GRid        *ID,
                  struct GRmd_env    *me_env));

extern
IGRint  VC_coord_pres __((IGRdouble       *dCIN,
                          IGRdouble       *dPREV,
                          IGRdouble       *dMatrix,
                          IGRboolean       bDepth,
                          IGRboolean       bOrtho,
                          IGRboolean       bGoing,
                          IGRdouble       *dCOUT));

extern
IGRboolean  VC_colinear __((IGRdouble     *p1,
                            IGRdouble     *p2,
                            IGRdouble     *p3));

extern
IGRint      VC_pidmac   __((IGRlong        *msg,
                            IGRchar        *szCode,
                            IGRchar        *szMac));

extern
IGRint      VC_digit    __((IGRdouble     *p1,
                            IGRdouble     *p2));

extern
IGRint      VC_termexpand __((IGRlong      *msg,
                              IGRint       *nNUM,
                       struct GRid         *MACRO_ID,
                       struct GRmd_env     *MOD_ENV));

/*     decoders     */

extern
void        VCDBstr   __((IGRchar     *Cout,
                          IGRchar     *Cin));

extern
IGRint      VCDBint   __((IGRchar     *Cin));

extern
IGRdouble   VCDBdbl   __((IGRchar     *Cin));


/*     Seen that solaris seems to have some problems with <math.h>
       I'll include the needed declarations here                       */

extern double acos __((double));
extern double asin __((double));
extern double atan __((double));
extern double atan2 __((double,double));
extern double ceil __((double));
extern double cos __((double));
extern double cosh __((double));
extern double exp __((double));
extern double fabs __((double));
extern double floor __((double));
extern double fmod __((double,double));
extern double frexp __((double, int *));
extern double ldexp __((double, int));
extern double log __((double));
extern double log10 __((double));
extern double modf __((double, double *));
extern double pow __((double, double));
extern double sin __((double));
extern double sinh __((double));
extern double sqrt __((double));
extern double tan __((double));
extern double tanh __((double));

#endif
