
/* $Id: VRPDB.S,v 1.2 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRPDB.S
 *
 * Description:
 *      interface class for PIPING database access
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRPDB.S,v $
 *        Revision 1.2  2002/04/15 20:01:45  anand
 *        Removed version.h and associated dependencies. version.h is
 *        an include file in $EXNUC.
 *
 *        Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/12/11  18:47:02  pinnacle
# Replaced: vrpdu/VRPDB.S for:  by impd for route
#
# Revision 1.2  1997/12/11  18:04:02  pinnacle
# Replaced: vrpdu/VRPDB.S for:  by r250_int for route
#
# Revision 1.1  1997/08/15  19:37:22  pinnacle
# Created: vrpdu/VRPDB.S by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VRPDB (0:0) of Root;

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

#include "VRPDBdef.h"

#include "vrpdu_pto.h"

instance VRPDB
{
  IGRboolean       bDB_open;              /*    logged in              */

  IGRboolean       bNEW_bend;             /*   new bendtable found     */
  IGRboolean       bNEW_branch;           /*   new branchtable found   */

  IGRdouble        dCUR_dia;              /*   caching diameter sch    */
  IGRdouble        dAL1_dia;              /*   caching diameters comm  */
  IGRdouble        dAL2_dia;              /*   caching diameters comm  */

  IGRshort         nLST_dia;              /*   last dia touched (comm) */
  IGRshort         nCUR_prj;              /*   caching project         */
  IGRshort         nCUR_spc;              /*   caching specnum         */
  IGRshort         nCUR_spc_idx;          /*   caching spec index      */

  IGRshort         nCUR_npd;              /*   caching npd tableno     */
  IGRshort         nCUR_npdb;             /*   caching npd tableno     */
  IGRshort         nCUR_bend;             /*   caching bend tableno    */
  IGRshort         nCUR_branch;           /*   caching branch tableno  */

  IGRshort         nCUR_cdl;              /*   caching codelist no     */

  struct VRPDB_project       VRprj;

  /*     variable length cache buffers      */

  variable
  struct VRPDB_sch_thk       VRsch[0];

  variable
  struct VRPDB_ct            VRct[0];

  variable
  struct VRPDB_commod        VRcomm[0];

  variable
  struct VRPDB_commod        VRaltcomm[0];

  variable
  struct VRPDB_npd           VRnpd[0];

  variable
  struct VRPDB_npd           VRnpdbase[0];

  variable
  struct VRPDB_spec          VRspec[0];

  variable
  struct VRPDB_comps         VRcomps[0];

  variable
  struct VRPDB_bend          VRbend[0];

  variable
  struct VRPDB_branch        VRbranch[0];

  variable
  struct VRPDB_cdl           VRcdl[0];
};

/*    automatic initialize caches    */

message  PDB_init  (IGRlong      *msg);

/*    automatic update caches        */

message  PDB_set   (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec;
                    IGRdouble     dDia);

/*    public retrieve methods     */

message  PDB_gprj  (IGRlong       *msg;
                    IGRshort       nProj;
             struct VRPDB_project *Rec);

message  PDB_gnpd  (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec;
                    IGRshort     *nNum;
             struct VRPDB_npd    *Rec);

message  PDB_gbnpd (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort     *nNum;
             struct VRPDB_npd    *Rec);

message  PDB_gsch  (IGRlong      *msg;
                    IGRshort      nEnd;
                    IGRshort      nGen;
                    IGRdouble     dDia;
                    IGRchar      *Sched;
                    IGRdouble    *dThk;
                    IGRshort     *nUnits);

message  PDB_gcomm (IGRlong      *msg;
                    IGRchar      *si_comm;
                    IGRdouble     dia1;
                    IGRdouble     dia2;
                    IGRchar      *s_t1;
                    IGRchar      *s_t2;
                    IGRchar      *pdm_part);

message  PDB_gct   (IGRlong      *msg;
             struct VRPDB_ct_key *keyin;
                    IGRshort     *nNum;
             struct VRPDB_ct     *Rec);

message  PDB_gspec (IGRlong        *msg;
                    IGRshort        nProj;
             struct VRPDB_spec_key *keyin;
                    IGRshort       *nNum;
             struct VRPDB_spec     *Rec);

message  PDB_gcmps (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRPDB_comps_key *keyin;
                    IGRdouble        dia1;
                    IGRdouble        dia2;
                    IGRshort        *nNum;
             struct VRPDB_comps     *Rec);

message  PDB_gbend (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         rCode;
                    IGRdouble        dDia;
                    IGRchar         *Code);

message  PDB_gbran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRdouble        dDia1;
                    IGRdouble        dDia2;
                    IGRchar         *Code);

message  PDB_gClist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort         nSpec;
                     IGRshort        *nNum;
              struct VRPDB_comps_key *Comps);

message  PDB_gSlist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort        *nNum;
              struct VRPDB_spec_key  *Specs);

message  PDB_Stonam (IGRshort         nSpec;
                     IGRchar         *Spec);

message  PDB_Stonum (IGRchar         *Spec;
                     IGRshort        *nSpec);

message  PDB_gCDL   (IGRlong         *msg;
                     IGRshort         nList;
                     IGRshort         nCode;
                     IGRshort        *nNum;
              struct VRPDB_cdl       *Cdl);

message  PDB_cdlnum (IGRlong         *msg;
                     IGRshort         nList;
                     IGRchar         *sTxt;
                     IGRshort        *nNum);

/*    semi_private buffer pointerreturn   */

message  PDB_act   (IGRshort     *nNum;
             struct VRPDB_ct    **Rec);

message  PDB_aspec (IGRshort     *nNum;
             struct VRPDB_spec  **Rec);

message  PDB_acmps (IGRshort     *nNum;
             struct VRPDB_comps **Rec);

message  PDB_asch  (IGRshort     *nNum;
             struct VRPDB_sch_thk **Rec); 

message  PDB_anpd  (IGRshort     *nNum;
             struct VRPDB_npd   **Rec);

message  PDB_abnpd (IGRshort     *nNum;
             struct VRPDB_npd   **Rec);

/*     private loader messages        */

message  PDB_lPROJ (IGRlong         *msg);
message  PDB_lSPEC (IGRlong         *msg);
message  PDB_lSCH  (IGRlong         *msg);
message  PDB_lCT   (IGRlong         *msg);
message  PDB_lCOMM (IGRlong         *msg);
message  PDB_lNPD  (IGRlong         *msg);
message  PDB_lNPDB (IGRlong         *msg);
message  PDB_lCOMP (IGRlong         *msg);
message  PDB_lBEND (IGRlong         *msg);
message  PDB_lBRNC (IGRlong         *msg);
message  PDB_lCDL  (IGRlong         *msg);

end specification VRPDB;

