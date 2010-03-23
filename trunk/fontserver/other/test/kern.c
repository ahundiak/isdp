/* This program tests the kern pair and kern track capabilities.	*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char *string = "YAT-YAT-YAT.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			48.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",
			FS_DEMAND
		    };

RangeSpec rangeSpec[] = { { 32, 96 },
			  { -1, -1 } };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int vs, window, i, numKernPairs;
    long event;
    double x, y, atof ();
    BmapInfo info;
    BmapKernPair *kernPairs;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	string = argv[3];

    if (argc > 4)
	fontSpec.flags = atof (argv[4]);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    FSNewFont (&fontSpec, rangeSpec, &font);

    FSGetBmapInfo (font, &info);
    printf ("track: %g %g %g %g\n", info.track[0], info.track[1],
				    info.track[2], info.track[3]);
    kernPairs = NULL;
    FSGetBmapKernTable (font, &kernPairs, &numKernPairs);
    for (i = 0; i < numKernPairs; i++)
	printf ("%c (%d)  %c (%d)  %g\n", kernPairs[i].char1,
		kernPairs[i].char1, kernPairs[i].char2, kernPairs[i].char2,
		kernPairs[i].kern);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 20, 40, 1019, 839, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    x = 10.0;	y = fontSpec.bodySize;

    FSSetKernMode (font, 0);
    FSSetKernTrack (font, 0);
    FSDrawString (window, font, string, x, y, &x, &y);
    FSDrawString (window, font, "        (No kerning)", x, y, NULL, NULL);
    x = 10.0;	y += fontSpec.bodySize;

    FSSetKernMode (font, 1);
    FSSetKernTrack (font, 0);
    FSDrawString (window, font, string, x, y, &x, &y);
    FSDrawString (window, font, "        (Kerning pairs)", x, y, NULL, NULL);
    x = 10.0;	y += fontSpec.bodySize;

    FSSetKernMode (font, 0);
    FSSetKernTrack (font, 1);
    FSDrawString (window, font, string, x, y, &x, &y);
    FSDrawString (window, font, "        (Kerning track 1)", x, y, NULL, NULL);
    x = 10.0;	y += fontSpec.bodySize;

    FSSetKernMode (font, 0);
    FSSetKernTrack (font, 2);
    FSDrawString (window, font, string, x, y, &x, &y);
    FSDrawString (window, font, "        (Kerning track 2)", x, y, NULL, NULL);
    x = 10.0;	y += fontSpec.bodySize;

    FSSetKernMode (font, 0);
    FSSetKernTrack (font, 3);
    FSDrawString (window, font, string, x, y, &x, &y);
    FSDrawString (window, font, "        (Kerning track 3)", x, y, NULL, NULL);
    x = 10.0;	y += fontSpec.bodySize;

    FSSetKernMode (font, 1);
    FSSetKernTrack (font, 3);
    FSDrawString (window, font, string, x, y, &x, &y);
    FSDrawString (window, font, "        (Kerning pairs & track 3)", x, y, NULL, NULL);
    x = 10.0;	y += fontSpec.bodySize;

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &event);

    FSWriteFontFile (font, "font16");

    FSExit ();
    Exit_tools ();
}
