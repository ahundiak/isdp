#include "machine.h"
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFIerrordef.h"
#include "NFMRextern.h"
#include "NFMdef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "SCdef.h"
#include "SCstruct.h"


extern int LOGIN_FLAG;

int NFAmake_msg (mess)
    char *mess;
    
{
    strcpy (mess, "NFM>  ");

/*    if (strcmp (NFMproject, "") != 0)
        {
        strcat (mess, "PRJ: ");
        strcat (mess, NFMproject);
        strcat (mess, "  ");
        }
*/
    if (strcmp (NFMcatalog, "") != 0)
        {
        strcat (mess, NFMcatalog);
        if (strcmp (NFMitem, "") != 0)
            {
            strcat (mess, " : ");
            strcat (mess, NFMitem);
            if (strcmp (NFMrev, "") != 0)
                {
                strcat (mess, ".");
                strcat (mess, NFMrev);
                }
            }

        }

    if (strcmp (NFMstorage, "") != 0)
        {
        strcat (mess, "  STORAGE: ");
        strcat (mess, NFMstorage);
        }

    if (strcmp (NFMworkflow, "") != 0)
        {
        strcat (mess, "  WF: ");
        strcat (mess, NFMworkflow);
        }

    if (strcmp (NFMacl, "") != 0)
        {
        strcat (mess, "  ACL: ");
        strcat (mess, NFMacl);
        }
/*
    if (strcmp (NFMsearch_name, "") != 0)
        {
        strcat (mess, "  SCR: ");
        strcat (mess, NFMsearch_name);
        }

    if (strcmp (NFMsort_name, "") != 0)
        {
        strcat (mess, "  SRT: ");
        strcat (mess, NFMsort_name);
        }*/

    return (NFM_S_SUCCESS);
}


int NFMfree_list (data_list, num_rows, num_cols)
    char   **data_list;
    int    num_rows;
    int    num_cols;

{
    int    row;
    int    col;
    
    for (row=0; row<num_rows; ++row)
        {
        for (col=0; col<num_cols; ++col)
            {
            if (data_list[(num_cols * row) + col] != NULL)
                {
                free (data_list[(num_cols * row) + col]);
                }
            }
        }

    return (NFM_S_SUCCESS);
}


int NFMput_string (to_string, string)
    char  **to_string;
    char  *string;

{
    if (*to_string != NULL)
        {
        free (*to_string);
        *to_string = NULL;
        }

    if (string != NULL)
        {
        *to_string = (char *) malloc (strlen (string) + 1);
        strcpy (*to_string, string);
        }
        
    return (NFM_S_SUCCESS);
}


int NFMvalidate_string (dtype, string)
    char  *dtype;
    char  *string;

{
    int    status;
    int    i, len;
    
    if (string != NULL)
        {
        status = NFMget_dtype_len (dtype, string, &len);
        for (i=len-1; i>=0; --i)
            {
            if (string[i] != ' ')
                {
                break;
                }
            }
        string[i+1] = '\0';
        }
    else
        {
        string = (char *) malloc (2);
        strcpy (string, "");
        }

    return (NFM_S_SUCCESS);
}


int NFMvalidate_Y_or_N (string)
    char  *string;

{
    if (string != NULL)
        {
             if (strncmp (string, "n", 1) == 0)
                 strcpy (string, "N");

        else if (strncmp (string, "y", 1) == 0)
                 strcpy (string, "Y");

        if ((strncmp (string, "N", 1) != 0) &&
            (strncmp (string, "Y", 1) != 0))
	    {
	    ERRload_struct( NFI, NFI_E_INVALID_INFORMATION, NULL, NULL );
            return (NFI_E_FAILURE);
	    }
        string[1] = '\0';
        }

    return (NFM_S_SUCCESS);
}


int NFMput_buf_string (to_string, string, len)
    char  **to_string;
    char  *string;
    int   len;

{
    if (string != NULL)
        {
        strncpy (*to_string, string, len);
        }
    else
        {
        strncpy (*to_string, "", len);
        }

    return (NFM_S_SUCCESS);
}


int NFMput_and_validate_data (data, initial, limit, increment)
    char   **data;
    int    initial;
    int    limit;
    int    increment;

{
int  status, i;

    /* if blank, fill data with "" */
    /* make string valid length and strip trailing blanks */
    for (i=initial; i<limit; i+=increment)
        {
        if (data[i] == 0)
            {
            NFMput_string (&data[i], "");
            }
        else
            {
            status = NFMvalidate_string (data[i-1], data[i]);
            }
        }

    return (NFM_S_SUCCESS);
  }

int ADMcheck_login_flag()
 {
    char  msg[250];
    long  status;
  
  if (LOGIN_FLAG !=0)
   {

     status = NFM_I_MUST_LOGIN; 
     ERRload_struct (NFM, NFM_I_MUST_LOGIN, NULL,NULL);
     ERRget_message (msg) ;
     SCdisplay_msg( msg );
     return (status) ;
     }
   else
      return(NFM_S_SUCCESS);
}

int ADMcheck_logout_flag()
 {
    char  msg[250];
    long  status;
    static char *fname = "ADMcheck_logout_flag";
  
  if (LOGIN_FLAG ==0)
   {
     status = NFM_E_BAD_ENV;
     _NFMdebug((fname, "log out first\n"));
     ERRload_struct (NFM, NFM_E_BAD_ENV,NULL,NULL);

     ERRget_message (msg) ;
     SCdisplay_msg( msg );
     return (status) ;
     }
   else
      return(NFM_S_SUCCESS);
}









