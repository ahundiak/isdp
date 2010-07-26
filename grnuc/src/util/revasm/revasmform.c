/*
Name
        revasmform.c

Description
        This file contains functions used with the Revise Assembly form.

Notes
        This file is used to drive the Revise Assembly form from both within
        EMS and from the external utililty copy_assembly.  Since in the latter
        case this code will be linked *without* GRNUC, EXNUC, etc., great care
        must be taken not to introduce dependencies on that code.  This is
        preferable to maintaining two sets of source code or using #ifdef's to
        compile seperate object files.

History
        mrm     07/15/92    creation
        gang    03/04/93    Modified to support cyclic attachments.
        mrm     07/16/93    check for MDS if EMS is not loaded, removed hacks
                            added for custom Xerox build, change directories
                            before copying files to make sure relative
                            pathnames can be found
        dkk     07/28/94    fix for copying a file only once and fix for
                            changing the internal osname in the master after
                            a copy in place of master and its children.
*/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <alloca.h>
#ifdef X11
#include <X11/Intrinsic.h>
#include <FI.h>
#endif
#ifdef ENV5
#include <tools.h>
#include <FI.h>
#endif
#include "grmsg.h"
#include "refdef.h"
#include "refco.h"

#ifdef SUNOS
extern char *getwd();
#endif

/*
        Miscellaneous definitions and exit codes.
*/

#define TRUE    1
#define FALSE   0
#define Null    ((char*)NULL)

/*
        Static variables
*/

static int verbose = FALSE;

/*
Name
        GRrevasm_verbose

Description
        This function may be used to turn on some debugging output.
*/

int GRrevasm_verbose(state)
int state;
{
    if (state == TRUE || state == FALSE)
        return(verbose = state);
    else
        return(verbose);
}

/*
Name
        GRrevasm_scan_feedback

Description
        This is a callback function to be used while building the reference
        file list.  It will be called when each file is scanned for reference
        file attachments.  This allows the user to see that something is
        actually going on, rather than staring at a blank form for what might
        seem to be a long time.
*/

void GRrevasm_scan_feedback(filename, form)
char *filename;
Form form;
{
    char buf[MAXPATHLEN];

    UMSGetByNum(buf, GR_I_Scanning, "%s", filename);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
}

/*
Name
        GRref_files_on_form

Description
        This function builds a list of reference file attachments and displays
        it on the form.
*/

int GRref_files_on_form(filename, form, count, reflist, refptrs)
char *filename;
Form form;
int *count;
GRreffilelist **reflist, ***refptrs;
{
    int sts, i = 0;
    char buf[MAXPATHLEN], leader[128], nest[32], warning;
    GRreffilelist *p;

    sts = GRbuild_ref_list(filename, GRNestedInfo,
                           GRrevasm_scan_feedback, (void *)form, reflist);
    if (sts & 1)
    {
        p = *reflist;
        while (p)
        {
            /* format a leader to use indentation to represent nesting */
            memset(leader, (int)' ', p->depth * IndentWidth);
            leader[p->depth * IndentWidth] = NULL;

            /* format the current file name */
            sprintf(buf, "%s%s", leader, p->instance.name);

            /* format the nesting level */
            warning = (p->instance.flags & CantReadFile) ? '*' : ' ';
            sprintf(nest, "%-4d%c", p->depth, warning);

            /* add them to the form */
            FIfld_set_text(form, FileNameField, i,
                           NestLevelColumn, nest, TRUE);
            FIfld_set_text(form, FileNameField, i++,
                           CurrentNameColumn, buf, TRUE);

            /* increment the pointer */
            p = p->next;
        }

        /* set the output count */
        *count = i;

        if (refptrs)
        {
            /* create an array of pointers for convenient access into the
               linked list using the form's field row counter (since the list
               was not allocated contiguously) */
            *refptrs = (GRreffilelist **)calloc(i, sizeof(GRreffilelist *));
            for (i = 0, p = *reflist; p; (*refptrs)[i++] = p, p = p->next);
        }
    }
    return((*count = i) ? TRUE : FALSE);
}

static void GRrevasm_set_row_state(form, row, state)
Form form;
int row, state;
{
    FIfld_set_select(form, FileNameField, row, NestLevelColumn, state);
    FIfld_set_select(form, FileNameField, row, CurrentNameColumn, state);
    FIfld_set_select(form, FileNameField, row, OperationColumn, state);
    FIfld_set_select(form, FileNameField, row, NewNameColumn, state);
}

/*
Name
        GRrevasm_new_target_name

Description
        This function accepts a filename and changes the directory path and/or
        the suffix.  An error message is added to the string if the filename
        exists on disk or is not unique within the new name list on the form.
*/

/* ARGSUSED */
static void GRrevasm_new_target_name(old_name, new_path, suffix, form,
                                    index, total_file_count, new_name)
