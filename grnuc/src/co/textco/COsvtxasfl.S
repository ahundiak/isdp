class specification COsvtxasfl (1:0) of CEO_LOCATE;



#ifdef SUNOS 
#include "sunlimits.h"
#endif

#include <limits.h>

/******************************************************************************

Description:

    This command writes the text from an existing text element to an
ascii file.


Abstract class:      No.

Override methods:    None.

Messages:


History:  Bill Cecil     08/24/89  Design and Implementation

Algorithm:

Notes:

******************************************************************************/


instance COsvtxasfl
{
    struct IGRestx      text_attr;
    IGRuchar            *text_string;
    IGRchar             file_name[DI_PATH_MAX];
};


override init;

override delete;

message get_text (int strip_string);

message check_file ();

message write_text_to_file ();

end specification COsvtxasfl;
