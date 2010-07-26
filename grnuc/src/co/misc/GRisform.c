/*
Name
        GRis_form_file

Synopsis
        int GRis_form_file(filename, input_fp)
        int ()                  TRUE  - file is a form file
                                FALSE - file is not a form file
        char *filename          input - the name of the file to check
        FILE *input_fp          input - an open file pointer to the file to
                                        check

Description
        This function will determine whether a file is an I/FORMS or X/FORMS
        form file.  Either filename or input_fp may be used to specify the
        file to check, with filename taking precedence.  If filename is used,
        the file will be opened "r" and closed before the function exits.  If
        input_fp is used, the function will rewind(input_fp) before exiting.

Algorithm
        This first two characters of the file are ignored.  The next 6
        characters must be "FIform", which is not null-terminated.  Finally,
        the next short, which is a version number, must be greater than or
        equal to 3.  This is how the form builder checks for form files as of
        this writing.

History
        mrm     06/30/92    creation
*/

#include <stdio.h>

#define TRUE    1
#define FALSE   0

int GRis_form_file(filename, input_fp)
char *filename;
FILE *input_fp;
{
    char buf[16];
    short version;
    int sts;
    FILE *fp;

    if (filename)
    {
        if (!(fp = fopen(filename, "r")))
        {
            return(FALSE);
        }
    }
    else if (input_fp)
    {
        fp = input_fp;
        rewind(fp);
    }
    else
    {
        return(FALSE);
    }

    if ((fread(buf, sizeof(char), 8, fp) == 8) &&
        (strncmp(buf + 2, "FIform", 6) == 0) &&
        (fread(&version, sizeof(short), 1, fp) == 1) &&
        (version >= 3))
        sts = TRUE;
    else
        sts = FALSE;

    if (filename)
        fclose(fp);
    else
        rewind(input_fp);

    return(sts);
}
