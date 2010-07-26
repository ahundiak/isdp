/*
Name
        COplotlog

Description
        This function is used to keep a logfile of shell commands
        executed by the plotting code.

History
        mrm     03/20/91    creation
*/

#include <stdio.h>
#include <stdlib.h>

#define TRUE    1
#define FALSE   0

#define FILENAME            "mdemplotlog"
#define FILENAME_LENGTH     (64)
#define DIR_LENGTH          (FILENAME_LENGTH - 16)  /* filename - / - NULL */

static short plotlog_on = FALSE;
static short checked_env = FALSE;

void COplotlog_on()
{
    plotlog_on = TRUE;
}

void COplotlog_off()
{
    plotlog_on = FALSE;
}

void COplotlog(string)
char *string;
{
    static char filename[FILENAME_LENGTH] = "";
    char *c;
    FILE *log;

    if (!checked_env)
    {
        if (c = getenv("PLOTLOG"))
        {
            plotlog_on = TRUE;
            strcpy(filename,c);
        }
        checked_env = TRUE;
    }
    if (plotlog_on)
    {
        if (filename[0] == NULL)
        {
            if (!((c = getenv("TMPDIR")) && (strlen(c) < DIR_LENGTH)))
            {
                c = "/usr/tmp";
            }
            sprintf(filename,"%s/%s", c, FILENAME);
        }
        if (log = fopen(filename, "a"))
        {
            fprintf(log,"%s\n",string);
            fclose(log);
        }
    }
}
