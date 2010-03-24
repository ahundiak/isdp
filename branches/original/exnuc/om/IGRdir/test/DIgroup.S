/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a unix-like
  mechanism for the graphics group.

  HISTORY :
  -------

  11/04/1988 : HGB - Creation Date
*/

class specification DIgroup ( 1:2 ) of DIbstch, GRoups, IGRdir;

  instance DIgroup
  {
    channel {(rel_ordered,many_to_many,initial=1,increment=1)
                DIbstch.to_components;} to_owners;
  };

 message untranslate ( DIint *status; DIobjid objid; DIchar *name );
   /* 
      This message is used to find a name given the objid, the name array 
      must be at least PATH_MAX_LENGTH character long

      Argument description :
      --------------------

        DIint  *status          : the 	returned status		(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_W_NAME_NOT_FOUND : name duplicated
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : DIgroup error

        DIchar  *name           : the name of the object (this	(OUT)
				  array must contain at least
				  PATH_MAX_LENGTH elements) 

        DIobjid objid          : the objid associated with	(IN)
				 the name
   */

   override i_find /* for boot strapping */, init, debug;

end specification DIgroup;
