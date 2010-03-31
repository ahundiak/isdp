#define	MO_DATA 	1
#define NOMO_DATA	0

/*---------------------------------------------------------------------
NAME
        HSgetopt
        
DESCRIPTION
        Get the next option from the command line (and its data)
        and return that to the caller.
        
ARGUMENTS
        argc (IN): The number of fields on the command line
        argv (IN): Array of strings containing the command line fields
        delimeters (IN): String containing the list of charaters that
        	mark an option
        valid_options (IN):  String containing the list of valid options.
        option (OUT): The option key found on the command line
        option_data (OUT): The option data, if the option has data,
                NULL if the option does not have data.
                
RETURN VALUES
        TRUE:  There is more data from the command line to process
        FALSE:  There is no more data from the command line to process
        
HISTORY
        06/22/93	Created
                M. Lanier
-----------------------------------------------------------------------*/

extern int HSgetopt( int argc,
                    char *argv[],
                    char *delimeters,
                    char *valid_options,
                    char *option,
                    char **option_data );
