/***************************************************************************/
/* HISTORY:                                                                */
/*     Implementation of 'select part' and 'place part' commands           */
/*                                                                         */
/*     The form MOSelecPart2 gets invoked for Select Part &  Place Part &  */
/*      replace part commands on 'Design Operations' form                  */
/*                                                                         */
/*     Date Created 1/06/92         :      MMS (IGI)                       */
/*         modified 4/12/92         :      DKK (IGI)                       */
/*                                                                         */
/***************************************************************************/

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
#include "PALglbs.h"
#include <PDUstr.h>
#include "PDUerror.h"
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif

#include "MEMerrordef.h"
#include "PALmsg.h"
#include "ACattrib.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDMmessage.h"
#ifdef bld21
#include "FI.h"
#endif

#include "PALlctypes.h"
/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"

#define EXP_MAX_LEN 80

/*****  PDU external variables set in placement options *************/
extern int PDMdebug_on ;
extern char *PDU_tagno;
extern int PDU_display_dyn_attr ;
extern char *PDU_incl_BOM         ;
extern char *PDU_incl_ASM         ;
extern char PDU_place_part_by    ;
extern int PDU_auto_part_selection  ;  /* selection ci_macro or not */
extern int PDU_default_layer    ;
extern int PDU_default_color    ;
extern int PDU_default_style    ;
extern int PDU_default_weight   ;
extern char	PDU_placement_type	;
extern short 	PDU_attach           	;
extern int	PDU_command             ;
extern int	PDU_save_command             ;
extern int      PDU_ComputedID          ;
extern MEMptr   PDU_dyn_attr_bufr; 
extern MEMptr   PDU_dyn_data_bufr;
extern struct	PDUrefresh	*refresh ;
extern MEMptr	PDU_ret_buffer;
extern MEMptr	PDUsearch_part_list;
extern int  PDU_refresh_gadgets[7];

/**************************************************************************/

/* Gadgets */
#define PROJECT        38
#define PROJECT_BTN    16
#define CATALOG        39
#define CAT_DESC       11	
#define SKETCH         17
#define SYM_MAP        23
#define CMP_NAME       20   
#define TABLE          21  
#define LEVEL1         28
#define SEARCH	       32
#define	EXP_LIST       33
#define SELCI_TOG      34	
#define PART_INDEX     22
#define PLUS	       26
#define MINUS	       25
#define STDorNSTD      23
#define SUB_TABLE      21	
#define	PARAMETERS     22
#define SYM_CONST      37
#define FORM_ID       201
#define PLCMNT_OPTIONS 12
#define RESTORE_CRT	45
#define SAVE_CRT	46
#define SORT		47
/*#define CLEAR_ALL       29 */

#define ATTR_COL	0
#define DATA_COL	1
#define OPER_COL	2
#define SEARCH_COL	3
/******************************************************************************/
/*********************** BEGIN EXTERN DECLARATION *****************************/

extern char             *s_text ;


extern	char 	**AttrList;    		/* common attribute list    */
extern 	char 	**AttrSynonym;		/* synonyms of attributes   */
extern 	char 	**AttrTypes;        	/* attribute types          */
extern 	int  	NumAttribs;	    	/* No. of common attributes */
extern	char 	ViewOrTblList[][6];

/*	TR # 139308062.	03/aug/93 - raj.	*/
extern	char	**AttrValsRep_PPart;

/************	svs.c *********************************************************/

#define	MAX_SVS_PARAMS		45		/* Maximum parameters */
#define MAX_SVS_COND 		45		/* Maximum conditions */
#define MAX_SVS_COND_LEN 	1024		/* Maximum condition length, assumed */
#define	MAX_SVS_QRY_LEN		1024		/* Maximum query length */
#define MAX_SVS_ROWS		50		/* Maximum values that can be returned from a query */
#define	SVS_NAME_LEN		32		/* Identifier length */

extern	int	NoParams, NoRows, NoSlctd;
extern	int	NoCols;
extern int      PDU_active_button;
extern Form PDU_form_id;
extern Form PDU_calling_form;
extern struct PDUforms forms;

extern	char	CurrentSVSView[];
extern	char	*VueColTypes[MAX_SVS_PARAMS];


extern	struct	columns_in_formula {
		char	*col_name;
		int	ndx;
	} cols_in_form[MAX_SVS_PARAMS];

/******************************************************************************/
/*********************** END EXTERN DECLARATION **********************/



/* If the order of following fields is to be changed 	*/
/* do so accordingly in selection ci_macro PDUselect.u	*/


Form		place_part_f/*=NULL*/ ;
static Form             exp_list_f ;



static int 		symbol_occurence ;
static int              col;
static int	        form_displayed , cur_level, no_of_buttons ;
static char   		*part_no, macname[32] ;
static int		ismacro;
short			PALis_sort_selected;
static struct GRmd_env	my_env;
static int		num_loc;
static char		*lCID;

/*********************** BEGIN GLOBAL  DATA DECLARATION ***********************/
int      display_all, row_num, max_rows_rtvd, sel_row, PALsavecrit ;
int	 lab[MAX_LEVELS];
char     **StatAttribs, **DynAttribs, **DynAttribTypes,**DynAttribDesc,
	 **StatUnits,  **StatTypes, **StatDesc ;
int	 NewCatalogSelected;
int 	 MacroDisplayed  ;
struct GRid	*grid_list, DYNA_GRID_LIST[MAX_DYN];
char     *PALchild_no;
int	Num_Stat, Num_Dyn ;
MEMptr   PALdyn_bufr;
MEMptr   filterbuf;
int      PALMacintf;
struct stemp	*MAC_temp_desc;
int		MAC_num_temp;

int		NumSelTemp;
struct GRid 	*SelTemplist;

/*	TR # 1393 01199. Smart View Search to work.	*/
int	EnableSVS;

/*********************** end of GLOBAL data declaration **********************/

#define CleanUp(){                                                      \
                                                                        \
        	  if(access("/bin/rm /usr/tmp/ViewDef.dat", 04) == 0) {	\
			system ("/bin/rm /usr/tmp/ViewDef.dat");        \
        	  }                                                     \
                                                                        \
        	  if(access("/bin/rm /usr/tmp/Condition.dat", 04) == 0) {\
			system ("/bin/rm /usr/tmp/Condition.dat");      \
        	  }                                                     \
}

#define FreeThem(){                                             	\
	int	ndx;							\
		for (ndx = 0; ndx < no_vals; ndx = ndx + 1)     	\
			MyFree (param_vals[ndx]);               	\
		MyFree (param_vals);                            	\
                                                                	\
		if (NoCols > 0){                                    	\
			for (ndx = 0; ndx < NoCols; ndx = ndx + 1)  	\
				MyFree (cols_in_form[ndx].col_name);	\
			for (ndx = 0; ndx < no_vals; ndx = ndx + 1) 	\
				MyFree (vals_in_formula[ndx]);      	\
			MyFree (vals_in_formula);                   	\
		}                                                   	\
}

int  PDUcommand_type ;
int  PDU_cat_selected , PDU_comm_attribs ;
int  multiple_parts ;
Form PDU_desrev_fp;

int SelectOrPlacePart (int flag , IGRboolean  flag1,Form lfp )

	/*******************************************************************

           Persistent form display routine: If invoked first time,
           create the form and set gadget types. 

           Catalog if already selected on PDM/PDU main form, and if the
           catalog on the current form is different update the form.

	*******************************************************************/
{             
	PDU_desrev_fp = lfp ;
	refresh->status = PDM_S_SUCCESS;

	if( flag )
		PDUcommand_type = SELECT_PART;
	else
		PDUcommand_type = PLACE_PART ;

        /* MJG - reset the PDU_command */
        if (flag && PDU_save_command && place_part_f)
          PDU_command = PDU_save_command;

	if ( flag1 )
		multiple_parts = 1 ;
	else 
		multiple_parts = 0 ;

       /* ALR  TR 139312036  In the past a file would be open at this   
         point. Now, with the Retrieve options form a file may not be open.
         This call would cause an EXNUC macro call to fail. */

/* ALR  4/14/94  This could also be called from the revise assembly form */

        if (((lfp == 0) && (forms.ex_file_form_id == 0)) ||
            (lfp != forms.ex_file_form_id) ||
            (lfp != forms.rev_assy_form_id))
	   get_mod_info(&my_env);

	/* If form is already displayed just return */

	if ( form_displayed ) return(1) ;

	if ( place_part_f == NULL )
	{
		/* 	Initialise the forms		   */
		if ( !init_forms(SPpart_F, SPpart_SUB_F, &place_part_f, &exp_list_f,0)) 
			return (0);

		_pdm_debug("created now: ", 0 );

		FIfld_set_text(place_part_f,CATALOG,0,0,"",FALSE);
	   
		/* Unless toggle is set placement mode is normal	*/
		symbol_occurence = 1;
		row_num = 0;

		/* display the form */
		select_part_fun_init();

		lab[0] = LEVEL1 ; 
		no_of_buttons = 1 ;

	}

	if( refresh -> rev_catalog != NULL && strcmp ( refresh -> rev_catalog,"" ))
		_pdm_debug("catalog on entering: %s", refresh -> rev_catalog);
	else
	{
		FIfld_set_text( place_part_f, CATALOG, 0, 0, "", FALSE );
		FIg_disable( place_part_f, TABLE );
	}

	update_form_with_current_catalog();

	switch_off_gdgs(place_part_f);

	/* check whether the catalog selcted on the main form and the	*/
	/* catalog name on this form are same. If not, need to update 	*/
        /* the form							*/

	/* set attributes to save / restore
        sts = FIf_get_attr(place_part_f , &mask);

        mask = mask | FI_SAVE_RESTORE ;

        sts = FIf_set_attr(place_part_f , mask); 
	*/

         /* clear out message field */
         FIg_set_text(place_part_f, FI_MSG_FIELD, NULL_STRING);

        FIf_display ( place_part_f);

	set_active_form_ptr(place_part_f);

/* TR 139416716 - disable placement options button if search is being done
   from the assembly structure form - MJG */
        if ((PDU_calling_form == forms.rev_assy_form_id) &&
            (forms.rev_assy_form_id))
          {
          FIg_disable(place_part_f, PLCMNT_OPTIONS);
          _pdm_debug("PDU_calling_form == forms.rev_assy_form_id", 0);
          }
        else
          FIg_enable(place_part_f, PLCMNT_OPTIONS);

        form_displayed = 1;

	return(1);
}

init_selprt()
{
		grid_list = NULL;
}

update_form_with_current_catalog()
{

	int  i;

	/* If catalog not selected on PDM/PDU main form return */
	cur_level = 1 ;

	if (  Get_text(place_part_f,CATALOG,0,0) ) {
		_pdm_debug("s_text: %s", s_text );

		if( refresh -> rev_catalog == NULL || 
			!strcmp (refresh -> rev_catalog,"") )	{

			mystrcpy(&(refresh -> rev_catalog),s_text);
			return(1);
		}
		else if( !strcmp(s_text, refresh -> rev_catalog ) )
				return(1);
	}

	else if( PDU_comm_attribs ) {

		if( ! GetSelectedRow(exp_list_f,SUB_TABLE,&i))
			return(1);

		/* TR# 139307102 */
		get_row_from_mcf ( i+1, NumAttribs, exp_list_f, SUB_TABLE);

		if( refresh -> rev_catalog == NULL ||
			!strcmp(refresh -> rev_catalog,"") ){

			if( Get_text(exp_list_f,SUB_TABLE,i,0)){
				mystrcpy(&(refresh -> rev_catalog),s_text);
		                FIg_enable( place_part_f, TABLE );
			}
		}
		return(1);				
	}

	if( refresh -> rev_catalog == NULL ||
		!strcmp(refresh -> rev_catalog,"") )
	{
/* TR#92W2154 - SEARCH FOR PARTS - donot remember old catalog */
		FIf_reset( place_part_f );
                FIg_disable(place_part_f, TABLE);
		disable_gadgets( place_part_f );

		return(1);
	}
	
	FIf_reset(exp_list_f);					
	rest_on_cat_selection(place_part_f,1);

	if( refresh -> rev_project != NULL && strcmp(refresh -> rev_project,""))
		FIfld_set_text(place_part_f, PROJECT, 0, 0, refresh -> rev_project, FALSE);

	FIfld_set_text(place_part_f, CATALOG, 0, 0, refresh -> rev_catalog, FALSE);

	/* set the lelvel button for the current catalog in off mode 
	if( refresh -> cat_path != NULL && strcmp(refresh -> cat_path,"")){
		ptr = strtok(refresh -> cat_path, ":" );
		while( ptr != NULL ) {
			ptr = strtok(NULL,":");
			if( ptr != NULL )
				cur_level ++;
		}
	}

	If buttons already added or less than required 
	if( cur_level  > no_of_buttons){
		for( i = no_of_buttons+1 ; i <= cur_level && i < MAX_LEVELS ; ++i ){
			add_level_button(place_part_f, i, lab);
			no_of_buttons++;
		}

		FIg_set_state_on(place_part_f,lab[i-1]);
	}
	else {
		for( i = cur_level +1 ; i <= no_of_buttons ; ++i )
			FIg_delete(place_part_f,lab[cur_level]);
		no_of_buttons = cur_level ;
	}This is not required - KK */

	return( 1 );

}

select_part_fun_init()
{
	/* This function sets the initial field values before the 
	   form is displayed 
	*/

	int	i;

	/* set the parameter column in select mode */
	for (i = 0; i < 3; i++)
		FIfld_set_mode(place_part_f,TABLE, i,FI_SINGLE_SELECT); 


	/* Initialise variables */
	FIfld_set_text(place_part_f,CMP_NAME,0,0,"",TRUE);

	disable_gadgets(place_part_f);

	display_all = 0 ;
}