char *old_name, *new_path, *suffix;
Form form;
int index, total_file_count;
char *new_name;
{
    int  state, op, found;
    char *c, *n, *s, *errmsg, buf[MAXPATHLEN];
    GRrevasm_data *cd;
    GRreffilelist *l;

    FIf_get_user_pointer(form, (char **)&cd);

    /* check on the parent's operation */
    if (cd->list[index]->parent)
    {
        if (cd->list[index]->parent->flags & (NoOperation | ReplaceOperation))
        {
            /* this row cannot be selected */
            cd->list[index]->flags = NoOperation;
            *new_name = NULL;
            FIfld_set_text(form, FileNameField, index, OperationColumn, 
                           "", FALSE);
            FIfld_set_text(form, FileNameField, index, NewNameColumn, 
                           "", FALSE);
            GRrevasm_set_row_state(form, index, FALSE);
            return;
        }
    }

    /* assign the new path */
    if (new_path)
    {
        /* copy whitespace into new name */
        for (c = old_name, n = new_name; isspace(*c); *n++ = ' ', c++);

        /* rip the directory spec off the original name */
        s = c;
        while (*c && !isspace(*c)) c++;
        c--;
        while ((c > s) && (*c != '/') && !isspace(*c)) c--;
        if (c != s) c++;

        /* format the new path */
        if ((*new_path == NULL) ||
            (strlen(new_path) && (new_path[strlen(new_path) - 1] == '/')))
            s = "";
        else
            s = "/";
        sprintf(n, "%s%s%s", new_path, s, c);
    }
    else if (new_name != old_name)
    {
        strcpy(new_name, old_name);
    }

    /* assign the new suffix */
    if (suffix)
    {
        strcat(new_name, suffix);
    }

    /* strip off any whitespace or old error messages */
    for (c = new_name; isspace(*c); c++);       /* past leading whitespace */
    while (*c && !isspace(*c)) c++;             /* to end of name */
    *c = NULL;                                  /* terminate string */

    /* make sure the new file name does not already exist on disk */
    errmsg = NULL;
    op = CopyOperation;
    for (c = new_name; isspace(*c); c++);
    if (access(c, F_OK) == 0)
    {
        struct stat old, new;

        /* File is already out there; is it the same as the current file? */
        /* Note - old_name is not necessarily current name */
        stat(c, &new);
        stat(cd->list[index]->instance.name, &old);
        if (new.st_ino == old.st_ino)
        {
            /* if there are children to be changed, then this is an edit */
            found = FALSE;
            if (l = cd->list[index]->child)
            {
                do
                {
                    if (l->flags & (CopyOperation | ReplaceOperation |
                                    OverWriteOperation | EditOperation))
                    {
                        found = TRUE;
                        cd->list[index]->flags = op = EditOperation;
                        UMSGetByNum(buf, GR_I_edit, 0);
                        state = TRUE;
                    }
                }
                while (!found && (l = l->sibling));
            }
            if (!found)
            {
                /* this is a no change */
                cd->list[index]->flags = op = NoChangeOperation;
                UMSGetByNum(buf, GR_I_NoChange, 0);
                state = FALSE;
            }
        }
        else
        {
            /* different file */
            /* strcpy(new_name, old_name); hoses new dir case */
            cd->list[index]->flags = op = ReplaceOperation;
            UMSGetByNum(buf, GR_I_replace, 0);
            state = TRUE;
        }
        FIfld_set_text(form, FileNameField, index, OperationColumn, 
                       buf, FALSE);
        GRrevasm_set_row_state(form, index, state);
    }
    else 
    {
        /* make sure the directory specified is writable */
        if (s = strrchr(strcpy(buf, c), '/'))
            *s = NULL;
        else
            strcpy(buf, "./");
            
        if (access(buf, W_OK) != 0)
        {
            perror(c);
            UMSGetByNum(buf, GR_E_NotWritable, 0);
            errmsg = buf;
        }
        else
        {

            if ((op & CopyOperation) && (errmsg == NULL))
            {
                /* filename must be ok; set the operation to copy */
                cd->list[index]->flags = CopyOperation;
                UMSGetByNum(buf, GR_I_copy, 0);
                FIfld_set_text(form, FileNameField, index, OperationColumn, 
                               buf, FALSE);
            }
        }
    }

    if (errmsg)
    {
        /* flag this file as a problem */
        strcat(new_name, " ");
        strcat(new_name, errmsg);

        /* deselect the old file (the user must edit this by hand) */
        GRrevasm_set_row_state(form, index, FALSE);
    }
    else if (op != NoChangeOperation)
        /* make sure the entire row (especially OperationColumn) matches */
        GRrevasm_set_row_state(form, index, TRUE);
}

/*
Name
        GRrevasm_check_for_good_name

Description
        This function checks a target filename for error flags.  It assumes
        that any filename that contains embedded blanks has some sort of error
        message trailing it.
*/

static int GRrevasm_check_for_good_name(form, index)
Form form;
int index;
{
    int state, rpos;
    char *c, filename[MAXPATHLEN];

    /* get the name */
    FIfld_get_text(form, FileNameField, index, NewNameColumn, MAXPATHLEN, 
                   filename, &state, &rpos);

    /* skip past the indentation */
    for (c = filename; isspace(*c); c++);

    /* scan over the name looking for blanks */
    while (*c && !isspace(*c)) c++;

    /* return the results */
    return((*c) ? FALSE : TRUE);
}

/*
Name
        GRrevasm_strip_suffix

Description
        This function strips the suffix from each entry in the New Name
        column.
*/

static void GRrevasm_strip_suffix(form)
Form form;
{
    int i, state, rpos;
    char old_name[MAXPATHLEN], *o, *c, *n;
    GRrevasm_data *cd;

    /* loop through all files stripping off the old suffix */
    FIf_get_user_pointer(form, (char **)&cd);
    for (i = 0; i < cd->total_file_count; i++)
    {
        /* get the proposed name */
        FIfld_get_text(form, FileNameField, i, NewNameColumn,
                       MAXPATHLEN, old_name, &state, &rpos);

        /* pull the base filename out of the proposed name */
        for (o = old_name; isspace(*o); o++);
        for (c = &o[strlen(o)]; (*c != '/') && (c > o); c--)
            if (isspace(*c))
                *c = NULL;
        c++;

        /* strip off the old suffix */
        n = &c[strlen(c) - strlen(cd->suffix)];
        if (strcmp(n, cd->suffix) == NULL)
            *n = NULL;

        /* display the new name */
        FIfld_set_text(form, FileNameField, i, NewNameColumn, 
                       old_name, FALSE);
    }
}

/*
Name
        GRrevasm_match_nested_selections

Description
        This function sets fields representing nested reference file
        attachments to match the selection state of the specified row.
*/

static void GRrevasm_match_nested_selections(form, row)
Form form;
int row;
{
    int i, sts, depth, parent_depth, state, rpos, errcount;
    char nest_level[16], buf[MAXPATHLEN], filename[MAXPATHLEN];
    GRrevasm_data *cd;

    FIfld_get_text(form, FileNameField, row, NestLevelColumn,
                   16, nest_level, &sts, &rpos);
    depth = atoi(nest_level);
    FIf_get_user_pointer(form, (char **)&cd);

    if (sts == TRUE)
    {
        /* enforce the "no discontinuity" rule by turning on all parents */

        /* first, make sure all parents have valid names */
        errcount = 0;
        parent_depth = depth;
        i = row - 1;
        while (i >= 0)
        {
            FIfld_get_text(form, FileNameField, i, NestLevelColumn,
                           16, nest_level, &state, &rpos);
            if (atoi(nest_level) < parent_depth)
            {
                if (!GRrevasm_check_for_good_name(form, i))
                {
                    FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                                   MAXPATHLEN, filename, &state, &rpos);
                    UMSGetByNum(buf, GR_E_CantSelBadParent, "%s", filename);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
                    GRrevasm_set_row_state(form, row, FALSE);
                    sts = FALSE;
                }
                parent_depth = parent_depth - 1;
            }
            i = i - 1;
        }

        /* set all parent entries to match the selected row */
        i = row - 1;
        parent_depth = depth;
        while (i >= 0)
        {
            FIfld_get_text(form, FileNameField, i, NestLevelColumn,
                           16, nest_level, &state, &rpos);
            if (atoi(nest_level) < parent_depth)
            {
                if (GRrevasm_check_for_good_name(form, i))
                {
                    GRrevasm_set_row_state(form, i, sts);
                }
                parent_depth = parent_depth - 1;
            }
            i = i - 1;
        }

        /* kick out if an error was found in a parent filename */
        if (sts == FALSE)
            return;
    }
                
    /* set nested files to match the current row */
    for (i = row + 1; i < cd->total_file_count; i++)
    {
        if (!(cd->list[i]->flags & NoOperation) &&
            GRrevasm_check_for_good_name(form, i))
        {
            FIfld_get_text(form, FileNameField, i, NestLevelColumn,
                           16, nest_level, &state, &rpos);
            if (depth < atoi(nest_level))
            {
                GRrevasm_set_row_state(form, i, sts);
            }
            else
                break;
        }
    }
}

/*
Name
        GRrevasm_verify_selection

Description
        This function checks whether a row is eligible to be selected.
*/

