/***************************************************************************/
/*									   */
/*   This file contains routines which will be invoked at the time of      */
/*   placement of ACdyn_col class object, and when any of the templates    */
/*   templates of the ACdyn_col changes.				   */
/*									   */
/*	Date Created :  18/08/92		MMS  (IGI)		   */
/*	Date Modified:  05/02/93		DKK  (IGI)		   */
/*									   */
/***************************************************************************/


class implementation ACdyn_col ;

#include "AS_status.h"
#include "exmacros.h"
#include "expmacros.h"
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <sys/types.h>
#include <sys/dirent.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "madef.h"
#include "msdef.h"
#include "MOmacros.h"

#include "parametric.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "macro.h"
#include "PDUstr.h"
#include "PALglbs.h"

/* mold include files */
#include "msdef.h"
#include "msmacros.h"
#include "PALmsg.h"
#include "FI.h"
#include "CIforms.h"
#include "expression.h"
#include "PDUfile_def.h"
#include "MEMerrordef.h"
#include "PDUuser.h"


/*#include "PDUproto.h"*/

#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"

#define	EXP_DOUBLE	0
#define EXP_TEXT	4

#define	TAB_MAX_VALUES	20
#define DEBUG 1  

from ACcpx import ACfind_temp_obj;
from expression import give_formula;

extern int PDMdebug_on ;
extern struct PDUuser *user;

extern  OMuword OPP_nci_macro_class_id ;

static struct GRid Tcol;
static struct GRmd_env MOD_ENV;

/* This routine adds an attribute to an ACdyn_col class object given
	   attribute name, value and type
*/
add_attribute(dyn_grid, val,name,  attr_type)
 struct GRid *dyn_grid ;
char *name, *val ;
int attr_type ;

{
	int     	sts  ;
	IGRlong 	msg ;


	_pdm_debug("val:%s ", val );
	_pdm_debug(" name: %s ", name ) ; 

	/*** Added on 05/18/93 *******/
        if( !strcmp( val,"nil" ) && (attr_type == AC_ATTRIB_DOUBLE ))
		strcpy( val, "0.0" );
	/*** end ***/

	sts = om$send(	msg	 = message ACdyn_col.ACadd_attribute_by_type
					( &msg, attr_type, name, val ),
			targetid = dyn_grid -> objid,
			senderid = dyn_grid -> objid,
			targetos = dyn_grid -> osnum );

//       	_MO_omerr_chk("ACadd_attribute", sts, wrapup);
//        _MO_emerr_chk("ACadd_attribute", msg, wrapup);


	if( !(msg&1) ) /* attribute exists */
	{
		sts = mod_attribute(dyn_grid,name,val, attr_type);
	        _MO_omerr_chk("ACrg_collect.ACmod_attribute ", sts, wrapup);
	}



	return(1);
wrapup:
	return(0);

}
/* This routine modifies an existing attribute in an ACdyn_col class object
   given attribute name, value and type
*/
mod_attribute(dyn_grid, name, val, attr_type )
struct GRid *dyn_grid ;
char *name, *val ;
int attr_type ;
{
	int     	sts  ;
	IGRlong 	msg ;
	struct ACrg_coll mycol ;

	
	_pdm_debug("mod_attribute: attrib: %s", name );
	_pdm_debug("val: %s", val);

	strcpy(mycol.name,name);
	mycol.desc.type = attr_type ;

	if( attr_type == AC_ATTRIB_DOUBLE )
		sscanf(val,"%lf", &(mycol.desc.value.att_exp));
	else
		strcpy(mycol.desc.value.att_txt,val);

		
	sts = om$send(	msg	 = message ACrg_collect.ACmod_list_attribute
					( &msg, 1, &mycol ),
			targetid = dyn_grid -> objid,
			senderid = dyn_grid -> objid,
			targetos = dyn_grid -> osnum );
	
        _MO_emerr_chk("ACrg_collect.ACmod_attribute ", msg, wrapup);
        _MO_omerr_chk("ACrg_collect.ACmod_attribute ", sts, wrapup);

		return(sts);
wrapup:
		return(sts);
}

normal_cmpt( rc, dcol, attr, md_env,nb_par,list_temp,state,context )

IGRlong			*rc;
struct	GRid		dcol;
struct	ACrg_coll	*attr;
struct	GRmd_env	*md_env;
struct	GRid		*list_temp;
IGRint			nb_par ;
IGRint			*state;
struct GRid		*context ;
{
IGRlong			sts, msg;
struct	ret_struct	*temp_rts;
IGRint			i,indx, no_of_exps  ;
char 			*ptr, attr_name[10], attr_val[10], *attr_desc ;

	_pdm_debug("entering compute", 0);

/* Added this to avoid recompute if the attributes are not modified - KK */
	for( i = 0; i < nb_par; i++ )
		if( state[i] != ND_COMP_SAME )
			break;
	/* None of the parents is changed */
	if( i == nb_par ) 
		return(OM_S_SUCCESS);
/*end of addition */

	/*| initialization */
	*rc		= MSSUCC;


	temp_rts = (struct ret_struct *)malloc( nb_par * sizeof( struct ret_struct));

