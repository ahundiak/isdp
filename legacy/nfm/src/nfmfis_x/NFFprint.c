
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include <time.h>
#include <errno.h>
#include <pwd.h>

/*
   addition [KMM on 10.12.93]:

   NFMporttypes.h defines macros for OS specific typedefs.
*/

#include "NFMporttypes.h"

/* addition ends. */

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFprint_listing (f_label)
  int    f_label;
  {
    auto    int     i;
    auto    int     status;
    auto    int     *cols;
    auto    int     selected;
    auto    int     displayed;
    auto    int     num_cols;
    auto    int     uid;
    auto    char    *time_string;
    auto    char    filename[120];
    auto    time_t  time_now;
    struct  passwd  *pswd_ptr;
    auto    Form    form = NULL;
    static  char    *fname = "_NFFprint_listing";

    /*
    modification [KMM on 10.12.93]:

    original:

    pswd_ptr = getpwuid (uid=getuid ());

    */

    /*
       Added braces to uid=.. to avoid compilation error in CLIX
       recompilation in the line below - Vasu
    */

    pswd_ptr = getpwuid ((NFM_UID_T)(uid=getuid ()));

    /* modification ends. */

    if (pswd_ptr)
        sprintf (filename, "%s/", pswd_ptr -> pw_dir);
    else
	strcpy( filename, "" );

    /*  Get the output filename for the listing  */

    switch (f_label)
      {
        case PROJECTS_LABEL:
            strcat (filename, "projects.list");
            num_cols = PROJECTS_COLUMNS;
            break;

        case CATALOGS_LABEL:
            strcat (filename, "catalogs.list");
            num_cols = CATALOGS_COLUMNS;
            break;

        case ITEMS_LABEL:
            strcat (filename, "items.list");
            FImcf_get_num_cols (NFFglobal.forms[f_label], TOP_MCF, &num_cols);
            break;

        case WORKING_AREAS_LABEL_ADMIN:
        case WORKING_AREAS_LABEL_USER:
            strcat (filename, "w_areas.list");
            num_cols = WORKING_AREAS_COLUMNS;
            break;

        case NODES_LABEL:
            strcat (filename, "nodes.list");
            num_cols = NODES_COLUMNS;
            break;

        case STORAGE_AREAS_LABEL:
            strcat (filename, "s_areas.list");
            num_cols = STORAGE_AREAS_COLUMNS;
            break;

        case USERS_LABEL:
            strcat (filename, "users.list");
            num_cols = USERS_COLUMNS;
            break;

        case REVIEW_LABEL:
            strcat (filename, "rev_item.list");
            FImcf_get_num_cols (NFFglobal.forms[f_label], TOP_MCF, &num_cols);
            break;

        case WORKFLOWS_LABEL:
            strcat (filename, "workflows.list");
            num_cols = WORKFLOWS_COLUMNS;
            break;

        case ACLS_LABEL:
            strcat (filename, "acls.list");
            num_cols = ACLS_COLUMNS;
            break;

        case ACLUSERS_LABEL:
            strcat (filename, "aclusers.list");
            num_cols = ACLUSERS_COLUMNS;
            break;

        case SIGNOFFUSERS_LABEL:
            strcat (filename, "so_users.list");
            num_cols = SIGNOFFUSERS_COLUMNS;
            break;

        case CATALOGACL_LABEL:
            strcat (filename, "cat_acls.list");
            num_cols = CATALOGACL_COLUMNS;
            break;

        case CATALOGSA_LABEL:
            strcat (filename, "cat_sa.list");
            num_cols = CATALOGSA_COLUMNS;
            break;

        case PROJECTACL_LABEL:
            strcat (filename, "proj_acl.list");
            num_cols = PROJECTACL_COLUMNS;
            break;

        case PROJECTSA_LABEL:
            strcat (filename, "proj_sa.list");
            num_cols = PROJECTSA_COLUMNS;
            break;

        case ARCHIVES_LABEL:
            strcat (filename, "archives.list");
            num_cols = ARCHIVES_COLUMNS;
            break;

        case BACKUPS_LABEL:
            strcat (filename, "backups.list");
            num_cols = BACKUPS_COLUMNS;
            break;

        case RESTORE_LABEL:
            strcat (filename, "restore.list");
            num_cols = RESTORE_COLUMNS;
            break;

        case DELETE_LABEL:
            strcat (filename, "delete.list");
            num_cols = DELETE_COLUMNS;
            break;

        case SEARCH_LABEL:
            strcat (filename, "search.list");
            num_cols = CRITERIA_COLUMNS;
            break;

        case SORT_LABEL:
            strcat (filename, "sort.list");
            num_cols = CRITERIA_COLUMNS;
            break;

        case LOCAL_FILES_LABEL:
            strcat (filename, "files.list");
            num_cols = LOCAL_FILES_COLUMNS;
            break;

        case ITEM_SIGNOFF_LABEL:
            strcat (filename, "so_item.list");
            num_cols = ITEM_SIGNOFF_COLUMNS;
            break;

        case SIGNOFF_HISTORY_LABEL:
            strcat (filename, "so_hist.list");
            num_cols = SIGNOFF_HISTORY_COLUMNS;
            break;

        case PROJM_LABEL:
            strcat (filename, "items_proj.list");
            num_cols = PROJM_COLUMNS;
            break;

        case SETM_LABEL:
            strcat (filename, "set_mem.list");
            num_cols = SETM_COLUMNS;
            break;

        case WHERE_PROJECT_LABEL:
            strcat (filename, "wh_proj.list");
            num_cols = WHERE_PROJECT_COLUMNS;
            break;

        case WHERE_SET_LABEL:
            strcat (filename, "wh_set.list");
            num_cols = WHERE_SET_COLUMNS;
            break;

        case LIST_ARCHIVES_LABEL:
            strcat (filename, "archives.list");
            num_cols = LIST_ARCHIVES_COLUMNS;
            break;

        case SAVESETS_LABEL:
            strcat (filename, "savesets.list");
            num_cols = SAVESETS_COLUMNS;
            break;

        case ITEMS_TAPE_LABEL:
            strcat (filename, "item_tape.list");
            num_cols = ITEMS_TAPE_COLUMNS;
            break;

        case TAPE_LABELS_LABEL:
            strcat (filename, "labels.list");
            num_cols = TAPE_LABELS_COLUMNS;
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

    if ((cols = (int *) malloc (num_cols * (sizeof (int)))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", num_cols * (sizeof (int))));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", num_cols * (sizeof (int)));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if (f_label < CURRENT_LABEL)
        form = NFFglobal.forms[f_label];
    else
        form = NFFglobal.current_form;

    displayed = 0;
    for (i = 0; i < num_cols; ++i)
      {
        /*  See if this attribute is to be printed but FORCE both 
	 *  columns of Review Item Attributes to be printed.
         */

        if( f_label != REVIEW_LABEL )
          {
            if ((status = FIfld_get_select
                (form, TOP_MCF, 0, i, &selected)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                if (cols) free (cols);
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
   	  }
	else
	    selected = TRUE;

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Column %d is NOT to be printed\n", i));
            cols[i] = -1;
          }
        else
          {
            _NFIdebug ((fname, "Column %d IS to be printed\n", i));
            cols[i] = displayed;
            ++displayed;
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

    NFFform_message (f_label, NFI_I_PRINTING, NULL);

    /*  Call function to actually write to the file  */

    if ((status = _NFFprint_to_file
        (form, num_cols, cols, time_string, filename)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFprint_to_file = <0x%.8x>\n", status));
        if (cols) free (cols);
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (cols) free (cols);

    /*  Erase the message  */

    NFFerase_message ();

    ERRload_struct (NFI, NFI_I_PRINT_LISTING, "%s", filename);
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_I_PRINT_LISTING);
  }


long _NFFprint_to_file (form, num_cols, cols, time_string, filename)
  Form   form;          /*  i - Listing form to get the data from           */
  int    num_cols;      /*  i - Number of columns in the MCF                */
  int    *cols;         /*  i - Array of selected columns to print          */
  char   *time_string;  /*  i - Current date/time as a 26 character string  */
  char   *filename;     /*  i - Name of file to print listing to            */
  {
    auto    int     i, j;
    auto    int     length;
    auto    int     sel, rpos;
    auto    int     num_chars;
    auto    int     num_rows;
    auto    long    status;
    auto    char    *blanks;
    auto    char    *output_string;
    auto    char    temp_str[512];
    auto    FILE    *outfile;
    static  char    *fname = "_NFFprint_to_file";

    _NFIdebug ((fname, "Print file <%s>\n", filename));

    if ((outfile = fopen (filename, "a")) == NULL)
      {
        _NFIdebug ((fname, "fopen failed; filename = <%s>\n", filename));
        ERRload_struct (NFI, NFI_E_OPEN_FILE_APPEND, "%s", filename);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_OPEN_FILE_APPEND);
      }

    /*  Scan the data_list for the length of the rows  */

    length = 0;
    FIfld_get_num_rows (form, MCF, &num_rows);
    for (i = 0; i < num_cols; ++i)
      {
        /*  See if this data is to be output  */

        if (cols[i] == -1) continue;

        /*  Determine how wide the column is  */

        FIfld_get_text_length (form, TOP_MCF, 0, i, &num_chars);
        cols[i] = num_chars + 2;

        for (j = 0; j < num_rows; ++j)
          {
            FIfld_get_text_length (form, MCF, j, i, &num_chars);

            /*  Add one for an extra blank between columns  */

            if (cols[i] < (num_chars + 1))
                cols[i] = num_chars + 1;
          }

        length += cols[i];
      }

     for (i = 0; i < num_cols; ++i)
         _NFIdebug ((fname, "cols[%d] = <%d>\n", i, cols[i]));

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

    /*  Write the column headings first  */

    for (i = 0; i < num_cols; ++i)
      {
        /*  See if this data is to be output  */

        if (cols[i] == -1) continue;

        /*  Get the text out of the TOP_MCF  */

        FIfld_get_text
            (form, TOP_MCF, 0, i, sizeof (temp_str), temp_str, &sel, &rpos);

        /*  Build the output string  */

        strncat (output_string, temp_str, (size_t) cols[i]);

        _NFIdebug ((fname, "output_string = <%s>\n", output_string));

        if ((strlen (temp_str)) < cols[i])
          {
            /*  Pad the remaining space with blanks  */

            sprintf (blanks, "%*s", cols[i] - (strlen (temp_str)) - 1, " ");
            strcat (output_string, blanks);
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

    FIfld_get_num_rows (form, MCF, &num_rows);
    for (i = 0; i < num_rows; ++i)
      {
        strcpy (output_string, "");

        for (j = 0; j < num_cols; ++j)
          {
            /*  See if this data is to be output  */

            if (cols[j] == -1) continue;

            /*  Get the text out of the MCF  */

            FIfld_get_text
                (form, MCF, i, j, sizeof (temp_str), temp_str, &sel, &rpos);

            /*  Build the output string  */

            strncat (output_string, temp_str, (size_t) cols[j]);

            _NFIdebug ((fname, "output_string = <%s>\n", output_string));

            if ((strlen (temp_str)) < cols[j])
              {
                /*  Pad the remaining space with blanks  */

                sprintf (blanks,
                    "%*s", cols[j] - (strlen (temp_str)) - 1, " ");
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
    NFMchmod( filename, 00666 );
    if (output_string) free (output_string);
    if (blanks) free (blanks);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
