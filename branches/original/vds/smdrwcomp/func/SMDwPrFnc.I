/* $Id: SMDwPrFnc.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwcomp/func / SMDwPrFnc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMDwPrFnc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/13  21:45:10  pinnacle
# Replaced: smdrwcomp/func/SMDwPrFnc.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/09/26  20:47:28  pinnacle
# Replaced: smdrwcomp/func/SMDwPrFnc.I for:  by sundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation Root;

/****************************************************************************
  Filename:	SMDwPrFnc.I

  Description:
	This file contains functions which are used by form_notification
  of "Define Compartment Drawing Parameters (SMCompDwPr.sl)" command.

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "madef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#inclue  "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "gotextdef.h"
#include "FI.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "adpdef.h"
#include "dpmacros.h"
#include "dperr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#include "SMDwDef.h"
#include "SMDwPrDef.h"
#include "SMmsg.h"

#define SM_STR_LEN	24

/****************************************************************************
  Function name:	SMget_level

  Description:
	This function gets the name and no. of a level  given the either level
  no. or name. The level should always be input as string. It also checks
  if the given level is valid or not.

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int SMget_level( msg, level_inp, level_name, level_no)
long	*msg;		/* return status [O] */
char	level_inp[];	/* input level	 [I] */
char	level_name[];	/* level name	 [O] */
short	*level_no;	/* level no.	 [O] */
{
struct GRid	mod_obj;
char		temp_text[SM_STR_LEN];
IGRlong		buffersize, sts;
int		num_levels;

     *msg = 1;
     strcpy( temp_text, level_inp);
     sts = ex$get_cur_mod ( id = &mod_obj.objid, osnum = &mod_obj.osnum );
     if ( !(sts&1) )
     { *msg = 2;  goto wrapup; }

     if ( isalpha (level_inp[0]) )
     { /* level name is input */
       sts = dp$levels_name_to_number(msg = msg,
                                name = level_inp,
                                number = level_no,
                                mod_objid = mod_obj.objid,
                                osnum = mod_obj.osnum);

       if ( !(sts&1) ) goto wrapup;
       if ( !(*msg&1) ) goto wrapup;
       strcpy( level_name, level_inp);
     }
     else
     { /* level no. is input */
       *level_no = atoi ( level_inp );
       buffersize = SM_STR_LEN;
       sts = dp$levels_number_to_name(msg       = msg,
                           name      = temp_text,
                           number    = *level_no,
                           ret_num_lev = &num_levels,
                           size_name_buffer = &buffersize,
                           mod_objid = mod_obj.objid,
                           osnum     = mod_obj.osnum);
       if ( !(sts&1) ) goto wrapup;
       if ( !(*msg&1) ) goto wrapup;
     }

     if ( *level_no < GR_LO_LAYER || *level_no > GR_HI_LAYER )
	goto wrapup;

     if ( !strncmp(temp_text,"all",3) )
	sprintf(level_name,"%hd", *level_no);
     else
	strcpy( level_name, temp_text );

      return 1;

wrapup:
      return 0;
}

/****************************************************************************
  Function name:	SMget_color

  Description:
	This function gets the color text and color no. given the either color
  no. or color text. The color should always be input as string. It also checks
  if the given color is valid or not.

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int SMget_color( msg, color_inp, color_name, color_no)
long	*msg;		/* return status [O] */
char	color_inp[];	/* color	 [I] */
char	color_name[];	/* color_name	 [O] */
short	*color_no;	/* color no.	 [O] */
{
struct GRid	mod_obj;
long		sts;

     *msg = 1;
     sts = ex$get_cur_mod ( id = &mod_obj.objid, osnum = &mod_obj.osnum );
     if ( !(sts&1) )
     { *msg = 2;  goto wrapup; }

     if ( isalpha (color_inp[0]) )
     { /* color text is input	*/
       sts = ige$get_color_from_name(	name = color_inp,
				color = color_no,
				mod_id = mod_obj.objid,
				mod_osnum = mod_obj.osnum );
       if ( !(sts&1) )
	{ *msg = 3; goto wrapup; }
       strcpy( color_name, color_inp );
     }
     else
     { /* color no. is input	*/
       *color_no = atoi ( color_inp );
       sts = ige$get_name_from_color( color = *color_no,
				name = color_name,
				mod_id = mod_obj.objid,
				mod_osnum = mod_obj.osnum );
       if ( !(sts&1) )
          if( *color_no < GR_LO_COLOR || *color_no > GR_HI_COLOR )
	  { *msg = 4; goto wrapup; }
	  else
	    sprintf(color_name,"%hd",*color_no);
     }

     return 1;

wrapup:
    return 0;
}