/* notification routine for place part form */
selprt_notification(int f_label, int g_label, double value, Form fp)
/* f_label :	The label of the form   */
/* g_label :	The label of the gadget */
/* value   :	The value of the gadget */
/* fp	   :	Pointer to the form     */
{
int     row, j;
int	status,select, pos, length;
char *msg = NULL, file[256], cat_type[10], text[40];

/* 23/Nov/93 - raj.	*/
/* Save refresh info to be restored after show graahics is done.	*/
char	*current_catalog = NULL,
	*current_partid = NULL,
	*current_revision = NULL,
	*current_filename = NULL,
	*current_description = NULL;
/************************************************************************/

	_pdm_debug("Enter : selprt_notification", 0);
        PDU_form_id = 0;
        if(IGEresetstop())
         {
	_pdm_debug("IGEresetstop failed = %d", 0);
         }

	_pdm_debug("gadget label = %d", g_label);
	/* FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE); */
	switch ( g_label )  {

		case FI_HELP:     /* Member of group FI_CTRL_GROUP */
         		FIf_cvrt_to_perm_win(fp);
         		status = PDUinitialize_help();
                        if (status != PDM_S_SUCCESS)
                          {
                          PDUmessage(status, 's');
                          return(status);
                          }
         		Help_topic("MOPartSelec2");
         		break;

    		case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */
         		FIf_cvrt_to_perm_win(fp);
	 		break;

		case FI_CANCEL:  
                        /* MJG - save the current command */
                        PDU_save_command = PDU_command;

	                CleanUp ();
			refresh -> status = PDM_E_CMD_CANCELLED ;
                        PDU_command = 0;
			FIg_set_state_off(fp,FI_CANCEL);
			PALerase_form () ;
			delete_window(fp,SKETCH);
			PDU_comm_attribs = FALSE; /*TR#13937056 */
			ret_fromGpart();
			break;
	
		case FI_RESET:
			delete_window(fp,SKETCH);
                   /* ALR TR139313182 */
			reset_forms(place_part_f, exp_list_f,TABLE,refresh -> rev_catalog, refresh->rev_project,NumAttribs, AttrSynonym, AttrList) ;
                        row_num = 0;

                   /* MJG TR139415921 - reset PDUsearch_part_list because the
                      search results have been erased  */
                        if (PDUsearch_part_list)
                          {
                          _pdm_debug("MEMclosing PDUsearch_part_list", 0);
                          MEMclose(&PDUsearch_part_list);
                          PDUsearch_part_list = NULL;
                          }
                      PDUmessage(PDM_E_CLEAR_FIELD, 's');

			switch_off_gdgs(fp);
                        FIf_display(fp);

			break;

		case FI_EXECUTE:
			acc_data(FI_EXECUTE);
			if( PDUcommand_type == SELECT_PART)
				ret_fromGpart();
			break;

		case FI_ACCEPT: 
			if ( !acc_data (FI_ACCEPT) )
			{
				FIg_set_state_off(fp,FI_ACCEPT);
				break;
			}

			FIg_set_state_off(fp,FI_ACCEPT);

                        /* MJG - save the current command */
                        PDU_save_command = PDU_command;

			if( PDUcommand_type == SELECT_PART)
				ret_fromGpart();
		        break;

		case SKETCH:

		        FIf_cvrt_to_perm_win ( fp );     /* Fix for TR#139222800 */
			FIg_get_state( fp, SKETCH, &status );
			if ( status == 0 && MacroDisplayed) /* window is displayed */
			{
				delete_window( fp, SKETCH );
				FIg_set_state_off( fp, SKETCH );
                                FIg_set_text(fp, FI_MSG_FIELD, "");
				break;
			}

			/* 23/Nov/93 - raj. I need this information here. */
			/* Update PDUrefresh structure */
			/* Before that save current refresh info.	*/

                        PrintRefreshInfo();
			PALSaveRefreshInfo(&current_catalog, &current_partid,
						&current_revision, &current_filename,
								&current_description);

			if( !UpdateRefreshStr(place_part_f,TABLE) )
			{
		                msg = (char *)PDUtranslate_message(PDM_I_PRT_SEL_NOT_COMPLETE);
				FIfld_set_text(place_part_f,FI_MSG_FIELD,0,0,msg,0);
				PALRestoreRefreshInfo(current_catalog, current_partid,
							current_revision, current_filename,
							current_description);
				return(0);
			}

                        PrintRefreshInfo();

			if( refresh->rev_catalog == NULL || !strcmp( refresh->rev_catalog,"" ) )
			{ /* if search across catalogs is done */
                          msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
                          FIg_set_text(fp, FI_MSG_FIELD, msg);
 			  FIg_set_state_off( fp, SKETCH );
			  PALRestoreRefreshInfo(current_catalog, current_partid,
						current_revision, current_filename,
						current_description);
			  break;
			}
			if( !Get_text( fp, PART_INDEX, 0, 0 ) || !strcmp( s_text, "0" ) )
			{ /* If no parts selected */
	  	          PDMquery_catalog_type(refresh->rev_catalog, cat_type);
		  	  if( strcmp(cat_type,"P") && strcmp(cat_type,"CID") 
					&& strcmp(cat_type,"PXT")
					&& strcmp(cat_type,"EID"))
			  { /* if it is a standard part */
			    if( GetAttribindx( "p_sketch" ) == -1 )
                              msg = (char *)PDUtranslate_message(PDM_E_NO_SKETCH_FILE);
			    else
                              msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
                            FIg_set_text(fp, FI_MSG_FIELD, msg);
 			    FIg_set_state_off( fp, SKETCH );
			    PALRestoreRefreshInfo(current_catalog, current_partid,
						current_revision, current_filename,
						current_description);
			    break;
			  }
			}
			
			status = GetRleFileName( file );
			if( status && ( strcmp( file, "nil" ) && strcmp (file, "") && strcmp( file, "NULL" )) )
			{ /* if a valid filename is found */
	                        status = PALis_grraster();
        	                if (status != PDM_S_SUCCESS)
				{  /* could not find raster component */
	                          msg = (char *)PDUtranslate_message(PDM_I_GRRASTER_NOT_LOADED);
				  status = 0;
				}
			}
			else if( !status ) /* no valid file found */
                          msg = (char *)PDUtranslate_message(PDM_E_NO_SKETCH_FILE);

			if( status )
			if( !display_fig(SPpart_F,place_part_f,SKETCH,&my_env))
                        {  /* possible File transfer problem */
                          msg = (char *)PDUtranslate_message(PDM_E_LOAD_FILE_INFO);
			  status = 0;
                        }
			if( !status )
			{
                          FIg_set_text(fp, FI_MSG_FIELD, msg);
 			  FIg_set_state_off( fp, SKETCH );
			}

			/* 23/Nov/93 - raj.	*/
			/* Pop-up Show Graphics button, if raster file.	*/
			if (!MacroDisplayed)
				FIg_set_state_off( fp, SKETCH );

			PALRestoreRefreshInfo(current_catalog, current_partid,
						current_revision, current_filename,
						current_description);
			break;

		case TABLE:  
			col = 0 ;
			row = 0 ;
			FImcf_get_active_col ( fp, g_label, &col, &pos );
			FIfld_get_active_row ( fp, g_label, &row, &pos );

			if( row >= NumAttribs )
			break;

			_pdm_debug("Notification Table row: %d",row);
			_pdm_debug("Notification Table col: %d",col);

			ProcessMCF (fp, TABLE, row, col, pos);
			break;

		case  SEARCH:
                        FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
			/* global search i.e., search for all the templates 
			   where n_read set to 'Y'			    */

			max_rows_rtvd = 0;

			display_all = 1;
			/* Function below checks whether the search is on a 
			   single catalog or multiple catalogs and processes */
			PDUmessage( PDS_M_LIST_OF_PARTS, 's' );

/* mjg - added function calls for search format or union attrs 12/93 */
			if (PDU_command == PDS_M_GET_UNION_ATTR)
                          {
                          _pdm_debug("searching all attributes", 0);
                          status = search_on_multiple_ctlgs_with_union(
                                               fp,TABLE,exp_list_f,CATALOG);
                          if (status == 1)
                            PDUmessage(PDM_S_SUCCESS, 's');
                          else
                            PDUmessage(status,'s');
                          }
			else if (PDU_command == PDS_M_GET_LIST_ATTR)
                          {
                          _pdm_debug("searching list attributes", 0);
                          status = search_on_multiple_ctlgs_for_format(
                                               fp,TABLE,exp_list_f,CATALOG);
                          if (status == 1)
                            PDUmessage(PDM_S_SUCCESS, 's');
                          else
                            PDUmessage(status,'s');
                          }
                        else
			  status = search_on_multiple_ctlgs(
                                                 fp,TABLE,exp_list_f,CATALOG);
                          if (status == 1)
                            PDUmessage(PDM_S_SUCCESS, 's');
                          else
                            PDUmessage(status,'s');

			/* after search set gadget state off */
			FIg_set_state_off(fp,SEARCH);

			/*PDUmessage( PDM_E_CLEAR_FIELD, 's' );*/
			break;

/*		 case CLEAR_ALL:
			for( j = 0 ; j < NumAttribs ; ++j )
				FIfld_set_text(fp,TABLE,j,1,"",FALSE);

			break;
*/

		case  EXP_LIST:
			/* display expanded listing form */
		/*	FIg_set_state_off ( fp, EXP_LIST ); */
			FIf_display ( 	    exp_list_f   );
                        FIg_display( exp_list_f, PARAMETERS);
                        FIg_display( exp_list_f, SUB_TABLE);
			break;


		case  PLUS:

			if (row_num == max_rows_rtvd || row_num == 0) {
				FIg_set_state_off(fp,PLUS);
                                msg = (char *)PDUtranslate_message(PDM_E_END_OF_DATA);
				FIfld_set_text (fp, FI_MSG_FIELD, 0, 0, msg, TRUE);
			}
			else {
				row_num = row_num + 1;
				get_row_from_mcf (row_num,NumAttribs, exp_list_f, SUB_TABLE);
				FIg_set_state_off(fp,PLUS);
				FIfld_set_text (fp, 10, 0, 0, "", TRUE);	 

				/* col is forced to 1 always!! Probably a bug in FORMS ? */
				FImcf_set_select(exp_list_f, SUB_TABLE, (row_num - 1), 1);
			}
			break;

		case  MINUS:
			if (row_num == 1 || row_num == 0) 
				FIg_set_state_off(fp,MINUS);	 
			else {
				row_num = row_num - 1;
				get_row_from_mcf (row_num, NumAttribs,
                                                  exp_list_f, SUB_TABLE);
				FIg_set_state_off(fp,MINUS);
				FIfld_set_text (fp, 10, 0, 0, "", TRUE);
			}

			/* col is forced to 1 always!! Probably a bug in FORMS ? */
			FImcf_set_select(exp_list_f, SUB_TABLE, (row_num - 1), 1);
			break;

		case SAVE_CRT:
			if( !NumAttribs )
				break;

			/*PALcritfile(1, NumAttribs);*/
                        PALsavecrit=1;
                        PALgfname();
			break;

		case RESTORE_CRT:
			/*PALcritfile(2, NumAttribs);*/
                        PALsavecrit = 0;
                        PALgfname();
			break;

		case SORT:
                        if (PDUsearch_part_list)
                          {
                          PDUmessage(PDM_I_SEL_SORT_BEFORE_SEARCH, 's');
                          msg = (char *)PDUtranslate_message(
                                        PDM_I_SEL_SORT_BEFORE_SEARCH);
                          FIg_set_text(fp, FI_MSG_FIELD, msg);
                          }
			status = PDUsort_form(NumAttribs,AttrList,AttrSynonym);
                        _pdm_status("PDUsort_form", status);
                        if (status != PDM_S_SUCCESS)
                          {
                          PDUmessage(status, 's');
                          PALis_sort_selected = FALSE;
                          }
			PALis_sort_selected = TRUE ;
			break;

		case CATALOG:
                        PDU_command = 0;
			FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE);
			SelectCatalog (fp, CATALOG);
			FIf_reset(exp_list_f);
			break;

		case PROJECT:
                       PDU_form_id = fp;
                       PDU_refresh_gadgets[0] = PROJECT;
                       PDU_refresh_gadgets[1] = CATALOG;
	               FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE);
			/*select_project();*/
                /* ALR This variable needs to be cleared if field is cleared */
                       FIfld_get_text_length(fp,PROJECT,0,0,&length);
                       FIfld_get_text(fp,PROJECT,0,0,length,(unsigned char *)text, &select, &pos);
                        _pdm_debug("text = <%s>", text);
                       if (!text)
                         refresh->rev_project[0] = '\0';
                       else if (strcmp(text,"") == 0)
                         refresh->rev_project[0] = '\0';
                       else
                         PDUfill_in_string(&refresh->rev_project, text);
        		break;


		case PROJECT_BTN:
         		FIf_cvrt_to_perm_win(fp);
                        PDU_refresh_gadgets[0] = PROJECT;
                        PDU_refresh_gadgets[1] = CATALOG;
			FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE);
                        PDU_active_button = PROJECT_BTN;
                        PDU_form_id = fp;
                        _pdm_debug("Entering LIST_PROJECTS",0);

                       status = PDUep_proj_btn();
                       _pdm_status("PDUep_proj_btn",status);

                       if (status != PDM_S_SUCCESS)
                         FIg_set_state_off(fp, PROJECT_BTN);

                       PDUmessage(status,'s');
		       break;

		case PLCMNT_OPTIONS:
