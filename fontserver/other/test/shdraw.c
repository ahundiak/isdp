/* This program exercises the shared memory semaphore and character	*/
/* locking mechanism.  Run two instances of the program like this:	*/
/*									*/
/*   shdraw 0 & shdraw 1 &						*/
/*									*/
/* They will both try to create and access the same font in shared	*/
/* memory.  This creates a race condition between the two processes,	*/
/* but only one of the processes is repsonsible for creating a		*/
/* particular character.  While a character is being created (by the	*/
/* daemon, of course), the other process can't access the character	*/
/* (assuming it catches up in time to ask for it).  Is this confusing	*/
/* enough?								*/


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

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    CharId chr;
    int vs, events, window, i, rVal, outl, offs, offset, width, height;
    double x, y, nx, ny, atof ();
    BmapInfo info;
    BmapCharInfo bmapCInfo;
    OutlCharInfo outlCInfo;

    offs = 0;
    if (argc > 1)
	offs = atoi (argv[1]);

    if (argc > 2)
	fontSpec.typeface = argv[2];

    if (argc > 3)
	fontSpec.bodySize = atof (argv[3]);

    FSEnter (0);

    if ((rVal = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	printf ("FSNewFont error: %d\n", rVal);
	goto Done;
    }

    if (outl = fontSpec.flags & FS_OUTLINE)
	FSGetOutlInfo (font, &info);
    else
	FSGetBmapInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT | REFRESH_EVENT);

    Inq_displayed_vs (&vs);
    offset = offs ? WIDTH + 20 : 0;
    Create_win (vs, "A font", 20 + offset, 35, 19 + WIDTH + offset,
		34 + HEIGHT, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    {
	int	x1, y1, x2, y2;

	Inq_win_region (window, &x1, &y1, &x2, &y2);
	width = x2 - x1 + 1;
	height = y2 - y1 + 1;
    }

    for (;;)
    {
	x = 10.0;
	y = info.ascent + 10.0;
	Erase_win (window);

	for (;;)
	{
	    Inq_events (&events);

	    if (events & DELETE_EVENT)
		goto AllDone;

	    if (events & REFRESH_EVENT)
	    {
		int	x1, y1, x2, y2, rx1, ry1, rx2, ry2, op;

		Get_refresh_area_data (&window, &vs, &x1, &y1, &x2, &y2,
					&rx1, &ry1, &rx2, &ry2, &op);
		width = x2 - x1 + 1;
		height = y2 - y1 + 1;
	    }

	    chr = rand () % 600;
	    if ((!outl && (FSGetBmapCharInfo (font, chr, &bmapCInfo) == FS_NO_ERROR)) ||
		(outl && (FSGetOutlCharInfo (font, chr, &outlCInfo) == FS_NO_ERROR)))
	    {
		FSGetCharVect (font, chr, x, y, &nx, &ny);
		if (nx > (double) width)
		{
		    x = 10.0;
		    y += info.bodySize;
		    if (y + info.descent > (double) height)
			break;
		}
		hidecursor (window);
		FSDrawChar (window, font, chr, x, y, &x, &y);
		showcursor (window);
		flushbuffer (window);
	    }
	}
    }

AllDone:
    Exit_tools ();

Done:
    FSExit ();
}
