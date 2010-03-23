/* This program tests the speed of the Font Server.  Type as fast as	*/
/* you can.  It'll keep up!!!						*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

#define WIDTH	1000
#define HEIGHT	800

FontSpec fontSpec = {	"dutch801",	/* typeface	*/
			64.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"dec",
			0
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    RangeSpec *range;
    int vs, window, i, numChars;
    char key[1];
    long event;
    double x, y, asc, desc, nx, ny, atof ();
    BmapInfo info;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.flags = atoi (argv[3]);
    fontSpec.flags |= (FS_DEMAND | FS_NO_KERN);

    FSEnter (0);

    if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	goto Done;
    }

    if (fontSpec.flags & FS_OUTLINE)
	FSGetOutlInfo (font, &info);
    else
	FSGetBmapInfo (font, &info);

    desc = info.descent;
    asc = info.ascent;

    Enter_tools ();
    Enable_events (DELETE_EVENT | KEYBOARD_EVENT);
    Set_keyboard_buffer (key, 1);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Type as fast as you can!", 20, 30, 19 + WIDTH, 29 + HEIGHT, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    x = 10.0;	y = asc;
    for (;;)
    {
	Wait_for_events (DELETE_EVENT | KEYBOARD_EVENT, &event);

	if (event & DELETE_EVENT)
	    break;
	else if (event & KEYBOARD_EVENT)
	{
	    Get_keyboard_data (&numChars);

	    hidecursor (window);

	    if ((key[0] == '\n') || (key[0] == '\r'))
		goto NextLine;
	    else
	    {
		FSGetCharVect (font, key[0], x, y, &nx, &ny);
		if (nx > (double) WIDTH)
		{
NextLine:	    x = 10.0;
		    y += info.bodySize;
		    if (y + desc > (double) HEIGHT)
			break;
		}
	    }

	    fgcolor (window, -1);
	    FSDrawChar (window, font, key[0], x, y, &x, &y);
	    showcursor (window);
	    flushbuffer (window);
	}
    }

    Wait_for_events (DELETE_EVENT, &event);

    Exit_tools ();

Done:
    FSExit ();
}