	for( i = 0 ; i < nb_par ; i = i + 1 ) {
		sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&temp_rts[i],
					md_env ),
			targetid = list_temp[i].objid,
			senderid = list_temp[i].objid,
			targetos = list_temp[i].osnum );

	       	_MO_omerr_chk("NDgive_structure ", sts, wrapup);
        	_MO_emerr_chk("NDgive_structure ", msg, wrapup);

	}

	_pdm_debug("Numexps templ= %s", temp_rts[i-1].var.text_st.text_string);

	/* parse last template first */
	sscanf(temp_rts[nb_par-1].var.text_st.text_string,"%d",&no_of_exps);

	_pdm_debug("Numexps %d", no_of_exps );

	if( no_of_exps <= 0 )
	{
		free( (char *) temp_rts );
		return(0);
	}
	
	attr_desc = (char *)malloc( no_of_exps * 85 );

	attr_desc[0] = '\0' ;
	
	for( i = 0 ; i < no_of_exps ; ++i ) 

		strcat(attr_desc,temp_rts[nb_par-1 - (no_of_exps-i)].var.text_st.text_string);

	_pdm_debug("attr_desc = %s", attr_desc);


	ptr  = strtok(attr_desc,",");	

	while ( ptr != NULL ) {
		strcpy(attr_name,ptr);
	 	ptr = strtok(NULL,",");
		sscanf(ptr,"%d",&indx);
		if( temp_rts[indx].type == text_type )
			add_attribute(&dcol,temp_rts[indx].var.text_st.text_string,attr_name,AC_ATTRIB_TEXT);
		else {
			sprintf(attr_val,"%lf",temp_rts[indx].var.root_pm_st.value);
			add_attribute(&dcol,attr_val,attr_name,AC_ATTRIB_DOUBLE);
		}
		ptr = strtok(NULL,",");
	}
	free( attr_desc );

	free( (char *) temp_rts );

	return	OM_S_SUCCESS;		
wrapup :
	return(0);
}

/*** THIS FUNCTION NOT BEING USED ---------------- 05/27/93 *****/
stdstatic_cmpt( rc, dcol, attr, md_env,nb_par,list_temp,state,context )
IGRlong			*rc;
struct	GRid		dcol;
struct	ACrg_coll	*attr;
struct	GRmd_env	*md_env;
struct	GRid		*list_temp;
IGRint			nb_par ;
IGRint			*state;
struct GRid		*context ;
{
char	*catalogname, *nitemname;
int	alsize = 20;
char *ptr;

	_pdm_debug("Entering Std_static_cmpt ... ",0);

	normal_cmpt( rc, dcol, attr, md_env,nb_par,list_temp,state,context );

/************************************************************************************

        Here we have to first make sure that this recompute is being done for the 
        first collection ( STANDARD STATIC ) of the part, which only should have the
        n_itemname attribute

        This is accomplished by having a different recompute function for the first
        collection ie., the first collection will either have "stdstatic_cmpt" or 
        "selection_compute" as the recompute function depending on whether the part 
        is without or with selection criteria, and the rest of all the collections 
        can always have "normal_cmpt" as the recompute function.

**************************************************************************** ********/

	nitemname  = (char *)malloc(20);
	nitemname[0] = '\0' ;
	if(GetACrgAttribVal(&dcol,"n_itemname",&nitemname,&alsize))
	{
		/* check if it is a formula */
		nitemname[strlen(nitemname)-1] = '\0' ;		
		ptr = nitemname;
		while( *ptr )
			if( *ptr++ == '$' )
				break;
		if( *ptr == '\0') /* Not a formula */
			return( OM_S_SUCCESS);
	}
	else
		PDUmessage(PDM_E_CLEAR_FIELD, 's');	

	_pdm_debug(" No n_itemname inside collection",0);

	catalogname  = (char *)malloc(20);
	catalogname[0] = '\0' ;
	if(! GetACrgAttribVal(&dcol,"n_catalogname",&catalogname,&alsize))
		goto wrapup;

	catalogname[strlen(catalogname)-1] = '\0' ;

	if( !ComputeIDAddToDynCol(catalogname, &dcol) )
		goto wrapup;

	return	OM_S_SUCCESS;		
wrapup :
	return(0);
}


extern warn_box();

#define MAX_TEMP 30    /* ACrg_collect + individual exp objects in the criteria */
#define MAX_FEET        60
#define MAX_CHA_TEMP    4
#define MOLD_F	      100

#define	AC_ATTRIB_MASK_TYPE	0x00ff

/* Gadgets */
#define CATALOG        39
#define CAT_DESC       11
#define SKETCH         17
#define LEVEL1         28
#define SEARCH	       32
#define	EXP_LIST       33
#define PART_INDEX     22
#define PLUS	       26
#define MINUS	       25
#define	SUB_TABLE      21
#define PROJECT        38
#define TABLE          21  

#define FORM_ID       201
#define MAX_ROWS      100
#define MOLD_SUB_F    111
#define	PARAMETERS     22


extern  char tolower();
extern  int  display_all, sel_row, max_rows_rtvd, row_num;