/****************************************************************************
  Function name:	SMCompSetSymb

  Description:
	This function sets the symbology in the form for a given object.
      
  Return status :	1 - Success
			0 - Failure

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/

int SMCompSetSymb ( Fp, Symb, VObject)
Form		Fp;			/* [I] form pointer	*/
struct SMDwSymb	Symb;			/* [I] Symbology to set */
int		VObject;			/* [I] graphic object name */
{

char  	LvOpt, ClOpt, WtOpt, StOpt;
IGRchar JustTxt[SM_STR_LEN], temp_text[SM_STR_LEN], level_name[SM_STR_LEN],
	color_name[SM_STR_LEN];
int	status;
short   level_no, color_no;
long	msg;
struct GRdpb_text_symb 	text_symb;
IGRlong                 sizebuf, nret;



/* ------------------------------------------------------------------------
 * Set level option
 */
   LvOpt = (Symb.options & SMDWLVUSR) ? SM_USER :
		 ((Symb.options & SMDWLVACT) ? SM_ACTIVE : SM_OBJECT ); 
   FIfld_set_select(Fp, SM_LV_OPT, (int)LvOpt,0,0);
   if ( LvOpt == SM_USER )
   { /* get the name of the layer, if any */
     sprintf( temp_text, "%hd", Symb.symb.level );
     status = SMget_level( &msg, temp_text, level_name, &level_no );
     if ( !(status&1) ) goto wrapup;

     FIfld_set_text( Fp, SM_LV_FLD, 0, 0, level_name, 0 );
     FIg_display( Fp, SM_LV_FLD);
   }
   else
	FIg_erase( Fp, SM_LV_FLD);

/* ------------------------------------------------------------------------
 * Set color option
 */
   ClOpt = (Symb.options & SMDWCLUSR) ? SM_USER :
		 ((Symb.options & SMDWCLACT) ? SM_ACTIVE : SM_OBJECT ); 
   FIfld_set_select(Fp, SM_CL_OPT, (int)ClOpt,0,0);
   if ( ClOpt == SM_USER )
   { /* get the name of the color */
     sprintf(temp_text,"%hd",Symb.symb.display_attr.color);
     status = SMget_color( &msg, temp_text, color_name, &color_no );
     if ( !(status&1) ) goto wrapup;

     FIfld_set_text( Fp, SM_CL_FLD, 0, 0, color_name, 0 );
     FIg_display( Fp, SM_CL_FLD);
   }
   else
	FIg_erase( Fp, SM_CL_FLD);

/* ------------------------------------------------------------------------
 * Set weight option
 */
   WtOpt = (Symb.options & SMDWWTUSR) ? SM_USER :
		 ((Symb.options & SMDWWTACT) ? SM_ACTIVE : SM_OBJECT ); 
   FIfld_set_select(Fp, SM_WT_OPT, (int)WtOpt,0,0);
   if ( WtOpt == SM_USER )
   {    FIfld_set_value( Fp, SM_WT_FLD, 0, 0, (double)Symb.symb.display_attr.weight, 0 );
	FIg_display( Fp, SM_WT_FLD);
   }
   else
	FIg_erase( Fp, SM_WT_FLD);

/* ------------------------------------------------------------------------
 * Set style option
 */
   StOpt = (Symb.options & SMDWSTUSR) ? SM_USER :
		 ((Symb.options & SMDWSTACT) ? SM_ACTIVE : SM_OBJECT );
   FIfld_set_select(Fp, SM_ST_OPT, (int)StOpt,0,0);
   if ( StOpt == SM_USER )
   {    FIfld_set_value( Fp, SM_ST_FLD, 0, 0, (double)Symb.symb.display_attr.style, 0 );
	FIg_display( Fp, SM_ST_FLD);
   }
   else
	FIg_erase( Fp, SM_ST_FLD);

/* ------------------------------------------------------------------------
 * Set justification and title attribute
 */
   if ( VObject == SM_NAME )
   {
      SMVA_display( Fp, 4, SM_JUST_TXT, SM_JUST_FLD, SM_ATTR_TXT, SM_ATTR_FLD );
      if ( Symb.options & SMDWTXACT )
      {
        sizebuf = sizeof(text_symb);
        gr$get_text_symb(msg    = &msg,
                     sizbuf = &sizebuf,
                     buffer = &text_symb,
                     nret   = &nret);
        status = SMjustif_func(SM_GET_TEXT,JustTxt,(short *)&(text_symb.Active_just));
        FIfld_set_text(Fp, SM_JUST_FLD, 0, 0, JustTxt, 0);
      }
      else
      {
        status = SMjustif_func( SM_GET_TEXT, JustTxt, &(Symb.TextJust) );
        FIfld_set_text( Fp, SM_JUST_FLD, 0, 0, JustTxt, 0 );
      }

      if ( Symb.AttName[0] != '\0' )
	FIfld_set_text( Fp, SM_ATTR_FLD, 0, 0, Symb.AttName, 0 );
   }

   return 1;

wrapup:
   return 0;
}

