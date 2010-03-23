/* This program draws all (or as many as possible of) the characters	*/
/* in a typeface.  The font that is created is a shared font.		*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>
#include <FSOutl.h>


#define WIDTH	500
#define HEIGHT	780

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			32.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"all",		/* all chars	*/
			FS_ALL_BITMAPS | FS_DEMAND | FS_SHARED
		    };

double	atof ();


main (argc, argv)
int argc;
char *argv[];
{
    int			vs, tmp, window, i, start, status, outl;
    int			wx1, wy1, wx2, wy2, wWidth, wHeight;
    double		x, y, nx, ny;
    FontId		font;
    BmapInfo		info;
    BmapCharInfo	bmapCInfo;
    OutlCharInfo	outlCInfo;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.charMap = argv[3];

    if (argc > 4)
	fontSpec.flags = atoi (argv[4]);

    start = 0;
    if (argc > 5)
	start = atoi (argv[5]);

    FSEnter (0);

    if ((status = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	printf ("Can't create font!  Error = %d\n", status);
	goto Done;
    }

    if (outl = fontSpec.flags & FS_OUTLINE)
	FSGetOutlInfo (font, &info);
    else
	FSGetBmapInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "A font", 20, 40, 19 + WIDTH, 39 + HEIGHT, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    if (Display_win_marq (window))
	goto AllDone;
    Inq_win_region (window, &wx1, &wy1, &wx2, &wy2);
    wWidth = wx2 - wx1 + 1;
    wHeight = wy2 - wy1 + 1;

    x = 10.0;	y = info.ascent + 10.0;
    for (i = start; i < 0x10000; i++)
    {
	Inq_events (&tmp);
	if (tmp & DELETE_EVENT)
	    goto AllDone;

	if ((!outl && (FSGetBmapCharInfo (font, i, &bmapCInfo) == FS_NO_ERROR)) ||
	    (outl && (FSGetOutlCharInfo (font, i, &outlCInfo) == FS_NO_ERROR)))
	{
	    FSGetCharVect (font, i, x, y, &nx, &ny);
	    if (nx > (double) wWidth)
	    {
		x = 10.0;
		y += info.bodySize;
		if (y + info.descent > (double) wHeight)
		    break;
	    }
	    hidecursor (window);
	    FSDrawChar (window, font, i, x, y, &x, &y);
	    showcursor (window);
	}

	/* Simple progress indicator based on charId */
	hidecursor (window);
	pnt (window, i * wWidth / 0x10000, 0);
	pnt (window, i * wWidth / 0x10000, 1);
	showcursor (window);
	flushbuffer (window);
    }

    Wait_for_events (DELETE_EVENT, &tmp);

AllDone:
    Exit_tools ();

Done:
    FSExit ();
}
