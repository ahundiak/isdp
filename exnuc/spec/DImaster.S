/*

   ABSTRACT :
   --------

   This class supports the directory of directories mechanism.  It is
   defined for internal use only.

   HISTORY :
   -------

   03/20/1987 : HGB - Creation Date
   03/18/1988 : HGB - Move to OM
   07/29/1988 : HGB - Override debug
*/

class specification DImaster ( 1:2 ) of DIbstgr, IGRdir;

 message give_pointer ( DIchar *key, **ptr );
   /*
      This message is used to get the address of a directory name (for the untree)

      Argument description :
      --------------------

        DIchar *key	: the key to be used				(IN)

        DIchar **ptr	: the pointer					(OUT)
   */

  override retrieve_info, IGRdir.init, debug;

end specification DImaster;
 

