#include "machine.h"
#include <time.h>
#include <errno.h>
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMdef.h"

int NFAmake_msg (mess)
    char *mess;
    
{
    strcpy (mess, "NFM>  ");

    if (NFMlist_driven == 1)
        {
        strcat (mess, "LIST  ");
        }

    if (strcmp (NFMproject, "") != 0)
        {
        strcat (mess, "PRJ: ");
        strcat (mess, NFMproject);
        strcat (mess, "  ");
        }

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
        if (strcmp (NFMset, "") != 0)
            {
            strcat (mess, "  SET: ");
            strcat (mess, NFMset);
            if (strcmp (NFMset_rev, "") != 0)
                {
                strcat (mess, ".");
                strcat (mess, NFMset_rev);
                }
            }
	}

    if (strcmp (NFMworking, "") != 0)
        {
        strcat (mess, "  WORK_AREA: ");
        strcat (mess, NFMworking);
        }

/*
    if (strcmp (NFMstorage, "") != 0)
        {
        strcat (mess, "  STORAGE: ");
        strcat (mess, NFMstorage);
        }
*/

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

    if (strcmp (NFMsearch_name, "") != 0)
        {
        strcat (mess, "  SCR: ");
        strcat (mess, NFMsearch_name);
        }

    if (strcmp (NFMsort_name, "") != 0)
        {
        strcat (mess, "  SRT: ");
        strcat (mess, NFMsort_name);
        }

    return (NFI_S_SUCCESS);
}


int NFAfree_list (data_list, num_rows, num_cols)
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

    return (NFI_S_SUCCESS);
}


int NFAput_string (to_string, string)
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
        
    return (NFI_S_SUCCESS);
}


int NFAvalidate_string (dtype, string)
    char  *dtype;
    char  *string;

{
    long   status;
    int    i, len;
    
    if (string != NULL)
        {
        status = NFAget_dtype_len (dtype, string, &len);
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

    return (NFI_S_SUCCESS);
}


int NFAvalidate_Y_or_N (string)
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

    return (NFI_S_SUCCESS);
}


int NFAvalidate_P_or_S (string)
    char  *string;

{
/* start - check for NULL value of string PS */
    if (string == NULL)
        {
            ERRload_struct( NFI, NFI_E_INVALID_INFORMATION, NULL, NULL );
            return (NFI_E_FAILURE);
        }
/* end - PS */

    if (string != NULL)
        {
             if (strncmp (string, "p", 1) == 0)
                 strcpy (string, "P");

        else if (strncmp (string, "s", 1) == 0)
                 strcpy (string, "S");

        if ((strncmp (string, "P", 1) != 0) &&
            (strncmp (string, "S", 1) != 0))
	    {
	    ERRload_struct( NFI, NFI_E_INVALID_INFORMATION, NULL, NULL );
            return (NFI_E_FAILURE);
	    }
        string[1] = '\0';
        }

    return (NFI_S_SUCCESS);
}


int NFAput_buf_string (to_string, string, len)
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

    return (NFI_S_SUCCESS);
}


int NFAput_and_validate_data (data, initial, limit, increment)
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
            NFAput_string (&data[i], "");
            }
        else
            {
            status = NFAvalidate_string (data[i-1], data[i]);
            }
        }

    return (NFI_S_SUCCESS);
}

NFAdisplay_message_set( title, set_msg )
    char   *title;
    MEMptr set_msg;
{
    long   status;

    int    i;
    int    tot_data;
    int    pos;
    char   **set_msg_ptr;
    
    struct SCcolumn_data_st data;

    static char *fname = "NFAdisplay_message_set";

    set_msg_ptr = (char **) set_msg->data_ptr;

    pos = 0;
    data.num_of_rows = set_msg->rows;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 80;

    data.new_rows_expected = FALSE;
    strcpy (data.title, title );

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for( i=0; i<set_msg->rows; ++i )
    {
        NFAput_string (&data.data[i], set_msg_ptr[i] );
    }

    status = SCprocess_column_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
			data.sts));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if( status != NFM_S_SUCCESS )
	return( status );       
 
    return (NFI_S_SUCCESS);
}

