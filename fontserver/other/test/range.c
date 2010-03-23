/** This program tests the capability of specifying a range while	**/
/** having the FS_DEMAND flag turned on.  Only the specified range of	**/
/** characters should be created.					**/
/** Output should be: ABCDPQRST						**/

#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char str[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			64.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_DEMAND
		    };

RangeSpec	range[] = { { 'A', 4 }, { 'P', 5 }, { 0xFFFF, 0 } };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    BmapInfo info;
    int vs, tmp, wno, i, j, stat;
    double x, y, atof ();

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.flags = atoi (argv[3]);

    FSEnter (0);

    if ((stat = FSNewFont (&fontSpec, range, &font)) != FS_NO_ERROR)
    {
	printf ("Can't create font!  Error = %d\n", stat);
	goto DONE;
    }

    if (FSGetBmapInfo (font, &info) != FS_NO_ERROR)
	FSGetOutlInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 20, 40, 1020, 200, &wno);
    Display_win (wno);
    Set_win_sys_icon (wno, REFRESH_ICON_VALUE, 0);

    hidecursor (wno);

    x = 10.0;	y = info.maxExtent;
    FSDrawString (wno, font, str, x, y, &x, &y);

    showcursor (wno);
    flushbuffer (wno);

    Wait_for_events (DELETE_EVENT, &tmp);

    Exit_tools ();

DONE:
    FSExit ();
}
