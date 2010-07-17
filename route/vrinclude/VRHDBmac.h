
/* $Id: VRHDBmac.h,v 1.1.1.1 2001/01/04 21:12:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrinclude/VRHDBmac.h
 *
 * Description:
 *
 *  Include file for HVAC DB interface macros
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRHDBmac.h,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:53  cvs
 *     Initial import to CVS
 *
 * Revision 1.2  2000/02/08  21:13:02  pinnacle
 * (No comment)
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/08/15  19:31:14  pinnacle
 * Created: vrinclude/VRHDBmac.h by hverstee for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/01/97          HV            New
 *      02/09/2000        Alwin         Added macros to fetch the material &
 *										insulation table contents. CR179900696
 *
 * -------------------------------------------------------------------*/

#ifndef VRHDBmac_include

#define VRHDBmac_include

/****************************************************************************/
/*                     HDB calling macros                                   */
/****************************************************************************/

/*    NOTE, we'll have to import all these methods     */

from VRHDB    import  HDB_init;
from VRHDB    import  HDB_set;
from VRHDB    import  HDB_gprj;
from VRHDB    import  HDB_gct;
from VRHDB    import  HDB_gspec;
from VRHDB    import  HDB_gcmps;
from VRHDB    import  HDB_gbend;
from VRHDB    import  HDB_gbran;
from VRHDB    import  HDB_gtran;

from VRHDB    import  HDB_gClist;
from VRHDB    import  HDB_gSlist;
from VRHDB    import  HDB_Stonam;
from VRHDB    import  HDB_Stonum;
from VRHDB    import  HDB_gCDL;
from VRHDB    import  HDB_cdlnum;

from VRHDB    import  HDB_act;
from VRHDB    import  HDB_aspec;
from VRHDB    import  HDB_acmps;

from VRHDB    import  HDB_gmaterial;  //added for CR179900696
from VRHDB    import  HDB_ginsulation;
from VRHDB    import  HDB_amaterial;
from VRHDB    import  HDB_ainsulation;

/*  initialize interface */
#omdef VR$HDB_INIT (p_msg)

om$send (msg = message VRHDB.HDB_init (p_msg),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*    setup     (Normally done automatically)                           */
/*    force caching parameters, project number/spec number/diameter     */

#omdef VR$HDB_SET (p_msg,
                   proj = VRHDB_UNDEF,
                   spec = VRHDB_UNDEF)

om$send (msg = message VRHDB.HDB_set
                       (p_msg, (IGRshort) proj, (IGRshort) spec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get  project   */
#omdef VR$HDB_PROJ (p_msg,
                    proj = VRHDB_UNDEF,   /* project number    */
                    p_rec)                /* projecr DB record */

om$send (msg = message VRHDB.HDB_gprj (p_msg, (IGRshort) proj, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get component types by key or all   */
#omdef VR$HDB_CT   (p_msg,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gct (p_msg, keyin, p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$HDA_CT   (p_num,
                    p_ptr)

om$send (msg = message VRHDB.HDB_act (p_msg, p_ptr),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef


/*  get spec records by key or alls   */
#omdef VR$HDB_SPEC (p_msg,
                    proj = VRHDB_UNDEF,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gspec (p_msg, (IGRshort) proj, keyin,
                                        p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$HDA_SPEC (p_num,
                    p_ptr)

om$send (msg = message VRHDB.HDB_aspec (p_msg, p_ptr),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get components by key/diameters or all  */
#omdef VR$HDB_COMP (p_msg,
                    proj = VRHDB_UNDEF,
                    spec = VRHDB_UNDEF,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gcmps
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           keyin, p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$HDA_COMP (p_num,
                    p_ptr)

om$send (msg = message VRHDB.HDB_acmps (p_msg, p_ptr),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get bend component code according to input   */
#omdef VR$HDB_BEND (p_msg,
                    proj = VRHDB_UNDEF,
                    spec = VRHDB_UNDEF,
                    angle = 90.0,
                    ctype = 0,
                    width,
                    depth = 0.0,
                    p_code)

om$send (msg = message VRHDB.HDB_gbend
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           angle, (IGRshort) ctype, width, depth, p_code),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get branchcomponent code according to input   */
#omdef VR$HDB_BRAN (p_msg,
                    proj = VRHDB_UNDEF,
                    spec = VRHDB_UNDEF,
                    angle = 90.0,
                    ctype = 0,
                    width1,
                    depth1 = 0.0,
                    width2,
                    depth2 = 0.0,
                    p_code)

om$send (msg = message VRHDB.HDB_gbran
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           angle, (IGRshort) ctype, width1, depth1,
                           width2, depth2, p_code),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get transitioncomponent code according to input   */
#omdef VR$HDB_TRAN (p_msg,
                    proj = VRHDB_UNDEF,
                    spec = VRHDB_UNDEF,
                    ttype = 0,
                    scode = 0,
                    width,
                    depth = 0.0,
                    p_code)

om$send (msg = message VRHDB.HDB_gtran
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           (IGRshort) ttype, (IGRshort) scode,
                           width, depth, p_code),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get component keys list   */
#omdef VR$HDB_CLST (p_msg,
                    proj = VRHDB_UNDEF,
                    spec = VRHDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gClist
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec keys list   */
#omdef VR$HDB_SLST (p_msg,
                    proj = VRHDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gSlist
                          (p_msg, (IGRshort) proj, p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec number from name   */
#omdef VR$HDB_SNUM (p_nam,
                    p_num)

om$send (msg = message VRHDB.HDB_Stonum (p_nam, p_num),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get spec name from number  */
#omdef VR$HDB_SNAM (num,
                    p_nam)

om$send (msg = message VRHDB.HDB_Stonam ((IGRshort) num, p_nam),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get codelist  */
#omdef VR$HDB_CDL  (p_msg,
                    nlist,
                    ncode = VRHDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gCDL (p_msg, (IGRshort)nlist, (IGRshort)ncode,
                                       p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  convert text to codelistnum  */

#omdef VR$HDB_CDLNUM (p_msg,
                      nlist,
                      p_txt,
                      p_num)

om$send (msg = message VRHDB.HDB_cdlnum (p_msg, (IGRshort) nlist, p_txt, p_num),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/* following macros added by Alwin.  To access the HVAC_MATERIAL_LIST and 
HVAC_INSULATION_LIST table. for CR179900696 */

/* VR$HDA macros help us fetch the current cache content */
#omdef VR$HDA_MATERIAL (p_num,
						p_ptr)

om$send (msg = message VRHDB.HDB_amaterial (p_num, p_ptr),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#omdef VR$HDA_INSULATION (p_num,
						  p_ptr)

om$send (msg = message VRHDB.HDB_ainsulation (p_num, p_ptr),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get material list based on the spec and material_class */
#omdef VR$HDB_MATERIAL (p_msg,
                    proj = VRHDB_UNDEF,
                    spec = VRHDB_UNDEF,
                    keyin = NULL,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_gmaterial
                          (p_msg, (IGRshort) proj, (IGRshort) spec,
                           keyin, p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

/*  get insulation table contents */
#omdef VR$HDB_INSULATION (p_msg,
                    proj = VRHDB_UNDEF,
                    p_num,
                    p_rec = NULL)

om$send (msg = message VRHDB.HDB_ginsulation
                          (p_msg, (IGRshort) proj, p_num, p_rec),
    targetid = VRHDB_id.objid,
    targetos = VRHDB_id.osnum,
    senderid = NULL_OBJID)

#endomdef

#endif