/* TR139418447 - MJG */
                       if (!refresh->rev_catalog)
			 PDUfill_in_string(&refresh->rev_catalog, "");

                       if ( UpdateRefreshStr(place_part_f, TABLE))
                        {
                        PDUget_parttype(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision,
                                        &refresh->rev_parttype);
                        }
			PDUdesign_options_form();
			break;
			
		default:
		_pdm_debug("Coming into default case");
/* mjg - manually turn LEVEL button off 1/4/94 */
                FIg_set_state_off(fp, g_label);
                PDU_command = 0;
			for( j = 0 ; j < MAX_LEVELS ; j = j + 1 ) {
				if( g_label == lab[j] ) {
					FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE);
					cur_level = j + 1 ;
					update_catalog(fp, SPpart_F, &cur_level, g_label,lab);
					if( !display_all )
						FIf_reset(exp_list_f);
				}
			}
			break;
	}
	_pdm_debug("Exit : selprt_notification", 0);
   return(0);
} 

update_catalog(Form fp, int flabel, int *curlevel, int glabel, int lab[])
{

	int sts, i = 0;
	char	*lclcatpath = NULL, *temppath = NULL, *ptr=NULL;

	if( refresh -> cat_path != NULL && strcmp(refresh -> cat_path,"" ) )
		i = strlen( refresh -> cat_path );

	lclcatpath = (char *) malloc ( (i + 1) * sizeof (char));

	MemCheck (lclcatpath);
	lclcatpath[0] = '\0';

	ptr = NULL ;

	if ( refresh -> cat_path != NULL && strcmp(refresh -> cat_path,"") )
	{
		temppath = (char *)malloc(strlen(refresh->cat_path) + 1 );
		strcpy( temppath, refresh->cat_path );
		ptr = strtok ( temppath, ":");
	}

	for (i = 1; i < *curlevel; i++) {

		if( ptr == NULL )
			break;

		if (i > 1)
			strcat (lclcatpath, ":");
		strcat (lclcatpath, ptr);
		ptr = strtok (NULL, ":");		
	}
	

	_pdm_debug("lclcatpath: %s\n", lclcatpath );

         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
begn:
	sts =  DispClsAndCtlgs(fp, flabel, curlevel, &lclcatpath,glabel)  ;

	switch(sts) {

		case CATALOG_SELECTED:

			_pdm_debug("catalog selected",0);
			
/*
			if ( refresh -> cat_path != NULL &&
					strcmp(refresh -> cat_path,"") ) 
			{
				free( (char *) refresh -> cat_path );
				refresh -> cat_path = NULL ;
			}

			refresh->cat_path=
				(char *)malloc(strlen(lclcatpath)+1);

			MemCheck( refresh->cat_path );
 			_pdm_debug("PDMselprt:lclcatpath %s",lclcatpath);

			strcpy(refresh -> cat_path, lclcatpath);
 			_pdm_debug("refresh->cat_path %s",refresh->cat_path);

** Updating the cat_path in refresh is shifted into rest_on_cat_..() * - KK */ 

                        PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
			rest_on_cat_selection(fp,1);
                        PDUmessage(PDM_E_CLEAR_FIELD, 's');
 			_pdm_debug("Exit rest on catalog selection",0);

			_pdm_debug("cur_level: %d", *curlevel );
			_pdm_debug("nobuttons: %d", no_of_buttons );
			_pdm_debug("label: %d", lab[no_of_buttons-1] );

                        /* ALR changed from on to off TR#139313182 */
			FIg_set_state_off(fp,lab[no_of_buttons-1]);
			break;

		case COMM_ATTRIBS:
			PDU_comm_attribs = TRUE ;
			PDU_cat_selected = FALSE ;

			if(NumAttribs < 1 )
				break;
                        PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
			display_attribs(fp,TABLE,NumAttribs,AttrSynonym,AttrList);
                        PDUmessage(PDM_E_CLEAR_FIELD, 's');
			enable_gadgets(fp);
 			FIfld_set_text(fp, CATALOG,0,0,"",FALSE);
 			FIfld_set_text(fp, CAT_DESC,0,0,"",FALSE);
/*
			FIg_reset(fp,CATALOG);
			FIg_reset(fp,CAT_DESC);
*/
			PALis_sort_selected = FALSE ;
			PDU_ComputedID = FALSE ;
			/* Delete macro if displayed */
			if( MacroDisplayed )
				delete_window(fp,SKETCH);
			/* Update the cat_path in refresh and display buttons */
			mystrcpy( &(refresh->cat_path), lclcatpath );
			for( i = 1 ; i < no_of_buttons ; ++i )
				FIg_delete(fp,lab[i]);
			no_of_buttons = 1;
			ptr = NULL;
			ptr = strtok( lclcatpath, ":" );	
			if( ptr != NULL )
				ptr = strtok( NULL, ":" );	
			while( ptr != NULL )
			{
				++no_of_buttons;
				add_level_button(fp,no_of_buttons,lab);
				ptr = strtok( NULL, ":" );	
			}
			break;

		case SUCCESS:
			if(*curlevel +1 != MAX_LEVELS)
				(*curlevel)++;

/* Donot add level button yet, doing in rest_on_cat..() - KK

			if( *curlevel > no_of_buttons ){
				add_level_button(fp,*curlevel,lab);
				++no_of_buttons;
			}
*/
			goto begn;
		default:
			/* show all buttons in off position */ 
                        PDU_command = 0;
			for( i = 0 ; i < no_of_buttons ; ++i ) 
				FIg_set_state_off(fp,lab[i]);
			/*no_of_buttons = 1 ;*/
			break;
	}

	MyFree(lclcatpath);
	return(1);
}

rest_on_cat_selection(Form fp,int flag)
{
int i;
	char *cat_desc = NULL ;
        char cat_type[5];

	/* TR # 1393 01199. Smart View Search to work.			*/
	/* Every time a new catalog is selected, set flag to -1,	*/
	/* to indicate that this view has not been parsed.		*/
	EnableSVS = -1;

	PDU_cat_selected = TRUE ;
	PDU_comm_attribs = FALSE ;
	display_all = 0 ;

	FIg_enable(fp,TABLE);
	FIg_reset(fp,TABLE);
	FIg_reset(fp, PART_INDEX);
/*	if( flag == 1 )
		FIf_reset(exp_list_f);
*/
	/* Delete any previous level buttons except L1  - KK */
	/* Note in case of modify part the no_of_buttons is to be updated */
	for( i = 1 ; i < no_of_buttons ; ++i )
		FIg_delete(fp,lab[i]);
	no_of_buttons = 1;

	/* Now given the catalog name display the level buttons and update the
           refresh structure with the cat_path */

	UpdateCatPath( fp, refresh -> rev_catalog );

	FIfld_set_text(fp, CATALOG,0,0,refresh ->rev_catalog,FALSE);

	GetCatalogDesc(refresh -> rev_catalog,&cat_desc);

/*	TR # 1393 08421 and TR # 1393 09002.				*/
/*	NULL in catalog desc field.	26/jul/'93 - raj.		*/

/*	Set CAT_DESC with null string if cat_desc == NULL.		*/
	if (!strcmp (cat_desc, "NULL"))
		FIfld_set_text(fp, CAT_DESC,0,0,"",FALSE);
	else
		FIfld_set_text(fp, CAT_DESC,0,0,cat_desc,FALSE);

	if( cat_desc != NULL )
		free(cat_desc);

	SetCatAttribs(fp,TABLE);

	_pdm_debug("setcatattribs: OK %s", refresh -> rev_catalog );

	/* if flag == 2 set values also */
	if( flag == 2 )
	{
		GetValsForAttribs(fp,TABLE, DATA_COL);
		display_all = 1;
	}

	/* Set flag to indicate that a new catalog is selected 		     */
	/* This flag is used in 'PDMmodprt.I" which uses these same routines */
	NewCatalogSelected = TRUE;

	/* Since a new catalog is selected, 				*/
	/* free 'SlctdAttrList' and clear 'SlctdAttrNum', 		*/
	/* used in routines related to and in 'UpdateShortList ()'	*/

	CleanUpSlctdAttribs ();

	/* Delete macro if displayed */
	if( MacroDisplayed )
		delete_window(fp,SKETCH);

	enable_gadgets(fp);

	PALis_sort_selected = FALSE ;

	/* Because catalogs with view or avoided in search across common 
	   attributes, it is only ViewOrTblList[0] that needs to be checked.
	*/
        /* get catalog type becuase when catalog is keyed in, no value
           is in ViewOrTblList- jbp*/
        PDMquery_catalog_type(refresh->rev_catalog, cat_type);
        _pdm_debug("cat_type = <%s>", cat_type);

	if( !strcmp(ViewOrTblList[0],"CID") || !strcmp(ViewOrTblList[0],"EID")){
		PDU_ComputedID = TRUE ;
		multiple_parts = TRUE ;
	}
	else if ( !strcmp(cat_type,"CID")  || !strcmp(cat_type,"EID")){
		PDU_ComputedID = TRUE ;
		multiple_parts = TRUE ;
	}
	else
		PDU_ComputedID = FALSE ;
       /* clear out refresh parts */
        PDUfill_in_string(&refresh->rev_partid, NULL);
        PDUfill_in_string(&refresh->rev_revision, NULL);
        PDUfill_in_string(&refresh->rev_parttype, NULL);
        PDUfill_in_string(&refresh->rev_filename, NULL);
        PDUfill_in_string(&refresh->rev_description, NULL);
		
}

acc_data(glab)
int glab ;
{
       char *msg;

	/* Delete macro if displayed */
	if( MacroDisplayed )
		delete_window(place_part_f,SKETCH);

	/* Update PDUrefresh structure */
/* mjg - added check for PDUsearch_part_list - UpdateRefreshStr core dumps if
   search is incomplete - 1/4/94 */
        if (PDUsearch_part_list)
          {
	  if( !UpdateRefreshStr(place_part_f,TABLE) ){
                msg = (char *)PDUtranslate_message(PDM_I_PRT_SEL_NOT_COMPLETE);
		FIfld_set_text(place_part_f,FI_MSG_FIELD,0,0,msg,0);
		return(0);
	    }
          }
        else
          {
          msg = (char *)PDUtranslate_message(PDM_I_PRT_SEL_NOT_COMPLETE);
          FIfld_set_text(place_part_f,FI_MSG_FIELD,0,0,msg,0);
          return(0);
          }

	_pdm_debug("multiple_parts : %d", multiple_parts );
	_pdm_debug("display_all : %d ", display_all );
	_pdm_debug("command_type : %d", PDUcommand_type);
	
	/* see if a part is uniquely selected  */
	if ( 
	     /* in case of multiple parts, global 'search' shoule be done */
	     (
	      multiple_parts && !display_all 
	     ) 
	     || 
	     /* in case of single part partid and revision must be selected */
	     (
	     !multiple_parts && 
	     !(refresh -> rev_partid && refresh -> rev_revision)
	     )
	   )
	{      /* single part - ID and revision should be selected */

/*	23/Nov/93 - raj. Converted warn box to a message to form.	*/
/*		FlashMessage (PDR_E_nDef);				*/
                msg = (char *)PDUtranslate_message(PDR_E_nDef);
		FIfld_set_text(place_part_f,FI_MSG_FIELD,0,0,msg,0);
       	        return(0); ;
        }

        if( glab == FI_ACCEPT )
         	 PALerase_form () ;

	/* BREAK HERE FOR SELECT PART AND PLACE PART COMMANDS  */

	if( PDUcommand_type == SELECT_PART )
		return(1);


	/* If part type is not parameteric, return */

	if( ! UpdatePartType(place_part_f,TABLE,refresh -> rev_catalog))
		return(0);

	_pdm_debug("part type : %s", refresh -> rev_parttype );
	_pdm_debug("catalog : %s", refresh -> rev_catalog );

	{
		int             responses[1]	;
		char            *strings[1];		

		if( strcmp(refresh -> rev_parttype,"P")
			&& strcmp(refresh -> rev_parttype,"PXT")
			&& strcmp(refresh -> rev_parttype,"CID")
			&& strcmp(refresh -> rev_parttype,"EID")	)
		{
			PDU_command = PDC_M_PLACE_PART;
			responses[0] = EX_CMD_KEY;
			strings[0] = "PDPPr";
		}
	 	else
 		{
 			PDU_command = PDC_M_PLACE_PPART;
	 		responses[0] = EX_CMD_KEY;
 			strings[0] = "PDPPPr";
 			/* Set the PALMacintf flag to '0' */
	 		PALMacintf = 0;
 		}
	PDUprepare_queue(responses,strings,1);
	return(1);
	}
/*
	if(!PALplace_part(refresh -> rev_catalog,refresh -> rev_partid,
				refresh -> rev_revision,&my_env, place_part_f,0))
		return(0);

	return( 1 );
*/
}

/*
PALplace_part(char *lcatalog,char *lpartid,char *lpartrev,struct GRmd_env *lenv,
		Form fp, int Intflag )
*/

