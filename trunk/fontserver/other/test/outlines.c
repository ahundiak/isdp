/* This program tests the FSGetOutl*() routines.  It uses them to draw	*/
/* a string of character outlines.  However, the outline draw function	*/
/* is normally used for this purpose.					*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSOutl.h>


FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			48.0,		/* bodysize	*/
			1.0,
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0		/* slant	*/
			"ascii",	/* char map	*/
			FS_NO_PLAID | FS_OUTLINE | FS_DEMAND
		    };


main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    OutlInfo fontInfo;
    OutlKernPair *kern;
    OutlCharInfo *charInfo;
    OutlPolySize *charPSize;
    OutlVertex *charVert;
    int vs, window, i, j, k, tmp, c, numChars, numKerns, stat;
    double x, y, atof ();

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    if (stat = FSNewFont (&fontSpec, NULL, &font))
    {
	printf ("NewFont error: %d\n", stat);
	goto Done;
    }
    FSGetOutlInfo (font, &fontInfo);

    kern = NULL;
    FSGetOutlKernTable (font, &kern, &numKerns);

    charInfo = NULL;
    FSGetOutlAllCharInfo (font, &charInfo, &numChars);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Outlines", 20, 30, 1120, 230, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    x = 10.0;	y = fontInfo.bodySize;
    for (c = 0; c < numChars; c++)
    {
	charPSize = (OutlPolySize *) malloc (charInfo[c].nPSize *
					       sizeof (OutlPolySize));
	FSGetOutlPolySizes (font, charInfo[c].charId, &charPSize, &tmp);

	charVert = (OutlVertex *) malloc (charInfo[c].nVert *
					    sizeof (OutlVertex));
	FSGetOutlVertices (font, charInfo[c].charId, &charVert, &tmp);

	if (charInfo[c].nPSize > 0)
	{
	    i = 0;	/* i = vertex index */
	    for (j = 0; j < charInfo[c].nPSize; j++)	/* j = poly index */
	    {
		move (window, (int) (x + charVert[i + charPSize[j] - 1].x),
			      (int) (y - charVert[i + charPSize[j] - 1].y));
		for (k = 0; k < charPSize[j]; k++)
		{
		    draw (window, (int) (x + charVert[i + k].x),
				  (int) (y - charVert[i + k].y));
		}
		i += charPSize[j];
	    }
	}
	x += charInfo[c].setWid;

	free (charVert);
	free (charPSize);
    }

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSDeleteFont (font);

Done:
    FSExit ();
    Exit_tools ();
}