NFAasterisk_to_percent( in, out )
    char *in;
    char *out;
{
    static char *fname = "NFAasterisk_to_percent";

    while( *in )
    {
	if( *in == '*' )
	{
	    *out = '%';
	    out++;
	    in++;
	}
	else
 	    *out++ = *in++;
    }    
    *out = '\0';

    return( NFM_S_SUCCESS );
}


long _NFAfind_col_offset (buffer, attrname, offset)
  MEMptr    buffer;
  char      *attrname;
  short     *offset;
  {


    auto    int     i;
    auto    char    **column;
    auto    short   found = FALSE;
    static  char    *fname = "_NFAfind_col_offset";

    _NFIdebug ((fname, "attrname = <%s>\n", attrname));

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
       }

    column = (char **) buffer->column_ptr;

    for (i = 0; i < buffer->columns; ++i)
      {
        if ((strcmp (column[i], attrname)) == 0)
          {
            *offset = i;
            found = TRUE; 

           }
      }

    if (found == FALSE)
      {
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    _NFIdebug ((fname, "offset = <%d>\n", *offset));

    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFAfind_higest_seqno (buffer, seqno)
  MEMptr       buffer ;
  int          *seqno;
  {
    int     i;
    int     temp;
    int     highest = 0;
    int     total_fields;
    long    status;
    char    **data_ptr;
    char    **column_ptr;
    short   offset;

    static  char *fname = "_NFAfind_highest_seqno";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Find the maximum seqno from the attribute buffer  */

    data_ptr = (char **) buffer->data_ptr;
    column_ptr = (char **) buffer->column_ptr ;

    for (i=0; i<buffer->columns; i++)
      {
    if (strcmp (column_ptr[i], "n_seqno") == 0)
      {
        offset = i ;
        break ;
      }
      }


    total_fields = buffer->rows * buffer->columns;
    for (i = 0; i < total_fields; i += buffer->columns)
      {
        temp = atoi (data_ptr[i + offset]);
        if (temp > highest)
            highest = temp;
      }

    _NFIdebug ((fname, "highest = <%d>\n", highest));

    *seqno = highest;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

  

long _NFAvalidate_datatype (datatype, width)
  char    *datatype;
  int     *width;
  {
    auto    int     i;
    auto    char    size[20];
    static  char    *fname = "_NFAvalidate_datatype";

    _NFIdebug ((fname, "datatype = <%s>\n", datatype));

    if ((strcmp (datatype, "integer")) == 0)
        *width = 15;
    else if ((strcmp (datatype, "smallint")) == 0)
        *width = 15;
    else if ((strcmp (datatype, "double")) == 0)
        *width = 30;
    else if ((strcmp (datatype, "real")) == 0)
        *width = 30;
    else if ((strcmp (datatype, "timestamp")) == 0)
        *width = 19;
    else if ((strncmp (datatype, "char(", 5)) == 0)
      {
        /*  Make sure there is a right paren  */

        if (datatype[strlen (datatype) - 1] != ')')
          {
            _NFIdebug ((fname, "no right paren for char datatype\n"));
            ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_INVALID_DATATYPE);
          }

        for (i = 5; i < strlen (datatype) - 1; ++i)
          {
            if ((isdigit (datatype[i])) == 0)
              {
                _NFIdebug ((fname, "digit <%d> is NOT numeric\n", i));
                ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_INVALID_DATATYPE);
              }
          }

        strncpy (size, &datatype[5], strlen (&datatype[5]) - 1);
        *width = atoi (size);
      }
    else
      {
        *width = 0;
        _NFIdebug ((fname, "unrecognized datatype\n"));
        ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_INVALID_DATATYPE);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