LoadLib_N_PrepareAttribs( lenv, fp, list_coll, hdr, num_coll )
struct GRmd_env *lenv;
Form fp;
struct GRid **list_coll, *hdr ;
int *num_coll;
{
	char *lcatalog = NULL, *lpartid = NULL, *lpartrev = NULL;
        char *msg;

	_pdm_debug("Enter LoadLib_N_PrepareAttribs()",0);

	mystrcpy( &lcatalog, refresh->rev_catalog );
	mystrcpy( &lpartid, refresh->rev_partid );
	mystrcpy( &lpartrev, refresh->rev_revision );

	if( !PDUgetDefPlcmntName(&part_no,lcatalog))
		_pdm_debug("No default name for Placement",0);
	else
		_pdm_debug("default name for Placement %s",part_no);

	/* copy and load macro libraries relevant to catalog */	
	if( !copy_and_load_macro_lib(lcatalog))
		return(0) ;

	_pdm_debug("Macro library attached", 0);

	if( !GetStatAndDynAttribs (lcatalog ,&Num_Stat,&StatAttribs,
				&StatTypes,&StatDesc,&StatUnits,
				&Num_Dyn, &DynAttribs, &DynAttribTypes,
				&DynAttribDesc))
		return(0); 


	/* Get macro name from 'catalog' table has attribute by 
	   name 'macro'  else get from 'pdmparamloc' table	*/

	if ( !get_macro_name(macname,lcatalog,fp,TABLE,DATA_COL) )
		return(0);

	_pdm_debug("Macro name %s",macname);

        if (! get_mac_hdr (macname,hdr,lenv))
		return(0);

	if (!GetOriginalMacroInfo( hdr, &MAC_temp_desc, &MAC_num_temp,
					&num_loc, num_coll ))
		return(0);  

	if( *num_coll == 0 ) 
	{
                msg = (char *)PDUtranslate_message(PDM_E_PART_UNEDITED);
		warn_box(msg);
		return(0);
	}

	/* Create the necessary collections for the macro */
	if( !CreateCollections( lenv, list_coll, *num_coll ))
		return(0);

	PALchild_no = NULL;
	/* add standard attributes to the collections */
	if(!AddStdAttribsToColl( *list_coll, *num_coll, lcatalog, 
				lpartid, lpartrev,lenv ))
		return(0);

	_pdm_debug("Calling GetStaticAttribsAddToRgObj",0);

	/* Query for static templates list from pdmparameters table */
	if( PDU_ComputedID == FALSE )
	{
		if( ! GetStaticAttribsAddToRgObj( hdr, StatAttribs, StatTypes,
					StatUnits,Num_Stat,*list_coll) )
		{
			_pdm_debug("Error creating static attribs in rg_collect",0);
			return(0);
		}
	}
	else
	{
		/* Read Static Attrib Vals from the form and Add to Coll */
		if( !ReadStatAttribsonForm( refresh->rev_catalog, fp, TABLE, StatAttribs, StatTypes,
					StatUnits,Num_Stat,*list_coll))
		{
                	_pdm_debug("Error creating static attrs in rg_collect",0);
	                return(0);
        	}
	}
        if ( PDU_auto_part_selection == TRUE  )
        {
                _pdm_debug("Calling Add_slct_crit",0);
/* Get the selection criteria from the form, translate it and then Add the 
   criteria for each cat attribute and any expr objects in the criteria as
   templates to the first collection
*/
  	       	if( !Add_slct_crit( fp, TABLE, *list_coll, lenv,
				AttrList, AttrSynonym, NumAttribs,
				refresh->rev_catalog ))
			return(0);

		if( *num_coll > 1 )
			selection_temp_to_ACdyncol( NumSelTemp,SelTemplist,*list_coll,
							lenv, *num_coll); 
        }
	else
		NumSelTemp = 0;

	_pdm_debug("Returning from LoadLib_N_PrepareAttribs()",0);

	return(1);
}

SetDynAttrs( list_coll, num_coll, grid_list, numtemp )
struct GRid *list_coll, **grid_list;
int *numtemp, num_coll;
{
	if ( ! AddDynattrsToColl( MAC_temp_desc, list_coll, num_coll, MAC_num_temp,
					  num_loc, grid_list, numtemp ))
		return( 0 );

	PDU_auto_part_selection = FALSE;
	return(1);
}

Instance_Macro( fp, env, hdr, rg_grid, numgrids, numcol )
Form fp;                    /* Active form ptr, place/replace form */
struct GRid *hdr, *rg_grid; /* header and the collection grid list */
struct GRmd_env *env;       /* Module env */
int numgrids, numcol;       /* Total number of grids in grid_list and rg_grid */
{
int sts;

char **vals, **names, **types;
int  noattr = 0, i, j;
char *computed_id = NULL;

/* Added on 04/04/93 */
	_pdm_debug(" refresh->rev_partid = :%s:",refresh->rev_partid);

	if( !strcmp (refresh->rev_partid, "computable") )
	{
		/* TR # 139308062. 03/aug/93 - raj.		*/
	/*	TR # 13938062.	03/aug/93 - raj.	*/
#define	GET_flag	0
#define	SET_flag	1
#define	THROUGH_PLACE_PART	0
#define	THROUGH_REPLACE_PART	1

		int	command_flag;
		SetOrGet_command_flag (&command_flag, GET_flag);
		/************************************************/
		/* get the dynamic attributes list */
		ReadAtrsFromCols(&rg_grid[numcol-1], &names, &types, &vals, &j );
		noattr = j + NumAttribs;

		_pdm_debug( "Total attribs = %d", noattr);

		vals  = (char **)realloc(vals,sizeof(char *) * noattr);
		names = (char **)realloc(names,sizeof(char *) * noattr);
		types = (char **)realloc(types,sizeof(char *) * noattr);
		
		/* append the static & catalog attributes */
		for( i = 0 ; i < NumAttribs; i++, j++ )
		{
			/* TR # 139308062. 03/aug/93 - raj.		*/
			if (command_flag == THROUGH_REPLACE_PART)
			{
				vals[j] = (char *) malloc ((strlen (AttrValsRep_PPart[i]) + 1) * sizeof(char));
				strcpy (vals[j], AttrValsRep_PPart[i]);
				_pdm_debug ("Get value from array", 0);
			}
			else if (command_flag == THROUGH_PLACE_PART)
			{
				Get_text(fp,TABLE,i,1);
				vals[j] = (char *) malloc ((strlen (s_text) + 1) * sizeof(char));
				strcpy (vals[j], s_text);
				_pdm_debug ("Got value from from", 0);
				
			}
			names[j] = (char *)malloc(strlen(AttrList[i]) + 1 );
			types[j] = (char *)malloc(strlen(AttrTypes[i]) + 1 );
/*	TR # 139308062.	03/aug/93. Commented out the following
			vals[j]  = (char *)malloc(strlen(s_text) + 1 );
*/
			strcpy( names[j], AttrList[i] );
			strcpy( types[j], AttrTypes[i] );
/*	TR # 139308062.	03/aug/93. Commented out the following
			strcpy( vals[j], s_text );
*/
		}
		
		/* TR # 139308062. 03/aug/93 - raj.		*/
		command_flag = THROUGH_PLACE_PART;
		SetOrGet_command_flag (&command_flag, SET_flag);

		/* Free AttrValsRep_PPart[].	*/
		/* 17/may/1994 - raj.	*/
		if (AttrValsRep_PPart != NULL)
		{
			int	i;
			for (i = 0; i < NumAttribs; i++)
				free ((char *) AttrValsRep_PPart[i]);
			free ((char *) AttrValsRep_PPart);
		}
		/************************************************/
		_pdm_debug("Calling GetID_N_Compute",0);

		sts = GetID_N_Compute(refresh->rev_catalog, names, vals, types, noattr, &computed_id,0 );

		if( sts )	
		        add_attribute(rg_grid, computed_id, "n_itemname",AC_ATTRIB_TEXT);
		else
			_pdm_debug("ComputeID failed",0);	

		MyFree(computed_id);
	}
	else
		sts = 1;
/* end */
	if( sts )
	{
	        _pdm_debug("Calling place_macro",0);
	       	sts = place_macro(env, numgrids, hdr, grid_list,
                	    ismacro, PDU_placement_type, macname, part_no) ;
	}

	if( sts )
	{
		PDUupdate_parametric_tag(env->md_id.osnum,PDU_tagno);
		PDUincrement_child_no( env->md_id.osnum );
	}

	if( PDU_desrev_fp != NULL )
		ret_fromGpart();

        return(sts);
}

/* Modified this function arguments and also its body ------ KK 11/06/92 ***/

Add_slct_crit(Form fp, int mcf, struct GRid  *rg_grid, struct GRmd_env *env,
		char **cat_attr,  char **cat_desc, int no_cat_attr,
		char *catalog_name )
{
	int no_of_attrs,tbl_no,sts  ;
	char **list_of_attr, **attr_type, viewORtable[6] ;
        int i,j, num_exp_objs , ind ;
        char **temp_val, **attr_desc, oper[15],tmp_str[200];
        struct GRid sel_grid[30], *exp_list  ;

	_pdm_debug("Enter Add_slct_crit()",0) ;

	/* If search across common attributes, get all catalog attributes
           with n_read = 'y' 
	*/

	if( PDU_comm_attribs ) 
	{
		GetCatTableNo( catalog_name , &tbl_no, viewORtable);

		GetCatAttribs(tbl_no, &list_of_attr, &attr_desc, &attr_type,
						 &no_of_attrs);
	}
	else 
	{
		list_of_attr = cat_attr;
		attr_desc    = cat_desc;
		no_of_attrs  = no_cat_attr;
	}

	/* For each attribute of n_read = 'Y', get the selection criteria */

	_pdm_debug("building search criteria ", 0);

	temp_val = (char **)malloc( no_of_attrs * sizeof(char *));
	MemCheck( temp_val );

        for( i = 0 ; i < no_of_attrs ; i = i + 1 ) 
	{
		if( PDU_comm_attribs )
			ind = get_index_of_attr(list_of_attr,attr_desc,i);
		else
			ind = i;

		if( ind != -1 && Get_text(fp,mcf,ind,3) ) 
		{
			_pdm_debug("criteria: %s", s_text);
			_pdm_debug(" strlen %d ",strlen(s_text));

			temp_val[i] = (char *)malloc(strlen(s_text)+20);
			strcpy(temp_val[i], s_text);

			if(Get_text(fp,mcf,ind,OPER_COL))
			{
				strcpy(oper,s_text);
				define_Aoperator(oper,tmp_str);
			}
			else
				strcpy(oper,"=");

			_pdm_debug("oper = %s",oper);
		
			strcpy(tmp_str,oper);
			strcat(tmp_str,",");
			strcat(tmp_str,temp_val[i]);
			strcpy(temp_val[i],tmp_str);
                }
                else
		{
			temp_val[i] = (char *)malloc(10);
                	strcpy(temp_val[i], "=,0");
		}

		_pdm_debug("temp_val: %s", temp_val[i]);
        }


        change_text_to_index(no_of_attrs,temp_val,sel_grid,&num_exp_objs,
								env);
	
	exp_list = (struct GRid *)malloc( sizeof( struct GRid) *
				 (no_of_attrs + num_exp_objs + 3));
	MemCheck( exp_list );

#ifdef PDEBUG
	printf("no_exps alloced: %d",(no_of_attrs + num_exp_objs +3));
#endif

	/* First create one exp object for criteria of each static attribute
	   of catalog ( to be made template to ACdyn_col ).
	*/

	for( i = 0 ; i < no_of_attrs ; ++i ) 
	{
		exp_list[i].osnum = env->md_id.osnum ;
		if(!create_expression("",temp_val[i],&exp_list[i],2))
		{
			sts = 0;
			goto wrapup;
		}
	}


        /* make all individual exp objects in the criteria as
           templates to enable compute to be kicked off when
           one of the them are modified 
	   add each individual expression object to template list of
	   ACdyn_col
	*/

	for( j=0; j < num_exp_objs  ; ++j )
		exp_list[j+i] = sel_grid[j];

	NumSelTemp = j + i;  /* no_of_crit + no_of_exps */
	SelTemplist = exp_list;

/*	selection_temp_to_ACdyncol(i,exp_list,rg_grid,env); */
	
	sts = 1;

wrapup:

	FreeArrayPtr(temp_val,no_of_attrs);
/*	MyFree( exp_list );	*/
	return(sts);
}


get_index_of_attr(list_of_attr,attr_desc,ind)
int ind;
char **list_of_attr , **attr_desc ;

{
	int i;

	for( i = 0 ; i < NumAttribs ; ++i )
		if( !strcmp(AttrList[i],list_of_attr[ind]) ||
		    !strcmp(AttrSynonym[i],attr_desc[ind] ) )
			return(i); 

	return(-1);
}

CreRgcolAddStdAttribs(	struct GRid *rg_collect_grid, int numcoll, char *partno, 
		      	char *catalog_name, char *n_itemno, char *n_revision,
			struct GRmd_env *lenv,char *child_no )

	/* Function to create ACrg_collect object 
	   and create nfm required attributes    */
{
	/* Create ACrgcollect class object first */

	if (child_no != NULL)
		_pdm_debug("childno = %s", child_no );
	if (partno != NULL)
		_pdm_debug("partno = %s", partno );

	rg_collect_grid -> objid = NULL_OBJID ;

	if( ! PDUcreat_rgbox("", lenv,rg_collect_grid) ) {
		_pdm_debug("PDUcreat_rgbox failed",0);
		return(0);
	}
	_pdm_debug("PDUcreat_rgbox success",0);

	/* Add standard attributes to ACrg_collect object */

	AddStdAttribsToColl(rg_collect_grid, numcoll, catalog_name, n_itemno,
				   n_revision, lenv );

	return(1);
}

