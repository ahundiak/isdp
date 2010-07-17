
/* $Id: VRRDB.S,v 1.4 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRRDB.S
 *
 * Description:
 *      interface class for HVAC database access
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRRDB.S,v $
 *        Revision 1.4  2002/04/15 20:01:45  anand
 *        Removed version.h and associated dependencies. version.h is
 *        an include file in $EXNUC.
 *
 *        Revision 1.3  2001/02/20 01:14:56  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/11 19:22:55  anand
 *        SP merge
 *
# Revision 1.1  2000/07/10  19:08:04  pinnacle
# Created: route/vrpdu/VRRDB.S by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:37:34  pinnacle
# Created: vrpdu/VRRDB.S by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        07/10/00        Alwin     Added method to load/cache Raceway Nozzles
 *
 *************************************************************************/

class specification VRRDB (0:0) of Root;

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

#include "VRRDBdef.h"

#include "vrpdu_pto.h"
#include "vrdbgmacros.h"

instance VRRDB
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

  struct VRRDB_project       VRprj;

  /*     variable length cache buffers      */

  variable
  struct VRRDB_ct            VRct[0];

  variable
  struct VRRDB_spec          VRspec[0];

  variable
  struct VRRDB_comps         VRcomps[0];

  variable
  struct VRRDB_bend          VRbend[0];

  variable
  struct VRRDB_branch        VRbranch[0];

  variable
  struct VRRDB_trans         VRtrans[0];

  variable
  struct VRRDB_cdl           VRcdl[0];

  /* Instance to store the contents of rway_nozzle table. */
  variable
  struct VRRDB_rwaynozz      VRrwnozz[0];

};

/*    automatic initialize caches    */

message  RDB_init  (IGRlong      *msg);

/*    automatic update caches        */

message  RDB_set   (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec);

/*    public retrieve methods     */

message  RDB_gprj  (IGRlong       *msg;
                    IGRshort       nProj;
             struct VRRDB_project *Rec);

message  RDB_gct   (IGRlong      *msg;
             struct VRRDB_ct_key *keyin;
                    IGRshort     *nNum;
             struct VRRDB_ct     *Rec);

message  RDB_gspec (IGRlong        *msg;
                    IGRshort        nProj;
             struct VRRDB_spec_key *keyin;
                    IGRshort       *nNum;
             struct VRRDB_spec     *Rec);

message  RDB_gcmps (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRRDB_comps_key *keyin;
                    IGRdouble        wid1;
                    IGRdouble        dep1;
                    IGRdouble        wid2;
                    IGRdouble        dep2;
                    IGRshort        *nNum;
             struct VRRDB_comps     *Rec);

message  RDB_gbend (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid;
                    IGRdouble        dDep;
                    IGRchar         *Code);

message  RDB_gbran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid1;
                    IGRdouble        dDep1;
                    IGRdouble        dWid2;
                    IGRdouble        dDep2;
                    IGRchar         *Code);

message  RDB_gClist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort         nSpec;
                     IGRshort        *nNum;
              struct VRRDB_comps_key *Comps);

message  RDB_gSlist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort        *nNum;
              struct VRRDB_spec_key  *Specs);

message  RDB_Stonam (IGRshort         nSpec;
                     IGRchar         *Spec);

message  RDB_Stonum (IGRchar         *Spec;
                     IGRshort        *nSpec);

message  RDB_gCDL   (IGRlong         *msg;
                     IGRshort         nList;
                     IGRshort         nCode;
                     IGRshort        *nNum;
              struct VRRDB_cdl       *Cdl);

message  RDB_cdlnum (IGRlong         *msg;
                     IGRshort         nList;
                     IGRchar         *sTxt;
                     IGRshort        *nNum);

/*    semi_private buffer pointerreturn   */

message  RDB_act   (IGRshort     *nNum;
             struct VRRDB_ct    **Rec);

message  RDB_aspec (IGRshort     *nNum;
             struct VRRDB_spec  **Rec);

message  RDB_acmps (IGRshort     *nNum;
             struct VRRDB_comps **Rec);

/*     private loader messages        */

message  RDB_lPROJ (IGRlong         *msg);
message  RDB_lSPEC (IGRlong         *msg);
message  RDB_lCT   (IGRlong         *msg);
message  RDB_lCOMP (IGRlong         *msg);
message  RDB_lBEND (IGRlong         *msg);
message  RDB_lBRNC (IGRlong         *msg);
message  RDB_lCDL  (IGRlong         *msg);

message  RDB_arwnozz (	IGRlong			*msg;
			IGRshort     		*nNum;
             		struct VRRDB_rwaynozz 	**Rec);

message  RDB_lRWAYNOZZ (IGRlong     *msg);

end specification VRRDB;
