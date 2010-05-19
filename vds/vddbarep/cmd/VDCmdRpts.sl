
/* $Id: VDCmdRpts.sl,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $  */

/* I/VDS
 *
 * File:	vddbarep/VDCmdRpts.sl
 *
 * Description:
 *	This Command Object is used for generating VDS reports.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRpts.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
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
 *	09/30/93	Raju		Creation
 *
 */
		  
/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_Reports, 0, VDRpts
class		VDCmdRpts
super_class	VDS_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"
options		"SITC"

/* used forms */
form		"VDRpts",VDS_RPTS_FORM,0,"-1","-1"
form		"VDDispRpts",DISP_RPTS_FORM,0,"-1","-1"

start_state	start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification
/*
  The Command Object uses the following instance.

*/
#include "VDRptsDef.h"
#include "FI.h"			/* FI_...	*/


#define	FP_VDS_RPTS	me^^CEO.forms[VDS_RPTS_FORM].form_ptr
#define FP_DISP_RPTS	me^^CEO.forms[DISP_RPTS_FORM].form_ptr
#define my		me^^VDCmdRpts

instance
{
   int	SinglePartNo;
   int  Part1, Part2;
   int  PrjRev1, PrjRev2;
   char TempLib[VD_MAX_LIBNAME_LEN];
   int  TempNo;
   char processed;		/* flag to indicate if the reports generated */
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

#include "VDmsg.h"

#include "PDUerror.h"

#include "dbadev.h"

extern  char Ris_SchemaName[];
extern	char Ris_SchemaPwd[];


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "VDmsg.h"

#define VDS_RPTS_FORM  0
#define DISP_RPTS_FORM 1

state start

  display_form  0	
  message_key	VD_M_Reports
  filter	get_event

  on EX_FORM_FINISHED					state terminate 

at init do setup_form


/************************************************************************/
/*	METHOD:	setup_form						*/
/************************************************************************/

action setup_form
{
long		msg , sts2;
char		tmp_lib[VD_MAX_LIBNAME_LEN], errmsg[132];
char		schema[40], product_path[25];
extern	int	dba_message_strip;

  /* check if user logged into database */
  if(VDSverify_login() != PDM_S_SUCCESS )
  {
     ex$message(msgnumb=VD_E_PrUsNotLog);
     me->state = _terminate;
     *sts = OM_E_ABORT;
     return OM_S_SUCCESS;
  }

  /* check if user selected Project */ 
  if(VDSverify_project() != OM_S_SUCCESS )
  {
     ex$message(msgnumb=VD_E_PrUsNotSel);
     me->state = _terminate;
     *sts = OM_E_ABORT;
     return OM_S_SUCCESS;
  }

  /* set first assembly catalog list field */
  my.SinglePartNo = 0;
  VDSetCatFld( &msg, FP_VDS_RPTS, VD_RPT_CAT_LIST1, &(my.SinglePartNo) );
  if ( !msg )
  {   me->state = _terminate;
      *sts = OM_E_ABORT;
      return OM_S_SUCCESS;
  }

  my.Part1 = -1;
  my.Part2 = -1;

  my.PrjRev1 = -1;
  my.PrjRev2 = -1;
  
  sts2 = dba_setup( 0, 0, 0, errmsg );
  if ( sts2 ) 
  { ex$message(msgnumb=VD_E_RpStDb);
    me->state = _terminate;
    *sts = OM_E_ABORT;
    return OM_S_SUCCESS;
  }

  dba_message_strip = 0;
  sprintf(schema,"%s.%s",Ris_SchemaName,Ris_SchemaPwd );
  sts2 = dba_schema_select( schema );
  if ( sts2 )
  { ex$message(msgnumb=VD_E_RpSlSc);
    me->state = _terminate;
    *sts = OM_E_ABORT;
    return OM_S_SUCCESS;
  }

  /*   set the default template library */
  if(get_modtype_data("Vds",NULL,NULL,NULL,NULL,product_path) == 0)
  { /* can not get product_path */
    me->state = _terminate;
    *sts = OM_E_ABORT;
    return OM_S_SUCCESS;
  }

  strcpy(tmp_lib,product_path);
  strcat(tmp_lib,VD_RPT_TEMPLIB);


  FIfld_set_text( FP_VDS_RPTS, VD_RPT_LIB_FLD, 0, 0, tmp_lib, 0);
  strcpy(my.TempLib, tmp_lib);

  my.TempNo = 0;
  /* get the first template and display */
  VDSetTemp( &msg, my.TempLib, &(my.TempNo), FP_VDS_RPTS, VD_RPT_TEMP_FLD );
  if ( !msg )
  {   me->state = _terminate;
      *sts = OM_E_ABORT;
      return OM_S_SUCCESS;
  }

  my.processed = 0;  /* set the flag to FLASE */
}



action form_notification
{
int		sel_flag, r_pos, state, num_row, ii, len;
char		temp_text[VD_MAX_LIBNAME_LEN], Rev[20], Rev1[20], msg_buff[81],
		PartText[VD_MAX_PART_LEN], PartText1[VD_MAX_PART_LEN];
long		msg, sts;


switch( form_label )
{
 case VDS_RPTS_FORM :

  FIg_set_text( FP_VDS_RPTS, FI_MSG_FIELD, "");

  switch ( gadget_label )
  {
    case VD_RPT_SINGLE_PART:
	sts = om$send( msg = message VDCmdRpts.VDSetupSinglePart( &msg, FP_VDS_RPTS ),
			targetid = my_id );
	break;

    case VD_RPT_DIFF_2PARTS:
	sts = om$send( msg = message VDCmdRpts.VDSetupDiff2Parts( &msg, FP_VDS_RPTS ),
			targetid = my_id );
	break;

    case VD_RPT_DIFF_2PRJS:
	sts = om$send( msg = message VDCmdRpts.VDSetupDiff2Prjs( &msg, FP_VDS_RPTS ),
			targetid = my_id );
	break;

    case VD_RPT_USR_DEF:
	sts = om$send( msg = message VDCmdRpts.VDSetupUsrDef( &msg, FP_VDS_RPTS ),
			targetid = my_id );
	break;


    case VD_RPT_CAT_LIST1:
	/* get the selected row no. */
	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_CAT_LIST1, 0, 0,
			VD_MAX_PART_LEN, PartText, &sel_flag, &r_pos );
	len = strlen ( PartText );

	FIfld_get_list_num_rows( FP_VDS_RPTS, VD_RPT_CAT_LIST1, 0, &num_row );
	for( ii=0; ii < num_row; ii++)
	{  FIfld_get_list_text( FP_VDS_RPTS, VD_RPT_CAT_LIST1, ii, 0,
			VD_MAX_PART_LEN, PartText1, &sel_flag );

	   if ( !strncmp( PartText, PartText1 , len) )
	      break;
	}

	FIg_get_state ( FP_VDS_RPTS, VD_RPT_SINGLE_PART, &state );
	if ( state )
	   my.SinglePartNo = ii;

	FIg_get_state ( FP_VDS_RPTS, VD_RPT_DIFF_2PARTS, &state );
	if ( state )
	{
	    my.Part1 = ii;
	    /* set the corresponding versions in list 2 */
	    VDSetCatList2( &msg, FP_VDS_RPTS, VD_RPT_CAT_LIST1, VD_RPT_CAT_LIST2,
		&(my.Part2) );
	}
        break;

    case VD_RPT_REV_FLD1:
    case VD_RPT_REV_FLD2:
	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_REV_FLD1, 0, 0, 20,
		Rev, &sel_flag, &r_pos );
	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_REV_FLD2, 0, 0, 20,
		Rev1, &sel_flag, &r_pos );
	if ( !strcmp( Rev, Rev1 ) )
	{ ex$message ( msgnumb=VD_E_RpSeSmRv, buff=msg_buff );
	  FIg_set_text( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	}

    case VD_RPT_LIB_FLD:
	/* Erase the list associated with template field */
	FIfld_set_list_num_rows( FP_VDS_RPTS, VD_RPT_TEMP_FLD, 0, 0);
	/* Erase the text in template field */
	FIfld_set_text( FP_VDS_RPTS, VD_RPT_TEMP_FLD, 0, 0, "", 0);

	FIfld_get_text( FP_VDS_RPTS, VD_RPT_LIB_FLD, 0, 0, VD_MAX_LIBNAME_LEN,
			temp_text, &sel_flag, &r_pos);
	if ( strcmp( temp_text, my.TempLib ) )
        {  strcpy( my.TempLib, temp_text );
	   my.TempNo = 0;
	   VDSetTemp( &msg, my.TempLib, &(my.TempNo), FP_VDS_RPTS, VD_RPT_TEMP_FLD );
        }
        break;

    case VD_RPT_PROCESS:
	sts = om$send( msg = message VDCmdRpts.VDProcessReport( &msg ),
			targetid = my_id );
        break;

    case VD_RPT_DISPLAY:
	sts = om$send( msg = message VDCmdRpts.VDDispRpt( &msg ),
			targetid = my_id );
	FIg_set_state_off ( FP_VDS_RPTS, VD_RPT_DISPLAY );
	if ( msg )  FIf_display( FP_DISP_RPTS );
        break;

    case VD_RPT_SAVE:
	sts = om$send( msg = message VDCmdRpts.VDSavetoFile( &msg ),
			targetid = my_id );
        break;

    case VD_RPT_PARAM_TGL:
	FIg_get_state ( FP_VDS_RPTS, VD_RPT_PARAM_TGL, &state );
	if ( state )
	   SMVA_display ( FP_VDS_RPTS, 12, 
			  VD_RPT_PARAM_TXT1, VD_RPT_PARAM_FLD1,
			  VD_RPT_PARAM_TXT2, VD_RPT_PARAM_FLD2,
			  VD_RPT_PARAM_TXT3, VD_RPT_PARAM_FLD3,
			  VD_RPT_PARAM_TXT4, VD_RPT_PARAM_FLD4,
			  VD_RPT_PARAM_TXT5, VD_RPT_PARAM_FLD5,
			  VD_RPT_PARAM_TXT6, VD_RPT_PARAM_FLD6);
	else
	   SMVA_erase   ( FP_VDS_RPTS, 12, 
			  VD_RPT_PARAM_TXT1, VD_RPT_PARAM_FLD1,
			  VD_RPT_PARAM_TXT2, VD_RPT_PARAM_FLD2,
			  VD_RPT_PARAM_TXT3, VD_RPT_PARAM_FLD3,
			  VD_RPT_PARAM_TXT4, VD_RPT_PARAM_FLD4,
			  VD_RPT_PARAM_TXT5, VD_RPT_PARAM_FLD5,
			  VD_RPT_PARAM_TXT6, VD_RPT_PARAM_FLD6);
	break;

    case FI_CANCEL :
	remove ( VD_RPT_OUTFILE );
        _put_response( resp = EX_FORM_FINISHED );
        break;

    default :
        break;

  }
  break;

 case DISP_RPTS_FORM :
  switch ( gadget_label )
  {
     case FI_CANCEL :
	FIg_set_state_off ( FP_DISP_RPTS, FI_CANCEL );
	FIf_erase (FP_DISP_RPTS);
	break;
  }
  break;
}

}