/******************** PDU extern variables *******************/

extern char *s_text;
/*************************************************************/


static short   mat_type, stat_func, direction;

static int     select_flag, pos , col , num_feet ;
static int     row_position, ret_flag , selci_macro ;
static int     return_flag ;
static int     sts, msg;


static char    thk[20] ,  tabl_name[20], *part_id, *part_revision ;
static char    txt[MAX_CHA_TEMP], buff[MAX_TEMP*MAX_CHA_TEMP];
static char	*temp_names[MAX_TEMP], *feet_names[MAX_TEMP] ;
static char    fbuff[MAX_TEMP*MAX_CHA_TEMP], *path ;

static double  tmat[16] ;

static Form    placepartf, expfptr ;

/*************************************************************/


selection_place(rc, dcol, attr, md_env)
IGRlong *rc ;
struct	GRid		dcol;
struct	ACrg_coll	*attr;
struct	GRmd_env	*md_env;
{
IGRint			nb_par, *state;
struct GRid		*list_temp, *context ;
int i;


	if( !GetACdyncolExpTempls(&dcol,&nb_par,&list_temp))
		return(0);

	state = (int *)malloc( sizeof(int ) * nb_par);

	for(i = 0;i < nb_par; i++)
		state[i] = ND_COMP_OUT_OF_DATE;

	normal_cmpt( rc, dcol, attr, md_env,nb_par,list_temp,state,context );

	for(i = 0;i < nb_par; i++)
		state[i] = ND_COMP_SAME;

	return(1);
}

dummy_place(/*rc, dcol, attr, md_env*/)
/*IGRlong *rc ;
struct	GRid		dcol;
struct	ACrg_coll	*attr;
struct	GRmd_env	*md_env;
*/
{
	return(1);
}

static char view[5] , **attrlist, **attrsynonym, **attrtypes ;
static int numattribs ;


extern char **AttrList;
extern int NumAttribs;

selection_compute(rc, dcol, attr, md_env,nb_par,list_temp,status,context)
IGRlong *rc ;
struct	GRid		dcol;
struct	ACrg_coll	*attr;
struct	GRmd_env	*md_env;
IGRint			nb_par,*status;
struct GRid		*list_temp, *context ;
{

	int i,  j ,  tabl_no, ch_ind;
	MEMptr data_bufr;
	char formula[200],  **temp_val  ;

	struct ret_struct temp_rts ;
	IGRlong msg;


	_pdm_debug("Enter: selection_compute()",0);

	if( user->username == NULL )
	{
		_pdm_debug("Recompute not possible, No user logged in",0);
		warn_box("Selection not possible, Not in PDM session");
		return(0);
	}

/* Added this to avoid recompute if the attributes are not modified - KK */
	for( i = 0; i < nb_par; i++ )
		if( status[i] != ND_COMP_SAME )
			break;

	ch_ind = i; /* Index of the first template that is modified */

	_pdm_debug("channel index changed = %d", ch_ind);

	/* None of the parents is changed */
	if( i == nb_par ) 
		return(OM_S_SUCCESS);
/*end of addition */

	/*  see if "selection" template is present - special case of single
           collection part with autopart selection */

	for( i = 0; i < nb_par; i ++ )
	{
		sts = om$send(	msg	 = message NDnode.NDgive_structure(
				&msg,
				&temp_rts,
				md_env ),
			targetid = list_temp[i].objid,
			senderid = list_temp[i].objid,
			targetos = list_temp[i].osnum );

	       	_MO_omerr_chk("NDgive_structure1 ", sts, wrapup);
       		_MO_emerr_chk("NDgive_structure1 ", msg, wrapup);

		_pdm_debug("temp_rts.type = %d", temp_rts.type);

		if( (temp_rts.type == text_type) && 
			!strcmp( temp_rts.var.text_st.text_string, "selection") )
				break;	
	}

	if( i < nb_par )  /* Single collection selection criteria */
	{
	int indx;
	char *ptr;
	char temp[156];

		sts = om$send(	msg	 = message NDnode.NDgive_structure(
				&msg,
				&temp_rts,
				md_env ),
			targetid = list_temp[i+1].objid,
			senderid = list_temp[i+1].objid,
			targetos = list_temp[i+1].osnum );

	       	_MO_omerr_chk("NDgive_structure2 ", sts, wrapup);
       		_MO_emerr_chk("NDgive_structure2 ", msg, wrapup);

		_pdm_debug("temp_rts.type = %d", temp_rts.type);
		if( temp_rts.type != text_type )
		{
			_pdm_debug("Error - Should not come here",0);
			return(0);
		}
		_pdm_debug("string = %s",temp_rts.var.text_st.text_string);
		strcpy( temp, temp_rts.var.text_st.text_string );
		ptr = strtok(temp,","); /* first dynattr name */
		ptr = strtok(NULL,","); /* first dynattr name */
		sscanf(ptr,"%d",&indx); /* Channel no. of first dyn. attr */

		_pdm_debug("index of first dynattr = %d", indx);

		if( ch_ind >= indx ) /* Call normal_compute for updating dyn attr */
		{
			normal_cmpt( rc, dcol, attr, md_env,nb_par,list_temp,status,context );
			return(1);
		}
	}

