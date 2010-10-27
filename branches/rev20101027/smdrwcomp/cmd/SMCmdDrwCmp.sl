/* $Id: SMCmdDrwCmp.sl,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwcomp/cmd / SMCmdDrwCmp.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdDrwCmp.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
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

/****************************************************************************

	Filename:	SMCmdDrwCmp.sl
	Author:		Raju
	Type:		Slic File
	Process by:	$EXNUC/bin/slic SMCmdDrwCmp.sl
	Output:		SMCmdDrwCmp.S  and SMCmdDrwCmpi.I
	makemake file	SMcoppl.m -> makefile -> ../lib/SMdrawing.o

	Description:

	  This Command Object is to set the options for drawing extraction of
	  compartments. One or more of the Contour, Plane, CoG, and Name objects
          can be selected. Symbology for the selected objects can be set.

	History:
	03 Jun 1993    Raju		Creation
 
 ****************************************************************************/
		  
/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	SMC_M_CompDwPr, 0, SMDfDrOp
class		SMCmdDrwCmp
super_class	CEO_LOCATE
product_name	"$VDS"
command_table	"sman.cmd"
options		"SITC"

/* used forms */
form		"SMCompDwPr",0,0,"-1","-1"

start_state	start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification
/*
  The Command Object will use the following instance for
  "Defining Compartment Drawing Parameters".
*/

#include "SMdef.h"
#include "SMDwDef.h"
#include "SMDwPrDef.h"

#define	FP_DWPAR	me^^CEO.forms[0].form_ptr
#define my		me^^SMCmdDrwCmp
#define SM_STR_LEN	24

instance
{
   IGRboolean		Crt[NO_GO];
   struct SMDwSymb	Symb[NO_GO];
}

/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "AS_status.h"		/* as$status 	*/
#include "adpdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "gotextdef.h"
#include "FI.h"			/* FI_...	*/

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "vdsmacros.h"		/* vd$openfile	*/
#include "VDmsg.h"

#include "SMmsg.h"
#define  SM_DWPAR_FILE  "SMCompDrawing"

/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "SMmsg.h"

state start

  display_form  0	
  message_key	SM_M_CompDwPr
  prompt_key	SM_P_SfChForm
  filter	get_event

  on EX_FORM_FINISHED					state terminate 


at init do set_def


/************************************************************************/
/*	METHOD:	set_def							*/
/************************************************************************/

action set_def 
{
int		ii;
IGRboolean	*Crt;
struct SMDwSymb 	*Symb;

   Crt = my.Crt;
   Symb = my.Symb;

   for(ii=0; ii<NO_GO; ii++)
      Crt[ii] = FALSE;

   Crt[SM_CONTOUR] = TRUE; 	/* set extraction of all objects exept CONTOUR
					to FLASE	*/

   /* set default symbology to active */
   Symb[SM_CONTOUR].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT ;

   Symb[SM_PLANE].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT ;

   Symb[SM_NAME].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT
				| SMDWTXACT | SMDWATTOBJ;
   Symb[SM_NAME].TextJust = CENTER_CENTER;
   strcpy( Symb[SM_NAME].AttName, "comp_name" );

   Symb[SM_COG].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT;

   /* Initialize user symbology as follows	*/
   for(ii=0; ii<NO_GO; ii++)
   {  Symb[ii].symb.level = 1;
      Symb[ii].symb.display_attr.color = 1;
      Symb[ii].symb.display_attr.weight = 0;
      Symb[ii].symb.display_attr.style = 0;
   }
  /* set the values in the form */
  status =
  om$send(msg = message SMCmdDrwCmp.set_form (sts),
	  targetid = my_id );
  as$status( action = RET_STATUS );
}

/************************************************************************/
/*	METHOD:	set_form						*/
/************************************************************************/