static int GRrevasm_verify_selection(form, row, cd)
Form form;
int row;
GRrevasm_data *cd;
{
    int sts = FALSE;
    char buf[128];

    /* make sure this isn't a field with a naming problem */
    if (GRrevasm_check_for_good_name(form, row))
    {
        if (!(cd->list[row]->flags & NoOperation))
        {
            /* row ok, set nested files to match this field's state */
            sts = TRUE;
            GRrevasm_match_nested_selections(form, row);
        }
        else
        {
            UMSGetByNum(buf, GR_E_CantEditSubAsm, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            GRrevasm_set_row_state(form, row, FALSE);
        }
    }
    else
    {
        /* this line contains a bad target filename */
   /*
        UMSGetByNum(buf, GR_E_CantSelBadFName, 0);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
        GRrevasm_set_row_state(form, row, FALSE);
   */
    }
    return(sts);
}

/*
Name
        GRinit_revasm_form

Description
        This function initializes the data in the Revise Assembly form.
*/

int GRinit_revasm_form(form, n_files, files, new_path, suffix, 
                      total_file_count, list)
Form form;
int n_files;
char *files[], *new_path, *suffix;
int *total_file_count;
GRreffilelist ***list;
{
    int i, sts, state = 0;
    int rpos;
    char old_name[MAXPATHLEN], new_name[MAXPATHLEN];
    GRreffilelist *linked_list;

    /* adjust the path gadgets */
    if (new_path)
    {
        FIg_set_state(form, PreservePathToggle, 1);
        FIfld_set_text(form, PathField, 0, 0, new_path, FALSE);
    }
    else
    {
        FIg_set_state(form, PreservePathToggle, 0);
    }

    /* adjust the auto naming gadgets */
    if (suffix)
    {
        FIg_set_state(form, AutoNamingToggle, 0);
        FIfld_set_text(form, SuffixField, 0, 0, suffix, FALSE);
    }
    else
    {
        FIg_set_state(form, AutoNamingToggle, 1);
    }

    /* fill in the file names along with nested attachments */
    for (i = 0; i < n_files; i++)
    {
        sts = GRref_files_on_form(files[i], form, total_file_count,
                                  &linked_list, list);
        if (!(sts & 1))
            return(FALSE);
    }

    /* assign the new names */
    for (i = 0; i < *total_file_count; i++)
    {
        /* get the old name */
        FIfld_get_text(form, FileNameField, i, CurrentNameColumn, MAXPATHLEN, 
                       old_name, &state, &rpos);

        /* apply the new path & suffix, and validate the new name */
        GRrevasm_new_target_name(old_name, new_path, suffix, form, i,
                                *total_file_count, new_name);

        /* display the new name */
        FIfld_set_text(form, FileNameField, i, NewNameColumn, new_name, FALSE);
    }

    return(TRUE);
}

/*
Name
        GRrevasm_callback

Description
        This function handles all input to the Revise Assembly form.
*/

/* ARGSUSED */
void GRrevasm_callback(f_label, g_label, value, form)
int f_label, g_label;
double value;
Form form;
{
    int i, j, count, state, rpos, row, col, errcount, cra, depth, found;
    char *c, *o, *command, **reused_intosnames, *cwd, *file_dir;
    char new_path[MAXPATHLEN], buf[MAXPATHLEN], *buf2, leader[128];
    char new_name[MAXPATHLEN], old_name[MAXPATHLEN], new_suffix[16];
    char data_file[MAXPATHLEN], title[32];
    char dros[MAXPATHLEN], *eoc, *ems = "ems";
    GRrevasm_data *cd;
    GRreffilelist *l;
    FILE *fp, *dp;
    struct stat p_stat, q_stat;
    int sts;

    /* clear any lingering prompts */
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", FALSE);

    switch (g_label)
    {
      case FI_ACCEPT:

        /* 
            Build the copyOS command.
        */
        FIf_get_user_pointer(form, (char **)&cd);
        command = (char *)alloca((cd->total_file_count + 1) * MAXPATHLEN);
        command[0] = NULL;
        GRget_product_data("Exnuc", Null, Null, Null, Null, command);
        if (command[0] == NULL)
        {
            /* someone's playing games... */
            UMSGetByNum(buf, GR_E_NotInProdData, "%s", "Exnuc");
            UMSGetByNum(title, GR_I_Error, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            FI_msg_box2(title, FI_RED, buf, FI_BLACK);
            fprintf(stderr,"%s\n", buf);
            FIg_set_state(form, g_label, 0);
            break;
        }
        strcat(command, "bin/copyOS");
        if (access(command, X_OK) != 0)
        {
            UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", "copyOS");
            UMSGetByNum(title, GR_I_Error, 0);
            fprintf(stderr, "%s\n", buf);
            perror(command);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            FI_msg_box2(title, FI_RED, buf, FI_BLACK);
            FIg_set_state(form, g_label, 0);
            break;
        }

        /* redirect stderr to the stdout stream */
        strcat(command, " 2>&1 ");

        /* check whether to change the ref file attachments */
        dp = NULL;
        cra = (cd->flags & ChangeRefAttachments) ? TRUE : FALSE;
        if (cra)
        {
            /*
                Open a file to store the old/new name pairs.  This file will
                be used later by a ppl command in a batch EMS process to
                change all the reference file attachments.
            */

            c = (c = getenv("TMPDIR")) ? c : "/usr/tmp";
            sprintf(data_file, "%s/revasmXXXXXX", c);
            mktemp(data_file);
            if ((dp = (FILE *)fopen(data_file, "w")) == NULL)
            {
                cra = FALSE;
                UMSGetByNum(buf, GR_E_CannotChRfAtt, 0);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
                c = &buf[strlen(buf)];
                sprintf(c, "; ");
                c += 2;
                UMSGetByNum(c, GR_E_CannotOpenFile, "%s", data_file);
                UMSGetByNum(title, GR_I_Notice, 0);
                FI_msg_box2(title, FI_BLUE, buf, FI_BLACK);
            }
        }

        /* build a list of valid files */
        for (i = 0, errcount = 0, count = 0; i < cd->total_file_count; i++)
        {
            /* check the target name for problems */
            if (GRrevasm_check_for_good_name(form, i))
            {
                /* good old/new pair - run with 'em */
                FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                               MAXPATHLEN, old_name, &state, &rpos);
                FIfld_get_text(form, FileNameField, i, NewNameColumn,
                               MAXPATHLEN, new_name, &state, &rpos);

                /* check whether the row is selected */
                FImcf_get_select(form, FileNameField, i, &state);
                if (state && 
                    !(cd->list[i]->flags & EditOperation) &&
                    !(cd->list[i]->flags & ReplaceOperation))
                {
/* FIX to avoid copying the same file multiple times ***************/
                int st, rp;

		    /* Check if this file has already been copied */
                    for(c = new_name; isspace(*c); c++);
                    for(j = 0; j < i; j++)
                    {
                        if (GRrevasm_check_for_good_name(form, j))
                        {
                            FIfld_get_text(form, FileNameField, j, NewNameColumn,
                                           MAXPATHLEN, buf, &st, &rp);

                            /* check whether the row is selected */
                            FImcf_get_select(form, FileNameField, j, &st);
                            if (st && 
                                !(cd->list[j]->flags & EditOperation) &&
                                !(cd->list[j]->flags & ReplaceOperation))
                            {
                                for(o = buf; isspace(*o); o++);
                                if (!strcmp(c, o)) /* same file */
				    break;
                            }
                        }
                    }
                    sts = 0;
                    if (j == i) /* file not copied, copy this */
		    {
/* END of FIX */
                        /* add old/new pair to the command line */
                        sprintf(buf, "%s %s %s ", command,old_name, new_name);
                        if (verbose)
                        puts(buf);
                        /* 
                            Fork the copyOS command
                        */
                        if ((fp = (FILE *)popen(buf, "r")) == NULL)
                        {
                            UMSGetByNum(buf,GR_E_CannotExecuteFile,"%s", "copyOS");
                            UMSGetByNum(title, GR_I_Error, 0);
                            fprintf(stderr, "%s\n", buf);
                            FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                        }
                        else
                        {
                            /* read the output */
                            c = buf;
                            while (fgets(c, sizeof(buf), fp))
                            {
                                if (strlen(buf))
                                {
                                    c = &buf[strlen(buf)];
                                }

                                if (verbose)
                                    puts(buf);
                            }

                            /* close the pipe */
                            if (pclose(fp) != 0)
                            {
                                /* warn about possibly unsuccessful operation */
                                UMSGetByNum(title, GR_I_Notice, 0);
                                FI_msg_box2(title, FI_BLUE, buf, FI_BLACK);
                            }
                            else
                                sts = 1;
                        }
                    }
                    else sts = 1;

/* Fix for changing the INT_OS_NAME in the parent file, from the old name to
   the new(copied) name in the parent file - 27/06/94
*/
		    /* If copy operation is succesful */
                    if (sts)
		    {
                        char  intosname[2][MAXPATHLEN], com1[256];
                        char  file[2][MAXPATHLEN];
		        int   st, rp;
			GRreffilelist *par;

			par = cd->list[i]->parent;
    			if (par)
			{
			    /* Get the INT_OS_NAME of the copied and the
			       original files, through dros -N */
                            strcpy(file[0], old_name);
                            strcpy(file[1], new_name);

                            /* get the path to dros */
                            GRget_product_data("Exnuc", Null, Null,
                                                   Null, Null, dros);
                            strcat(dros, "bin/dros");
                            if (access(dros, X_OK) == 0)
                            {
                                for(j = 0; j < 2; j++ )
                                {
                                    sprintf(com1,"%s -f %s -N", dros, file[j]);
                                    if (verbose) puts(com1);

                                    if ((fp = (FILE *)popen(com1, "r")) == NULL)
                                    {
                                        UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", 
                                                                dros);
                                        UMSGetByNum(title, GR_I_Error, 0);
                                        FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                                    }
                                    else
                                    {
                                        while (fgets(intosname[j], MAXPATHLEN,
                                                                         fp))
                                        {
                                            if (c = strrchr(intosname[j],
                                                (int)'\n'))
                                            *c = NULL;
                                            if (verbose)
                                                puts(intosname[j]);
                                        }
                                        if (pclose(fp) != 0)
                                        {
                                            UMSGetByNum(title, GR_I_Notice, 0);
                                            FI_msg_box2(title, FI_BLUE, 
                                                intosname[j], FI_BLACK);
                                        }
                                    }
                                }
                            }

                            while(par)
                            {
    			        /* Get the parent index and the newfilename
			           of the parent */
                                for (j = i - 1; 
                                     cd->list[j] != par;
                                     j--);

                                /* get new parent name */
                                FIfld_get_text(form, FileNameField, j,
                                           NewNameColumn, MAXPATHLEN,
                                           buf, &st, &rp);

			        /* Change the INT_OS_NAME in the parent file
				       of the original's to that of copied, using
				       dros -R */
                                sprintf(com1,"%s -f %s -R %s %s",dros, buf,
                                                    intosname[0], intosname[1]);
                                if (verbose) puts(com1);

                                if ((fp = (FILE *)popen(com1, "r")) == NULL)
                                {
                                    UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", 
                                                             dros);
                                    UMSGetByNum(title, GR_I_Error, 0);
                                    FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                                }
                                else if (pclose(fp) != 0)
                                {
                                    UMSGetByNum(title, GR_I_Notice, 0);
                                    FI_msg_box2(title, FI_BLUE, 
                                                       com1, FI_BLACK);
                                }
                                par = par->parent;
                            }
                        }
/* END OF FIX */
		    }
                    count++;
		}


                /*
                    If changing reference file attachments and the row is
                    selected or is a top-level replace file or has a
                    self-attachment
                */

                if (cra && 
                    ((state) || 
                     ((cd->list[i]->flags & ReplaceOperation) &&
                      !(cd->list[i]->parent && 
                        (cd->list[i]->parent->flags & ReplaceOperation))) || 
                     (cd->list[i]->instance.flags & HasSelfAttachedFile)))
                {
                    /*
                        Add the old/new pair to the data file, along with the
                        new master file name
                    */

                    if (cd->list[i]->parent)
                    {
                        /* find parent index */
                        for (j = i - 1; 
                             cd->list[j] != cd->list[i]->parent;
                             j--);
                            {
                        /* get new parent name */
                        FIfld_get_text(form, FileNameField, j,
                                       NewNameColumn, MAXPATHLEN,
                                       buf, &state, &rpos);

                        /* dump the data to the file */
                        fprintf(dp, "%s %s %s\n", old_name, new_name, buf);
                            }
                    }
                    else if (cd->list[i]->instance.flags & HasSelfAttachedFile)
                    {
                        /* make sure self-attachments get updated */
                        fprintf(dp, "%s %s %s\n",
                                old_name, new_name, new_name);
                    }
                }
            }
            else 
                errcount++;
        }

        /*
            Close the data file *before* invoking ems, otherwise it won't get
            flushed to disk and the process will fail to update the reference
            file attachments.
        */
        if (cra && dp)
        {
            fclose(dp);
        }

        /* make sure something is selected */
        if (count == 0)
        {
            UMSGetByNum(buf, GR_E_NoFilesSel, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            FIg_set_state(form, g_label, 0);
            if (dp) fclose(dp);
            break;
        }

        /* make sure user wants to proceed it there were bad filenames */
        if (errcount && !GRconfirm(GR_E_InvTargetNames))
        {
            /* reset the button */
            FIg_set_state(form, g_label, 0);
            if (dp) fclose(dp);
            break;
        }

        /* If the master file is not in the current directory, then a cd to
           that directory is necessary to make sure relative path names are
           found in copyOS.  Use new_name and old_name as handy buffers to
           hold the master file's directory and the current working directory,
           respectively.  */
        file_dir = old_name;
        FIfld_get_text(form, FileNameField, 0, CurrentNameColumn,
                       MAXPATHLEN, file_dir, &state, &rpos);
        if (c = strrchr(file_dir, '/'))
        {
#ifndef SUNOS
            char thisdir[MAXPATHLEN];
#endif
            *c = NULL;
#ifdef SUNOS
            if (cwd = getwd(new_name))  /* faster than getcwd */
#else
            if (cwd = getcwd(thisdir, MAXPATHLEN)) /* getwd not available */
#endif
            {
                stat(file_dir, &p_stat);
                stat(cwd, &q_stat);
                if (p_stat.st_ino != q_stat.st_ino)
                    chdir(file_dir);
            }
        }

        /* print a working message */
        UMSGetByNum(buf, GR_I_Working, 0);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);

                /* 
                    Update tag connects pointing to reused files
                */

                /* get the path to dros */
                GRget_product_data("Exnuc", Null, Null, Null, Null, dros);
                strcat(dros, "bin/dros");
                if (access(dros, X_OK) != 0)
                {
                    UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", dros);
                    UMSGetByNum(title, GR_I_Error, 0);
                    fprintf(stderr, "%s\n", buf);
                    perror(dros);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
                    FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                    break;
                }

                /* get the internal osnames of the top-level reused files */
                i = cd->total_file_count * sizeof(char *);
                reused_intosnames = (char **)alloca(i);
                memset((char *)reused_intosnames, 0, i);
                strcpy(command, dros);
                eoc = &command[strlen(command)];
                for (i = 0; i < cd->total_file_count; i++)
                {
                    if (cd->list[i]->flags & ReplaceOperation)
                    {
                        if ((cd->list[i]->parent) &&
                            (cd->list[i]->parent->flags & ReplaceOperation))
                            continue;

                        reused_intosnames[i] = 
                            (char *)alloca(sizeof(char)*MAXPATHLEN);
                        FIfld_get_text(form, FileNameField, i, NewNameColumn,
                                       MAXPATHLEN, new_name, &state, &rpos);
                        sprintf(eoc, " -f %s -N", new_name);
                        if (verbose) puts(command);
                        if ((fp = (FILE *)popen(command, "r")) == NULL)
                        {
                            UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", 
                                        dros);
                            UMSGetByNum(title, GR_I_Error, 0);
                            fprintf(stderr, "%s\n", buf);
                            FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                        }
                        else
                        {
                            while (fgets(reused_intosnames[i], MAXPATHLEN, fp))
                            {
                                if (c = strrchr(reused_intosnames[i],
                                                (int)'\n'))
                                    *c = NULL;
                                if (verbose)
                                    puts(reused_intosnames[i]);
                            }
                            if (pclose(fp) != 0)
                            {
                                UMSGetByNum(title, GR_I_Notice, 0);
                                FI_msg_box2(title, FI_BLUE, 
                                            reused_intosnames[i], FI_BLACK);
                            }
                        }
                    }
                }
                        
                /* decide which files refer to reused files */
                for (i = 0, *command = NULL; 
                     i < cd->total_file_count;
                     i++, *command = NULL)
                {
                    if (!(cd->list[i]->flags & ReplaceOperation))
                    {
                        for (l = cd->list[i]->child; l; l = l->sibling)
                        {
                            if (l->flags & ReplaceOperation)
                            {
                                /* found a reused file - get new name */
                                for (j = 0; cd->list[j] != l; j++);

                                /* check whether a different file was reused */
                                if (strcmp(reused_intosnames[j],
                                           l->instance.intosname) != 0)
                                {
                                    if (*command == NULL)
                                    {
                                        /* format a dros command */
                                        FIfld_get_text(form, FileNameField, i,
                                                       NewNameColumn, 
                                                       MAXPATHLEN, new_name,
                                                       &state, &rpos);
                                        sprintf(command, "%s -f %s -R ",
                                                dros, new_name);
                                    }

                                    /* add the changes to the command line */
                                    sprintf(buf, " %s %s",
                                            l->instance.intosname,
                                            reused_intosnames[j]);
                                    strcat(command, buf);
                                }
                            }
                        }

                        if (*command)   /* Star Command? This is Buck Rogers */
                        {
                            /* 
                                change the tag connects to the reused files
                            */
                            if (verbose) puts(command);
                            if ((fp = (FILE *)popen(command, "r")) == NULL)
                            {
                                UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", 
                                            dros);
                                UMSGetByNum(title, GR_I_Error, 0);
                                fprintf(stderr, "%s\n", buf);
                                FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                            }
                            else
                            {
                                while (fgets(buf, MAXPATHLEN, fp))
                                    if (verbose)
                                        puts(buf);
                                if (pclose(fp) != 0)
                                {
                                    UMSGetByNum(title, GR_I_Notice, 0);
                                    FI_msg_box2(title, FI_BLUE, 
                                                buf, FI_BLACK);
                                }
                            }
                        }
                    }
                }

                if (cra)
                {
                    /*
                        Run EMS in batch to change the ref file attachments
                    */

                    /* prepare the user for a long wait */
                    UMSGetByNum(buf, GR_I_ChangingRfAtt, 0);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);

                    /* get the path to EMS (already validated in main) */
                    buf[0] = NULL;
                    GRget_product_data("Emsui01", Null, Null, Null, Null, buf);
                    if (buf[0] == NULL)
                    {
                        GRget_product_data("Emsui02", Null, Null, 
                                           Null, Null, buf);
                        if (buf[0] == NULL)
                        {
                            GRget_product_data("Mdsui01",  Null, Null,
                                               Null, Null, buf);
                            if (buf[0] == NULL)
                                GRget_product_data("Mdsui02",  Null, Null,
                                                   Null, Null, buf);
                            if (buf[0])
                                ems = "mds";
                        }
                    }
                    if (buf[0] != '\0')
                    {
                        char * c = strrchr (buf, '/');

                        if (c != NULL)
                        {
                            *c = '\0';

                            if ((c = strrchr(buf, '/')) != NULL)
                            {
                                *(++c) = '\0';
                            }
                        }
                    }
                    if (buf[0] == NULL)
                    {
                        /* someone's playing games... */
                        UMSGetByNum(buf, GR_E_NotInProdData, "%s", "EMS/MDS");
                        UMSGetByNum(title, GR_I_Error, 0);
                        FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                    }
                    else
                    {
                        strcat(buf, "bin/");
                        strcat(buf, ems);
                        if (access(buf, X_OK) != 0)
                        {
                            c = new_name;       /* use a handy buffer */
                            UMSGetByNum(c, GR_E_CannotExecuteFile, "%s", buf);
                            UMSGetByNum(title, GR_I_Error, 0);
                            fprintf(stderr, "%s\n", c);
                            perror(buf);
                            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, c, FALSE);
                            FI_msg_box2(title, FI_RED, c, FI_BLACK);
                            FIg_set_state(form, g_label, 0);
                            break;
                        }

                        /* invent a non-existent file name */
                        c = (c = getenv("TMPDIR")) ? c : "/usr/tmp";
                        sprintf(new_name, "%s/revasm1XXXXXX", c);
                        mktemp(new_name);

                        /* 
                            format the ems command line -- the memory
                            alloca'ed for the copyOS command is reused here;
                            it is at least 2x MAXPATHLEN, and should be more
                            than sufficient
                        */
                        sprintf(command, 
                                "%s -cf %s -b -C \"\\\"ci=UpdRefAtt %s%s\\\"\"",
                                buf, new_name, data_file,
                                (verbose) ? " -v" : "");

                        if (verbose)
                            puts(command);

                        /* fork the ems command line */
                        if ((fp = (FILE *)popen(command, "r")) == NULL)
                        {
                            UMSGetByNum(buf, GR_E_CannotExecuteFile, 
                                        "%s", ems);
                            UMSGetByNum(title, GR_I_Error, 0);
                            fprintf(stderr, "%s\n", buf);
                            FI_msg_box2(title, FI_RED, buf, FI_BLACK);
                        }
                        else
                        {
                            /* read the output */
                            buf[0] = NULL;
                            c = new_name;       /* use a handy buffer */
                            while (fgets(c, sizeof(new_name), fp))
                            {
                                if (verbose)
                                    puts(c);

                                if ((strlen(c) + strlen(buf)) < MAXPATHLEN)
                                {
                                    strcat(buf, c);
                                }
                            }

                            /* close the pipe */
                            if (pclose(fp) != 0)
                            {
                                /* warn about possible problems */
                                UMSGetByNum(title, GR_I_Notice, 0);
                                FI_msg_box2(title, FI_BLUE, buf, FI_BLACK);
                            }
                        }
                    }
                }

        /* remove the data file */
        if (cra && dp)
            unlink(data_file);

        /* clear the working message */
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", FALSE);

        /* no break! */

      case FI_CANCEL:

        /* erase the form to return control from FI_process_forms to main */
        FIf_erase(form);

        break;

      case FileNameField:

        FIf_get_user_pointer(form, (char **)&cd);

        if (value == -1.0)
        {
            /* row selection button */
            FIfld_get_active_row(form, g_label, &row, &rpos);

            /* validate the selected row */
            GRrevasm_verify_selection(form, row, cd);
        }
        else
        {
            row = (int)value;

            /* retrieve the index of the affected column */
            FImcf_get_active_col(form, g_label, &col, &rpos);

            if ((col == NestLevelColumn) || (col == CurrentNameColumn))
            {
                /* validate the selected row */
                GRrevasm_verify_selection(form, row, cd);
            }
            else if (col == OperationColumn)
            {
                /* shouldn't get here - GRrevasm_button_intercept grabs input */
            }
            else if (col == NewNameColumn)
            {
                /* make sure input is in valid list */
                if (row >= cd->total_file_count)
                {
                    FIfld_set_text(form, FileNameField, row, NewNameColumn,
                                   "", buf);
                    break;
                }

                /* make sure the user didn't sneak into an invalid row with */
                /* the arrow keys */ 
                if (cd->list[row]->flags & NoOperation)
                {
                    UMSGetByNum(buf, GR_E_CantEditSubAsm, 0);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
                    GRrevasm_set_row_state(form, row, FALSE);
                    break;
                }

                /* get the proposed new name */
                FIfld_get_text(form, FileNameField, row, NewNameColumn,
                               MAXPATHLEN, buf, &state, &rpos);

                /* check for blank name */
                for (c = buf; isspace(*c); c++);
                if (*c == NULL)
                {
                    /* if there are children to be changed, then this is */
                    /* an edit */
                    found = FALSE;
                    if (l = cd->list[row]->child)
                    {
                        do
                        {
                            if (l->flags & (CopyOperation | 
                                            ReplaceOperation |
                                            OverWriteOperation | 
                                            EditOperation))
                            {
                                found = TRUE;
                                cd->list[row]->flags = EditOperation;
                                UMSGetByNum(buf, GR_I_edit, 0);
                                state = TRUE;
                            }
                        }
                        while (!found && (l = l->sibling));
                    }
                    if (!found)
                    {
                        /* this is a no change */
                        cd->list[row]->flags = NoChangeOperation;
                        UMSGetByNum(buf, GR_I_NoChange, 0);
                        state = FALSE;
                    }

                    FIfld_set_text(form, FileNameField, row, OperationColumn,
                                   buf, FALSE);
                    GRrevasm_set_row_state(form, row, state);
                    break;
                }

                /* check for name conflicts */
                GRrevasm_new_target_name(buf, Null, Null, form, row,
                                        cd->total_file_count, new_name);

                /* display the new name BEFORE validating */
                FIfld_set_text(form, FileNameField, row, NewNameColumn, 
                               new_name, FALSE);

                /* validate the new name */
                state = GRrevasm_check_for_good_name(form, row);

                /* don't mess with settings any further for these cases */
                if (cd->list[row]->flags & (NoChangeOperation | NoOperation))
                    break;

                if ((state == FALSE) ||
                    (cd->list[row]->flags & ReplaceOperation))
                {
                    /* toggle all nested files to noop */
                    depth = cd->list[i = row]->depth;
                    while (cd->list[i++]->next && (cd->list[i]->depth > depth))
                    {
                        cd->list[i]->flags = NoOperation;
                        FIfld_set_text(form, FileNameField, i, OperationColumn,
                                       "", FALSE);
                        FIfld_set_text(form, FileNameField, i, NewNameColumn,
                                       "", FALSE);
                        GRrevasm_set_row_state(form, i, FALSE);
                    }
                }
                else
                {
                    stat(cd->list[row]->instance.name, &p_stat);
                    for(j=0; new_name[j] == ' '; j++);
                    buf2 = strchr(new_name,new_name[j]);
                    for(i = 0; i < cd->total_file_count; i++)
                       {
                           stat(cd->list[i]->instance.name, &q_stat);

                           if(p_stat.st_ino == q_stat.st_ino)
                            {
                                 for(j=0;j < cd->list[i]->depth*IndentWidth;j++)
                                     leader[j] = ' ';
                                 leader[j] = '\0';
                                 sprintf(buf, "%s%s",leader,buf2);
                                 FIfld_set_text(form,FileNameField,i,
                                                NewNameColumn,buf,FALSE);
                            } 

                       }
                }
            }
        }
        break;

      case ClearAllButton:

        /* clear all selections */
        FIf_get_user_pointer(form, (char **)&cd);
        UMSGetByNum(buf, GR_I_NoChange, 0);
        for (i = 0; i < cd->total_file_count; i++)
        {
            cd->list[i]->flags = NoChangeOperation;
            FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                           MAXPATHLEN, old_name, &state, &rpos);
            FIfld_set_text(form, FileNameField, i, NewNameColumn,
                           old_name, FALSE);
            FIfld_set_text(form, FileNameField, i, OperationColumn,
                           buf, FALSE);
            GRrevasm_set_row_state(form, i, FALSE);
        }

        /* reset the button */
        FIg_set_state(form, g_label, 0);

        break;

      case SetAllButton:

        /* select all fields */
        FIf_get_user_pointer(form, (char **)&cd);
        for (i = 0, count = 0; i < cd->total_file_count; i++)
        {
            /* make sure this isn't a field with a naming problem */
            if (GRrevasm_check_for_good_name(form, i))
            {
                /* 
                    If this is a no change, then assume that it got that way
                    through the ClearAllButton, and regenerate a new name.
                */
                if (cd->list[i]->flags & NoChangeOperation)
                {
                    FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                                   MAXPATHLEN, old_name, &state, &rpos);
                    FIfld_get_text(form, PathField, 0, 0,
                                   MAXPATHLEN, new_path, &state, &rpos);
                    GRrevasm_new_target_name(old_name, new_path, cd->suffix, 
                                            form, i, cd->total_file_count, 
                                            new_name);
                    FIfld_set_text(form, FileNameField, i, NewNameColumn, 
                                   new_name, FALSE);
                }
            }
            else
                count++;
        }

        /* draw attention to any errors */
        if (count)
        {
            UMSGetByNum(buf, GR_E_CantSelBadFNames, "%d", count);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
        }

        /* reset the button */
        FIg_set_state(form, g_label, 0);

        break;

      case PreservePathToggle:

        if (value) /* toggle set to "No" */
        {
            /* fall through to the PathField case - no break!! */
        }
        else /* toggle set to "Yes" */
        {
            /* loop through all files changing the pathnames to match the old
               filename */
            FIf_get_user_pointer(form, (char **)&cd);
            for (i = 0; i < cd->total_file_count; i++)
            {
                /* get the current name */
                FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                               MAXPATHLEN, old_name, &state, &rpos);

                /* get the proposed new name */
                FIfld_get_text(form, FileNameField, i, NewNameColumn,
                               MAXPATHLEN, buf, &state, &rpos);
                for (c = buf; isspace(*c); c++);
                if (*c == NULL)
                    strcpy(buf, old_name);

                /* pull the directory spec out of the current name */
                for (o = old_name; isspace(*o); o++);
                for (c = &o[strlen(o)]; (*c != '/') && (c > o); c--);
                if (c == o)
                    *o = NULL;
                else
                    *(++c) = NULL;

                /* apply the new path */
                GRrevasm_new_target_name(buf, o, Null, form, i, 
                                        cd->total_file_count, new_name);

                /* display the new name */
                FIfld_set_text(form, FileNameField, i, NewNameColumn, 
                               new_name, FALSE);
            }
            break;      /* yes, this goes here */
        }

        /* no break!! */

      case PathField:

        /* make sure the Preserve Path toggle is set to "No" */
        if (g_label == PathField)
            FIg_set_state(form, PreservePathToggle, 1);

        /* get the new path */
        FIfld_get_text(form, PathField, 0, 0, MAXPATHLEN, new_path, &state,
                       &rpos);

        if (strlen(new_path) == 0)
        {
            UMSGetByNum(buf, GR_P_Cd, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            FIg_start_seq(form, PathField);
        }
        else
        {
            /* make sure the path is accessible */
            if (access(new_path, W_OK) != 0)
            {
                UMSGetByNum(buf, GR_E_CantWriteDir, 0);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
                FIg_start_seq(form, PathField);
            }
            else
            {
                /* loop through all fields changing the path */
                FIf_get_user_pointer(form, (char **)&cd);
                for (i = 0; i < cd->total_file_count; i++)
                {
                    /* get the current name */
                    FIfld_get_text(form, FileNameField, i, NewNameColumn,
                                   MAXPATHLEN, old_name, &state, &rpos);

                    /* apply the new path */
                    GRrevasm_new_target_name(old_name, new_path, Null,
                                            form, i, cd->total_file_count,
                                            new_name);

                    /* display the new name */
                    FIfld_set_text(form, FileNameField, i, NewNameColumn, 
                                   new_name, FALSE);
                }
            }
        }

        break;

      case AutoNamingToggle:

        if (value) /* toggle set to "No" */
        {
            /* strip off the suffix */
            GRrevasm_strip_suffix(form);

            /* validate the filename */
            FIf_get_user_pointer(form, (char **)&cd);
            for (i = 0; i < cd->total_file_count; i++)
            {
                /* get the current name */
                FIfld_get_text(form, FileNameField, i, NewNameColumn,
                               MAXPATHLEN, old_name, &state, &rpos);
                for (c = old_name; isspace(*c); c++);
                if (*c == NULL)
                {
                    /* blank name - grab to original name */
                    FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                                   MAXPATHLEN, old_name, &state, &rpos);

                    /* pick up alternate directory */
                    FIg_get_state(form, PreservePathToggle, &state);
                    if (state)
                    {
                        FIfld_get_text(form, PathField, 0, 0, 
                                       MAXPATHLEN, new_path, &state, &rpos);
                        c = *new_path ? new_path : NULL;
                    }
                    else
                        c = NULL;
                }
                else
                    c = NULL;

                /* apply the new path */
                GRrevasm_new_target_name(old_name, c, Null, form, i, 
                                        cd->total_file_count, new_name);

                /* display the new name */
                FIfld_set_text(form, FileNameField, i, NewNameColumn, 
                               new_name, FALSE);
            }

            break;      /* yes, this goes here */
        }
        else /* toggle set to "Yes" */
        {
            /* fall through to SuffixField case - no break!! */
        }

        /* no break!! */

      case SuffixField:

        /* make sure the Auto Naming toggle is set to "Yes" */
        if (g_label == SuffixField)
            FIg_set_state(form, AutoNamingToggle, 0);

        /* strip off the old suffix */
        GRrevasm_strip_suffix(form);

        /* grab the form data */
        FIf_get_user_pointer(form, (char **)&cd);

        /* get the new suffix */
        FIfld_get_text(form, SuffixField, 0, 0, 16, new_suffix,
                       &state, &rpos);

        if (new_suffix[0] != NULL)
        {
            /* add the suffix to each filename */
            for (i = 0; i < cd->total_file_count; i++)
            {
                /* get the target name */
                FIfld_get_text(form, FileNameField, i, NewNameColumn,
                               MAXPATHLEN, old_name, &state, &rpos);

                /* check for blank entry */
                for (c = old_name; isspace(*c); c++);
                if (*c == NULL)
                    FIfld_get_text(form, FileNameField, i, CurrentNameColumn,
                                   MAXPATHLEN, old_name, &state, &rpos);

                /* apply the new suffix */
                GRrevasm_new_target_name(old_name, Null, new_suffix, form, i, 
                                        cd->total_file_count, new_name);

                /* display the new name */
                FIfld_set_text(form, FileNameField, i, NewNameColumn, 
                               new_name, FALSE);
            }
        }

        /* store the new suffix */
        strncpy(cd->suffix, new_suffix, 16);
        cd->suffix[15] = NULL;

        break;

      default:

        fprintf(stderr, "Unknown gadget label: %d\n", g_label);
        break;
    }
}

