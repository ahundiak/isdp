/*
Name
        GUsetmetactb

Description
        This function writes the specified color table into an IGDS
        plotting metafile.

History
        mrm     03/13/92    Sun changes
*/

#include "exsysdep.h"
/*
#include "grimport.h"
*/
#include <stdio.h>
#include "igrtypedef.h"
#include "transerr.h"
#include "msdef.h"

IGRboolean GUsetmetactb(msg, metafile, igdsctbfile)
IGRlong	*msg;
IGRchar	*metafile;
IGRchar	*igdsctbfile;
{
    IGRint 	num;
    IGRshort 	buffer[2];
    IGRshort 	type_level;
#ifdef BIG_ENDIAN
    IGRshort    swapped_short;
#endif
    IGRboolean	lstat = FALSE;
    IGRboolean	status = TRUE;
    FILE	*ct_file = NULL, *plot_file = NULL;
    IGRuchar    colortable[256 * 3];

    /*
     *  Initialization.
     */
     
    *msg = MSSUCC;
    
    /*
     *	Open metafile and IGDS color table file.
     */

    if ((plot_file = fopen(metafile,"r+")) == 0)
    {
	*msg = GUCANTOPNMTFL;
	status = FALSE;
#ifdef DEBUG
	printf("GUsetmetactb: Can't open metafile\n");
#endif
	goto wrapup;
    }

    if ((ct_file = fopen(igdsctbfile,"r")) == 0)
    {
	*msg = GUCANTOPNFL;
	status = FALSE;
#ifdef DEBUG
	printf("GUsetmetactb: Can't open color table file\n");
#endif
	goto wrapup;
    }

    /*
     *	Search for plotting type 5 and insert
     *  new color table in it.
     */
     
    while (!lstat)
    {
	if ((num = fread(buffer, sizeof(short), 2, plot_file)) != 2)
	{
	    *msg = GUNOTPLTMTFL;
	    status = FALSE;
#ifdef DEBUG
	    printf("GUsetmetactb: Not a plotting metafile.\n");
#endif
	    goto wrapup;
	}
	
#ifdef BIG_ENDIAN
        GRconv_short(&buffer[0], &swapped_short); buffer[0] = swapped_short;
        GRconv_short(&buffer[1], &swapped_short); buffer[1] = swapped_short;
#endif

	type_level = buffer[0];
	if (type_level == 0x0504)	/* found plotting type 5 */
	{
	    lstat = TRUE;
	    fseek(plot_file, 556, 1);
            if (fread(colortable, sizeof(IGRuchar) * 3, 256, ct_file) != 256)
            {
                *msg = GUREAD_ERROR;
                status = FALSE;
#ifdef DEBUG
                printf("GUsetmetactb: Cannot read IGDS color table.\n");
#endif
                goto wrapup;
            }

            if (fwrite(colortable, sizeof(IGRuchar) * 3, 256, plot_file) != 256)
            {
                *msg = GUWRITE_ERROR;
                status = FALSE;
#ifdef DEBUG
                printf("GUsetmetactb: Cannot write color table.\n");
#endif
                goto wrapup;
            }
	}
	else
	{
	    fseek(plot_file, buffer[1]*2, 1);
	}
    }

wrapup:

    if (plot_file)
    {
	fclose(plot_file);
    }

    if (ct_file)
    {
	fclose(ct_file);
    }

    return(status);

}
