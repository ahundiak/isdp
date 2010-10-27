/* $Id: vdstagcon.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func/ vdstagcon.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdstagcon.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  15:00:00  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1995/07/24  15:37:16  pinnacle
# Created: smutil/func/vdstagcon.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *       07/25/95        HV              Moved from vds/smutil/cmd
 *
 * -------------------------------------------------------------------*/

class implementation OMTagCon;

#include "OMminimum.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMtags.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "VDmem.h"

 
/*  Function :: vds_get_tagcon_info()
**
**  This function will return infomation about an OMTagCon object
**
**  Input:    os         OMuword       Object Space Number
**
**            oid        OM_S_OBJID    Object ID of OMTagCon object
**
**  Output:   intname    char *        Array to hold intenal os name - must be
**                                     dimensioned to OM_K_MAXINTOSNAME_LEN
**                                     (from OMlimits.h - currently 32)
**
**            oidlist    OM_p_OBJID *  An array of oids will be malloc'ed
**                                     inside this function - responsibility
**                                     of caller to free
**
**            taglist    OMuint **     An array of tags will be malloc'ed
**                                     inside this function - responsibility
**                                     of caller to free
**
**            count      OMuint *      Count of above lists will be returned
**/

int vds_get_tagcon_info ( os, oid, intname, oidlist, taglist, count )

OMuword       os;
OM_S_OBJID    oid;
char         *intname;
OM_S_OBJID  **oidlist;
OMuint      **taglist;
OMuint       *count;
{
   int          sts;
   OMuint       vla_sz, *p_tags;
   OM_S_OBJID  *p_oids;
   OM_S_RIP     rip;
   struct OMTagCon_instance  *myme;
   struct OM_sd_connect_record *p_con_rec, *p_vla;

   p_oids = NULL;
   p_tags = NULL;
   myme = NULL;
   p_con_rec = NULL;
   p_vla = NULL;

   sts = om$get_any_instance ( osnum = os,
                               objid = oid,
                               p_rip = &rip );
   if (!(1&sts)) return (sts);

    /*  this is all just cheating - please ignore and NEVER reproduce  */
 
    myme = &(((struct OMTagCon_total_instance *) rip.p_object)->OMTagCon);
    p_vla = (struct OM_sd_connect_record *)myme->con_rec_descr.i_offset;
 
   strncpy ( intname, myme->osname, OM_K_MAXINTOSNAME_LEN );
 
   /*  check if empty  */
 
    *count = 0;
 
    if (myme->first_tag == OM_K_TAGEND)
      return (OM_S_SUCCESS);
 
    p_con_rec = &p_vla[myme->first_tag];
    vla_sz = myme->con_rec_descr.i_count;
 
   p_oids = _MALLOC ( vla_sz ,OM_S_OBJID );
    if (!p_oids) goto wrapup ; /*  return (OM_E_NODYNMEM); */
 
    p_tags = _MALLOC( vla_sz,OMuint );
    if (!p_tags) goto wrapup ; /* return (OM_E_NODYNMEM); */
 
    while (1) {
       p_oids[*count] = p_con_rec->objid;
       p_tags[*count] = p_con_rec->tag;
      *count = *count + 1;
 
      if (p_con_rec->next == OM_K_TAGEND) break;
 
       p_con_rec = &p_vla[p_con_rec->next];
    }
    
    *oidlist = p_oids;
    *taglist = p_tags;
 
    return (OM_S_SUCCESS);

    wrapup :
	if (p_oids) _FREE(p_oids);
	if (p_tags) _FREE(p_tags);
    	return (OM_E_NODYNMEM);
 }
 
end implementation OMTagCon;