action VDSetupSinglePart( long *msg; char *fp )
{

int state;

  
  SMVA_erase( fp, 9, VD_RPT_NO1, VD_RPT_NO2, VD_RPT_CAT_LIST2,
		VD_RPT_PRJ_TXT, VD_RPT_PRJ_FLD, VD_RPT_REV_TXT1,
		VD_RPT_REV_FLD1, VD_RPT_REV_TXT2, VD_RPT_REV_FLD2 );

  SMVA_erase( fp, 2, VD_RPT_WHERE_TXT, VD_RPT_WHERE_FLD );

  SMVA_display ( fp, 2, VD_RPT_CAT_TXT, VD_RPT_CAT_LIST1);


  SMVA_enable ( fp, 6, VD_RPT_LIB_TXT, VD_RPT_LIB_FLD, VD_RPT_TEMP_TXT,
		VD_RPT_TEMP_FLD, VD_RPT_FILE_TXT, VD_RPT_FILE_FLD );

  SMVA_display ( fp, 2, VD_RPT_PARAM_TXT, VD_RPT_PARAM_TGL );

  FIg_get_state ( fp, VD_RPT_PARAM_TGL, &state );
  if ( state )
	SMVA_display ( fp, 12, 
			  VD_RPT_PARAM_TXT1, VD_RPT_PARAM_FLD1,
			  VD_RPT_PARAM_TXT2, VD_RPT_PARAM_FLD2,
			  VD_RPT_PARAM_TXT3, VD_RPT_PARAM_FLD3,
			  VD_RPT_PARAM_TXT4, VD_RPT_PARAM_FLD4,
			  VD_RPT_PARAM_TXT5, VD_RPT_PARAM_FLD5,
			  VD_RPT_PARAM_TXT6, VD_RPT_PARAM_FLD6);

  VDSetCatFld( msg, fp, VD_RPT_CAT_LIST1, &(my.SinglePartNo) );

  return OM_S_SUCCESS;

}
  
