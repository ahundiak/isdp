/* $Id: VDItemDBppl.h,v 1.4 2001/02/11 17:35:58 ahundiak Exp $  */

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
 *      Revision 1.4  2001/02/11 17:35:58  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.3  2001/01/14 16:39:21  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/09 21:35:20  art
 *      ah
 *
 * Revision 1.1  2000/12/06  20:38:36  pinnacle
 * Created: vds/api/item/VDItemDBppl.h by jdsauby for Service Pack
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

