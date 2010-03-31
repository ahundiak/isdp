/*
Name
        GRget_product_data

Description
        This function is really get_modtype_data, pulled from
        $EXNUC/exec/exec/mod_type.C

History
        mrm     07/02/92    ripped out of EXNUC
*/

#include <stdio.h>
#include <string.h>

#define TRUE    1
#define FALSE   0

int GRget_product_data(run_name,logo_ptr,module_class,srch_path,
                     config_path,product_path )
char *run_name;
char *logo_ptr;
char *module_class;
char *srch_path;
char *config_path;
char *product_path;
{
    char buffer[256];
    char runname[30];
    int numread;
    char *quot1, *quot2;
    int name_found;
    FILE *file_ptr;

    name_found = FALSE;
    sprintf(buffer, "%s/product_data", GRget_ingrhome(NULL));
    file_ptr=fopen(buffer,"r");
    if (file_ptr!=0)
    {
        while( fgets(buffer,256,file_ptr) != 0)
        {
            if((buffer[0] == '#') || (buffer[0] == ' ') || (buffer[0] == '\t')
               || (buffer[0] == '\n'))
                continue;

            runname[0] = '\0';
            if( strchr( buffer, '"' ) )
            {
                /* get run name */
                quot1 = strchr(buffer,'"');
                quot2 = strchr(quot1+1,'"');
                if ( quot2 )    /* second '"' found */
                {
                    strncpy(runname,quot1+1, quot2 - quot1 - 1);
                }
                else
                {
                    printf("missing double quote in product_data\n");
                }
                *(runname+(quot2-quot1-1))='\0';
            }

            if(strcmp(runname, run_name) == 0 )
            {
                name_found = TRUE;
                if ( logo_ptr != NULL)
                {
                    sscanf(buffer,"%*s %s %*s %*s %*s",logo_ptr);
                }
                if ( module_class != NULL)
                {
                    sscanf(buffer,"%*s %*s %s %*s %*s",module_class);
                }
                if ( srch_path != NULL)
                {
                    sscanf(buffer,"%*s %*s %*s %s %*s",srch_path);
                }
                if ( config_path != NULL)
                {
                    sscanf(buffer,"%*s %*s %*s %*s %s",config_path);
                    if( config_path[strlen(config_path)-1] != '/')  strcat(config_path, "/");
                }
                if ( product_path != NULL)
                {
                    numread=sscanf(buffer,"%*s %*s %*s %*s %*s %s",product_path);
                    if (numread == -1 )
                    {
                        numread=sscanf(buffer,"%*s %*s %*s %*s %s %*s",product_path);
                        if( numread == -1 ) printf("get_product_path: can not get product_path\n");
                    }
                    if(( numread != -1 ) && ( product_path[strlen(product_path)-1] != '/'))
                        strcat(product_path, "/");
                }

                break;
            }                   /* if(run_name eq runname) */
        }                       /* while loop */
        fclose(file_ptr);
    }                           /* if (file_ptr!=0) */
    return( name_found ? 1 : 0);
}                               /* get_modtype_data */
