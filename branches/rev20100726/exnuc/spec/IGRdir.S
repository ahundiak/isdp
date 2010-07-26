/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a directory
  mechanism for the objects. This class is intended to be an abstract
  class where the necessary messages and the methods common to all kinds
  of storage are defined.  The key is assumed to be a string, but the
  data may be anything (objid, grid, ...)

  HISTORY :
  -------

  02/09/1987 : HGB - Creation Date
  06/22/1987 : HGB - Handle any kind of objects
  01/20/1988 : HGB - start_ls, start_find, fetch_ls, fetch_find
  03/18/1988 : HGB - Move to OM
  05/02/1988 : HGB - Protection and indexing
  09/07/1988 : HGB - Override delete to send it to storage

*/

class specification IGRdir ( 1:2 ) of Root;

/*#include <stdio.h> */

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"


 /* The following messages are defined for internal use only
    ======================================================== */

 message i_find ( DIint  *status; 
                  DIchar *my_name;
                  DIchar **exp_buf;
                  DIint  buf_count;
                  DIint  level;
                  DIint  max_level;
                  DIint  *deep;
                  DIchar ***lines;
                  DIgrid **grids; 
                  DIint  *count;
                  DIchar options );
   /* 
      This message is used to find the entries of my directory and my
      sub-directories that match the regular expression

      Argument description :
      --------------------

        DIint *status           : the 	returned status		  	(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error

        DIchar *my_name         : the name of the directory       	(IN)
                                  (to avoid an untranslate)

        DIchar **exp_buf        : the compiled regular expression 	(IN)

        DIint  buf_count        : number of buffers for regular   	(IN)
                                  expressions (used with '|')

        DIint  level            : the level of the target directory 	(IN)

        DIint  max_level        : the maximum level of search     	(IN)

        DIint  *deep            : the deep of the search          	(OUT)

        DIchar ***lines         : if specified, the entires are 
                                  listed in this array            	(OUT)

        DIgrid **grids          : the grids of the listed enties	(OUT)

        DIint *count            : the number of listed entry; its
				  value must be set to 0 
				  (*count = 0) before the call    	(OUT)

        DIchar options          : two options are valid,          	(IN)

                                       o OPT_ALL : the names starting with
                                                   a dot (.) are displayed

                                       o OPT_LEVEL   : the display is indented
                                                       to reflect the directory
                                                       structure
   */


 /* General naming capabilities : the following messages can be used as
    ---------------------------   a name manager interface; the error
                                  messages are defined in DIdef.h    */

 message init ( DIint *status );
   /*
      This message is used to initialize a directory.

      Argument description :
      --------------------

        DIint *status          : the 	returned status			(OUT)
                                      DIR_S_SUCCESS : successful operation
   */


 message ls ( DIint *status; DIchar *reg_exp; DIchar ***lines; 
              DIint *count; DIchar options );
   /* 
      This message is used to list the entries (objects + directories)
      of the directory.  If a regular expression is given, only the 
      names that match it are returned.


      Argument description :
      --------------------

        DIint *status            : the 	returned status			(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error

        DIchar *reg_exp          : if not NULL, only the names		(IN)
				   that match this regular 
				   expression are given.

        DIchar ***lines          : if not NULL, the entries are		(OUT)
				   listed in this array

        DIint *count             : the number of listed entry        (IN/OUT)
                                   *count MUST be set to 0

        DIchar options           : one option is valid,			(IN)

                                       o OPT_ALL : the names starting with
                                                   a dot (.) are displayed
   */


 message find ( DIint  *status; DIchar *reg_exp; DIchar ***lines; DIgrid **grids;
                DIint *count; DIint  max_level, *deep; DIchar options );
   /* 
      This message is used to find the entries of my directory and my
      sub-directories that match the regular expression

      Argument description :
      --------------------

        DIint *status           : the returned status			(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error


        DIchar *reg_exp         : must be specified; only      		(IN)
				  the names that match this 
				  regular expression are given.


        DIchar ***lines         : if specified, the entires are 	(OUT)
	   		          listed in this array

        DIgrid **grids          : the grids of the listed enties	(OUT)

        DIint *count            : the number of listed entry;		(OUT)
				  its value must be set to 0 
				  (*count = 0) before the call

        DIint  max_level        : the maximum level of search 		(IN)
				  (< 0 means no limit)

        DIint  *deep            : the effective deep of the 		(OUT)
				  search (<= max_level)

        DIchar options          : two options are valid,		(IN)
                                       o OPT_LEVEL   : the display is indented
                                                       to reflect the directory
                                                       structure

                                       o OPT_ALL : the names starting with
                                                   a dot (.) are displayed
   */


 /* Object naming capabilities : the following messages can be used as an object
    --------------------------   naming / indexing manager interface; the error
                                 messages are defined in DIdef.h    */

 message add ( DIint  *status; DIchar *name; DIobjid objid; DIint *p_index );
   /*
      This message is defined to add the objid to the target directory; 
      if specified, its name must not be in the target directory

      Argument description :
      --------------------

        DIint  *status          : the returned status			(OUT)
                                    DIR_S_SUCCESS : successful operation
                                    DIR_I_REORG   : successful operation,
                                                    storage modified
                                    DIR_E_NAME_DUP: name duplicated
                                    DIR_E_OVFLOW  : overflow error
                                    DIR_E_SYNTAX  : syntax error
                                    DIR_E_ABORT   : directory error

        DIchar  *name           : the name of the object        	(IN)

        DIobjid objid           : the objid to be added         	(IN)

        DIint   *p_index	: the index of the object 		(OUT)
   */


 message remove ( DIint *status; DIchar *name; DIint index );
   /*
      This message removes the given object (by name or by index) from the directory.

      Argument description :
      --------------------

        DIint  *status	: the returned status				(OUT)
                         	DIR_S_SUCCESS        : successful operation
                                DIR_W_NAME_NOT_FOUND : name missing
                                DIR_E_SYNTAX         : syntax error
                                DIR_E_ABORT          : directory error

        DIchar  *name	: the name of the object to be removed        	(IN)

        DIint index	: the name of the object to be removed        	(IN)
   */


 message translate ( DIint *status; DIchar *name; DIint index; DIchar *p_name; DIobjid *objid );
   /* 
      This message is sent to translate a name / index into an objid

      Argument description :
      --------------------

        DIint *status	: the returned status				(OUT)
				DIR_S_SUCCESS        : successful operation
				DIR_W_NAME_NOT_FOUND : name NOT found
				DIR_E_OVFLOW         : overflow error
				DIR_E_SYNTAX         : syntax error
				DIR_E_ABORT          : directory error

        DIchar *name	: the name of the object 			(IN)

        DIint index	: the index of the object	 		(IN)
                          if name is specified then index is ignored

        DIchar *p_name	: the name of the object (when index is used)	(IN)
                          p_name can be NULL

        DIobjid *objid	: the objid associated with the name    	(OUT)
   */


 message unindex ( DIint *status; DIint *index; DIchar *name; DIobjid objid );
   /* 
      This message is sent to translate a name (or an objid) into an index

      Argument description :
      --------------------

        DIint  *status          : the 	returned status			(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_W_NAME_NOT_FOUND : name NOT found
                                    DIR_E_ABORT          : directory error

        DIint *index            : the index of the name 		(OUT)

        DIchar *name		: the object name			(IN)

        DIobjid objid		: the object objid			(IN)
   */


 message dump ( DIint *status; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; DIchar options );
   /* 
      This message is used to list the entries (objects + directories)
      of the directory.  If a regular expression is given, only the 
      names that match it are returned.

      Argument description :
      --------------------

        DIint *status            : the 	returned status			(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error

        OM_p_CLASSLIST classlist : list of classes that must or 	(IN)
                                   must not be returned

        DIchar *reg_exp          : if not NULL, only the names		(IN)
				   that match this regular 
				   expression are given.

        DIchar ***lines          : if not NULL, the entries are		(OUT)
				   listed in this array

        DIgrid **grids           : the grids of the objects     	(OUT)

        DIint *count             : the number of listed entry       (IN/OUT)
                                   *count must be set to 0

        DIchar options           : one option is valid,			(IN)

                                       o OPT_ALL : the names starting with
                                                   a dot (.) are displayed.

                                       o OPT_TRAILER : a trailer is added at
                                                       the end of the names.
   */



 message pass ( DIint *status; OM_S_MESSAGE msg; OM_E_WRT_FLAG flag;
                DIchar *reg_exp; OM_p_CLASSLIST classlist );
   /*
      This message will send msg to the objects of the target directory, 
      eventually restricted by classlist 

      Argument description :
      --------------------

        DIint *status            : the 	returned status			(OUT)
                                    DIR_S_SUCCESS        : successful operation
                                    DIR_E_OVFLOW         : overflow error
                                    DIR_E_ABORT          : directory error

        OM_p_CLASSLIST classlist :  list of classes that must or 	(IN)
                                   must not be returned

        DIchar *reg_exp          : if specified, only the names 	(IN)
				   that match this regular
				   expression are given.

        OM_S_MESSAGE msg         : the message to be send		(IN)

        OM_E_WRT_FLAG flag       : the mode to be used to send		(IN)
				   the message
   */


  override delete;

end specification IGRdir;
