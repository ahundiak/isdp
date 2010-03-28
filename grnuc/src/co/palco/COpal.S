class specification COpal (1:0) of COtools, CEO_LOCATE;



#ifdef SUNOS 
#include "sunlimits.h"
#endif

#include <coimport.h>
#include <FI.h>
#include <limits.h>
#include "palgo.h"
#include "palco.h"


instance COpal
{
    int     label;
    int     rows;
    int     cols;
    int     num_cmds;
    char    name[DI_PATH_MAX];
    char    cmd[PAL_MAX_CMD_LENGTH];
    int     cmd_type;
    char    symbol_file[DI_PATH_MAX];
    int     symbol;
    struct palette *p;
};


override arg_name_to_value;

message COpal_startup ( long * sts );

override status_disp;

message COpal_func (int func);

override form_notification;

message set_gadgets ();

end specification COpal;
