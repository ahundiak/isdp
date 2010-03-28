/* #######################    APOGEE COMPILED   ######################## */
class specification GRdsnew (1:1) of global_class;
/********************************************************

Description:			
	The class GRdsnew defines a global data object which manages drawing 
	sheet and drawing sheet	standard information. GRds is subclassed from
	global_class so it can take advantage of the ige macros for creating 
	supers. GRds contains a description of all drawing sheets and drawing
	sheet standards defined for a particular file.

Abstract class:			
	No

Override methods:
	from global_class
	
	super_construct

Motivation:

	super_construct - overridden to set the default standard to index 0.

Messages:
	Access to GRdsnew data should be handled through the macros provided in
	in the file dsmacros.h.

	*** PRIVATE ***
	message get_grds(
        	  IGRlong *msg;
	          IGRlong type;
        	  IGRchar *buffer);

	message put_grds(
        	  IGRlong *msg;
	          IGRlong type;
        	  IGRchar *buffer1;
	          IGRchar *buffer2);

	message del_grds(
        	  IGRlong *msg;
	          IGRlong type;
        	  IGRchar *buffer;
	          IGRlong num_ndxs);          

History:
	10/9/93		Jay Wallingford		Adapted from the original GRdsi.I

Bugs:
	None at present.

Algorithm:
	See inline comments.

********************************************************************/

#include <OMminimum.h>
#include <OMerrordef.h>
#include <OMmacros.h>
#include <OMprimitives.h>
#include <igrtypedef.h>
#include <igr.h>
#include <igrdp.h>
#include <igetypedef.h>
#include <gr.h>
#include <ex.h>
#include <exmacros.h> 
#include "dsdef.h"
#include "ds.h"

instance GRdsnew
{
     IGRint                        default_standard;
     variable struct GRds_standard standard_tab[];
     variable struct GRds_sheet    sheet_tab[];
};

/*
 * Private Messages.
 */
message get_grds(
          IGRlong *msg;
          IGRlong type;
          IGRchar *buffer);

message put_grds(
          IGRlong *msg;
          IGRlong type;
          IGRchar *buffer1;
          IGRchar *buffer2);

message del_grds(
          IGRlong *msg;
          IGRlong type;
          IGRchar *buffer;
          IGRlong num_ndxs);          

override super_construct, debug;

end specification GRdsnew;

