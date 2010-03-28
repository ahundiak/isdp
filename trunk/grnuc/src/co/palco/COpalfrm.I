/*
File:

    COpalfrm.I

Methods:

    set_gadgets
    form_notification

Functions:

    COpal_verify_file (static)

History:

    jay wallingford     4/10/89     Creation date.
    mrm                 12/17/91    Check only PALPATH directories for
                                    filed palettes
    scw                 06/23/92    Added static ANSI C prototypes
*/
class implementation COpal;

#include <FI.h>
#include <alloca.h>
#include <sys/types.h>
#ifdef CLIX
#include <sys/dir.h>
#include <dirent.h>
#endif
#ifdef IRIX5
#include <dirent.h>
#define DIRSIZ MAXNAMLEN
#endif
#ifdef SUNOS5
#include <dirent.h>
#define DIRSIZ MAXNAMLEN
#endif
#include "grmessage.h"


extern int GRpal_get_paths();

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int COpal_verify_file __((char *path));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



%safe
static int COpal_verify_file (path)
    char * path;
{
    FILE    *fp;
    int     properties,
            rows, cols,
            color,
            xpos, ypos,
            xsize, ysize,
            btn_x, btn_y,
            btn_on_color, btn_off_color;
    char    version[50];
    int     nread = 0, ok = FALSE;

    if (fp = (FILE *) fopen(path, "r"))
    {
        /* read in the file header */

        nread = fscanf(fp,
                       "%49[^,],%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                       version,
                       &properties,
                       &rows,&cols,
                       &color,
                       &xpos,&ypos,
                       &xsize,&ysize,
                       &btn_x,&btn_y,
                       &btn_on_color, &btn_off_color);

        if (nread == 13)
        {
            /* check for unreasonable data */

            if ((rows > 15) || (cols > 15) || (rows < 1)    || (cols < 1)    ||
                (xpos < 0)  || (ypos < 0)  || (xpos > 1183) || (ypos > 883)  ||
                (btn_x < 0) || (btn_y < 0) || (btn_x > 500) || (btn_y > 500) ||
                (color < 0) || (color > 14) ||
                (xsize > (1183 * 2)) || (ysize > (883 * 2)) || /* 2x for 27" */
                (btn_on_color < 0)   || (btn_on_color > 14) ||
                (btn_off_color < 0)  || (btn_off_color > 14))
                ok = FALSE;
            else
                ok = TRUE;
        }
        fclose (fp);
    }
    return (ok);
}
%endsafe

method set_gadgets ()
{
    char ** paths, *p, *q, buf[128];
    DIR  *dp;
    struct  dirent *entry;
#ifdef SUNOS
    char    name[256], path[256];
#else
    char    name[DIRSIZ + 1], path[256];
#endif
    int     i, row, num;

    ex$message(msgnumb = GR_I_SrchPl);

    /*
        Generate a list of directories to search for palette files.
        This code used to call GRpal_get_paths, which returned a list of
        directories that included the current working directory, all
        directories specified in the environment variable PALPATH, and
        all the product paths.  This has been changed to exclude the
        product directories, since they contain dozens of palette files
        used by the popup menus.  The average user is probably not
        interested in those files.
    */

#define MAX_PATHS       16

    i = 0;
    if (p = (char *)getenv("PALPATH"))  /* check the environment */
    {
        if (p[i = strlen(p)] == ':')
            p[i--] = NULL;              /* strip trailing ":" */
    }
    q = (char*)alloca(i + 4);           /* add room for .: */
    strcpy(q, ".");
    if (p)
    {
        strcat(q, ":");
        strcat(q, p);                   /* tack on the PALPATH dirs */
    }
    num = 0;
    p = q;
    paths = (char **)alloca(sizeof(char *) * MAX_PATHS);
    while (num < MAX_PATHS)
    {
        paths[num++] = p;
        if (p = strchr(p, ':'))         /* check for another dir spec */
            *p++ = NULL;
        else
            break;                      /* not one, so get out */
    }

    /*
     * For each search path.
     */
    row = 0;
    for (i=0; i<num; ++i)
    {
        /*
         * Open the search path directory.
         */

        if (!(dp= (DIR *)opendir(paths[i]))) continue;

        /*
         * Read the "." and ".." and the first entry directory entries
         */

	if (entry = (struct dirent *)readdir(dp))
	{
	    if (entry = (struct dirent *)readdir(dp))
	    {
		entry = (struct dirent *)readdir(dp);
	    }
	}

	while (entry)
	{
            /*
             * While there are directory entries.
             */

            /*
             * Copy the DIRSIZ char d_name into DIRSIZ + 1 char name
             * up to DIRSIZ chars.
             * NOTE: This is required size a d_name entry is only 14
             *       chars. If a directory name is 14 chars there will
             *       be NO NULL at the end.
             */

#if defined SUNOS && defined XYXYX
	    strncpy(name, entry->d_name, DIRSIZ(entry));
            name[DIRSIZ(entry)] = '\0';
#else
	    strncpy(name, entry->d_name, DIRSIZ);
            name[DIRSIZ] = '\0';
#endif
             /*
              * Construct the full pathname.
              */

            strcpy(path, paths[i]);
            strcat(path, "/");
            strcat(path, name);

            /*
             * If the file is not the icons directory
             */

            if (COpal_verify_file(path))
	    {
		/*
                 * Put the filename in the form.
                 */
                 FIfld_set_text (me->status_display_form_ptr, PALETTE_FIELD,
                                 row++, 0, path, 0);
	    }

    	    entry = (struct dirent *)readdir(dp);
	}					/* end while loop 	*/

        closedir(dp);
    }

    ex$message(msgnumb = GR_I_Clear);
    i = (row) ? GR_P_SelFile : GR_I_NoPalFnd;
    ex$message(msgnumb = i, buff = buf);
    FIfld_set_text (me->status_display_form_ptr, 10, 0, 0, buf, 0);

    return (OM_S_SUCCESS);
}

method form_notification(int form_label;
                         int gadget_label;
                         double value;
                         char * form_ptr )
{
    IGRint      status, msg, row, sel, r_pos;
    IGRint      response;
    IGRlong     buffersize;
    IGRchar     text[256];

    switch (gadget_label)
    {
      case PALETTE_FIELD:

        row = value;

        /*
         * Push selected name on the queue.
         */
        FIfld_get_text(form_ptr, PALETTE_FIELD, row, 0, 255,
                       text, &sel, &r_pos);

        if (sel)
        {
            /*
             * Put text on queue.
             */
            response = EX_STRING;
            buffersize = strlen(text) + 1;

            ex$putque(msg = (IGRlong *)&msg,
                      response = &response,
                      byte = &buffersize,
                      buffer = text);
        }
        break;

      case FI_ACCEPT:

        FIg_set_state_off(me->status_display_form_ptr, FI_ACCEPT);

        status = om$send(msg = message CEO.erase_form_by_label
                              (form_label, 0, &msg),
                         targetid = my_id);

        me->form_requested = FALSE;

        break;
    }

    return (OM_S_SUCCESS);
}
end implementation COpal;
