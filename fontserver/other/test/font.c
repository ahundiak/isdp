/* This program is for creating and displaying characters in a font.	*/
/* All font parameters may be specified on the command line.		*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char *string = "The quick brown fox jumps over the lazy dog. 0123456789 !@#$%^&*()[]{}<>";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_DEMAND	/* flags	*/
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    BmapInfo info;
    int vs, tmp, window;
    double x, y, atof ();

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

    if (argc > 9)
	string = argv[9];

    FSEnter (0);

    if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	goto DONE;
    }

    if (FSGetBmapInfo (font, &info) != FS_NO_ERROR)
	FSGetOutlInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "A font", 20, 30, 1020, 820, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    x = 500.0;	y = 400.0 + info.maxExtent;
    FSDrawString (window, font, string, x, y, &x, &y);

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSWriteFontFile (font, "fsfont");
    FSWriteSymbolFile (font, "symfont");

    FSDeleteFont (font);

    Exit_tools ();

DONE:
    FSExit ();
}
