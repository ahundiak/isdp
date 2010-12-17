#include "machine.h"
#include "NFMSextern.h"
#include "NFMerrordef.h"
#include "DEBUG.h"

int NFMconsole (mess)
  char *mess;
    
{

_NFMSdebug(( "NFMconsole", "%s\n", mess));

return (NFM_S_SUCCESS);
}


int NFMfree_list (data_list, num_rows, num_cols)
    char   **data_list;
    int    num_rows;
    int    num_cols;

{
    int    status = NFM_S_SUCCESS;
    int    row;
    int    col;
    char   msg[128];
    
    sprintf (msg, "Begin freeing list - %d rows, %d cols",
             num_rows, num_cols);
    NFMconsole (msg);
    
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

    NFMconsole ("Done freeing list");

    return (status);
}


int NFMput_string (to_string, string)
    char  **to_string;
    char  *string;

{
    int    status = NFM_S_SUCCESS;

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
        
    return (status);
}


int NFMvalidate_string (dtype, string)
    char  *dtype;
    char  *string;

{
    int    status = NFM_S_SUCCESS;
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

    return (NFM_S_SUCCESS);
}


int NFMput_buf_string (to_string, string, len)
    char  **to_string;
    char  *string;
    int   len;

{
    int    status = NFM_S_SUCCESS;

    if (string != NULL)
        {
        strncpy (*to_string, string, len);
        }
    else
        {
        strncpy (*to_string, "", len);
        }

    return (status);
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

NFMget_dtype_len (data_ptr1, data_ptr2, len)
    char  *data_ptr1;
    char  *data_ptr2;
    int   *len;
    
{
int  i;
int  temp_len1;
int  temp_len2;
char str[5];

    *len = 0;
    temp_len1 = 0;
    temp_len2 = 0;
    
    if (strncmp (data_ptr1, "char", 4) == 0)
        {
        strncpy (str, data_ptr1 + 5, (strlen (data_ptr1) - 6));
        str[strlen(data_ptr1) - 6] = '\0';
        temp_len1 = atoi (str);
        }
    else
        {
        if ((strncmp (data_ptr1, "int", 3) == 0) ||
            (strncmp (data_ptr1, "smallint", 8) == 0))
            {
            temp_len1 = 12;
            }
        else
            {
            if ((strncmp (data_ptr1, "float", 5) == 0) ||
                (strncmp (data_ptr1, "smallfloat", 10) == 0) ||
                (strncmp (data_ptr1, "decimal", 7) == 0) ||
                (strncmp (data_ptr1, "money", 5) == 0))
                {
                temp_len1 = 25;
                }
            else
                {
                if ((strncmp (data_ptr1, "ser", 3) == 0) ||
                    (strncmp (data_ptr1, "date", 4) == 0))
                    {
                    temp_len1 = 10;
                    }
                }
            }
        }
        
    temp_len2 = strlen (data_ptr2);
    
    if (temp_len1 >= temp_len2)
        {
        *len = temp_len2;
        }
    else
        {
        *len = temp_len1;
        }
        
    return (NFM_S_SUCCESS);
}



