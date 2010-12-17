#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

NFAdefine_search (search_string, from_string, c_attr_buffer, f_attr_buffer)
    char **search_string;
    char **from_string;
    MEMptr c_attr_buffer;
    MEMptr f_attr_buffer;

{
int    status, i, j, k, l;
int    old_tot_data, new_tot_data;
int    string_size;
struct SCfree_data_st data;
struct SCfree_data_st oper1;
struct SCfree_data_st oper2;
struct SCcolumn_data_st form;
int    FORM_FILLED;
int    select_index = 0;
int    form_index = 0;
int    paren_cnt = 0;
int    form_rows = 1;
int    count;
int    SEARCH_DONE = FALSE;
int    ROW_SELECTED = FALSE;
char   new_scr[500];
char   *temp_string;
char   **column_ptr;
char   **format_ptr;
char   **c_data_ptr;
char   **f_data_ptr;
char   operator1[5];
char   operator2[32];
char   paren1[10];
char   paren2[10];
char   attr[100];
NDXptr c_index;
NDXptr f_index;
char   nfm_date[100];
char   ris_date[100];
static char *fname = "NFAdefine_search";

    _NFIdebug ((fname, "Enter.\n"));

/*******************************************************************/


    /* set up attribute form -> data */
    _NFIdebug ((fname, "NFAsearch_attr_form\n"));
    
    status = NFAsearch_attr_form (&data, c_attr_buffer, f_attr_buffer);
    if (status != NFI_S_SUCCESS)
        {
        return (status);
        }

    status = MEMbuild_array (c_attr_buffer);
    if (status != MEM_S_SUCCESS)
        {
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild_array");
        return (NFI_E_MEMORY);
        }

    status = MEMbuild_array (f_attr_buffer);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild_array");
        return (NFI_E_MEMORY);
        }
 
    column_ptr = (char **) c_attr_buffer->column_ptr;
    format_ptr = (char **) c_attr_buffer->format_ptr;
    c_data_ptr = (char **) c_attr_buffer->data_ptr;
    f_data_ptr = (char **) f_attr_buffer->data_ptr;
        
    NFMRfill_index (c_attr_buffer, &c_index);
    NFMRfill_index (f_attr_buffer, &f_index);

/********************************************************************/

    /* set up operator1 form -> oper1 */
    _NFIdebug ((fname, "NFAsearch_oper1_form\n"));
    
    status = NFAsearch_oper1_form (&oper1);
    if (status != NFI_S_SUCCESS)
        {
        return (status);
        }

/********************************************************************/

    /* set up operator2 form -> oper2 */
    _NFIdebug ((fname, "NFAsearch_oper2_form\n"));
    
    status = NFAsearch_oper2_form (&oper2);
    if (status != NFI_S_SUCCESS)
        {
        return (status);
        }

/*******************************************************************/

    /* set up search form -> form */
    _NFIdebug ((fname, "NFAsearch_search_form\n"));

    status = NFAsearch_form (&form, form_rows, &old_tot_data);
    if (status != NFI_S_SUCCESS)
        {
        return (status);
        }

