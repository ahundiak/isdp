/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPgetggid

          Abstract:   This routine will return window id in the array
                      if the name matches.
----
%SC%

     VALUE = DPgetggid(msg,name,numid,wnid )
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      name		*IGRchar                  name to be matched
----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
       wnid[]          GRid                   array of window id's 
----
%MD%
 
     MODULES INVOKED:  

----
%NB%

      NOTES:   you should declare   struct GRid wnid[40];

----
%CH%

       HT   06/17/86   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

this routine will match the input name with window name in instance
data. If it matches then put window in into the wnid array and add 1
to the numid. The name may be of the form  win[a-z]e, win*, win?ow 
or win[abcd].

win[a-z]e will match name starts with "win" and any character between 
a and z then ends with e.

win* will match any name starts with "win"

win?ow will match any name starts with "win" then any single
character and then "ow"
 
win[abcd] will match any name starts with "win" and any one
character that apperaed within the brackets.

---*/
/*EH*/

class implementation IGEgragad;

#include <string.h>

#include "grimport.h"
#include "igetypedef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "exdef.h"
#include "ex.h"
#include "dpdef.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

/* prototype files */
%safe
#include "DPgetggid.h"
#include "DPgetid.h"
/* #include "DIstring.h" -> include when the prototype file is fixed */
%endsafe


IGRint DPgetggid(msg,mod_grid,name,array_size,total_num,numid,gg_id,type_gragad,search_priority)

IGRlong *msg;
struct GRid *mod_grid;
IGRchar *name;
IGRint  array_size;
IGRint  *total_num;
IGRint *numid;
struct GRid *gg_id;
IGRint type_gragad;
IGRchar *search_priority;


{
    IGRint  status = 1;
    IGRint  num_windows;
    struct GRid wn_list[EX_MAX_WINDOW];   
    GRspacenum osnum;
    GRspacenum *p_osnum;
    IGRlong pass_numid;
    IGRlong pass_totalnum;
    IGRchar path[DI_PATH_MAX];      
    IGRchar pathname[DI_PATH_MAX];  
    IGRchar cur_path[DI_PATH_MAX];  
    IGRchar *search_path;
    IGRchar *blank_char;
    IGRboolean col_win_flag;
    IGRboolean search = TRUE;
    IGRint num_char;
    IGRlong copy_num;
    struct GRid *p_ids;
    GRobjid mod_objid;
    DIint  i, om_st, sts, count;
    DIgrid grid;


    search_path = search_priority;
    p_ids = gg_id;
    *numid = 0;
    if (total_num != NULL)
    {
	*total_num = 0;
    }
    if (mod_grid == NULL)
    {
   	p_osnum = NULL;
    }
    else
    {
	osnum = mod_grid->osnum;
	p_osnum = &osnum;
    }
    if (strlen(name) == 0)
    {
	status = 0;
	search = FALSE;
    }
while (search)
{
    cur_path[0] = '\0';
    path[0] = '\0';
    pathname[0] = '\0';
    col_win_flag = FALSE;
    blank_char = strchr (search_path,' ');
    if (blank_char == NULL)
    {
	search = FALSE;
	status =DIstrcpy(cur_path, search_path);
	if (!(1 & status))
	{
	    goto fini;
	}
    }
    else
    {
	num_char = blank_char - search_path;
	strncpy(cur_path,search_path,num_char);
	cur_path[num_char] = '\0';
	blank_char ++;
	search_path = blank_char;
	/* the search path is now pointing to the next search string */
    }
    col_win_flag = FALSE;

    if (!(strcmp (cur_path,GRDP_REGVIEWS)))
    {
	DIstmcpy (pathname,GRDP_VIEWS,cur_path,"*",0);
	col_win_flag = TRUE;
    }
    else if (!(strcmp (cur_path,GRDP_GRVIEWS)))
    {
    	DIstmcpy (pathname,GRDP_VIEWS,GRDP_REGVIEWS,cur_path,0);
	col_win_flag = TRUE;
    }
    else if (!(strcmp (cur_path,GRDP_SAVEDVIEWS)))
    {
    	DIstmcpy (pathname,GRDP_VIEWS,cur_path,"*",0);
    }
    else if (!(strcmp (cur_path,GRDP_GRSAVEDVIEWS)))
    {
    	DIstmcpy (pathname,GRDP_VIEWS,GRDP_SAVEDVIEWS,cur_path,0);
    }
    else
    {
	status = DIstrcpy (pathname,cur_path);
	if (!(1 & status))
	{
	    goto fini;
	}
    }

    if ((col_win_flag == TRUE) && (type_gragad != ALL_TYPES))
    {
    	if (p_osnum == NULL)
    	{
	ex$get_cur_mod( id=&mod_objid, osnum=&osnum);
    	}

	status = DIstmocpy(path,pathname,name,0,osnum);                   

	/* get the windows that match the string => don't use di$pass() because it */
	/* will return the default view (.GRdefaultview) which we don't want       */
        num_windows = 0;        
	sts = di$start_dump ( regexp = path, p_classes = NULL, ptr = &count );
	   for (i = 0, om_st = 1; (i < count) && (sts == 1) && (om_st & 1); i++)
	      if ((sts = di$fetch_dump ( index = i, p_grid = &grid )) == DIR_S_SUCCESS)
	         om_st = om$send ( msg = message IGEgragad.DPcollect_win( msg, &num_windows, EX_MAX_WINDOW,
	                                                                  wn_list, type_gragad ),
	                           mode = OM_e_wrt_object, senderid = NULL_OBJID,
	                           targetid = grid.objid, targetos = grid.osnum );

	if (array_size < num_windows)
	{
	    copy_num = array_size;
	}
	else
	{
	    copy_num = num_windows;	
	}
	OM_BLOCK_MOVE(wn_list,p_ids,(sizeof(struct GRid) * copy_num));
	if (total_num != NULL)
    	{
	    *total_num += num_windows;
    	}
	*numid += copy_num;	
	p_ids += copy_num;
	array_size -= copy_num;
    }
    else /* col_win FALSE */
    {
	/* p_ids gets incremented in this routine and should be pointing to 
	   the right place */
	DPgetid(msg, name, array_size, &pass_totalnum, &pass_numid, p_ids, p_osnum, pathname);
	if (total_num != NULL)
    	{
	    *total_num += pass_totalnum;
    	}
	*numid += pass_numid;
	array_size -= pass_numid;
    }
}  /* close for while */
fini:
    *msg = ( 1 & status) ? MSSUCC :MSFAIL;
    return(status);
}


/* the following function does the actual pattern matching. */

int GRmatch (str1,str2)
    char *str1, *str2;
{
    char cb,ce;
    if (!(*str1) && !(*str2)) return(1);
    if (!(*str1) || !(*str2)) return(0);
    if ((*str1 == *str2) || (*str1 == '?')) return(GRmatch(str1+1,str2+1));
    if (*str1  == '*') return((GRmatch(str1+1,str2+1)) || (GRmatch(str1,str2+1)));
    /* handle [  ] */
    if (*str1 == '[')
      {
        /* handle [a-z]  */
        if (*(str1+2) == '-')
           {
                cb = *(str1+1) - 1;
                ce = *(str1+3);
                while (ce > cb++)
                  {
                    if (cb == *str2) return(GRmatch(str1+5,str2+1));
                  }
                return(0);
           }
        /*  handle [abcxyz] */  
        while (*str1++ != ']')
            {
                if (*str1 == *str2)
                   {
                     while (*(++str1) != ']');
                     return(GRmatch(str1+1,str2+1));
                   }
            }
        return(0);
      }
    return(0);
}


end implementation IGEgragad;
