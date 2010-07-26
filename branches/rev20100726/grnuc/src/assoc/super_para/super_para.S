/*
    ABSTRACT

    This super object is created as soon as associative elements are created.
    Its aim is to initialize what as to be initialize each time the mode
    receives a wakeup, and to send an NDsleep message to the associative 
    element when the module receives a sleep message.
*/
  
 
     

    
class specification super_para (0:1) of global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "DIdef.h"

#define ACWD_PATH_MAX 256


instance super_para 
{
  variable char ACpath[0];
  char ACwd [ACWD_PATH_MAX];
};

/*
  ABSTRACT

  The following messages give access to the instance data of this
  object. The arguments are self describing. Note that the memory
  for the output must be supplied by the caller -- 1) path, size of
  string in bytes obtained by give_path_size. Caller must supply atleast
  size+1 to hold the NULL terminator, 2) wd, the current work directory
  can have a max size of ACWD_PATH_MAX.
*/

message give_path_size (IGRint *size);

message give_path (IGRchar *path);

message give_wd (IGRchar *wd);



override super_construct,	/* Initialization for associative variables */
			  	/* before creating first associative object */
         wake_up,		/* Initialization for associative variables */
				/* when a design file already exists.       */
	 sleep;			/* Cleanning before to save a design file   */


end specification super_para;
 