	data_bufr = NULL ;
	Tcol = dcol;
	MOD_ENV = *md_env;

	ret_flag = 1 ;

	if( ! GetNamedAttribValue(&dcol,"n_catalogname",tabl_name,&i)) {
		ex$message(msgnumb = PDR_E_NoDb,
                	      buff = buff);
		warn_box( buff );
		return(0);
	}

	_pdm_debug("Catalogname: %s", tabl_name);

	if( !GetCatTableNo(tabl_name,&tabl_no,view))
		return(0);

	/* get attributes of catalog */
	if( !GetCatAttribs(tabl_no,&attrlist,&attrsynonym,&attrtypes,&numattribs))
		return(0);

	j = 0 ;

	if(!GetCriteria(numattribs, dcol, md_env, &temp_val , nb_par,list_temp))
		return(0);

	if( ! init_select_form( temp_val) )
		return(0);

	for( i = 0 ; i < numattribs ; i = i + 1 )
		MyFree(temp_val[i]);

	MyFree(temp_val);


	_pdm_debug("Returned From init_select_form ()", 0);


	max_rows_rtvd = 0 ;

	do_global_search(placepartf,TABLE,expfptr,tabl_name,&data_bufr,
				attrlist, attrsynonym, attrtypes, numattribs) ;

	if ( data_bufr == NULL  ) {

		if(placepartf)
			FIf_delete(placepartf);

		if(expfptr)
			FIf_delete(expfptr);

		sprintf(formula,"No valid row found for catalog %s",tabl_name);
		warn_box(formula); 
		return(1);
	}


	set_sub_form_params (expfptr, PARAMETERS,attrsynonym,attrlist,numattribs,0);   
	
	FImcf_set_select(expfptr, SUB_TABLE, (max_rows_rtvd - 1), 1, 1);

	get_row_from_mcf (max_rows_rtvd, numattribs , expfptr, 21);


	_pdm_debug("Returned From do_global_search ()",0);
	
	if( MEMbuild_array(data_bufr) != MEM_S_SUCCESS ) {
		_pdm_debug("Error building array\n",0);
		return(0);
	}

	_pdm_debug("no. of records found:%d ", data_bufr -> rows );


       /* if only one row found change extern feet */
       if( data_bufr -> rows == 1 ) {
		SELacc_datadata();

		if(placepartf)
			FIf_delete(placepartf);

		if(expfptr)
			FIf_delete(expfptr);
	}

	else      /* If more than one valid row found let user select part */
	{
/*
 * 	TR # 1393 10493. Form is displayed, erased and displayed again.
 * 	This is caused by displaying the form first and them converting it to permanent window.
 * 	FIf_display () call moved.
 * 
 * 		FIf_display( placepartf );
 */		
	        FIf_cvrt_to_perm_win(placepartf); /* This is required, since more
                                                     than one part can get the compute
                                                     at the same time, and if each of the
                                                     forms is not converted, it locks
                                                     up the system*/
		FIf_display( placepartf );
		if ( ! WaitForEvent()  ) {
			return(0);
		}

	}
	return(1);
wrapup:
	return(0);
 
}

void DYNdelete_form()
{

     FIf_erase(placepartf);
     FIf_delete(placepartf);

     if(expfptr)
          FIf_delete(expfptr);
}     

#define DYN_NAMES      32
#define SYM_MAP        23
#define STA_DYN        17

init_select_form( temp_val)
char *temp_val[] ;
{
extern int exp_list_notification();
void f_notification();

	/* This function creates form and sets the initial field values before the 
	   form is displayed 
	*/

	int      i, len ;
	char *cat_desc, *ptr  ;

        display_all = 0 ;

  	sts = FIf_new ( MOLD_F, "MOPartSelec2",f_notification, &placepartf);
  	if ( sts ) 
  	{	
    		fprintf(stderr,"FORM CREATION ERROR %d\n",sts );
    		return(FALSE);
  	}

        sts = FIf_new ( MOLD_SUB_F, "MOListing",exp_list_notification, &expfptr);
  	if ( sts ) 
  	{	
    		fprintf(stderr,"MOListing FORM CREATION ERROR %d\n",sts );
    		return(FALSE);
  	}

	/* set the parameter column in select mode */
	for( i = 0 ; i < 4 ; i = i + 1 ) 
        	FIfld_set_mode(placepartf,TABLE,i,FI_SINGLE_SELECT); 

	/* set catalog class gadget and catalog gadget in select mode */

	FIfld_set_mode(placepartf,CATALOG,0,FI_SINGLE_SELECT); 

	display_attribs(placepartf,TABLE,numattribs,attrsynonym,attrlist);


	_pdm_debug("Returned From set_parameters ()",0);


	GetCatalogDesc(tabl_name,&cat_desc);
	FIfld_set_text(placepartf,CATALOG,0,0,tabl_name,TRUE);
        if (!strcmp (cat_desc, "NULL"))
	  FIfld_set_text(placepartf,CAT_DESC,0,0,"",TRUE);
        else
	  FIfld_set_text(placepartf,CAT_DESC,0,0,cat_desc,TRUE);

	set_active_form_ptr(placepartf);

	free( cat_desc );

	for( i = 0 ; i < numattribs  ; i = i + 1 ) {
        	/* some junk in column 4. causing problem . So put null first*/
		FIfld_set_text(placepartf,TABLE,i,3,"",FALSE);
		remove_quotes(temp_val[i]);
		
		/* seperate operator and criteria */
		ptr = strtok(temp_val[i],",");
		len = strlen(ptr );
		if( temp_val[i][len+1] == '0' ) continue ;
		FIfld_set_text(placepartf,TABLE,i,SEARCH_COL,&temp_val[i][len+1],FALSE);
		FIfld_set_text(placepartf,TABLE,i,OPER_COL,ptr,FALSE);
	}

	/* erase the following gadgets */
	/* erase gadgets related to dyn pars */
	switch_off_gdgs(placepartf);
	FIg_disable(placepartf,PROJECT);
	FIg_disable(placepartf,LEVEL1);
	FIg_disable(placepartf,CATALOG);
	FIg_disable(placepartf,SEARCH);
	FIg_disable(placepartf,12);
	FIg_disable(placepartf,SKETCH);
	FIg_disable(placepartf,45);
	FIg_disable(placepartf,46);
	FIg_disable(placepartf,47);

	selci_macro = 1 ;

	return(1);
}

