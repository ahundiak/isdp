class specification COgetcmd (1:0) of super_cmd;

#include <FI.h>

instance COgetcmd
{
    Form form;
};

override wakeup, execute, sleep, delete;

end specification COgetcmd;
