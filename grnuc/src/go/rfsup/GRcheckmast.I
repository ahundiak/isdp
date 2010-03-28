/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
     GRcheckmast -  This function checks to see if the requested
	reference file is the master file.


Synopsis
	IGRlong GRcheck_master_file(filename)

	IGRchar 	*filename;

Description

	This function uses the tables stored by the executive to
	determine if a file is the master file.
	
Diagnostics
	The return codes:
	    0 - file is not the master file
	    1 - file is the master file

Notes
	None.

History
	MAS	07/08/87	Design Date.
\*/

class implementation GRgraphics;

#include "grimport.h"
#include "exdef.h"

IGRlong GRcheck_master_file(filename)

IGRchar 	*filename;

{
    IGRlong	OMmsg;
    IGRint	i;
    IGRlong     is_master;

    OMuword	osnum;

    IGRchar	path_name[OM_K_MAXOSNAME_LEN];

    extern struct EX_visible_module  *module_table;
    
    is_master = 0;

    strcpy(path_name,filename);

    module_build_path(path_name);

    OMmsg = om$os_name_to_number(osname = path_name,
	p_osnum = &osnum);

    if ( 1 & OMmsg)
    {
        for (i = 0; i < EX_MAX_MODULES && (!is_master); ++i)
        {
	    if (module_table[i].obj_space_num == osnum)
	    {
	        is_master = 1;
	    }
	}
    }

    return( is_master );
}
end implementation GRgraphics;
