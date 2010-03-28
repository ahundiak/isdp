/*
Name
        GRlist_ref_files

Synopsis
        int GRlist_ref_files(msg, flags, design_file, 
                             n_attachments, attachments)

        int()                   TRUE - Success, attachment names returned
                                FALSE - Failure, no attachment names returned

        int *msg                out - return code
                                    GR_S_Success - Success, attachment names
                                        returned
                                    GR_E_NoRead - Failure, could not read file
                                    GR_E_CannotExecuteFile - Failure, could not
                                        execute dros
                                    GR_E_IlgFileTyp - Failure, file not a 
                                        design file
                                    GR_E_NoRefFl - Failure, no reference file
                                        attachments found
                                    GR_E_NotInProdData - Could not find EXNUC
                                        the product_data file
        int flags               in  - flags defined in refdef.h
                                    GRMultipleAttachments - return duplicate
                                        names if a file is attached more than
                                        once
        char *design_file       in  - name of file to check
        int *n_attachments      out - number of filenames returned
        GRreffilelist **attachments
                                out - info about attachments found
        char *intosname         out - internal object space name of the file 
                                    being checked

Description
        This function will return a list of the reference files which are
        attached to the design file specified.

        The returned list will be allocated within this function.  It is the
        caller's responsibility to free the memory with GRfree_ref_list().
        The caller might access each name as shown in the sample call below.

Example
        int sts, msg, n;
        char intosname[OM_K_MAXINTOSNAME_LEN];
        GRreffilelist *list, *p;

        sts = GRlist_ref_files(&msg, NULL, "/usr/tmp/foo",
                               &n, &list, intosname);
        for (i = 0, p = list; i < n; i++, p = p->next)
            printf("list[%d] = %s\n", i, p->instance.name);
        GRfree_ref_list(list);

Algorithm
        A pipe is opened to dros, which is used to first find the classid for
        GRreffile, then to find file offsets to each occurrence of the object.
        Then the objects are located in the file and mapped to the total
        instance structure output from opp'ing GRreffile.S.  The reference
        file info is pulled from that instance data.

Notes
        This code is very sensitive to output format changes in dros, as well
        as to instance data changes GRreffile or any ancestors.

History
        mrm     07/02/92    creation
        gang    03/04/93    Modified to support cyclic attachments.
*/

#include <stdlib.h>
#include <stdio.h>
#ifndef NT
#include <unistd.h>
#else
#define R_OK    4       /* Test for Read permission */
#define W_OK    2       /* Test for Write permission */
#define X_OK    1       /* Test for eXecute permission */
#define F_OK    0       /* Test for existence of File */
#include <stdlib.h>
#define MAXPATHLEN _MAX_PATH
#endif
#include <alloca.h>
#ifndef NT
#include <sys/param.h>
#endif
#include <sys/types.h>
#include <sys/stat.h>
#include "OMlimits.h"
#include "grmsg.h"
#include "refdef.h"
#include "refco.h"
#include "listref.h"

#define TRUE            1
#define FALSE           0
#define Null            ((char*)NULL)
#define HeaderSize      (2 * sizeof(int))

/*
  These structures are used internally to build the list of reference file
  attachments.
*/

typedef struct _offset_t
{
    int objid;
    int offset;
    struct _offset_t *next;
}   new_offset_t;

/*
  Some of the dependencies on dros output are isolated here to minimize the
  impact of reacting to changes in the format.
*/

char *dros_prompt = "[Dr.OS] ";
char *intosname_label = "Internal object space name: ";
char *classid_label = "Classid: ";
char *object_label = " Object";
char *found_label = "Found";
char *invalid_label = "File not valid";

int GRlist_ref_files(msg, in_flags, design_file,
                     n_attachments, attachments, intosname)
