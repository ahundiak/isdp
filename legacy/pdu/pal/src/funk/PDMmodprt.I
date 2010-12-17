/******************************************************************************/
/*									      */
/*	File	  : PDMmodprt.I						      */
/*	Algorithm :                                                           */
/*	This module has routines that allow user to MODIFY or REPLACE a	      */
/*	parametric part.						      */
/*      Steps     :                                                           */
/*	Allow user to locate a part.					      */
/*	Retrieve the STATIC and DYNAMIC template information of the	      */
/*	macro located and displays it on a form.			      */
/*	Check whether the located macro has a Selction criteria in the        */
/*	first collection. If YES, retrieve the criteria ( given at the time   */
/*	of instancing) from the Selection collection and display it on	      */
/*	form in the 'criteria' column.					      */
/*	Allow user to change values of the templates or criteria there by     */
/*	modifying the part. 						      */
/*	ALSO allow user to select : 					      */
/*	1) A different macro under the same catalog, OR			      */
/*	2) A different catalog 						      */
/*									      */
/*	In either of the cases check the templates of the NEW macros	      */
/*	case 1) 							      */
/*      If the new macro has only a Coord Sys and an ACdyn_col as templates   */
/*		a) If same catalog :					      */
/*		   Do nothing further (since the attributes are still the     */
/*		   same).						      */
/*		   When user 'accepts' or 'runs', delete the old macro        */
/*		   and initiate 'place_macro ()' function and TERMINATES.     */
/*		b) If a different catalog :				      */
/*                 Invoke Place part command                                  */
/*	case2)								      */
/*	If the new macro has other locatable templates in addition to the     */
/*	Coord Sys and ACdyn_col.					      */
/*		When user accepts or 'runs' the form, invoke "Place" command  */
/*		and TERMINATES.						      */
/*									      */
/*	Creation date :	9th, July, 1992		Raj Shekar .P		      */
/*      Modified      : 5th, Dec., 1992         dkk (IGI).                    */
/*									      */
/******************************************************************************/

class implementation	Root;

#include <stdio.h>
#include <math.h>
#include <string.h>

#	include "FI.h"

#	include	"OMlimits.h"		/*				*/
#	include	"OMminimum.h"		/* Typedefs			*/
#	include	"OMerrordef.h"		/* Error codes OM_?_*		*/
#	include	"OMprimitives.h"	/* Macros om$*()		*/
#	include	"igetypedef.h"		/* IGE typedefs GR*		*/
#	include	"igrtypedef.h"		/* Typedef IGR*			*/
#	include	"exdef.h"		/* Constants for exec (IGE)	*/
#	include	"ex.h"			/* Structs EX*			*/
#	include	"fi.h"			/* Structures for forms		*/
#	include	"igrdef.h"		/* Constants IGR??		*/
#	include	"igr.h"			/* Structs IGR* for geometries	*/
#	include	"igrdp.h"		/* Structs IGR* for display	*/
#	include	"gr.h"			/* Structs GR* for graphic info	*/
#	include	"godef.h"		/* Constants GR* for graphics	*/
#	include	"go.h"			/* Struct GR* for graphics	*/
#	include	"griodef.h"		/* Constants for graphic I/O	*/
#	include	"grio.h"		/* Structs for graphic I/O	*/
#	include	"dpdef.h"		/* Constants for display	*/
#	include	"dp.h"			/* Enums, structs for display	*/
#	include	"parametric.h"		/* Assoc. Geo. consts & types	*/
#	include "lcdef.h"		/* Constants for locate function*/

#include "OMmacros.h"

#include "ciexecmacros.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpmacros.h"

#include "nddef.h"
#include "graph.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "expression.h"
#include "expmacros.h"
#include "asbox.h"
#include "PDUerror.h"
#include "MEMstruct.h"

/* mold include files */
#include "MOmacros.h"
#include "PALmsg.h"
#include "PALglbs.h"
#include "PALlctypes.h"
#include "macro.h"

/* Include file for gadgets and defines */
#include "PDMmdprtdef.h"

#include "PDUstr.h"
#include "PDUcommand.h"
#include "PDMmessage.h"

/* ACrg_collect include files */
#include "AS_status.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"
#include "PDUfile_def.h"

#define	AC_ATTRIB_MASK_TYPE	0x00ff
#define CLEAR_ALL	29
#define NO_STD_DYN_ATTRS  	4
#define PROJECT_BTN    16

from	ACcpx		import	find_macro		;
from	ACncpx		import	ACreturn_foot		;
from	ACncpx		import	ACcontext_compute	;
from	ACcpx_defn	import	ACgive_name		;
from	ACcpx_defn	import	ACgive_temp_desc	;
from	ACmacro_defn	import	ACgive_upscan 		;
from	ACpretend	import	ACgive_downscan		;
from	ACpretend	import	ACfind_parent		;
from	NDnode		import	NDget_objects		;
from	NDnode		import	NDconnect		;
from	NDnode		import	NDchange_connect	;
from	NDnode		import	NDgive_structure	;
from	NDnode		import	ASreturn_go		;
from	ACrg_collect	import	AClist_attribute	;
from    ACrg_collect    import  ACget_named_attribute   ;
from	GRvg		import	GRgetname		;
/* TR# 13941 8747.	*/
from 	GRvg		import	GRchgname		;
from	GRgraphics	import	GRdisplay		;
from	GRgraphics	import	GRdelete		;
from	expression	import	give_formula		;

char 		**dyn_attr_val;

/************	BEGIN Extern Data Declarations	*******************************/

extern	char		*s_text;
extern	struct 	PDUrefresh	*refresh;
extern	char 	ViewOrTblList[][6];
extern	char	PDU_placement_type;
extern	int	PDU_auto_part_selection;
extern   int     PDU_command   ;
extern 	char 	**AttrList    ;
extern 	char 	**AttrTypes   ;
extern 	char 	**AttrSynonym ;
extern 	int  	NumAttribs    ;
extern  char  	**StatAttribs, **StatDesc, **StatUnits, **StatTypes,
		**DynAttribs, **DynAttribTypes,**DynAttribDesc ;
extern  char    *PALchild_no ;
extern  int 	PALMacintf;

extern  OMuword OPP_nci_macro_class_id ;
extern  OMuword OPP_ACconst_class_id ;
extern  OMuword OPP_ACdyn_col_class_id ;
extern  OMuword OPP_expression_class_id;
extern  OMuword OPP_text_exp_class_id;
extern  OMuword OPP_GRpart_class_id;
extern  OMuword OPP_GRgencs_class_id;
extern	int	NewCatalogSelected;	/* Set in "PDMselprt.c" routines, to  */
					/* indicate selection of new catalog  */
extern  struct	GRid	DYNA_GRID_LIST[], *grid_list ;
extern  int     row_num, max_rows_rtvd, sel_row, display_all, PALsavecrit;
extern  int     Num_Stat, Num_Dyn;
static  Form	explstf;
static int	num_stat, num_dyn ;
extern  short   PALis_sort_selected ;
extern  int     PDU_ComputedID ;
extern  int 	PDU_cat_selected;

extern short    PDU_replace_all_occur;
extern char     *PDU_usage_id;
extern  int	lab[MAX_LEVELS] ;
extern Form 	PDU_desrev_fp;

extern char *to_lower();
extern int      PDU_active_button;
extern Form PDU_form_id;
extern int PDU_refresh_gadgets[7];

extern char *PDU_incl_BOM         ;
extern char *PDU_incl_ASM         ;
extern short 	PDU_attach        ;

/*	TR # 139308062.	04/aug/93 - raj.	*/
extern	int  multiple_parts ;

/* 23/Nov/93 - raj.	*/
extern	int 	 MacroDisplayed  ;

/************	END Extern Data Declaration	*******************************/


Form    ModifyPartForm ;
int	PALnotification_flag;	/* Flag set in form notification routine to */
					/* signify which gadget was selected	    */

static int	num_temp, action_flag ;
static int	SelCiMacFlag ;
/*static int	symbol_occurence;*/

static int	sts,col, symb_mod_flag,num_mac_temps   ;
static int      pos,temp_ndx,form_act_row , static_flag;
static IGRlong  msg ;
static int	num_loc, num_coll;
static struct GRid *coll_list;

static char	**cat_attr_val,  **loc_temp_val;
static int	*dyn_attr_ndx;

static char	*cat_desc;

static struct  stemp           *temp_desc ;
static  struct GRmd_env	my_env;
static struct  GRid            part_located, temp_id[MAX_TEMP];
static struct  ret_struct      ret_st ;
static struct	GRid		ACdyn_col_obj;
static 	char 			*partinfo[2];

static int  MacroRow;	/* Varaible which indicates whether a catalog has  */
			/* an attribute by name "macro"	and also holds the */
			/* index of that attribute in the list		   */

static int		ActionUponAccept;
static char		nmac_name[32];
static struct	GRid	nmac_hdr;


static struct	attributes	{

	char	**dyn_attr,
		**dyn_attr_desc;
	int	*dyn_attr_type;
	int	no_dyn_attr;

	char	**loc_temp,
		**loc_temp_type,
		**loc_temp_desc;
	int	num_loc_temp;

	}	omac, nmac;

static int 		cur_level;

/*
static OMuword		classes[3];
static OM_S_CLASSLIST  elig_classes;
*/

static int dyn_star_type[50];            


static int PALdonot_free, is_it_grpart ;

/* Invoked from design operations form when user pokes on replace
   part button. The design operations form is erased before calling
   this function and the form fp is passed as an argument for redisplay.
*/

void ModifyPart(frfp)
Form frfp;
{
	if( frfp != NULL )
		PDU_desrev_fp = frfp ;
		
	PALis_sort_selected = FALSE ;

	_pdm_debug ("PAL -- Enter Modify Part\n", 0);

	/* Get module info */
	get_mod_info (&my_env);

	lab[0] = LEVEL1 ;

	memset_mac( &omac );
	memset_mac( &nmac );
	{
		int             responses[1]	;
		char            *strings[1];		

/**** CHANGE THE COMMAND NAME AND STRING LATER **************/
		PDU_command = PDC_M_REPLACE_PPART;
		responses[0] = EX_CMD_KEY;
		strings[0] = "PDRpPPr";

		PDUprepare_queue(responses,strings,1);
	}

/*	for ( ; ; ) {
		if (!ProcessObjectLocated ())
			break;
	}
*/	
}

void PALstack_events(ctype,com_str,evnt,lobjid)
char *com_str ;
int evnt,ctype ;
GRobjid *lobjid ;
{

	int sts, resp,pos ;
/*
	if( !strcmp(com_str,"PDCpPrPt")) PDU_command = PDC_M_COPY_PART_PTR;
	if( !strcmp(com_str,"PDDlPrPt")) PDU_command = PDC_M_DELETE_PART_PTR;
*/
        /* Put edit part command on the queue */
       	resp = evnt;
        pos = FRONT;
	sts = PDUput_queue(
                           ctype,
                           NULL,
			   com_str,
                           NULL,
                           NULL,
	                   &resp,
        	           lobjid,
                	   NULL, 
                           NULL,
                           &pos
	                   );

        _pdm_status("PDUput_queue (Case III)", sts);
}

PALmodprt(loc_grid,flg)
struct 	GRid 	*loc_grid;
int flg ;
{

	int			no_acdyncol_attribs, i, j ;
	struct ACrg_coll	*acdyncol_attribs;
	struct GRid		hdr, dyncol;
	char			*cat_name;
	int			size;

	is_it_grpart 		= flg ;

	part_located            = *loc_grid ;

	row_num 		= 0 ;
	MacroRow 		= -1;
	SelCiMacFlag  		= FALSE;
	NewCatalogSelected 	= FALSE;
	ActionUponAccept	= MODIFY;
	PALdonot_free           = FALSE ;
        sts = 1 ;
	NewCatalogSelected = FALSE;

	loc_temp_val = NULL;    /* added this to avoid crash in Terminate() */

	if( is_it_grpart ){
		if(!grpart_update())
			return(0);
		return(1);
	}

	if( !GetMacroHeaderGivenGrid( part_located, &hdr ))
		return(0);

	/* Get the template description	*/
        if ( !GetOriginalMacroInfo( &hdr, &temp_desc, &num_mac_temps, &num_loc, &num_coll))
		return (0);

	/* Check to see if there are minimum 2 collections
	if( num_coll < 2 )
	{
		warn_box("Replace Part Possible on PDM parts only");
		return(0);
	}
	*/

	coll_list = (struct GRid *)malloc(sizeof(struct GRid) * num_coll);
	/* Get All the collections */
	for( i = num_loc,j = 0; i < (num_loc + num_coll); i++,j++ ) 
		if (!get_acdyncol_temp(&part_located, &coll_list[j], i))
			return (0);

	/* The FIRST collection containing the catalog attributes	*/
	/* (that are not templates to the macro ) comes after the 	*/
	/* locatable templates and is at 'num_loc'eth position	*/

	ACdyn_col_obj = coll_list[0];

	_pdm_debug ("cat_attr_coll : %d\n", ACdyn_col_obj.objid );

	size=20;
	cat_name=(char *)malloc(size);
	cat_name[0] = '\0' ;

	if(!GetACrgAttribVal(&ACdyn_col_obj,"n_catalogname",&cat_name,&size))
		return(0);

	cat_name[strlen(cat_name)-1]= '\0' ;/* above routine adds '\1' at end */

	_pdm_debug("catalog name : %s", cat_name);

	mystrcpy(&(refresh->rev_catalog), cat_name);

	size = 2;
	PDU_incl_ASM[0] = '\0';
	if(!GetACrgAttribVal(&coll_list[num_coll-1],"p_incstr",&PDU_incl_ASM,&size))
		return(0);

	PDU_incl_ASM[strlen(PDU_incl_ASM)-1]= '\0' ;

	PDU_incl_BOM[0] = '\0';
	if(!GetACrgAttribVal(&coll_list[num_coll-1],"p_incbom",&PDU_incl_BOM,&size))
		return(0);

	PDU_incl_BOM[strlen(PDU_incl_BOM)-1]= '\0' ;

        /* Get catalog description using catalog name 	*/

	cat_desc = NULL;
        if (!GetCatalogDesc (refresh -> rev_catalog, &cat_desc))
		return (0);

	_pdm_debug("cat desc:%s",cat_desc);

	/* Get catalog attributes, STATIC & DYNAMIC templates	*/
	if (!GetAllTheAttributes (ORIGINAL_CATALOG, refresh -> rev_catalog, &omac, ""))
		return (0);

	_pdm_debug("num_stat_temp:%d",num_stat);
	_pdm_debug("omac->dyn_temp:%d",num_dyn);
	_pdm_debug("omac->dyn_temp are: ...",0);
	for(i=0;i< num_dyn;i++)
	{
		_pdm_debug("%s",DynAttribs[i]);
		_pdm_debug("%s",DynAttribDesc[i]);
	}

/* IMPORTANT: If the number of collections is more than 2 and if the dynamic
   CAUTION  : attributes are mapped to collections other than the LAST 
              collection, then we have to first gather all the DYNAMIC 
              COLLECTIONS and build the attributes list, and ExtractDyn...().
   At present the code is written assuming only one LAST dynamic collection
   and as such the dynamic attributes in the last collection are extracted.
*/

	/* Take the LAST collection grid */
	dyncol = coll_list[num_coll-1];

	/* Get attribute list of LAST template of the macro */
	if (!GetACrgAttribList(&dyncol,&acdyncol_attribs, &no_acdyncol_attribs))
		return (0);

	/* This list will contain :					    */
	/* 								    */
	/* 1) Attributes that are DYNAMIC templates to the macro.	    */
	/* 2) Other DYNAMIC attributes				   	    */
	/*    other than the ones obtained in 'DynAttribs' list obtained    */
	/*    thro' GetStatAndDynAttribs ().			   	    */


	_pdm_debug("calling ExtractDynamicAttributes...",0);

	if (!ExtractDynamicAttributes (&dyncol, acdyncol_attribs,
						 no_acdyncol_attribs))
		return (0);

/*
	if( !GetACdyncolExpTempls(&ACdyn_col_obj,&cnt,NULL))
		return(0);

	if( cnt == 0 )
		SelCiMacFlag = FALSE;
	else
		SelCiMacFlag = TRUE;
*/
	_pdm_debug("Selcimac = %d",SelCiMacFlag);

/*
	_pdm_debug("Calling ModifyMacro",0);

        ModifyMacro();

        if( notification_flag != FI_EXECUTE )
		return (0);
*/

	return (1);
}