/*
Name
        GRrevasm_button_intercept

Description
        This function handles input to the OperationColumn of the Copy
        Assembly form.
*/

void GRrevasm_button_intercept(form, xpos, ypos, button, trans, t_tag)
Form form;
int xpos, ypos;
int button;
int trans;
int t_tag;
{
    int invocation_button = -1;
    int row, col;

    /* clear any lingering prompts */
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", FALSE);

#ifdef X11
    invocation_button = Button2;
#endif
#ifdef ENV5
    invocation_button = MIDDLE_BUTTON;
#endif

    if ((button == invocation_button) &&
        (FIfld_find_row_and_column(form, FileNameField, xpos, ypos,
                                   &row, &col) == FI_SUCCESS))
    {
        int state, i, depth, rpos, readable, writable, same, flags, found;
        char *c, buf[128], new_name[MAXPATHLEN], old_name[MAXPATHLEN];
        char path[MAXPATHLEN];
        GRrevasm_data *cd;
        GRreffilelist *l;

        /* get pointer to data stored in form */
        FIf_get_user_pointer(form, (char **)&cd);

        /* don't accept input below the valid list of data */
        if (row >= cd->total_file_count)
            return;

        /* don't accept input to rows under noop or replace */
        if ((cd->list[row]->parent) &&
            (cd->list[row]->parent->flags & (NoOperation | 
                                             ReplaceOperation | 
                                             NoChangeOperation)))
        {
            UMSGetByNum(buf, GR_E_CantEditSubAsm, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            GRrevasm_set_row_state(form, row, FALSE);
            return;
        }

        if (col != OperationColumn)
        {
            /* let FORMS handle the input from here */
            FIf_process_point(form, xpos, ypos, button, trans, t_tag);
            return;
        }

        /* make sure there is a target name */
        FIfld_get_text(form, FileNameField, row, NewNameColumn, MAXPATHLEN,
                       new_name, &state, &rpos);
        for (c = new_name; isspace(*c); c++);
        if (*c == NULL)
        {
            /* there is not one, so generate it from the old one */
            FIfld_get_text(form, FileNameField, row, CurrentNameColumn,
                           MAXPATHLEN, old_name, &state, &rpos);
            FIfld_get_text(form, PathField, 0, 0,
                           MAXPATHLEN, path, &state, &rpos);
            GRrevasm_new_target_name(old_name, path, cd->suffix, form, row, 
                                    cd->total_file_count, new_name);
            FIfld_set_text(form, FileNameField, row, NewNameColumn, 
                           new_name, FALSE);
            for (c = new_name; isspace(*c); c++);
        }

        /* check for target filename existence - everything hinges on this */
        if (*c)
        {
            struct stat old, new;

            readable = (access(c, F_OK) == 0);
            writable = (access(c, W_OK) == 0);

            /* check whether current and target are the same file */
            stat(c, &new);
            stat(cd->list[row]->instance.name, &old);
            same = (new.st_ino == old.st_ino);
        }
        else
        {
            /* this had better never be hit! */
            UMSGetByNum(buf, GR_E_CantEditSubAsm, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
            GRrevasm_set_row_state(form, row, FALSE);
            return;
        }

        /* decide where to transition -- see planning notes for a flowchart */
        if (readable && same)
        {
            if (cd->list[row]->flags & NoChangeOperation)
            {
                /* toggling this allows user to select children */
                cd->list[row]->flags = EditOperation;
                UMSGetByNum(buf, GR_I_edit, 0);
                state = TRUE;
            }
            else
            {
                /* if there are children to be changed, then this is an edit */
                /* (unless there is a dirty diaper involved, in which case I */
                /* am not to be found) */
                found = FALSE;
                if (l = cd->list[row]->child)
                {
                    do
                    {
                        if (l->flags & (CopyOperation | ReplaceOperation |
                                        OverWriteOperation | EditOperation))
                        {
                            found = TRUE;
                            cd->list[row]->flags = EditOperation;
                            UMSGetByNum(buf, GR_I_edit, 0);
                            state = TRUE;
                        }
                    }
                    while (!found && (l = l->sibling));
                }
                if (!found)
                {
                    /* this is a no change */
                    cd->list[row]->flags = NoChangeOperation;
                    UMSGetByNum(buf, GR_I_NoChange, 0);
                    state = FALSE;
                }
            }
 
            FIfld_set_text(form, FileNameField, row, OperationColumn,
                           buf, FALSE);
            GRrevasm_set_row_state(form, row, state);
        }
        else if (!readable)
        {
            /* toggle to copy mode */
            UMSGetByNum(buf, GR_I_copy, 0);
            cd->list[row]->flags = CopyOperation;
            FIfld_set_text(form, FileNameField, row, OperationColumn,
                           buf, FALSE);
            GRrevasm_set_row_state(form, row, TRUE);
        }
        else if (readable && writable && !same)
        {
            flags = cd->list[row]->flags;
            if (flags & (CopyOperation | ReplaceOperation))
            {
                /* toggle to overwrite mode */
                UMSGetByNum(buf, GR_I_overwrite, 0);
                cd->list[row]->flags = OverWriteOperation;
                FIfld_set_text(form, FileNameField, row, OperationColumn,
                               buf, FALSE);
                GRrevasm_set_row_state(form, row, TRUE);

                if (flags & ReplaceOperation)
                {
                    /* regenerate new names */
                    FIfld_get_text(form, PathField, 0, 0, MAXPATHLEN,
                                   path, &state, &rpos);
                    depth = cd->list[i = row]->depth;
                    while (cd->list[i++]->next && (cd->list[i]->depth > depth))
                    {
                        /* get the current name from the form to maintain
                           indentation */
                        FIfld_get_text(form, FileNameField, i, 
                                       CurrentNameColumn, MAXPATHLEN,
                                       old_name, &state, &rpos);

                        GRrevasm_new_target_name(old_name, path, cd->suffix, 
                                                form, i, cd->total_file_count,
                                                new_name);

                        FIfld_set_text(form, FileNameField, i, NewNameColumn,
                                       new_name, FALSE);
                    }
                }
            }
            else if (flags & (NoChangeOperation | OverWriteOperation))
            {
                /* toggle to replace mode */
                UMSGetByNum(buf, GR_I_replace, 0);
                cd->list[row]->flags = ReplaceOperation;
                FIfld_set_text(form, FileNameField, row, OperationColumn,
                               buf, FALSE);
                GRrevasm_set_row_state(form, row, TRUE);

                if (flags & OverWriteOperation)
                {
                    /* toggle all nested files to noop */
                    depth = cd->list[i = row]->depth;
                    while (cd->list[i++]->next && (cd->list[i]->depth > depth))
                    {
                        cd->list[i]->flags = NoOperation;
                        FIfld_set_text(form, FileNameField, i, OperationColumn,
                                       "", FALSE);
                        FIfld_set_text(form, FileNameField, i, NewNameColumn,
                                       "", FALSE);
                        GRrevasm_set_row_state(form, i, FALSE);
                    }
                }
            }
        }

        /* keep the same selection state for this row */
        FImcf_get_select(form, FileNameField, row, &state);
        GRrevasm_set_row_state(form, row, state);
    }
    else
    {
        /* let FORMS handle the input */
        FIf_process_point(form, xpos, ypos, button, trans, t_tag);
    }
}
