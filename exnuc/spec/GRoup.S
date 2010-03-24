/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a group
  protection/privileges mechanism for the objects.  The principle
  is very straigthforward : there are three kinds of groups :

         o public
           anybody can read/write objects of this class.

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

class specification GRoup ( 0:0 ) of Root;

#include "GRtypedef.h"
#include "GRdef.h"
#include "GRglob.h"

  instance GRoup
  {
    GRchar passwd [6]	/* the password attached to the group		*/;
    GRchar type		/* the group may be public, read only,
                           or private					*/;
  };


  message init ( GRint *status, type; GRchar *passwd, *groupname );
   /*
      This message must be sent to a group when it is created.

      Argument description :
      --------------------

        GRint *status	        : the returned status			   (OUT)
                                    GR_S_SUCCESS : successful operation
                                    GR_E_OVFLOW  : password is too long
                                    GR_E_ABORT   : directory error

        GRint type	        : a valid group type (GRdef.h)		   (IN)

        GRchar *passwd          : the password of the group (max 5 char)   (IN)

        GRchar *groupname       : the name of the group to initialize      (IN)
    */


  message get_type ( GRint *type );
   /*
      This message is sent to a group to get its type.

      Argument description :
      --------------------

        GRint *type             : a valid group type (GRdef.h)		(OUT)
    */


  message change_passwd ( GRint *status; GRchar *old_passwd, *new_passwd,
						*groupname );
   /*
      This message is sent to a group to change its password.  The old
      password MUST be valid.

      Argument description :
      --------------------

        GRint *status		: the returned status			(OUT)
                                    GR_S_SUCCESS : valid password
                                    GR_E_ABORT   : non-valid password

        GRchar *old_passwd	: the old password 			(IN)

        GRchar *new_passwd	: the new password 			(IN)

        GRchar *groupname 	: the name of the group to alter 	(IN)
    */


  message check_passwd ( GRint *status; GRchar *passwd; GRchar *groupname );
   /*
      This message is sent to a group to check its password against password.

      Argument description :
      --------------------

        GRint *status	        : the returned status			(OUT)
                                    GR_S_SUCCESS : valid password
                                    GR_E_ABORT   : non-valid password

        GRchar *passwd	        : the password candidate		(IN)

        GRchar *groupname       : the name of the group to check        (IN)
    */


end specification GRoup;