AddStdAttribsToColl(struct GRid *rg_collect_grid, int numcoll,
		      	char *catalog_name, char *n_itemno, char *n_revision,
			struct GRmd_env *lenv )

	/* Function to create ACrg_collect object 
	   and create nfm required attributes    */
{
char	*child_tno = NULL ;
char    attach[4];

	if (PALchild_no == NULL)
		PDUgenerate_child_no (&child_tno, lenv ->md_id.osnum);
	else
		child_tno = PALchild_no ;

	_pdm_debug( " child no: %s", child_tno );

	/* Add standard attributes to ACrg_collect object */
        add_attribute(rg_collect_grid, catalog_name, "n_catalogname",AC_ATTRIB_TEXT);

	if( strcmp(n_itemno,"computable"))
	        add_attribute(rg_collect_grid, n_itemno, "n_itemname",AC_ATTRIB_TEXT);

        add_attribute(rg_collect_grid, n_revision,   "n_itemrev",AC_ATTRIB_TEXT);

        add_attribute(&rg_collect_grid[numcoll-1], child_tno,   "serial_no",AC_ATTRIB_TEXT);
        add_attribute(&rg_collect_grid[numcoll-1], PDU_incl_BOM, "p_incbom",AC_ATTRIB_TEXT);
        add_attribute(&rg_collect_grid[numcoll-1], PDU_incl_ASM, "p_incstr",AC_ATTRIB_TEXT);	

	if( PDU_attach )
		strcpy(attach,"Y");
	else
		strcpy(attach,"N");

	_pdm_debug("PDU_attach: %s", attach );

        add_attribute(&rg_collect_grid[numcoll-1],attach,"p_attach",AC_ATTRIB_TEXT);	

	_pdm_debug("Added standard attributes: ", 0 );

	return(1);
}

get_mac_hdr(macname,hdr,lenv)
char *macname ;
struct GRid *hdr ;
struct GRmd_env *lenv ;
{

	if (!GetMacroHeaderGivenName (macname,lenv,hdr))
	{
		PDUmessage( PDM_E_MACRO_NOT_FOUND, 's' ); /* TR#1393 07116 */
		return (0);
	}

	GetMacroType(hdr,&ismacro);

    	return(1);
}


PALerase_form()
{
   if( form_displayed ){
       form_displayed = 0 ;
       FIf_erase( place_part_f );
       FIf_erase( exp_list_f );
   }
   return ;
}


get_feet_num_for_symb(src_dir,filename,numft)
char *src_dir, *filename ;
int *numft ;
{
    FILE *f1 ;
    char file_name[200],nme[20];
    int i,v1,v2,v3,v4 ;

    sprintf(file_name,"%s/%s",src_dir,filename);

    *numft = 0 ;

    f1 = fopen(file_name,"r");

    if( f1 == NULL ) return ;

    i = fscanf(f1,"%s %d %d %d %d\n",nme,&v1,&v2,&v3,&v4 );

    while ( i != EOF ){
         *numft = *numft + 1 ;
         i = fscanf(f1,"%s %d %d %d %d\n",nme,&v1,&v2,&v3,&v4 );
    
    }

    fclose(f1);
}

select_project(fp)
Form fp ;
{
	int sts, ind ; 
	char *prject; 
        char *msg;

	/* Get list of projects */

	sts = PDMproject_catalog_listing("",refresh ->rev_catalog,"proj_list");
	if( sts != PDM_S_SUCCESS ) {
                msg = (char *)PDUtranslate_message(PDM_E_SEL_PROJECT);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0) ;
	}

	if( (sts = MEMbuild_array(PDU_ret_buffer) ) != MEM_S_SUCCESS ) {
		_pdm_debug("MEMbuild_array_error: status = %d",sts );
		return(0);
	}

	/* display in a pull down list, existing projects */
	pull_main( SPpart_F, fp, PROJECT, 0, 0,
		   (char **) PDU_ret_buffer -> data_ptr,
		   PDU_ret_buffer->rows,0,0,5,&sts,&ind );
      
	if( !sts ) return(0);

	prject = ((char **) PDU_ret_buffer -> data_ptr)[PDU_ret_buffer -> columns + ind] ;

	FIfld_set_text(fp,PROJECT,0,0,prject, FALSE);

	/* Update PDUrefresh structure */


	if( refresh -> rev_project != NULL ) 
		refresh -> rev_project = (char *)realloc(refresh -> rev_project,
							strlen(prject) + 1 );
	else
		refresh -> rev_project = (char *)malloc(strlen(prject) + 1 );

	strcpy(refresh -> rev_project ,prject );

	MEMclose(&PDU_ret_buffer);

	return(1);
}


mystrcpy(str1,str2)
char **str1,*str2;
{

	if( ((*str1) != NULL) && strcmp(*str1,"") ) 
		free( *str1 );

	(*str1) = malloc(strlen(str2) + 1 );
	
/*	else 
		(*str1) = realloc( (*str1), strlen(str2) + 1 );
*/


	strcpy( (*str1), str2);
}
	
GetAttribindx(colname)
char *colname;
{

	/* Given column name, finds the index and gets the value from 
	   Value column on select part form
	*/

	int i;

	for( i = 0 ; i < NumAttribs ; ++i ) 
		if(!strcmp(AttrList[i],colname))
			return(i);

	return(-1);
}

UpdateRefreshStr(Form fp, int glabel)

	/* On selecting a part, this routine updates PDUrefresh structure */
{

	int ind ;
	char *ptr, *itemname;
	char cat_type[5];

	/* This is required here because, the user can place more than one part from
           the same catalog at any time. - kk
	*/

        PDMquery_catalog_type(refresh->rev_catalog, cat_type);
        _pdm_debug("cat_type = <%s>", cat_type);
	if( !strcmp(cat_type,"CID") || !strcmp(cat_type,"EID"))
		PDU_ComputedID = TRUE ;

	ind = GetAttribindx("n_itemname");
	_pdm_debug("part number ind: %d ", ind);
	if( (ind != -1) )
	{
		if( ! Get_text(fp,glabel,ind,1) )
			return(0);
		itemname = s_text;
	}
	else if( !PDU_ComputedID )  /* n_itemname should not be turned off */
		return(0);
	else 			    /* n_itemname turned off for a CID/EID catalog */
		Getpartnumber( refresh->rev_catalog, &itemname,0 );
		
	if( PDU_ComputedID) 
	{
		ptr = itemname;
		while( *ptr )
			if( *ptr++ == '$' )
				break;
		if( *ptr == '\0') /* Not a formula */
		{
/*			PDU_ComputedID = FALSE; cannot do this - PDMNORM 'dave' problem */
			mystrcpy(&refresh -> rev_partid,s_text);/* PDMNORM case */
		}
		else
		{
			mystrcpy(&refresh -> rev_partid,"computable");
			mystrcpy(&lCID,s_text);
		}
	}
	else
		mystrcpy(&refresh -> rev_partid,itemname);

	_pdm_debug( "part number : %s", refresh -> rev_partid );

	ind = GetAttribindx("n_itemrev");
	_pdm_debug("part revision ind: %d ", ind);

	if( ind == -1 ) return(0);

	if ( ! Get_text(fp,glabel,ind,1) )
		return(0);

	mystrcpy(&refresh -> rev_revision,s_text);

	_pdm_debug("Part revision: %s", refresh -> rev_revision );

        PDUget_filename_for_part(refresh->rev_catalog, refresh->rev_partid, 
                                 refresh->rev_revision, &refresh->rev_filename);
	ind = GetAttribindx("n_itemdesc");
	_pdm_debug("part description ind: %d ", ind);

	if( ind == -1 ) return(1);

        if ( ! Get_text(fp,glabel,ind,1) )
          {
          _pdm_debug("desc field is empty; setting refresh to NULL_STRING", 0);
          mystrcpy(&refresh -> rev_description,"");
                return(1);
          }

	mystrcpy(&refresh -> rev_description,s_text);

        _pdm_debug("setting description to: %s", refresh -> rev_description );
	_pdm_debug("Part revision: %s", refresh -> rev_revision );

	/* Fill child buffer */
	return(1);
}


/* This routine seperates exp (both double and text) type templates and
   locate type templates, and fills the global MEMbuffer PALdyn_bufr.
*/

BreakLocAndNonLocDYn( int num_coll, int **loc, char ***prompts, int *numloc )
{
	long sts ;
	int  i, k, alloc_size, alsize1 ;
	char *str = NULL ;
	char *str1 = NULL ;

	int	is_template;
	int	p_macro_exists = 0;

	_pdm_debug("ENTER: BreakLocAndNonLocDYn()", 0);

	PALdyn_bufr = NULL;
	filterbuf = NULL;

	if( (PDUcreate_dynamic_attr_buffr(&PALdyn_bufr) ) != PDM_S_SUCCESS )
	{
		_pdm_debug("Error formatting the buffer\n",0);
		return(0);
	}

	str = malloc(512);
	str[0] = '\0' ;
	alloc_size = 512 ;

	*numloc = 0;
	*loc = (int *) malloc( sizeof( int ));
	*prompts = ( char ** ) malloc( sizeof (char *) );

	/*
	 * Find if the catalog has 'p_macro' attribute.
	 * This is used to decide whether to filter dynamic attributes or not.
	 * 03/Dec/93 - raj.
	 */
   	for( i = 0, p_macro_exists = 0; i < NumAttribs ; i = i + 1 )
   	{
          if (!strcmp (AttrList[i], "p_macro"))
          {
            p_macro_exists = i;
            _pdm_debug("p_macro attr exists", 0);
            break;
          }
        }
	
	for( i = 0 ; i < Num_Dyn ; ++ i ) 
	{
		/* If the template dyn_temp[i] is not a template to the macro
			to be placed skip it.
		*/

/*	We're failing to weed out the locatable templates.	*/
/*	Hence the flag 'is_template'. To be used later.		*/
/*	30/aug/93 - raj.					*/
/*        	if ( get_temp_index(MAC_temp_desc,DynAttribs[i],MAC_num_temp) < 0 )*/
/*
 *	DO NOT filter an attributes EVEN if it is NOT a template to macro
 * 	under following conditions:
 * 	If the macro is 'Vdaps' ci-macro of PDMNORM or some such specialized
 * 	macro. Which does not have any expression templates (mapped to its
 * 	collections) but the catalog contains dynamic attributes which are
 * 	needed for its placement. In other words it might not be an edited
 * 	macro whose original expression templates are mapped to collections
 * 	at Create Catalog time.
 * 	We will use the absense of 'p_macro' attribute as an idicator to such
 * 	specialized macros. If the catalog does not have the 'p_macro'
 * 	attribute then BYPASS the filtering process even if the attribute is
 * 	NOT a template to the macro.
 * 	ASSUMPTION: A specialized (ci)macro such as a Vdaps ci-macro will be
 * 	the ONLY macro attached to a catalog. Hence no p_macro attribute.
 * 	03/Dec/93 - raj.
*/
		is_template = get_temp_index(MAC_temp_desc,DynAttribs[i],
								MAC_num_temp);
		if ((is_template < 0 ) && p_macro_exists)
		{
			_pdm_debug("Dyn attr filtered: %s", DynAttribs[i]);

			if( (PDUcreate_dynamic_attr_buffr(&filterbuf) ) != PDM_S_SUCCESS )
			{
				_pdm_debug("Error formatting the buffer\n",0);
				return(0);
			}

			str1 = malloc(512);
			str1[0] = '\0' ;
			alsize1 = 512;

			if(!strcmp(DynAttribTypes[i],"Expression double")  || 
				!strcmp(DynAttribTypes[i],"Expression text") )
			{
				if( ( strlen(DynAttribTypes[i]) + 
				      strlen(DynAttribDesc[i]) + 
				      strlen(DynAttribs[i]) + 20   )  > alsize1 )
				{
					alsize1 = strlen(DynAttribTypes[i])
					     	+ strlen(DynAttribDesc[i]) 
					     	+ strlen(DynAttribs[i]) + 20 ;

					str1 = realloc(str1,alsize1);
				}

				strcat(str1,DynAttribs[i]);
				strcat(str1,"\1");
				strcat(str1,DynAttribTypes[i]);
				strcat(str1,"\1");
				strcat(str1,DynAttribDesc[i]);
        	                for(k=0;k<6 ; ++k )
                	               strcat(str1,"\1");
                        	if(strcmp(DynAttribTypes[i],"Expression text"))
                	               	strcat(str1,"N"); /* put n_null = "N" */
	                        for(k=0;k<7; ++k )
        	                       strcat(str1,"\1");

				_pdm_debug("BreakLocNonLOc:write str %s",str1);

				if( (sts = MEMwrite(filterbuf,str1)) != MEM_S_SUCCESS)
				{
					_pdm_debug("MEMwrite Error : status %d\n",sts);
					MEMclose(&filterbuf);
					free(str1);
					return(0);
				}

				str1[0] = '\0' ;
	       	        	continue ;
			}
		}

		_pdm_debug("Dyn temp type: %s", DynAttribTypes[i]);

		if(!strcmp(DynAttribTypes[i],"Expression double")  || 
			!strcmp(DynAttribTypes[i],"Expression text") )
		{
			if( ( strlen(DynAttribTypes[i]) + 
			      strlen(DynAttribDesc[i]) + 
			      strlen(DynAttribs[i]) + 20   )  > alloc_size )
			{
				alloc_size = strlen(DynAttribTypes[i])
					     + strlen(DynAttribDesc[i]) 
					     + strlen(DynAttribs[i]) + 20 ;

				str = realloc(str,alloc_size);
			}

			/* TR # 139312520. 04/Nov/93 - raj.	*/
			/* Convert dyn attr name to lowercase.	*/
			{
			char	temp[32];
			strcpy (temp,DynAttribs[i]);
			strcat(str, to_lower(temp));
			}
			strcat(str,"\1");
			strcat(str,DynAttribTypes[i]);
			strcat(str,"\1");
			strcat(str,DynAttribDesc[i]);
                        for(k=0;k<6 ; ++k )
                               strcat(str,"\1");
                        if(strcmp(DynAttribTypes[i],"Expression text"))
                               strcat(str,"N"); /* put n_null = "N" */
                        for(k=0;k<7; ++k )
                               strcat(str,"\1");

			_pdm_debug("BreakLocNonLOc:write str %s",str);

			if( (sts = MEMwrite(PALdyn_bufr,str)) != MEM_S_SUCCESS)
			{
				_pdm_debug("MEMwrite Error : status %d\n",sts);
				MEMclose(&PALdyn_bufr);
				free(str);
				return(0);
			}

			str[0] = '\0' ;
		}

/*	Else it is a locatable template.			*/
/*	If 'is_template' == -1 ; this entry is NOT a template	*/
/*	to this macro.			30/aug/93 - raj.	*/

		else  if (is_template != -1)
		{
			*loc = (int *) realloc(*loc, (*numloc+1) * sizeof(int));
			*prompts = ( char ** ) realloc( *prompts, 
						(*numloc+1) * sizeof( char * ));

			if( strcmp(DynAttribTypes[i],"Point") == 0 ) 
				(*loc)[*numloc] = POINT_TYPE;
			else if( strcmp(DynAttribTypes[i],"Coord sys") == 0 )
				(*loc)[*numloc] = CS_TYPE;
			else if( strcmp(DynAttribTypes[i],"Line") == 0 ) 
				(*loc)[*numloc] = LINE_TYPE;
			else if( strcmp(DynAttribTypes[i],"Conic") == 0 ) 
				(*loc)[*numloc] = CONIC_TYPE;
			else if( strcmp(DynAttribTypes[i],"Circle") == 0 ) 
				(*loc)[*numloc] = CIRCLE_TYPE;
			else if( strcmp(DynAttribTypes[i],"Arc") == 0 ) 
				(*loc)[*numloc] = ARC_TYPE;
			else if( strcmp(DynAttribTypes[i],"Lbs") == 0 ) 
				(*loc)[*numloc] = LBS_TYPE;
			else if( strcmp(DynAttribTypes[i],"Plane") == 0 ) 
				(*loc)[*numloc] = PLANE_TYPE;
			else if( strcmp(DynAttribTypes[i],"Surface") == 0 ) 
				(*loc)[*numloc] = SURF_TYPE;
			else if( strcmp(DynAttribTypes[i],"Curve") == 0 ) 
				(*loc)[*numloc] = CURVE_TYPE;
			else if (strcmp(DynAttribTypes[i],"Macro") == 0 )
				(*loc)[*numloc] = MACRO_TYPE;
			else if( strcmp(DynAttribTypes[i],"Solid") == 0 ) 
				(*loc)[*numloc] = SOLID_TYPE;
			else if( strcmp(DynAttribTypes[i],"ref_cimacro") == 0 ) 
				(*loc)[*numloc] = REFCI_TYPE;
			else if( strcmp(DynAttribTypes[i],"graph") == 0 ) 
				(*loc)[*numloc] = GRAPH_TYPE;
			else
				(*loc)[*numloc] = UNKNOWN_TYPE;
		
			(*prompts)[*numloc] = DynAttribDesc[i];

			_pdm_debug("dynamic locatable temp indx: %d",
					 (*loc)[*numloc] );
			_pdm_debug("prompt is :%s:",(*prompts)[*numloc]);
			(*numloc)++;
		}
	}

	if( filterbuf && PDMdebug_on )
		MEMprint_buffer( "filterbuf: ", filterbuf, PDU_DEBUG_FILE );

	MyFree( str1 );
	free(str);
	num_loc = *numloc;

	return(1);
}

