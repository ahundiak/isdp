/*

 Class specification for ci_executor
 Subclass of GRlistener 

 Abstract:
   This class provides a mean to link a CI file with an object of class GRnotify
   by connecting to the channel "notification". Messages collected from this
   channel are eventually converted into function calls in the related CI file.
   Therefore "ci_executor" objects appear to behave like filters.

 Message overridden, motivation:
    GRnotifylis
	Must eventually run the CI file previously loaded by CLplace.
    delete
	In addition to the object itself, the CI object must be deleted. This
	method is the most straightforward to remove the "link" built by
	CLplace.

 History:
    GARDELLA D.	03/15/88 :  creation.
    E BEEKER: 03/25/88: modification of ci_listener to deal
			with the event queue

*/
class specification ci_executor (0:1) of GRlistener;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#define MAX_LENGTH_FOR_CI_NAME	128

instance ci_executor
{
    channel { (many_to_one) }	to_graphic;
    struct GRid			user_data;
		/* to keep data if necessary */
    char			ci_file_name[MAX_LENGTH_FOR_CI_NAME]; 
		/* file to run upon notification */
};

override GRnotifylis;

/*
 * Connect to the graphic object, load the name of the CI file
 * into the instance data
 */
message CI_ex_load(struct GRid		GR_exec;	/* IN. Object to be monitored */
		   struct GRid		user_data;
		   IGRchar		*ci_fname;	/* IN. CI file name */
		   IGRint		*rc );		/* OUT. Return Code */

end specification ci_executor;
