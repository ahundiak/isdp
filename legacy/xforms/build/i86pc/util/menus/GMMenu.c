#include <stdio.h>
/* #include <tools.h> */
#include "FI.h"
#include "FIdyn.h"
#include "MI.h"
#include "GMmenu.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

/******************************************************************************

Doc:	GMWriteMenu

Abstract:
	The GMWriteMenu function writes the I/FORMS files for the menu
	described by the given list of palettes and then deletes the
	list of palettes.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_E_WRITE	-	Error writing file(s) (to correct directory)
	GM_F_WRITE	-	Fatal error writing file(s)
	GM_F_IFORMS	-	Inexplicable I/FORMS error
	GM_F_ALLOC	-	Unable to allocate memory

******************************************************************************/
/* char	             *mnuFile;	** i - Menu file name		*/
/* int	             menuType;	** i - Menu type  (See MI.h)	*/
/* struct GMPalette *palList;	** i - Lined list of palettes	*/
/* FILE	            *errFp;	** i - Opened "stderr" file	*/

int	GMWriteMenu (char              *mnuFile,
                     int               menuType,
                     struct GMPalette *palList,
                     FILE             *errFp)
{
extern	int		errno;
struct	GMPalette	*pal;
Form			palPtr;
int			sts, saveMask;
char			mnuDir[GM_FILENAME_LEN], tmpDir[GM_FILENAME_LEN],
			cmdBuf[512];

	GMParseMenuName( mnuDir, palList->name, mnuFile );

	saveMask = umask( 0 );
	mkdir( tmpnam( tmpDir ), 0777 );	/* This had better work	*/

	pal = palList;
	do
	{
		sts = GMCreateMenuPal( &palPtr, menuType, pal, errFp );
		if ( GM_ERROR( sts ) )
			goto clean_up;

		sts = GMWriteMenuPal( palPtr, tmpDir, pal->name, errFp );
		if ( GM_ERROR( sts ) )
			goto clean_up;

		pal = pal->nextPal;

	} while ( pal );

	sprintf( cmdBuf, "cp %s/* %s", tmpDir, mnuDir );
	sts = system( cmdBuf );
	if ( sts == 0 )
	{
		fprintf( errFp,
			 "Copied palette files to %s\n",
			 mnuDir );
		sprintf( cmdBuf, "rm -rf %s", tmpDir );
		system( cmdBuf );
		sts = GM_S_SUCCESS;
	}
	else
	{
		fprintf( errFp,
			 "System error %d copying palettes to %s\n",
			 ( ( sts < 0 ) ? errno : sts ) );
		sts = GM_E_WRITE;
	}

clean_up:
	GMFreeMenuPal( palList );
	umask( saveMask );

	return( sts );
}

/******************************************************************************

Doc:	GMParseMenuName

Abstract:
	The GMParseMenuName function parses the given menu file name
	into the menu directory and the palette name.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* char	*mnuDir;		** o - Menu directory		*/
/* char	*palName;		** o - Palette name		*/
/* char	*mnuFile;		** i - Menu file name		*/

int	GMParseMenuName (char *mnuDir,
                         char *palName,
                         char *mnuFile)
{
int	len;

	len = strlen( mnuFile );
	while ( len > 0 && mnuFile[len - 1] != '/' )
		len--;

	strncpy( palName, &mnuFile[len], 14 );
	palName[14] = '\0';

	if ( len == 0 )
		strcpy( mnuDir, "." );
	else if ( mnuFile[0] == '/' || mnuFile[0] == '.' )
	{
		len--;
		strncpy( mnuDir, mnuFile, len );
		mnuDir[len] = '\0';
	}
	else
	{
		len--;
		strcpy( mnuDir, "./" );
		strncat( mnuDir, mnuFile, len );
	}

	return( GM_S_SUCCESS );
}

/******************************************************************************

Doc:	GMCreateMenuPal

Abstract:
	The GMCreateMenuPal function creates a menu palette (i.e. a form)
	and populates it with buttons based on the given palette data.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_F_IFORMS	-	Inexplicable I/FORMS error
	GM_F_ALLOC	-	Unable to allocate memory

******************************************************************************/
/* Form		    *palPtr;	** o - Palette's form pointer	*/
/* int		    menuType;	** i - Menu type  (See MI.h)	*/
/* struct GMPalette *pal;       ** i - Menu palette data	*/
/* FILE		    *errFp;	** i - Opened "stderr" file	*/