/****************************************************************************
  Function name:	SMform_notif_lv

  Description:
	This function is invoked when level option is clicked

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/

int   SMform_notif_lv( Fp, Symb )
Form	Fp;			/* [I] form_pointer	*/
struct  SMDwSymb    *Symb;	/* [I] Symbology of the object	*/

{

int	opt, pos;
IGRlong		msg, sts;
IGRchar		temp_text[SM_STR_LEN], level_name[SM_STR_LEN], msg_buff[81];
short		level_no;

     FIfld_get_active_row( Fp, SM_LV_OPT, &opt, &pos );
     switch ( opt )
     {
        case SM_USER :
           Symb->options = ( Symb->options & ~0xF0 ) | SMDWLVUSR;
	   FIg_display ( Fp, SM_LV_FLD );
	   /* get the name of the layer */
	   sprintf( temp_text, "%hd", Symb->symb.level);
	   sts = SMget_level ( &msg, temp_text, level_name, &level_no);
	   if ( !(sts&1) ) goto wrapup;
	   FIfld_set_text ( Fp, SM_LV_FLD, 0, 0, level_name, 0);
	   break; 

        case SM_ACTIVE :
           Symb->options = (Symb->options & ~0xF0 ) | SMDWLVACT;
	   FIg_erase ( Fp, SM_LV_FLD );
           break;

        case SM_OBJECT :
           Symb->options = ( Symb->options & ~0xF0) | SMDWLVOBJ;
	   FIg_erase ( Fp, SM_LV_FLD );
           break;
     }
   return 1;

wrapup:
   ex$message ( msgnumb = SM_E_ErDfLv, buff = msg_buff );
   FIg_set_text ( Fp, FI_MSG_FIELD, msg_buff );
   return 0;
}

/****************************************************************************
  Function name:	SMform_notif_cl

  Description:
	This function is invoked when color option is clicked

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int   SMform_notif_cl( Fp, Symb )
Form	Fp;			/* [I] form_pointer	*/
struct  SMDwSymb    *Symb;	/* [I] Symbology of the object	*/

{

int	opt, pos, sts;
IGRchar	temp_text[SM_STR_LEN], color_name[SM_STR_LEN], msg_buff[81];
short	color_no;
long	msg;

