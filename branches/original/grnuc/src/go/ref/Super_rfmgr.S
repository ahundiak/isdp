/*
Name
        Super_rfmgr

Description
        This class serves as the manager object for reference file
        attachments.  There is a channel to the reference file attachment
        objects which are contained in this Object Space.  There is also a
        list of files which should be retrieved writable.

History	
	MAS  09/01/86  : Design date.
        SCW  05/08/92  : Ansi Conversion
        mrm  10/29/92    added force_add method for PDU
*/

class specification Super_rfmgr (1:1) of global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMminimum.h"
#include "gr.h"

instance Super_rfmgr
{
    channel {(rel_ordered,one_to_many,initial=1,increment=1)
		GRreffile.to_mgr;}  mgr;
    channel {(rel_ordered,one_to_many,initial=1,increment=1)
		GRcontext.to_super;}  to_context;

    /* list of writable files */
    variable char names [0];
};

message Super_passon( IGRlong *msg; OM_p_MESSAGE pass_msg);

message GRselectpass(IGRlong *msg; IGRulong *ref_properties_mask; 
   	IGRshort *pass_to_nested_attachments; OM_p_MESSAGE pass_msg; 
	IGRshort *mx_type; IGRdouble *matrix; GRobjid *module_id; 
	GRspacenum *module_osnum);

message GRget_channel_count(IGRlong *msg;
 	IGRulong *ref_properties_mask; 
	IGRshort *count_nested_attachments; IGRlong  *count);

message GRget_channel_objects(IGRlong *msg;
   	IGRulong *ref_properties_mask;
	IGRshort *get_nested_attachments;  IGRlong *objids_array_size; 
	GRobjid *objids; GRspacenum *osnums; IGRlong *num_objids_returned);

message add ( long *msg; char *file_name );
/*
      This message is defined to add a file name in the list.

      Argument description :
      --------------------

        long *msg      : the returned status				(OUT)
                                    MSSUCC: the file name was added
                                    MSFAIL: the file name was NOT added

        char *file_name: the file name 		        		(IN)
*/


message force_add ( long *msg; char *file_name );
/*
      This message is defined to add a file name in the list, with a special
      mark to indicate that failure to obtain UNIX write permission during
      retrieve should be silently ignored.

      Argument description :
      --------------------

        long *msg      : the returned status				(OUT)
                                    MSSUCC: the file name was added
                                    MSFAIL: the file name was NOT added

        char *file_name: the file name 		        		(IN)
*/


message remove_file_name ( long *msg; char *file_name );
/*
      This message removes the given file name.

      Argument description :
      --------------------

        long *msg      : the returned status				(OUT)
                                    MSSUCC: the file name was removed
                                    MSFAIL: the file name was NOT removed

        char *file_name: the file name 		        		(IN)
*/


message translate ( long *msg; char *file_name );
/* 
      This message is sent to find if a file name is in the list

      Argument description :
      --------------------

        long *msg      : the returned status				(OUT)
                                    MSSUCC: the file name is in the list
                                    MSFAIL: the file name is NOT the list

        char *file_name: the file name 		        		(IN)
*/

message force_translate ( long *msg; char *file_name );
/* 
      This message is sent to find if a file name is in the list with the
      special mark placed there by force_add.

      Argument description :
      --------------------

        long *msg      : the returned status				(OUT)
                                    MSSUCC: the file name is in the list
                                    MSFAIL: the file name is NOT the list

        char *file_name: the file name 		        		(IN)
*/

override debug, wake_up, sleep, super_construct;

end specification Super_rfmgr;
