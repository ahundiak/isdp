/* $Id: VDItemDBppl.h,v 1.2 2001/02/11 17:30:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDItemDB.h
 *
 * Description: Routines for getting additional attributes from database tables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDItemDBppl.h,v $
 *      Revision 1.2  2001/02/11 17:30:40  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/09 21:50:23  art
 *      ah
 *
 * Revision 1.1  2000/12/06  19:02:30  pinnacle
 * Created: vds/include/VDItemDBppl.h by jdsauby for Service Pack
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/08/00  js      Creation
 *
 ***************************************************************************/

#include "VDppl.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDtypedef.h"
#include "VDrisc.h"
#include "VDItemDBUtil.h"

/* ------------------------------------------
 * trick to allow sharing of variables amongst PPLs
 */
// PPL to get key value
IGRchar     		KEY_VALUE[128];
TGRid       		KEY_VALUE_OBJID;
TVDrisInfo  		KEY_RIS_INFO;

// PPL to get list of attributes
TVDitemdbCollAttrs 	*KEY_ATTRS;

