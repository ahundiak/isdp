/* This program is used in conjunction with the shsig program.  It	*/
/* creates and displays a shared font.  It also counts the number of	*/
/* the signal SIGUSR1 it catches, and displays the number as a line of	*/
/* pixels drawn between the characters that are drawn.  Due to the	*/
/* way signals work, only one signal at a time is usually caught.	*/
/*									*/
/* See shsig.c for a lengthy and confusing explanation of how to use	*/
/* it.									*/


#include <signal.h>
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
			FS_ALL_BITMAPS | FS_SHARED | FS_DEMAND
		    };

int	sigCount;

void	Usr1Func ();


main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int vs, tmp, window, i, stat, outl, offs, offset;
    char *wTitle;
    double x, y, nx, ny, atof ();
    BmapInfo info;
    BmapCharInfo bmapCInfo;
    OutlCharInfo outlCInfo;

    sigset (SIGUSR1, Usr1Func);
    sleep (1);

    offs = 0;
    if (argc > 1)
	offs = atoi (argv[1]);

    if (argc > 2)
	fontSpec.typeface = argv[2];

    if (argc > 3)
	fontSpec.bodySize = atof (argv[3]);

    if (argc > 4)
	fontSpec.charMap = argv[4];

    if (argc > 5)
	fontSpec.flags = atof (argv[5]);

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

    if (info.flags & FS_SHARED)
	wTitle = "A Shared Font";
    else
	wTitle = "A Font";

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    offset = offs ? WIDTH + 20 : 0;
    Create_win (vs, wTitle, 20 + offset, 40, 19 + WIDTH + offset,
		39 + HEIGHT, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    sigCount = 0;
    x = 10.0;	y = info.ascent + 10.0;
    for (i = 0; i < 0x10000; i++)
    {
	Inq_events (&tmp);
	if (tmp & DELETE_EVENT)
	    goto ALLDONE;

	if ((!outl && (FSGetBmapCharInfo (font, i, &bmapCInfo) == FS_NO_ERROR)) ||
	    (outl && (FSGetOutlCharInfo (font, i, &outlCInfo) == FS_NO_ERROR)))
	{
	    FSGetCharVect (font, i, x, y, &nx, &ny);
	    if (nx > (double) WIDTH)
	    {
		x = 10.0;
		y += info.bodySize;
		if (y + info.descent > (double) HEIGHT)
		    break;
	    }
	    hidecursor (window);
	    FSDrawChar (window, font, i, x, y, &x, &y);
	    showcursor (window);
	    flushbuffer (window);
	}

	if (sigCount > 0)
	{
	    move (window, (int) x, (int) y);
	    x += (double) sigCount;
	    draw (window, ((int) x) - 1, (int) y);
	    sigCount = 0;
	}

	pnt (window, i * WIDTH / 0x10000, 0);
	pnt (window, i * WIDTH / 0x10000, 1);
    }

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

ALLDONE:
    Exit_tools ();

DONE:
    FSExit ();
}


void Usr1Func ()
{
    sigCount++;
}
