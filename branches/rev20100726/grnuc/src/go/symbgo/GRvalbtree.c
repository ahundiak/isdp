/*
Name
        GRvalidate_cell_lib_btree

Description
        This function checks whether the OMbtree object in a cell library was
        written on a Sun workstation with a 2.0.*.* version of EMS.  During
        that time, a bug in the EXNUC big-little endian conversion routines
        incorrectly swapped a value in the OMbtree object.  That incorrect
        swapping, while consistent and well-bahaved on the Sun, corrupts the
        object so that bringing it up on a Clipper is risky business at best.
        Since EXNUC does not execute the conversion code on the Clipper
        platform, a check or repair would be highly problematic at their
        level.  EXNUC has fixed the bug for the 2.1.*.* release, but that can
        do nothing to repair existing files.  This function exists to check
        for possible corruption at the GRNUC level.  If corruption is
        detected, a second function will be called to repair the damage.

Algorithm
        The corruption is believed to be isolated to files written on a Sun
        with either a 2.0.0.* release, or a 2.1.0.* release prior to the fixed
        version of EXNUC (14).  The application version stamps are checked to
        determine whether the cell library was written in that window.  If so,
        then corruption is assumed.

        The EXNUC version stamp is used to check to file's write date.  This
        stamp is used because it is usually (always?) first and always
        present.  It also always is consistent; EMS sometimes sneaks in a
        "field test" blurb.  Another strike against EMS would be if MDS wrote
        the file last.

        The EXNUC version stamp is assumed to have the format shown below.

                I/EXNUC   02.01.00.12 09-Oct-92

Return Values
        TRUE - the btree is in good shape
        FALSE - the state of the btree is undetermined or bad

History
        mrm     10/20/92    creation
*/

#include <stdio.h>
#include <string.h>
#include <alloca.h>
#include "OMOSfilehdr.h"

#define FixedVersion 14

int GRvalidate_cell_lib_btree(filename, osnum, filenum)
char *filename;
OMuword osnum;
int filenum;
{
    int i;
    int tzlen, tolen;
    char *appver, *v;
    static char *exnuc = "I/EXNUC      "; /* leave the blanks!! */
    static char *two_zero = "02.00.";
    static char *two_one = "02.01.";
    OM_S_OS_FILEHDR hdr;
    FILE *fp;

    /* open the file */
    if ((fp = fopen(filename, "r")) == NULL)
        return(FALSE);

    /* read the OM file header */
    if (fread(&hdr, sizeof(OM_S_OS_FILEHDR), 1, fp) != 1)
    {
        fclose(fp);
        return(FALSE);
    }

    /* check whether the file was written on a Sun */
    if (strcmp(hdr.syst.mach_name.sysname, "CLIX/Sun"))
    {
        /* not written on a Sun, so bug cannot be present - go home happy */
        fclose(fp);
        return(TRUE);
    }

#ifdef BIG_ENDIAN
    /* swap the values of interest in the header */
    GRconv_int(&hdr.i_num_appver, &hdr.i_num_appver);
    GRconv_int(&hdr.fp_appver, &hdr.fp_appver);
#endif

    /* read the application version stamps */
    if (hdr.i_num_appver == 0)
    {
        /* no version stamps - punt */
        fclose(fp);
        return(FALSE);
    }
    appver = (char *)alloca(hdr.i_num_appver * OM_K_APPVER_LEN);
    fseek(fp, (long)hdr.fp_appver, 0);
    if (fread(appver, OM_K_APPVER_LEN * hdr.i_num_appver, 1, fp) != 1)
    {
        fclose(fp);
        return(FALSE);
    }
    fclose(fp);

    /* loop through each stamp... */
    tzlen = strlen(two_zero);
    tolen = strlen(two_one);
    for (i = 0; i < hdr.i_num_appver; i++)
    {
        /* ...looking for exnuc... */
        if (strncmp(&appver[OM_K_APPVER_LEN * i],
                    exnuc, OM_K_APPVER_ID_LEN) == 0)
        {
            /* found exnuc, now check versions */
            v = strchr(&appver[OM_K_APPVER_LEN * i], '0');
            if ((strncmp(v, two_zero, tzlen) == 0) ||
                ((strncmp(v, two_one, tolen) == 0) && 
                 ((i = atoi(v + 9)) < FixedVersion)))
                /* found it - need to fix this file */
                return(GRrebuild_cell_lib_btree(filename, osnum, filenum));

            /* no need to continue */
            break;
        }
    }
    return(TRUE);
}

#ifdef TestThis
int GRrebuild_cell_lib_btree(osnum)
OMuword osnum;
{
    printf("Called GRrebuild_cell_lib_btree\n");
    return(1);
}

main(argc, argv)
int argc;
char *argv[];
{
    GRvalidate_cell_lib_btree(argv[1], 0);
}
#endif
