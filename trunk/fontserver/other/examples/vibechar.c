#include <stdio.h>
#include <tools.h>
#include <math.h>
#include <FS.h>
#include <FSBmap.h>
#include <FSOutl.h>


#define	FALSE	0
#define	TRUE	(!FALSE)

#define SAMP_SIZE	12.0

#define DIV(a,b)	((a < 0) ? ((a - b + 1) / b) : (a / b))

#define INDEX(size,rot)	((DIV (size, fontSizeInc) - 1) + \
			 (DIV (rot, fontRotInc) - minRot) * sizeDim)

#define NORM(a)		((a >= 180) ? (a - 360) : ((a < -180) ? (a + 360) : a))


typedef struct
{
    double x, y;
} Point;


extern	char	*optarg;
extern	int	optind, opterr;

struct scr_info info[MAX_SCREENS];
double mult[128];
int vs, dbFlag, colorFlag, genFlag;
int sizeDim, rotDim;
int maxFontSize, fontSizeInc, maxFontRot, fontRotInc, minRot;
int wWidth = 800, wHeight = 600;
int startColor, maxColor = 64;

FontSpec fontSpec = {	"dutch801b",
			0,
			1.0,
			1.0,
			0.0,
			0.0,
			"ascii",
			FS_ALL_BITMAPS | FS_NO_PLAID | FS_NO_KERN | FS_SHARED };

double	atof ();


