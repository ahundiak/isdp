/* #######################    APOGEE COMPILED   ######################## */
class specification GRds (1:1) of global_class;
/********************************************************

Description:			
	The class GRds defines a global data object which manages drawing 
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
	Access to GRds data should be handled through the macros provided in
	in the file dsmacros.h.

	*** PRIVATE ***
	message dump ();
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
	8/31/88		Jay Wallingford		Creation Date
    11/9/93     jhw                 Added automatic convert to new class.

Bugs:
	None at present.

Algorithm:
	See inline comments.

Notes:
	Initially this class stored all strings in the ds_sheet and ds_standard
	structures in an object called IGRpack. This class of objects stored
	variable length strings without duplicates. During the development of 
	the I/DRAFT drawing sheet composition features a modification was made 
	to the makeup of the ds_sheet and ds_standard structure which reduced 
	by more than half the number of strings in those structures. As a result
	of this change the use of the IGRpack object as a storage mechanism for
	the strings became too cumbersome for the problem at hand.

	If the ds_sheet and ds_standard do change in the future to include more
	strings, thought should be given to using the IGRpack object as a storage
	mechanism. For source code see Jay Wallingford.

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

instance GRds
{
     IGRint                        default_standard;
     variable struct ds_standard   standard_tab[];
     variable struct ds_sheet      sheet_tab[];
};

/*
 * Messages.
 */
message dump();
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

override super_construct;

/*
 * This is a private message which converts an old GRds super
 * object into a new GRdsnew super object. The new drawing standards
 * manager class (GRdsnew) doesn't use the bit fields that the old 
 * class did and is thus allows portablity between hardware platforms.
 *
 * THIS IS A PRIVATE MESSAGE!!!!!
 */
message auto_convert (IGRlong     * msg;
                      struct GRid * GRdsnew_super_id);

end specification GRds;



