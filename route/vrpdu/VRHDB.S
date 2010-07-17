
/* $Id: VRHDB.S,v 1.2 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRHDB.S
 *
 * Description:
 *      interface class for HVAC database access
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRHDB.S,v $
 *        Revision 1.2  2002/04/15 20:01:45  anand
 *        Removed version.h and associated dependencies. version.h is
 *        an include file in $EXNUC.
 *
 *        Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *        Initial import to CVS
 *
# Revision 1.2  2000/02/08  21:05:00  pinnacle
# added messages to cache material & insulation tables\
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:35:38  pinnacle
# Created: vrpdu/VRHDB.S by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        02/08/2000      Alwin     Added messages to cache material &insulation
 *									tables.
 *
 *************************************************************************/

class specification VRHDB (0:0) of Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "ACattrib.h"
#include "dberror.h"

#include "PDUerror.h"

#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRDbTbl.h"

#include "VRHDBdef.h"

#include "vrpdu_pto.h"

instance VRHDB
{
  IGRboolean       bDB_open;              /*    logged in   */

  IGRboolean       bNEW_bend;             /*   new bendtable found  */
  IGRboolean       bNEW_branch;           /*   new branchtable found  */
  IGRboolean       bNEW_trans;            /*   new branchtable found  */

  IGRdouble        dCUR_wid;              /*   caching diameter    */
  IGRdouble        dCUR_dep;              /*   caching diameter    */

  IGRshort         nCUR_prj;              /*   caching project     */
  IGRshort         nCUR_spc;              /*   caching specnum     */
  IGRshort         nCUR_spc_idx;          /*   caching spec index    */

  IGRshort         nCUR_bend;             /*   caching bend tableno    */
  IGRshort         nCUR_branch;           /*   caching branch tableno    */
  IGRshort         nCUR_trans;            /*   caching branch tableno    */

  IGRshort         nCUR_cdl;              /*   caching codelist no    */

  IGRchar          szCUR_mat_spec[30];         /*   caching material spec */

  struct VRHDB_project       VRprj;

  /*     variable length cache buffers      */

  variable
  struct VRHDB_ct            VRct[0];

  variable
  struct VRHDB_spec          VRspec[0];

  variable
  struct VRHDB_comps         VRcomps[0];

  variable
  struct VRHDB_bend          VRbend[0];

  variable
  struct VRHDB_branch        VRbranch[0];

  variable
  struct VRHDB_trans         VRtrans[0];

  variable
  struct VRHDB_cdl           VRcdl[0];

  /* Following structures added by Alwin for CR179900696 */
  variable
  struct VRHDB_material      VRmaterial[0];

  variable
  struct VRHDB_insulation    VRinsulation[0];
};

/*    automatic initialize caches    */

message  HDB_init  (IGRlong      *msg);

/*    automatic update caches        */

message  HDB_set   (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec);

/*    public retrieve methods     */

message  HDB_gprj  (IGRlong       *msg;
                    IGRshort       nProj;
             struct VRHDB_project *Rec);

message  HDB_gct   (IGRlong      *msg;
             struct VRHDB_ct_key *keyin;
                    IGRshort     *nNum;
             struct VRHDB_ct     *Rec);

message  HDB_gspec (IGRlong        *msg;
                    IGRshort        nProj;
             struct VRHDB_spec_key *keyin;
                    IGRshort       *nNum;
             struct VRHDB_spec     *Rec);

message  HDB_gcmps (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRHDB_comps_key *keyin;
                    IGRshort        *nNum;
             struct VRHDB_comps     *Rec);

message  HDB_gbend (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid;
                    IGRdouble        dDep;
                    IGRchar         *Code);

message  HDB_gbran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid1;
                    IGRdouble        dDep1;
                    IGRdouble        dWid2;
                    IGRdouble        dDep2;
                    IGRchar         *Code);

message  HDB_gtran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRshort         tType;
                    IGRshort         sCode;
                    IGRdouble        dWid;
                    IGRdouble        dDep;
                    IGRchar         *Code);

message  HDB_gClist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort         nSpec;
                     IGRshort        *nNum;
              struct VRHDB_comps_key *Comps);

message  HDB_gSlist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort        *nNum;
              struct VRHDB_spec_key  *Specs);

message  HDB_ginsulation (IGRlong		*msg;
                    IGRshort         nProj;
                    IGRshort        *nNum;
             struct VRHDB_insulation  *Rec);

message  HDB_gmaterial (IGRlong		*msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRHDB_mat_key   *keyin;
                    IGRshort        *nNum;
             struct VRHDB_material  *Rec);

message  HDB_Stonam (IGRshort         nSpec;
                     IGRchar         *Spec);

message  HDB_Stonum (IGRchar         *Spec;
                     IGRshort        *nSpec);

message  HDB_gCDL   (IGRlong         *msg;
                     IGRshort         nList;
                     IGRshort         nCode;
                     IGRshort        *nNum;
              struct VRHDB_cdl       *Cdl);

message  HDB_cdlnum (IGRlong         *msg;
                     IGRshort         nList;
                     IGRchar         *sTxt;
                     IGRshort        *nNum);

/*    semi_private buffer pointerreturn   */

message  HDB_act   (IGRshort     *nNum;
             struct VRHDB_ct    **Rec);

message  HDB_aspec (IGRshort     *nNum;
             struct VRHDB_spec  **Rec);

message  HDB_acmps (IGRshort     *nNum;
             struct VRHDB_comps **Rec);

message  HDB_amaterial (IGRshort     *nNum;
             struct VRHDB_material **Rec);

message  HDB_ainsulation (IGRshort     *nNum;
             struct VRHDB_insulation **Rec);

/*     private loader messages        */

message  HDB_lPROJ (IGRlong         *msg);
message  HDB_lSPEC (IGRlong         *msg);
message  HDB_lCT   (IGRlong         *msg);
message  HDB_lCOMP (IGRlong         *msg);
message  HDB_lBEND (IGRlong         *msg);
message  HDB_lBRNC (IGRlong         *msg);
message  HDB_lTRAN (IGRlong         *msg);
message  HDB_lCDL  (IGRlong         *msg);

/* Following added by Alwin for CR179900696 */
message  HDB_lMATERIAL ( IGRlong	*msg);
message  HDB_lINSULATION ( IGRlong	*msg);

end specification VRHDB;
