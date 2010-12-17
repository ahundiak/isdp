#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "DEBUG.h"

int record_status (file, title, item, revision, status)
    FILE *file;
    char *title;
    char *item;
    char *revision;
    int  status;

{
char data_line[256];
static char *fname = "record_status";

    _NFMdebug ((fname,  "ENTER\n"));

if (status == NFM_S_SUCCESS)
    {
    sprintf (data_line, "%s: %s.%s -> SUCCESS\n", title, item, revision);
    fputs (data_line, file);
    }
else
    {
    sprintf (data_line, "\n*** NFM_E_FAILURE *** %s: %s.%s -> %d\n\n",
             title, item, revision, status);
    fputs (data_line, file);
    }

return (NFM_S_SUCCESS);
}