/* notification routine for MODIFY part form */
mdprt_notification(f_label, g_label, value, fp)
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
int     j,row;
char	oper[10];
char    *msg, file[256];
int	sel_flg;
int     state, status;

/* 23/Nov/93 - raj.	*/
/* Save refresh info to be restored after show graahics is done.	*/
char	*current_catalog = NULL,
	*current_partid = NULL,
	*current_revision = NULL,
	*current_filename = NULL,
	*current_description = NULL;
/************************************************************************/

  sts = 0;
  PDU_form_id = 0;
  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }
         FIf_cvrt_to_perm_win(fp);
         Help_topic("MOPartSelec2");

         break;

    case FI_CANCEL:  
         PALnotification_flag = FI_CANCEL;
         FIg_set_state_off(fp, FI_CANCEL);
         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */
         FIf_cvrt_to_perm_win(fp);
         break;

    case FI_EXECUTE:
	 PALnotification_flag = FI_EXECUTE;
	 FIg_set_state_off(fp, FI_EXECUTE);
	 if ((sts = ProcessData()) == TERMINATE){
		Terminate ();
	 }
	 else {
        	FIf_reset(ModifyPartForm);
		static_flag = 0 ;
		set_gadgets(ModifyPartForm);
		FIf_reset(explstf);
		action_flag = 0 ;
/*		ProcessObjectLocated (); */
		delete_window(fp,SKETCH);
		FreeMem();
	 }
         break;

    case FI_ACCEPT: 
         PALnotification_flag = FI_ACCEPT;
         FIg_set_state_off(fp, FI_ACCEPT);
         FIg_get_state(fp, 19, &state);
	 FIf_erase(ModifyPartForm);
         if (state == 0)
           PDU_replace_all_occur = TRUE;
         else
           PDU_replace_all_occur = FALSE;
	 sts = ProcessData();
/*
	 if( sts == TERMINATE )
		 Terminate ();
	 else
		FIf_display(ModifyPartForm);
*/
	 if( sts == 0 )   /* Some Error Redisplay the Form */
		FIf_display( ModifyPartForm );
	 else 
		return( sts );
         break;

    case FI_RESET:
	PDU_auto_part_selection = FALSE; /*** Added 06/04/93 *****/
	delete_window(fp,SKETCH);
	reset_forms(ModifyPartForm, explstf,TABLE,refresh -> rev_catalog, "", 
		NumAttribs, AttrSynonym, AttrList) ;
/* TR 139417186 - When form is reset PLCMNT_OPTIONS button should be turned
   on anytime the form is reset.  mjg */

        FIg_enable(fp,PLCMNT_OPTIONS);	

	if (NewCatalogSelected)
	{
		switch_off_gdgs(fp);
                row_num = 0;
		FIg_display(fp,19);
	}
	else {
		static_flag = 0 ;
		set_gadgets(fp);
                FIg_display(fp, 51);
		UpdatePartType(ModifyPartForm,TABLE,refresh->rev_catalog);
        	if ((strcmp(refresh->rev_parttype, "P") == 0) ||
	            (strcmp(refresh->rev_parttype, "PXT") == 0) ||
	            (strcmp(refresh->rev_parttype, "p") == 0))
        	{
	        	FIg_set_state_on(ModifyPartForm, 19);
		        FIg_disable(ModifyPartForm, 19);
	        }

		if ( !is_it_grpart )
		{
			/* set the dyn attr names only */
			set_dynnames();

			/* set the special dyn attr description */
			PALset_attribute_type(omac.no_dyn_attr,omac.dyn_attr,
				omac.dyn_attr_desc, dyn_star_type, ModifyPartForm,
				DYN_NAMES, num_loc);

			/* set standard dynamic attr values also */
			j = num_loc;
			set_stddyn_attrval( &j, NO_STD_DYN_ATTRS );
		}
		else
			update_dynnames();
	}

	break;

    case STA_DYN:
         set_gadgets(fp);
         break;

    case TABLE:  
        col = 0 ;
        row = 0 ;
        FImcf_get_active_col ( fp,  g_label,  &col,  &pos );
        FIfld_get_active_row ( fp,  g_label,  &row,  &pos );

	/* User entered a criteria for search in the SEARCH_COL */
	if (col == SEARCH_COL){

		/* If attrib type is 'char', let user keyin anything, no validation required	*/
		
		if (!strncmp (AttrTypes[row], "char", 4))
			break;

		if (Get_text (ModifyPartForm, TABLE, row, OPER_COL))
			strcpy(oper,s_text);
		else
			strcpy(oper,"=");
		if (Get_text (ModifyPartForm, TABLE, row, SEARCH_COL))
		if(!validate_search_criteria_input(oper, &s_text)){

			FIfld_set_text(ModifyPartForm, TABLE, row, SEARCH_COL,"",FALSE);
			break;
		}
		break;
	}
	else if( col == 2 ) 
	{
		FIfld_set_text ( fp, g_label, row, col, "", FALSE );
		/* Show choice of operators in a puldwn menu	*/
		input_operator(fp,pos,row, AttrTypes[row]);
	}
	else {
		ProcessMCF (fp, TABLE, row, col, pos);

		if (!NewCatalogSelected){
			/* If the current row searched on is same as 	      */
			/* MacroRow and if a value was picked from pull down  */
			/* list in display_few(sel_flg).   		      */
			/* IF TRUE : 					      */
			/* Get the value from that row, and if a new macro    */
			/* name is selected, call relevant function	      */

			sel_flg = 1; /* This should be removed and got from ProcessMCF */
/* CAUTION: sel_flg is not being set from ProcessMCF ******************************/
			if (row == MacroRow && sel_flg){
			   if (Get_text (ModifyPartForm, TABLE, MacroRow, 2))
/* 20/apr/94 - raj. macro name might be NULL in that case do not call NewMacroSelected(). */
/*			      if (strcmp (cat_attr_val[MacroRow], s_text))	*/
			      if (strcmp(cat_attr_val[MacroRow], "") && strcmp (cat_attr_val[MacroRow], s_text))
			         NewMacroSelected ();
			      /* NOTE : 'cat_attr_val' holds initial values of attributes */
			}
		}
	}

	break;

    case SKETCH:
        FIf_cvrt_to_perm_win ( fp );     /* Fix for TR#139222800 */
	FIg_get_state( fp, SKETCH, &status );
	if ( status == 0 && MacroDisplayed)
	{
		delete_window( fp, SKETCH );
		FIg_set_state_off( fp, SKETCH );
		break;
	}

	/* 23/Nov/93 - raj. I need this information here. */
	/* Update PDUrefresh structure */
	/* Before that save current refresh info.	*/

	PrintRefreshInfo();
	PALSaveRefreshInfo(&current_catalog, &current_partid,
				&current_revision, &current_filename,
						&current_description);
	if( !UpdateRefreshStr(fp,TABLE) )
	{
                msg = (char *)PDUtranslate_message(PDM_I_PRT_SEL_NOT_COMPLETE);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,0);
		PALRestoreRefreshInfo(current_catalog, current_partid,
					current_revision, current_filename,
							current_description);
		return(0);
	}
	PrintRefreshInfo();

	status = GetRleFileName( file );
	if( status && ( strcmp( file, "nil" ) && strcmp (file, "") ) )
	{
                status = PALis_grraster();
                if (status != PDM_S_SUCCESS)
		{
                  msg = (char *)PDUtranslate_message(PDM_I_GRRASTER_NOT_LOADED);
              	  FIg_set_text(fp, FI_MSG_FIELD, msg);
		  status = 0;
		}
	}
	else if( !status )
        {
                msg = (char *)PDUtranslate_message(PDM_E_NO_SKETCH_FILE);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
        }
	if( status )
        if( !display_fig(MODPRT_F,ModifyPartForm,SKETCH,&my_env))
        {
                msg = (char *)PDUtranslate_message(PDM_E_LOAD_FILE_INFO);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
 	        status = 0;
        }
	if( !status )
		FIg_set_state_off( fp, SKETCH );

	/* 23/Nov/93 - raj.	*/
	/* Pop-up Show Graphics button, if raster file.	*/
	if (!MacroDisplayed)
		FIg_set_state_off( fp, SKETCH );

	/* 23/Nov/93 - raj.	*/
	PALRestoreRefreshInfo(current_catalog, current_partid,
				current_revision, current_filename,
						current_description);
        break;

    case DYN_NAMES:

         FImcf_get_active_col ( fp,  DYN_NAMES,  &col,  &pos );
         FIfld_get_active_row ( fp,  DYN_NAMES,  &form_act_row,  &pos );

         if( !Get_text(fp, DYN_NAMES, form_act_row, 0))
		break;

	 if( form_act_row < omac.num_loc_temp ){

		 _pdm_debug("template picked up: %s", s_text);

		if(  col ==  2 )
			FIfld_set_text(fp,DYN_NAMES,form_act_row,2,loc_temp_val[form_act_row],0);
		else {
			 temp_ndx = get_temp_index( temp_desc, omac.loc_temp[form_act_row], num_mac_temps );
			_pdm_debug(" temp name %s", omac.loc_temp[form_act_row]);
			 _pdm_debug("tempndx = %d", temp_ndx);
			 if( temp_ndx < 0 )
				break;
		         if(temp_desc[temp_ndx].type != double_type && 
	        		    temp_desc[temp_ndx].type != text_type )
				return(form_act_row+1);
/*
				select_new_grobj();
*/
		}
		break;
	 }

	 else {

		if( !strcmp(omac.dyn_attr[form_act_row-num_loc], "p_tagno" ))
			FIfld_set_text(fp,DYN_NAMES,form_act_row,2,
					dyn_attr_val[form_act_row-num_loc],FALSE );
		else 
			if( !process_dyn_attrs_mcf(MODPRT_F, ModifyPartForm, g_label, form_act_row , 
				(form_act_row - num_loc) , dyn_star_type, omac.dyn_attr[form_act_row-num_loc]))
			FIfld_set_text(fp,DYN_NAMES,form_act_row,2,
				dyn_attr_val[form_act_row-num_loc],FALSE );
	 }

	 break;

    case SEARCH :

	/* global search i.e., search for all the templates */
	/* where n_read set to 'Y'			    */

	display_all = 1;

	max_rows_rtvd = 0 ;

	/* Function below checks whether the search is on a 	*/
	/* single catalog or multiple catalogs and processes 	*/
        /* Function below checks whether the search is on a
           single catalog or multiple catalogs and processes */
        PDUmessage( PDS_M_LIST_OF_PARTS, 's' );

/* mjg - added function calls for search format or union attrs  3/4/94 */
        if (PDU_command == PDS_M_GET_UNION_ATTR)
          {
          _pdm_debug("searching all attributes", 0);
          status = search_on_multiple_ctlgs_with_union(
                      ModifyPartForm,TABLE,explstf,CATALOG);
          if (status == 1)
            PDUmessage(PDM_S_SUCCESS, 's');
          else
            PDUmessage(status,'s');
          }
        else if (PDU_command == PDS_M_GET_LIST_ATTR)
          {
          _pdm_debug("searching list attributes", 0);
          status = search_on_multiple_ctlgs_for_format(
                       ModifyPartForm,TABLE,explstf,CATALOG);
          if (status == 1)
            PDUmessage(PDM_S_SUCCESS, 's');
          else
            PDUmessage(status,'s');
          }
        else
          status = search_on_multiple_ctlgs(
                      ModifyPartForm,TABLE,explstf,CATALOG);
          if (status == 1)
            PDUmessage(PDM_S_SUCCESS, 's');
          else
            PDUmessage(status,'s');

	/* search_on_multiple_ctlgs(ModifyPartForm,TABLE, explstf,CATALOG);*/

        FIg_set_state_off(fp, SEARCH);

	/* TR#139306731,32 */
	FIg_enable( fp, EXP_LIST );
	FIg_enable( fp, PLUS );
	FIg_enable( fp, MINUS );


	break;

    case EXP_LIST :
	 /* display expanded listing form */
         FIg_set_state_off(fp, EXP_LIST);
	 FIf_display (explstf);
	 FIg_display (explstf, PARAMETERS);
	 FIg_display (explstf, SUB_TABLE);

         break;

	  
    case  PLUS:
	 if (row_num == max_rows_rtvd || row_num == 0) {
             FIg_set_state_off(fp, PLUS);
	     FIfld_set_text (fp,  10,  0,  0,  "At End of Data",  TRUE);
	     break ;
	 }
	 else {
            row_num = row_num + 1;
	    get_row_from_mcf (row_num,  NumAttribs ,   explstf,  SUB_TABLE);
            FIg_set_state_off(fp, PLUS);
            FIfld_set_text (fp,  10,  0,  0,  "",  TRUE);	 
            FImcf_set_select(explstf,  SUB_TABLE,  (row_num - 1),  1,  1);
	    break;
	 }

    case  MINUS:
	 if (row_num == 1 || row_num == 0) {
             FIg_set_state_off(fp, MINUS);	 
	     break ;
	 }
	 else {
             row_num = row_num - 1;
	     get_row_from_mcf (row_num,  NumAttribs,  explstf,  SUB_TABLE);
             FIg_set_state_off(fp, MINUS);
    	     FIfld_set_text (fp,  10,  0,  0,  "",  TRUE);
             FImcf_set_select(explstf,  SUB_TABLE,  (row_num - 1),  1,  1);
	     break;
	 }

    case SAVE_CRT:
	PALsavecrit = 1;
	PALgfname();
	FIg_set_state_off( fp, SAVE_CRT );
	break;
    case RESTORE_CRT:
	PALsavecrit = 0;
	PALgfname();
	FIg_set_state_off( fp, RESTORE_CRT );
	break;

    case SORT:
	status = PDUsort_form(NumAttribs,AttrList,AttrSynonym);
         _pdm_status("PDUsort_form", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           PALis_sort_selected = FALSE;
           }
	PALis_sort_selected = TRUE ;
	FIg_set_state_off( fp, SORT );
	break;

    case CATALOG:
	/* GBTYL : func params to be set */
	SelectCatalog (fp, CATALOG);
	ProcessNewCat();
	break;

    case PROJECT:
	select_project(fp);
	break;


    case PROJECT_BTN:
        FIf_cvrt_to_perm_win(fp);
        FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE);
        PDU_active_button = PROJECT_BTN;
        PDU_form_id = fp;
        PDU_refresh_gadgets[0] = PROJECT;
        PDU_refresh_gadgets[1] = CATALOG;
        _pdm_debug("Entering LIST_PROJECTS",0);

        status = PDUep_proj_btn();
        _pdm_status("PDUep_proj_btn",status);

        if (status != PDM_S_SUCCESS)
          FIg_set_state_off(fp, PROJECT_BTN);

        PDUmessage(status,'s');
        break;

    case PLCMNT_OPTIONS:
                if (UpdateRefreshStr(ModifyPartForm, TABLE))
                  {
                  PDUget_parttype(refresh->rev_catalog,
                                 refresh->rev_partid,
                                 refresh->rev_revision,
                                 &refresh->rev_parttype);
                  }

		PDUdesign_options_form();
		break;
			
    default:
	for( j = 0 ; j < MAX_LEVELS ; j = j + 1 ) {
		if( g_label == lab[j] ) {
			cur_level = j + 1 ;
			update_catalog(fp, MODPRT_F, &cur_level, g_label,lab);
			if(!display_all)
				FIf_reset(explstf);

			ProcessNewCat();
		}
	}
	break;
  }