main (argc, argv)
int argc;
char *argv[];
{
    int		i, window, numChars, x, y, tmp, lx, ly, toler, toler2;
    int		bIndex, bDown, strLen, sampleMode, sample, event, maxPoints;
    char	*string, ch;
    double	k, a, length;
    Point	*point0, *point1, *pnt0, *pnt1, *ptmp;
    Point	*veloc;
    FontId	*font;

    Enter_tools_no_act ();
    Inq_displayed_vs (&vs);
    Inq_screen_info (info);

    k = 0.03;
    a = 0.02;
    dbFlag = info[vs].vsi_flags & VSI_DB_ABILITY;
    colorFlag = TRUE;
    genFlag = TRUE;
    toler = 15;
    string = "Intergraph";
    maxFontSize = 96;
    fontSizeInc = 8;
    maxFontRot = 180;
    fontRotInc = 15;

    while ((ch = getopt (argc, argv, "k:a:d:c:p:t:f:s:1:2:3:4:?")) != EOF)
    {
	switch (ch)
	{
	    case 'k':
		k = atof (optarg);
		break;

	    case 'a':
		a = atof (optarg);
		break;

	    case 'd':
		dbFlag = atoi (optarg);
		break;

	    case 'c':
		colorFlag = atoi (optarg);
		break;

	    case 'p':
		genFlag = atoi (optarg);
		break;

	    case 't':
		toler = atoi (optarg);
		break;

	    case 'f':
		fontSpec.typeface = optarg;
		break;

	    case 's':
		string = optarg;
		break;

	    case '1':
		maxFontSize = atoi (optarg);
		break;

	    case '2':
		fontSizeInc = atoi (optarg);
		break;

	    case '3':
		maxFontRot = atoi (optarg);
		break;

	    case '4':
		fontRotInc = atoi (optarg);
		break;

	    default:
		goto Usage;
	}
    }

    if (optind < argc)
    {
Usage:
	printf ("Usage:  %s [options]\n", argv[0]);
	printf ("Options:\n");
	printf ("  -k Kf\t\tHook's force constant (%g)\n", k);
	printf ("  -a Ka\t\tAir resistance (%g)\n", a);
	printf ("  -d flag\tdouble buffer (%d)\n", dbFlag ? 1 : 0);
	printf ("  -c flag\tuse colors (%d)\n", colorFlag ? 1 : 0);
	printf ("  -p flag\tpre-generate characters (%d)\n", genFlag ? 1 : 0);
	printf ("  -t toler\tmouse sampling tolerance; left button (%d)\n", toler);
	printf ("  -f typeface\tFont Server typeface (\"%s\")\n", fontSpec.typeface);
	printf ("  -s string\tdisplayed string of characters (\"%s\")\n", string);
	printf ("  -1 max\tmaximum character size (%d)\n", maxFontSize);
	printf ("  -2 inc\tcharacter size increment value (%d)\n", fontSizeInc);
	printf ("  -3 max\tmaximum character +/- rotation angle (%d)\n", maxFontRot);
	printf ("  -4 inc\tcharacter rotation angle increment value (%d)\n", fontRotInc);
	printf ("\n");
	printf ("Use the left button to draw the baseline curve.\n");
	printf ("Use the middle button to grab at the curve.\n");
	printf ("\n");
	exit (1);
    }

    toler2 = toler * toler;

    sizeDim = (maxFontSize / fontSizeInc);
    rotDim = (maxFontRot / fontRotInc * 2);
    minRot = - maxFontRot / fontRotInc;

    /** Create a vlt **/
    if (colorFlag)
    {
	int		numColors;
	struct vlt_slot	*vlt;

	startColor = 0;
	numColors = info[vs].vsi_vlt_size;
	if (numColors > maxColor)
	{
	    startColor = numColors - maxColor;
	    numColors = maxColor;
	}

	if (startColor == 0)
	{
	    startColor = 1;
	    numColors -= 1;
	}

	vlt = (struct vlt_slot *) malloc (numColors * sizeof (struct vlt_slot));
	srand (time (NULL) + getpid ());
	for (i = 0; i < numColors - 1; i++)
	{
	    vlt[i].v_slot = i + startColor;
	    vlt[i].v_red = 20000 + ((rand() % 3) ? 0 : 22767) + rand() % 22767;
	    vlt[i].v_green = 20000 + ((rand() % 3) ? 0 : 22767) + rand() % 22767;
	    vlt[i].v_blue =  20000 + ((rand() % 3) ? 0 : 22767) + rand() % 22767;
	}
	vlt[i].v_slot = i + startColor;
	vlt[i].v_red = vlt[i].v_green = vlt[i].v_blue = 0xffff;

	Loadvlt (vs, vlt, numColors);
	free (vlt);
    }

    /** Create the fonts **/
    FSEnter (0);

    font = (FontId *) malloc (sizeDim * rotDim * sizeof (FontId));
    if (InitFonts (font, string))
	goto Done;

    /** Create a window **/
    Create_win (vs, "Vibes", 20, 35, 19 + wWidth, 34 + wHeight, &window);
    Set_win_button_mode (window, 3);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    Activate_process ();

    strLen = strlen (string);
    maxPoints = strLen + 1;
    point0 = (Point *) malloc (maxPoints * sizeof (Point));
    point1 = (Point *) malloc (maxPoints * sizeof (Point));
    veloc = (Point *) malloc (maxPoints * sizeof (Point));

    hidecursor (window);
    fgcolor (window, 0);
    rectf (window, 0, 0, wWidth - 1, wHeight - 1);
    showcursor (window);

    Enable_events (DELETE_EVENT | BUTTON_EVENT | REFRESH_EVENT);

    sampleMode = FALSE;
    numChars = 0;
    bDown = FALSE;
    for (;;)
    {
	if (sampleMode)
	{
	    Mouseposition (window, &x, &y, &tmp);
	}
	else
	{
	    for (i = 1; i < numChars; i++)
	    {
		double x01, y01, x21, y21, f, fx, fy, vx, vy, mult01, mult21;

		x01 = pnt0[i - 1].x - pnt0[i].x;
		y01 = pnt0[i - 1].y - pnt0[i].y;
		x21 = pnt0[i + 1].x - pnt0[i].x;
		y21 = pnt0[i + 1].y - pnt0[i].y;

		vx = veloc[i].x;
		vy = veloc[i].y;

		mult01 = mult[string[i - 1]];
		mult21 = mult[string[i]];

		fx = k * (x01 * mult01 + x21 * mult21);
		fy = k * (y01 * mult01 + y21 * mult21);

		if (a > 0.0)	/* air friction */
		{
		    fx -= vx * a;	/* proportional to velocity */
		    fy -= vy * a;
		}

		vx += fx;
		vy += fy;

		veloc[i].x = vx;
		veloc[i].y = vy;

		pnt1[i].x = pnt0[i].x + vx;
		pnt1[i].y = pnt0[i].y + vy;

		pnt1[0] = pnt0[0];
		pnt1[numChars] = pnt0[numChars];
	    }

	    if (bDown)
	    {
		Mouseposition (window, &x, &y, &tmp);
		veloc[bIndex].x = veloc[bIndex].y = 0.0;
		pnt1[bIndex].x = (double) x;
		pnt1[bIndex].y = (double) y;
	    }

	    DrawChars (window, pnt1, font, string, numChars);

	    ptmp = pnt0;	pnt0 = pnt1;	pnt1 = ptmp;
	}

	Inq_events (&event);
	if (event & DELETE_EVENT)
	{
	    int	aWindow;

	    Get_delete_data (&aWindow);
	    break;
	}
	else if (event & REFRESH_EVENT)
	{
	    int	aWindow, aVS;
	    int wx1, wy1, wx2, wy2, rx1, ry1, rx2, ry2;

	    Get_refresh_area_data (&aWindow, &aVS, &wx1, &wy1, &wx2, &wy2,
				   &rx1, &ry1, &rx2, &ry2, &tmp);
	    wWidth = wx2 - wx1 + 1;
	    wHeight = wy2 - wy1 + 1;
	}
	else if (event & BUTTON_EVENT)
	{
	    int	aWindow, button, trans;

	    Get_button_data (&window, &x, &y, &button, &trans, &tmp);
	    if (sampleMode)
	    {
		if (trans == UP)
		{
SampleOff:	    sampleMode = FALSE;
		    numChars = sample - 1;
		    point1[0] = point0[0];
		    point1[numChars] = point0[numChars];
		    pnt0 = point0;
		    pnt1 = point1;
		    bDown = FALSE;
		}
	    }
	    else
	    {
		if ((button == LEFT_BUTTON) && (trans == DOWN))
		{
		    sampleMode = TRUE;
		    sample = 1;
		    point0[0].x = (double) x;
		    point0[0].y = (double) y;
		    fgcolor (window, -1);
		    move (window, x, y);
		    lx = x;
		    ly = y;

		    /** All velocities are zero **/
		    for (i = 0; i < maxPoints; i++)
			veloc[i].x = veloc[i].y = 0.0;

		}
		else if ((trans == DOWN) && (numChars > 0))
		{
		    double dist0, dist1;

		    bDown = TRUE;
		    dist0 = 1.0e37;
		    for (i = 0; i <= numChars; i++)
		    {
			dist1 = (x - pnt1[i].x) * (x - pnt1[i].x) +
				(y - pnt1[i].y) * (y - pnt1[i].y);
			if (dist1 < dist0)
			{
			    bIndex = i;
			    dist0 = dist1;
			}
		    }
		    hidecursor (window);
		}
		else
		{
		    bDown = FALSE;
		    showcursor (window);
		}
	    }
	}
	else if (sampleMode &&
		 (((x - lx) * (x - lx) + (y - ly) * (y - ly)) >= toler2))
	{
	    point0[sample].x = (double) x;
	    point0[sample].y = (double) y;
	    lx = x;
	    ly = y;

	    sample++;
	    if (sample == strLen + 1)
		goto SampleOff;

	    hidecursor (window);
	    draw (window, x, y);
	    showcursor (window);
	    flushbuffer (window);
	}
    }

    free (font);
    free (point0);
    free (point1);
    free (veloc);

Done:
    FSExit ();
    Exit_tools ();
}