/* Here, the dynamic exp templates are defined to the input dyncol */

SetDynTemp( rg_grid, num_coll, flg,lenv )
struct GRid *rg_grid;
int num_coll;
int flg; /* To indicate call from Copy/Place part (0/1) */
struct GRmd_env *lenv;
{
	int  sts, colno ;
	int  i, exptype, cols;
	char tmp[10], *temp ;
	char **attr_ptr, **data_ptr  ,**format_ptr , **attr_desc ;
	struct GRid **exp_list ;
	struct GRid *totexplist = NULL;

	int *lsize;
	int Singleflg = FALSE;

	_pdm_debug("Entered SetDynTemp...",0);
/*
	if( PDU_ComputedID && lCID && strlen( lCID ))
		mystrcpy(&refresh -> rev_partid,lCID);
*/
	if( (flg == 1) && (num_coll == 1) && (PDU_auto_part_selection==TRUE) )
		Singleflg = TRUE;

	_pdm_debug("Single flag = %d", Singleflg );

	/* Add dynamic attributes to corresponding ACdyn_coll object 
            ( all attributes returned in global buffer PDU_dyn_attr_bufr )
	*/ 	

	if( PDU_dyn_data_bufr && PDU_dyn_attr_bufr )
	{
		MEMbuild_array(PDU_dyn_data_bufr);
		MEMbuild_array(PDU_dyn_attr_bufr);
	}
	else 
	{
		_pdm_debug("Error in PDU_dynamics_for_part\n",0);
		return(0) ;  
	}
	
	attr_ptr   = (char **) PDU_dyn_attr_bufr->data_ptr ;
	format_ptr = (char **) PDU_dyn_attr_bufr->data_ptr ;
	data_ptr   = (char **) PDU_dyn_data_bufr->data_ptr ;


	exp_list = (struct GRid **)malloc( sizeof(struct GRid *) * num_coll ); 
	MemCheck( exp_list );
	attr_desc = (char **)malloc( sizeof(char *) * num_coll ); 
	MemCheck( attr_desc );
	lsize = (int *)malloc( num_coll * sizeof(int) );
	MemCheck( lsize );

	for( i = 0; i < num_coll; i++ )
	{
		exp_list[i] = (struct GRid *)malloc(sizeof(struct GRid)); 
		MemCheck( exp_list[i] );
		attr_desc[i] = (char *)malloc(sizeof(char)); 
		MemCheck( attr_desc[i] );
		lsize[i] = 0;
		attr_desc[i][0] = '\0';
	}

	/* For each dynamic atribute create a unnamed expression object
		and make the expression a template to corresponding ACdyn_col
                also add the attr to the attr_desc string of that ACdyn_col 
	*/
	cols = PDU_dyn_attr_bufr->columns;
	_pdm_debug("attr cols : %d", cols);
	_pdm_debug("data rows : %d", PDU_dyn_data_bufr->rows);
	for( i = 0 ; i < PDU_dyn_data_bufr->rows; ++i ) 
	{ 
		if( !data_ptr[(PDU_dyn_data_bufr->columns * i) + 
                     PDU_DYN_DEFAULT_VAL_COL] )
			continue;

		_pdm_debug("exp type: %s", format_ptr[i*cols+1]);
		if( !strcmp(format_ptr[i*cols+PDU_DYN_DATA_COL],
                     "Expression text") ||
		    !strncmp(format_ptr[i*cols+PDU_DYN_DATA_COL],"char",4) )
			exptype = 2;
		else 
			exptype = 1;

		if( exptype == 1 && strlen(data_ptr[(PDU_dyn_data_bufr->columns
                     * i) + PDU_DYN_DEFAULT_VAL_COL]) < 1 )
		{
			_pdm_debug("No data value for this",0);
			continue;
		}

		_pdm_debug("mapping to coll index %s", attr_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL]);
		if(GetDyncolIndx( MAC_temp_desc, attr_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL], MAC_num_temp, 
						num_loc, &colno ) == -1 )
			colno = num_coll - 1; /* put that in last collection */ 

		_pdm_debug("mapping to coll index %d", colno);

		lsize[colno] += 1;
		exp_list[colno] = (struct GRid *)realloc(exp_list[colno],
					sizeof(struct GRid) * lsize[colno] );
		MemCheck( exp_list[colno] );
 
		exp_list[colno][lsize[colno]-1].osnum = lenv->md_id.osnum;

		if( exptype == 2 ) /* Text type attribute */
		{
			temp = (char *)malloc( strlen( data_ptr[(PDU_dyn_data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL] ) + 1 );
			strcpy(temp, data_ptr[(PDU_dyn_data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL] );
			get_text_exp_value( &temp );
			_pdm_debug("Text attr value = %s", data_ptr[(PDU_dyn_data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL]);
	 		if( !create_expression("", temp,
				&exp_list[colno][lsize[colno]-1], exptype))
			{
				sts = 0;
				goto CleanUp;
			}
		}
 		else if( !create_expression("",data_ptr[(PDU_dyn_data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],
				&exp_list[colno][lsize[colno]-1], exptype))
		{
			sts = 0;
			goto CleanUp;
		}

		/* Add the attr to the description template of this dyncol */
 
		attr_desc[colno] = (char *)realloc( attr_desc[colno],
				strlen(attr_desc[colno]) + strlen(attr_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL]) + 5 );
		MemCheck(attr_desc[colno]);

		strcat(attr_desc[colno],attr_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL]); 
		if( !Singleflg )
			sprintf(tmp,",%d,", lsize[colno]-1 );
		else
			sprintf(tmp,",%d,", lsize[colno]-1+NumSelTemp );

		strcat(attr_desc[colno], tmp);
/*
		if( Singleflg )  One collection and autopartselect ON and not in Copy 
		{
			if( exptype == 1 )
			add_attribute(rg_grid,data_ptr[(PDU_dyn_data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],attr_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL],AC_ATTRIB_DOUBLE);
			else
			add_attribute(rg_grid,data_ptr[(PDU_dyn_data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],attr_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL],AC_ATTRIB_TEXT);
		}
*/
	}
	if( Singleflg ) /* Create a texpexp template "selection" also -
						 for backward compatibility to 2.1 */
	{
		lsize[0] += 1;
		exp_list[0] = (struct GRid *)realloc(exp_list[0],
					sizeof(struct GRid) * lsize[0] );
		MemCheck( exp_list[0] );
		exp_list[0][lsize[0]-1].osnum = lenv->md_id.osnum;
 		if( !create_expression("","selection",
				&exp_list[0][lsize[0]-1], 2))
		{
			sts = 0;
			goto CleanUp;
		}
	}

	/* Now, given the exp_list, attr_desc and the lsize arrays,
           for each collection break up attr_desc if it is longer
           than EXP_MAX_LEN, create so many text expr. objects and
           add them to the exp_list, incrementing the lsize for that
           collection 
	*/

	for( i = 0; i < num_coll; i++ )
	{
		if( !lsize[i] ) /* no templates mapped to this particular collection */
			continue;
		if( !BreakupAndAddToList( attr_desc[i], &exp_list[i], &lsize[i],
						 lenv))
		{
			sts = 0;
			goto CleanUp; 
		}
	}
	if( Singleflg )
	{
		totexplist = (struct GRid *)malloc( sizeof(struct GRid) * (NumSelTemp +
									  lsize[0]) + 1);
		MemCheck( totexplist );
		for( i = 0; i < NumSelTemp; i++ )
			totexplist[i] = SelTemplist[i];
		for( i = 0; i < lsize[0]; i++ )
			totexplist[i+NumSelTemp] = exp_list[0][i];
		selection_temp_to_ACdyncol( (NumSelTemp + lsize[0]), totexplist, rg_grid,
                   					lenv, num_coll); 
	}
	else
	{
		for( i = 0; i < num_coll; i++ )
		{
			if( !lsize[i] ) /* no templates mapped to this particular collection */
				continue;
			if( ! define_temp_to_ACdyncol( lsize[i], exp_list[i], 
						&rg_grid[i], lenv ))
			{
				_pdm_debug("Define temp to ACdyncol failed",0);
				sts = 0;
				goto CleanUp;
			}
		}
	}

	sts = 1;

CleanUp:		
	MEMclose(&PDU_dyn_data_bufr);
	MEMclose(&PDU_dyn_attr_bufr);

/*	FreeArrayPtr( exp_list, num_coll );		*/

	for( i = 0 ; i < num_coll ; i= i + 1 )
		MyFree( exp_list[i] );

	MyFree(exp_list);
	MyFree(totexplist);

	FreeArrayPtr( attr_desc, num_coll );		
	MyFree(lsize);
	return(sts);
}

       

disable_gadgets(fp)
Form fp;
{

	FIg_disable (fp,SKETCH);
	FIg_disable (fp,PLCMNT_OPTIONS);
	FIg_disable (fp,SEARCH);
	FIg_disable (fp,EXP_LIST);
        FIg_disable (fp,SAVE_CRT);
        FIg_disable (fp,PLUS);
        FIg_disable (fp,MINUS);
        /* 27/Dec/93 - raj. TR# 13931 4390. Disable Load Criteria button. */
        FIg_disable (fp,RESTORE_CRT);
	FIg_disable (fp,SORT);
}

enable_gadgets(fp)
Form fp;
{

	FIg_enable (fp,SKETCH);
	FIg_enable (fp,PLCMNT_OPTIONS);
	FIg_enable (fp,SEARCH);
}


GetParamVal (no_vals, param_vals, vals_in_formula, string)
int	no_vals;
char 	*param_vals[], *string;
double  **vals_in_formula;
{
	int	ndx, j;
	char	tmp_str[32];

	if (puldwn_menu ( 1, no_vals, 10, place_part_f, TABLE, param_vals, &ndx)){
		strcpy (string, param_vals[ndx]);
		/* Get the corresponding values of the columns in the formula value selected */
		for (j = 0; j < NoCols; j = j + 1){
			sprintf (tmp_str, "%f", vals_in_formula[ndx][j]);
			FIfld_set_text(place_part_f, TABLE, cols_in_form[j].ndx, 1, tmp_str, FALSE);
		}
                FreeThem ();
		return (1);
	}
	else {
/*	Crash due to NULL. Changed to "".	*/
/*		strcpy (string, NULL);		*/
		strcpy (string, "");
                FreeThem ();
		return (0);
	}
}

