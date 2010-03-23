/* This program generates a font compatible with those in		*/
/* /usr/ip32/resrc/bsfont.  The typefaces in				*/
/* /usr/ip32/resrc/fontserver/typeface are used as the source for	*/
/* creating the fonts.  For typefaces other than swiss742, dutch801,	*/
/* and mono821, you may have to use 'fchooser' to download the proper	*/
/* typeface.								*/
/* The specified bodysize is not the actual size of the symbol font;	*/
/* it is somewhat smaller due to the fact that the bodysize is defined	*/
/* as the distance from the ascent to the descent line, while the	*/
/* actual maximum height of the bitmaps may be larger.  The new size is	*/
/* printed after the font is created.					*/


#include <stdio.h>
#include <math.h>
#include <FS.h>
#include <FSBmap.h>


FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"dec",		/* DEC multinational */
			FS_DEMAND | FS_NO_KERN | FS_INT_WIDTHS | FS_ALL_BITMAPS
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int i, rval;
    char *symFile;
    double atof ();

    if (argc < 4)
    {
	printf ("Usage:  %s typeface bodysize symfile\n", argv[0]);
	exit (1);
    }

    fontSpec.typeface = argv[1];
    fontSpec.bodySize = atof (argv[2]);
    symFile = argv[3];

    if (argc > 4)
	fontSpec.aspect = atof (argv[4]);

    FSEnter (0);

    if ((rval = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	printf ("Can't create font: %d\n", rval);
	goto DONE;
    }

    /* Adjust the font metrics so that it can be a usable symbol font.	*/
    /* I.e., don't let any bitmaps go off the top or bottom edge.	*/
    {
	int		numChars, tmp, top, bottom;
	BmapInfo	info;
	BmapCharInfo	*charInfo, *cPtr;

	FSGetBmapInfo (font, &info);

	info.ascent = floor (info.ascent + 0.5);
	info.descent = floor (info.descent + 0.5);

	charInfo = NULL;
	FSGetBmapAllCharInfo (font, &charInfo, &numChars);

	bottom = top = 0;
	for (i = 0; i < numChars; i++)
	{
	    cPtr = &charInfo[i];
	    if ((tmp = - (cPtr->vOff + (int) info.descent)) > bottom)
		bottom = tmp;
	    if ((tmp = (cPtr->vOff + cPtr->rHgt) - (int) info.ascent) > top)
		top = tmp;
	}

	info.bodySize += (double) top + bottom;
	info.ascent += (double) top;
	info.descent += (double) bottom;
	FSPutBmapInfo (font, &info);
	printf ("New size: %d\n", (int) info.bodySize);

	free (charInfo);
    }

    FSWriteSymbolFile (font, symFile);
    FSDeleteFont (font);

DONE:
    FSExit ();
    exit (0);
}