DrawChars (window, point, font, string, numChars)
int window;
Point *point;
FontId font[];
char *string;
int numChars;
{
    int i, color, index;

    if (numChars <= 0)
	return;

    if (dbFlag)
	enter_db (vs, 0);
    else
	hidecursor (window);

    weight (window, 0);
    fgcolor (window, 0);
    rectf (window, 0, 0, wWidth - 1, wHeight - 1);

    if (colorFlag)
	color = startColor;
    else
	fgcolor (window, -1);

    for (i = 0; i < numChars; i++)
    {
	if (colorFlag)
	    fgcolor (window, color++);

	move (window, (int) (point[i].x + 0.5), (int) (point[i].y + 0.5));
	draw (window, (int) (point[i + 1].x + 0.5),
		      (int) (point[i + 1].y + 0.5));

	GetSizeRot (&point[i], &point[i + 1], string[i], &index);
	FSDrawChar (window, font[index], string[i],
		    point[i].x, point[i].y, NULL, NULL);
    }

    if (dbFlag)
	exit_db (vs, 0);
    else
	showcursor (window);
}



InitFonts (font, string)
FontId font[];
char *string;
{
    int i, j, n;
    FontId sampFont;
    BmapCharInfo bmapCharInfo;
    OutlCharInfo outlCharInfo;
    RangeSpec *range;

    range = (RangeSpec *) malloc ((strlen (string) + 1) * sizeof (RangeSpec));
    for (i = 0; i < strlen (string); i++)
    {
	range[i].start = (CharId) string[i];
	range[i].count = 1;
    }
    range[i].start = (CharId) -1;

    fontSpec.bodySize = SAMP_SIZE;
    if (!genFlag)
	fontSpec.flags |= FS_DEMAND;
    else
	fontSpec.flags &= ~FS_DEMAND;

    if (FSNewFont (&fontSpec, range, &sampFont) != FS_NO_ERROR)
    {
	printf ("Font not found!\n");
	return (-1);
    }

    for (i = 32; i < 127; i++)
    {
	if (FSGetBmapCharInfo (sampFont, i, &bmapCharInfo) == FS_NO_ERROR)
	    mult[i] = SAMP_SIZE / bmapCharInfo.setWid;
	else if (FSGetOutlCharInfo (sampFont, i, &outlCharInfo) == FS_NO_ERROR)
	    mult[i] = SAMP_SIZE / outlCharInfo.setWid;
    }
    FSDeleteFont (sampFont);

    printf ("Fonts needed: %d\n", sizeDim * rotDim);
    n = 0;
    for (i = fontSizeInc; i <= maxFontSize; i += fontSizeInc)
    {
	fontSpec.bodySize = (double) i;
	for (j = - maxFontRot; j < maxFontRot; j += fontRotInc)
	{
	    fontSpec.rotation = (double) j;
	    if (FSNewFont (&fontSpec, range, &font[INDEX (i, j)]) != FS_NO_ERROR)
	    {
		printf ("Font not found!\n");
		return (-1);
	    }
	    printf ("%d\r", ++n);
	    fflush (stdout);
	}
    }
    printf ("\n");
    free (range);
    return (0);
}
	


GetSizeRot (point0, point1, character, index)
Point *point0, *point1;
char character;
int *index;
{
    double realSize, realRot, dx, dy;
    int intSize, intRot;

    dx = point1->x - point0->x;
    dy = point0->y - point1->y;		/* for convenience */

    realSize = sqrt (dx * dx + dy * dy) * mult[character];
    intSize = (int) (realSize + fontSizeInc/2);
    intSize = DIV (intSize, fontSizeInc) * fontSizeInc;
    if (intSize > maxFontSize)
	intSize = maxFontSize;
    else if (intSize < fontSizeInc)
	intSize = fontSizeInc;

    if (dx != 0.0)
    {
	realRot = atan (dy / dx) / M_PI * 180.0;
	if (dx < 0.0)
	    realRot += 180.0;
    }
    else if (dy > 0.0)
	realRot = 90.0;
    else
	realRot = -90.0;

    intRot = (int) (realRot + fontRotInc/2);
    intRot = DIV (NORM (intRot), fontRotInc) * fontRotInc;
    if (intRot >= maxFontRot)
	intRot = maxFontRot - fontRotInc;
    else if (intRot < -maxFontRot)
	intRot = -maxFontRot;

    *index = INDEX (intSize, intRot);
}