action set_form 
{
int		ii;
IGRchar 	CollName[81];
struct GRid	CollId;
IGRboolean	*Crt;
struct SMDwSymb 	*Symb;
GRspacenum	cur_os;

   Crt = my.Crt;
   Symb = my.Symb;

   /* Look if collection already exists */
   VDSget_filename(CollName);
   strcat(CollName, SMDwCollName);

   status = di$translate(objname = CollName,
              p_objid = &CollId.objid,
              p_osnum = &CollId.osnum);
   if( status & 1 )		/* collection exists	*/
   {
      status = SMGetDwPr(&Crt[SM_PLANE],&Symb[SM_PLANE],&Crt[SM_CONTOUR],
		 &Symb[SM_CONTOUR], &Crt[SM_LINE], &Symb[SM_LINE],
		 &Crt[SM_COG], &Symb[SM_COG], &Crt[SM_NAME],
		 &Symb[SM_NAME], &Crt[SM_EXTRACT], &Symb[SM_EXTRACT], &CollId );
      if ( !(status&1) ) goto USE_DEF;     /* continue with default options */
   }
   else
   {
     /* The collection does not exit, create collection from default params file and
        then get params */
	ex$get_cur_mod( osnum = &cur_os );
        status = SMReadDrawParam( SM_DWPAR_FILE, cur_os );
        if ( !(status&1) ) goto USE_DEF;     /* continue with default options */

        status = SMGetDwPr(&Crt[SM_PLANE],&Symb[SM_PLANE],&Crt[SM_CONTOUR],
		   &Symb[SM_CONTOUR], &Crt[SM_LINE], &Symb[SM_LINE],
		   &Crt[SM_COG], &Symb[SM_COG], &Crt[SM_NAME],
		   &Symb[SM_NAME], &Crt[SM_EXTRACT], &Symb[SM_EXTRACT], NULL);
        if ( !(status&1) ) goto USE_DEF;     /* continue with default options */

   }

USE_DEF:

   FIg_set_state( FP_DWPAR, SM_CONT_SEL,  (int)(Crt[SM_CONTOUR]) );
   FIg_set_state( FP_DWPAR, SM_PLANE_SEL,  (int)(Crt[SM_PLANE]) );
   FIg_set_state( FP_DWPAR, SM_COG_SEL,  (int)(Crt[SM_COG]) );
   FIg_set_state( FP_DWPAR, SM_NAME_SEL,  (int)(Crt[SM_NAME]) );

   /* set symbology for the first selected graphic object	*/
   for(ii=0; ii<NO_GO; ii++)
	if ( Crt[ii] ) break;
   /* If none is selected or LINE is selected,
		set for the SM_CONTOUR				*/
   if( ii == NO_GO || ii == SM_LINE ) ii = SM_CONTOUR;
   /* set Crt[SM_LINE] to FLASE. Not yet implemented.	*/
   if( Crt[SM_LINE] ) Crt[SM_LINE] = FALSE;

   FIfld_set_select( FP_DWPAR, SM_SYMB_OPT, (int)ii, 0, 0);

   status = SMCompSetSymb( FP_DWPAR, Symb[ii], ii );

   if ( Crt[SM_EXTRACT] && (Symb[SM_EXTRACT].options & SMDWEXTFLR) )
     FIg_set_state ( FP_DWPAR, SM_FLOOR_SEL, (int) TRUE );
   else
     FIg_set_state ( FP_DWPAR, SM_FLOOR_SEL, (int) FALSE );
}