/* notification routine for place part form */
void f_notification(f_label, g_label, value, fp)
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
/*	int     i,col,row, attr ;
	int	cnt, sel_flg;
	char *output_str ;
	MEMptr data_bufr ;

	data_bufr = NULL ;
*/
  int             responses[1];
  char          * strings[1];
  char          * msg;

	switch ( g_label )  {

		case FI_CANCEL:  
			FIg_set_state_off(fp,FI_CANCEL);

		        _pdm_debug("putting MOVE_ON to the queue", 0);
		        responses[0] = MOVE_ON;
		        strings[0] = "";
		        PDUprepare_queue(responses, strings, 1);

			ret_flag = 0 ;
			DYNdelete_form();
			break;

		case FI_ACCEPT: 
        		if ( ! SELacc_datadata() )
				break;
			FIg_set_state_off(fp,FI_ACCEPT);

		        _pdm_debug("putting MOVE_ON to the queue", 0);
		        responses[0] = MOVE_ON;
		        strings[0] = "";
		        PDUprepare_queue(responses, strings, 1);

			ret_flag = 1 ;
			DYNdelete_form();
			break;

		case SKETCH:
			/* for the current part show sketch */     
			display_fig(200,placepartf,SKETCH,&MOD_ENV);
			break;

/*		case TABLE:  

			col = 0 ;
			row = 0 ;

			FImcf_get_active_col ( fp, g_label, &col, &pos );
			FIfld_get_active_row ( fp, g_label, &row, &pos );

			if(col == 0  ) {
				do_search ( fp, TABLE,tabl_name, row,col,&output_str,
					  attrlist, attrsynonym, attrtypes, numattribs);

				display_few(fp,MOLD_F, TABLE, row, col, pos, &sel_flg);
			}

			break;
*/

		case SEARCH :
			/* global search i.e., search for all the templates	*/

/*			display_all = 1;

			do_global_search(fp,TABLE,expfptr,tabl_name,&data_bufr,
					attrlist, attrsynonym, attrtypes, numattribs) ;

			set_sub_form_params (expfptr, PARAMETERS,attrsynonym,attrlist,numattribs,0);   
	
			FImcf_set_select(expfptr, SUB_TABLE, (max_rows_rtvd - 1), 1, 1);

			get_row_from_mcf (max_rows_rtvd, numattribs , expfptr, 21);

        		FIg_set_state_off(fp,SEARCH);
*/
			break;

		case  EXP_LIST:
			/* display expanded listing form */
			FIg_set_state_off ( fp, EXP_LIST );
			FIf_display ( 	    expfptr   );
			break;


		case  PLUS:

			if (row_num == max_rows_rtvd || row_num == 0) {
				FIg_set_state_off(fp,PLUS);
                                msg = (char *)PDUtranslate_message(PDM_E_END_OF_DATA);
				FIfld_set_text (fp, FI_MSG_FIELD, 0, 0, msg, TRUE);
			}
			else {
				row_num = row_num + 1;
				get_row_from_mcf (row_num,numattribs, expfptr, SUB_TABLE);
				FIg_set_state_off(fp,PLUS);
				FIfld_set_text (fp, 10, 0, 0, "", TRUE);	 

				/* col is forced to 1 always!! Probably a bug in FORMS ? */
				FImcf_set_select(expfptr, SUB_TABLE, (row_num - 1), 1, 1);
			}
			break;

		case  MINUS:
			if (row_num == 1 || row_num == 0) 
				FIg_set_state_off(fp,MINUS);	 
			else {
				row_num = row_num - 1;
				get_row_from_mcf (row_num, numattribs,
                                                  expfptr, SUB_TABLE);
				FIg_set_state_off(fp,MINUS);
				FIfld_set_text (fp, 10, 0, 0, "", TRUE);
			}

			/* col is forced to 1 always!! Probably a bug in FORMS ? */
			FImcf_set_select(expfptr, SUB_TABLE, (row_num - 1), 1, 1);
			break;
	}
} 

