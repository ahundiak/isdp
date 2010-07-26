/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a group
  protection/privileges mechanism for the objects.  The principle
  is very straigthforward : there are three kinds of groups :

         o public
           anybody can read and write objects of this class.

         o read only
           anybody outside the group can read objects of this class.

         o private
           nobody outside the group can read/write objects of this class.

  There is the concept of the current group.  When a group is current,
  all the objects of this group are read/write.  A password may be
  attached to a group in order to restrict its access.

  HISTORY :
  -------

  03/31/1988 : HGB - Creation Date

*/

class specification GRoups ( 0:0 ) of Root;

/*#include <stdio.h>*/
#include "GRtypedef.h"
#include "GRdef.h"
#include "GRglob.h"

  instance GRoups
  {
    GRchar index	/* Group index */;
  };


 message init ( GRint *status );
   /*
      This message is used to initialize the group index to the current
      group index.

      Argument description :
      --------------------

        GRint *status          : the returned status			(OUT)
                                   GR_S_SUCCESS : successful operation
   */


 message give_group ( GRint *status; GRint *group_ind );
   /*
      This message is used to return my group index.

      Argument description :
      --------------------

        GRint *status          : the returned status			(OUT)
                                   GR_S_SUCCESS : successful operation
                                   GR_E_ABORT   : group error

        GRint *group_ind       : the group index			(OUT)
   */


 message change_group ( GRint *status; GRchar *passwd );
   /*
      This message is used to change the group to the current one.

      Argument description :
      --------------------

        GRint  *status         : the returned status			(OUT)
                                   GR_S_SUCCESS : successful operation
				   GR_E_PASSWD  : the password is wrong
                                   GR_E_ABORT   : group error

        GRchar *passwd	       : the previous group password		(IN)
   */


 message validate ( GRint *status; GRchar type );
   /*
      This message is used to validate an operation depending on my group
      and the active group.

      Argument description :
      --------------------

        GRint  *status         : the returned status			(OUT)
                                   GR_S_SUCCESS   : valid operation
				   GR_E_PRIVATE   : the group is private
			           GR_E_READ_ONLY : the group is read only
                                   GR_E_ABORT     : group error

        GRchar type	       : the type of the operation (GRdef.h)	(IN)
   */


end specification GRoups;
