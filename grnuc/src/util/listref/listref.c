/*
Name
        listref

Description
        This is a utility to list the reference file attachments in a design
        file.  It can recursively descend into reference files to list nested
        attachments.

History
        mrm     07/02/92    creation
        mrm     07/28/93    Changed to display filename, rather than osname,
                            so as to keep this output similar to the Review
                            Reference File form in I/EMS.  TR119222519.
                            Changed so that the NoAttachment error filtered up
                            from leaf nodes is not passed out as the exit
                            status.  TR119309096.
                            Changed really_verbose to refrain from printing
                            useless junk about the top level file.
*/

#include <stdio.h>
#include <sys/param.h>
#include <alloca.h>
#include "grmsg.h"
#include "refdef.h"
#include "refco.h"

/*
        Miscellaneous definitions and exit codes.
*/

#define TRUE    1
#define FALSE   0

#define Success         0
#define NoAttachments   1
#define ReadError       2
#define ExecError       3
#define InvalidFile     4
#define InvalidArgs     5

/*
        External references.
*/

extern int optind;
extern char *optarg;

/*
        These static variables control output behavior.
*/

static int silent = FALSE;
static int verbose = FALSE;
static int dots = FALSE;
static int Dots = FALSE;
static int really_verbose = FALSE;
static int recursive = FALSE;
static int warn_if_no_attachments = FALSE;
static int exit_status = Success;

/*
Name
        usage

Description
        This function prints the command line syntax and a short explanation
        to stderr.  This function does not return; it terminates the process.
*/

void usage(progname)
char *progname;
{
    fprintf(stderr, "\nUsage: %s [-d] [-m] [-r] [-s] [-v] [-w] ", progname);
    fprintf(stderr, "filename [filename...]\n");
    fprintf(stderr, "\t-d\tdots: display dots as files are scanned ");
    fprintf(stderr, "to indicate that the\n\t\tprogram is working\n");
    fprintf(stderr, "\t-m\tmultiple: print each attachment found, ");
    fprintf(stderr, "regardless of repetition\n");
    fprintf(stderr, "\t-r\trecursive: search for nested attachments\n");
    fprintf(stderr, "\t-s\tsilent: nothing is printed; but the exit value ");
    fprintf(stderr, "is still valid\n");
    fprintf(stderr, "\t-v\tverbose: print the attachment description, ");
    fprintf(stderr, "saved view name,\n\t\tand scale factor\n");
    fprintf(stderr, "\t-w\twarning: print a warning if no attachments are ");
    fprintf(stderr, "found\n");
    fprintf(stderr, "\nExit Values:\n");
    fprintf(stderr, "\t%d\tattachments found\n", Success);
    fprintf(stderr, "\t%d\tno attachments found\n", NoAttachments);
    fprintf(stderr, "\t%d\terror reading file\n", ReadError);
    fprintf(stderr, "\t%d\terror executing dros\n", ExecError);
    fprintf(stderr, "\t%d\tnot a design file\n", InvalidFile);
    fprintf(stderr, "\t%d\tinvalid command line arguments\n", InvalidArgs);
    fprintf(stderr, "\n\tNote that an error will be returned if any file ");
    fprintf(stderr, "processed\n\tgenerates an error.\n\n");
    exit(1);
}

/*
Name
        print_ref_info

Description
        This function dumps out the information in the ref file structure.
*/

void print_ref_info(l)
GRreffilelist *l;
{
    if (!silent)
    {
        int j;
        char *leader;

        leader = (char *)alloca(sizeof(char) * l->depth + 1);
        memset(leader, (int)'\t', l->depth);
        leader[l->depth] = NULL;

        printf("%s%s", leader, l->instance.filename);

        if (l->instance.flags & CantReadFile)
        {
            exit_status = ReadError;
            printf("\tCannot read file\n");
        }
        else if (l->instance.flags & CantExeFile)
        {
            exit_status = ExecError;
            printf("\tCannot execute dros\n");
        }
        else if (l->instance.flags & NotDesignFile)
        {
            exit_status = InvalidFile;
            printf("\tNot a design file\n");
        }
        else if (l->instance.flags & NoAttachmentsFound)
        {
            exit_status = NoAttachments;
            if (warn_if_no_attachments)
                printf("\tNo attachments found");
            printf("\n");
        }
        else
            printf("\n");

        if (verbose && l->depth)
        {
            if (l->instance.description[0] || really_verbose)
                printf("%s  description = %s\n", 
                       leader, l->instance.description);
            if (l->instance.saved_view[0] || really_verbose)
                printf("%s  saved_view = %s\n", 
                       leader, l->instance.saved_view);
            if (l->instance.scale_factor[0] || really_verbose)
                printf("%s  scale_factor = %s\n", 
                       leader, l->instance.scale_factor);
            if (really_verbose)
            {
                printf("%s  filename = %s\n", 
                       leader, l->instance.filename);
                printf("%s  osname = %s\n", 
                       leader, l->instance.osname);
                printf("%s  ref_properties = %#x\n", 
                       leader, l->instance.ref_properties);
                printf("%s  range = %g, %g, %g\n", leader,
                       l->instance.range[0], 
                       l->instance.range[1], 
                       l->instance.range[2]);
                printf("%s          %g, %g, %g\n", leader,
                       l->instance.range[3],
                       l->instance.range[4], 
                       l->instance.range[5]);
                printf("%s  vw_volume = %g, %g, %g\n", leader,
                       l->instance.vw_volume[0],
                       l->instance.vw_volume[1], 
                       l->instance.vw_volume[2]);
                printf("%s              %g, %g, %g\n", leader,
                       l->instance.vw_volume[3], 
                       l->instance.vw_volume[4], 
                       l->instance.vw_volume[5]);
                printf("%s  vw_rotation = \n", leader);
                for (j = 0; j < 15; j += 4)
                    printf("%s    %g %g %g %g\n", leader,
                           l->instance.vw_rotation[j],
                           l->instance.vw_rotation[j + 1],
                           l->instance.vw_rotation[j + 2],
                           l->instance.vw_rotation[j + 3]);
                printf("%s  vw_origin = %g, %g, %g\n", leader,
                       l->instance.vw_origin[0], 
                       l->instance.vw_origin[1], 
                       l->instance.vw_origin[2]);
                printf("%s  master_to_ref_matrix = \n", leader);
                for (j = 0; j < 15; j += 4)
                    printf("%s    %g %g %g %g\n", leader,
                           l->instance.master_to_ref_matrix[j],
                           l->instance.master_to_ref_matrix[j + 1],
                           l->instance.master_to_ref_matrix[j + 2],
                           l->instance.master_to_ref_matrix[j + 3]);
                printf("%s  ref_to_master_matrix = \n", leader);
                for (j = 0; j < 15; j += 4)
                    printf("%s    %g %g %g %g\n", leader,
                           l->instance.ref_to_master_matrix[j],
                           l->instance.ref_to_master_matrix[j + 1],
                           l->instance.ref_to_master_matrix[j + 2],
                           l->instance.ref_to_master_matrix[j + 3]);
                printf("%s  dp_levels = \n", leader);
                for (j = 0; j < 32; j += 8)
                    printf("%s    %x %x %x %x\n%s    %x %x %x %x\n", leader,
                           l->instance.dp_levels[j],
                           l->instance.dp_levels[j + 1],
                           l->instance.dp_levels[j + 2],
                           l->instance.dp_levels[j + 3], leader,
                           l->instance.dp_levels[j + 4],
                           l->instance.dp_levels[j + 5],
                           l->instance.dp_levels[j + 6],
                           l->instance.dp_levels[j + 7]);
            }
        }
    }
}

