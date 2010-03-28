#include <ctype.h>
#include <string.h>

#include "igrtypedef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "griodef.h"

#include "numstr.h"   /* defining prototype file */

IGRboolean numstr(msg,old_str,new_str,max_len,num_str,new_strlen)

IGRlong *msg;
IGRchar **old_str;
IGRchar **new_str;
IGRint  max_len;
IGRint  num_str;
IGRint  *new_strlen;

{

IGRboolean look_flag = TRUE;
IGRshort i,j,length;
IGRchar neg;
IGRchar temp[GRIO_MAX_ALIAS_SIZE];
IGRchar *old;
IGRchar *old_start;
IGRchar *new;
IGRint *new_len;
IGRboolean status = TRUE;

    *msg = MSSUCC;
    neg = '-';
    for(i = 0; i < num_str; i++ )
    {
	old = *(old_str + i);
	new = *(new_str + i);
	new_len = new_strlen + i;
	for(j = 0; look_flag == TRUE && j < max_len; ++j)
	{
	    if ((isdigit (*old)) || 
			(*old == neg ))
	    {
		look_flag = FALSE;
	    }
	    old++;
	}
	old_start = old - 1;
	if (j == max_len)
	{
	   *msg = MSFAIL;
	   status = FALSE;
	   goto fini;
	}
	length = strlen (old_start);
	look_flag = TRUE;
	if (j >= max_len)
	{
	   *msg = MSFAIL;
	   status = FALSE;
	   goto fini;
	}
	old = old_start + length;
	for(j = length; look_flag == TRUE; --j)
	{
	    old--;
	    if (isdigit (*old))
	    {
		look_flag = FALSE;
	    }
	}
	*new_len = old - old_start + 1;
	OM_BLOCK_MOVE (old_start,temp,*new_len); 
	OM_BLOCK_MOVE (temp,new,*new_len); 
	*(new + *new_len) = '\0';
	look_flag = TRUE;
    }		
    fini:
    return (status);
}