int *msg, in_flags;
char *design_file;
int *n_attachments;
GRreffilelist **attachments;
char *intosname;
{
#ifdef BIG_ENDIAN
    int i;
#endif
    int n, m, found, n_matches, ref_classid, n_unique;
    int object, cluster, classid, size, file_pointer;
    char *c, buf[128], *osname, flags = 0;
    char tmpfile[MAXPATHLEN], command[MAXPATHLEN], dros[MAXPATHLEN];
    FILE *fp;
    new_offset_t *offset_list = NULL, *po = NULL;
    GRreffilelist *data_list = NULL, *p_data_list = NULL;
    GRreffilelist *last_data_list = NULL;
    struct GRreffile_total_instance *ME;
    struct OM_sd_objecthdr objhdr;


    /* initialize data */
    *msg = GR_E_ErrEnc;
    *n_attachments = 0;

    /* check the file access */
    if (access(design_file, R_OK) != 0)
    {
        *msg = GR_E_NoRead;
        return(FALSE);
    }

    /* find the path to EXNUC */
    GRget_product_data("Exnuc", Null, Null, Null, Null, dros);
    if (dros[0] == NULL)
    {
        *msg = GR_E_NotInProdData;
        return(FALSE);
    }

    /* construct the path to dros and make sure it is executable */
    strcat(dros, "/bin/dros");
    if (access(dros, X_OK) != 0)
    {
        *msg = GR_E_CannotExecuteFile;
        return(FALSE);
    }

    /* create a temporary file for dros commands */
    if ((c = getenv("TMPDIR")) == NULL) c = "/usr/tmp";
    sprintf(tmpfile, "%s/%s", c, "listrefXXXXXX");
    mktemp(tmpfile);
    if ((fp = (FILE *)fopen(tmpfile, "w")) == NULL)
        return(FALSE);

    /* write the necessary dros commands into the temporary file */
    fprintf(fp, "N\n");                 /* internal object space name */
    fprintf(fp, "c\n");                 /* Display class info */
    fprintf(fp, "n\n");                 /* info by name */
    fprintf(fp, "GRreffile -l\n");      /* verbose info for ref file class */
    fprintf(fp, "-q\n");                /* quit name mode */
    fprintf(fp, "q\n");                 /* quit class info */
    fprintf(fp, "o\n");                 /* Show object info */
    fprintf(fp, "A\n");                 /* All objects */
    fprintf(fp, "q\n");                 /* quit dros */

    /* close the temporary file */
    fclose(fp);

    /* format a command line to invoke dros on the design file */
    sprintf(command, "%s -q -f %s <%s", dros, design_file, tmpfile);

    /* open a pipe to invoke dros and grab the output */
    if ((fp = (FILE *)popen(command, "r")) == NULL)
    {
        unlink(tmpfile);
        return(FALSE);
    }

    if (intosname)
    {
        /* scan for the internal osname */
        found = FALSE;
        n = strlen(intosname_label);
        m = strlen(invalid_label);
        while(!found)
        {
            if (fgets(buf, sizeof(buf), fp) == NULL)
            {
                pclose(fp);
                unlink(tmpfile);
                return(FALSE);
            }

            if (strncmp(buf, intosname_label, n) == NULL)
            {
                if ((sscanf(&buf[n], "%s", intosname) == 1))
                    found = TRUE;
                else
                {
                    *msg = GR_E_NoRefFl;
                    pclose(fp);
                    unlink(tmpfile);
                    return(FALSE);
                }
            }
            else if (strncmp(buf, invalid_label, m) == NULL)
            {
                *msg = GR_E_IlgFileTyp;
                pclose(fp);
                unlink(tmpfile);
                return(FALSE);
            }
        }
    }

    /* scan for the search results or invalid file message */
    found = FALSE;
    n = strlen(found_label);
    m = strlen(invalid_label);
    while (!found)
    {
        if (fgets(buf, sizeof(buf), fp) == NULL)
        {
            pclose(fp);
            unlink(tmpfile);
            return(FALSE);
        }

        if (strncmp(buf, found_label, n) == NULL)
        {
            if ((sscanf(&buf[n], "%d", &n_matches) == 1) &&
                (n_matches > 0))
                found = TRUE;
            else
            {
                *msg = GR_E_NoRefFl;
                pclose(fp);
                unlink(tmpfile);
                return(FALSE);
            }
        }
        else if (strncmp(buf, invalid_label, m) == NULL)
        {
            *msg = GR_E_IlgFileTyp;
            pclose(fp);
            unlink(tmpfile);
            return(FALSE);
        }
    }

    /* scan for the class id */
    found = FALSE;
    n = strlen(classid_label);
    while (!found)
    {
        if (fgets(buf, sizeof(buf), fp) == NULL)
        {
            pclose(fp);
            unlink(tmpfile);
            return(FALSE);
        }

        if (strncmp(buf, classid_label, n) == NULL)
        {
            if (sscanf(&buf[n], "%d", &ref_classid) == 1)
                found = TRUE;
            else
            {
                pclose(fp);
                unlink(tmpfile);
                return(FALSE);
            }
        }
    }

    /* scan for the beginning of the object list */
    found = FALSE;
    n = strlen(object_label);
    while (!found)
    {
        if (fgets(buf, sizeof(buf), fp) == NULL)
        {
            pclose(fp);
            unlink(tmpfile);
            return(FALSE);
        }

        if (strncmp(buf, object_label, n) == NULL)
            found = TRUE;
    }

    /* read objects until the dros prompt appears again */
    n = strlen(dros_prompt);
    found = FALSE;
    while (!found)
    {
        if (fgets(buf, sizeof(buf), fp) == NULL)
        {
            pclose(fp);
            unlink(tmpfile);
            return(FALSE);
        }

        if (strncmp(buf, dros_prompt, n) == NULL)
            found = TRUE;
        else
        {
            /* check whether this line identifies a reference file object */
            if ((sscanf(buf, "%d%d%d%d%d", &object, &cluster, &classid,
                        &size, &file_pointer) == 5) &&
                (classid == ref_classid))
            {
                /* store the info for later use */
                if (po)
                {
                    po->next = (new_offset_t *)alloca(sizeof(new_offset_t));
                    po = po->next;
                }
                else
                {
                    offset_list = (new_offset_t *)alloca(sizeof(new_offset_t));
                    po = offset_list;
                }
                po->objid = object;
                po->offset = file_pointer;
                po->next = NULL;
            }
        }
    }

    /* close the pipe, and delete the tmp file */
    pclose(fp);
    unlink(tmpfile);

    /* make sure reference file objects were found before proceeding */
    if (po == NULL)
    {
        *msg = GR_E_NoRefFl;
        return(FALSE);
    }

    /* open the design file */
    if ((fp = (FILE *)fopen(design_file, "r")) == NULL)
    {
        *msg = GR_E_NoRead;
        return(FALSE);
    }

    /* cycle through the list of reference file attachments */
    size = sizeof(GRreffiledata) * 2;
    ME = (struct GRreffile_total_instance *)alloca(size);
    n_unique = 0;
    po = offset_list;
    while (po)
    {
        /* seek to the reference file object */
        n = po->offset + HeaderSize;
        fseek(fp, n, 0);

        /* read the object header */
        fread(&objhdr, sizeof(struct OM_sd_objecthdr), 1, fp);
#ifdef BIG_ENDIAN        
        GRconv_int(&objhdr.oid, &objhdr.oid);
        GRconv_int(&objhdr.i_size, &objhdr.i_size);
#endif

        /* make sure the buffer is big enough to hold the object */
        if (objhdr.i_size > size)
        {
            size = objhdr.i_size;
            ME = (struct GRreffile_total_instance *)alloca(size);
        }

        /* read the entire object */
        fseek(fp, n, 0);
        fread(ME, sizeof(char), objhdr.i_size, fp);

#ifdef BIG_ENDIAN
        /* convert the filename and osname from little endian */
        GRconv_int(&ME->GRreffile.filename_descr.i_offset,
                   &ME->GRreffile.filename_descr.i_offset);
        GRconv_int(&ME->GRreffile.filename_descr.i_count,
                   &ME->GRreffile.filename_descr.i_count);
        GRconv_int(&ME->GRreffile.osname_descr.i_offset,
                   &ME->GRreffile.osname_descr.i_offset);
        GRconv_int(&ME->GRreffile.osname_descr.i_count,
                   &ME->GRreffile.osname_descr.i_count);
#endif

        /* grab the osname and make sure the file exists */
        c = (char *)&ME->GRreffile.osname_descr.i_offset;
        c += ME->GRreffile.osname_descr.i_offset;
        if (access(c, F_OK) == 0)
            flags |= OSNamePresent;
        else
        {
            /* save the osname */
            osname = c;

            /* couldn't find the file, try looking without the path */
            c = (char *)&ME->GRreffile.filename_descr.i_offset;
            c += ME->GRreffile.filename_descr.i_offset;
            if (access(c, F_OK) == 0)
                flags |= FileNamePresent;
            else
                /* can't find the file, but proceed anyway */
                c = osname;
        }

        /* check whether the caller wants more than one listing for files
           which are attached more than once */
        found = FALSE;
        p_data_list = data_list;
        if (in_flags & GRMultipleAttachments)
        {
            /* allow multiple occurences of the name in the output list */
            while (p_data_list)
            {
                /* look for the end of the list */
                last_data_list = p_data_list;
                p_data_list = p_data_list->next;
            }
        }
        else
        {
            /* check whether this name has already been encountered */
            while (p_data_list)
            {
                if (strcmp(p_data_list->instance.osname, c) == NULL)
                {
                    found = TRUE;
                }
                last_data_list = p_data_list;
                p_data_list = p_data_list->next;
            }
        }

        if (!found)
        {
            /* update the unique attachment counter */
            n_unique++;

#ifdef BIG_ENDIAN
            /* convert the rest of the data to little endian */
            GRconv_short(&ME->GRgraphics.properties, 
                         &ME->GRgraphics.properties);
            GRconv_short(&ME->GRgraphics.level, &ME->GRgraphics.level);
            GRconv_short(&ME->GRvg.display_attr.color,
                         &ME->GRvg.display_attr.color);
            GRconv_int(&ME->GRreffile.saved_view_descr.i_offset,
                       &ME->GRreffile.saved_view_descr.i_offset);
            GRconv_int(&ME->GRreffile.saved_view_descr.i_count,
                       &ME->GRreffile.saved_view_descr.i_count);
            GRconv_int(&ME->GRreffile.ref_properties,
                       &ME->GRreffile.ref_properties);
            GRconv_int(&ME->GRreffile.description_descr.i_offset,
                       &ME->GRreffile.description_descr.i_offset);
            GRconv_int(&ME->GRreffile.description_descr.i_count,
                       &ME->GRreffile.description_descr.i_count);
            GRconv_int(&ME->GRreffile.scale_factor_descr.i_offset,
                       &ME->GRreffile.scale_factor_descr.i_offset);
            GRconv_int(&ME->GRreffile.scale_factor_descr.i_count,
                       &ME->GRreffile.scale_factor_descr.i_count);
            GRconv_int(&ME->GRreffile.ref_properties,
                       &ME->GRreffile.ref_properties);
            for (i = 0; i < 6; i++)
            {
                GRconv_dbl(&ME->GRreffile.range[i], &ME->GRreffile.range[i]);
                GRconv_dbl(&ME->GRreffile.vw_volume[i],
                           &ME->GRreffile.vw_volume[i]);
            }
            for (i = 0; i < 16; i++)
            {
                GRconv_dbl(&ME->GRreffile.vw_rotation[i],
                           &ME->GRreffile.vw_rotation[i]);
                GRconv_dbl(&ME->GRreffile.master_to_ref_matrix[i],
                           &ME->GRreffile.master_to_ref_matrix[i]);
                GRconv_dbl(&ME->GRreffile.ref_to_master_matrix[i],
                           &ME->GRreffile.ref_to_master_matrix[i]);
            }
            for (i = 0; i < 3; i++)
            {
                GRconv_dbl(&ME->GRreffile.vw_origin[i],
                           &ME->GRreffile.vw_origin[i]);
            }
            for (i = 0; i < 32; i++)
            {
                GRconv_int(&ME->GRreffile.dp_levels[i],
                           &ME->GRreffile.dp_levels[i]);
            }
#endif

            /* find the end of the list */
            if (data_list)
            {
                p_data_list = last_data_list;
                p_data_list->next = 
                    (GRreffilelist *)calloc(1, sizeof(GRreffilelist));
                p_data_list->sibling = p_data_list->next;
                p_data_list = p_data_list->next;
            }
            else
            {
                data_list = (GRreffilelist *)calloc(1, sizeof(GRreffilelist));
                p_data_list = data_list;
            }

            /* store the data in the list */
            p_data_list->instance.flags = flags;
            p_data_list->instance.properties = ME->GRgraphics.properties;
            p_data_list->instance.level = ME->GRgraphics.level;
            p_data_list->instance.display_attr = ME->GRvg.display_attr;
            c = (char *)&ME->GRreffile.filename_descr.i_offset;
            c += ME->GRreffile.filename_descr.i_offset;
            strcpy(p_data_list->instance.filename, c);
            c = (char *)&ME->GRreffile.osname_descr.i_offset;
            c += ME->GRreffile.osname_descr.i_offset;
            strcpy(p_data_list->instance.osname, c);
            p_data_list->instance.name = (flags & OSNamePresent) ? 
                p_data_list->instance.osname : p_data_list->instance.filename;
            c = (char *)&ME->GRreffile.saved_view_descr.i_offset;
            c += ME->GRreffile.saved_view_descr.i_offset;
            strcpy(p_data_list->instance.saved_view, c);
            c = (char *)&ME->GRreffile.description_descr.i_offset;
            c += ME->GRreffile.description_descr.i_offset;
            strcpy(p_data_list->instance.description, c);
            c = (char *)&ME->GRreffile.scale_factor_descr.i_offset;
            c += ME->GRreffile.scale_factor_descr.i_offset;
            strcpy(p_data_list->instance.scale_factor, c);
            p_data_list->instance.ref_properties = 
                ME->GRreffile.ref_properties;
            memcpy(p_data_list->instance.dp_levels,
                   ME->GRreffile.dp_levels, sizeof(int) * 32);
            memcpy(p_data_list->instance.range,
                   ME->GRreffile.range, sizeof(double) * 6);
            memcpy(p_data_list->instance.vw_volume,
                   ME->GRreffile.vw_volume, sizeof(double) * 6);
            memcpy(p_data_list->instance.vw_rotation,
                   ME->GRreffile.vw_rotation, sizeof(double) * 16);
            memcpy(p_data_list->instance.vw_origin,
                   ME->GRreffile.vw_origin, sizeof(double) * 3);
            memcpy(p_data_list->instance.master_to_ref_matrix, 
                   ME->GRreffile.master_to_ref_matrix, sizeof(double) * 16);
            memcpy(p_data_list->instance.ref_to_master_matrix,
                   ME->GRreffile.ref_to_master_matrix, sizeof(double) * 16);
            p_data_list->next = NULL;
        }

        /* move to the next reference file */
        po = po->next;
    }

    *n_attachments = n_unique;
    *attachments = data_list;
    *msg = GR_S_Success;

    return(TRUE);
}

