/* $Id: GRvggetrang.I,v 1.2 2001/01/13 00:23:47 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc/GRvggetrang.I
 *
 * Description: for handling expression objects
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRvggetrang.I,v $
 *	Revision 1.2  2001/01/13 00:23:47  hans
 *	SP16 modifications
 *	
 *	Revision 1.1  2001/01/13 00:05:06  hans
 *	SP16 modifications
 *
# Revision 1.1  2000/06/06  15:47:36  pinnacle
# ylong
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/05/00	ylong		overwrite method GRvg.getrang;
 * -------------------------------------------------------------------*/
/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRgetrang

     Abstract: This routine retrieves the range of the object.

-----
%SC%
	GRgetrang(msg,matrix_type,matrix,world,range)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	 type of environment matrix
     matrix	   IGRmatrix	 environment matrix
     *world	   IGRboolean    indicator of whether the range should
			 	 be computed in world or local coordinates
				  1 : apply the environment matrix
				  0 : do not apply the environment matrix
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
      range	   GRrange	 range of the object
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	none.

     Methods:
	none.
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:

	MAS     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine retrieves the range of the object and
	stores it in the input array.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "v_dbgmacros.h"

method GRgetrang(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRboolean *world; GRrange range)
{
	IGRlong		OMmsg;
	GRclassid	classId;

	SetProc( GRvg_GRgetrang ); Begin
	__DBGpr_me();

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	OMmsg = om$get_classid(	objid		= my_id,
				p_classid	= &classId );
	if( !(OMmsg & 1) )
	{
		__DBGpr_com("Could not get classid for my_id");
		*msg = MSFAIL;
		End
		return OM_S_SUCCESS;
	}

	if( om$is_ancestry_valid(	subclassid      = classId,
					superclassname  = "expression" )
				== OM_S_SUCCESS )
	{
		__DBGpr_com("The object is an expression");
		*msg = MSFAIL;
		End
		return OM_S_SUCCESS ;
	}

	range[0] = range[1] = range[2] = GRDGNLIMITS_MIN_D;
	range[3] = range[4] = range[5] = GRDGNLIMITS_MAX_D;

	End
	return(OM_S_SUCCESS);

}

end implementation GRvg;

