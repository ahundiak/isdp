/*
Name
        GRget_ingrhome

Description
        This function will return the first directory path to specified by
        INGRHOME, or set it based on the current machine if not found.

Synopsis
        char *GRget_ingrhome(char *arg)

        The function returns a pointer to a static string containing the
        INGRHOME directory.  It is only calculated once locally, so it is
        important that the caller not overwrite the string.  If arg is not
        NULL, then the INGRHOME string is copied there.

History
        mrm     11/12/93    creation, based on equivalent shell script
*/

#include <stdlib.h>
#include <string.h>

static char *p_INGRHOME = "INGRHOME";
static char *p_ingrhome = NULL;
static char *p_env_var = NULL;

char *GRget_ingrhome(char *arg)
{
    /* been here before? */
    if (p_ingrhome == NULL)
    {
        /* nope - check the environment */
        if (p_ingrhome = getenv(p_INGRHOME))
        {
            /* make sure not to return a list of directories */

            int len;
            char *c, *s;

            if (c = strchr(p_ingrhome, (int)':'))
            {
                /* make a local copy of the string & chop it after the first
                   directory in the list */
                len = c - p_ingrhome;
                s = malloc(len + 2);
                strncpy(s, p_ingrhome, len);
                s[len] = NULL;
                p_ingrhome = s;
            }
        }
        else
        {
            /* figure out INGRHOME based on machine */
#ifdef CLIX
            p_ingrhome = "/usr/ip32";
#endif
#ifdef IRIX
            p_ingrhome = "/var/opt/ingr";
#endif
#ifdef SUNOS5
            p_ingrhome = "/opt/ingr";
#endif

            /* slap INGRHOME into the environment, in case someone else
               looks for it later */
            p_env_var = malloc(strlen(p_ingrhome) + strlen(p_INGRHOME) + 4);
            sprintf(p_env_var, "%s=%s", p_INGRHOME, p_ingrhome);
            putenv(p_env_var);
        }
    }

    /* fill in output arg */
    if (arg)
        strcpy(arg, p_ingrhome);

    return(p_ingrhome);
}
