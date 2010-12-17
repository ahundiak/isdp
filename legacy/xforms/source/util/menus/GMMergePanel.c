#include <malloc.h>
#include <stdio.h>
/* #include <tools.h> */
#include "FI.h"
#include "FIdyn.h"
#include "GMmenu.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

/*
struct	GMButtonList
{
  int	 numBtn;
  int	 numAlloc;
  int	*btnLabel;
};
*/

extern int panelPalHeight;	/* command line-specified panel height */
extern int panelPalWidth;	/* command line-specified panel width */

/**********************************************************************

Doc:	GMMergePanels

Abstract:
	The GMMergePanels function generates the palette list (actually
	a single palette) for the merged panel menu from the given list
	of panel menus.

Return Status:
	GM_S_SUCCESS	-  Success
	GM_F_MENU	-  Menu file not found
			   Menu file cannot be read
			   No buttons on merged menu (shouldn't happen)
	GM_F_IFORMS	-  Inexplicable I/FORMS error
	GM_F_ALLOC	-  Unable to allocate memory

**********************************************************************/
/*  struct GMPalette  **palList;    ** o - Pointer to new palette  */
/*  char	      *menuList[];  ** i - Panel menus to merge    */
/*  int               numMenu;      ** i - Number of menus in list */
/*  FILE              *errFp;	    ** i - Opened "stderr" file    */

int GMMergePanels (struct GMPalette  **palList,
                   char              *menuList[],
                   int               numMenu,
                   FILE              *errFp)
{
#define	PANEL_PAL_WIDTH		180
#define	PANEL_PAL_HEIGHT	830
#define	PANEL_NUM_COLUMN1	4
#define	PANEL_BTN_WIDTH1	45
#define	PANEL_BTN_HEIGHT1	35
#define	BORDER_WIDTH		3

  extern void			GMGenBtnList();
  extern struct	GMButton	*GMCopyButton();

  struct GMPalette	*pal;
  struct GMButton	*curBtn, *prevBtn;
  struct GMButtonList	btnList;
  Form			pnlPtr;
  int			numColumn = 1, btnWidth, btnHeight;
  int			sts, num, numBtn, totBtn;


  btnList.numAlloc = 0;
  btnList.btnLabel = ( int * )0;

  pal = (struct GMPalette * ) 0;
  totBtn = 0;
  prevBtn = (struct GMButton *)0;

  for ( num = 0; num < numMenu; num++ )
    {
      sts = FIf_new( 0, menuList[num], 0, &pnlPtr );
      if ( sts == FI_NO_MEMORY )
	{
	  goto alloc_fail;
	}
      else if ( sts == FI_FORM_FILE_NOT_FOUND	||
		sts == FI_FORM_FILE_READ_ERROR	 )
	{
	  fprintf( errFp, "Unable to read %s\n", menuList[num] );
	  sts = GM_F_MENU;
	  goto error_ret;
	}
      else if ( sts != FI_SUCCESS )
	{
	  fprintf( errFp, "I/FORMS error %d initializing %s\n",
		 sts, menuList[num] );
	  sts = GM_F_IFORMS;
	  goto error_ret;
	}

      btnList.numBtn = 0;
      FIgrp_callback( pnlPtr, FI_FORM_GROUP, (int (*)())GMGenBtnList, (int)&btnList );

      if ( ! pal )
	{
	  pal = (struct GMPalette *) calloc( 1,
				sizeof( struct GMPalette ) );
	  if ( ! pal )
	    {
	      goto alloc_fail;
	    }

	  sts = FIf_get_location( pnlPtr, &pal->xPos, &pal->yPos );

		/************************************************/
		/* sml:10-14-94:TR 249406896                    */
		/*  check if command line options for panel's   */
		/*  width and height were specified.            */
		/************************************************/

	  if (panelPalWidth > 0)
	  {
		pal->xSize = 2 * BORDER_WIDTH + panelPalWidth;
	  }
	  else
	  {
		pal->xSize = 2 * BORDER_WIDTH + PANEL_PAL_WIDTH;
	  }

	  if (panelPalHeight > 0)
	  {
		pal->ySize = panelPalHeight;
	  }
	  else
	  {
		pal->ySize = PANEL_PAL_HEIGHT;
	  }

	  pal->remember = 0;

	  if ( btnList.numBtn )
	    {
	      sts = FIg_get_size( pnlPtr, btnList.btnLabel[0],
				    &btnWidth, &btnHeight );
	      btnWidth++;	/* I/FORMS size is (hi - lo) */
	      btnHeight++;	/* instead of (hi - lo + 1) */
	      numColumn = PANEL_PAL_WIDTH / btnWidth;
	    }
	  else
	    {
	      numColumn = PANEL_NUM_COLUMN1;
	      btnWidth = PANEL_BTN_WIDTH1;
	      btnHeight = PANEL_BTN_HEIGHT1;
	    }
	}

      for ( numBtn = 0; numBtn < btnList.numBtn; numBtn++ )
	{
	  curBtn = GMCopyButton( (Form *)pnlPtr, btnList.btnLabel[numBtn] );
	  if ( ! curBtn )
	    {
	      goto alloc_fail;
	    }

	  if ( prevBtn )
	    {
	      prevBtn->nextBtn = curBtn;
	    }
	  else
	    {
	      pal->buttons = curBtn;
	    }

	  curBtn->std.xlo = BORDER_WIDTH +
				( totBtn % numColumn ) * btnWidth;

	  curBtn->std.ylo = BORDER_WIDTH +
				( totBtn / numColumn ) * btnHeight;

	  curBtn->std.xhi = curBtn->std.xlo + btnWidth - 1;
	  curBtn->std.yhi = curBtn->std.ylo + btnHeight - 1;

	  totBtn++;
	  prevBtn = curBtn;
	}

      sts = FIf_delete ( pnlPtr );
    }

  if ( totBtn == 0 )
    {
	fprintf ( errFp, "No buttons on merged panel menu\n" );
	sts = GM_F_MENU;
	goto error_ret;
    }

  if ( btnList.btnLabel )
    {
	free ( btnList.btnLabel );
    }

  *palList = pal;

  return( GM_S_SUCCESS );

alloc_fail:

  sts = GM_F_ALLOC;
  fprintf( errFp, "Unable to allocate memory\n" );

error_ret:
  if ( pal )
    {
	GMFreeMenuPal ( pal );
    }

  if ( btnList.btnLabel )
    {
	free ( btnList.btnLabel );
    }

  return( sts );
}

