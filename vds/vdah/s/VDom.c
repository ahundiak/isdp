/* $Id: VDom.c,v 1.11 2001/11/09 14:19:02 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDom.c
 *
 * Description: OM Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDom.c,v $
 *      Revision 1.11  2001/11/09 14:19:02  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/06/22 15:39:29  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/05/17 14:29:11  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/05/02 15:13:20  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/02/17 14:04:00  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/02/08 15:20:35  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/02/01 15:34:48  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/01/14 16:33:27  art
 *      sp merge
 *
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 * Revision 1.2  2000/12/07  17:36:58  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:54:16  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:03:18  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/30/00  ah      Creation
 * 01/12/01  ah      A few more stubs
 * 01/10/01  ah      Ad added some of the sill debug statements to vdval
 *                   Need a couple of globals VDdbgAssert.h
 ***************************************************************************/

#include "VDtypedefc.h"


VDosnum OM_Gw_current_OS;

long  DBG_Gb_dbg;
FILE *DBG_Gb_Fp;

IGRint som_is_ancestry_valid(OMuword  sub_classid,
			     OMuword  super_classid, 
			     IGRchar *sub_classname,
			     IGRchar *super_classname)
{
  return 0;
}
 
IGRint som_get_classid(VDosnum     osnum, 
		       IGRchar    *classname,
		       OM_S_OBJID  objid, 
		       void       *p_object, 
		       OMuword    *p_classid)
{
  return 0;
}

IGRint som_convert_os_number_to_name(VDosnum osnum, IGRchar *name)
{
  IGRint retFlag = 0;
  
  // Arg check
  if (name == NULL) goto wrapup;
  *name = 0;
  
  // Always fail

 wrapup:
  return retFlag;
}

IGRint EX_findmod(OM_S_OBJID *objid, uword *osnum)
{
  if (objid) *objid = NULL_OBJID;
  if (osnum) *osnum = 0;
  return 0;
}

IGRint EX_getpath(IGRint nth, IGRchar *buf, IGRint size, IGRint type)
{
  return 0;
}

IGRint EX_save1(IGRchar *fileName)
{
  return 0;
}

IGRint ASend_fence(void)
{
  return 0;
  
}

IGRint VDstart_var_fence(TGRobj_env  *setOE, 
			 IGRint      *locNum, 
			 TGRobj_env **locOEs)
{
  if (locNum) *locNum = 0;
  if (locOEs) *locOEs = NULL;
  return 0;
}

IGRint VDputResponse(IGRint response)
{
  return 12345;
}

void IGEExit(IGRint status)
{
  exit(status);
}

void *dload_address_lookup()
{
  return NULL;
}

/* -----------------------------------------------
 * Allows some of the stand alone programs
 * to change their behaviour when isdp is not running
 */
IGRstat VDahIsIsdpRunning()
{
  return 0;
}