SELacc_datadata()
{
        int i ;
	int     alsize;
	char	*nitemname, *ptr;

	int 	no_stat, no_dyn, sts;
	char 	**stat_attr=NULL, **stat_type=NULL, **stat_desc=NULL, 
		**stat_unit=NULL, **dyn_attr=NULL,  **dyn_type=NULL,
		**dyn_desc=NULL ;

	char    **vals, *computed_id;

/*	TR # 139310496. Have another var to store NumAttribs Value.	*/
/*	07/Nov/93 - raj.						*/
	int	store_numattribs;
/*	TR# 139420918. 12/July/94 - raj. Store AttrList value to be restored at end.	*/
	char	**save_attrlist;
	
	sts = 0;

        /* Get the n_itemname from the collection to check later, if it contains a 
           formula ( Computed ID )
        */
	nitemname  = (char *)malloc(20);
	nitemname[0] = '\0' ;
	alsize = 20;
	if(!GetACrgAttribVal(&Tcol,"n_itemname",&nitemname,&alsize))
		goto wrapup;

	nitemname[strlen(nitemname)-1] = '\0' ;		

	no_stat = 0;  no_dyn = 0 ;

	/* Get static attributes which are templates to macro */
	GetStatAndDynAttribs (  tabl_name, 
			&no_stat, &stat_attr, &stat_type, &stat_desc, &stat_unit,
			&no_dyn,  &dyn_attr,  &dyn_type,  &dyn_desc  );

	FreeArrayPtr(dyn_attr,no_dyn);
	FreeArrayPtr(dyn_type,no_dyn);
	FreeArrayPtr(dyn_desc,no_dyn);

	/* Obtain the n_itemname and n_itemrev from the FORM */
	for( i = 0 ; i < numattribs ; ++i ) 
		if(!strcmp(attrlist[i],"n_itemname"))
			break;

	if( (i == numattribs) || (!Get_text(placepartf,TABLE,i,1)))
		goto warn_msg ;

	part_id = (char *)malloc(strlen(s_text) + 1 );
	strcpy(part_id,s_text);

	for( i = 0 ; i < numattribs ; ++i ) 
		if(!strcmp(attrlist[i],"n_itemrev"))
			break;

	if( (i == numattribs) || (!Get_text(placepartf,TABLE,i,1))){
warn_msg:
       		ex$message( msgnumb = PDR_E_nDef,
                      	    buff = buff) ;
       		warn_box(buff); 
               	return(0); ;
       	}

	part_revision = (char *)malloc(strlen(s_text) + 1 );
	strcpy(part_revision,s_text );

	/* Now read the other static attributes from the FORM and modify them in
           the collection
        */

/* Added 25/02/93 -- */
/*	TR# 139420918. 12/July/94 - raj. Store AttrList value to be restored at end.	*/
	save_attrlist = AttrList;
	AttrList = attrlist;
/*	TR # 139310496. store NumAttribs Value.	*/
/*	07/Nov/93 - raj.						*/
	store_numattribs = NumAttribs;
	NumAttribs = numattribs;
/* end */

	if( !ReadStatAttribsonForm( tabl_name, placepartf, TABLE, stat_attr, stat_type,
					stat_unit,no_stat,&Tcol))
	{
               	_pdm_debug("Error modifying static attrs in rg_collect",0);
                goto wrapup;
       	}

	/* Check if the original part has a Computed ID */
	ptr = nitemname;
	while( *ptr )
		if( *ptr++ == '$' )
			break;
	if( *ptr != '\0') /*  a formula string rpesent */
	{
/*
		if( !ComputeIDAddToDynCol( tabl_name, &Tcol) )
			goto wrapup;
*/

      /*** NOTE: NOT using the dynamic attributes for recomputing the CID. - TBD ****/

		vals  = (char **)malloc(sizeof(char *) * numattribs);

		for( i = 0 ; i < NumAttribs; i++)
		{
			Get_text(placepartf,TABLE,i,1);
			vals[i]  = (char *)malloc(strlen(s_text) + 1 );
			strcpy( vals[i], s_text );
		}
		
		_pdm_debug("Calling GetID_N_Compute",0);

		sts = GetID_N_Compute(tabl_name, attrlist, vals, attrtypes, numattribs,
									 &computed_id, 0);
		if( sts )	
		        mod_attribute(&Tcol, "n_itemname", computed_id, AC_ATTRIB_TEXT);
	}
	else /* No formula */
		mod_attribute(&Tcol, "n_itemname", part_id,AC_ATTRIB_TEXT);

	mod_attribute(&Tcol, "n_itemrev",  part_revision,AC_ATTRIB_TEXT);
/* end */

/*	compute_dependents( &Tcol, 1 );*/
	clear_ptrs();

/*	TR # 139310496. Restore NumAttribs Value.	*/
/*	07/Nov/93 - raj.				*/
	NumAttribs = store_numattribs;
/*	TR# 139420918. 12/July/94 - raj. Store AttrList value to be restored at end.	*/
	AttrList = save_attrlist;

	sts = 1;

wrapup:
	FreeArrayPtr(stat_attr,no_stat);
	FreeArrayPtr(stat_type,no_stat);
	FreeArrayPtr(stat_desc,no_stat);
	FreeArrayPtr(stat_unit,no_stat);
	return(sts);
}


