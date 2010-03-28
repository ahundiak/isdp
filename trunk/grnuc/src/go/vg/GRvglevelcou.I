/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRlevelcount

     Abstract: 	This routine adds the byte count of this object 
	to the in the array position corresponding to the objects 
	level.  The array position in the object count is also 
	incremented to count the number of objects on each level.

-----
%SC%    
	GRlevelcount(msg,byte_count,object_count)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
     *byte_count   IGRlong	 array for byte count.  Size should
				 equal maximum number of levels 
				 allowed in an object space.
     *object_count IGRlong	 array for object count.  Size should
				 equal maximum number of levels 
				 allowed in an object space.

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
	The caller of this method is responsible for clearing the
	arrays before invoking the function.  This method only
	adds this objects information into information already
	present in the buffers.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     11/24/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method increments the byte count and the object count
	in the input arrays at array position equal to the  objects
	level.
----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRlevelcount(IGRlong *msg; IGRint *byte_count; 
	IGRint *object_count)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	byte_count[me->level] += me->OPPobjecthdr.i_size;
	++object_count[me->level];

	

	return(OM_S_SUCCESS);
}
end implementation GRvg;
