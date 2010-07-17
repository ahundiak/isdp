/* $Id: VSfegetsib.I,v 1.1 2001/01/17 23:18:08 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       vsfeature/VSfegetsiblings.I
 *
 * Description: Overridden GRget_siblings method.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfegetsib.I,v $
 *      Revision 1.1  2001/01/17 23:18:08  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/17 23:14:30  ramarao
 *      *** empty log message ***
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/24/00        Rama Rao        Method Creation for GRowner class.
 *	01/17/01	Rama Rao	Moved the method from SP to PLOAD.
 *					Also overridden at VSfeature Level.
 * -------------------------------------------------------------------*/

class implementation VSfeature;

#include "v_miscmacros.h"

extern GRclassid	OPP_VSplate_class_id, OPP_VSbeam_class_id;

method GRget_siblings (long *msg; unsigned short opts;
                       int *num_siblings; struct GRid **siblings;
                       int num_buff; struct GRid *buff)
{
  struct GRid	myGRid;

  myGRid.objid  = my_id;
  myGRid.osnum  = OM_Gw_current_OS;

  *num_siblings = 0;
  *siblings     = NULL;
  if( vd_$is_ancestry_valid( object  = &myGRid,
		             classid = OPP_VSplate_class_id ) ||
      vd_$is_ancestry_valid( object  = &myGRid,
                             classid = OPP_VSbeam_class_id ) )
  {
      VSgetSiblings( msg, myGRid, num_siblings, siblings );
      *msg = MSSUCC;
      return (OM_S_SUCCESS);
  }

wrapup:
  *msg = MSSUCC;
  *num_siblings = 0;
  *siblings = NULL;
  return (OM_S_SUCCESS);
}

end implementation VSfeature;