GetCriteria( stat_attr, acdcol, md_env, crit_val,cnt,list )
int stat_attr, cnt;
struct GRid acdcol;
struct GRmd_env *md_env;
char ***crit_val;
struct GRid *list;
{
int i, sts, nb_exp, no_of_exps;
struct ret_struct temp_rts ;
IGRlong msg;

int num_dyn;
char *attr_desc;
char *ptr;

	/*  see if "selection" template is present - special case of single
           collection part with autopart selection */

	for( i = 0; i < cnt; i ++ )
	{
		sts = om$send(	msg	 = message NDnode.NDgive_structure(
				&msg,
				&temp_rts,
				md_env ),
			targetid = list[i].objid,
			senderid = list[i].objid,
			targetos = list[i].osnum );

	       	_MO_omerr_chk("NDgive_structure1 ", sts, wrapup);
       		_MO_emerr_chk("NDgive_structure1 ", msg, wrapup);

		_pdm_debug("temp_rts.type = %d", temp_rts.type);

		if( (temp_rts.type == text_type) && 
			!strcmp( temp_rts.var.text_st.text_string, "selection") )
				break;	
	}

	if( i < cnt )  /* Single collection selection criteria */
	{
		/* Get the value of the last template */
		sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&temp_rts,
					md_env ),
				targetid = list[cnt-1].objid,
				senderid = list[cnt-1].objid,
				targetos = list[cnt-1].osnum );

	       	_MO_omerr_chk("NDgive_structure ", sts, wrapup);
       		_MO_emerr_chk("NDgive_structure ", msg, wrapup);

		sscanf(temp_rts.var.text_st.text_string,"%d",&no_of_exps);

		_pdm_debug("no_of_exps:%d",no_of_exps);

		/* Now parse the last template to get the number of dynamic	*/
		/* attributes connected						*/

		num_dyn = 0;/* Attrib name */

		_pdm_debug("no_of_exps: %d", no_of_exps ) ;

		attr_desc = (char *) malloc( no_of_exps * 85 );
		attr_desc[0] = '\0';

		for( i = 0 ; i < no_of_exps ; ++i ) {
			sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&temp_rts,
					md_env ),
               		       	targetid = list[cnt-1 - (no_of_exps-i)].objid, 
               			targetos = list[cnt-1 - (no_of_exps-i)].osnum,
				senderid = list[cnt-1 - (no_of_exps-i)].objid);

	     		_MO_omerr_chk("expression: give_formula : GetCriteria():", sts, wrapup);

			strcat(attr_desc,temp_rts.var.text_st.text_string);
		}
	
		_pdm_debug("attr_desc: %s", attr_desc );

		ptr = strtok(attr_desc, "," ); 
		while( ptr != NULL ) {
			ptr = strtok(NULL,","); /* Attrib index */
			if( ptr != NULL )
				num_dyn ++;
			ptr = strtok(NULL, "," ); /* Attrib name */
		}
		free( attr_desc );

		/* no. of exp objects */	
		nb_exp = cnt - (num_dyn + stat_attr + no_of_exps + 2); 
	}
	else
		nb_exp = cnt - stat_attr; 

	_pdm_debug("GetCriteria(): no. of exps in criteria %d", nb_exp );

	*crit_val = (char **)malloc( stat_attr * sizeof( char *));
	for( i = 0 ; i < stat_attr ; i = i + 1 ) 
	{
		sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&temp_rts,
					md_env ),
                       	targetid = list[i].objid, 
                       	targetos = list[i].osnum,
			senderid = list[i].objid);

	     	_MO_omerr_chk("expression: give_formula : GetCriteria():", sts, wrapup);

		(*crit_val)[i]= (char *)malloc(strlen(temp_rts.var.text_st.text_string) + 30);
		strcpy((*crit_val)[i],temp_rts.var.text_st.text_string);

		_pdm_debug("GetCriteria: stat_crit_temp: %s",(*crit_val)[i]);
	}

	change_index_to_text(*crit_val,stat_attr,nb_exp,acdcol,md_env);
	return(1);
wrapup:
	return(0);
}

clear_ptrs()
{
	/* free catalog attribs */
	FreeArrayPtr(attrlist,numattribs);
	FreeArrayPtr(attrtypes,numattribs);
	FreeArrayPtr(attrsynonym,numattribs);

/*	TR # 139310496. Restore NumAttribs value after the call to this	*/
/*	function in SELacc_datadata(). Do NOT make it zero here.	*/
/*	07/Nov/93 - raj.						*/
/*      NumAttribs = 0;	*/

	return(1);
}