ProcessMCF (Form fp, int g_label, int row, int col, int pos)
{
	int	i,sel_flg, total_ent = 0;
	char	oper[32];
        int     length, select;
        static  char *text = NULL;

	if( col == 3 ) /* TR#139306731 */
	{
            for( i = 0; i < NumAttribs; i++ )
        	if (Get_text ( fp, TABLE, i, SEARCH_COL))
                {
                    FIg_enable( fp, SAVE_CRT );
                    break;
                }
            if( i == NumAttribs )
		FIg_disable( fp, SAVE_CRT );
        }

	/* GBTYL : Shouldn't this be the value column ??	*/
	if (col == 1)
                {
                /* MJG - if text = NIL, do not clear out the field */

                FIfld_get_text_length(fp, g_label, row, 1, &length);
         	text = (char *) malloc (sizeof (char) * length + 1);
         	memset(text, NULL, sizeof (char) * length + 1);
         	FIfld_get_text(fp, g_label, row, 1, length,
                       (unsigned char *)text, &select, &pos);
                _pdm_debug("text = <%s>", text);

                if ((text) && (strcmp(text, "~") != 0))
		  FIfld_set_text ( fp, g_label, row, col, "", FALSE );
                else if (!text)
		  FIfld_set_text ( fp, g_label, row, col, "", FALSE );
                }

	else if(col == 0) {

                /* MJG - check to see if value is NIL for SAC - list */
                FIfld_get_text_length(fp, g_label, row, 1, &length);
         	text = (char *) malloc (sizeof (char) * length + 1);
         	memset(text, NULL, sizeof (char) * length + 1);
         	FIfld_get_text(fp, g_label, row, 1, length,
                       (unsigned char *)text, &select, &pos);
                _pdm_debug("text = <%s>", text);
                if ((text) && (strcmp(text, "~") == 0))
                  {
                  FIfld_set_select(fp, g_label, row, col, FALSE);
                  FIfld_set_select(fp, g_label, row, 1, FALSE);
                  FIfld_set_select(fp, g_label, row, 2, FALSE);
                  PDUmessage(PDM_E_NO_ATTR_VALUES, 's');
                  return(0);
                  }

		/* Parameter search on single catalog */
		if(PDU_cat_selected) {

			_pdm_debug("PDU_cat_selected == TRUE ()\n", 0);	
			_pdm_debug("ViewOrTblList[0] %s\n", ViewOrTblList[0]);	

#if 0
			/* Put D later when SVS works - sarma */

			if (!strcmp (ViewOrTblList[0], "CI")){
				    /* Single Parameter Search On View    */
				    /* Call Smart View Search Into Action */
				    _pdm_debug("CallSmartViewSearch ()\n", 0);	
				    CallSmartViewSearch (fp, g_label, row);
			}
#endif			

/* TR # 1393 01199. Smart View Search to work.	*/
			/* If it is a view, we MIGHT use SVS on it. */
			if ((!strcmp (ViewOrTblList[0], "CID")) || (!strcmp (ViewOrTblList[0], "EID")))
			{
				/* If -1, have not parsed this view till now.*/
				if (EnableSVS == -1)
					if (!DoesSVSWork (&EnableSVS))
						return (0);
				if (EnableSVS == TRUE)
					CallSmartViewSearch (fp, g_label, row);
			}
			/* If it is NOT a view or if SVS won't work on it. */
			/* Do a regular query.				   */
			if (EnableSVS == FALSE || EnableSVS == -1)
			{
				    char *outstr ;
				    int sts;

				    _pdm_debug("Callin' do_search ()\n", 0);	
				    PDUmessage( PDM_I_WORKING, 's' );				    
				    sts = do_search(fp,TABLE,
						refresh -> rev_catalog,
						row,col,
						&outstr,
						AttrList,
						AttrSynonym,
						AttrTypes,
						NumAttribs,
                                                &total_ent  );
	                            PDUmessage(PDM_E_CLEAR_FIELD, 's');
				    if ( !sts )
					return(0); 

				    _pdm_debug("Callin' display_few ()\n", 0);	

				    display_few(fp,SPpart_F, TABLE, row, col, pos, &sel_flg);

				    _pdm_debug("Finished with display_few ()\n", 0);	

				    free( (char *)outstr);
			}
		}
		else {  /* Parameter search on multiple catalogs */
			_pdm_debug("Parameter search on multiple catalogs \n", 0);

			ParamSearchOnMultipleCtlgs(fp, g_label, row, col);
			display_few(fp,SPpart_F, TABLE, row, col, pos, &sel_flg);

			UpdateShortList (fp, g_label, row, sel_flg);
		}
	}

	/* GBTYL : Shouldn't this be the OPER_COL ??	*/
	else if( col == 2 ) 
	{
		FIfld_set_text ( fp, g_label, row, col, "", FALSE );
		/* Show choice of operators in a puldwn menu	*/
		input_operator(fp,pos,row, AttrTypes[row]);
	}

	else if( col == 3 && strncmp(AttrTypes[row],"char",4)
			  && strncmp(AttrTypes[row],"timestamp",9) ){

		/* If attribute type is NOT 'char' we need to 	*/
		/* validate the user key in			*/

		if (!Get_text ( fp, TABLE, row, OPER_COL))
			return (0);

		strcpy (oper, s_text);

		if (!Get_text ( fp, TABLE, row, SEARCH_COL))
			return (0);

                /* Added for TR#139309139 */
		if( !strcmp( s_text, "NULL" ) )
		        return( 1 );

		if(!validate_search_criteria_input(oper, &s_text))
			FIfld_set_text(fp,TABLE,row,3,"",FALSE);
	     }

	return(1);
}


CallSmartViewSearch (Form fp, int g_label, int row)
{
char 	ordering_type[8] ;
int     i, r, rows_to_retrv;
char 	param[32], param_nam[32], slctd_val[32], value[16], 
	*tail_condition,  orderby[32];
char	**param_vals = NULL;
double	**vals_in_formula;
int	no_vals, param_ndx = 0;
int	no_deps, dep_ndxs[MAX_SVS_PARAMS];


	if (strcmp (CurrentSVSView, refresh->rev_catalog))
		InitSmartViewSearch (refresh->rev_catalog);
	
	strcpy (ordering_type, "ASC");

	/* Get the parameter on which search is being made */
	Get_text (fp, g_label, row, ATTR_COL);

	/* We've the synonym, get the attr name.	*/
	for (i = 0; i < NumAttribs; i++)
	{
		if (!strcmp (s_text, AttrSynonym[i]))
		{
			strcpy (param, AttrList[i]);
			break;
		}
	}

	/* Get a list of already selected parameters by reading the form */
	NoSlctd = 0;
        for (r = 0; r < NoParams; r = r + 1)
		if (Get_text (fp, g_label, r, DATA_COL)){
                	strcpy (slctd_val, s_text);
			Get_text (fp, g_label, r, ATTR_COL);

			/* We've the synonym, get the attr name.	*/
			for (i = 0; i < NumAttribs; i++)
			{
				if (!strcmp (s_text, AttrSynonym[i]))
				{
					strcpy (param_nam, AttrList[i]);
					break;
				}
			}

			StoreVal (slctd_val, param_nam, r, VueColTypes);
		}

		/* If any criteria given for this parameter use it */
		CnvtOperNCriteriaToCondition (fp, g_label, row, row, 
					&rows_to_retrv, &tail_condition, 
					ordering_type, AttrTypes, NumAttribs);

		sprintf (orderby, " ORDER by %s ", ordering_type);

		/* Initiate search */
		if (!(EnableSVS = Search (	refresh -> rev_catalog, 
				param, 
				&param_vals, 
				&vals_in_formula, 
				&no_vals, 
				&param_ndx,
				rows_to_retrv,
				tail_condition,
				orderby
			    )))
		{
			for (i = 0; i < no_vals; i = i + 1){
				MyFree (param_vals[i]);
				MyFree (vals_in_formula[i]);
			}
			MyFree (param_vals);
			MyFree (vals_in_formula);
			return (0);
		}
		/* Show pulldown list. Get value picked up by user */
		if (!GetParamVal (no_vals, param_vals, vals_in_formula, value))
			return (0);

		FIfld_set_text(fp, g_label, row, 1, value, FALSE);
			
		if (ClearDependentParams (param_ndx, dep_ndxs, &no_deps))
			for (i = 0; i < no_deps; i = i + 1)
				FIfld_set_text(fp, g_label, dep_ndxs[i], 1, "", FALSE);

	return(1);
}

SelectCatalog (Form fp, int g_label)
{
char *project;

	Get_text(fp, g_label, 0, 0);

	if( refresh->rev_project == NULL )
		project = "";
	else
		project = refresh->rev_project;

	if( (PDUvalid_catalog(project,s_text)) != 
		PDM_S_SUCCESS ){
		FIfld_set_text(fp, g_label, 0, 0, "", FALSE);
		FIfld_set_text(fp, FI_MSG_FIELD, 0, 0, "", FALSE);
                FIg_disable(fp, TABLE);
		return (0);
	}

	mystrcpy(&(refresh -> rev_catalog),s_text);
        PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
	rest_on_cat_selection(fp,1);
        PDUmessage(PDM_E_CLEAR_FIELD, 's');
/*	enable_gadgets(fp); */

	return(1);
}


switch_off_gdgs(Form fp)
{

	/* Dynamic parameter MCF group , static/dyn toggle and replace all toggle
	   since not relevant in select/place part erase the gadgets 
	*/

	FIg_erase(fp,51);
	FIg_erase(fp,19);
	FIg_erase(fp,56);

}

Restore_save_load_buttons(Form fp)
{
        FIg_set_state_off(fp, SAVE_CRT);
        FIg_set_state_off(fp, RESTORE_CRT);
        return(1);
}

SaveCriteria(Form fp,char *search_name, int noattrs)
{
	int i, alloc_size ;
	MEMptr ret_buf=NULL ;
	char add_mode[2] , *search_string , **data_ptr, lsrch_name[30];

	strcpy(lsrch_name,search_name);
        FIg_set_state_off(fp, SAVE_CRT);

	_pdm_debug("before PDUlist_report_buffer: %s",search_name);

	if( PDUlist_report_buffer(CAT_SEARCH_LIST, &ret_buf) !=
		PDM_S_SUCCESS ){
		_pdm_debug("Error in PDUlist_report_buffer\n",0);
		return(0);
	}

	strcpy(add_mode,"A") ;

	if( ret_buf != NULL ){

		MEMbuild_array(ret_buf);

		data_ptr = (char **) ret_buf -> data_ptr ;

		for( i = 0; i < ret_buf -> rows ; ++i )
			if( ! strcmp(data_ptr[i* (ret_buf ->columns)] ,search_name)){
				strcpy(add_mode,"M") ;
				break;
			}
	}

	alloc_size = 1024 ;
	search_string = (char *)malloc(alloc_size);

	search_string[0] = '\0' ;

	for( i = 0 ; i < noattrs ; ++i ){

		if ( !Get_text(fp,TABLE,i,OPER_COL))
			strcat(search_string,"=");
		else
			strcat(search_string,s_text);
		strcat(search_string,"~");

		if(!Get_text(fp,TABLE,i,SEARCH_COL))
			strcpy(s_text,"0");
	
		if( strlen (search_string) + strlen( s_text ) + 15 >
			alloc_size ) {

			alloc_size = strlen (search_string) + strlen( s_text ) + 150;

			search_string = (char *)realloc(search_string,	alloc_size);

		}

		strcat(search_string,s_text);
		strcat(search_string,"~");

	}

	_pdm_debug("search_string: %s", search_string);
					
	PDUdefine_criteria_string("W", "C", lsrch_name, search_string,
                                       add_mode);
		
/*	free ( search_string); */
	return(1);			
			
}


RestoreCriteria(Form fp, char *search_name, int noattrs)
{

	int i;
        int status = PDM_S_SUCCESS;
	char *search_string=NULL, *ptr ;
        char *operator = NULL;
        char *msg;

        FIg_set_state_off(fp, RESTORE_CRT);
	status = PDUget_criteria_string("W","C",search_name,&search_string);
        if (status != PDM_S_SUCCESS)
        {
                PDUmessage(status, 's');
                msg = (char *)PDUtranslate_message(PDM_E_FILE_NOT_FOUND);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0);
	}

        PDUmessage(status, 's');

	_pdm_debug("retrieved search_string: %s", search_string);

	ptr = strtok(search_string,"~");

	for( i = 0 ; i < noattrs ; ++i ){

		if( ptr == NULL )
			break;

		if(strcmp(ptr,"="))
			FIfld_set_text(fp,TABLE,i,OPER_COL,ptr,FALSE);
               PDUfill_in_string(&operator, ptr);

		ptr = strtok(NULL,"~");

		if( ptr == NULL )
			break;

		if(strcmp(ptr,"0"))
                        {
                        FIfld_set_text(fp,TABLE,i,SEARCH_COL,ptr,FALSE);
                        FIfld_set_text(fp,TABLE,i,OPER_COL,operator, FALSE);
                        }

		ptr = strtok(NULL,"~");
	}
		
	MyFree( search_string );		

	return(1);
}
		

get_fp(fp)
Form *fp ;
{

	*fp = place_part_f ;
}

Form gfname_p ;
extern int PDU_value_pulldown;
extern char *PDU_value_list[605];
extern int gname_notif();

PALgfname()
{
        int sts ;
        char *msg = NULL;

        sts = FIf_new ( 102, "PALgetfname", gname_notif, &gfname_p);
        if (PALsavecrit)
         {
          msg = (char *)PDUtranslate_message(PDM_I_SAVE_SEARCH_CRIT);
          FIg_set_text(gfname_p, 15, msg);
         }
        if ( sts )
        {
                fprintf(stderr,"MOPartSelec2 FORM CREATION ERROR %d\n",sts );
                return(FALSE);
        }

        FIf_display(gfname_p);
	return(1);
}

