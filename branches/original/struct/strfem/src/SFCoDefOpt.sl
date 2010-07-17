/****************************************************************************

	Filename:	SMCoDefOpt.sl
	Author:		Raju
	Type:		Slic File
	Process by:	$EXNUC/bin/slic SMCoDefOpt.sl
	Output:		SMCoDefOpt.S  and SMCoDefOpti.I

	Description:

	  This Command Object is used for defining the options for conversion
	  of I/STRUCT elements.

	History:
	22 Aug 1994    Raju		Creation
 
*****************************************************************************/
		  
/****************************************************************************/
/*	CLASS SPECIFICATION						*****/
/****************************************************************************/

command_string	"Define Conversion Options", 0, SFDfCnvOp
class		SFCoDefOpt
super_class	CEO_LOCATE
product_name	"$STRFEM"
command_table	"sf.cmd"
options		"SITC"

/* form used */
form		"SFDefCnvOpt",0,0,"-1","-1"

start_state	start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification


/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <string.h>
#include "FI.h"			/* FI_...	*/
#include "SFmsg.h"

#include "ACrg_collect.h"
#include "APdef.h"

#include "vderrmacros.h"
#include "SFconvDef.h"

#define  SF_PLACE_PL_AT_FLD	14
#define  SF_OFFSET_TXT		18
#define  SF_OFFSET_FLD		15
#define  SF_OFFSET_UNIT_TXT	17
#define  SF_BM_EXTRACT_OPT_FLD	16
#define  SF_BM_ELEM_TYPE_TXT	19
#define  SF_BM_ELEM_TYPE_FLD	20
#define  SF_BM_FEM_ELEM_TXT	21
#define  SF_BM_FEM_ELEM_FLD	22
#define  SF_CONV_ELEM_FLD	24

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

extern  double  APu_default_to_dbase();

/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "SFmsg.h"

state start

  display_form  0
  message	"Define Conversion Options"
  prompt	"Select Options"
  filter	get_event

  on EX_FORM_FINISHED					state terminate 


at init		do set_form
		do set_form_pos
at delete	do save_form_pos

/************************************************************************/
/*	METHOD:	set_form							*/
/************************************************************************/

action set_form 
{
long	msg;
char	PlateSurfOpt[ATTR_NAME],
	BmExtractOpt[ATTR_NAME],
	DefUnitName[GRIO_MAX_ALIAS_SIZE];
int	ElemType,
	NbFemElem,
	ConvAllEl;
double  offset_db,
	offset_def;


  status = SFgetConvOpt( &msg, PlateSurfOpt, &offset_db, BmExtractOpt,
			 &ElemType, &NbFemElem, &ConvAllEl );
  VDS_ERR_HNDLR ("Getting Conversion options", status, msg, VD_VERBOSE, quit);

  FIg_set_text ( me->forms[0].form_ptr, SF_PLACE_PL_AT_FLD, PlateSurfOpt );
  status = (long) APu_getTypeDefaultUnit ( GRIO_DISTANCE, DefUnitName );
  FIg_set_text ( me->forms[0].form_ptr, SF_OFFSET_UNIT_TXT, DefUnitName);

  if ( !strcmp(PlateSurfOpt, SF_TXT_KEYIN ) )
  {
	status = (long) APu_dbase_to_default_dbl ( GRIO_DISTANCE, offset_db,
						   &offset_def, NULL );
	FIg_set_value ( me->forms[0].form_ptr,
			SF_OFFSET_FLD, offset_def );
  }
  else
	SMVA_erase   ( me->forms[0].form_ptr, 3, SF_OFFSET_TXT,
						 SF_OFFSET_FLD,
						 SF_OFFSET_UNIT_TXT );

  FIg_set_text ( me->forms[0].form_ptr, SF_BM_EXTRACT_OPT_FLD, BmExtractOpt );
  if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )
  {
	if ( ElemType == LINE2 )
	  FIg_set_state( me->forms[0].form_ptr, SF_BM_ELEM_TYPE_FLD, FALSE );
	else
	  FIg_set_state( me->forms[0].form_ptr, SF_BM_ELEM_TYPE_FLD, TRUE );

	FIg_set_value ( me->forms[0].form_ptr, SF_BM_FEM_ELEM_FLD,
			(double) NbFemElem );
  }
  else
	SMVA_erase   ( me->forms[0].form_ptr, 4, SF_BM_ELEM_TYPE_TXT,
						 SF_BM_ELEM_TYPE_FLD,
						 SF_BM_FEM_ELEM_TXT,
						 SF_BM_FEM_ELEM_FLD );

  if ( ConvAllEl )
   FIg_set_text ( me->forms[0].form_ptr, SF_CONV_ELEM_FLD, SF_TXT_ALL_ELEM);
  else
   FIg_set_text ( me->forms[0].form_ptr, SF_CONV_ELEM_FLD, SF_TXT_UNCONV_ELEM);

}