action form_notification
{
int		row, pos, ActObjIndx, sel_flag, r_pos, ii, ii1;
double 		value;
short		TxtNo;
char		text[SM_STR_LEN], msg_buff[81];
long		i1;



  FIfld_get_active_row( FP_DWPAR, SM_SYMB_OPT, &row, &pos );
  ActObjIndx = row;

  FIg_set_text( FP_DWPAR, FI_MSG_FIELD, "");

  switch( gadget_label )
  {
   case SM_SYMB_OPT :
     /* Erase Justif. and Attr. gadgets of Name object even if not displayed */
     SMVA_erase( FP_DWPAR, 4, SM_JUST_TXT, SM_JUST_FLD, SM_ATTR_TXT, SM_ATTR_FLD );
     FIfld_get_active_row( FP_DWPAR, SM_SYMB_OPT, &row, &pos );
     /* Get the next selected object. If no other object is selected, symbology for
        the same object is displayed	*/
     if ( my.Crt[row] )
       ActObjIndx = row;
     else
     {  /* get the next selected object	*/
	for( ii =0; ii<NO_GO; ii++)
	{ ii1 = ( ii + row ) % NO_GO; 
	  if ( ii1 == SM_EXTRACT ) 	/* EXTRACT is not in options */
		continue; 
          if ( my.Crt[ii1] )
	  {     FIfld_set_select( FP_DWPAR, SM_SYMB_OPT, (int)(ii1),0,0);
		ActObjIndx = ii1;
		break;
	  }
	}
     }
     /* display symbology of the respective graphic object	*/
     status = SMCompSetSymb( FP_DWPAR, my.Symb[ActObjIndx], ActObjIndx );
     break;

   case SM_LV_OPT :
     SMform_notif_lv ( FP_DWPAR, &(my.Symb[ActObjIndx]) );
     break;

   case SM_CL_OPT :
     SMform_notif_cl ( FP_DWPAR, &(my.Symb[ActObjIndx]) );
     break;

   case SM_WT_OPT :
     SMform_notif_wt ( FP_DWPAR, &(my.Symb[ActObjIndx]) );
     break;

   case SM_ST_OPT :
     SMform_notif_st ( FP_DWPAR, &(my.Symb[ActObjIndx]) );
     break;

   case SM_LV_FLD :
     status = SMform_notif_lv_fld( FP_DWPAR, &(my.Symb[ActObjIndx]) );
     if ( !status )  SMCompSetSymb ( FP_DWPAR, my.Symb[ActObjIndx], ActObjIndx );
     break;

   case SM_CL_FLD :
     status = SMform_notif_cl_fld( FP_DWPAR, &(my.Symb[ActObjIndx]) );
     if ( !status )  SMCompSetSymb ( FP_DWPAR, my.Symb[ActObjIndx], ActObjIndx );
     break;

   case SM_WT_FLD :
     FIfld_get_value( FP_DWPAR, SM_WT_FLD, 0, 0, &value, &sel_flag, &r_pos );

     if ( value < GR_LO_WEIGHT || value > GR_HI_WEIGHT )
     { ex$message ( msgnumb = SM_E_ErDfWt, buff = msg_buff );
       FIg_set_text ( FP_DWPAR, FI_MSG_FIELD, msg_buff );
       status = SMCompSetSymb ( FP_DWPAR, my.Symb[ActObjIndx], ActObjIndx );
     }
     else
	my.Symb[ActObjIndx].symb.display_attr.weight = (IGRuchar) value;
     break;

   case SM_ST_FLD :
     FIfld_get_value( FP_DWPAR, SM_ST_FLD, 0, 0, &value, &sel_flag, &r_pos );
     if ( value < GR_LO_STYLE || value > GR_HI_STYLE )
     { ex$message ( msgnumb = SM_E_ErDfSt, buff = msg_buff );
       FIg_set_text ( FP_DWPAR, FI_MSG_FIELD, msg_buff );
       status = SMCompSetSymb ( FP_DWPAR, my.Symb[ActObjIndx], ActObjIndx );
     }
     else
	my.Symb[ActObjIndx].symb.display_attr.style = (IGRuchar) value;
     break;

   case SM_JUST_FLD :
     my.Symb[ActObjIndx].options = (my.Symb[ActObjIndx].options & ~0xF00000 ) |
					SMDWTXUSR;
     FIfld_get_text( FP_DWPAR, SM_JUST_FLD, 0, 0, SM_STR_LEN, text, &sel_flag,&r_pos);
     status = SMjustif_func( SM_GET_TEXTNO, text, &TxtNo);
     if ( status ) my.Symb[ActObjIndx].TextJust = TxtNo;
     break;

   case SM_ATTR_FLD :
     my.Symb[ActObjIndx].options = (my.Symb[ActObjIndx].options & ~0xF000000 ) |
					SMDWATTUSR;
     FIfld_get_text( FP_DWPAR, SM_ATTR_FLD, 0, 0, SM_STR_LEN, text, &sel_flag,&r_pos);
     strcpy(my.Symb[ActObjIndx].AttName, text);
     break;

   case SM_CONT_SEL:
     FIg_get_state( FP_DWPAR, SM_CONT_SEL,  &i1 );
     my.Crt[ SM_CONTOUR ] = (IGRboolean) i1;
     break;

   case SM_PLANE_SEL:
     FIg_get_state( FP_DWPAR, SM_PLANE_SEL, &i1 );
     my.Crt[ SM_PLANE ] = (IGRboolean) i1;
     break;

   case SM_COG_SEL:
     FIg_get_state( FP_DWPAR, SM_COG_SEL,   &i1 );
     my.Crt[ SM_COG ] = (IGRboolean) i1;
     break;

   case SM_NAME_SEL:
     FIg_get_state( FP_DWPAR, SM_NAME_SEL,  &i1 );
     my.Crt[ SM_NAME ] = (IGRboolean) i1;
     break;

   case FI_ACCEPT :
     FIg_get_state( FP_DWPAR, SM_FLOOR_SEL, &i1 );
     if ( i1 == FALSE )
	my.Crt[SM_EXTRACT] = FALSE;
     else
     {	my.Crt[SM_EXTRACT] = TRUE;
	my.Symb[SM_EXTRACT].options = ( my.Symb[SM_EXTRACT].options & ~0xF0000000 ) |
					  SMDWEXTFLR;
     }

     status = SMSetDwPr(my.Crt[SM_PLANE],&(my.Symb[SM_PLANE]),my.Crt[SM_CONTOUR],
	      &(my.Symb[SM_CONTOUR]), my.Crt[SM_LINE], &(my.Symb[SM_LINE]),
	      my.Crt[SM_COG], &(my.Symb[SM_COG]), my.Crt[SM_NAME],&(my.Symb[SM_NAME]),
	      my.Crt[SM_EXTRACT], &my.Symb[SM_EXTRACT], NULL);
     if ( !(status & 1) )
     { FIg_set_text(FP_DWPAR, FI_MSG_FIELD, "Error : Could not set parameters");
       break;
     }
     _put_response( resp = EX_FORM_FINISHED );
     break;

   case FI_CANCEL :
     _put_response( resp = EX_FORM_FINISHED );
     break;
  }

}