     FIfld_get_active_row( Fp, SM_CL_OPT, &opt, &pos );
     switch ( opt )
     {
        case SM_USER :
           Symb->options = ( Symb->options & ~0xF ) | SMDWCLUSR;
	   FIg_display ( Fp, SM_CL_FLD );
	   sprintf(temp_text,"%hd",Symb->symb.display_attr.color);
	   /* get the name of the color, if any */
	   sts = SMget_color( &msg, temp_text, color_name, &color_no );
	   if ( !(sts&1) ) goto wrapup;

           FIfld_set_text( Fp, SM_CL_FLD, 0, 0, color_name, 0 );

           break; 

        case SM_ACTIVE :
           Symb->options = ( Symb->options & ~0xF ) | SMDWCLACT;
	   FIg_erase ( Fp, SM_CL_FLD );
           break;

        case SM_OBJECT :
           Symb->options = ( Symb->options & ~0xF ) | SMDWCLOBJ;
	   FIg_erase ( Fp, SM_CL_FLD );
           break;
     }
   return 1;

wrapup:
   ex$message ( msgnumb = SM_E_ErDfCl, buff = msg_buff );
   FIg_set_text ( Fp, FI_MSG_FIELD, msg_buff );
   return 0;
}

/****************************************************************************
  Function name:	SMform_notif_wt

  Description:
	This function is invoked when weight option is clicked

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int   SMform_notif_wt( Fp, Symb )
Form	Fp;			/* [I] form_pointer	*/
struct  SMDwSymb    *Symb;	/* [I] Symbology of the object	*/

{

int	opt, pos;


     FIfld_get_active_row( Fp, SM_WT_OPT, &opt, &pos );
     switch ( opt )
     {
        case SM_USER :
           Symb->options = ( Symb->options & ~0xF00 ) | SMDWWTUSR;
	   FIfld_set_value ( Fp, SM_WT_FLD, 0, 0, 
			(double) Symb->symb.display_attr.weight, 0);
	   FIg_display ( Fp, SM_WT_FLD );
           break; 

        case SM_ACTIVE :
           Symb->options = (Symb->options & ~0xF00 ) | SMDWWTACT;
	   FIg_erase ( Fp, SM_WT_FLD );
           break;

        case SM_OBJECT :
           Symb->options = ( Symb->options & ~0xF00) | SMDWWTOBJ;
	   FIg_erase ( Fp, SM_WT_FLD );
           break;
     }
   return 1;
}

/****************************************************************************
  Function name:	SMform_notif_st

  Description:
	This function is invoked when style option is clicked

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int   SMform_notif_st( Fp, Symb )
Form	Fp;			/* [I] form_pointer	*/
struct  SMDwSymb    *Symb;	/* [I] Symbology of the object	*/

{

int	opt, pos;


     FIfld_get_active_row( Fp, SM_ST_OPT, &opt, &pos );
     switch ( opt )
     {
        case SM_USER :
           Symb->options = ( Symb->options & ~0xF000 ) | SMDWSTUSR;
	   FIfld_set_value ( Fp, SM_ST_FLD, 0, 0, 
			(double) Symb->symb.display_attr.style, 0);
	   FIg_display ( Fp, SM_ST_FLD );
           break; 

        case SM_ACTIVE :
           Symb->options = ( Symb->options & ~0xF000 ) | SMDWSTACT;
	   FIg_erase ( Fp, SM_ST_FLD );
           break;

        case SM_OBJECT :
           Symb->options = ( Symb->options & ~0xF000 ) | SMDWSTOBJ;
	   FIg_erase ( Fp, SM_ST_FLD );
           break;
     }
   return 1;
}

/****************************************************************************
  Function name:	SMjustif_func

  Description:
	This function returns 
		. justification text given its no., or, 
                . its no. given the text

  History:
  10 Jun 1993    Raju		Creation

 ****************************************************************************/
int SMjustif_func( opt, JustTxt, TxtNo)
int		opt;	   /* [I] = SM_GET_TEXTNO, return no., given the justif text,
				  = SM_GET_TEXT, return text, given the no. */