/*
  if ( sts == TERMINATE )
  if(!strcmp(refresh -> rev_parttype,"P" )
		|| !strcmp(refresh -> rev_parttype,"PXT" )
		|| !strcmp(refresh -> rev_parttype,"CID" )
		|| !strcmp(refresh -> rev_parttype,"EID" ))
  {
    if(ActionUponAccept == PLACE_MACRO || ActionUponAccept == PART_SELECTION)
	return ( -2 ) ; |* Invoke Place Parametric Part command *|
  }
  else
	return( -3 ); |* Invoke processgrpart() 
*/
  
  return (0);
} 


CreateExpForm ()
{
	Form    tempf;

	if ( !init_forms(MODPRT_F, EXPLST_F,&tempf, &explstf, 1)) 
		return (0);
	FIf_delete( tempf );

	_pdm_debug("explstf created",0);

   	return (1);
}


InitModify()
{
   	/* This function retrieves templates' values AND		*/
   	/* sets initial field values before the form is displayed 	*/

   	int	i, limit ;
   	char   	**rootmac_temp_val;
	char 	*ptr;

	_pdm_debug("Enter InitModify() %d", ModifyPartForm);

    	/* By default set modify batch in delay mode */
    	nd$mod_batch(request    = ND_SET,
	 	req_mode   = ND_DEFER);

   	action_flag 	= 1 ;

	limit = 3; /* Always the "values" and "oper" columns will be in SINGLE_SELECT */

   	/* Set the limit no of columns in select mode */
   	for( i = 0 ; i < limit ; i = i + 1 ) 
		FIfld_set_mode(ModifyPartForm,TABLE,i,FI_SINGLE_SELECT); 

   	/* Set catalog field in select mode and fill it up */
   	FIfld_set_text(ModifyPartForm, CATALOG, 0, 0, refresh -> rev_catalog, TRUE);
	PDU_cat_selected = TRUE;

        if (!strcmp (cat_desc, "NULL"))
   	  FIfld_set_text(ModifyPartForm, CATDESC, 0, 0, "", TRUE);
        else
   	  FIfld_set_text(ModifyPartForm, CATDESC, 0, 0, cat_desc, TRUE);

	/* Update the Catalog's Path */
	UpdateCatPath( ModifyPartForm, refresh -> rev_catalog );

   	static_flag = 0;		/* Show static attribs by default ?? */

	_pdm_debug("calling set_gadgets",0);

   	set_gadgets(ModifyPartForm);

   	symb_mod_flag = 0 ;

   	/* Retrieve template and catalog attribute values of part located */
	/* from ACdyn_col template to the macro			  	  */
	if ( !is_it_grpart)
	   	if( ! GetTemp_N_AttrValues(part_located))
			return(0);

	_pdm_debug ("Returned from GetTemp_N_AttrValues()", 0);

	update_dynnames();

   	/* Set dyn parameters name row in single select mode */
   	for( i = 0 ; i < 2 ; i = i + 1 )
      		FIfld_set_mode(ModifyPartForm, DYN_NAMES, i, FI_SINGLE_SELECT);

   	_pdm_debug ("Set dyn parameters name row in single select mode", 0);

	_pdm_debug ("Allocate for the selection ci-macro templates' values", 0);

   	/* Set catalog attributes (also contians readable STATIC templates) */
	/* of the part located    					    */
        _pdm_debug("NumAttribs = <%d>", NumAttribs);
   	for( i = 0 ; i < NumAttribs ; i = i + 1 ) {
                _pdm_debug("i = <%d>", i);
		if (!strcmp (AttrList[i], "p_macro"))
			MacroRow = i;
		if( AttrSynonym[i] && strlen(AttrSynonym[i]) > 0) 
	       		FIfld_set_text(ModifyPartForm, TABLE, i, 0, AttrSynonym[i], FALSE);
		else 
	       		FIfld_set_text(ModifyPartForm, TABLE, i, 0, AttrList[i], FALSE);
                if (strcmp( cat_attr_val[i],"NULL"))
		FIfld_set_text(ModifyPartForm, TABLE, i, 1, cat_attr_val[i], FALSE);

	}

   	/* Set criteria of catalog attributes */
   	if( SelCiMacFlag ) {	/* If Selection Ci-macro		*/
				/* set the criteria in that columns	*/

		char oper[15] ;
		int nb_par ;
		struct GRid *list_temp= NULL ;

		PDU_auto_part_selection = TRUE; /**** Added 06/04/93 *****/
		GetACdyncolExpTempls(&ACdyn_col_obj,&nb_par,&list_temp);

		GetCriteria(NumAttribs, ACdyn_col_obj, &my_env, 
				&rootmac_temp_val,nb_par,list_temp);

		free( (char *)list_temp);

          	for( i = 0 ; i < NumAttribs; i = i + 1 ) {
			

			if( !strcmp(rootmac_temp_val[i],"=,0"))
				continue;

			/* get operator first */
			ptr = strtok( rootmac_temp_val[i],","); 
			strcpy(oper,ptr);
			define_Foperator(oper);

              		if( rootmac_temp_val[i][strlen(ptr)+1] !=  '0')  {
                  		FIfld_set_text(ModifyPartForm, TABLE, i, SEARCH_COL, &rootmac_temp_val[i][strlen(ptr)+1], FALSE);
                  		FIfld_set_text(ModifyPartForm, TABLE, i, OPER_COL, oper, FALSE);
			}
              		MyFree(rootmac_temp_val[i]);
          	}
		MyFree (rootmac_temp_val);
   	}

        _pdm_debug("set_sub_form_params", 0);
    	set_sub_form_params ( explstf, PARAMETERS, AttrSynonym,AttrList,NumAttribs, 0 ); 

	UpdatePartType(ModifyPartForm,TABLE,refresh->rev_catalog);
        if ((strcmp(refresh->rev_parttype, "P") == 0) ||
            (strcmp(refresh->rev_parttype, "PXT") == 0) ||
            (strcmp(refresh->rev_parttype, "p") == 0))
          {
	          FIg_set_state_on(ModifyPartForm, 19);
	          FIg_disable(ModifyPartForm, 19);
          }

	set_active_form_ptr( ModifyPartForm );
	PDUmessage(PDM_E_CLEAR_FIELD, 's' );

	return (1);
}

GetMacroHeaderGivenGrid (grid, mac_hdr)
struct GRid grid ;
struct GRid *mac_hdr;
{
	int	sts;
        sts = om$send( msg = message ACcpx.find_macro( mac_hdr),
                      	         targetid = grid.objid,
        	        	 targetos = grid.osnum,
				senderid = grid.objid);

      	_MO_omerr_chk("ACcpx.find_macro : GetMacroHeaderGivenGrid () : ", sts, wrapup);

	return (1);

wrapup :
	return (0);
}


ProcessData()
{
	int 		i = 0, num_exp_objs, splcase = FALSE;
	int 		num_temps = 0, cnt ;
	char    	**temp_val;
        char            *msg_str;
/*	char		*part_no = NULL, *child_no= NULL;*/
	struct GRid 	*exp_list ;
	struct GRid 	selci_tempid[MAX_TEMP];
	struct	GRid	*list = NULL ;
	struct  GRid	hdr;
	long msg;
/*	struct GRmd_env lenv;*/

	char **vals, *computed_id = NULL;

	/* TR# 13941 8747.	*/
	int	sts;
	char	p_usageid[32], formula[128];
	char 		dir_name[DI_PATH_MAX];

	_pdm_debug("Enter ProcessData..",0);

	/* TR # 13938062. 04/AUG/93.	*/
	/* If the part is from a CID catalog (computed-id), then the
	   user must do a global search and select the values for all the
	   attributes on the form.
	   The flag 'multiple_parts' is set during part selection, when
	   catalog is of type CID or EID. Flag 'display_all' is set when
	   user pokes at the SEARCH button and a global search is done.
	*/
	/* see if a part is uniquely selected  */
	if ( ( multiple_parts && !display_all ) )
	{

/*	22/Nov/93 - raj. Change warn box to message to form message field.	*/
/*		FlashMessage (PDR_E_nDef);					*/
                msg_str = (char *)PDUtranslate_message(PDR_E_nDef);
		FIfld_set_text(ModifyPartForm,FI_MSG_FIELD,0,0,msg_str,0);
       	        return(0); ;
        }
	/****************************************************************/

	/* Check if all values for catalog attributes and DYNAMIC 	*/
	/* templates are selected.					*/
	/* Update PDUrefresh structure */
	if( !UpdateRefreshStr(ModifyPartForm,TABLE) ){
                msg_str = (char *)PDUtranslate_message(PDM_I_PRT_SEL_NOT_COMPLETE);
		FIfld_set_text(ModifyPartForm,FI_MSG_FIELD,0,0,msg_str,0);
		return(0);
	}
	if( ! UpdatePartType(ModifyPartForm,TABLE,refresh -> rev_catalog))
		return(0);

	if(  strcmp(refresh -> rev_parttype,"P" )
		&& strcmp(refresh -> rev_parttype,"PXT" )
		&& strcmp(refresh -> rev_parttype,"CID" )
		&& strcmp(refresh -> rev_parttype,"EID" )	)
	{
/*
		if(!processgrpart())
			return(0);
*/
		return(-1);
	}

	/*
	 * 17/Dec/93 - raj.	TR # 13931 1475.
	 * If catalog has p_macro attribute only.
	 * Let me see if user has selected a new macro. I need to set
	 * ActionUponAccept flag to delete old macro and place new one.
	 */
	if (MacroRow != -1)
	  if(!IsDfntMacroSelected())
		return (0);
/* 22/Dec/93 - raj.	TR# 13931 4305.		*/
/* Get header for macro part only (non GRparts).*/
	if (!is_it_grpart)
	if( !GetMacroHeaderGivenGrid( part_located, &hdr ))
		return(0);
		
	/*********************************************************************/
	/* Simple modification, NEITHER a new macro (under the same catalog) */
	/* NOR a new catalog, was selected.				     */
	/*********************************************************************/	
	if (ActionUponAccept == MODIFY )
	{
	    _pdm_debug("ActionUponAccept = MODIFY",0);

	    if (!GetDynAttrValsOnForm ())
		return (0);

	    /******************************************************************/
	    /* CRITERIA DRIVEN ACDYN_COL OBJECT :			      */
	    /******************************************************************/
	    /* Get the criteria keyed in for catalog attris and format them.  */
	    /* Instance a new criteria driven ACdyn_col object, and 	      */
	    /* delete the old one and swap connections to the new one	      */
	    if((PDU_auto_part_selection == TRUE) || (SelCiMacFlag == TRUE)) 
	    {
		struct GRid tmpid;
	
		GetChildNumber (&PALchild_no, &coll_list[num_coll-1]);
		tmpid = ACdyn_col_obj ;		
		
		ACdyn_col_obj.objid = NULL_OBJID ;
		if( ! PDUcreat_rgbox("", &my_env, &ACdyn_col_obj) ) {
			_pdm_debug("PDUcreat_rgbox failed",0);
			return(0);
		}
		coll_list[0] = ACdyn_col_obj;

		AddStdAttribsToColl( coll_list, num_coll,
					 refresh -> rev_catalog, 
					 refresh -> rev_partid,
					 refresh -> rev_revision,
					 &my_env); 

		if( PDU_ComputedID == FALSE )
		{		
			if(!GetStaticAttribsAddToRgObj(&hdr, StatAttribs,StatTypes,StatUnits,
						num_stat,coll_list))
				return(0);
		}
		else
		{
			/* Read Static Attrib Vals from the form and Add to Coll */
			if( !ReadStatAttribsonForm( refresh->rev_catalog, ModifyPartForm,
						    TABLE, StatAttribs, StatTypes,
						    StatUnits,num_stat,coll_list))
			{
                		_pdm_debug("Error creating static attrs in rg_collect",0);
	                	return(0);
        		}
		}
	        if((PDU_auto_part_selection == FALSE) && (SelCiMacFlag == TRUE)) 
		{
			if( num_coll == 1 ) /* Create dyn exp templates */
			{
				CreateDynTemps( 0, &exp_list, &num_temps );
				define_temp_to_ACdyncol(num_temps, exp_list,
						 &ACdyn_col_obj,&my_env);
				splcase = 1;
				MyFree (exp_list);
			}
		}
		else
		{
			if (!GetCatAttrCriteriaAndFormat (&temp_val, selci_tempid,
						 &num_exp_objs, &my_env))
				return (0);

			if (!CreateTemplatesToACdyncol (&num_temps, &exp_list,
						num_exp_objs, temp_val, 
						selci_tempid, &my_env ))
				return (0);

			selection_temp_to_ACdyncol(num_temps, exp_list,
						 &ACdyn_col_obj,&my_env, num_coll);

			if( (num_coll == 1) && (SelCiMacFlag == FALSE) )
			{
				num_temps = NumAttribs + num_exp_objs;
				splcase = 2;
			}
			MyFree (exp_list);
		}

		/* TR#139307085 - do a change_connect to all the dependents, before
                                  deleting the static collection.
                */
	      	sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN,NULL,
							  0, NULL,
							  0, OM_K_MAXINT, &cnt),
        	               	targetid = tmpid.objid, 
                	       	targetos = tmpid.osnum,
				senderid = tmpid.objid);

	     	_MO_omerr_chk("NDnode: NDgetobjects : ProcessData() : ",  sts,  wrapup);

		if( cnt > 1 ) /* only if more than one part is a dependent */
		{
			list = (struct GRid *)malloc( sizeof(struct GRid) * cnt );
		      	sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN,
                                                                          list,
							  		  cnt, NULL,
							       0, OM_K_MAXINT, &cnt),
        	               	targetid = tmpid.objid, 
                	       	targetos = tmpid.osnum,
				senderid = tmpid.objid);

		     	_MO_omerr_chk("NDnode:NDgetobjects:ProcessData():",sts,  wrapup);
			
			for ( i = 0; i < cnt; i ++ )
				if ( list[i].objid != part_located.objid )
				{
			            sts = om$send( msg = message NDnode.NDchange_connect(
								1,&tmpid,&ACdyn_col_obj), 
		                       		targetid = list[i].objid, 
                		       		targetos = list[i].osnum ,
		       				senderid = list[i].objid);

		            	     _MO_omerr_chk("NDnode.NDchange_connect",sts, wrapup);
				}
			MyFree(list);
			list = NULL;
		}

		/* Delete old ACdyn_col object	*/
		sts = om$send(msg = message GRgraphics.GRdelete(&msg,&my_env),
				targetid = tmpid.objid,
				senderid = tmpid.objid,
				targetos = tmpid.osnum );

		/* Set the first collection template to new ACdyn_col_obj */
		temp_id[num_loc] = ACdyn_col_obj ;

	    }	/* End of modify sel ci mac templates	*/

	    /******************************************************************/
	    /* NORMAL MACRO MODIFICATION				      */
	    /******************************************************************/
	    else 
	    {	/* NO Selectio Ci-macro in picture	*/

		_pdm_debug("calling GetUniqRecord",0);

		/* Get STATIC templates' values	*/

		if( PDU_ComputedID == FALSE )
		{
			if( !GetStaticAttribsAddToRgObj(&hdr, StatAttribs,StatTypes,
					StatUnits,num_stat, coll_list))
				return(0);
		}
		else
		{
			/* Read Static Attrib Vals from the form and Add to Coll */
			if( !ReadStatAttribsonForm( refresh->rev_catalog, ModifyPartForm,
						  TABLE, StatAttribs, StatTypes,
						  StatUnits,num_stat,coll_list))
			{
        	        	_pdm_debug("Error creating static attrs in rg_collect",0);
	        	        return(0);
        		}
		}

		_pdm_debug("Modify StaticTemplates complete",0);

		GetChildNumber (&PALchild_no, &coll_list[num_coll-1]);

		AddStdAttribsToColl( coll_list, num_coll,
				    refresh -> rev_catalog, 
				    refresh -> rev_partid,
				    refresh -> rev_revision,
				    &my_env); 

	    }	/* End of oridinary macro modification	*/


            /* Modify DYNAMIC templates */
            if( !GetACdyncolExpTempls(&coll_list[num_coll-1],&cnt,&list))
		return(0);

	    for( i = 0 ; i < omac.no_dyn_attr ; i = i + 1 ) {

		_pdm_debug("omac.dyn_attr: <%s>", omac.dyn_attr[i]);

		if( strlen(dyn_attr_val[i]) < 1 )
			continue ;

		/* TR# 13941 8747. Begin.	*/
		/* 20/Apr/94 - raj.		*/
		/* Generate usage id if user did not key in one.	*/
		if (!strcmp(omac.dyn_attr[i], "p_usageid"))
		{
		  _pdm_debug("begin processing p_usageid", 0);

                  /* See if user keyed in a different p_usageid value.	*/

                  _pdm_debug("Get old usage id from ACdyn_col", 0);
                  
                  /* Get old usage id from ACdyn_col now.	*/
                  sts = om$send ( msg = message expression.give_formula(formula),
					targetid = list[dyn_attr_ndx[i]].objid,
					senderid = list[dyn_attr_ndx[i]].objid,
					targetos = list[dyn_attr_ndx[i]].osnum);

		  if (!(sts&1))
		  {
                    return(0);
                  }
                  
	     	  _pdm_debug ("Formula: <%s>\n", formula);

	     	  remove_quotes(formula); 

	     	  strcpy(p_usageid,formula);

		  _pdm_debug("old usage id: <%s>", p_usageid);
  		  _pdm_debug("new usage id: <%s>", dyn_attr_val[i]);
  		  
                  if (!strcmp(dyn_attr_val[i], p_usageid))
                  {
                    _pdm_debug("Same usage id. Generating new one.", 0);

                    /* User did not change p_usageid, need generate new one. */
                    strcpy(p_usageid, "");

                    /* generate usageid */
                    sts = PDUget_default_usage_id(refresh->rev_catalog,refresh->rev_partid,
                                     refresh->rev_revision, p_usageid);
                    _pdm_status("PDUget_default_usageid", sts);

                    if ((p_usageid != NULL) && (strcmp(p_usageid, "") != 0))
                    {
                      _pdm_debug("usageid = <%s>", p_usageid);
                      PDUfill_in_string(&PDU_usage_id, p_usageid);
                      strcpy(dyn_attr_val[i], p_usageid);
                    }
                  }
       		  _pdm_debug("end processing p_usageid", 0);
                }
		/* TR# 13941 8747. End.	*/
		
		/* Global array filled in 'ExtractDyn... () ' for the */
		/* channel numbers				     */
		/* attribute 'dyn_attr_val[i]' at 'dyn_attr_ndx[i]]';*/

		_pdm_debug("exp_syntax: %s",dyn_attr_val[i]);
		_pdm_debug("dynattrindx %d",dyn_attr_ndx[i]);

		if( !splcase )
		{
			sts = exp$modify(exp_id = list[dyn_attr_ndx[i]].objid,
				   osnum  = list[dyn_attr_ndx[i]].osnum,
			           exp_syntax = dyn_attr_val[i]);
			_MO_omerr_chk("exp$modify : ",sts,wrapup);
		}
		else if( splcase == 1 )
		{
			sts = exp$modify(exp_id = list[i].objid,
				   osnum  = list[i].osnum,
			           exp_syntax = dyn_attr_val[i]);
			_MO_omerr_chk("exp$modify : ",sts,wrapup);
		}
		else if( splcase == 2 )
		{
			
			sts = exp$modify(exp_id = list[num_temps+i].objid,
				   osnum  = list[num_temps+i].osnum,
			           exp_syntax = dyn_attr_val[i]);
			_MO_omerr_chk("exp$modify : ",sts,wrapup);
		}
           }

