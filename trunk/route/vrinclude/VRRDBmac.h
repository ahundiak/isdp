
/* $Id: VRRDBmac.h,v 1.2 2001/01/12 21:37:36 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRRDBmac.h
 *
 * Description:
 *
 *  Include file for RWAY DB interface macros
 *
 * Dependencies:
 *
 * Revision History:
 *    $Log: VRRDBmac.h,v $
 *    Revision 1.2  2001/01/12 21:37:36  anand
 *    SP merge
 *
 *    Revision 1.1.1.1  2001/01/04 21:12:54  cvs
 *    Initial import to CVS
 *
 * Revision 1.1  2000/07/10  19:03:08  pinnacle
 * Created: route/vrinclude/VRRDBmac.h by apazhani for Service Pack
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/08/15  19:30:58  pinnacle
 * Created: vrinclude/VRRDBmac.h by hverstee for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/01/97          HV            New
 *      07/10/2000        Alwin         Added macro to access Rway Nozzle DB
 *
 * -------------------------------------------------------------------*/

#ifndef VRRDBmac_include

#define VRRDBmac_include

/****************************************************************************/
/*                     RDB calling macros                                   */
/****************************************************************************/

/*    NOTE, we'll have to import all these methods     */

from VRRDB    import  RDB_init;
from VRRDB    import  RDB_set;
from VRRDB    import  RDB_gprj;
from VRRDB    import  RDB_gct;
from VRRDB    import  RDB_gspec;
from VRRDB    import  RDB_gcmps;
from VRRDB    import  RDB_gbend;
from VRRDB    import  RDB_gbran;

from VRRDB    import  RDB_gClist;
from VRRDB    import  RDB_gSlist;
from VRRDB    import  RDB_Stonam;
from VRRDB    import  RDB_Stonum;
from VRRDB    import  RDB_gCDL;
from VRRDB    import  RDB_cdlnum;

from VRRDB    import  RDB_act;
from VRRDB    import  RDB_aspec;
from VRRDB    import  RDB_acmps;

from VRRDB    import  RDB_arwnozz;

/*  initialize interface */
#omdef VR$RDB_INIT (p_msg)

om$send (msg = message VRRDB.RDB_init (p_msg),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*    setup     (Normally done automatically)                           */
/*    force caching parameters, project number/spec number/diameter     */

#omdef VR$RDB_SET (p_msg,
                   proj = VRRDB_UNDEF,
                   spec = VRRDB_UNDEF)

om$send (msg = message VRRDB.RDB_set
                       (p_msg, (IGRshort) proj, (IGRshort) spec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get  project   */
#omdef VR$RDB_PROJ (p_msg,
                    proj = VRRDB_UNDEF,   /* project number    */
                    p_rec)                /* projecr DB record */

om$send (msg = message VRRDB.RDB_gprj (p_msg, (IGRshort) proj, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get component types by key or all   */
#omdef VR$RDB_CT   (p_msg,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRRDB.RDB_gct (p_msg, keyin, p_num, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$RDA_CT   (p_num,
                    p_ptr)

om$send (msg = message VRRDB.RDB_act (p_num, p_ptr),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec records by key or alls   */
#omdef VR$RDB_SPEC (p_msg,
                    proj = VRRDB_UNDEF,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRRDB.RDB_gspec (p_msg, (IGRshort) proj, keyin,
                                        p_num, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$RDA_SPEC (p_num,
                    p_ptr)

om$send (msg = message VRRDB.RDB_aspec (p_num, p_ptr),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get components by key/diameters or all  */
#omdef VR$RDB_COMP (p_msg,
                    proj = VRRDB_UNDEF,
                    spec = VRRDB_UNDEF,
                    keyin = NULL,
                    wid1,
                    dep1  = 0.0,
                    wid2,
                    dep2  = 0.0,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRRDB.RDB_gcmps
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           keyin, wid1, dep1, wid2, dep2, p_num, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$RDA_COMP (p_num,
                    p_ptr)

om$send (msg = message VRRDB.RDB_acmps (p_num, p_ptr),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get bend component code according to input   */
#omdef VR$RDB_BEND (p_msg,
                    proj = VRRDB_UNDEF,
                    spec = VRRDB_UNDEF,
                    angle = 90.0,
                    ctype = 0,
                    width,
                    depth = 0.0,
                    p_code)

om$send (msg = message VRRDB.RDB_gbend
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           angle, (IGRshort) ctype, width, depth, p_code),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get branchcomponent code according to input   */
#omdef VR$RDB_BRAN (p_msg,
                    proj = VRRDB_UNDEF,
                    spec = VRRDB_UNDEF,
                    angle = 90.0,
                    ctype = 0,
                    width1,
                    depth1 = 0.0,
                    width2,
                    depth2 = 0.0,
                    p_code)

om$send (msg = message VRRDB.RDB_gbran
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           angle, (IGRshort) ctype, width1, depth1,
                           width2, depth2, p_code),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get component keys list   */
#omdef VR$RDB_CLST (p_msg,
                    proj = VRRDB_UNDEF,
                    spec = VRRDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRRDB.RDB_gClist
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           p_num, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec keys list   */
#omdef VR$RDB_SLST (p_msg,
                    proj = VRRDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRRDB.RDB_gSlist
                          (p_msg, (IGRshort) proj, p_num, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec number from name   */
#omdef VR$RDB_SNUM (p_nam,
                    p_num)

om$send (msg = message VRRDB.RDB_Stonum (p_nam, p_num),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec name from number  */
#omdef VR$RDB_SNAM (num,
                    p_nam)

om$send (msg = message VRRDB.RDB_Stonam ((IGRshort) num, p_nam),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get codelist  */
#omdef VR$RDB_CDL  (p_msg,
                    nlist,
                    ncode = VRRDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRRDB.RDB_gCDL (p_msg, (IGRshort)nlist, (IGRshort)ncode,
                                       p_num, p_rec),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  convert text to codelistnum  */

#omdef VR$RDB_CDLNUM (p_msg,
                      nlist,
                      p_txt,
                      p_num)

om$send (msg = message VRRDB.RDB_cdlnum (p_msg, (IGRshort) nlist, p_txt, p_num),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$RDA_RWAYNOZZ (p_msg, p_num, p_ptr)

om$send (msg = message VRRDB.RDB_arwnozz (p_msg, p_num, p_ptr ),
    targetid = VRRDB_id.objid,
    targetos = VRRDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#endif

