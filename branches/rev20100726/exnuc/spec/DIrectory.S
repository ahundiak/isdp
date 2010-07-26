/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a unix-like
  mechanism for the objects.

  HISTORY :
  -------

  03/18/1988 : HGB - Creation Date
  07/29/1988 : HGB - Override debug
  05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX

*/

class specification DIrectory ( 1:2 ) of DIbstob, GRoups, IGRdir;


 message untranslate ( DIint *status; DIobjid objid; DIchar *name );
   /* 
      This message is used to find a name given the objid, the name array 
      must be at least DI_PATH_MAX character long

      Argument description :
      --------------------

        DIint  *status          : the 	returned status		(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_W_NAME_NOT_FOUND : name duplicated
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error

        DIchar  *name           : the name of the object (this	(OUT)
				  array must contain at least
				  DI_PATH_MAX elements) 

        DIobjid objid          : the objid associated with	(IN)
				 the name
   */

   override i_find /* for boot strapping */, init, debug;

end specification DIrectory;