/*********************************************************************/

    operator2[0] = 0;
    paren2[0] = 0;

    /* process all search attributes */
    do
        {
        /* initialize strings */
	attr[0] = 0;
        operator1[0] = 0;
        paren1[0] = 0;
        
        /* set forms to reflect NO selections */
        status = NFAclear_form_selects (&oper1);
        status = NFAclear_form_selects (&oper2);

        /* process attribute form until chosen attr != "(" */
        do
            {
            /* set forms to reflect NO selections */
            status = NFAclear_form_selects (&data);

            ROW_SELECTED = FALSE;
            select_index = 0;
            status = SCprocess_free_form (&data, NFMprint_file);
            SCclear_msg ();

            if (data.sts == FORM_CANCELED)
                break;

            ROW_SELECTED = NFAverify_row_selected (data, &select_index);
 
            /* row must be selected */

                 if (!ROW_SELECTED)
                     SCdisplay_msg ("NFM:  Attribute must be selected.");

            /* if a "(" is chosen, strcat to paren1; if not, it is attr */
            else if (strncmp (data.data[select_index*data.num_of_cols],
                              "(", 1) == 0)
                     {
                     ++paren_cnt;
                     ROW_SELECTED = FALSE;
                     strcat (paren1, "(");
                     }
            else
                    strcat (attr, data.data[select_index*data.num_of_cols]);

            }
        while (!ROW_SELECTED);

        if (data.sts == FORM_CANCELED)
            {
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            NFAfree_list (oper1.data, oper1.num_of_rows, oper1.num_of_cols);
            free (oper1.data);
            NFAfree_list (oper2.data, oper2.num_of_rows, oper2.num_of_cols);
            free (oper2.data);
            NFAfree_list (form.data, form.num_of_rows, form.num_of_cols);
            free (form.data);
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
            return (NFI_W_COMMAND_CANCELLED);
            }
 
        /* process form until operator has been chosen */
        do
            {
            ROW_SELECTED = FALSE;
            status = SCprocess_free_form (&oper1, NFMprint_file);
            SCclear_msg ();

            if (oper1.sts == FORM_CANCELED)
                break;
 
            /* make sure that a row has been selected */
            ROW_SELECTED = NFAverify_row_selected (oper1, &select_index);
            
            /* row must be selected */
            if (!ROW_SELECTED)
                SCdisplay_msg ("NFM:  Operator must be selected.");
            }
        while (!ROW_SELECTED);

        if (oper1.sts == FORM_CANCELED)
            {
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            NFAfree_list (oper1.data, oper1.num_of_rows, oper1.num_of_cols);
            free (oper1.data);
            NFAfree_list (oper2.data, oper2.num_of_rows, oper2.num_of_cols);
            free (oper2.data);
            NFAfree_list (form.data, form.num_of_rows, form.num_of_cols);
            free (form.data);
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
            return (NFI_W_COMMAND_CANCELLED);
            }

            strcpy (operator1, oper1.data[select_index*oper1.num_of_cols]);

/*******************************************************************/

        for (i=(form_rows-1)*form.num_of_cols;
             i<form_rows*form.num_of_cols;
             i+=form.num_of_cols)
            {
            if (operator2[0] != 0)
                {
                NFAput_string (&form.data[i-2], paren2);
                NFAput_string (&form.data[i-1], operator2);
                }
            NFAput_string (&form.data[i], paren1);
            NFAput_string (&form.data[i+1], attr);
            NFAput_string (&form.data[i+2], operator1);
	    }
        form_index = i;
       
        do
            {
            FORM_FILLED = TRUE;
            status = SCprocess_column_form (&form, NFMprint_file);
            SCclear_msg ();

            if (form.sts == FORM_CANCELED)
                {
                break;
                }

            /* make string valid length and strip trailing blanks */
            status = NFAvalidate_string ("char(50)", form.data[form_index-3]);

          /*  if (strcmp (form.data[form_index-3], "") == 0) */
              if ((form.data[form_index-3] == NULL) ||(( form.data[form_index-3] != NULL ) && (strcmp (form.data[form_index-3], "") == 0)))
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Expression must be entered.");
                }
            }
        while (!FORM_FILLED);
    
        if (form.sts == FORM_CANCELED)
            {
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            NFAfree_list (oper1.data, oper1.num_of_rows, oper1.num_of_cols);
            free (oper1.data);
            NFAfree_list (oper2.data, oper2.num_of_rows, oper2.num_of_cols);
            free (oper2.data);
            NFAfree_list (form.data, form.num_of_rows, form.num_of_cols);
            free (form.data);
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
            return (NFI_W_COMMAND_CANCELLED);
            }

 	/*  Replace any '*' characters with '%' */
	_NFIdebug(( fname, "Old Search <%s>\n", form.data[form_index-3] ));
	NFAasterisk_to_percent( form.data[form_index-3], new_scr );
	_NFIdebug(( fname, "New Search <%s>\n", new_scr ));
	NFAput_string( &form.data[form_index-3], new_scr );

        strcpy (operator2, "");
        strcpy (paren2, "");

        do
            {
            status = NFAclear_form_selects (&oper2);
            ROW_SELECTED = FALSE;
            status = SCprocess_free_form (&oper2, NFMprint_file);
            SCclear_msg ();

            if (oper2.sts == FORM_CANCELED)
                break;
 
            /* make sure that a row has been selected */
            ROW_SELECTED = NFAverify_row_selected (oper2, &select_index);

            /* row must be selected */
                 if (!ROW_SELECTED)
                     SCdisplay_msg ("NFM:  Operator must be selected.");

            /* was a close paren chosen? */
            else if (strncmp (oper2.data[select_index*oper2.num_of_cols],
                              ")", 1) == 0)
                     {
                     --paren_cnt;
                     ROW_SELECTED = FALSE;
                     strcat (paren2, ")");
                     }
 
            else
                     {
                     strcat (operator2,
                                   oper2.data[select_index*oper2.num_of_cols]);

                     /* see if this is the end */
                     if (strcmp (oper2.data[select_index*oper2.num_of_cols],
                                 "END") == 0)
                         {
                         if (paren_cnt != 0)
                             {
                             SCdisplay_msg ("NFM:  Parenthesis mismatch.");
                             ROW_SELECTED = FALSE;
                             operator2[0] = 0;
                             }
                         else
                             SEARCH_DONE = TRUE;
                        }
                    }

            }
        while (!ROW_SELECTED);

        if (oper2.sts == FORM_CANCELED)
            {
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            NFAfree_list (oper1.data, oper1.num_of_rows, oper1.num_of_cols);
            free (oper1.data);
            NFAfree_list (oper2.data, oper2.num_of_rows, oper2.num_of_cols);
            free (oper2.data);
            NFAfree_list (form.data, form.num_of_rows, form.num_of_cols);
            free (form.data);
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
            return (NFI_W_COMMAND_CANCELLED);
            }

        /**************************************************************/

        if (!SEARCH_DONE)
            {
            /* set up search form -> form */ 

            ++form_rows;
            status = NFAreset_search_form (&form, form_rows, &old_tot_data,
                                           &new_tot_data);
            }  /* end if !SEARCH_DONE */
        }
    while (!SEARCH_DONE);

