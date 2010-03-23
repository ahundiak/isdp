/* This program is used in conjunction with shwrite.sh.			*/
/* It reads stdin as text and outputs the text in a scrolling window	*/
/* using the specified font.						*/
/*									*/
/* See shwrite.sh for an explanation of how to use it.			*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>
#include <FSOutl.h>

typedef struct
{
	int x1, y1, x2, y2;
} Rect;

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			32.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* ASCII	*/
			FS_ALL_BITMAPS | FS_DEMAND | FS_SHARED
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    CharId chr;
    int vs, tmp, window, i, stat, outl;
    int width, height, howMany, which, xx, yy;
    double x, y, nx, ny, atof (), lineHeight;
    BmapInfo info;
    BmapCharInfo bmapCInfo;
    OutlCharInfo outlCInfo;
    Rect *wBounds;

    howMany = 2;	/* sqrt of how many windows */
    if (argc > 1)
	howMany = atoi (argv[1]);

    which = 0;
    if (argc > 2)
	which = atoi (argv[2]);

    if (argc > 3)
	fontSpec.typeface = argv[3];

    if (argc > 4)
	fontSpec.bodySize = atof (argv[4]);

    /** Calculate the windows' bounds **/
    wBounds = (Rect *) malloc (howMany * howMany * sizeof (Rect));
    width = 1174 / howMany - 10;
    height = 790 / howMany - 40;
    for (yy = i = 0; yy < howMany; yy++)
    {
	for (xx = 0; xx < howMany; xx++)
	{
	    wBounds[i].x1 = xx * (width + 10) + 10;
	    wBounds[i].y1 = yy * (height + 40) + 40;
	    wBounds[i].x2 = wBounds[i].x1 + width - 1;
	    wBounds[i].y2 = wBounds[i].y1 + height - 1;
	    i++;
	}
    }

    FSEnter (0);

    if ((stat = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	printf ("FSNewFont error: %d\n", stat);
	goto DONE;
    }

    if (outl = fontSpec.flags & FS_OUTLINE)
	FSGetOutlInfo (font, &info);
    else
	FSGetBmapInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "A font", wBounds[which].x1, wBounds[which].y1,
		wBounds[which].x2, wBounds[which].y2, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    lineHeight = info.maxExtent - info.minExtent;
    x = 10.0;
    y = info.maxExtent + 10.0;
    fgcolor (window, -1);

    for (;;)
    {
	Inq_events (&tmp);
	if (tmp & DELETE_EVENT)
	    goto ALLDONE;

	chr = getchar ();
	if (feof (stdin))
	    goto Stop;

	if (chr == '\n')
	{
	    goto NextLine;
	}
	else if ((!outl && (FSGetBmapCharInfo (font, chr, &bmapCInfo) == FS_NO_ERROR)) ||
		 (outl && (FSGetOutlCharInfo (font, chr, &outlCInfo) == FS_NO_ERROR)))
	{
	    FSGetCharVect (font, chr, x, y, &nx, &ny);
	    if (nx > (double) width)
	    {
NextLine:
		x = 10.0;
		if (y + lineHeight - info.minExtent < (double) height)
		    y += lineHeight;
		else
		{
		    int	wx1, wy1, wx2, wy2;

		    Inq_win_region (window, &wx1, &wy1, &wx2, &wy2);
		    width = wx2 - wx1;
		    height = wy2 - wy1;

		    hidecursor (window);
		    blockmove (window, 0, (int) lineHeight,
			       width - 1, height - 1, 0, 0);

		    fgcolor (window, 0);
		    rectf (window, 0, (int) (y - info.maxExtent), width - 1,
			   (int) (y - info.minExtent) - 1);
		    fgcolor (window, -1);
		    showcursor (window);
		}
	    }
	    hidecursor (window);
	    FSDrawChar (window, font, chr, x, y, &x, &y);
	    showcursor (window);
	    flushbuffer (window);
	}
    }

    showcursor (window);
    flushbuffer (window);

Stop:
    Wait_for_events (DELETE_EVENT, &tmp);

ALLDONE:
    Exit_tools ();

DONE:
    FSExit ();
}