/* Added on 04/04/93 */
	    _pdm_debug("rev_partid = %s", refresh->rev_partid ); 
	    if( !strcmp (refresh->rev_partid, "computable") )
	    {
		vals  = (char **)malloc(sizeof(char *) * NumAttribs);

		/* append the static & catalog attributes */
		for( i = 0 ; i < NumAttribs; i++ )
		{
			Get_text(ModifyPartForm,TABLE,i,1);
			vals[i]  = (char *)malloc(strlen(s_text) + 1 );
			strcpy( vals[i], s_text );
		}
		
		_pdm_debug("Calling GetID_N_Compute",0);

		if( GetID_N_Compute(refresh->rev_catalog, AttrList, vals, AttrTypes, 
					NumAttribs, &computed_id,0 ))
		        add_attribute(coll_list, computed_id, "n_itemname",AC_ATTRIB_TEXT);
		else
		{
			_pdm_debug("ComputeID failed",0);	
			return(0);
		}

		MyFree(computed_id);

/*
		if( !ComputeIDAddToDynCol( refresh->rev_catalog, coll_list))
		{
			_pdm_debug("ComputeID failed",0);
			return(0);
		}
*/
	    }
/* end */

           if( list )
		free( (char *) list );

	    _pdm_debug("before NDconnect: ", 0 );            
            sts = om$send( msg = message NDnode.NDconnect(num_temp, temp_id, 
                                            NULL_GRID, ND_FULL ), 
                       		targetid = part_located.objid, 
                       		targetos = part_located.osnum ,
		       		senderid = part_located.objid);

            _MO_omerr_chk("NDnode.NDconnect : ProcessData () : ", sts, wrapup);

	    _pdm_debug("After NDconnect: ", 0 );            


/*TR# 13941 8747. Begin.	*/
            /* To add entry in directory */
            _pdm_debug("before naming in directory: %s", PDU_usage_id);

            /* make absolute path from the main directory  */
            DIstmocpy(dir_name, "PDU", "macro_parts", PDU_usage_id, 0, my_env.md_id.osnum);

            _pdm_debug("absolute path : %s", dir_name);

            di$mkpath( pathname = dir_name );

            sts = om$send(msg = message GRvg.GRchgname(&msg, &my_env, dir_name),
                      targetid = part_located.objid,
                      senderid = part_located.osnum,
                      targetos = my_env.md_id.osnum );

            _MO_emerr_chk("GRchgname : name", msg, wrapup);
            _MO_omerr_chk("GRchgname : name", sts, wrapup);

            _pdm_debug("after naming object ", 0 );
/*TR# 13941 8747. End.		*/

	    /* Now get all the dependent parts of this static collection, AC_dyncol_obj
               and put them in the ND batch, for recompute
	    */
	    
            if( PALnotification_flag == FI_ACCEPT) 
		compute_dependents( &ACdyn_col_obj, 1 ); /* do nd$exec_batch */
	    else
		compute_dependents( &ACdyn_col_obj, 0 ); /* Just put them in batch */

	    _pdm_debug("Leaving ProcessData(): ", 0 );            	

	    MyFree(PALchild_no );
	    return (-2);

	}	/* End of simple modification		*/

	/**********************************************************************/
	/* NEW MACRO (SAME CATALOG) or DIFFERENT CATALOG		      */
	/**********************************************************************/
	/* Check flag which indicates the course of action */

	if(ActionUponAccept == PLACE_MACRO || 
                    	ActionUponAccept == PART_SELECTION)
	{

		/* Get serial_no before the macro is deleted	*/
		if( ! is_it_grpart )
			GetChildNumber (&PALchild_no, &coll_list[num_coll-1] );

		/* Delete the macro	*/
		_pdm_debug("Calling Delete Part",0);
		if( !is_it_grpart )
                        {
                        /* use API instead to prevent looping with EMS */
                        /*delete_prpart (&part_located, &my_env); */
                        pdmoDeletePartOccurrence(&msg, NULL, &part_located);

/* 19/apr/94 - raj. Force immediate processing to delete the object now. Begin.	*/
	_pdm_debug("Exeucuting bacth. Begin", 0);
        nd$mod_batch(request    = ND_SET,
                     req_mode   = ND_IMMEDIATE);

        nd$exec_batch();
	_pdm_debug("Exeucuting bacth. Done", 0);
/* 19/apr/94 - raj. Force immediate processing to delete the object now. End.	*/

                        }

		if (ActionUponAccept == PLACE_MACRO){
		
			_pdm_debug("ActionUponAccept: PLACE_MACRO",0);
			grid_list = (struct GRid *)malloc( 2 * sizeof(struct GRid));
			grid_list[0] = temp_id[0] ;
			PALMacintf = PLCMNT_MOD_PART;
		}

		else{
			_pdm_debug("ActionUponAccept: PART+SELECTION",0);
			grid_list = NULL ;
			PALMacintf = PLCMNT_STD_INTF ;
		}

		if( is_it_grpart ) 
			return( -3 );
		return (-4);
	}
wrapup :
	return (0);
}

GetCatalogTemplateValue(macro,  no_temps,  catalog_name)
int		no_temps;
char		**catalog_name;
struct GRid 	*macro ;
{
	/* Given the number templates, gets the objid of the ACdyn_col 	  */
	/* object which is always the last template of the edited macro.  */
	/* With this objid, it retrieves the value of 'n_catalogname' 	  */
	/* stored in the ACdyn_col object copies it to parameter 	  */
	/* 'catalog_name'.						  */

	int	alsize, cnt;
	IGRmatrix tmat;
	IGRshort  mat_type;

	_pdm_debug("PAL -- Enter GetCatalogTemplateValue",0);

     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, &ACdyn_col_obj, 1,
						    NULL, no_temps-1, no_temps-1, &cnt),
                       	targetid = macro->objid, 
                       	targetos = macro->osnum,
			senderid = macro->objid);

     	_MO_omerr_chk("GetCatalogTemplateValue () : NDnode.NDgetobjects ",  sts,  wrapup);

	/* Might be a pretend, get the original.	*/
	sts = om$send(msg = message NDnode.ASreturn_go( &ACdyn_col_obj,
							&mat_type, 
							tmat),
					senderid = ACdyn_col_obj.objid,
					targetid = ACdyn_col_obj.objid,
					targetos = ACdyn_col_obj.osnum);

	_pdm_debug("ACdyncolobj:%d",ACdyn_col_obj.objid);

	/* Retrieve value of 'n_catalogname' from ACdyn_col object */
	(*catalog_name)[0] = '\0';

	alsize = 32;
	if (!GetACrgAttribVal (&ACdyn_col_obj,  "n_catalogname",  catalog_name,  &alsize))
		return (0);

	/* Return with '\1' appended,  remove it */
	(*catalog_name)[strlen(*catalog_name) - 1] = '\0';

	_pdm_debug("Catalog Template = %s", *catalog_name);

	return (1);

wrapup :
	return (0);
}

get_obj_name(grid, partname)
struct GRid grid ;
char partname[];
{
char text1[DI_PATH_MAX], text2[DI_PATH_MAX] ;
struct GRid mac ;                  

	_pdm_debug("Entered get_obj_name",0);

     sts = om$send(msg = message ACpretend.ACgive_downscan(text1), 
                         targetid = grid.objid, 
                         targetos = grid.osnum,
				senderid = grid.objid);


     if(sts&1){
	_pdm_debug("text1 = %s",text1);
           sts = om$send(msg = message ACpretend.ACfind_parent(&mac, NULL, NULL), 
                         targetid = grid.objid, 
                         targetos = grid.osnum,
				senderid = grid.objid);
           if(sts&1){
                    sts = om$send(msg = message GRvg.GRgetname(&msg, text2), 
                                        targetid = mac.objid, 
                                       targetos = mac.osnum,
				senderid = mac.objid);
              	    if(sts&msg&1){
                                  strcat(text2, ":");
                                  strcat(text2, text1); 
                                  strcpy(partname, text2); 
                    }
           }
     }

     else{

           /* see if it is a exp object */
           if(check_obj_class(grid)) {
              di$untranslate( objname = partname, 
                              objid = grid.objid, 
                              osnum = grid.osnum );
           }
           else {
           
              sts = om$send(msg = message GRvg.GRgetname(&msg, text1), 
                               targetid = grid.objid, 
                               targetos = grid.osnum,
				senderid = grid.objid);

              if(sts&msg&1) strcpy(partname, text1);
           }
     }

	return (1);
}

get_loc_obj( type)
int *type;
{
        /* highlight old object */
        HiLiteObject(GRhd, temp_id[temp_ndx]);

        switch(temp_desc[temp_ndx].type) 
	{
		case point_generic:
			*type = POINT_TYPE;
			break;
		case ref_generic:
			*type = CS_TYPE;
			break;
		case line_generic:
			*type = LINE_TYPE;
			break;
		case circle_type:
			*type = CIRCLE_TYPE;
			break;
		case arc_type:
			*type = ARC_TYPE;
			break;
		case lbs_generic:
			*type = LBS_TYPE;
			break;
		case plan_type:
			*type = PLANE_TYPE;
			break;
		case surface_generic:
			*type = SURF_TYPE;
			break;
		case curve_generic:
			*type = CURVE_TYPE;
			break;
		case macro_generic:
			*type = MACRO_TYPE;
			break;
		case solid_generic:
			*type = SOLID_TYPE;
			break;
		default:
			*type = UNKNOWN_TYPE;
			break;
        }                     

	return (1);
}

set_new_obj( grid )
struct GRid *grid;
{
char objname[150];

        HiLiteObject(GRhe, temp_id[temp_ndx]);

        /* If object is located get its name and set its name */
        as$make_source(go_grid = *grid, 
                       as_os = grid->osnum, 
                       as_grid = &temp_id[temp_ndx]);

	objname[0] = '\0';
        get_obj_name(temp_id[temp_ndx], objname);

	if( strlen( objname ) > 1 )
        FIfld_set_text(ModifyPartForm, DYN_NAMES, form_act_row, 2, objname, TRUE);
	else
	FIfld_set_text(ModifyPartForm, DYN_NAMES, form_act_row, 2, "", TRUE);

	return(1);
} 

HiLiteObject(mode, obj)
enum GRdpmode mode;
struct GRid obj;
{
struct GRid mac ,  par_id;
char text1[DI_PATH_MAX] ;
IGRshort mat_type,  i  ;
IGRmatrix matrix ;

     mat_type = my_env.md_env.matrix_type ;

     for( i = 0 ; i < 16; i = i + 1 )
          matrix[i] = my_env.md_env.matrix[i] ;

     sts = om$send(msg = message ACpretend.ACgive_downscan(text1), 
                         targetid = obj.objid, 
                         targetos = obj.osnum,
				senderid = obj.objid);

     if(sts&1){
           sts = om$send(msg = message ACpretend.ACfind_parent(&par_id, NULL, NULL), 
                         targetid = obj.objid, 
                         targetos = obj.osnum,
				senderid = obj.objid);

           sts = om$send( msg = message ACncpx.ACreturn_foot(&msg, 
                                      text1, 
                                      &mac, 
                                      &mat_type, matrix), 
                         targetid = par_id.objid, 
                         targetos = par_id.osnum,
				senderid = par_id.objid);
           if( ! sts & msg & 1 )
                  return (0);
      }

      else 
           mac = obj ;

#ifdef DEBUG
  printf("objd: mode : %d %d %d\n ",  mode,  mac.objid,  mac.osnum );
#endif

  sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
					&mat_type, 
					matrix, 
					&mode,  &my_env.md_id), 
	  targetid = mac.objid, 
	  targetos = mac.osnum,
				senderid = mac.objid);

   _MO_emerr_chk("GRgraphics.GRdisplay : HiLiteObject () : ", msg, wrapup);
   _MO_omerr_chk("GRgraphics.GRdisplay : HiLiteObject () : ", sts, wrapup);

	return (1);

