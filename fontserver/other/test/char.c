/* This program is for creating and displaying a single character.	*/
/* All font parameters may be specified on the command line.		*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			600.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			0		/* flags	*/
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    BmapInfo info;
    RangeSpec range[2];
    int tmp, wno, i, vs;
    double x, y, atof ();
    CharId chr;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.resFactor = atof (argv[3]);

    if (argc > 4)
	fontSpec.aspect = atof (argv[4]);

    if (argc > 5)
	fontSpec.rotation = atof (argv[5]);

    if (argc > 6)
	fontSpec.slant = atof (argv[6]);

    if (argc > 7)
	fontSpec.charMap = argv[7];

    if (argc > 8)
	fontSpec.flags = atoi (argv[8]);

    chr = 65;
    if (argc > 9)
	chr = atoi (argv[9]);

    FSEnter (0);

    range[0].start = chr;
    range[0].count = 1;
    range[1].start = (CharId) -1;

    if (FSNewFont (&fontSpec, range, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	goto DONE;
    }

    if (FSGetBmapInfo (font, &info) != FS_NO_ERROR)
	FSGetOutlInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 40, 40, 1000, 800, &wno);
    Set_win_sys_icon (wno, REFRESH_ICON_VALUE, 0);
    Display_win (wno);

    hidecursor (wno);

    x = 10.0;	y = info.maxExtent;
    FSDrawChar (wno, font, chr, x, y, &x, &y);

    showcursor (wno);
    flushbuffer (wno);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSDeleteFont (font);

    Exit_tools ();

DONE:
    FSExit ();
}