action form_notification 
{
long	msg;
char	PlateSurfOpt[ATTR_NAME],
	BmExtractOpt[ATTR_NAME],
	TmpTxt[25];
double  offset_db,
	offset_def,
	TmpDbl;
int	ElemType,
	NbFemElem,
	eltype_tgl,
	ConvAllEl;



  switch( gadget_label )
  {
   case SF_PLACE_PL_AT_FLD :
     FIg_get_text( form_ptr, SF_PLACE_PL_AT_FLD, PlateSurfOpt );
     if ( !strcmp(PlateSurfOpt, SF_TXT_KEYIN ) )
	SMVA_display ( me->forms[0].form_ptr, 3, SF_OFFSET_TXT,
						 SF_OFFSET_FLD,
						 SF_OFFSET_UNIT_TXT );
     else
	SMVA_erase   ( me->forms[0].form_ptr, 3, SF_OFFSET_TXT,
						 SF_OFFSET_FLD,
						 SF_OFFSET_UNIT_TXT );
     break;

   case SF_BM_EXTRACT_OPT_FLD :
     FIg_get_text( form_ptr, SF_BM_EXTRACT_OPT_FLD, BmExtractOpt );
     if ( !strcmp( BmExtractOpt, SF_TXT_MESHING) )
	SMVA_display ( me->forms[0].form_ptr, 4, SF_BM_ELEM_TYPE_TXT,
						 SF_BM_ELEM_TYPE_FLD,
						 SF_BM_FEM_ELEM_TXT,
						 SF_BM_FEM_ELEM_FLD );
     else
	SMVA_erase   ( me->forms[0].form_ptr, 4, SF_BM_ELEM_TYPE_TXT,
						 SF_BM_ELEM_TYPE_FLD,
						 SF_BM_FEM_ELEM_TXT,
						 SF_BM_FEM_ELEM_FLD );
     break;

   case FI_ACCEPT :
     FIg_get_text( form_ptr, SF_PLACE_PL_AT_FLD, PlateSurfOpt );
     if ( !strcmp(PlateSurfOpt, SF_TXT_KEYIN ) )
     {
	FIg_get_value ( form_ptr, SF_OFFSET_FLD, &offset_def );
	offset_db = APu_default_to_dbase ( GRIO_DISTANCE, offset_def );
     }
     FIg_get_text( form_ptr, SF_BM_EXTRACT_OPT_FLD, BmExtractOpt );

     /* Following two statements are just to remove compiler warnings */
     ElemType = LINE2;
     NbFemElem = 1;

     if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )
     {
	FIg_get_state ( form_ptr, SF_BM_ELEM_TYPE_FLD, &eltype_tgl );
	if ( eltype_tgl )
	   ElemType = LINE3;
	else
	   ElemType = LINE2;
	FIg_get_value ( form_ptr, SF_BM_FEM_ELEM_FLD, &TmpDbl );
	NbFemElem = TmpDbl;
     }

     FIg_get_text( form_ptr, SF_CONV_ELEM_FLD, TmpTxt );
     if ( !strcmp ( TmpTxt, SF_TXT_ALL_ELEM ) )
	ConvAllEl = TRUE;
     else
	ConvAllEl = FALSE;

     status = SFsetConvOpt( &msg, PlateSurfOpt, &offset_db, BmExtractOpt,
			    ElemType, NbFemElem, ConvAllEl );

     VDS_ERR_HNDLR("Setting conversion options", status, msg, VD_VERBOSE,quit);
     _put_response( resp = EX_FORM_FINISHED );
     break;

   case FI_CANCEL :
     _put_response( resp = EX_FORM_FINISHED );
     break;
  }

}

action  set_form_pos
{

  status = OM_S_SUCCESS;

  if(x_pos != -1 && y_pos != -1)
    FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

  goto quit;

}

action  save_form_pos
{

  status = OM_S_SUCCESS;

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

  goto quit;

}
