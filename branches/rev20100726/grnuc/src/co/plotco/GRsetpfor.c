/*
Name
        GRset_plotfile_orientation

Description
        This function opens an IGDS plotting metafile and sets or clears the
        portrait/landscape bit in the Interplot type 5 level 4 element.  The
        bit is adjusted according to the input argument "portrait".

        This function allows a plotfile to be rotated without using IPLOT.

Synopsis
        int GRset_plotfile_orientation(char *filename, int portrait)

        The function returns TRUE if it succeeds in adjusting the bit, and
        FALSE otherwise.

        char *filename - input
        The name of the file to adjust.

        int portrait - input
        If TRUE, the plotfile is set to portrait mode.
        If FALSE, the plotfile is set to landscape mode.

History
        mrm     08/05/93        creation
*/

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include "trans_ele.h"

#define TRUE    1
#define FALSE   0

int GRset_plotfile_orientation(char *filename, int portrait)
{
    int fd = -1;
    int sts = FALSE;
    int found = FALSE;
    int two_shorts = sizeof(short) * 2;
    short buf[2], n;
    Trans_ele type5;

    if ((fd = open(filename, 2)) == -1)       /* read/write */
        return(FALSE);
    
    /* make sure the file is an IGDS file */
    if (read(fd, buf, two_shorts) != two_shorts)
        goto punt;
#ifdef BIG_ENDIAN
    GRconv_short(&buf[0], &buf[0]);
    GRconv_short(&buf[1], &buf[1]);
#endif
    if ((((buf[0] & 0x7f00) >> 8) == 9) && (buf[1] == 766))
        lseek(fd, buf[1] * 2, 1);    
    else
        goto punt;

    /* scan the file */
    while (!found)
    {
        /* read the element type/level */
        if (read(fd, buf, two_shorts) != two_shorts || buf[0] == EOF)
            goto punt;
#ifdef BIG_ENDIAN
        GRconv_short(&buf[0], &buf[0]);
        GRconv_short(&buf[1], &buf[1]);
#endif

        /* check whether it is a plotting type 5 level 4 element */
        if (buf[0] == 0x0504)
        {
            /* read the rest of the element */
            type5.type_level = buf[0];
            type5.words_to_follow = buf[1];
            n = sizeof(short) * buf[1];
            if (read(fd, &type5.xlow, n) != n)
                goto punt;

            /* set the landscape/portrait bit */
#ifdef BIG_ENDIAN
            GRconv_short(&type5.extended_dflags, &type5.extended_dflags);
#endif
            if (portrait)
                type5.extended_dflags |= (1 << IPOrientBit);
            else
                type5.extended_dflags &= ~(1 << IPOrientBit);
#ifdef BIG_ENDIAN
            GRconv_short(&type5.extended_dflags, &type5.extended_dflags);
#endif

            /* write the element back out */
            lseek(fd, n * (-1), 1);
            write(fd, &type5.xlow, n);

            /* break the loop */
            found = TRUE;
            sts = TRUE;
        }
        else
            /* skip ahead to the next element */
            lseek(fd, buf[1] * 2, 1);    
    }

  punt:

    /* close the file */
    if (fd != -1)
        close(fd);

    return(sts);
}
