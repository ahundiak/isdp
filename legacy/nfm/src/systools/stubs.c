#include "machine.h"
#include <sys/types.h>
#include <sys/stat.h>

int Stat (path, buf)
    char *path;
    struct stat *buf;
{
return (stat (path, buf));
}

void Exit (status)
    int status;
{
exit (status);
}