int	GMCreateMenuPal (Form             *palPtr,
                         int              menuType,
                         struct GMPalette *pal,
                         FILE             *errFp)
{
struct	GMButton	*btn;
int			sts, symIdx, label;

	sts = FIf_new( 0, "", 0, palPtr );
	if ( sts == FI_NO_MEMORY )
		goto alloc_fail;
	else if ( sts != FI_SUCCESS )
		goto other_err;

	/*                                                            */
	/* sml:06-11-92	use FIf_set_Xscreen instead of FIf_set_screen */
	/*                                                            */
	sts = FIf_set_Xscreen( *palPtr, FI_CURRENT_SCRN, 0 );
	sts = FIf_set_location( *palPtr, pal->xPos, pal->yPos );
	sts = FIf_set_orig_size( *palPtr, pal->xSize - 1, pal->ySize - 1 );
	sts = FIf_set_size( *palPtr, pal->xSize - 1, pal->ySize - 1 );
		/* I/FORMS size is (hi - lo) instead of (hi - lo + 1)	*/
	sts = FIf_set_color( *palPtr, FI_MED_GREY );
	sts = FIf_set_attr( *palPtr, FI_NO_BEZEL | FI_LINE_BORDER );

	if ( menuType == PANEL_MENU )
		symIdx = 2;
	else if ( menuType == BAR_MENU )
		symIdx = 1;
	else
		symIdx = 0;
	sts = FIf_set_collapse_symbol( *palPtr, "collapse.icon", symIdx );

	if ( pal->remember )
		sts = FIf_set_start_seq( *palPtr, pal->remember );

	label = 11;
	btn = pal->buttons;
	do
	{
		sts = FIg_new( *palPtr, FI_BUTTON, label );
		if ( sts != FI_SUCCESS )
		{
			FIf_delete( *palPtr );
			if ( sts == FI_NO_MEMORY )
				goto alloc_fail;
			else
				goto other_err;
		}

		sts = FIg_set_standard_variables( *palPtr, label, &btn->std );
		if ( btn->std.attr_mask & FI_TEXT_GADGET )
		{
			sts = FIg_set_text_style( *palPtr, label, btn->textStyle );
			sts = FIg_set_justification( *palPtr, label, btn->textJust );
		}
		sts = FIg_set_pass_data( *palPtr, label, -1 );

		sts = FIbtn_set_menu_status( *palPtr, label, 1 );
		if ( btn->palName[0] )
			sts = FIbtn_set_palette( *palPtr, label, btn->palName );

		label++;
		btn = btn->nextBtn;

	} while ( btn );

	return( FI_SUCCESS );

alloc_fail:
	fprintf( errFp,
		 "Error allocating menu memory\n" );
	return( GM_F_ALLOC );

other_err:
	fprintf( errFp,
		 "I/FORMS sts %d creating palette %s\n",
		 sts, pal->name );
	return( GM_F_IFORMS );
}

/******************************************************************************

Doc:	GMWriteMenuPal

Abstract:
	The GMWriteMenuPal function writes the menu palette file by
	saving the palette (i.e. form) to a temporary location.  This
	function also deletes the form.

Return Status:
	GM_S_SUCCESS	-	Success
	GM_F_WRITE	-	Error writing palette file
	GM_F_IFORMS	-	Inexplicable I/FORMS error

******************************************************************************/
/* Form	palPtr;			** i - Palette's form pointer		*/
/* char	*tmpDir;		** i - Temporary directory for file	*/
/* char	*palName;		** i - Palette's name			*/
/* FILE	*errFp;			** i - Opened "stderr" file		*/

int	GMWriteMenuPal (Form palPtr,
                        char *tmpDir,
                        char *palName,
                        FILE *errFp)
{
int	sts;
char	tmpFile[GM_FILENAME_LEN];

/******************* sml:06-11-92 display menu for debug purposes 
FIf_display(palPtr);
sleep(5);
FIf_erase(palPtr);
********************/

	sprintf( tmpFile, "%s/%s", tmpDir, palName );

	sts = FIf_save( palPtr, tmpFile );
	if ( sts == FI_SUCCESS )
	{
/*******************		Form tmp_form;*******************/
		fprintf( errFp,
			 "Created palette file %s\n",
			 palName );
		sts = GM_S_SUCCESS;

/******************* sml:06-11-92 display menu for debug purposes 
FIf_display(palPtr);
sleep(5);
FIf_erase(palPtr);

FIf_new(222, tmpFile, 0, &tmp_form);
FIf_display(palPtr);
sleep(5);
FIf_erase(palPtr);
********************/
	}
	else if ( sts == FI_FORM_FILE_OPEN_DENIED )
	{
		fprintf( errFp,
			 "Unable to create palette file %s\n",
			 tmpFile );
		sts = GM_F_WRITE;
	}
	else
	{
		fprintf( errFp,
			 "I/FORMS sts %d saving palette %s\n",
			 sts, tmpFile );
		sts = GM_F_IFORMS;
	}

	FIf_delete( palPtr );
	return( sts );
}

/******************************************************************************

Doc:	GMFreeMenuPal

Abstract:
	The GMFreeMenuPal function fress the space allocated for the
	linked list of menu palettes.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* struct GMPalette *palList;     ** i - Linked list of palettes */

int	GMFreeMenuPal (struct GMPalette *palList)
{
struct	GMPalette	*pal, *nextPal;
struct	GMButton	*btn, *nextBtn;

	pal = palList;
	do
	{
		nextPal = pal->nextPal;

		if ( pal->buttons )
		{
			btn = pal->buttons;
			do
			{
				nextBtn = btn->nextBtn;
				GMFreeMenuBtn( btn );
				btn = nextBtn;
			} while ( btn );
		}

		free( pal );
		pal = nextPal;

	} while ( pal );

	return( GM_S_SUCCESS );
}

/******************************************************************************

Doc:	GMFreeMenuBtn

Abstract:
	The GMFreeMenuBtn function frees the space allocated for a
	menu button.

Return Status:
	GM_S_SUCCESS	-	Success

******************************************************************************/
/* struct GMButton *btn;    ** i - Menu button  */

int	GMFreeMenuBtn (struct GMButton *btn)
{
	if ( btn->std.text )
		free( btn->std.text );
	if ( btn->std.help_topic )
		free( btn->std.help_topic );
	if ( btn->std.command )
		free( btn->std.command );
	if ( btn->std.fontname )
		free( btn->std.fontname );
	free( btn );

	return( GM_S_SUCCESS );
}