action VDSetupDiff2Parts( long *msg; char *fp )
{
char msg_buff[81];


  SMVA_erase( fp, 6, VD_RPT_PRJ_TXT, VD_RPT_PRJ_FLD, VD_RPT_REV_TXT1,
		VD_RPT_REV_FLD1, VD_RPT_REV_TXT2, VD_RPT_REV_FLD2 );

  SMVA_erase( fp, 2, VD_RPT_PARAM_TXT, VD_RPT_PARAM_TGL );

  SMVA_erase ( fp, 2, VD_RPT_WHERE_TXT, VD_RPT_WHERE_FLD );

  SMVA_erase   ( fp, 12,  VD_RPT_PARAM_TXT1, VD_RPT_PARAM_FLD1,
			  VD_RPT_PARAM_TXT2, VD_RPT_PARAM_FLD2,
			  VD_RPT_PARAM_TXT3, VD_RPT_PARAM_FLD3,
			  VD_RPT_PARAM_TXT4, VD_RPT_PARAM_FLD4,
			  VD_RPT_PARAM_TXT5, VD_RPT_PARAM_FLD5,
			  VD_RPT_PARAM_TXT6, VD_RPT_PARAM_FLD6);

  SMVA_display ( fp, 5, VD_RPT_NO1, VD_RPT_NO2,
		VD_RPT_CAT_TXT, VD_RPT_CAT_LIST1, VD_RPT_CAT_LIST2);

  SMVA_enable ( fp, 6, VD_RPT_LIB_TXT, VD_RPT_LIB_FLD, VD_RPT_TEMP_TXT,
		VD_RPT_TEMP_FLD, VD_RPT_FILE_TXT, VD_RPT_FILE_FLD );


  if ( my.Part1 < 0 )
  { /* invoking diff. bet. 2 parts for the first time */
    my.Part1 = 0;

    VDSetCatFld( msg, fp, VD_RPT_CAT_LIST1, &(my.Part1) );
    if ( *msg == 0 ) goto wrapup;

    ex$message ( msgnumb = VD_I_RpSl1Pt, buff = msg_buff );
    FIg_set_text ( fp, FI_MSG_FIELD, msg_buff );
  }
  else
  {
    VDSetCatFld( msg, fp, VD_RPT_CAT_LIST1, &(my.Part1) );
    if ( *msg == 0 ) goto wrapup;

  }

wrapup:
  return OM_S_SUCCESS;

}  

