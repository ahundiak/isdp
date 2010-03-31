#include <stdio.h>
#include "HSgetopt.h"

#define	MO_DATA 	1
#define NOMO_DATA	0

static int current_field = 0;

/*---HSgetopt-----------------------------------*/

int HSgetopt( int argc,
             char *argv[],
             char *delimeters,
             char *valid_options,
             char *option,
             char **option_data )

    {
    char *field;
    int i;


    /* If the current_field pointer is equal to or greater than the  */
    /* number of fields on the command line, then there is nothing  */
    /* to parse. */

    if (++current_field >= argc)
        {
        current_field = 0;
        *option = 0;
        *option_data = NULL;
        return (NOMO_DATA);
        }


    /* If the first character of the current field is not '-' or '/', */
    /* then the field is assumed to contain data that is not part of  */
    /* any option.  Return the option flag of 0x7f which tells the    */
    /* caller that the data being returned is, un-optioned data       */

    field = argv[current_field];

    i = 0;
    while ((field[0] != delimeters[i]) && (i < strlen (delimeters)))  i++;
    if (i == strlen (delimeters))
        {
        *option = 0x7f;
        *option_data = argv[current_field];
        return (MO_DATA);
        }


    /* Try and match the second character in the field with one of the */
    /* characters in the valid option string.  If cannot, display an  */
    /* error, incriment the current_field counter and return  */

    i = 0;
    while ((field[1] != valid_options[i]) && (i < strlen (valid_options)))  i++;

    if (i == strlen (valid_options))
        {
        printf ("HSgetopt: Invalid option: %c\n", field[1]);
        *option = 0;
        *option_data = NULL;
        return (MO_DATA);
        }


    /* Found a valid character. Set the return variable, and  */
    /* check for data.  An option with data will be followed */
    /* by a ':' in the valid_options string */

    *option = field[1];
    if ((i >= strlen (valid_options)) || (valid_options[i + 1] != ':'))
        {
        	
        /*  The option is not defined to have data.  Return NULL  */
        /*  in the option_data variable  */
        
        *option_data = NULL;
        }
    else
        {
        	
        /*  The option is defined to have data.  If the user did not place  */
        /*  any 'white' space between the option and the data, then the data */
        /*  is in the same field, starting at the third character, else it  */
        /*  will be in the next field starting at the first character */
        
        if (strlen (field) > 2)
            {
            *option_data = &field[2];
            }
        else
            {
            	
            /*  If the option's field did not contain its data, and that  */
            /*  was the last field in the command line, then there is an error */
                
            if (++current_field == argc)
                {                	
                printf ("optarg: Option %c requires data\n", *option);
                *option_data = NULL;
                }
            else
                {
                *option_data = argv[current_field];
                }
            }
        }

    return (MO_DATA);
    }
