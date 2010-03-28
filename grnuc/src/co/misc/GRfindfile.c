/*
Name
        GRfindfile.C

Description
        This file contains utility functions used for locating files on disk.
*/

#include <stdio.h>
#include <string.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/stat.h>

#define TRUE    1
#define FALSE   0

extern char *EX_search_path;

/*
Name
        GRfind_file

Description
        This function looks for a file on disk based on the input name and
        search path supplied by the caller.  The file to found may contain a
        partial pathname.

Algorithm
        Each component of searchpath is prepended to file_to_find until a
        matching file is found.

Synopsis
        int GRfind_file(char *file_to_find,
                        char *searchpath,
                        char *actual_filename)

        file_to_find    INPUT   The file to be found
        searchpath      INPUT   The search path to use in locating the file.
                                Identical format to the shell PATH variable
                                (e.g. "/usr/dir1:/usr/dir2").
        actual_filename OUPUT   If successful, contains a valid file name.

Return Values
        TRUE    File found, actual_filename contains the path to the file.
        FALSE   File not found

History
        mrm     06/09/93    creation
*/

int GRfind_file(char *file_to_find, char *searchpath, char *actual_filename)
{
    char *s, *e, *t, buf[MAXPATHLEN];
    struct stat statbuf;

    *actual_filename = NULL;

    /* idiot checks */
    if ((file_to_find == NULL) || (searchpath == NULL))
        return(FALSE);

    /* check in each directory specified */
    s = searchpath;
    e = NULL;
    while (s && *s)
    {
        if (e = strchr(s, (int)':')) *e = NULL;
        strcpy(buf, s);
        if (e) *e = ':';
        if (buf[strlen(buf) - 1] != '/') strcat(buf, "/");
        strcat(buf, file_to_find);
        if (stat(buf, &statbuf) == 0)
        {
            strcpy(actual_filename, buf);
            return(TRUE);
        }
        s = (e) ? e + 1 : NULL;
    }
    return(FALSE);
}

/*
Name
        GRfind_file_in_products

Description
        This function looks for a specified file in each active product.

Synopsis
        int GRfind_file(char *file_to_find,
                        char *actual_filename)

        file_to_find    INPUT   The file to be found
        actual_filename OUPUT   Valid file name.

Return Values
        TRUE    File found, actual_filename contains the path to the file.
        FALSE   File not found

Example
        char buf[MAXPATHLEN]
        ...
        GRfind_file_in_products("userdata/plot_defaults", buf);
        ...

History
        mrm     06/09/93    creation
*/

int GRfind_file_in_products(char *file_to_find,
                            char *actual_filename)
{
    return(GRfind_file(file_to_find, EX_search_path, actual_filename));
}