/**********************************************************************

Doc:	GMGenBtnList

Abstract:
	The GMGenBtnList function generates a list of the gadget labels
	for the buttons in the first palette of a panel menu.

**********************************************************************/
/* Form			pnlPtr;     ** i - Pointer to panel menu   */
/* int			label;	    ** i - Gadget label for button */
/* struct GMButtonList	*btnList;   ** i/o - Button label list     */

/* ARGSUSED */
void GMGenBtnList (Form                 pnlPtr,
                  int                  label,
                  struct GMButtonList  *btnList)
{
  unsigned	bufSize;

  if ( btnList->numBtn == btnList->numAlloc )
    {
	btnList->numAlloc += 5;
	bufSize = btnList->numAlloc * sizeof( int );
	btnList->btnLabel = ( btnList->btnLabel ) ?
			( int * )realloc( btnList->btnLabel, bufSize ) :
			( int * )malloc( bufSize );
    }

  btnList->btnLabel[ btnList->numBtn++ ] = label;
}

/**********************************************************************

Doc:	GMCopyButton

Abstract:
	The GMCopyButton function generate a new button for the merged
	panel menu by copying the given button.

Notes:
	GMCopyButton uses calloc() instead of malloc(); therefore, any
	value not explicitly set is 0.

Return Values:
	Pointer to the new button
	0  (Error allocating memory)

**********************************************************************/
/* Form	*pnlPtr;    ** i - Pointer to panel menu form      */
/* int	label;	    ** i - Gadget label of button to copy  */