wrapup :
	return (0);
}

get_exp_name(fp,glabel,row)
Form fp ;
int glabel, row ;

{
	/* This function gets the value of a dynamic parameter from 	*/
	/* the user and updates the corresponding row on the form.	*/
	/* These new values will be read from the form in 'ProcessData ()' */
	/* and the corresponding attributes in the ACdyn_col will be 	*/
	/* set equal to these new values there.				*/

	/* form_act_row is the row on which user picked on the form 	*/
	/* right now I expect only dynamic templates to be displayed on	*/
	/* DYN_NAMES mcf.						*/
        /* The order is : locatables come first followed by expressions.*/

	Get_text(fp,glabel,row,2);

	dyn_attr_val[form_act_row - num_loc] = (char *) realloc 
				(dyn_attr_val[form_act_row - num_loc],  
				(strlen (s_text) + 1) * sizeof (char));
	MemCheck (dyn_attr_val[form_act_row - num_loc]);

	strcpy(dyn_attr_val[form_act_row - num_loc], s_text);
                  
        return(1);
}

extern plane_locate();

#define DOUBLE_SIZE 8

plane_dyn_params(grid)
struct GRid *grid ;
{
     IGRdouble	rds[ EX_RESPONSE_DATA_SIZE / DOUBLE_SIZE ];
     IGRchar       * response_data ,  buff [60];
     struct GRid tmp_grid ;

     response_data =  (char *)rds;
     ex$message( msgnumb = PDR_P_LocNewpt, 
                 buff    = buff );

     sts =  plane_locate(response_data, buff, &tmp_grid);

           if( sts == -1 ) return(0);  // in case of reset button
           if( sts == -2 ) return(-1); // in case of backup button

     as$make_source(go_grid = tmp_grid, 
                       as_os = tmp_grid.osnum, 
                       as_grid = grid);

     return(1);
}

GetTemp_N_AttrValues(located_part)
struct GRid located_part ;
{
	/* Gets the values of all the templates and other attributes in */
	/* ACdyn_col object of the macro and stores their values in	*/
	/* global vars 'dyn_attr_val', 'loc_temp_val' 			*/
	/* and 'cat_attr_val' for later use. 				*/

	int 		cnt, i, ind , alsize;
	char 		objname[DI_PATH_MAX] , *tmp;
	struct GRid 	*list;

	_pdm_debug("Enter GetTemp_N_AttrValues",0);

     	/* Get template count of the macro	*/
      	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT,NULL, 0, NULL,
							  0, OM_K_MAXINT, &cnt),
                       	targetid = located_part.objid, 
                       	targetos = located_part.osnum,
			senderid = located_part.objid);

     	_MO_omerr_chk("NDnode: NDgetobjects : GetTemp_N_AttrValues () : ",  sts,  wrapup);

	_pdm_debug("no. of temps %d",cnt);

	/* Get the objids of all the templates of the macro	*/
	list = (struct GRid *)malloc( cnt * sizeof( struct GRid ));

     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, list, cnt,
						    NULL, 0, OM_K_MAXINT, &cnt),
                       	targetid = located_part.objid, 
                       	targetos = located_part.osnum,
			senderid = located_part.objid);

     	_MO_omerr_chk("NDnode: NDgetobjects : GetTemp_N_AttrValues () : ",  sts,  wrapup);
	
	/* Store the template ids	*/
     	num_temp = cnt ;
        for (i = 0; i < num_temp; i++)
            temp_id[i]  = list[i];

     	loc_temp_val  = (char **) malloc ( num_loc * sizeof (char *));

     	MemCheck (loc_temp_val);

     	/* The macro has 2 ACdyn_col object as the LAST two templates   */
     	/* ALL locatable type templates preceding . 			*/

     	/* So FIRST get object name of each locatable type template	*/
     	for( ind = 0 ; ind < num_loc; ind++) {
           objname[0] = '\0' ;
	   get_obj_name(list[ind], objname);

	   _pdm_debug("object name %s",objname);

	   loc_temp_val[ind] = (char *) malloc ((strlen (objname) + 1) );
	   MemCheck (loc_temp_val[ind]);

           strcpy(loc_temp_val[ind], objname);
     	}

	free( (char *)list );


     	/* Get values of each catalog atrribute	using STATIC templates' values*/

   	tmp = (char *) malloc (32 * sizeof (char));
	MemCheck (tmp);
	tmp[0] = '\0';
	alsize = 32;

	if( !GetACrgAttribVal(&ACdyn_col_obj, "n_itemname", &tmp, &alsize))
		return(0);

	tmp[strlen (tmp)-1] = '\0';

	mystrcpy(&(refresh -> rev_partid),tmp);

	tmp[0] = '\0' ;

	GetACrgAttribVal(&ACdyn_col_obj, "n_itemrev", &tmp, &alsize);
	tmp[strlen (tmp)-1] = '\0';
	mystrcpy(&(refresh -> rev_revision),tmp);

	free( tmp);

	if( !check_CID(refresh -> rev_catalog, &ACdyn_col_obj))
		return(0);

	if(!update_cat_val(refresh->rev_partid, refresh->rev_revision) )
		return(0);
     	return(1);

wrapup:
     	return(0);
}

update_cat_val(partno,partrev)
char *partno, *partrev ;

{ 
	int   i;
	char  *tmp, *output_str ;
	extern char *attribs_in_ID, *vals_of_attribs_in_ID;
	char *tmp1, *tmp2;

/*
        Note: No dynamic attrs supported in Computed ID - TBD 

	if( PDU_ComputedID)
	{
		     Remove any dynamic attributes from the global strings
                     attribs_in_ID and vals_of_attribs_in_ID, filled in getatts()
                     during the reverse transformation of computed ID 

		mystrcpy( &tmp1, attribs_in_ID );
		mystrcpy( &tmp2, vals_of_attribs_in_ID );
		for( i = 0; i < num_dyn; i++ )
		{
			remove_dynatr( &tmp1, DynAttribs[i], &pos );
			if( pos == -1 )
				continue;
 			else remove_dynval( &tmp2, pos );
			_pdm_debug("tmp1 = %s", tmp1 );
			_pdm_debug("tmp2 = %s", tmp2 );
		}
		strcpy( attribs_in_ID, tmp1 );
		strcpy( vals_of_attribs_in_ID, tmp2 );
	}
*/
        if (PDU_ComputedID && (num_coll != 1))
          AddStatAttrsToQuery(&ACdyn_col_obj);
	if( ! GetUniqRecord (refresh -> rev_catalog, 
				partno,
				partrev,
		     		AttrList, NumAttribs, 
				&output_str))
	return(0);

	tmp = strtok(output_str,"~");
	i = 0 ;

	cat_attr_val = (char **)malloc( NumAttribs * sizeof(char *));
	MemCheck (cat_attr_val);
	
	while(tmp != NULL ) {

		cat_attr_val[i] = (char *)malloc(strlen(tmp) + 1 );
		if( !strcmp(tmp,"nil"))
			cat_attr_val[i++][0] = '\0' ;
		else
			strcpy(cat_attr_val[i++],tmp);

		tmp = strtok(NULL,"~");
	}

	free( output_str);
	return(1);
}


MODsleep()
{
        if( ModifyPartForm)
            FIf_erase(ModifyPartForm);
        if(explstf)
            FIf_erase(explstf);
        return (1);
}

set_gadgets(fp)
Form fp ;
{
         if( static_flag == 1 ) {
             static_flag = 0 ;
             FIg_erase(fp, STAT_GRP);
             FIg_display(fp, DYN_GRP);

	     FIg_disable(fp, SEARCH);
	     FIg_disable(fp, EXP_LIST);
         }
         else{
             static_flag = 1 ;
	     FIg_erase(fp, DYN_GRP);
             FIg_display(fp, STAT_GRP);
	
	     FIg_enable(fp, SEARCH);
	     FIg_enable(fp, EXP_LIST);
         }
	return (1);
}


GetACrgAttribList (acdyncol, list_attr, nb_attr)
struct GRid *acdyncol;
struct ACrg_coll **list_attr;
int *nb_attr;
{
	IGRlong		sts, msg;

	_pdm_debug ("Enter GetACrgAttribList ", 0);


	/* If pointer to "struct ACrg_coll" is NULL, the message 	*/
	/* RETURNS the no of attributes in 'nb_attr'			*/
	sts = om$send (	msg	= message ACrg_collect.AClist_attribute( 
						&msg, 0, 
						NULL, nb_attr),
			targetid = acdyncol->objid,
			targetos = acdyncol->osnum ,
			senderid = acdyncol->objid);

	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", msg, wrapup);
	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", sts, wrapup);

	_pdm_debug ("No Of Attribs %d", *nb_attr);

	/* The message expects an array of structures of type	*/
	/* "struct ACrg_coll" of length 'list_len' to be allocated for	*/
	/* in advance. 							*/

	/* Allocate for the no of attributes in ACdyn_col object	*/
	*list_attr = (struct ACrg_coll *) malloc ( *nb_attr * sizeof (struct ACrg_coll));
	MemCheck (*list_attr);

	sts = om$send (	msg	= message ACrg_collect.AClist_attribute( 
						&msg, *nb_attr, 
						*list_attr, nb_attr),
			targetid = acdyncol->objid,
			targetos = acdyncol->osnum ,
			senderid = acdyncol->objid);

	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", msg, wrapup);
	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", sts, wrapup);

	return (1);

wrapup :
	return (0);	
}


GetAllTheAttributes (flag, catalog_name, mac, macroname)
int flag;
char *catalog_name;
struct attributes *mac;
char	*macroname;
{
        int     	table_num;
	char		table_type[5];
	int		props, temp_num, sts;
	struct	GRid	hdr;
	struct	sup	*sup;
	int	i, j;

	_pdm_debug ("Enter GetAllTheAttributes", 0);

	if (flag == ORIGINAL_CATALOG){
	    /* Get n_tableno for the catalog */
	    if( ! GetCatTableNo (catalog_name, &table_num, table_type))
		return(0);

	    /* Query nfmattributes table for attributes given table no. */
	    if( ! GetCatAttribs(table_num, &AttrList, &AttrSynonym, &AttrTypes,
		 &NumAttribs))
		return(0);

	    if( is_it_grpart )
			return(1);
	}

	/* 139418063. 12/may/94 - raj.	*/
	/* The actual allocated lengths of arrays StatAttribs, etc.,	*/
	/* sometimes are not the same as num_stat.			*/
	num_stat = Num_Stat;
	num_dyn  = Num_Dyn;
	/* 139418063. End.		*/

        /* Read 'pdmparameters' table to get static and dynamic 	*/
	/* templates to the macro 					*/
	if( !GetStatAndDynAttribs (catalog_name ,&num_stat,&StatAttribs,
				&StatTypes,&StatDesc,&StatUnits,
				&num_dyn, &DynAttribs, &DynAttribTypes,
				&DynAttribDesc))
		return(0); 

        Num_Stat = num_stat;
        Num_Dyn = num_dyn;
	if (flag == ORIGINAL_CATALOG){
		if (!GetMacroHeaderGivenGrid (part_located, &hdr))
			return (0);

		_pdm_debug("macroname: %s", macroname );

		/* Get macro template info of the edited macro	*/
		sts = om$send( msg = message ACmacro_defn.ACgive_upscan(
					&temp_num,
					&props,
					&sup),
			senderid = hdr.objid,
			targetid = hdr.objid,
			targetos = hdr.osnum);

		_MO_omerr_chk("GetAllTheAttributes () : ACmacro_defn.ACgive_upscan : ", sts, wrapup);

		/* Allocate for the locatable type templates	*/
		mac->loc_temp 	   = (char **) malloc (num_loc * sizeof (char *));
		mac->loc_temp_type = (char **) malloc (num_loc * sizeof (char *));
	 	mac->loc_temp_desc = (char **) malloc (num_loc * sizeof (char *));

		mac->num_loc_temp = num_loc;

		/* From the info gathered above in 'sup' get the type and description */
		/* of each locatable type from 'mac->dyn_temp_*'		      */
		for (i = 0; i < mac->num_loc_temp; i++){
			for (j = 0; j <  num_dyn; j++){
				if (!strcmp (sup[i].prompt, DynAttribs[j])){
					mac->loc_temp[i] = DynAttribs[j];
					mac->loc_temp_type[i] = DynAttribTypes[j];
					mac->loc_temp_desc[i] = DynAttribDesc[j];
					break;
				}
			}
		}
	}
	return (1);

wrapup :
	return (0);
}

NewMacroSelected ()
{
	/*  Assumed that if a new macro under the same catalog 		*/
	/*	   is selected AND					*/
	/* 1) It has only a coord sys and an ACdyn-col as templates.	*/
	/*	Set flag 'ActionUponAccept' for later use		*/
	/*	Do Nothing till user accepts or 'runs'			*/
	/*	Then delete the macro.					*/
	/*	Invoke place_macro ()					*/
	/* 2) It has other templates in addition.	      		*/
	/*	Do Nothing till user accepts or 'runs'			*/
	/*	Then delete the macro. 					*/
	/*	Invoke "Part Selection" COB. 		      		*/

	/* Get the macro name	*/
	Get_text (ModifyPartForm, TABLE, MacroRow, 2);

	/* Check If macro has a CS and ACdyn_col only or other templates */
	/* are also there 						*/
	if (!SetActionUponAccept (s_text, &nmac_hdr))
		return (0);

	return (1);	
}


SetActionUponAccept (macro_name, machdr)
char *macro_name;
struct GRid *machdr;
{
	int		edited_temp_num, props, sts;
	struct	sup	*sup;
	OMuword         classid ;

	/* Get macro header, given name */
	if (!GetMacroHeaderGivenName(macro_name, &my_env, machdr))
		return (0);

	if( is_it_grpart ) {
		_pdm_debug("Part located for modify is grpart", 0);
		ActionUponAccept = PART_SELECTION;
		return (1);
	}
		
	_pdm_debug("Part located for modify is Parametric part", 0);
	/* Get edited macro template info	*/
	sts = om$send( msg = message ACmacro_defn.ACgive_upscan(
						&edited_temp_num,
						&props,
						&sup),
       			senderid = machdr->objid,
			targetid = machdr->objid,
			targetos = machdr->osnum );

	_MO_omerr_chk("SetActionUponAccept (): ACmacro_defn.ACgive_upscan : ", sts, wrapup);

	if(edited_temp_num == 2 &&
	   sup[0].type == ref_generic && sup[1].type == macro_generic){

		/* It has only a coord sys and an ACdyn-col		      */
		/* Set flag to indicate that once FI_ACCEPT or FI_EXECUTE     */
		/* is selected, old macro is to be deleted and place_macro () */
		/* is to be initiated.					      */

		/* Check if the old macro has a Ref cs as template */

		om$get_classid( objid = temp_id[0].objid,
				osnum = temp_id[0].osnum,
				p_classid = &classid );

		if( classid != OPP_GRgencs_class_id )
			ActionUponAccept = PART_SELECTION;
		else
			ActionUponAccept = PLACE_MACRO;
		return(1);
	}
	else {	/* It has other templates in addition to CS & ACdyn_col       */
		/* Set flag to indicate that once FI_ACCEPT or FI_EXECUTE     */
		/* is picked , old macro is to be deleted and "Part Selection"*/
		/* is to be initiated.					      */
		ActionUponAccept = PART_SELECTION;
		return (1);
	}

wrapup :
	return (0);
}


Terminate ()
{
	_pdm_debug("Entering Terminate ",0);
	delete_window(ModifyPartForm,SKETCH);
	/* Erase and delete form(s) 			*/
	if( ModifyPartForm )
		FIf_erase( ModifyPartForm );
	if( explstf)
		FIf_delete(explstf);
	if( ModifyPartForm )
	        FIf_delete( ModifyPartForm );
	ModifyPartForm = NULL ;

	_pdm_debug("deleted forms", 0 );

	/* Force immediate processing */
        nd$mod_batch(request    = ND_SET,
                     req_mode   = ND_IMMEDIATE);

        nd$exec_batch();

	_pdm_debug("mod batch" , 0 );

	FreeMem(); 

	if(PDU_desrev_fp && !(ActionUponAccept == PLACE_MACRO 
				|| ActionUponAccept == PART_SELECTION))
		FIf_display(PDU_desrev_fp);

	_pdm_debug("display from form ", 0);

	return (1);
}