action VDSetupDiff2Prjs( long *msg; char *fp )
{
int	num_rev;
char	msg_buff[81];


  SMVA_erase  ( fp, 5, VD_RPT_NO1, VD_RPT_NO2,
		VD_RPT_CAT_TXT, VD_RPT_CAT_LIST1, VD_RPT_CAT_LIST2);

  SMVA_erase ( fp, 2, VD_RPT_WHERE_TXT, VD_RPT_WHERE_FLD );

  SMVA_disable ( fp, 4, VD_RPT_LIB_TXT, VD_RPT_LIB_FLD, VD_RPT_TEMP_TXT,
		VD_RPT_TEMP_FLD);

  SMVA_display ( fp, 2, VD_RPT_FILE_TXT, VD_RPT_FILE_FLD );


  SMVA_erase   ( fp, 2, VD_RPT_PARAM_TXT, VD_RPT_PARAM_TGL );

  SMVA_erase   ( fp, 12,  VD_RPT_PARAM_TXT1, VD_RPT_PARAM_FLD1,
			  VD_RPT_PARAM_TXT2, VD_RPT_PARAM_FLD2,
			  VD_RPT_PARAM_TXT3, VD_RPT_PARAM_FLD3,
			  VD_RPT_PARAM_TXT4, VD_RPT_PARAM_FLD4,
			  VD_RPT_PARAM_TXT5, VD_RPT_PARAM_FLD5,
			  VD_RPT_PARAM_TXT6, VD_RPT_PARAM_FLD6);

  SMVA_display( fp, 6, VD_RPT_PRJ_TXT, VD_RPT_PRJ_FLD, VD_RPT_REV_TXT1,
		VD_RPT_REV_FLD1, VD_RPT_REV_TXT2, VD_RPT_REV_FLD2 );

  if ( my.PrjRev1 >= 0 && my.PrjRev2 >=0 ) goto wrapup;

  /* display the project no. */
  VDSetPrjFld( msg, fp, VD_RPT_PRJ_FLD );
  if ( *msg == 0 ) goto wrapup;

  VDGetPrjRevList ( msg, &num_rev );

  if ( *msg == 0 ) goto wrapup;

  if ( num_rev == 1 )
  {  ex$message ( msgnumb=VD_E_RpPj1Vr, buff=msg_buff );
     FIg_set_text( fp, FI_MSG_FIELD, msg_buff );
  }

  if ( my.PrjRev1 < 0 ) my.PrjRev1 = 0;
  VDSetPrjRev( msg, fp, VD_RPT_REV_FLD1, &(my.PrjRev1) );
  if ( *msg == 0 ) goto wrapup;

  if ( num_rev > 1 )
  { if ( my.PrjRev2 < 0 ) 
    { my.PrjRev2 = my.PrjRev1 + 1;
      if ( my.PrjRev2 == num_rev ) my.PrjRev2 = 0;
    }
    VDSetPrjRev( msg, fp, VD_RPT_REV_FLD2, &(my.PrjRev2) );
    if ( *msg == 0 ) goto wrapup;
  }

wrapup:
 return OM_S_SUCCESS;
}