struct GMButton *GMCopyButton (Form *pnlPtr,
                               int  label)
{
  struct GMButton	*newBtn;
  int			 value;

  newBtn = ( struct GMButton * )calloc( 1, sizeof( struct GMButton ) );
  if ( ! newBtn )
    {
	return( newBtn );
    }

  FIg_get_attr( (Form)pnlPtr, label, (int *)&newBtn->std.attr_mask );

  if ( newBtn->std.attr_mask & FI_TEXT_GADGET )
    {
      FIg_get_text_length( (Form)pnlPtr, label, &value );
      newBtn->std.text = malloc( value + 1 );
      if ( newBtn->std.text )
	{
	  FIg_get_text( (Form)pnlPtr, label, newBtn->std.text );
	}
      else
	{
	  goto alloc_fail;
	}

      newBtn->std.fontname = malloc( 16 );
      if ( newBtn->std.fontname )
	{
	  FIg_get_font( (Form)pnlPtr, label, newBtn->std.fontname,
					    &newBtn->std.bodysize );
	}
      else
	{
	  goto alloc_fail;
	}

      FIg_get_text_style( (Form)pnlPtr, label, &newBtn->textStyle );
      FIg_get_justification( (Form)pnlPtr, label, &newBtn->textJust );

      if (	newBtn->textStyle == FI_NORMAL_TEXT	||
		newBtn->textStyle == FI_SHADOWED	 )
	{
	  FIg_get_off_color( (Form)pnlPtr, label, &value );
	  newBtn->std.off_color = value;
	  FIg_get_on_color( (Form)pnlPtr, label, &value );
	  newBtn->std.on_color = value;
	}
      else if ( newBtn->textStyle == FI_EMBOSSED )
	{
	  newBtn->std.off_color = FI_BLACK;
	  newBtn->std.on_color = FI_WHITE;
	}
      else
	{
	  newBtn->std.off_color = FI_WHITE;
	  newBtn->std.on_color = FI_BLACK;
	}
    }
  else
    {
      newBtn->std.fontname = malloc( 16 );
      if ( newBtn->std.fontname )
	{
	  FIg_get_symbol_file ( (Form)pnlPtr, label, newBtn->std.fontname );
	}
      else
	{
	  goto alloc_fail;
	}

      FIg_get_off_symbol_index( (Form)pnlPtr, label, &value );
      newBtn->std.symbol_index = value;
      FIg_get_off_color( (Form)pnlPtr, label, &value );
      newBtn->std.off_color = value;
      FIg_get_on_color( (Form)pnlPtr, label, &value );
      newBtn->std.on_color = value;
      FIg_get_on_symbol_index( (Form)pnlPtr, label, &value );
      if ( value != 0 )
	{
	  newBtn->std.symbol_index2 = value;
	  FIg_get_off_color2( (Form)pnlPtr, label, &value );
	  newBtn->std.off_color2 = value;
	  FIg_get_on_color2( (Form)pnlPtr, label, &value );
	  newBtn->std.on_color2 = value;
	}
    }

  if ( newBtn->std.attr_mask & FI_HELP_TOPIC )
    {
      FIg_get_help_topic_length( (Form)pnlPtr, label, &value );
      newBtn->std.help_topic = malloc( value + 1 );
      if ( newBtn->std.help_topic )
	{
	  FIg_get_help_topic ( (Form)pnlPtr, label,
			newBtn->std.help_topic );
	}
      else
	{
	  goto alloc_fail;
	}
    }

  if (  newBtn->std.attr_mask & FI_CMD_KEY	||
	newBtn->std.attr_mask & FI_CMD_STRING	 )
    {
      FIg_get_command_length ( (Form)pnlPtr, label, &value );
      newBtn->std.command = malloc( value + 1 );

      if ( newBtn->std.command )
	{
	  FIg_get_command( (Form)pnlPtr, label, newBtn->std.command );
	}
      else
	{
	  goto alloc_fail;
	}
    }

  FIbtn_get_palette( (Form)pnlPtr, label, newBtn->palName );

  return ( newBtn );

alloc_fail:

  GMFreeMenuBtn( newBtn );
  return( (struct GMButton *) 0 );
}
