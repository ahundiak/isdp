/*
Name
        GRmenupath.c

Description
        This file contains functions used to retrieve information about the
        menu paths to commands.

Notes
        This file can be compiled for a standalone interactive test by
        defining the symbol TEST.

        $ acc -DTEST=1 -I$GRNUC/include -I$EXNUC/include GRmenupath.c

History
        mrm     08/23/93        creation
*/

#include <stdio.h>
#include <string.h>
#include <alloca.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include "comisc.h"
#ifndef TEST
#include "ex.h"
#endif

#define FALSE   0
#define TRUE    1

#ifdef TEST
static char *EX_search_path =
        "/usr2/ingr/emsppp/:"
        "/usr2/ingr/ems/emsui02/:"
        "/usr2/ingr/modeldp/:"
        "/usr2/ingr/grnucsrc/:"
        "/usr2/ingr/exnucdp/:"
        "/usr2/ingr/bspmathdp/:";
#else
extern char *EX_search_path;    /* "/usr/ingr/path1:.../usr/ingr/pathn:" */
#endif

#ifdef TEST
void GRget_active_task(char *task)
{
    strcpy(task, "IMTkMd");
}
#endif

/*
Name
        GRfind_menu_paths

Description
        This function retrieves menu path information about a command key from
        the data stored in each product.

Synopsis
        GRmenu_path_info *GRfind_menu_paths(char *cmdkey)

        GRmenu_path_info *GRfind_menu_paths()
        The function returns a pointer to a structure containing the path
        information.  It is the caller's responsibility to free this structure
        with free();

        char *cmdkey - input
        The command key for which to search.
*/