UpdatePartType(Form fp, int glabel,char *catname)
{
	int ind , max_rows = 1, err_code , sts ;
	char query[128] , *outstr, *ptr ;
	/* parametric part ( P ) or not */
	ind = GetAttribindx("p_parttype");

	if( (ind != -1) &&  (Get_text(fp,glabel,ind,1) )){
			mystrcpy(&refresh -> rev_parttype,s_text);
			return(1);
	}
/*	if( !PALgetPartType(refresh-> rev_catalog, refresh -> rev_partid,
				refresh -> rev_revision, &refresh -> rev_parttype )) 
	
*/
	sprintf(query,"select n_type from nfmcatalogs where n_catalogname='%s'",
					catname);

	sts = RISquery(query ,&max_rows,&outstr,&err_code); 

	_pdm_debug("sts: %d", (char *)&sts ) ;
	_pdm_debug(" output: %s", outstr);

	if( sts < 0 ) {
		free(outstr);
		RIS_box(err_code);
		return(0);
	}
	
	ptr = strtok(outstr,"~");

	if( !strcmp(ptr,"P") || !strcmp(ptr,"PXT") || !strcmp(ptr,"CID") || !strcmp(ptr,"EID") )
		mystrcpy(&(refresh->rev_parttype),"P");
	else
         {
           /* Added by kumar for KK 0601693 */
           /* added by jenny : get parttype according to catalog,part,rev */
             sts = PDUget_parttype(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision,
                                   &refresh->rev_parttype);
              _pdm_status("PDUget_parttype",sts);
              _pdm_debug("parttype = <%s>", refresh->rev_parttype);
          }
/* 
		mystrcpy(&(refresh->rev_parttype),ptr);
** changed this for TR#139307676 - donot know why it is being filled with NULL?? KK
		refresh -> rev_parttype = NULL_STRING ;
*****/

	free( outstr);

	return(1);

}

ret_fromGpart()
{

	if(PDU_desrev_fp && PDUcommand_type != SELECT_PART ){
/*		PDUcheck_file_for_parts();
		PDUcheck_file_for_origins();
		FIf_display(PDU_desrev_fp);
*/
           PDUdisplay_design_form();
	}
	else
		PDURetFromSelect(PDU_desrev_fp);
}

mystrncpy(str1,str2,no)
char *str1, *str2 ;
int no;

{

	int i;

	for( i = 0 ; i < no && str2[i] != '\0' ; ++i)

		str1[i] = str2[i] ;

		str1[i] = '\0' ;

	_pdm_debug("mystrncpy: %s", str1);
}

UpdateCatPath( fp, catname )
Form fp;
char *catname;
{
int lvls, i;
char *path;

	no_of_buttons = 1;

	/* Display the level buttons */

	GetDepthofCatalog( catname, &lvls );

	for( i = 1; i <= lvls; i++ )
	{
		add_level_button(fp,i+1,lab);
		++no_of_buttons;
	}

	GetCatPath( catname, lvls, &path );
	
	if( path )
	mystrcpy(&refresh -> cat_path, path);

}

BreakupAndAddToList( attr_desc, list, no, lenv ) 
char *attr_desc;
struct GRid **list;
int *no;
struct GRmd_env *lenv;
{
int temp, no_of_exps, j;
char temp_desc[EXP_MAX_LEN+1] ;
struct GRid expid  ;

	temp = strlen( attr_desc ) % EXP_MAX_LEN;

	if( temp )
		no_of_exps = strlen( attr_desc ) / EXP_MAX_LEN + 1 ;
	else
		no_of_exps = strlen( attr_desc ) / EXP_MAX_LEN ;

	_pdm_debug("no_of_exps = %d",no_of_exps);

	*list = (struct GRid *)realloc(*list,
				 sizeof(struct GRid ) * (*no + no_of_exps + 1));
	MemCheck( *list );

	for( j = 0 ; j < no_of_exps ; ++j ) 
	{
		if( strlen (&attr_desc[j*EXP_MAX_LEN]) > EXP_MAX_LEN )
			mystrncpy( temp_desc, &attr_desc[j*EXP_MAX_LEN],
							EXP_MAX_LEN);
		else 
			strcpy(temp_desc,&attr_desc[j*EXP_MAX_LEN]);

		_pdm_debug("temp_desc as split: %s", temp_desc );

		expid.osnum = lenv -> md_id.osnum ;
 
		if(!create_expression("",temp_desc,&expid,2))
			return(0);

		(*list)[*no+j] = expid ;
	}

	*no = *no + no_of_exps;

	expid.osnum = lenv -> md_id.osnum ;
	temp_desc[0] = '\0' ;

	sprintf(temp_desc,"%d", no_of_exps );

	_pdm_debug("no. of desc. exps = %d", no_of_exps );

	if(!create_expression("",temp_desc,&expid,2))
		return(0);

	(*list)[(*no)++] = expid ;

	_pdm_debug("list size changed to %d", *no );

       /* '*no' includes the text template which has the no_of_exps */ 
	
	return( 1 );
}


ReadStatAttribsonForm( ctlgname, fp, glab, attribs, types, units, numattr, rg_grid)
Form fp;
int glab, numattr;
char *ctlgname;
char **attribs, **types, **units;
struct GRid *rg_grid ;
{
int ind, i, j, doquery = FALSE;
char tmpstr[100];
int notfound[50], sts, maxrows = 1, err, coll;
char *query, *clause, *output, *ptr;
char *to_lower();

	for( i = 0, j = 0; i < numattr; i++ )
	{
		strcpy( tmpstr, attribs[i] );
		ind = GetAttribindx(to_lower(tmpstr));
		
		if( (ind != -1) &&  (Get_text(fp,glab,ind,1) ))
		{
			/* add the attribute to the collection */
			strcpy(tmpstr,s_text);

			if( !strncmp(units[i],"inch",4) || !strncmp(units[i],"mm",2) )
				from_cat_to_work_units(1,units[i],tmpstr);

			_pdm_debug("temp type: %s", types[i]);

			/* attrib not mapped to any collection */
			/* CHANGED behaviour for the sake of PDMNORM, Vdaps 
                       	CIMacro, which has unmapped attributes - 03/02/93 */

			if( GetDyncolIndx( MAC_temp_desc, attribs[i], MAC_num_temp,
						 num_loc, &coll ) == -1 )
				coll = 0;
		
			if(! strcmp(types[i],"Expression double") )
			        add_attribute(&rg_grid[coll],tmpstr,attribs[i],AC_ATTRIB_DOUBLE);
			else
			        add_attribute(&rg_grid[coll],tmpstr,attribs[i],AC_ATTRIB_TEXT);
		}
		else
		{
			_pdm_debug("No value for attib %s on Form",attribs[i]);
			doquery = TRUE;
			notfound[j++] = i;
		}
	}
	if( !doquery )
		return( 1 );

	/* build where condition with attributes on the form and do query to
           get the values of attributes NOT on form
        */
					

	clause = (char *) malloc (2);
	clause[0] = '\0'; 
	for( i = 0, j = 0; i < numattr; i++ )
	{
		if( notfound[j] == i ) /* attribute not on Form, donot add to where */
		{
			j++;
			continue;
		}
		strcpy(tmpstr,attribs[i]);
		ind = GetAttribindx(to_lower(tmpstr));
		Get_text(fp,glab,ind,1);
		if (strlen( clause ) > 1) /* second attribute onwards */
			strcat (clause, " and ");
		
		clause = (char *) realloc (clause, strlen (clause) + 
						   strlen (attribs[i]) +
						   strlen (" = ") + 
						   strlen (s_text) + 15 );
		strcat (clause, tmpstr);
/* added for TR#139307305 */
		if( !strcmp(s_text, "NULL") )
			strcat(clause," is NULL ");
		else
		{
/* end */
			strcat (clause, " = ");
			if( !strcmp(types[i],"Expression text"))
			{
				strcat( clause, "'");
				strcat( clause, s_text);
				strcat( clause, "'");
			}
			else
				strcat( clause, s_text);
		}
	}
	_pdm_debug("where condition is %s", clause );
	/* Now build the pre-query */
	query = (char *) malloc ((numattr * 20 + 132) * sizeof (char));

	strcpy (query, "Select ");

	j = 0;
	for (i = 0; i < numattr; i++)
	{
		if ( notfound[j] == i ) /* attribute not on form, add to query */
		{
			if (strlen(query) > 7)
				strcat (query, ", ");
			strcpy( tmpstr, attribs[i] );
			strcat (query, to_lower(tmpstr));
			j++;
		}
	}
	strcat (query, " From ");
	/* TABLE */
	strcat (query, ctlgname);
	strcat (query, " Where ");

	/* Add the where clause */
	query = (char *) realloc (query, strlen (query) + strlen (clause) + 1);

	strcat (query, clause );
	MyFree (clause);

	_pdm_debug("Total query is: %s", query );

	/* Send RIS query */
	sts = RISquery (query, &maxrows, &output, &err);	
	MyFree (query);

	if (sts < 0){
		free (output);
		_pdm_debug(stderr, "Error In RIS Operation - %d\n", err);
		return (0);
	}

	_pdm_debug("output: %s", output );

	ptr = strtok (output, "~");

	i = 0;
	while(ptr != NULL )
	{
		_pdm_debug("ptr: %s", ptr );
		j = notfound[i];
		/* convert to design units */
		if( !strncmp(units[j],"inch",4) || !strncmp(units[j],"mm",2) )
		{
			strcpy(tmpstr,ptr);
			from_cat_to_work_units(1,units[j],tmpstr);
			ptr = tmpstr ;
		}

		_pdm_debug("temp type: %s", types[j]);

		if( GetDyncolIndx( MAC_temp_desc, attribs[j], MAC_num_temp,
						 num_loc, &coll ) == -1 )
		{
			/* attrib not mapped to any collection 
			MyFree(output);
			return( 0 );
			*/
			coll = 0;
		}

		if(! strcmp(types[j],"Expression double") )
		        add_attribute(&rg_grid[coll],ptr,attribs[j],AC_ATTRIB_DOUBLE);
		else
		        add_attribute(&rg_grid[coll],ptr,attribs[j],AC_ATTRIB_TEXT);

		++i ;
		ptr = strtok(NULL,"~");
	}
	free( output );
	return(1);
}


PALSaveRefreshInfo (current_catalog,current_partid,current_revision,
		current_filename,current_description)
char	**current_catalog,
	**current_partid,
	**current_revision,
	**current_filename,
	**current_description;
{
  
  /********************** SAVE REFRESH INFORMATION **************************/

  _pdm_debug("Saving refresh information", 0);
  

  if (refresh->rev_catalog != NULL)
  {
    *current_catalog = (char *) malloc (strlen (refresh->rev_catalog)+1);
    strcpy (*current_catalog, refresh->rev_catalog);
  }
  else
  {
    *current_catalog = (char *) malloc (3);
    strcpy (*current_catalog, "");
  }
    

  if (refresh->rev_partid != NULL)
  {
    *current_partid = (char *) malloc (strlen (refresh->rev_partid)+1);
    strcpy (*current_partid, refresh->rev_partid);
  }
  else
  {
    *current_partid = (char *) malloc (3);
    strcpy (*current_partid, "");
  }
    

  if (refresh->rev_revision != NULL)
  {
    *current_revision = (char *) malloc (strlen (refresh->rev_revision)+1);
    strcpy (*current_revision, refresh->rev_revision);
  }
  else
  {
    *current_revision = (char *) malloc (3);
    strcpy (*current_revision, "");
  }
    

  if (refresh->rev_filename != NULL)
  {
    *current_filename = (char *) malloc (strlen (refresh->rev_filename)+1);
    strcpy (*current_filename, refresh->rev_filename);
  }
  else
  {
    *current_filename = (char *) malloc (3);
    strcpy (*current_filename, "");
  }
    


  if (refresh->rev_description != NULL) 
  {
    *current_description = (char *) malloc (strlen (refresh->rev_description)+1);
    strcpy (*current_description, refresh->rev_description);
  }
  else
  {
    *current_description = (char *) malloc (3);
    strcpy (*current_description, "");
  }
    
  
  return (1);
}



PALRestoreRefreshInfo ( saved_catalog, saved_partid, saved_revision,
					saved_description, saved_filename)
char	*saved_catalog,
	*saved_partid,
	*saved_revision,
	*saved_description,
	*saved_filename;
{
  
  /* Restore refresh information */
  _pdm_debug("restoring refresh information", 0);
  PDUfill_in_string(&refresh->rev_catalog, saved_catalog);
  PDUfill_in_string(&refresh->rev_partid, saved_partid);
  PDUfill_in_string(&refresh->rev_revision, saved_revision);
  PDUfill_in_string(&refresh->rev_filename, saved_filename);
  PDUfill_in_string(&refresh->rev_description, saved_description);

  free ((char *)saved_catalog);
  free ((char *)saved_partid);
  free ((char *)saved_revision);
  free ((char *)saved_filename);
  free ((char *)saved_description);
  
  return (1);
}


PrintRefreshInfo ()
{

  _pdm_debug ("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug ("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug ("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug ("refresh->rev_description = <%s>", refresh->rev_description);
  _pdm_debug ("refresh->rev_filename = <%s>", refresh->rev_filename);
  _pdm_debug ("refresh->rev_parttype = <%s>", refresh->rev_parttype);
  
  _pdm_debug ("refresh->act_catalog = <%s>", refresh->act_catalog);
  _pdm_debug ("refresh->act_partid = <%s>", refresh->act_partid);
  _pdm_debug ("refresh->act_revision = <%s>", refresh->act_revision);
  _pdm_debug ("refresh->act_description = <%s>", refresh->act_description);
  _pdm_debug ("refresh->act_filename = <%s>", refresh->act_filename);
  _pdm_debug ("refresh->act_parttype = <%s>", refresh->act_parttype);

  return (1);
  
}

