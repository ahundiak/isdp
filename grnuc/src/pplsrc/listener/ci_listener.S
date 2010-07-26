/*

 Class specification for ci_listener
 Subclass of GRlistener 

 Abstract:
   This class provides a mean to link a CI file with an object of class GRnotify
   by connecting to the channel "notification". Messages collected from this
   channel are eventually converted into function calls in the related CI file.
   Therefore "ci_listener" objects appear to behave like filters.

 Message overridden, motivation:
    GRnotifylis
	Must eventually run the CI file previously loaded by CLplace.
    delete
	In addition to the object itself, the CI object must be deleted. This
	method is the most straightforward to remove the "link" built by
	CLplace.

 History:
    GARDELLA D.	03/15/88 :  creation.

*/

class specification ci_listener (0:1) of GRlistener;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

instance ci_listener
{
    channel { (many_to_one) }	to_graphic;
    struct GRid			ci_file;     /* file to run upon notification */
};

override GRnotifylis, delete;

/*
 * Connect to the graphic object, load the CI file, and set the value of the
 * reserved variable "GR_EXECUTOR" identifying the graphic object.
 */
message CLplace(struct GRid	graphic;	/* IN. Object to be monitored */
		IGRchar		*fname;		/* IN. CI file name */
		IGRint		*rc );		/* OUT. Return Code */

end specification ci_listener;