delete_grpart()
{
char com_str[2] ;
GRobjid tmp;
	
	tmp = NULL_OBJID;
	com_str[0] = '\0' ;
	MyFree(partinfo[0]);
	MyFree(partinfo[1]);
	PALstack_events(2,com_str,EX_OBJID,&part_located. objid);
	PALstack_events(1,"PDDlPrPt",EX_CMD_KEY,&tmp);

	return(1);
}


FreeMem()
{
int i;

	if( ! PALdonot_free ){
        	for( i = 0 ; i < omac.no_dyn_attr; i = i + 1 ) 
			MyFree(dyn_attr_val[i]);
	        MyFree(dyn_attr_val);
	}

	_pdm_debug("freeing loc_temp_val", 0 );

	if( loc_temp_val )
	{
        	for( i = 0 ; i < num_loc; i = i + 1 ) 
			MyFree(loc_temp_val[i]);
	        MyFree(loc_temp_val);
	}

	_pdm_debug("free loc_temp_val ", 0 );

	free_omac(); 

	return(1);
}


GetDynAttrValsOnForm ()
{
    int	i;

	_pdm_debug("Entered GetDynAttrVals...",0);

    /* Get the dynamic attribs values	*/
    if (omac.no_dyn_attr)
	    FreeArrayPtr(dyn_attr_val, omac.no_dyn_attr);

    _pdm_debug("No. of dynattrs = %d",omac.no_dyn_attr);

    dyn_attr_val = (char **) malloc ( omac.no_dyn_attr * sizeof (char *));
    MemCheck (dyn_attr_val);


    for (i = 0; i < omac.no_dyn_attr; i++){
	if (!Get_text (ModifyPartForm, DYN_NAMES, i+num_loc, 2)){
		dyn_attr_val[i] = (char *) malloc (2 * sizeof (char));	
		dyn_attr_val[i][0] = '\0' ;
	}
	else {
		dyn_attr_val[i] = (char *) malloc ((strlen (s_text) + 1) * sizeof (char));
                MemCheck (dyn_attr_val[i]);
		_pdm_debug("s_text: %s", s_text);
                strcpy (dyn_attr_val[i], s_text);
		_pdm_debug("dynattrval=%s",dyn_attr_val[i]);
	}
    }

    return (1);

}
	
GetCatAttrCriteriaAndFormat (temp_val, selci_tempid, num_exp_objs, my_env)
char			***temp_val;
int			*num_exp_objs;
struct	GRmd_env	*my_env;
struct  GRid 		selci_tempid[];
{
	int	i;
	char    oper[128], tmpstr[20] ;
	/* Get the criteria keyed in for catalog attributes	*/
	*temp_val = (char **) malloc ( NumAttribs * sizeof (char *));
	MemCheck (*temp_val);
	for (i = 0; i < NumAttribs ; i++){
		if (!Get_text (ModifyPartForm, TABLE, i, SEARCH_COL)){
                        (*temp_val)[i] = (char *) malloc ((strlen ("=,0") + 1) * sizeof (char));
                        MemCheck ((*temp_val)[i]);
                        strcpy ((*temp_val)[i], "=,0");
		}
		else {
			
                        (*temp_val)[i] = (char *) malloc ((strlen (s_text) + 15) * sizeof (char));
                        MemCheck ((*temp_val)[i]);
                        strcpy ((*temp_val)[i], s_text);
			if( !Get_text(ModifyPartForm,TABLE,i,OPER_COL))
				strcpy(oper,"=");
			else{
				strcpy(oper,s_text);
				define_Aoperator(oper, tmpstr);
			}
			strcat(oper,",");
			strcat(oper,(*temp_val)[i]);
			strcpy((*temp_val)[i],oper);
			
		}
        }

	/* Change criteria to index format */
        change_text_to_index(NumAttribs, *temp_val, selci_tempid, num_exp_objs, my_env);

	return (1);
}

GetChildNumber (child_no, acdyn_col_obj)		
char		**child_no;
struct	GRid	*acdyn_col_obj;
{		
	int	alsize;
	
	_pdm_debug("GetChildNumber..",0);

	/* Instance a new criteria driven ACdyn_col object	*/
	/* Get serial_no before the macro is deleted	*/
	*child_no = (char *) malloc ((alsize = 32) * sizeof (char));
	(*child_no)[0] = '\0';
	GetACrgAttribVal(acdyn_col_obj, "serial_no", child_no, &alsize);
	(*child_no)[strlen(*child_no)-1] = '\0' ;

	return (1);
}

CreateTemplatesToACdyncol (num_temps, exp_list, num_exp_objs, temp_val, sel_grid, lenv )
int		*num_temps;
struct GRid 	**exp_list;
int		num_exp_objs;
char		**temp_val;

struct GRid 	*sel_grid;
struct GRmd_env *lenv;
{
	/* This routine creates templates to the criteria driven ACdyn_col */

	int	i, j, psize, sts ;

	/* Create expressions corresponding to the catalog	   */
	/* attribs criteria, dynamic attribs values, 'selection'   */
	/* template and the final list of dyn attribs and channums */

	psize = NumAttribs + num_exp_objs + 3 ;
	*exp_list = (struct GRid *)malloc( sizeof( struct GRid) * psize );
	MemCheck (*exp_list);

	*num_temps = 0;

	/* First create one exp object for criteria of each 	*/
	/* catalog attribute of catalog ( to be made template	*/
	/* to ACdyn_col ).					*/

	for( i = 0 ; i < NumAttribs ; ++i ) {
		(*exp_list)[(*num_temps)].osnum = lenv -> md_id.osnum ;
		create_expression("", temp_val[i], &(*exp_list)[(*num_temps)++], 2);
	}

	/* add each individual expression object to template 	*/
	/* list of ACdyn_col					*/
        for( i = 0 ; i < num_exp_objs ; i = i + 1 )
	        sel_grid[i].osnum = lenv->md_id.osnum ;
	for( j=0; j < num_exp_objs  ; ++j )
		(*exp_list)[(*num_temps)++] = sel_grid[j];

	if( num_coll == 1 )
	{
	        /* Create expressions for each dynamic attribute and also    */
        	/* create the string of attribs and channums                 */
		if( !CreateDynTemps( *num_temps, exp_list, num_temps ))
		{
			sts = 0;
			goto wrapup;
		}
	}

	sts = 1 ;

wrapup:
	if(!sts)
		MyFree(*exp_list);
	FreeArrayPtr(temp_val, NumAttribs);
	return (sts);

}

GetACdyncolExpTempls(dyncolid,cnt,list)
struct GRid *dyncolid;
int *cnt ;
struct GRid **list ;
{
	/* Get the no of templates to the ACdyn_col object	*/
	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT,NULL,
					 0, NULL, 0, OM_K_MAXINT, cnt	),
				targetid = dyncolid -> objid,
				senderid = dyncolid -> objid,
				targetos = dyncolid -> osnum );

    	_MO_omerr_chk("NDnode:NDgetobjects:getacdyncolexp.. () : ",sts,wrapup);

	_pdm_debug ("No of Templates to ACDynCol %d", *cnt);

	if( list == NULL )
		return( 1 );

	/* Get the grids of all the templates	*/
	(*list) = (struct GRid *)malloc(sizeof(struct GRid ) * (*cnt) );

	sts = om$send( msg =message NDnode.NDget_objects(ND_ROOT,(*list),
					 (*cnt), NULL, 0, OM_K_MAXINT, cnt),
				targetid = dyncolid -> objid,
				senderid = dyncolid -> objid,
				targetos = dyncolid -> osnum );

    	_MO_omerr_chk("NDnode:NDgetobjects:getacdyncolexp.. () : ",sts,wrapup);

	_pdm_debug("got the list of templates= %d",*cnt);

	return(1);
wrapup:
	return(0);
}


ExtractDynamicAttributes ( acdyncol, acdyncol_attribs, no_acdyncol_attribs)
struct GRid		*acdyncol;
struct ACrg_coll 	acdyncol_attribs[];
int  			no_acdyncol_attribs;
{
	/* This routine retrieves the dynamic attribute information 	*/

	int	i, j, cnt, cnt1;
	struct GRid *list;
	char *ptr ;

	char **ldyn_attr = NULL, **ldyn_attr_desc = NULL;
	int  *ldyn_attr_type = NULL;

	int  no_dyn_attr = 0;
	int  numdesc;
	char *attr_desc;
	char formula[128], tempstr[50], value[128];

	_pdm_debug ("Enter ExtractDynamicAttributes", 0);

	if( !GetACdyncolExpTempls(acdyncol,&cnt,&list))
		return(0);

	if( num_coll > 1 )
	{
		if( !GetACdyncolExpTempls(&ACdyn_col_obj,&cnt1,NULL))
			return(0);

		if( cnt1 == 0 )
			SelCiMacFlag = FALSE;
		else
			SelCiMacFlag = TRUE;
	}

	/* FIRST get the last template's value and see how many descript-exps
           are present
	*/
	sts = om$send ( msg = message NDnode.NDgive_structure(&msg,
						&ret_st,&my_env),
					targetid = list[cnt-1].objid ,
					senderid = list[cnt-1].objid ,
					targetos = list[cnt-1].osnum );

	_MO_omerr_chk(":NDgive_structure:ExtractDyn",sts,cleanup);
     	_MO_emerr_chk(":NDgive_structure:ExtractDyn",msg,cleanup);

	sscanf(ret_st.var.text_st.text_string,"%d",&numdesc);

	if( num_coll == 1 )
	{
		sts = om$send ( msg = message NDnode.NDgive_structure(&msg,
						&ret_st,&my_env),
					targetid = list[cnt-numdesc-2].objid ,
					senderid = list[cnt-numdesc-2].objid ,
					targetos = list[cnt-numdesc-2].osnum );

		_MO_omerr_chk(":NDgive_structure:ExtractDyn",sts,cleanup);
     		_MO_emerr_chk(":NDgive_structure:ExtractDyn",msg,cleanup);

		if( ret_st.type == text_type )
			if( ! strcmp(ret_st.var.text_st.text_string,"selection") )
				SelCiMacFlag = TRUE;
			else
				SelCiMacFlag = FALSE;

		_pdm_debug("Selcimac = %d",SelCiMacFlag);
	}

	attr_desc = (char *)malloc( numdesc * 85 );
	attr_desc[0] = '\0' ;
	for(i = 0; i < numdesc; i++ ) {
		sts = om$send ( msg = message NDnode.NDgive_structure(&msg,
					&ret_st,&my_env),
				targetid = list[cnt-numdesc-1+i].objid ,
				senderid = list[cnt-numdesc-1+i].objid ,
				targetos = list[cnt-numdesc-1+i].osnum );

    	_MO_omerr_chk("NDnode:NDgive_structure:ExtractDyn..:", sts,  cleanup);
    	_MO_emerr_chk("NDnode:NDgive_structure:ExtractDyn..:", msg,  cleanup);

		strcat(attr_desc,ret_st.var.text_st.text_string);
	}

	_pdm_debug("Got the attr_desc as: %s",attr_desc ); 

	no_dyn_attr = 0;

	ldyn_attr  = (char **) malloc (sizeof(char *));
	MemCheck (ldyn_attr);

	ldyn_attr_desc 	= (char **) malloc (sizeof(char *));
	MemCheck (ldyn_attr_desc);

	ldyn_attr_type 	= (int *) malloc (sizeof (int));
	MemCheck (ldyn_attr_type);

	dyn_attr_ndx = (int *) malloc (sizeof (int));
	MemCheck (dyn_attr_ndx);

	dyn_attr_val = (char **) malloc (sizeof (char *));
	MemCheck (dyn_attr_val);

	/* Parse the last template for the list of dynamic attributes 	*/
	/* and channel numbers						*/

	ptr = strtok(attr_desc,",");

	_pdm_debug("ptr = %s",ptr);

	while( ptr != NULL ){
	
		ldyn_attr = (char **) realloc (ldyn_attr, (no_dyn_attr+1) * sizeof(char *));
		MemCheck(ldyn_attr);

		ldyn_attr[no_dyn_attr] = (char *) malloc (strlen(ptr) + 1);
		MemCheck (ldyn_attr[no_dyn_attr]);

		strcpy (ldyn_attr[no_dyn_attr],ptr);

		_pdm_debug("dynattr[] = %s", ldyn_attr[no_dyn_attr]);

		/* GBTYL : use this to store the dyns passed from PDU */
		for( i = 0 ; i < no_acdyncol_attribs ; ++i )
			if( !strcmp(ptr, acdyncol_attribs[i].name)) break;

		if( i == no_acdyncol_attribs )
		{
			int	ii;
			_pdm_debug("problem matching acdyncol attrib\n",0);
			_pdm_debug("Freeing local arrays", 0);
			for (ii = 0; ii <= no_dyn_attr; ii++)
			{
                          free ((char *) ldyn_attr[ii]);
                        }
                        free ((char *) ldyn_attr);
                        ldyn_attr = NULL;

			if (ldyn_attr_type)
			{
			  free ((char *) ldyn_attr_type);
			  ldyn_attr_type = NULL;                        
                        }

                        for (ii = 0; ii < no_dyn_attr; ii++)
                        {
                          free ((char *) ldyn_attr_desc[ii]);
                        }
                        
                        if (ldyn_attr_desc)
                        {
                          free ((char *) ldyn_attr_desc);
                          ldyn_attr_desc = NULL;
                        }
                        
                        _pdm_debug ("Freed local arrays", 0);

			return(0);
		}

		ldyn_attr_type = (int *) realloc (ldyn_attr_type, (no_dyn_attr+1) * sizeof(int));
		MemCheck(ldyn_attr_type);

		ldyn_attr_type[no_dyn_attr] = acdyncol_attribs[i].desc.type;

		_pdm_debug("dynattrtype=%d", ldyn_attr_type[no_dyn_attr]);

		ldyn_attr_desc = (char **) realloc (ldyn_attr_desc, (no_dyn_attr+1) * sizeof(char *));
		MemCheck(ldyn_attr_desc);

		for (j = 0; j < num_dyn ; j++)
		{
			strcpy( tempstr, DynAttribs[j] );
			if (!strcmp (ptr, to_lower( tempstr)))
			{
			_pdm_debug("omac.dyntemp = %s",DynAttribs[j]);
			_pdm_debug("omac.dyntempdesc = %s",DynAttribDesc[j]);

				ldyn_attr_desc[no_dyn_attr] = (char *) malloc(
						strlen (DynAttribDesc[j]) + 1);
				MemCheck (ldyn_attr_desc[no_dyn_attr]);

				strcpy (ldyn_attr_desc[no_dyn_attr],DynAttribDesc[j]);

				_pdm_debug("dynattrdesc=%s",ldyn_attr_desc[no_dyn_attr]);
				break;
			}
		}
		if (j ==  num_dyn){

			ldyn_attr_desc[no_dyn_attr]=(char *) malloc ( 2 * sizeof (char));
			MemCheck (ldyn_attr_desc[no_dyn_attr]);

			ldyn_attr_desc[no_dyn_attr][0] = '\0';
		}

		ptr = strtok(NULL,",");  	/* for channel description */

		/* Store this channel num for later use in 'ProcessData ()' */
		dyn_attr_ndx= (int *)realloc(dyn_attr_ndx,(no_dyn_attr+1)*sizeof(int));
		MemCheck (dyn_attr_ndx);

		dyn_attr_ndx[no_dyn_attr] = atoi (ptr);

		_pdm_debug("attrib slot ind %d", dyn_attr_ndx[no_dyn_attr]);

		sts = om$send ( msg = message expression.give_formula(formula),
					targetid = list[dyn_attr_ndx[no_dyn_attr]].objid,
					senderid = list[dyn_attr_ndx[no_dyn_attr]].objid,
					targetos = list[dyn_attr_ndx[no_dyn_attr]].osnum);

	     	_MO_omerr_chk("NDnode:NDgive_structure:ExtractDyn..:",  sts,  cleanup);
	    	_MO_emerr_chk("NDnode:NDgive_structure:ExtractDyn..:", msg,  cleanup);

		_pdm_debug ("Formula: <%s>\n", formula);
		
		remove_quotes(formula); 

		dyn_attr_val = (char **)realloc( dyn_attr_val, (no_dyn_attr+1)*sizeof(char *));
		MemCheck(dyn_attr_val);

		if( ldyn_attr_type[no_dyn_attr] == AC_ATTRIB_DOUBLE ){
	   		dyn_attr_val[no_dyn_attr] = (char *) malloc (80 * sizeof (char));
	   		MemCheck (dyn_attr_val[no_dyn_attr]);
			/*
			 * 07/Nov/93 - raj. 'formula' in format '=1 [1]'.
			 * Get the value between "[" and "]".
			 */
			if (!get_val_from_formula(formula, value))
				goto cleanup;
			sscanf(value,"%s",dyn_attr_val[no_dyn_attr]);
		}
		else{
			dyn_attr_val[no_dyn_attr] = (char *) malloc (strlen(formula) + 1);
	   		MemCheck (dyn_attr_val[no_dyn_attr]);
			strcpy(dyn_attr_val[no_dyn_attr],formula);
		}

		_pdm_debug("dyn attr val: %s", dyn_attr_val[no_dyn_attr] );

		no_dyn_attr++;

		ptr = strtok(NULL,",");  	/* for next attribute      */
	}

	_pdm_debug ("No Of Dynamic Attribs %d", no_dyn_attr);

	omac.no_dyn_attr = no_dyn_attr;
	omac.dyn_attr = ldyn_attr;
	omac.dyn_attr_desc = ldyn_attr_desc;
	omac.dyn_attr_type = ldyn_attr_type;

	for(i=0;i<omac.no_dyn_attr;i++)
	{
		_pdm_debug("dynattr=%s",omac.dyn_attr[i]);
		_pdm_debug("dynattrdesc=%s",omac.dyn_attr_desc[i]);
		_pdm_debug("dynattrtype=%d",omac.dyn_attr_type[i]);
	}

	return(1);

cleanup :
  {
     int	ii;
     _pdm_debug("Freeing local arrarys", 0);
     
     if (ldyn_attr)
     {
       for (ii = 0; ii <= no_dyn_attr; ii++)
       {
         free ((char *) ldyn_attr[ii]);
       }
       free ((char *) ldyn_attr);
       ldyn_attr = NULL;
     }
     
     if (ldyn_attr_type)
     {
       free ((char *) ldyn_attr_type);
       ldyn_attr_type = NULL;                        
     }
     
     if (ldyn_attr_desc)
     {
       for (ii = 0; ii <= no_dyn_attr; ii++)
       {
         free ((char *) ldyn_attr_desc[ii]);
       }
       free ((char *) ldyn_attr_desc);
       ldyn_attr_desc = NULL;
     }

     _pdm_debug("Freed local arrarys", 0);
  }
	return (0);
}

