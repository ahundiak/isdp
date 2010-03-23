/* This program tests the FSPutBmapKernTable() routine.			*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>


char str[] = "The quick brown fox.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_DEMAND | FS_ALL_BITMAPS
		    };


BmapKernPair	kernPairs[] =
	{ { 'T', 'h', -2.0 }, { 'q', 'u', 5.1 }, { 'b', 'r', 4.2 } };

int	numKernPairs = sizeof (kernPairs) / sizeof (BmapKernPair);


main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int vs, tmp, window, i, j, stat;
    double x, y, atof ();
    BmapInfo info;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.flags = atoi (argv[3]);

    FSEnter (0);

    if ((stat = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	printf ("Can't create font!  Error = %d\n", stat);
	goto Done;
    }

    FSGetBmapInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 20, 30, 1020, 820, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    x = 10.0;	y = info.bodySize - info.descent;
    FSDrawString (window, font, str, x, y, &x, &y);

    FSPutBmapKernTable (font, kernPairs, numKernPairs);
    FSUpdateBmapFont (font);

    x = 10.0;	y += info.bodySize;
    FSDrawString (window, font, str, x, y, &x, &y);

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSDeleteFont (font);
    Exit_tools ();

Done:
    FSExit ();
}
