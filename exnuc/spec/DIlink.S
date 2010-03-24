/*
  ABSTRACT :
  --------

    The class DIlink handles the object space attachments for the
  directory sub-system.  In essence, it propagates the Directory
  messages to the root directory of the object space.


  HISTORY :
  -------

  07/27/1987 : HGB - Creation Date
  03/18/1988 : HGB - Move to OM
*/

class specification DIlink ( 1:2 ) of IGRdir;

instance DIlink
{
   DIgrid root	/* the root directory of that object space	*/;
};

override delete;



 message set_target ( DIint *status; DIgrid target );
   /*
      This message is used to divert all the messages that the links received
      to the object specified by the grid.

      Argument description :
      --------------------

        DIint  *status  : the returned status				(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error
        
        DIgrid target   : the target for the messages   		(IN)
   */


end specification DIlink;
