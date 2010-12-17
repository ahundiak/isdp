#include "machine.h"
#include "WFG.h"

/* This function assumes that the in_str is null terminated */

void WFGtic_it (in_str, out_str)
    char  *in_str;
    char  *out_str; 
{
    static  char *fname = "WFGtic_it";

    _NFMdebug ((fname, " in_str = <%s>\n", in_str));

    out_str[0] = '\0';

    while( *in_str )
    {
	if( *in_str == '\'' )
	{
	    *out_str = '\'';
	    ++out_str;
	}
	*out_str++ = *in_str++;
    }    
    *out_str = '\0';
    return;
}