action VDSetupUsrDef( long *msg; char *fp )
{

int state;

  
  SMVA_erase( fp, 9, VD_RPT_NO1, VD_RPT_NO2, VD_RPT_CAT_LIST2,
		VD_RPT_PRJ_TXT, VD_RPT_PRJ_FLD, VD_RPT_REV_TXT1,
		VD_RPT_REV_FLD1, VD_RPT_REV_TXT2, VD_RPT_REV_FLD2 );

  SMVA_erase ( fp, 2, VD_RPT_CAT_TXT, VD_RPT_CAT_LIST1);


  SMVA_enable ( fp, 6, VD_RPT_LIB_TXT, VD_RPT_LIB_FLD, VD_RPT_TEMP_TXT,
		VD_RPT_TEMP_FLD, VD_RPT_FILE_TXT, VD_RPT_FILE_FLD );

  SMVA_display ( fp, 2, VD_RPT_WHERE_TXT, VD_RPT_WHERE_FLD );

  SMVA_display ( fp, 2, VD_RPT_PARAM_TXT, VD_RPT_PARAM_TGL );

  FIg_get_state ( fp, VD_RPT_PARAM_TGL, &state );
  if ( state )
	SMVA_display ( fp, 12, 
			  VD_RPT_PARAM_TXT1, VD_RPT_PARAM_FLD1,
			  VD_RPT_PARAM_TXT2, VD_RPT_PARAM_FLD2,
			  VD_RPT_PARAM_TXT3, VD_RPT_PARAM_FLD3,
			  VD_RPT_PARAM_TXT4, VD_RPT_PARAM_FLD4,
			  VD_RPT_PARAM_TXT5, VD_RPT_PARAM_FLD5,
			  VD_RPT_PARAM_TXT6, VD_RPT_PARAM_FLD6);

  return OM_S_SUCCESS;

}

