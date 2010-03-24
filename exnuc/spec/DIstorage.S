/*
   ABSTRACT :
   --------

   This abstract class implements a storage.  It has been written for the
   directory sub-system (IGRdir).  Note that an empty storage do not
   require any space but a pointer and a variable array descriptor.

   This class is a private class.

   
   HISTORY :
   -------

   05/23/1988 : H. BEQUET - Creation Date.
   04/09/1989 : H. BEQUET - New B-tree Design.
*/

class specification DIstorage (0:0) of Root;

#include "DItypedef.h"
#include "DIdef.h"	/* Same error messages as a directory 		*/


  message init ( DIint *status );
   /*
      This message must be sent to a storage when it is created.

      Argument description :
      --------------------

        DIint *status     : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error
    */


  message close ( DIint *status );
   /*
      This message must be sent to a storage when it is deleted.

      Argument description :
      --------------------

        DIint *status     : the returned status				(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error
    */


  message get_type ( DIint *type );
   /*
      This message is sent to a storage to get its type (must be overrided).

      Argument description :
      --------------------

        DIint *type        : a valid storage type (DIstorage.h)		(OUT)
    */


  message wakeup ( DIint *status );
   /*
      This message must be sent to a storage when it is loaded.

      Argument description :
      --------------------

        DIint *status          : the returned status			(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

    */


  message sleep ( DIint *status, keep );
   /*
      This message must be sent to a storage when it is saved.

      Argument description :
      --------------------

        DIint *status          : the returned status			(OUT)
                                      DIR_S_SUCCESS : successful operation
                                      DIR_E_ABORT   : directory error

        DIint keep             : keep information or not 		(IN)
                               If this flag is on, the memory
                               WON'T be freed.
    */


  message is_empty ( DIint *status );
   /*
      This message is used to find if the storage is empty

      Argument description :
      --------------------

        DIint *status          : the returned status			(OUT)
                                      DIR_S_SUCCESS : the storage is empty
                                      DIR_E_ABORT   : the storage is NOT empty
    */



  message list ( DIint *status; DIchar *reg_exp; DIint *count; DIint (*driver) () );
   /* 
      This message is used to list the entries of the B-tree.  The
      driver function will be called for each node.  The driver must
      have two arguments : a character (the value of me->tree->type)
      and a pointer to the node, casted to a pointer to character.


      Argument description :
      --------------------

        DIint *status     : the returned status				(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error

        DIchar *reg_exp   : if not NULL, only the names			(IN)
				   that match this regular 
				   expression are given.

        DIint *count      : the number of listed entry 			(OUT)

        DIint driver ()   : a function that will be called for		(IN)
                            each node
   */

 message store_info ( DIint *status; DIchar *key, *info; DIint *p_index );
   /*
      This message is used to store an information with its key or its index 
      in the selected storing system 

      Argument description :
      --------------------

        DIint *status	: the returned status				(OUT)
                    		DIR_S_SUCCESS : successful operation
                      		DIR_E_ABORT   : directory error

        DIchar *key	: the key to be used				(IN)

        DIchar *info	: the information to be stored   		(IN)

	DIint  *p_index	: the index the entry has been put in		(OUT)
   */


 message retrieve_info ( DIint *status; DIchar *key; DIint index; DIchar *info;
                         DIchar *name; DIint *p_index );
   /* 
      This message is used to retrieve an information giving its key or its index

      Argument description :
      --------------------

        DIint *status 	: the returned status				(OUT)
          			DIR_S_SUCCESS : successful operation
                       		DIR_E_ABORT   : directory error

        DIchar *key 	: the key to be used				(IN)

	DIint index	: the index to be used				(IN)

        DIchar*info	: the retrieved information 			(OUT)

	DIchar *name	: the name of the entry (if any)		(OUT)

	DIint *p_index	: the index of the entry			(OUT)
   */



 message remove_info ( DIint *status; DIchar *key; DIint index );
   /* 
      This message is used to remove an information giving its key or its index

      Argument description :
      --------------------

        DIint *status	: the returned status				(OUT)
                        	 DIR_S_SUCCESS : successful operation
               			DIR_E_ABORT   : directory error

        DIchar *key 	: the key to be used				(IN)

	DIint index	: the index to be used				(IN)
   */


  reject init, get_type, wakeup, sleep, is_empty, store_info, remove_info,
         retrieve_info, list, close;


end specification DIstorage;
