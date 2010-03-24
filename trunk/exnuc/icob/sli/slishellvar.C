
/*
---------------------------------------------------------------------------

	Name:			shellvar.C
	Author:			Jeff Johnson	
	Creation Date:		Feb-25-1987
	Operating System(s):	Unix SYSV, v2

	Abstract:
	---------
		The function "expand_shell_vars(unexpanded_filename)"
	takes character strings "unexpanded_filename" as an arguments,
	in order to expand any "$SHELL_VARIABLES" contained in
	"unexpanded_filename".
			
			Tedious Examples
			----------------
		The function call expand_shell_vars("$AOSPATH/RedTruckAOS")
	would return "/usr2/wings/config/mod_type_2/RedTruckAOS" iff the
	shell variable "AOSPATH" was defined as "/usr2/wings/config/mod_type_2";
	otherwise, if "AOSPATH" were NOT defined, it would return simply
	"/RedTruckAOS".
	    Also, another really neato thing happens when you call
	expand_shell_vars("$SHELLVARIABLE/myfile"): the function looks
	up the shell variable value (if any) for "SHELLVARIABLE" and
	puts it in the string in front of "myfile" and then processes
	this new string. More than one shell variables can be included
	in the "unexpanded_filename" string, as in
	expand_shell_vars("$SHELL1/$SHELL2/junk/$SHELL3")
	although nobody will probably ever do that anyway (but they
	should, at least once, since I went to all that trouble).


        Notes:
	------


	Revision History:
	-----------------
	Feb-25-1987	jaj	Creation date for KRB.
	Jun-12-1987	jaj	Modified this for ODE use with load/dump-aos.

---------------------------------------------------------------------------
*/

#include <stdio.h>


/*==============================================================*/
/*		function expand_shell_vars			*/
/*==============================================================*/
char * expand_shell_vars(unexpanded_filename)	/*  see Notes section above  */
   char * unexpanded_filename;			/*  for description	*/
{
static  char	temp_filename[256];	/*  the expanded pathname returned */
    char	shellvariable[132];
    char	shellvariablevalue[132];
    char   *	temp;
    int		ii,jj;


    /***  expand all "$SHELLVARIABLE"s in the unexpanded_filename  ***/
    for ( ii = 0, temp = unexpanded_filename; * temp ; ii++, temp ++ )
      {
	if ( * temp == '$' )
	  {
	    char *temp_env = 0;

	    temp ++;

	    for ( jj = 0;
		    *temp != '/'  &&  *temp != '$'  &&  *temp ;
							jj++, temp ++ )
		shellvariable[jj] = *temp;
	    shellvariable[jj] = '\0';
	    temp_env = (char *)getenv(shellvariable);
            if (temp_env)
	       strcpy(shellvariablevalue,temp_env);
            else
               shellvariablevalue[0] = 0;
	    if ( shellvariablevalue[0] != 0 )
	      {
		temp_filename[ii] = '\0';
		strcat(&temp_filename[ii], shellvariablevalue );
		ii = strlen(temp_filename) - 1;
	      }
	    else
	      {
		ii--;
	      }
	    temp --;
	  }
	else
	  {
	    temp_filename[ii] = * temp;
	  }
	
      }   /**  end of for loop **/
    temp_filename[ii] = '\0';

    return(temp_filename);

}  /***  end of function expand_shell_vars  ***/