action VDProcessReport( long *msg )
{

short   ReportType = 0;	/* 0 - single part, 1 - diff of part,
			   2 - diff of proj, 3 - user defined */
int	state, sel_flag, r_pos;
char    LibName[VD_MAX_LIBNAME_LEN],Template[VD_MAX_TEMPLATE_LEN];
char	TempName[50], PartText[VD_MAX_PART_LEN], where_clause[200];
char	AssCat[20], AssName[20], Rev[20], Rev1[20];
char	p1[20], p2[20], p3[20], p4[20], p5[20], p6[20], msg_buff[81];
long	sts2;
extern  char *dba_errtxt;
char	proj_num[20], product_path[25];

     *msg = 1;
     FIg_get_state ( FP_VDS_RPTS, VD_RPT_SINGLE_PART, &state );
     if ( state ) ReportType = 0;

     FIg_get_state ( FP_VDS_RPTS, VD_RPT_DIFF_2PARTS, &state );
     if ( state ) ReportType = 1;

     FIg_get_state ( FP_VDS_RPTS, VD_RPT_DIFF_2PRJS, &state );
     if ( state ) ReportType = 2;

     FIg_get_state ( FP_VDS_RPTS, VD_RPT_USR_DEF, &state );
     if ( state ) ReportType = 3;

     /* initialize paramaters to NULL */
     p1[0] = p2[0] = p3[0] = p4[0] = p5[0] = p6[0] = 0;

     /* form the where clause */
     if ( ReportType == 0 || ReportType == 3 )   /* process single part */
     {
        if ( ReportType == 0 )
	{  FIfld_get_text ( FP_VDS_RPTS, VD_RPT_CAT_LIST1, 0, 0, VD_MAX_PART_LEN,
		PartText, &sel_flag, &r_pos );

	   sscanf( PartText, "%s %s %s", AssCat, AssName, Rev );
	   sprintf(where_clause, "where assembly_cat='%s' and assembly_nam='%s' \
and assembly_ver='%s'", AssCat, AssName, Rev );
	}
	else
	{
	   strcpy( where_clause, "where ");
	   FIfld_get_text ( FP_VDS_RPTS, VD_RPT_WHERE_FLD, 0, 0, 194,
		&where_clause[6], &sel_flag, &r_pos );
	   if ( !where_clause[6] || where_clause[6] ==' ' )
		where_clause[0] = '\0';
	}

#ifdef RAJU_DEBUG
	printf("Process single report\n WHERE CLAUSE = [%s]\n",where_clause);
#endif

  	FIg_get_state ( FP_VDS_RPTS, VD_RPT_PARAM_TGL, &state );
	if ( state )
	{ FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PARAM_FLD1, 0, 0, 20,
		p1, &sel_flag, &r_pos );
	  FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PARAM_FLD2, 0, 0, 20,
		p2, &sel_flag, &r_pos );
	  FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PARAM_FLD3, 0, 0, 20,
		p3, &sel_flag, &r_pos );
	  FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PARAM_FLD4, 0, 0, 20,
		p4, &sel_flag, &r_pos );
	  FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PARAM_FLD5, 0, 0, 20,
		p5, &sel_flag, &r_pos );
	  FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PARAM_FLD6, 0, 0, 20,
		p6, &sel_flag, &r_pos );
	}

     }
     else if ( ReportType == 1 )	/* process diff. bet. 2 ver. of a part */
     {
	if ( my.Part1 < 0 || my.Part2 < 0 )
	{  ex$message ( msgnumb = VD_E_Sl2Vr, buff = msg_buff )
	   FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	   *msg = 0;
	   goto wrapup;
	}

	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_CAT_LIST1, 0, 0, VD_MAX_PART_LEN,
		PartText, &sel_flag, &r_pos );

	sscanf( PartText, "%s %s %s", AssCat, AssName, Rev );

	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_CAT_LIST2, 0, 0, VD_MAX_PART_LEN,
		PartText, &sel_flag, &r_pos );
	sscanf( PartText, "%*s %*s %s", Rev1 );

	sprintf(where_clause, "where assembly_cat='%s' and assembly_nam='%s'",
		AssCat, AssName );
	strcpy( p1, Rev );
	strcpy( p2, Rev1 );
     }
     else	/* process diff. bet. 2 versions of project */
     {
	if ( my.PrjRev1 < 0 || my.PrjRev2 < 0 ) /*need not check for my.PrjRev1*/
	{  ex$message ( msgnumb=VD_E_RpPj1Vr, buff=msg_buff );
	   FIg_set_text( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	   goto wrapup;
	}

	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_PRJ_FLD, 0, 0, 20,
		proj_num, &sel_flag, &r_pos );
	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_REV_FLD1, 0, 0, 20,
		Rev, &sel_flag, &r_pos );
	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_REV_FLD2, 0, 0, 20,
		Rev1, &sel_flag, &r_pos );
	if ( !strcmp( Rev, Rev1 ) )
	{ ex$message ( msgnumb=VD_E_RpSeSmRv, buff=msg_buff );
	  FIg_set_text( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	  *msg = 0;
	  goto wrapup;
	}

	sprintf(where_clause, "where prj_number='%s'", proj_num );
	strcpy( p1, Rev );
	strcpy( p2, Rev1 );

     }

     if ( ReportType == 0 || ReportType == 1 || ReportType == 3 )
     {
	/* read template library and template */
	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_LIB_FLD, 0, 0, VD_MAX_LIBNAME_LEN,
		LibName, &sel_flag, &r_pos );
	if( !LibName[0] ) /* Template library not defined */
	{ ex$message ( msgnumb = VD_E_TmLbNtDf, buff = msg_buff );
	  FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	  *msg = 0;
          goto wrapup;
        }

	FIfld_get_text ( FP_VDS_RPTS, VD_RPT_TEMP_FLD, 0, 0, VD_MAX_TEMPLATE_LEN,
		Template, &sel_flag, &r_pos );
	if( !Template[0] )   /* Template not selected */
	{ ex$message ( msgnumb = VD_E_TmNtSl, buff = msg_buff );
	  FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	  *msg = 0;
	  goto wrapup;
	}
	sscanf(Template,"%s",TempName);
     }
     else
     {
       if(get_modtype_data("Vds",NULL,NULL,NULL,NULL,product_path) == 0)
       { /* can not get product_path */
	 *msg = 0;
	 goto wrapup;
       }
       strcpy(LibName,product_path);
       strcat(LibName,VD_RPT_TEMPLIB);

       strcpy(TempName,"VDS_PROJECT_PARTS");

     }

     ex$message ( msgnumb = VD_I_Process );
     if(where_clause[0] == 0 )
       sts2 = dba_single_report(LibName, TempName, 0,0,0, VD_RPT_OUTFILE,
		0,p1,p2,p3,p4,p5,p6);
     else
       sts2 = dba_single_report(LibName, TempName, 0,0,0, VD_RPT_OUTFILE,
		where_clause,p1,p2,p3,p4,p5,p6);

     if ( sts2 )      /*  error generating report */
     { UI_status("");
	FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, dba_errtxt );
	*msg = 0;
	goto wrapup;
     }
     else
     {  ex$message ( msgnumb = VD_I_ScGnRp );
	my.processed = 1;
     }