ProcessNewCat()
{
	if( !static_flag )
		set_gadgets(ModifyPartForm);

	switch_off_gdgs(ModifyPartForm);
	FIg_enable(ModifyPartForm,PLCMNT_OPTIONS);
	FIg_display(ModifyPartForm,19);

        if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
          PDUfill_in_string(&PDU_usage_id, NULL);

	if( strcmp(ViewOrTblList[0],"P")
		&& strcmp(ViewOrTblList[0],"PXT")
		&& strcmp(ViewOrTblList[0],"CID")
		&& strcmp(ViewOrTblList[0],"EID")	)
	{
		/* Get all the attributes of the new catalog	*/
                /*FIg_set_state_on(ModifyPartForm, 19);
                PDU_replace_all_occur = FALSE;*/
		return(1);
	}
			

	if (NewCatalogSelected == TRUE){
	/* Get macro name if it's on form else from 'pdmparamloc' table */
		GetMacroName (ModifyPartForm, TABLE, 0, 2, refresh->rev_catalog, nmac_name);
	
		/* Get all the attributes of the new catalog	*/
		GetAllTheAttributes (NEW_CATALOG, refresh->rev_catalog, &nmac, nmac_name);

		/* copy and load macro libraries relevant to catalog */
		if( !copy_and_load_macro_lib(refresh -> rev_catalog))
			  return(0);
		    
		/* Call function to determine the action to be 	   */
		/* taken when user selects FI_ACCEPT or FI_EXECUTE */
		SetActionUponAccept (nmac_name, &nmac_hdr);

		if (ActionUponAccept == PLACE_MACRO){
		_pdm_debug("ActionUponAccept = PLACE_MACRO",0);
			/* MatchAttributes (&omac, &nmac); */
			return (1);
		}
		else if (ActionUponAccept == PART_SELECTION)
		{
		_pdm_debug("ActionUponAccept = PART_SELECT",0);
			return(1);
		}
	}
	return(1);
}

grpart_update()
{

	partinfo[0] = NULL ;
	partinfo[1] = NULL ;
	
	if( PDUextract_GRpart_modify_info(&part_located,&my_env,
			&refresh -> rev_catalog,&partinfo[0],
			&partinfo[1],
			&omac.dyn_attr,&(omac.dyn_attr_desc),
			&(omac.dyn_attr_type),&dyn_attr_val,&omac.no_dyn_attr)
		!= PDM_S_SUCCESS )
		return(0);


	
	if( !GetAllTheAttributes(ORIGINAL_CATALOG,refresh -> rev_catalog,&omac,nmac_name ))
		return(0);

	if(!update_cat_val(partinfo[0],partinfo[1]))
		return(0);

	omac. num_loc_temp = 0 ;

	num_temp = 1 ;
	num_loc  = 0 ;

	cat_desc = NULL;
        if (!GetCatalogDesc (refresh -> rev_catalog, &cat_desc))
		return (0);
/*
	ModifyMacro(); 
*/
	return(1);
}

processgrpart()
{

	char com_str[10] ;
	int             responses[1]	;
	char            *strings[1];		
	GRobjid		tmp=NULL_OBJID;

		/* call Jamal's place part here */
	if( ! is_it_grpart )
                {
                /* use API instead to prevent looping with EMS */
                /*delete_prpart (&part_located, &my_env);*/
                pdmoDeletePartOccurrence(&msg, NULL, &part_located);
                }
	else {

		if( !NewCatalogSelected && !strcmp(partinfo[0],refresh -> rev_partid) &&
		    !strcmp(partinfo[1],refresh -> rev_revision) ){

			MyFree(partinfo[0]);
			MyFree(partinfo[1]);

			/* Only dynamic parameters are edited. Call Jamals
			   edit part here
			*/
			_pdm_debug("Calling Edit GRpart",0);
			
			/* 09/Sep/94 - raj. TR# 139418616. Do not display
			   Design Operations form in delete() of this PPL. */
			PDU_desrev_fp = NULL;
			
			GetDynAttrValsOnForm ();
                        PDU_command = PDC_M_EDIT_PART;
			com_str[0] = '\0' ;
		        PALstack_events(2,com_str,EX_OBJID,&part_located. objid);
			PALstack_events(1,"PDEdPr",EX_CMD_KEY,&tmp);

			PALdonot_free = TRUE ;
			return(1);
		}
		else {
                      _pdm_debug("Calling Replace  GRpart", 0);

		      /* 09/Sep/94 - raj. TR# 139418616. Do not display
			 Design Operations form in delete() of this PPL. */
                      PDU_desrev_fp = NULL;

                      PALstack_events(2,com_str,EX_OBJID,&part_located. objid);
                      PALstack_events(1,"PDRpPr",EX_CMD_KEY,&tmp);

                      return(1);
		}
	}

	_pdm_debug("Calling Place GRpart",0);
	PDU_command = PDC_M_PLACE_PART;
	responses[0] = EX_CMD_KEY;
	strings[0] = "PDPPr";

	PDU_desrev_fp = NULL;
		
	PDUprepare_queue(responses,strings,1);
	return(1);
}


memset_mac( mac )
struct attributes *mac;
{
	mac->dyn_attr = NULL;
	mac->dyn_attr_desc = NULL;
	mac->dyn_attr_type = NULL;
	mac->no_dyn_attr = 0;

	mac->loc_temp = NULL;
	mac->loc_temp_type = NULL;
	mac->loc_temp_desc = NULL;
	mac->num_loc_temp = 0;

	return(1);
}

free_omac()
{
	
	if( is_it_grpart )
		return( 1 );

	MyFree( omac.loc_temp );
	MyFree( omac.loc_temp_type );
	MyFree( omac.loc_temp_desc );

	if( omac . no_dyn_attr ) {
		FreeArrayPtr(omac . dyn_attr, omac.no_dyn_attr );
		FreeArrayPtr(omac . dyn_attr_desc, omac . no_dyn_attr );
		MyFree(  omac . dyn_attr_type );

		omac . no_dyn_attr = 0 ;
	}

	return(1);
}

update_dynnames()
{
int i,j;

	set_dynnames();

        for (i = 0; i < num_loc; i++)
		FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 2, loc_temp_val[i], 1);

	if( !is_it_grpart )
	{
		set_stddyn_attrval( &i, NO_STD_DYN_ATTRS );

   		for( j=i-num_loc ; j < omac.no_dyn_attr ; j++,i++){
			_pdm_debug("Jamal returns: %s", dyn_attr_val[j]);
			if( strlen(dyn_attr_val[j]) > 0 )
			FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 2, dyn_attr_val[j], 0);
			else
			FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 2,"", 0);
		}
		PALretrieve_dyn_info(refresh->rev_catalog,refresh -> rev_partid, refresh -> rev_revision);
	}
	else
	{
		set_stddyn_attrval( &i, omac.no_dyn_attr );
		PALretrieve_dyn_info(refresh->rev_catalog,partinfo[0], partinfo[1]);
	}

	PALset_attribute_type(omac.no_dyn_attr,omac.dyn_attr,omac.dyn_attr_desc,
			dyn_star_type, ModifyPartForm, DYN_NAMES, num_loc);

   	_pdm_debug ("Set DYNAMIC templates of the part located", 0);

	return(1);

}

set_dynnames()
{
int i,j;

        /* Set LOCATABLE templates of the part located  */
        for (i = 0; i < num_loc ; i++){
		FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 0, omac.loc_temp[i], 1);
		FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 1, omac.loc_temp_desc[i], 1);		
        }

        _pdm_debug ("Set LOCATABLE templates of the part located", 0);

   	/* Set DYNAMIC templates of the part located	*/
   	for( j=0 ; j < omac.no_dyn_attr ; j++,i++){
        	FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 0, omac.dyn_attr[j], 1);
       	        FIfld_set_text(ModifyPartForm, DYN_NAMES, i, 1, omac.dyn_attr_desc[j], 1);

   	}
   	/* Set dyn parameters name row in single select mode */
   	for( i = 0 ; i < 2 ; i = i + 1 )
      		FIfld_set_mode(ModifyPartForm, DYN_NAMES, i, FI_SINGLE_SELECT);

	return(1);
}


set_stddyn_attrval( i, end_attr )
int *i, end_attr;
{
int j;

/* The array dyn_attr_val contains all the standard dyn attrs in the beginning */

   	for( j=0 ; j < end_attr ; j++,(*i)++){
		_pdm_debug("Jamal returns: %s", dyn_attr_val[j]);
		if( strlen(dyn_attr_val[j]) > 0 )
			FIfld_set_text(ModifyPartForm, DYN_NAMES, *i, 2, dyn_attr_val[j], 0);
		else
			FIfld_set_text(ModifyPartForm, DYN_NAMES, *i, 2,"", 0);
	}
	return(1);
}

CheckACrgAttribVal(acdyn_col, attribname, val)
struct GRid *acdyn_col;
char *attribname, **val;
{
struct ACrg_coll attrib;
int sts;
long msg;

	strcpy( attrib.name, attribname);

	sts = om$send( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attrib ),
				senderid = acdyn_col->objid,
				targetid = acdyn_col->objid,
				targetos = acdyn_col->osnum );

		if( msg & 1 ) /* If this attribute is found in the coll */
		{
			if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_TEXT )
			{
				*val=(char *)malloc(strlen(attrib.desc.value.att_txt)+1);
				strcpy(*val,attrib.desc.value.att_txt);	
			}
			else if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_DOUBLE )
			{
				*val=(char *)malloc(20);
				sprintf(*val,"%lf", attrib.desc.value.att_exp);
			}
			else
				goto wrapup;
		}
		else
			goto wrapup;

	_pdm_debug("attribute %s found in collection",attribname);	
	_pdm_debug("attribute's value found in collection = %s",*val);	
	return(1);
wrapup:
	_pdm_debug("attribute %s not found in collection",attribname);
	return(0);
}

get_parameter_values( part_grid, params, num, param_vals)
struct GRid *part_grid; /* I */
char **params;          /* I */
int  num;               /* I */
char ***param_vals;     /* O */
{
long msg;
int sts, numcoll;
int i = 0, j, flg = 1;
struct GRid  *coll;
struct ACrg_coll attrib;

	_pdm_debug("part objid = %d", part_grid->objid );
	_pdm_debug("part osnum = %d", part_grid->osnum );
	_pdm_debug("num = %d", num );

	if( !GetCollsList ( part_grid, &coll, &numcoll ))
		return(0);

	*param_vals = (char **)malloc( num * sizeof(char *));

	/* Now find the values of each of the attributes */
	for ( i = 0; i < num; i++ )
	{
		strcpy( attrib.name, params[i]);

		for( j = 0; j < numcoll; j++ )
		{
			_pdm_debug("coll objid = %d", coll[j].objid);

			sts = om$send( msg = message ACrg_collect.ACget_named_attribute
							( &msg, &attrib ),
					  senderid = coll[j].objid,
				  	  targetid = coll[j].objid,
			  		  targetos = coll[j].osnum );
	
		        if(msg & 1)
				break;
		}

		if( j == numcoll ) /* Not Found in any collection */
		{
			_pdm_debug("Attr %s not found in any coll",params[i]);
			flg = 0;
			goto wrapup;
		}

		/* Allocate memory to the output vals array */
		(*param_vals)[i] = (char *)malloc(80);

		if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_TEXT )
			strcpy( (*param_vals)[i],attrib.desc.value.att_txt);	
		else
			if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_DOUBLE )
				sprintf((*param_vals)[i],"%lf", attrib.desc.value.att_exp);
	}

wrapup:
	MyFree(coll);
	if( !flg ) /* Failed */
	{
		for(j = 0; j < i; j++ )
			MyFree( (*param_vals)[j] );
		MyFree( *param_vals );
	}
	return(flg);
}