ReadAtrsFromCols(rg_grid, attrs, types, vals, num )
struct GRid *rg_grid ;
char ***attrs,  ***types ,  ***vals ;
int *num ;
{

struct ACrg_coll *list_attr;
int nb_attr, i;

	IGRlong		sts, msg;

	_pdm_debug ("Enter ReadAtrsFromCols: ", 0);

	/* If pointer to "struct ACrg_coll" is NULL, the message 	*/
	/* RETURNS the no of attributes in 'nb_attr'			*/
	sts = om$send (	msg	= message ACrg_collect.AClist_attribute( 
						&msg, 0, 
						NULL, &nb_attr),
			targetid = rg_grid -> objid,
			targetos = rg_grid -> osnum ,
			senderid = rg_grid -> objid);

	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", msg, wrapup);
	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", sts, wrapup);

	_pdm_debug ("No Of Attribs %d", nb_attr);

	/* The message expects an array of structures of type	*/
	/* "struct ACrg_coll" of length 'list_len' to be allocated for	*/
	/* in advance. 							*/

	/* Allocate for the no of attributes in ACdyn_col object	*/
	list_attr = (struct ACrg_coll *) malloc ( nb_attr * sizeof (struct ACrg_coll));
	MemCheck (list_attr);

	sts = om$send (	msg	= message ACrg_collect.AClist_attribute( 
						&msg, nb_attr, 
						list_attr, &nb_attr),
			targetid = rg_grid -> objid,
			targetos = rg_grid -> osnum ,
			senderid = rg_grid -> objid);

	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", msg, wrapup);
	_MO_omerr_chk("ACrg_collect.AClist_attribute : GetACrgAttribList () : ", sts, wrapup);

	*num = nb_attr ;

	*attrs = (char **)malloc( nb_attr * sizeof( char *));
	*types = (char **)malloc( nb_attr * sizeof( char *));
	*vals  = (char **)malloc( nb_attr * sizeof( char *));

	for ( i = 0 ; i < nb_attr ; ++i ) {

		(*attrs)[i] = (char *)malloc(strlen(list_attr[i].name)+1);
		strcpy((*attrs)[i],list_attr[i].name );
		
		(*vals) [i] = (char *)malloc( 80 );		
		(*types)[i] = (char *)malloc(20);

		if( list_attr[i].desc.type & AC_ATTRIB_MASK_TYPE 
						& AC_ATTRIB_DOUBLE ){
	
			strcpy((*types)[i],"Expression double");			
			sprintf((*vals)[i],"%lf",list_attr[i].desc.value.att_exp );
		}
		else{
			strcpy((*types)[i],"Expression text");			
			strcpy((*vals)[i],list_attr[i].desc.value.att_txt );
		}	
	}

	return (1);

wrapup :
	return (0);	


}

compute_dependents( coll, exec_flag ) 
struct GRid *coll; 
int exec_flag ;
{
	int cnt , info, i, j;
	struct GRid *list, *batchlist ;
	OMuword classid;

     	sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN, NULL,0,
						    NULL, 0, OM_K_MAXINT, &cnt),
                       	targetid = coll->objid, 
                       	targetos = coll->osnum,
			senderid = coll->objid);

     	_MO_omerr_chk("compute_dependents () : NDnode.NDgetobjects ",  sts,  wrapup);

	_pdm_debug("No. of dependents = %d", cnt);
	list = (struct GRid *)malloc(sizeof(struct GRid) *cnt );
	batchlist = (struct GRid *)malloc(sizeof(struct GRid) *cnt );

     	sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN, list,cnt,
						    NULL, 0, OM_K_MAXINT, &cnt),
                       	targetid = coll->objid, 
                       	targetos = coll->osnum,
			senderid = coll->objid);

     	_MO_omerr_chk("compute_dependents () : NDnode.NDgetobjects2 ",  sts,  wrapup);

/* Remove the nci_macro class objects from the batch list, these class of 
   objects are getting recompute directly */

	for(i = 0,j = 0; i < cnt; i++)
	{
		om$get_classid( objid = list[i].objid,
				osnum = list[i].osnum,
				p_classid = &classid );

		if( classid != OPP_nci_macro_class_id )
			batchlist[j++] = list[i];
	}

        _pdm_debug("No of dependents in batchlist = %d",j);

        info = ND_COMP;

        nd$wait_batch(
	    	type = GR_GEOM_POSTED, 
/* 09/Nov/93 - raj. TR # 139308986.				*/
/* Do not remove nci_macro class objects. Use original list.	*/
/*		l_object = batchlist, 	*/
		l_object = list, 	
		l_obj_info = &info, 
/* 09/Nov/93 - raj. TR # 139308986.				*/
/* Do not remove nci_macro class objects. Use original count.	*/
/*		nb_obj   = j );					*/
		nb_obj   = cnt );

	if( exec_flag )  /* Only if this flag is TRUE execute the batch */
	{
        	nd$mod_batch(request    = ND_SET, 
                  req_mode   = ND_IMMEDIATE);

	        nd$exec_batch();
	}

	MyFree( list );
	MyFree( batchlist );

	return(1);
wrapup:
	return(0);
}

end implementation ACdyn_col ;