wrapup:
  return OM_S_SUCCESS;

}


action VDDispRpt ( long *msg )
{
char msg_buff[81], TmpStr[258];
int sts, ii;
FILE *fp1;

/*  see if the reports have been processed */
/*  display  temporary reports file */

	*msg = 1;

	if ( !my.processed )
	{ ex$message ( msgnumb=VD_E_RpNtPr, buff=msg_buff );
	  FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	  *msg = 0;
	  goto wrapup;
	}

	fp1 = (FILE *) fopen ( VD_RPT_OUTFILE, "r" );
	ii = 0;
	while ( (fgets(TmpStr, 258, fp1) != NULL ) )
	{ 	FIfld_set_text ( FP_DISP_RPTS, VD_DISP_RPTS_FLD, ii, 0, TmpStr, 0 );
		ii++;
	}
	fclose( fp1 );
	FIfld_set_num_rows ( FP_DISP_RPTS, VD_DISP_RPTS_FLD, ii );

wrapup:
  return OM_S_SUCCESS;

}

action VDSavetoFile ( long *msg )
{
char FileName[132], msg_buff[81], TmpStr[258];
int sts, sel_flag, r_pos;
FILE *fp1, *fp2;

/*  see if the reports have been processed */
/*  get the name of the file for reports */
/*  copy temporary reports file to the specified file*/

	*msg = 1;

	if ( !my.processed )
	{ ex$message ( msgnumb=VD_E_RpNtPr, buff=msg_buff );
	  FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	  *msg = 0;
	  goto wrapup;
	}

	FIfld_get_text( FP_VDS_RPTS, VD_RPT_FILE_FLD, 0, 0, VD_MAX_FLNAME_LEN,
			FileName, &sel_flag, &r_pos);

	if ( !FileName[0] )
	{   ex$message ( msgnumb=VD_E_RpFlNtSp, buff=msg_buff);
	    FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	    *msg = 0;
	    goto wrapup;
	}

	fp1 = (FILE *) fopen ( VD_RPT_OUTFILE, "r" );
	fp2 = (FILE *) fopen ( FileName, "w" );
	if ( fp2 == NULL )
	{   ex$message ( msgnumb=VD_E_RpOpFlWr, buff=msg_buff,
			 type="%s", var=FileName );
	    FIg_set_text ( FP_VDS_RPTS, FI_MSG_FIELD, msg_buff );
	    *msg = 0;
	    goto wrapup;
	}
	while ( (fgets(TmpStr, 258, fp1) != NULL ) )
		fputs( TmpStr, fp2 );
	fclose( fp1 );
	fclose( fp2 );


wrapup:
  return OM_S_SUCCESS;

}     
