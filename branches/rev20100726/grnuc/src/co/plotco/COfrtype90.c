/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COfindrastype90

Description
        This function searches a plotfile for a type 90 Raster
        Reference element.  If it finds one, it checks to see that
        the file referenced is present on disk.  The raster file
        name is returned in rasfile.

Return Values
        IGRint COfindrastype90()    TRUE - success; type 90 and corresponding
                                        raster file both found
                                    FALSE - failure; check msg
        IGRlong *msg                PI_S_SUCCESS - success; type 90 and
                                        corresponding raster file both found
                                    PI_F_CANTOPENFILE - failed to open the
                                        plotfile
                                    PI_F_FAIL - type 90 not found
                                    PI_F_NORASFILE - type 90 found, but
                                        raster file not found on disk (raster
                                        name still returned)
                                    
History
        mrm     12/21/89    creation
                03/01/90    add check for EOF
*/

#include "exsysdep.h"
#ifndef STANDALONE
#include "coimport.h"
#endif
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "pidef.h"

struct type_90   /* from RDH */
{
    struct GUcommon_header_info		header;
    IGRlong				wds_in_descript;
    IGRchar                             comptype;
    IGRchar                             version;
    IGRchar                             filespec[66];
    IGRshort                            rasterid;
    IGRshort                            file_offset[2];
    IGRshort                            origin[12];
    IGRshort                            width[4];
    IGRshort                            height[4];
    IGRchar                             logical_name[24];
    IGRchar                             description[42];
    IGRchar                             attr_length;
    IGRchar                             attr_type;
    IGRlong                             priority;
};

extern int stat();
extern char *strrchr();

IGRint COfindrastype90 (msg, plotfile, rasfile, shvar)
IGRlong *msg;
IGRchar *plotfile, *rasfile, *shvar;
{
    char            *c;
    short            type90_found = FALSE;
    short            buf[2];
    FILE            *pf = NULL;
    struct stat      filestat;
    struct type_90   type90;
#ifdef BIG_ENDIAN
    short            swapped_buf0, swapped_buf1;
#endif

    *msg = PI_F_FAIL;
    *rasfile = NULL;

    if ((pf = fopen (plotfile, "r")) == 0)
    {
        *msg = PI_F_CANTOPENFILE;
        goto wrapup;
    }

    /* make sure the file is an IGDS file */

    if (fread (buf, sizeof (short), 2, pf) != 2)
    {
        goto wrapup;
    }

#ifdef BIG_ENDIAN
    GRconv_short(&buf[0], &swapped_buf0);
    GRconv_short(&buf[1], &swapped_buf1);
    if ((((swapped_buf0 & 0x7f00) >> 8) == 9) && (swapped_buf1 == 766))
#else
    if ((((buf[0] & 0x7f00) >> 8) == 9) && (buf[1] == 766))
#endif
    {
        rewind (pf);
    }
    else
    {
        goto wrapup;
    }

    /* read the metafile looking for type 90 element */

    while (!type90_found)
    {
        if (fread (buf, sizeof (short), 2, pf) != 2 || buf[0] == EOF)
        {
            goto wrapup;
        }

#ifdef BIG_ENDIAN
        GRconv_short(&buf[0], &swapped_buf0);
        GRconv_short(&buf[1], &swapped_buf1);

        if (((swapped_buf0 & 0x7f00) >> 8) == 90)
#else
        if (((buf[0] & 0x7f00) >> 8) == 90)
#endif
        {
#ifdef BIG_ENDIAN
            if (fread (type90.header.range, sizeof (short), swapped_buf1, pf)
                != swapped_buf1)
#else
            if (fread (type90.header.range, sizeof (short), buf[1], pf) != buf[1])
#endif
            {
                goto wrapup;
            }

            /* check for component type == 0 (header element) */

            if (type90.comptype == 0)
            {
                type90_found = TRUE;
                *msg = PI_F_NORASFILE;

                /* read the environment variable to pass along */

                strcpy (shvar, type90.filespec);

                /* check for raster file in same directory as plotfile */

                if (c = strrchr (plotfile, '/'))
                {
                    strcpy (rasfile, plotfile);
                    c = strrchr (rasfile, '/') + 1;
                }
                else
                {
                    c = rasfile;
                }
                strcpy (c, type90.description);
                if ((stat (rasfile, &filestat)) == 0)
                {
                    *msg = PI_S_SUCCESS;
                }
#ifdef DEBUG
                printf ("COfindrastype90: rasfile %s %sfound\n",
                        rasfile, (*msg & 1) ? "" : "not ");
#endif
            }
        }
        else
        {
#ifdef BIG_ENDIAN
            fseek (pf, swapped_buf1*2, 1);
#else
            fseek (pf, buf[1]*2, 1);    
#endif
        }
    }

wrapup:

    if (pf) fclose (pf);

    return (*msg & 1);
}
