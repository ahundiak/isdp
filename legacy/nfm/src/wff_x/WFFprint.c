#include "machine.h"
#include "WFF.h"
#include "WFFlist.h"
#include <time.h>

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFmain_print_listing (form, label1, label2, filename)
  Form   form;
  int    label1;
  int    label2;
  char   *filename;
  {
    long    status;
    int     i, *cols = NULL;
    int     selected;
    int     displayed;
    int     num_cols, frozen_cols;
    char    *time_string = NULL;
    time_t  time_now;
    MEMptr  buffer = NULL;
    static  char *fname = "_WFFmain_print_listing";

    long _WFFmain_print_to_file ();

    _NFIdebug ((fname, " Label1 = <%d>\n", label1));
    _NFIdebug ((fname, " Label2 = <%d>\n", label2));

    /*  Get the output filename for the listing  */

    switch (WFFglobal.current_list)
      {
        case WFF_LIST_WORKFLOWS:
            strcpy (filename, "workflow.list");
            break;

        case WFF_LIST_CLASSES:
            strcpy (filename, "classes.list");
            break;

        case WFF_LIST_STATES:
            strcpy (filename, "states.list");
            break;

        case WFF_LIST_TRANSITIONS:
            strcpy (filename, "trans.list");
            break;

        case WFF_LIST_CLASS_ACCESS:
            strcpy (filename, "access.list");
            break;

        case WFF_LIST_COMMANDS:
            strcpy (filename, "commands.list");
            break;

        default:
            _NFIdebug ((fname, "there is no list to print\n"));
            ERRload_struct (NFI, NFI_I_NO_LISTING, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_I_NO_LISTING);
      }

    /*  Get the current date/time  */

    if ((time_now = time ((long *) 0)) == -1)
      {
        _NFIdebug ((fname,
            "failed to get current date/time; errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_TIME, "%d", errno);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_TIME);
      }

    /*  Convert the time into a string  */

    if ((time_string = ctime (&time_now)) == NULL)
      {
        _NFIdebug ((fname,
            "failed to convert current date/time; errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_TIME, "%d", errno);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_TIME);
      }

    buffer = WFFglobal.list_buffer;

    if ((cols = (int *) malloc (buffer->columns * (sizeof (int)))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", buffer->columns * (sizeof (int))));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", buffer->columns * (sizeof (int)));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    /*  Find out how many columns are in label1 */

    if ((status = (long) FImcf_get_num_cols (form, label1, &num_cols)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_get_num_cols = <%d>\n", status));
        if (cols) free (cols);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    frozen_cols = num_cols;
    displayed = 0;
    for (i = 0; i < num_cols; ++i)
     {
        /*  See if this attribute is to be printed  */

        if ((status = (long) FIfld_get_select
            (form, label1, 0, i, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            if (cols) free (cols);
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Buffer column %d is NOT to be printed\n", i));
            cols[i] = -1;
          }
        else
          {
            _NFIdebug ((fname, "Buffer column %d IS to be printed\n", i));
            cols[i] = displayed;
            ++displayed;
          }
      }


    if (num_cols < buffer->columns)
     { 
       /*  Find out how many columns are in label2 */

       if ((status = (long) FImcf_get_num_cols (form, label2, &num_cols)) != FI_SUCCESS)
         {
           _NFIdebug ((fname, "FImcf_get_num_cols = <%d>\n", status));
           if (cols) free (cols);
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_cols", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
         }

       for (i = 0; i < num_cols; ++i)
        {
           /*  See if this attribute is to be printed  */

           if ((status = (long) FIfld_get_select
               (form, label2, 0, i, &selected)) != FI_SUCCESS)
             {
               _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
               if (cols) free (cols);
               ERRload_struct
                   (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_FORM);
             }
   
           if (selected == FALSE)
             {
               _NFIdebug ((fname, "Buffer column %d is NOT to be printed\n", i));
               cols[i + frozen_cols] = -1;
             }
           else
             {
               _NFIdebug ((fname, "Buffer column %d IS to be printed\n", i));
               cols[i + frozen_cols] = displayed;
               ++displayed;
             }
         }
   
      }

    /*  See if any columns have been selected  */

    if (displayed == 0)
      {
        _NFIdebug ((fname, "there are no columns selected to print\n"));
        if (cols) free (cols);
        ERRload_struct (NFI, NFI_P_SELECT_ATTRIBUTES, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_P_SELECT_ATTRIBUTES);
      }

    /*  Print a message (it might take a few seconds)  */

    _WFFmessage (NFI_I_PRINTING, NULL);

    /*  Call function to actually write to the file  */

    if ((status = _WFFmain_print_to_file
        (cols, time_string, filename)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFmain_print_to_file = <0x%.8x>\n", status));
        if (cols) free (cols);
        _WFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (cols) free (cols);

    /*  Erase the message  */

    _WFFerase_message ();

    ERRload_struct (NFI, NFI_I_PRINT_LISTING, "%s", filename);
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_I_PRINT_LISTING);
  }


long _WFFmain_print_to_file (cols, time_string, filename)
  int    *cols;         /*  i - array of selected columns to print          */
  char   *time_string;  /*  i - current date/time as a 26 character string  */
  char   *filename;     /*  i - name of file to print listing to            */
  {
    int     i, j, k;
    int     length;
    int     fields;
    long    status;
    char    *blanks;
    char    **attr_ptr = NULL;
    char    **data_ptr = NULL;
    char    *output_string;
    FILE    *outfile, *fopen ();
    MEMptr  attr_list = NULL;
    MEMptr  data_list = NULL;

    static  char *fname = "_WFFmain_print_to_file";

    if ((outfile = fopen (filename, "a")) == NULL)
      {
        _NFIdebug ((fname, "fopen failed; filename = <%s>\n", filename));
        ERRload_struct (NFI, NFI_E_OPEN_FILE_APPEND, "%s", filename);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_OPEN_FILE_APPEND);
      }

    attr_list = WFFglobal.attr_list;
    data_list = WFFglobal.list_buffer;

    if (attr_list != NULL)
      {
        attr_ptr = (char **) attr_list->data_ptr;

        /*  Make sure the buffers are in sync  */

        if (attr_list->rows != data_list->columns)
          {
            _NFIdebug ((fname,
                "attribute buffer has %d rows\n", attr_list->rows));
            _NFIdebug ((fname,
                "data buffer has %d columns\n", data_list->columns));
            _NFIdebug ((fname, "buffers are out of sync\n"));
            fclose (outfile);
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }
      }

    /*  Scan the data_list for the length of the rows  */

    length = 0;
    data_ptr = (char **) data_list->format_ptr;
    for (i = 0; i < data_list->columns; ++i)
      {
        /*  See if this data is to be output  */

        if (cols[i] == -1) continue;

        /*  Determine what the datatype is  */

        if ((strcmp (data_ptr[i], "integer")) == 0)
          {
            if (strlen (attr_ptr[i]) > 15)
             {
                 cols[i] = strlen (attr_ptr[i]);
                 length += cols[i];
             } 
            else 
             {
                 length += 15;
                 cols[i] = 15;
             } 
            _NFIdebug ((fname, "datatype of column %d is integer\n", i));
          }
        else if ((strcmp (data_ptr[i], "smallint")) == 0)
          {
            if (strlen (attr_ptr[i]) > 15)
             {
                 cols[i] = strlen (attr_ptr[i]);
                 length += cols[i];
             } 
            else 
             {
                 length += 15;
                 cols[i] = 15;
             }
            _NFIdebug ((fname, "datatype of column %d is smallint\n", i));
          }
        else if ((strcmp (data_ptr[i], "double")) == 0)
          {
            if (strlen (attr_ptr[i]) > 50)
             {
                 cols[i] = strlen (attr_ptr[i]);
                 length += cols[i];
             } 
            else
             {
                 length += 50;
                 cols[i] = 50;
             } 
            _NFIdebug ((fname, "datatype of column %d is double\n", i));
          }
        else if ((strcmp (data_ptr[i], "real")) == 0)
          {
            if (strlen (attr_ptr[i]) > 50)
             {
                 cols[i] = strlen (attr_ptr[i]);
                 length += cols[i];
             } 
            else
             {
                 length += 50;
                 cols[i] = 50;
             }
            _NFIdebug ((fname, "datatype of column %d is real\n", i));
          }
        else if ((strcmp (data_ptr[i], "decimal")) == 0)
          {
            if (strlen (attr_ptr[i]) > 50)
             {
                 cols[i] = strlen (attr_ptr[i]);
                 length += cols[i];
             } 
            else
             {
                 length += 50;
                 cols[i] = 50;
             }
            _NFIdebug ((fname, "datatype of column %d is decimal\n", i));
          }
        else if ((strcmp (data_ptr[i], "date")) == 0)
          {
            if (strlen (attr_ptr[i]) > 15)
             {
                 cols[i] = strlen (attr_ptr[i]);
                 length += cols[i];
             } 
            else
             {
                 length += 15;
                 cols[i] = 15;
             }
            _NFIdebug ((fname, "datatype of column %d is date\n", i));
          }
        else if ((strncmp (data_ptr[i], "char(", 5)) == 0)
          {
            if ((status = sscanf
                (data_ptr[i], "char(%d)", &(cols[i]))) == EOF)
              {
                _NFIdebug ((fname, "sscanf = <%d>\n", status));
                fclose (outfile);
                ERRload_struct (NFI, NFI_E_BUFFER, NULL);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_BUFFER);
              }

            /*  Add 1 for the NULL and 1 for an extra blank  */

            ++cols[i];
            length += cols[i] + 1;

            if (strlen (attr_ptr[i] + 1) > cols [i])
             {
                 cols[i] = strlen (attr_ptr[i] + 1);
                 length += cols[i] + 1;
             } 

            _NFIdebug ((fname,
                "datatype of column %d is char(%d)\n", i, cols[i]));
          }
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        for (i = 0; i < data_list->columns; ++i)
            _NFIdebug ((fname, "cols[%d] = <0x%.8x>\n", i, cols[i]));
      }

    _NFIdebug ((fname, "length = <%d>\n", length));

    /*  Allocate space for the output string  */

    if ((output_string = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        fclose (outfile);
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    /*  Initialize the string  */

    strcpy (output_string, "");

    /*  Allocate space for padding with blanks  */

    if ((blanks = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        fclose (outfile);
        if (output_string) free (output_string);
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if (attr_list != NULL)
      {
        attr_ptr = (char **) attr_list->data_ptr;

        /*  Write the column headings first  */

        fields = attr_list->columns * attr_list->rows;
        for (i = 0; i < fields; ++i)
          {
            /*  See if this data is to be output  */

            if (cols[i] == -1) continue;

            /*  Build the output string  */

            strncat (output_string, attr_ptr[i], (size_t) cols[i]);

            _NFIdebug ((fname, "output_string = <%s>\n", output_string));

            if ((strlen (attr_ptr[i])) < cols[i])
              {
                /*  Pad the remaining space with blanks  */

                sprintf (blanks, "%*s",
                    cols[i] - (strlen (attr_ptr[i])), " ");
                strcat (output_string, blanks);
              }
          }
      }
    else
      {
        attr_ptr = (char **) data_list->column_ptr;

        /*  Write the column names in the data_list  */

        for (i = 0; i < data_list->columns; ++i)
          {
            /*  See if this data is to be output  */

            if (cols[i] == -1) continue;

            /*  Build the output string  */

            strncat (output_string, attr_ptr[i], (size_t) cols[i]);

            _NFIdebug ((fname, "output_string = <%s>\n", output_string));

            if ((strlen (attr_ptr[i])) < cols[i])
              {
                /*  Pad the remaining space with blanks  */

                sprintf (blanks, "%*s", cols[i] - (strlen (attr_ptr[i])), " ");
                strcat (output_string, blanks);
              }
          }
      }

    /*  Write the current date/time to the file  */

    _NFIdebug ((fname, "Writing <%s> to file\n", time_string));

    if ((status = (long) fputs (time_string, outfile)) == EOF)
      {
        _NFIdebug ((fname, "fputs = <%d>\n", status));
        fclose (outfile);
        if (output_string) free (output_string);
        if (blanks) free (blanks);
        ERRload_struct (NFI, NFI_E_APPEND_FILE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_APPEND_FILE);
      }

    /*  Write column headers to the file  */

    _NFIdebug ((fname, "Writing <%s> to file\n", output_string));

    if ((status = (long) fputs (output_string, outfile)) == EOF)
      {
        _NFIdebug ((fname, "fputs = <%d>\n", status));
        fclose (outfile);
        if (output_string) free (output_string);
        if (blanks) free (blanks);
        ERRload_struct (NFI, NFI_E_APPEND_FILE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_APPEND_FILE);
      }

    if ((status = (long) fputs ("\n\n", outfile)) == EOF)
      {
        _NFIdebug ((fname, "fputs = <%d>\n", status));
        fclose (outfile);
        if (output_string) free (output_string);
        if (blanks) free (blanks);
        ERRload_struct (NFI, NFI_E_APPEND_FILE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_APPEND_FILE);
      }

    /*  Write the values in the file  */

    data_ptr = (char **) data_list->data_ptr;
    for (i = 0, k = -1; i < data_list->rows; ++i)
      {
        strcpy (output_string, "");

        for (j = 0; j < data_list->columns; ++j)
          {
            ++k;

            /*  See if this data is to be output  */

            if (cols[j] == -1) continue;

            /*  Build the output string  */

            strncat (output_string, data_ptr[k], (size_t) cols[j]);

            _NFIdebug ((fname, "output_string = <%s>\n", output_string));

            if ((strlen (data_ptr[k])) < cols[j])
              {
                /*  Pad the remaining space with blanks  */

                sprintf (blanks, "%*s", cols[j] - (strlen (data_ptr[k])), " ");
                strcat (output_string, blanks);
              }
          }

        /*  Write listing data to the file  */

        _NFIdebug ((fname, "Writing <%s> to file\n", output_string));

        if ((status = (long) fputs (output_string, outfile)) == EOF)
          {
            _NFIdebug ((fname, "fputs = <%d>\n", status));
            fclose (outfile);
            if (output_string) free (output_string);
            if (blanks) free (blanks);
            ERRload_struct (NFI, NFI_E_APPEND_FILE, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_APPEND_FILE);
          }

        if ((status = (long) fputs ("\n", outfile)) == EOF)
          {
            _NFIdebug ((fname, "fputs = <%d>\n", status));
            fclose (outfile);
            if (output_string) free (output_string);
            if (blanks) free (blanks);
            ERRload_struct (NFI, NFI_E_APPEND_FILE, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_APPEND_FILE);
          }
      }

    /*  Put a blank line at the end (file was opened for append)  */

    if ((status = (long) fputs ("\n", outfile)) == EOF)
      {
        _NFIdebug ((fname, "fputs = <%d>\n", status));
        fclose (outfile);
        if (output_string) free (output_string);
        if (blanks) free (blanks);
        ERRload_struct (NFI, NFI_E_APPEND_FILE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_APPEND_FILE);
      }

    /*  Close the file and deallocate space  */

    fclose (outfile);
    if (output_string) free (output_string);
    if (blanks) free (blanks);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