GRmenu_path_info *GRfind_menu_paths(char *cmdkey)
{
    char *e, *path, *c, data[BUFSIZ], buf[BUFSIZ];
    char active_task[32];
    int looking, n, ntasks = 0, ii, jj, kk;
    struct dirent *p_dirent;
    struct stat statbuf;
    GRmenu_button_info *button, *b1, *b2;
    GRmenu_path_info mpi, *p_mpi = NULL;
    DIR *dp;
    FILE *fp;

    memset((char *)&mpi, 0, sizeof(mpi));
    strcpy(mpi.cmdkey, cmdkey);

    /* read the menupaths files from each product */
    path = EX_search_path;
    while (e = strchr(path, (int)':'))
    {
        *e = NULL;
        sprintf(buf, "%s/config/english/cmdpaths", path);
        *e = ':';
        path = e + 1;
        if ((dp = opendir(buf)) == NULL)
            continue;
        while (p_dirent = readdir(dp))
        {
            sprintf(data, "%s/%s", buf, p_dirent->d_name);
            stat(data, &statbuf);
            if (!S_ISREG(statbuf.st_mode))
                continue;
            if ((fp = fopen(data, "r")) == NULL)
                continue;
            looking = TRUE;
            while (fgets(data, BUFSIZ, fp) && looking)
            {
                /* skip tabbed entries; they are icon paths */
                if (data[0] == '\t') continue;

                /* NULL-terminate the command key */
                for (c = data; !isspace(*c); c++);
                *c = NULL;
        
                /* strcmp the data & key - must be complete match */
                if (strcmp(cmdkey, data) == 0)
                {
                    /* read the menu paths - all begin with a tab */
                    while (fgets(data, BUFSIZ, fp) && (data[0] == '\t'))
                    {
                        strcpy(mpi.path[mpi.npaths].task, p_dirent->d_name);
                        c = data;
                        button = &mpi.path[mpi.npaths].button[0];
                        while (sscanf(c, "%s %d %d",
                                      button->symbol_file,
                                      &button->off_symbol, 
                                      &button->on_symbol) == 3)
                        {
                            mpi.path[mpi.npaths].nbuttons++;
                            if (mpi.path[mpi.npaths].nbuttons >=
                                MAX_BUTTON_DEPTH)
                                break;
                            button++;

                            /* move c ahead to the next icon spec */
                            while (isspace(*c))  c++; /* to symbol file */
                            while (!isspace(*c)) c++; /* past symbol file */
                            while (isspace(*c))  c++; /* to off index */
                            while (!isspace(*c)) c++; /* past off index */
                            while (isspace(*c))  c++; /* to on index */
                            while (!isspace(*c)) c++; /* past on index */
                            if (*c == '\n') break;
                        }

                        /* The data files delivered from Help duplicate the
                           last button in the path if it has a popup
                           associated with it, since the popup duplicates the
                           button.  Cull those here. */
                        if (n = mpi.path[ii = mpi.npaths].nbuttons - 1)
                        {
                            b1 = &mpi.path[ii].button[n - 1];
                            b2 = &mpi.path[ii].button[n];
                            if ((b2->off_symbol == b1->off_symbol) &&
                                (b2->on_symbol == -1) &&
                                (b1->on_symbol == 254) &&
                                (!strcmp(b2->symbol_file, b1->symbol_file)))
                            {
                                b1->on_symbol = -1;
                                mpi.path[ii].nbuttons--;
                            }
                        }

                        mpi.npaths++;

                        if (mpi.npaths > MAX_MENU_PATHS)
                            break;
                    }
                    looking = FALSE;
                    ntasks++;
                }
            }
            fclose(fp);
        }
        closedir(dp);
    }

    if (mpi.npaths)
    {
        if (p_mpi = (GRmenu_path_info *)malloc(sizeof(GRmenu_path_info)))
        {
            /* move the active task commands to the top */
            GRget_active_task(active_task);
            for (ii = 0; ii < mpi.npaths; ii++)
            {
                if (strcmp(active_task, mpi.path[ii].task) == 0)
                {
                    GRbutton_path tmp = mpi.path[ii];
                    for (jj = ii; jj > 0; jj--)
                        mpi.path[jj] = mpi.path[jj - 1];
                    mpi.path[0] = tmp;
                }
            }

            /* mark paths which reside in different tasks but are otherwise */
            /* identical, as well as the paths which have duplicates */
            for (ii = 0; ii < mpi.npaths; ii++)
            {
                for (jj = 0;
                     jj < ii && mpi.path[ii].is_duplicate == FALSE;
                     jj++)
                {
                    if (mpi.path[ii].nbuttons == mpi.path[jj].nbuttons)
                    {
                        for (kk = 0; kk < mpi.path[ii].nbuttons; kk++)
                        {
                            if ((mpi.path[jj].button[kk].off_symbol !=
                                 mpi.path[ii].button[kk].off_symbol) ||
                                (mpi.path[jj].button[kk].on_symbol !=
                                 mpi.path[ii].button[kk].on_symbol) ||
                                (strcmp(mpi.path[jj].button[kk].symbol_file,
                                        mpi.path[ii].button[kk].symbol_file)))
                                break;
                        }
                        if (kk == mpi.path[ii].nbuttons)
                        {
                            mpi.path[ii].is_duplicate = TRUE;
                            mpi.path[jj].has_duplicate = TRUE;
                        }
                    }
                }
            }

            *p_mpi = mpi;
        }
    }

    return(p_mpi);
}

#ifdef TEST

void print_path(GRmenu_path_info *p)
{
    int ii, jj;

    printf("cmdkey = %s, npaths = %d\n", p->cmdkey, p->npaths);
    for (ii = 0; ii < p->npaths; ii++)
    {
        printf("\t\t\tpath[%d].nbuttons = %d\n", ii, p->path[ii].nbuttons);
        printf("\t\t\tpath[%d].is_duplicate = %d\n",
               ii, p->path[ii].is_duplicate);
        printf("\t\t\tpath[%d].has_duplicate = %d\n",
               ii, p->path[ii].has_duplicate);
        printf("\t\t\tpath[%d].task = %s\n", ii, p->path[ii].task);
        for (jj = 0; jj < p->path[ii].nbuttons; jj++)
        {
            printf("\t\t\tpath[%d]->button[%d] = %s %d %d\n", ii, jj,
                   p->path[ii].button[jj].symbol_file,
                   p->path[ii].button[jj].off_symbol,
                   p->path[ii].button[jj].on_symbol);
        }
    }
}

main()
{
    char buf[BUFSIZ];
    GRmenu_path_info *p;

    while (gets(buf))
    {
        p = GRfind_menu_paths(buf);
        if (p)
            print_path(p);
        else
            printf("Failed to find %s\n", buf);

    }
}

#endif
