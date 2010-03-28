/*
Name
        GRingrconfig

Description
        This file contains a function to return the product name field from
        $INGRHOME/ingrconfig, given the product number.

History
        mrm     12/01/92    creation
        mrm     11/15/93    INGRHOME changes
*/

#include <stdio.h>
#include <string.h>

#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

int GRget_product_name(id, name)
char *id;       /* input - product id number */
char *name;     /* output - product name */
{
    int n, sts = FALSE;
    char buf[1024], *c, *b, *e;
    FILE *fp;

    /* open the file */
    sprintf(buf, "%s/ingrconfig", GRget_ingrhome(NULL));
    if (fp = fopen(buf, "r"))
    {
        /* read each line, looking for a matching product number */
        n = strlen(id);
        while (fgets(buf, sizeof(buf), fp))
        {
            if (strncmp(buf, id, n) == 0)
            {
                if (c = strchr(buf, '#'))
                {
                    c++;
                    if (b = strchr(c, '#'))
                    {
                        *b = NULL;
                        b++;
                        if (e = strchr(b, '#'))
                        {
                            *e = NULL;

                            /* substitute a / for the _ in the product name */
                            if (*(c + 1) == '_')
                                *(c + 1) = '/';

                            sprintf(name, "%s: %s", c, b);
                            sts = TRUE;
                        }
                    }
                }
                break;
            }
        }
    }

    if (!sts) 
        /* use input name as a default answer */
        strcpy(name, id);
    fclose(fp);
    return(sts);
}
