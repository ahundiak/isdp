#include <sys/types.h>
#include <string.h>
#include <stdio.h>
/* #include <tools.h> */
#include "FI.h"
#include "FIdyn.h"
#include "GMmenu.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

/******************************************************************************

Doc:	GMPrintDesc

Abstract:
	The GMPrintDesc function prints a description of the menu to stdout.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* char             *mnuFile;  ** i - Menu file name		*/
/* int              menuType;  ** i - Menu type  (See MI.h)	*/
/* struct GMPalette *palList;  ** i - Linked list of palettes	*/

int	GMPrintDesc (char             *mnuFile,
                     int              menuType,
                     struct GMPalette *palList)
{
static	char		*typeNames[]={ "Bar", "Panel", "Pocket" };
static	char		*colorNames[]={
				"off white",	"med grey",	"black",
				"yellow",	"lt grey",	"dk grey",
				"white",	"red",		"green",
				"blue",		"lt yellow",	"dk red",
				"dk green",	"dk blue" };
static	char		*styleNames[]={
				"normal", "embossed", "incised", "shadowed" };
static	char		*justNames[]={
				"left", "right", "center" };

struct	GMPalette	*pal;
struct	GMButton	*btn;
char			*p, buf[512];

	pal = palList;
	do
	{
		if ( pal == palList )
		{
			printf( "\n%s menu : %s\n", typeNames[menuType], mnuFile );
			printf( "Origin : %4d, %-4d\nSize : %4d, %-4d\n",
				pal->xPos, pal->yPos, pal->xSize, pal->ySize );
		}
		else
		{
			printf( "\nPalette : %s\n", pal->name );
			printf( "Origin : %4d, %-4d\nSize : %4d, %-4d\n",
				pal->xPos, pal->yPos, pal->xSize, pal->ySize );
			printf( "Remember selection : %s\n",
				( ( pal->remember ) ? "Yes" : "No" ) );
		}

		btn = pal->buttons;
		do
		{
			printf( "\n" );
			if ( btn->std.attr_mask & FI_TEXT_GADGET )
			{
				strcpy( buf, btn->std.text );
				p = strtok( buf, "\n" );
				printf( "    \"%s", p );
				while ( ( p = strtok( NULL, "\n" ) ) != NULL )
					printf( "\\n%s", p );
				printf( "\"\n" );
				printf( "    %-16s size %-4g %8s text %6s justified",
					btn->std.fontname,
					btn->std.bodysize,
					styleNames[btn->textStyle],
					justNames[btn->textJust] );
				if ( btn->textStyle == FI_NORMAL_TEXT ||
				     btn->textStyle == FI_SHADOWED )
					printf( " %9s/%-9s\n",
						colorNames[btn->std.off_color],
						colorNames[btn->std.on_color] );
				else
					printf( "\n" );
			}
			else
			{
				printf( "    %-16s %3d %9s/%-9s",
					btn->std.fontname,
					btn->std.symbol_index,
					colorNames[btn->std.off_color],
					colorNames[btn->std.on_color] );
				if ( btn->std.symbol_index2 )
					printf( " %3d %9s/%-9s\n",
						btn->std.symbol_index2,
						colorNames[btn->std.off_color2],
						colorNames[btn->std.on_color2] );
				else
					printf( "\n" );
			}

			printf( "\tCoordinates : %4d, %-4d  %4d, %-4d\n",
				btn->std.xlo, btn->std.ylo,
				btn->std.xhi, btn->std.yhi );

			if ( btn->palName[0] )
				printf( "\tPAL  : %s\n",
					btn->palName );
			if ( btn->std.attr_mask & FI_CMD_KEY )
				printf( "\tCMD  : %s\n",
					btn->std.command );
			if ( btn->std.attr_mask & FI_CMD_STRING )
				printf( "\tCMD  : \"%s\"\n",
					btn->std.command );
			if ( btn->std.attr_mask & FI_HELP_TOPIC )
				printf( "\tHELP : %s\n",
					btn->std.help_topic );

			btn = btn->nextBtn;

		} while ( btn );

		pal = pal->nextPal;

	} while ( pal );

	printf( "\n" );

	return( GM_S_SUCCESS );
}
