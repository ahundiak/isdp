/** This program prints out a bunch of information about the font it	**/
/** creates.								**/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>
#include <FSOutl.h>

char *string = "Now is the time for all good men.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			48.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",
			0
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int vs, window, i, numKernPairs, numChars, bmap;
    long event;
    double x, y, atof ();
    BmapInfo info;
    BmapKernPair *kernPairs;
    BmapCharInfo *bmapCharInfo;
    OutlCharInfo *outlCharInfo;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.charMap = argv[3];

    if (argc > 4)
	fontSpec.flags = atof (argv[4]);

    if (argc > 5)
	string = argv[5];

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    FSNewFont (&fontSpec, NULL, &font);

    /** Decide if font is bitmap or outline **/
    bmap = (FSGetBmapInfo (font, &info) == FS_NO_ERROR);
    if (!bmap)
	FSGetOutlInfo (font, &info);

    /** Get the info **/
    kernPairs = NULL;
    bmapCharInfo = NULL;
    outlCharInfo = NULL;
    if (bmap)
    {
	FSGetBmapKernTable (font, &kernPairs, &numKernPairs);
	FSGetBmapAllCharInfo (font, &bmapCharInfo, &numChars);
    }
    else
    {
	FSGetOutlKernTable (font, &kernPairs, &numKernPairs);
	FSGetOutlAllCharInfo (font, &outlCharInfo, &numChars);
    }

    /** Print the info **/
    printf ("Kern tracks: %g %g %g %g\n", info.track[0], info.track[1],
	    info.track[2], info.track[3]);

    printf ("\nKern pairs:\n");
    for (i = 0; i < numKernPairs; i++)
	printf ("%c (%d)  %c (%d)  %g\n", kernPairs[i].char1,
		kernPairs[i].char1, kernPairs[i].char2, kernPairs[i].char2,
		kernPairs[i].kern);

    printf ("\nChar id, set width:\n");
    for (i = 0; i < numChars; i++)
    {
	if (bmap)
	    printf ("%d\t%g\n", bmapCharInfo[i].charId, bmapCharInfo[i].setWid);
	else
	    printf ("%d\t%g\n", outlCharInfo[i].charId, outlCharInfo[i].setWid);
    }

    free (kernPairs);
    free (bmap ? (char *) bmapCharInfo : (char *) outlCharInfo);


    Inq_displayed_vs (&vs);
    Create_win (vs, "Font info", 20, 40, 1020, 840, &window);
    Display_win (window);

    hidecursor (window);

    x = 10.0;	y = fontSpec.bodySize;
    FSDrawString (window, font, string, x, y, &x, &y);

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &event);

    FSExit ();
    Exit_tools ();
}