/***************************************************/

    sprintf (msg, "old_tot_data -> %d, form_rows -> %d",
             old_tot_data, form_rows);
    memset (form.selectable, 0, (old_tot_data * sizeof (int)));
    NFAput_string (&form.data[((form_rows-1)*form.num_of_cols)+5], operator2);
    NFAput_string (&form.data[((form_rows-1)*form.num_of_cols)+4], paren2);

    SCdisplay_msg ("<PF1> to accept; <PF3> to cancel.");
    status = SCprocess_column_form (&form, NFMprint_file);
    SCclear_msg ();

    if (form.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        NFAfree_list (oper1.data, oper1.num_of_rows, oper1.num_of_cols);
        free (oper1.data);
        NFAfree_list (oper2.data, oper2.num_of_rows, oper2.num_of_cols);
        free (oper2.data);
        NFAfree_list (form.data, form.num_of_rows, form.num_of_cols);
        free (form.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    string_size = 1000;
    *search_string = (char *) malloc (string_size);
    *from_string   = (char *) malloc (100);

/*  JM - the entire search string will be in parens */
    strcpy (*search_string, "(");
    strcpy (*from_string, " " );

    for (i=0; i<form_rows; ++i)
        {
        j = i * form.num_of_cols;

        if ((strlen (*search_string)) >= (string_size - 100))
            {
            string_size += 1000;
            temp_string = (char *) malloc (string_size);
            strcpy (temp_string, *search_string);
            free (*search_string);
            **search_string = *temp_string;
            }

        /* "paren1" field */
        strcat (*search_string, form.data[j]);

        /* "attribute" field - use attr_name instead of synonym */
	count = 0;
        for (k=0; k<c_attr_buffer->rows*c_attr_buffer->columns;
             k+=c_attr_buffer->columns)
            {
            if (strcmp (form.data[j+1], c_data_ptr[k+c_index.syn]) == 0)
                {
		strcat (*search_string, "(" );
 	        strcat (*search_string, "a." );
                strcat (*search_string, c_data_ptr[k+c_index.name]);
                break;
                }
            }

        for (l=0; l<f_attr_buffer->rows*f_attr_buffer->columns;
             l+=f_attr_buffer->columns)
            {
            if (strcmp (form.data[j+1], f_data_ptr[l+f_index.syn]) == 0)
                {
	        strcat (*search_string, "f_a." );
                strcat (*search_string, f_data_ptr[l+f_index.name]);
		strcat (*from_string, "f_" );
		strcat (*from_string, NFMcatalog );
		count = 1;
                break;
       		}
            }

        /* "operator" field */
        strcat (*search_string, " ");
        strcat (*search_string, form.data[j+2]);
        strcat (*search_string, " ");

        /* "value" field and "char" data type, add single quotes */
	if( count == 0 )
	{
          if ((strncmp (c_data_ptr[k+c_index.dt], "char", 4) == 0) &&
            (strncmp (form.data[j+3], "'", 1) != 0))
            {
            strcat (*search_string, "\'");
            strcat (*search_string, form.data[j+3]);
            strcat (*search_string, "\'");
            }
/* Added the following else if as part of Year 2000 fixes - Ravi 14 June 98 */
          else if (strncmp (c_data_ptr[k+c_index.dt], "timestamp", 9) == 0) 
	    {
	       status = NFMRvalidate_and_format_date(form.data[j+3], nfm_date, ris_date);
	       if(status != NFM_S_SUCCESS)
	           return(status);
	       else
                   strcpy(form.data[j+3], ris_date);
               if(strncmp (form.data[j+3], "TIMESTAMP", 9) != 0)
               {
               strcat (*search_string, "TIMESTAMP \'");
               strcat (*search_string, form.data[j+3]);
               strcat (*search_string, "\'");
	       }
            }
/* End of Year 2000 changes - Ravi 14 June 98 */
          else
            strcat (*search_string, form.data[j+3]);
	}
	else if( count == 1 )
	{
          if ((strncmp (f_data_ptr[l+f_index.dt], "char", 4) == 0) &&
            (strncmp (form.data[j+3], "'", 1) != 0))
            {
            strcat (*search_string, "\'");
            strcat (*search_string, form.data[j+3]);
            strcat (*search_string, "\'");
            }
/* Added the following else if as part of Year 2000 fixes - Ravi 14 June 98 */
          else if (strncmp (f_data_ptr[l+f_index.dt], "timestamp", 9) == 0) 
            {
	       status = NFMRvalidate_and_format_date(form.data[j+3], nfm_date, ris_date);
	       if(status != NFM_S_SUCCESS)
	           return(status);
	       else
                   strcpy(form.data[j+3], ris_date);
                if(strncmp (form.data[j+3], "TIMESTAMP", 9) != 0)
                {
                strcat (*search_string, "TIMESTAMP \'");
                strcat (*search_string, form.data[j+3]);
                strcat (*search_string, "\'");
                }
            }
/* End of Year 2000 changes - Ravi 14 June 98 */
          else
            strcat (*search_string, form.data[j+3]);
	}       

	strcat (*search_string, ")" );

        /* "paren2" field */
        strcat (*search_string, form.data[j+4]);

        strcat (*search_string, " ");

        /* "continuation" field */
        if (strncmp (form.data[j+5], "END", 3) != 0)
            strcat (*search_string, form.data[j+5]);

        strcat (*search_string, " ");
        }
    strcat( *search_string, ")" );    
    
    _NFIdebug ((fname, "search_str <%s>\n", *search_string));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    
    NFAfree_list (oper1.data, oper1.num_of_rows, oper1.num_of_cols);
    free (oper1.data);

    NFAfree_list (oper2.data, oper2.num_of_rows, oper2.num_of_cols);
    free (oper2.data);
    
    NFAfree_list (form.data, form.num_of_rows, form.num_of_cols);
    free (form.data);
    
    return (NFI_S_SUCCESS); 
}