GetCollsList( part_grid, coll, numcoll )
struct GRid *part_grid, **coll;
int *numcoll;
{
struct GRid *list1 = NULL;
OM_S_CHANSELECT to_components;
OM_S_OBJECT_LINKAGE *list = NULL;
unsigned int total_count;
unsigned short classid;
int i, cnt, sts, flg = 0;
IGRshort mat_type ;
IGRmatrix tmat ; 

	*coll = (struct GRid *)malloc(sizeof(struct GRid));

	/* Get the template objs on the channel */
        sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, NULL,
                                                          0, NULL,
                                                          0, OM_K_MAXINT, &cnt),
                        targetid = part_grid->objid,
                        targetos = part_grid->osnum,
                        senderid = part_grid->objid);

        _MO_omerr_chk("NDgetobjects 1:GetCollsList(): ", sts, wrapup);

        _pdm_debug("no. of templates %d",cnt);

	if( cnt > 0 )
	{
	        /* Get the objids of all the templates of the part  */
        	list1 = (struct GRid *)malloc( cnt * sizeof( struct GRid ));

        	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, list1,
							  cnt, NULL, 0,
							  OM_K_MAXINT, &cnt),
                        	targetid = part_grid->objid,
                        	targetos = part_grid->osnum,
                        	senderid = part_grid->objid);

	        _MO_omerr_chk("NDgetobjects 2:GetCollsList(): ", sts, wrapup);
	
		total_count = cnt;
	}
	else /* If it is a ROOT part */
	{
		sts = om$make_chanselect( channame = "GRcmpowner.to_components",
			p_chanselect = &to_components );

		sts = om$get_channel_count(objid = part_grid->objid,
				   osnum = part_grid->osnum,
				   p_chanselect = &to_components,
				   count = &total_count);

		_pdm_debug("feet count = %d", total_count );

		if (!total_count)
			goto wrapup; /* No feet ??? */

        	list = (OM_S_OBJECT_LINKAGE *)
			malloc( (total_count) * sizeof(OM_S_OBJECT_LINKAGE) );

	        sts = om$get_channel_objects( objid = part_grid->objid,
				         osnum = part_grid->osnum,
                                         p_chanselect = &to_components,
                                         list = list,
                                         size = total_count,
                                         count = &total_count);

        	list1 = (struct GRid *)malloc( total_count * sizeof( struct GRid ));
		for ( i = 0; i < total_count; i++ )
		{
			list1[i].objid = list[i].S_objid;
			list1[i].osnum = list[i].osnum;
		}
	}

	*numcoll = 0;
	for ( i = 0; i < total_count; i++ )
	{
		/* Might be a pretend, get the original.	*/
		sts = om$send(msg = message NDnode.ASreturn_go(&list1[i],
							&mat_type, 
							tmat),
						senderid = list1[i].objid,
						targetid = list1[i].objid,
						targetos = list1[i].osnum);

		om$get_classid( objid = list1[i].objid,
				osnum = list1[i].osnum,
				p_classid = &classid );

		if( classid == OPP_ACdyn_col_class_id )
		{
			(*numcoll)++;
			if( *numcoll > 1 )
				*coll = (struct GRid *)realloc(*coll, *numcoll * sizeof( struct GRid ));
			(*coll)[*numcoll-1].objid = list1[i].objid;
			(*coll)[*numcoll-1].osnum = list1[i].osnum;
		}
	}
	_pdm_debug("no. of collection objects = %d", *numcoll);

	if( *numcoll == 0 ) /* No Collections in the foot list ??? */
		goto wrapup;

	flg = 1;
wrapup:
	MyFree(list);
	MyFree(list1);
	if( !flg ) MyFree( *coll );

	return(flg);
}

CreateDynTemps( in_count, list, out_count )
struct GRid **list;
int in_count, *out_count;
{
int exptype, j, noexps, temp;
char 	tmp[8], *dynattr_channum_str;
char temp_desc[EXP_MAX_LEN+1] ;
struct GRid expid  ;

	if( in_count )
		*list = (struct GRid *)realloc( *list, sizeof( struct GRid)*
						(omac.no_dyn_attr + in_count + 3));
	else
		*list = (struct GRid *)malloc( sizeof( struct GRid)*(omac.no_dyn_attr+3));
	MemCheck (*list);

        /* Create expressions for each dynamic attribute and also    */
       	/* create the string of attribs and channums                 */

	dynattr_channum_str = (char *)malloc(omac.no_dyn_attr*35 );
       	dynattr_channum_str[0] = '\0';

	*out_count = in_count;
	for( j = 0 ; j < omac.no_dyn_attr ; ++j ) 
	{
		if( omac.dyn_attr_type[j] == AC_ATTRIB_TEXT )
			exptype = 2 ;
		else
			exptype = 1 ;
		if( (exptype == 1) && strlen(dyn_attr_val[j]) < 1 )
			continue;
		(*list)[(*out_count)].osnum = my_env.md_id.osnum ;
		if( !create_expression("", dyn_attr_val[j], &(*list)[(*out_count)], 
					exptype))
		{
			sts = 0 ;
			goto cleanup;
		}
		strcat (dynattr_channum_str, omac.dyn_attr[j]);
		strcat (dynattr_channum_str, ",");
		sprintf (tmp, "%d", (*out_count)++);
		strcat (dynattr_channum_str, tmp);
		strcat (dynattr_channum_str, ",");
	}

	if( in_count )  /* Selection criteria present */
	{
		(*list)[*out_count].osnum = my_env.md_id.osnum ;
		if( !create_expression("", "selection",&(*list)[(*out_count)++], 2))
		{
			sts = 0 ;
			goto cleanup;
		}
	}

	temp = strlen( dynattr_channum_str ) % EXP_MAX_LEN;

	if( temp )
		noexps = strlen( dynattr_channum_str ) / EXP_MAX_LEN + 1 ;
	else
		noexps = strlen( dynattr_channum_str ) / EXP_MAX_LEN ;

	if( noexps > 1 ) 
	{
		*list = (struct GRid *)realloc(*list, 
					sizeof(struct GRid ) * ((*out_count)+noexps+1));

		MemCheck( *list );
	}

	for( j = 0 ; j < noexps ; ++j ) 
	{
		if( strlen (&dynattr_channum_str[j*EXP_MAX_LEN]) > EXP_MAX_LEN )
			mystrncpy(temp_desc,&dynattr_channum_str[j*EXP_MAX_LEN],
								EXP_MAX_LEN);
		else 
			strcpy(temp_desc,&dynattr_channum_str[j*EXP_MAX_LEN]);
		_pdm_debug("temp_desc as split: %s", temp_desc );

		expid.osnum = my_env.md_id.osnum ;
		if(!create_expression("",temp_desc,&expid,2))
		{
			free( dynattr_channum_str );			
			return(0);
		}

		(*list)[ j + (*out_count)++] = expid ;
	}

	free( dynattr_channum_str );

	expid.osnum = my_env.md_id.osnum ;

	temp_desc[0] = '\0' ;
	sprintf(temp_desc,"%d", noexps );

	if(!create_expression("",temp_desc,&expid,2))
		return(0);
	(*list)[(*out_count)++] = expid ;

	sts = 1;

cleanup:
	return(sts);
}

remove_dynatr( instr, str, pos )
char **instr, *str;
int *pos;
{
char *ptr, *ptr1;
int i=0,j;
char *tmpstr;

  ptr = strpbrk( *instr, str);

  if ( ptr )
  {
     tmpstr = (char *)malloc(strlen(*instr) + 1 );
     ptr1 = *instr;
     j = 0;
     while ( ptr1 != ptr )
     {
       if( *ptr1 == '~' ) i++;
       tmpstr[j++] = *ptr1++;
     }
     tmpstr[j] = '\0';
     ptr1 += strlen(str) + 1;
     strcat(tmpstr,ptr1);
     *instr = tmpstr;
     *pos = i;
   }
   else *pos = -1;

   return( 1 );
}

remove_dynval( instr, pos )
char **instr;
int pos;
{
int i;
char *ptr, *tmpstr;
 
   if( pos == -1 ) return(0);
   tmpstr = ( char * ) malloc( strlen(*instr) + 1 );
   ptr = *instr;
   tmpstr[0] = '\0';
   if ( pos == 0 )
   {
      while( *ptr && *ptr++ != '~' );
      strcpy( tmpstr, ptr);
      *instr = tmpstr;
      return(1);
   }
   i = 0;
   while( *ptr++ )
   {
      if( *ptr == '~' )
      {
         i++;
         if ( i == pos )
           break;
      }
   }
   strncpy( tmpstr, *instr, ptr - *instr); 
   while( *ptr && *(++ptr) != '~' );
   if( !*ptr )
      strcat( tmpstr, "~");
   else
      strcat( tmpstr, ptr);
   *instr = tmpstr;

   return(1);
}

/*
 * This function extracts the string between '[' and ']' from formula of format '=1 [1]'.
 * 19/Nov/93 - raj. There's a new twist in EMS 03.00.00.17.
 * Sometimes the formula is in '=1' format, with NO square brackets.
 * Modified function accordingly.
 */
get_val_from_formula(char *formula, char value[])
{
	int	ii, jj, len = strlen(formula);
	_pdm_debug("formula: <%s>\n", formula);
	for (ii = 0; ii < len; ii++)
          if (formula[ii] == '[')
          	break;

        if (ii == len)
        {
          	strcpy (value, "");
          	_pdm_debug("get_val_from_formula() : formula not in '=1 [1]' correct format", 0);
		/* 19/Nov/93 - raj.	*/
		/* '[' not found. So formula is in '=1' format.	*/
		/* Get the value after the '='.			*/
		for (ii = 0; ii < len; ii++)
	          if (formula[ii] == '=')
        	  	break;
	        if (ii == len)
	        {
	          	strcpy (value, "");
	          	_pdm_debug("get_val_from_formula() : formula not in '=1' format, either. Wrong format.", 0);
	        	return (0);
		}

  	        strcpy (value, &formula[ii+1]);
        	return (1);
	}

	/* Look for a blank.	*/
	for (jj = ii + 1; jj < len; jj++)
          if (formula[jj] == ' ')
            break;
	
	if (jj < len)
	{
          /* Found a space. */
          strcpy (value, &formula[jj+1]);	/* format : '=1 [some, 1]' */
        }
        else
        {
          /* No space found.	*/
          strcpy (value, &formula[ii+1]);
        }
	
	len = strlen(value);
	for (ii = 0; ii < len; ii++)
          if (value[ii] == ']')
          {
            value[ii] = '\0';
            _pdm_debug("value: <%s>\n", value);
            return (1);
          }
        
	/* Close square bracket not found.	*/
        strcpy (value, "");
        _pdm_debug("get_val_from_formula() : closing bracket not found", 0);
        return (0);
}

/* 17/Dec/93 - raj.	TR # 13931 1475.	*/
/* Function to check if a new macro has been selected and set ActionUponAccept falg.	*/
IsDfntMacroSelected()
{
	char	*output_str, *ptr, query[256];
	int	ii, maxrows = 1;
	char	macro_name[32];
	strcpy(macro_name, "");
	
	_pdm_debug("Entered IsDfntMacroSelected()", 0);
	query[0] = '\0';
	
	  /* If p_macro attribute has a value on the form.	*/  	
	  if (Get_text (ModifyPartForm, TABLE, MacroRow, 2))
	  {
	    /* If original macro name differs from current one.		*/
	    /* NOTE : 'cat_attr_val' holds initial values of attributes */
/* 20/apr/94 - raj. macro name might be NULL in that case do not call NewMacroSelected(). */
/*	    if (strcmp (cat_attr_val[MacroRow], s_text))	*/
	    if (strcmp(cat_attr_val[MacroRow], "") && strcmp (cat_attr_val[MacroRow], s_text))
	    {
               strcpy(macro_name, s_text);
	      _pdm_debug("new macro name on form: <%s>", s_text);
              NewMacroSelected ();
            }
          }
          /* p_macro attribute does not have a value selected. Get it from catalog table.	*/
          else
          {
            /* IF the catalog has STATIC attributes.	*/
	    if (num_stat != 0)
	    {
              if( ! GetUniqRecord (refresh->rev_catalog, 
			     refresh->rev_partid, 
			     refresh->rev_revision, 
			     StatAttribs, num_stat, &output_str))
		return(0);
              ptr = strtok (output_str, "~");
              ii = 0;
              while(ptr != NULL )
              {
                _pdm_debug("ptr: %s", ptr );
                if (ii == MacroRow)
                {
                   strcpy(macro_name, ptr);
                  _pdm_debug("p_macro value from catalog = <%s>", ptr);

                  /* Reached p_macro value. Set it on the form so that NewMacroSelected()	*/
                  /* can pick it up from there.						*/
                  FIfld_set_text(ModifyPartForm, TABLE, MacroRow, 2, ptr, 1);

	          /* NOTE : 'cat_attr_val' holds initial values of attributes */
/* 20/apr/94 - raj. macro name might be NULL in that case do not call NewMacroSelected(). */
/*	          if (strcmp (cat_attr_val[MacroRow], ptr))	*/
	          if (strcmp(cat_attr_val[MacroRow], "") && strcmp (cat_attr_val[MacroRow], ptr))
	          {
	            _pdm_debug("new macro name from catalog with STATIC attrs: <%s>", ptr);
	            NewMacroSelected ();
                  }
                  free (output_str);
                  break;
                }
                else
                {
                  ptr = strtok(NULL, "~");
                  ii = ii + 1;
                }
              }
              free (output_str);
            }
            /* catalog has NO STATIC attributes just use the n_itemname and	*/
            /* n_itemrev to get the p_macro attribute from catalog table.	*/
            else
            {
              sprintf(query, "select p_macro from %s where n_itemname = '%s' and n_itemrev = '%s'", refresh->rev_catalog, refresh->rev_partid,  refresh->rev_revision);
              _pdm_debug("No STATIC attributes for this catalog\nquery = <%s>", query);

              /* Send RIS query */
              sts = RISquery (query, &maxrows, &output_str, &ii);	

              if (sts < 0)
              {
                free (output_str);
                fprintf (stderr, "Error In RIS Operation - %d\n", ii);
                return (0);
              }
              _pdm_debug("output: %s", output_str );

              ptr = strtok(output_str, "~");

              strcpy(macro_name, ptr);

              /* Set it on the form so that NewMacroSelected() can pick it up from there.	*/
              FIfld_set_text(ModifyPartForm, TABLE, MacroRow, 2, ptr, 1);

              /* NOTE : 'cat_attr_val' holds initial values of attributes */
/* 20/apr/94 - raj. macro name might be NULL in that case do not call NewMacroSelected(). */
/*	      if (strcmp (cat_attr_val[MacroRow], ptr))	*/
	      if (strcmp(cat_attr_val[MacroRow], "") && strcmp (cat_attr_val[MacroRow], ptr))
	      {
                _pdm_debug("new macro name from catalog without STATIC attrs: <%s>", ptr);
	        NewMacroSelected ();
              }
              free(output_str);
            }
          }

          /* It's possible that the p_macro attribute has no value.	*/
          /* So, let's get it direct from table "pdmparamloc".		*/
          if (!strcmp(macro_name, ""))
          {
              sprintf(query, "select p_macroname from pdmparamloc where n_catalogname = '%s'",
              refresh->rev_catalog);
              _pdm_debug("No value for p_macro attribute of this catalog\nquery = <%s>", query);

              /* Send RIS query */
              sts = RISquery (query, &maxrows, &output_str, &ii);	

              if (sts < 0)
              {
                free (output_str);
                fprintf (stderr, "Error In RIS Operation - %d\n", ii);
                return (0);
              }
              _pdm_debug("output: %s", output_str );

              ptr = strtok(output_str, "~");

              strcpy(macro_name, ptr);

              /* Set it on the form so that NewMacroSelected() can pick it up from there.	*/
              FIfld_set_text(ModifyPartForm, TABLE, MacroRow, 2, ptr, 1);

              /* NOTE : 'cat_attr_val' holds initial values of attributes */
/* 20/apr/94 - raj. macro name might be NULL in that case do not call NewMacroSelected(). */
/*	      if (strcmp (cat_attr_val[MacroRow], ptr))	*/
	      if (strcmp(cat_attr_val[MacroRow], "") && strcmp (cat_attr_val[MacroRow], ptr))
	      {
                _pdm_debug("new macro name from catalog without STATIC attrs: <%s>", ptr);
	        NewMacroSelected ();
              }
              free(output_str);
          }

	_pdm_debug("Exit IsDfntMacroSelected()", 0);

	return (1);
}
	
end implementation	Root;
