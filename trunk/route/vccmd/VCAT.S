
/* $Id: VCAT.S,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmd/VCAT.S
 *
 * Description:
 *      Abstract class implementing Cabling attribute handling
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCAT.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.8  1997/07/22  15:58:00  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.7  1997/07/14  22:50:38  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.6  1997/05/22  14:47:20  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.5  1997/05/19  14:03:30  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.4  1997/05/07  14:11:02  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.3  1997/04/28  22:25:32  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.2  1997/03/12  21:43:22  pinnacle
# Replaced: vccmd/VCAT.S for:  by hverstee for cabling
#
# Revision 1.1  1997/01/03  17:56:02  pinnacle
# Created: vccmd/VCAT.S by hverstee for cabling
#
 *
 * History:
 *        12/20/96        hv        Initial
 *
 *************************************************************************/

class specification VCAT(0:0) of VDS_LOCATE;

#include <stdio.h>
#include <stdlib.h>
#include <float.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdp.h"
#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "asdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "acrepmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "coimport.h"
#include "COBmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCparameters.h"
#include "VCDBpar.h"
#include "VCdbaccess.h"
#include "VCproto.h"

instance VCAT
{
   IGRshort                     iSynType;   /* Command synonym type   */

   /*     attributes control    */

   IGRboolean                   bSyschg;    /* Locally changed  */
   IGRboolean                   bUsrchg;    /* Locally changed  */

   IGRboolean                   bSysact;    /* Locally changed  */
   IGRboolean                   bUsract;    /* Locally changed  */

   IGRint                       nSysref;    /* sys collection shared  */
   IGRint                       nUsrref;    /* usr collection shared  */

   IGRboolean                   bMTO;       /* MTO flag              */
   IGRdouble                    dPScale;    /* PID scale             */

   variable
   struct ACrg_coll             Syscoll[0]; /* local sys parameters  */

   variable
   struct ACrg_coll             Usrcoll[0]; /* local usr parameters  */

   struct GRid                  SysCId;     /*  created sys collection   */
   struct GRid                  UsrCId;     /*  created usr collection   */
   struct GRid                  RefCId;     /*  located parentid         */

   struct GRid                  SysACT;     /*  created sys collection   */
   struct GRid                  UsrACT;     /*  created usr collection   */

   IGRchar                      nACTrep;    /*  active representation  */

   GRspacenum                   My_OS;
   struct GRmd_env              CATenv;

   /*      forms control         */

   IGRint                       FCmain;     /*  location table    */
   IGRint                       FCsub;      /*  location table    */
   IGRint                       FCcontrol;  /*  location table    */

   IGRboolean                   bSysUp;
   IGRboolean                   bUsrUp;

   IGRchar                     *pSysAtt;
   IGRchar                     *pUsrAtt;
   IGRchar                     *pCtlAtt;
};

override init;

override wakeup;
override sleep;

/*    Attribute management   */

message VCAT_sav  (IGRlong     *sts);  /* saves current as active     */

message VCAT_sdsp (IGRlong     *sts;
                   IGRchar     *fptr); /* displays system parameters on fptr
                                          form     */

message VCAT_udsp (IGRlong     *sts;
                   IGRchar     *fptr); /* displays user parameters on fptr
                                          form     */

message VCAT_act  (IGRlong     *sts);        /* retrieves active set        */

message VCAT_set  (IGRlong     *sts;         /*  set an attribute     */
                   IGRint       nSys_usr;
                   IGRchar     *szNam;
                   IGRint       nType;
                   IGRchar     *szVal;
                   IGRdouble    dAtt);

message VCAT_get  (IGRlong     *sts;         /*  get all(or one) attribute(s) */
                   IGRint       nSys_usr;
                   IGRint       nCode;       /*  numeric or       */
                   IGRchar     *szName;      /*  alpha id input   */
                   IGRint      *nATnum;
            struct ACrg_coll   *Attr);

message VCAT_load (IGRlong     *sts;         /*  load attr of a ref     */
            struct GRid        *RefId);

message VCAT_coll (IGRlong     *sts;         /*  return active coll. IDs */
            struct GRid        *Sys;
            struct GRid        *Usr);

/*    service, actual load     */

message VCAT_getcoll  (IGRlong     *sts);  /* saves current as active     */

message VCAT_pid  (IGRlong     *sts);      /* sets PID return code if active */

end specification VCAT;