/*
Name
        GRfree_ref_list

Description
        This function frees all memory associated with the specified reference
        file list.  This includes following the "next" links to all nodes in
        the linked list.
*/

void GRfree_ref_list(list)
GRreffilelist *list;
{
    GRreffilelist *p, *q;

    p = list;
    while (p)
    {
        q = p->next;
        free(p);
        p = q;
    }
}

/*
Name
        GRbuild_nested_ref_list

Description
        This function builds a multiply linked list representing the reference
        file structure of the assembly.  Links are also maintained to
        represent the order in which files are encountered (as they will be
        presented on the Assembly forms).  The function recurses on itself
        (sounds a little dirty, eh?) to find nested attachments.
*/

int GRbuild_nested_ref_list(msg, list, flags, callback, callback_data)
int *msg;
GRreffilelist *list;
int flags;
void (*callback)();
void *callback_data;
{
    int sts, rsts, rmsg, i, n, cycle;
    GRreffilelist *att, *p, *q, *l, *top;
    struct stat list_stat, p_stat, q_stat;

    /** Fix for TR# 119526058 **/
    list->instance.name = list->instance.filename;
    /* call the feedback function */
    if (callback)
        (*callback)(list->instance.name, callback_data);

    /* find attachments to this file */
    sts = GRlist_ref_files(msg, flags, list->instance.name, 
                           &n, &att, list->instance.intosname);
    if (sts & *msg & 1)
    {
        /* 
            Eliminate cycles -- they aren't interesting and they create
            infinite loops.  However, self-attached files are allowed.
        */

        /* get the inode number of the current file for q&d id check */
        stat(list->instance.name, &list_stat);

        /* loop through each file attached to the current node */
        for (p = l = att, cycle = FALSE; p; cycle = FALSE)
        {
            /* get the inode number for the attachment */
            stat(p->instance.name, &p_stat);

            /* allow self-attached files */
            if (list_stat.st_ino == p_stat.st_ino)
            {
                /* be careful not to fall into a loop - which would happen */
                /* if list's parent is also this same file */
                if (list->parent)
                {
                    stat(list->parent->instance.name, &q_stat);
                    if (p_stat.st_ino == q_stat.st_ino)
                        cycle = TRUE;
                }
                else
                {
                    /* make a note that this is a self-attached file */
                    p->instance.flags |= SelfAttachedFile;
                    list->instance.flags |= HasSelfAttachedFile;
                }
            }
            else
            {
                /* check against each attachment already encountered */
                for (top = list; top && top->parent; top = top->parent)
                {
                    stat(top->instance.name, &q_stat);
                    if (p_stat.st_ino == q_stat.st_ino)
                    {
                        p->instance.flags |= HasCyclicAttachments;
                        cycle = TRUE;
                    }
                }

            }

            if (cycle)
            {
                /* delete this node */
                if (p == l)
                {
                    /* first entry in the current list (which may have already
                       been modified */ 
                    att = l = p->next;  /* reset start of list */
                    p->next = NULL;     /* terminate list */
                    GRfree_ref_list(p); /* delete node */
                    p = l;              /* increment to next unexamined node */
                }
                else
                {
                    l->next = p->next;  /* skip this node */
                    p->next = NULL;     /* terminate list */
                    GRfree_ref_list(p); /* delete node */
                    p = l->next;        /* increment to next node */
                }

                /* knock down the attachment counter */
                if (--n == 0)
                    return(FALSE);
            }
            else
            {
                /* increment to next node, keeping a pointer to this one */
                l = p;
                p = p->next;
            }
        }

        /* connect the "next" links */
        p = list->next;
        list->next = q = att;
        while (q) 
        {
            q->depth = list->depth + 1;
            l = q;
            q = q->next;
        }
        l->next = p;

        /* connect the "parent" links */
        q = att;
        while (q)
        {
            q->parent = list;
            q = q->sibling;
        }

        /* connect the "child" link */
        list->child = att;

        if (flags & GRNestedInfo)
        {   /* now recurse into each "child" to get nested attachments */
            for (i = 0, p = att; i < n; i++, p = p->sibling)
            {
                if(!(p->instance.flags & HasCyclicAttachments ))
                {
                    rsts = GRbuild_nested_ref_list(&rmsg, p, flags, 
                                                   callback, callback_data);
                    if (!(rsts & 1))
                    {
                        if (rmsg == GR_E_NoRead)
                            p->instance.flags |= CantReadFile;
                        else if (rmsg == GR_E_NotInProdData)
                            p->instance.flags |= CantFindEXNUC;
                        else if (rmsg == GR_E_CannotExecuteFile)
                            p->instance.flags |= CantExeFile;
                        else if (rmsg == GR_E_IlgFileTyp)
                            p->instance.flags |= NotDesignFile;
                        else if (rmsg == GR_E_NoRefFl)
                            p->instance.flags |= NoAttachmentsFound;
                    }
                }
            }
        }
    }
    else
    {
        if (*msg == GR_E_NoRead)
            list->instance.flags |= CantReadFile;
        else if (*msg == GR_E_NotInProdData)
            list->instance.flags |= CantFindEXNUC;
        else if (*msg == GR_E_CannotExecuteFile)
            list->instance.flags |= CantExeFile;
        else if (*msg == GR_E_IlgFileTyp)
            list->instance.flags |= NotDesignFile;
        else if (*msg == GR_E_NoRefFl)
            list->instance.flags |= NoAttachmentsFound;
    }
    return(sts & 1);
}

/*
Name
        GRbuild_ref_list

Description
        This function builds a linked list representing the reference file
        structure of the assembly.
*/

int GRbuild_ref_list(filename, flags, callback, callback_data, list)
char *filename;
int flags;
void (*callback)();
void *callback_data;
GRreffilelist **list;
{
    int sts, msg;

    /* build a dummy list node for the top file */
    *list = (GRreffilelist *)calloc(1, sizeof(GRreffilelist));
    strcpy((*list)->instance.filename, filename);
    (*list)->instance.name = (*list)->instance.filename;

    /* build a nested list of ref attachments using a recursive function */
    sts = GRbuild_nested_ref_list(&msg, *list, flags, callback, callback_data);
    return(sts);
}