/*
Name
        feedback

Description
        This function provides a little warm & fuzzy feedback to the user
        while files are being scanned.
*/
/* ARGSUSED */
void feedback(filename, dummy)
char *filename;
void *dummy;
{
    if (Dots)
        printf("%s\n", filename);
    else if (dots)
        printf(".");
    fflush(stdout);
}

/*
Name
        main

Description
        The main function handles command line arguments and cycles through
        each file specified looking for reference file attachments.
*/

main(argc, argv)
int argc;
char *argv[];
{
    char c;
    int i, sts;
    int list_flags = GRDefaultAttachInfo;
    GRreffilelist *list = NULL, *p = NULL;

    /* parse the command line arguments */
    while ((c = getopt(argc, argv, "AdDmrsvw")) != EOF)
    {
        switch (c)
        {
          case 'A': really_verbose = verbose = TRUE; silent = FALSE; break;
          case 'd': dots = TRUE; break;
          case 'D': Dots = TRUE; break;
          case 'm': list_flags |= GRMultipleAttachments; break;
          case 'r': list_flags |= GRNestedInfo; recursive = TRUE; break;
          case 's': silent = TRUE; break;
          case 'v': verbose = TRUE; silent = FALSE; break;
          case 'w': warn_if_no_attachments = TRUE; break;
          default:  usage(argv[0]); break;
        }
    }

    /* make sure at least one filename was specified */
    if (optind >= argc) usage(argv[0]);

    /* process each file listed on the command line */
    for (i = optind; i < argc; i++)
    {
        if (dots || Dots)
        {
            printf("Scanning files");
            if (Dots)
                printf("\n");
            fflush(stdout);
        }

        sts = GRbuild_ref_list(argv[i], list_flags, feedback, NULL, &list);

        p = list;

        if (Dots)
            printf("Scan complete\n");
        else if (dots)
            printf("\n");

        if (sts & 1)
        {
            while (p)
            {
                if (((p->depth < 2) || recursive) &&
                    (((p->instance.ref_properties & GRRF_BACKGROUND) !=
                     GRRF_BACKGROUND) || p->depth < 2 ))
                    /* print out info for this file */
                    print_ref_info(p);

                /* increment the pointer */
                p = p->next;
            }
        }
        else if (p)
        {
            if (p->instance.flags & CantReadFile)
            {
                exit_status = ReadError;
                printf("%s: %s: Cannot read file\n", argv[0], argv[i]);
            }
            else if (p->instance.flags & CantExeFile)
            {
                exit_status = ExecError;
                printf("%s: Cannot execute dros\n", argv[0]);
            }
            else if (p->instance.flags & NotDesignFile)
            {
                exit_status = InvalidFile;
                printf("%s: %s: Not a design file\n", argv[0], argv[i]);
            }
            else if (p->instance.flags & NoAttachmentsFound)
            {
                exit_status = NoAttachments;
                if (warn_if_no_attachments)
                    printf("%s: No attachments found", argv[i]);
            }
            else if (p->instance.flags & CantFindEXNUC)
            {
                exit_status = ExecError;
                printf("%s: Cannot find EXNUC in product_data\n", argv[0]);
            }
        }

        if ((exit_status == NoAttachments) && (list) && (list->next))
            /* The master file had at least one attachment, so ignore the
               NoAttachment error message; it filtered up from the leaf nodes
               of the tree. */
            exit_status = Success;
    }
    return(exit_status);
}
