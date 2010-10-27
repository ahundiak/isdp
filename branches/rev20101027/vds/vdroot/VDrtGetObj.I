/* $Id: VDrtGetObj.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDrtGetObj.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrtGetObj.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
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
# Revision 1.2  1995/05/31  20:10:12  pinnacle
# Replace: vdroot/VDrtGetObj.I by hverstee for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
*/
class implementation VDSroot ;

#include "grerr.h"
#include "vds.h"
#include "VDmacdef.h"
#include "VDmsg.h"
/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= VD_I_ObjRoot ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

method   VDGetProduct (  IGRshort *pnProduct;
                         IGRchar  *pc3Product )

{
  IGRchar     thisname[50];

  /*   default: parse classname    */

  om$get_classname (objid     = my_id,
                    osnum     = OM_Gw_current_OS,
                    classname = thisname);

  /*   and assume piping for all route ?????  */
  if ((thisname[0] == 'V') && (thisname[1] == 'R'))
  {
    *pnProduct = PIPING;
    if (pc3Product != NULL)
      strcpy (pc3Product, "Pi");
  }
  else
  if ((thisname[0] == 'S') && (thisname[1] == 'M'))
  {
    *pnProduct = STRUCT;
    if (pc3Product != NULL)
      strcpy (pc3Product, "Sm");
  }
  else
  {
    *pnProduct = VDS;
    if (pc3Product != NULL)
      strcpy (pc3Product, "Vd");
  }

  return (OM_S_SUCCESS);
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

