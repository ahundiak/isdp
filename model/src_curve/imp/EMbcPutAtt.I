/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbcsubbc
     METHOD NAME:	GRputattr

     Abstract: 		

		This method loads the "class specific" attributes
	into a subcurve object.


-----
%SC%    

	GRputattr(msg,attr)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *attr	  IGRchar	 pointer to class attributes (should
				 actually point to a structure of 
				 type IGResbc)
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code message
				   MSSUCC if successful
				   GRINVMSG if class doesn't have 
					    special attributes     
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:				None.

     Methods:				None.
-----
%RL%

     RELATIONS REFERENCED:		None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	REJ 	06/16/86 : Creation date.
    dhm     02/22/88 : Added GR_NOTIFY_LISTENERS
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	Set bits in dp_props based on info in element specific attr.

----*/
/*EH*/

class implementation GRbcsubbc;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "igrdef.h"
/*#include "grdef.h"*/
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

method GRputattr(IGRlong *msg; IGRchar *attr)

{

	IGRlong OMreturn;
	struct IGResbc *bc_attr;

	*msg = MSSUCC;
	OMreturn = OM_S_SUCCESS;

	bc_attr = (struct IGResbc *) attr;

	if (bc_attr->is_polydis)
	{
	  ME.GRbcsubbc->dp_props |= GRIS_POLYDIS;
	}
	else
	{
	  ME.GRbcsubbc->dp_props &= ~GRIS_POLYDIS;
	}

	if (bc_attr->is_curvedis)
	{
	  ME.GRbcsubbc->dp_props |= GRIS_CURVEDIS;
	}
	else
	{
	  ME.GRbcsubbc->dp_props &= ~GRIS_CURVEDIS;
	}

    GR_NOTIFY_LISTENERS(msg, &OMreturn, GR_ATTR_MODIFIED);
	return(OMreturn);

}

end implementation GRbcsubbc;