char		JustTxt[]; /* [I/O] Justif text */
short		*TxtNo;	   /* [I/O] Justif text number */
{
  int ii;
  static char *name_justif[] =
   {"LEFT_BOTTOM","LEFT_BASE","LEFT_CENTER","LEFT_CAP","LEFT_TOP",
    "CENTER_BOTTOM","CENTER_BASE","CENTER_CENTER","CENTER_CAP","CENTER_TOP",
    "RIGHT_BOTTOM","RIGHT_BASE","RIGHT_CENTER","RIGHT_CAP","RIGHT_TOP"};
  static short symb_justif[] =
    {LEFT_BOTTOM,LEFT_BASE,LEFT_CENTER,LEFT_CAP,LEFT_TOP,
    CENTER_BOTTOM,CENTER_BASE,CENTER_CENTER,CENTER_CAP,CENTER_TOP,
    RIGHT_BOTTOM,RIGHT_BASE,RIGHT_CENTER,RIGHT_CAP,RIGHT_TOP};


  if ( opt == SM_GET_TEXTNO && JustTxt[0] == '\0' ) return 0;

  if ( opt == SM_GET_TEXTNO )
  {
     /* text given, get no. */
     for( ii = 0; ii < 15; ii++)
        if(strncmp(JustTxt,name_justif[ii],strlen(name_justif[ii])) == 0)
	{  *TxtNo = symb_justif[ii];
	   return 1;
	}
  }

  if ( opt == SM_GET_TEXT )
  {
     /* no. given, get text */
     for( ii = 0; ii < 15; ii++)
        if( *TxtNo == symb_justif[ii] )
	{ strcpy( JustTxt, name_justif[ii] );
	  return 1;
	}
   }

   return 0;
}

/****************************************************************************
  Function name:	SMform_notif_lv_fld

  Description:
	This function is invoked when level field is clicked

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int   SMform_notif_lv_fld( Fp, Symb )
Form	Fp;			/* [I] form_pointer	*/
struct  SMDwSymb    *Symb;	/* [I] Symbology of the object	*/
{
IGRchar		temp_text[SM_STR_LEN], level_name[SM_STR_LEN], msg_buff[81];
int		sel_flag, r_pos;
short		level_no;
IGRlong		msg, sts;

     FIfld_get_text( Fp, SM_LV_FLD, 0, 0, SM_STR_LEN, temp_text, &sel_flag, &r_pos );
     if ( temp_text[0] == '\0' ) return 1;
     sts = SMget_level ( &msg, temp_text, level_name, &level_no );
     if ( !(sts&1) ) goto wrapup;

     FIfld_set_text( Fp, SM_LV_FLD, 0, 0, level_name, 0 );
     Symb->symb.level = level_no;

  return 1;

wrapup:
  ex$message ( msgnumb = SM_E_ErDfLv, buff = msg_buff );
  FIg_set_text ( Fp, FI_MSG_FIELD, msg_buff );
  return 0;
}

/****************************************************************************
  Function name:	SMform_notif_cl_fld

  Description:
	This function is invoked when color field is clicked

  History:
  10 Jun 1993    Raju		Creation
 
 ****************************************************************************/
int   SMform_notif_cl_fld( Fp, Symb )
Form	Fp;			/* [I] form_pointer	*/
struct  SMDwSymb    *Symb;	/* [I] Symbology of the object	*/

{
IGRchar		temp_text[SM_STR_LEN], msg_buff[81];
int		sel_flag, r_pos, sts;
short		color_no;
IGRchar		color_name[SM_STR_LEN];
long		msg;


     FIfld_get_text( Fp, SM_CL_FLD, 0, 0, SM_STR_LEN, temp_text, &sel_flag, &r_pos );
     if ( temp_text[0] == '\0' ) return 1;
     sts = SMget_color( &msg, temp_text, color_name, &color_no);
     if ( !(sts&1) ) goto wrapup;

     FIfld_set_text( Fp, SM_CL_FLD, 0, 0, color_name, 0 );
     Symb->symb.display_attr.color = color_no;

  return 1;

wrapup:
  ex$message ( msgnumb = SM_E_ErDfCl, buff = msg_buff );
  FIg_set_text ( Fp, FI_MSG_FIELD, msg_buff );
  return 0;
}



end implementation Root;
