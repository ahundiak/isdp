/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   variable sub-system.  Note that an empty B-tree does not require
   any space but a pointer and a variable array descriptor.

   The key is a string and the date is a variable (see VRtypedef.h).

   
   HISTORY :
   -------

   11/10/1988 : H. BEQUET - Creation Date.
*/

class specification DIbstvar (0:0) of DIbst;

#include "DIdef.h"
#include "DItypedef.h"


 message store_variable ( DIint *status; DIchar *key; DIdata info );
   /*
      This message is used to store a variable with its key.


      Argument description :
      --------------------

        DIint *status : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

        DIchar *key   : the key to be used				(IN)

        DIdata  info  : the variable to be stored   			(IN)
   */


 message retrieve_variable ( DIint *status; DIchar *key; DIdata *info );
   /* 
      This message is used to retrieve a variable giving its key

      Argument description :
      --------------------

        DIint *status : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

        DIchar *key   : the key to be used				(IN)

        DIdata *info  : the retrieved variable 				(OUT)
   */


 message store_var_index ( DIint *status; DIint *index; DIdata info );
   /*
      This message is used to store a variable with its index in the
      selected storing system 

      Argument description :
      --------------------

        DIint *status : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

        DIint index   : the position of the variable			(IN)

        DIdata info   : the variable to be stored    			(IN)
   */


 message retrieve_var_index ( DIint *status; DIint index; DIchar *name; DIdata *info );
   /* 
      This message is used to retrieve a variable giving its index

      Argument description :
      --------------------

        DIint *status : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

        DIint index   : the index to be used				(IN)

        DIchar *name  : the retrieved name				(OUT)

        DIdata *info  : the retrieved variable 				(OUT)
   */


 message change_variable ( DIint *status; DIchar *key; DIdata info );
   /*
      This message is used to change a variable with its key.


      Argument description :
      --------------------

        DIint *status : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

        DIchar *key   : the key to be used				(IN)

        DIdata  info  : the variable to be changed   			(IN)
   */


  override wakeup, sleep, get_type, retrieve_info, remove_info, store_info,
           retrieve_info, retrieve_index, store_index, remove_index, list;

end specification DIbstvar;
