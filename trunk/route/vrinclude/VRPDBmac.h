
/* $Id: VRPDBmac.h,v 1.1.1.1 2001/01/04 21:12:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRPDBmac.h
 *
 * Description:
 *
 *  Include file for piping DB interface macros
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRPDBmac.h,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:53  cvs
 *     Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/12/10  18:08:08  pinnacle
 * Replaced: vrinclude/VRPDBmac.h for: CR 179421375 and CR 179603102 by aharihar for route
 *
 * Revision 1.1  1997/08/15  19:31:32  pinnacle
 * Created: vrinclude/VRPDBmac.h by hverstee for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/01/97          HV            New
 *      10/10/97        Anand         Minor Corrections
 *
 * -------------------------------------------------------------------*/

#ifndef VRPDBmac_include

#define VRPDBmac_include

/****************************************************************************/
/*                     PDB calling macros                                   */
/****************************************************************************/

/*    NOTE, we'll have to import all these methods     */

from VRPDB    import  PDB_init;
from VRPDB    import  PDB_set;
from VRPDB    import  PDB_gnpd;
from VRPDB    import  PDB_gbnpd;
from VRPDB    import  PDB_gsch;
from VRPDB    import  PDB_gprj;
from VRPDB    import  PDB_gcomm;
from VRPDB    import  PDB_gct;
from VRPDB    import  PDB_gspec;
from VRPDB    import  PDB_gcmps;
from VRPDB    import  PDB_gbend;
from VRPDB    import  PDB_gbran;
from VRPDB    import  PDB_gClist;
from VRPDB    import  PDB_gSlist;
from VRPDB    import  PDB_Stonam;
from VRPDB    import  PDB_Stonum;
from VRPDB    import  PDB_gCDL;
from VRPDB    import  PDB_cdlnum;

from VRPDB    import  PDB_anpd;
from VRPDB    import  PDB_abnpd;
from VRPDB    import  PDB_asch;
from VRPDB    import  PDB_act;
from VRPDB    import  PDB_aspec;
from VRPDB    import  PDB_acmps;

/*  initialize interface */
#omdef VR$PDB_INIT (p_msg)

om$send (msg = message VRPDB.PDB_init (p_msg),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*    setup     (Normally done automatically)                           */
/*    force caching parameters, project number/spec number/diameter     */

#omdef VR$PDB_SET (p_msg,
                   proj = VRPDB_UNDEF,
                   spec = VRPDB_UNDEF,
                   dia  = 0.0)

om$send (msg = message VRPDB.PDB_set
                       (p_msg, (IGRshort) proj, (IGRshort) spec, dia),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get  project   */
#omdef VR$PDB_PROJ (p_msg,
                    proj = VRPDB_UNDEF,   /* project number    */
                    p_rec)                /* projecr DB record */

om$send (msg = message VRPDB.PDB_gprj (p_msg, (IGRshort) proj, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get  npd list for spec   */
#omdef VR$PDB_NPD (p_msg,
                   proj = VRPDB_UNDEF,
                   spec = VRPDB_UNDEF,
                   p_num,
                   p_rec = NULL)

om$send (msg = message VRPDB.PDB_gnpd (p_msg, (IGRshort) proj, (IGRshort) spec,
                                       p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$PDA_NPD (p_num,
                   p_ptr)

om$send (msg = message VRPDB.PDB_anpd (p_num, p_ptr),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get  base npd list   */
#omdef VR$PDB_NPDB (p_msg,
                    proj = VRPDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gbnpd (p_msg, (IGRshort) proj, p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$PDA_NPDB(p_num,
                   p_ptr)

om$send (msg = message VRPDB.PDB_abnpd (p_num, p_ptr),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get schedule   */
#omdef VR$PDB_SCH (p_msg,
                   nend = 5,
                   ngen = 300,
                   npd  = 0.0,
                   Sched,            /* scedule field input   */
                   dThk,             /* thickness output      */
                   nUnits)           /* units output          */

om$send (msg = message VRPDB.PDB_gsch (p_msg, (IGRshort) nend, (IGRshort) ngen,
                                       npd, Sched, dThk, nUnits),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$PDA_SCH (p_num,
                   p_ptr)

om$send (msg = message VRPDB.PDB_asch (p_num, p_ptr),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get commodity (pdm part number)   */
#omdef VR$PDB_COMM (p_msg,
                    si_comm,
                    dia1,
                    dia2,
                    st1,
                    st2,
                    pdmpart)

om$send (msg = message VRPDB.PDB_gcomm (p_msg, si_comm, dia1, dia2, 
                                        st1, st2, pdmpart),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get component types by key or all   */
#omdef VR$PDB_CT   (p_msg,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gct (p_msg, keyin, p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$PDA_CT   (p_num,
                    p_ptr)

om$send (msg = message VRPDB.PDB_act (p_num, p_ptr),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec records by key or alls   */
#omdef VR$PDB_SPEC (p_msg,
                    proj = VRPDB_UNDEF,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gspec (p_msg, (IGRshort) proj, keyin,
                                        p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$PDA_SPEC (p_num,
                    p_ptr)

om$send (msg = message VRPDB.PDB_aspec (p_num, p_ptr),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get components by key/diameters or all  */
#omdef VR$PDB_COMP (p_msg,
                    proj = VRPDB_UNDEF,
                    spec = VRPDB_UNDEF,
                    keyin = NULL,
                    dia1,
                    dia2 = 0.0,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gcmps
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           keyin, dia1, dia2, p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$PDA_COMP (p_num,
                    p_ptr)

om$send (msg = message VRPDB.PDB_acmps (p_num, p_ptr),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef



/*  get bend component code according to input   */
#omdef VR$PDB_BEND (p_msg,
                    proj = VRPDB_UNDEF,
                    spec = VRPDB_UNDEF,
                    angle = 90.0,
                    rcode = 0,
                    dia,
                    p_code)

om$send (msg = message VRPDB.PDB_gbend
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           angle, (IGRshort) rcode, dia, p_code),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get branchcomponent code according to input   */
#omdef VR$PDB_BRAN (p_msg,
                    proj = VRPDB_UNDEF,
                    spec = VRPDB_UNDEF,
                    angle = 90.0,
                    dia1,
                    dia2,
                    p_code)

om$send (msg = message VRPDB.PDB_gbran
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           angle, dia1, dia2, p_code),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get component keys list   */
#omdef VR$PDB_CLST (p_msg,
                    proj = VRPDB_UNDEF,
                    spec = VRPDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gClist
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec keys list   */
#omdef VR$PDB_SLST (p_msg,
                    proj = VRPDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gSlist
                          (p_msg, (IGRshort) proj, p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec number from name   */
#omdef VR$PDB_SNUM (p_nam,
                    p_num)

om$send (msg = message VRPDB.PDB_Stonum (p_nam, p_num),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec name from number  */
#omdef VR$PDB_SNAM (num,
                    p_nam)

om$send (msg = message VRPDB.PDB_Stonam ((IGRshort) num, p_nam),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get codelist  */
#omdef VR$PDB_CDL  (p_msg,
                    nlist,
                    ncode = VRPDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRPDB.PDB_gCDL (p_msg, (IGRshort)nlist, (IGRshort)ncode,
                                       p_num, p_rec),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  convert text to codelistnum  */

#omdef VR$PDB_CDLNUM (p_msg,
                      nlist,
                      p_txt,
                      p_num)

om$send (msg = message VRPDB.PDB_cdlnum (p_msg, (IGRshort) nlist, p_txt, p_num),
    targetid = VRPDB_id.objid,
    targetos = VRPDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#endif

