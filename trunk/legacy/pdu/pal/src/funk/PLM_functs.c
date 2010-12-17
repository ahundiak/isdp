#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "MEMstruct.h"
#include "PDUstr.h"
#include <PDUerror.h>
#include <PDMdebug.h>
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "griodef.h"
#include "PALglbs.h"
#include "PALmsg.h"
#include "MEMerrordef.h"
#ifdef bld21
#include "FI.h"
#endif

/* 13941 8047. */
#include "PDUuser.h"
#include <sys/stat.h>

/*#include "PDUproto.h" */
#include "PALfunkpro.h"
#include "PALpdmrpro.h"

#define	TRUE	1
#define	FALSE	0

/* Expanded listing sub form gadgets */
#define SUB_TABLE      	21	
#define	MOVE_YES	12
#define PARAMETERS	22
#define LIST_BTN	13
#define KEYIN_FIELD	11
#define	EXP_LIST       33
#define PLUS           26
#define MINUS          25
#define SAVE_CRT        46


/* Select/Place part from gadgets */
#define	SPpart_F	100
#define CATALOG		39
#define CAT_DESC	11
#define CMP_NAME	20
#define TABLE		21
#define PART_INDEX     	22
#define	DATA_COL	1
#define PROJECT		38

/* Warning form constants */
#define WARN_F	      177
Form    warning_f;

/* #define	DEBUG 1 */


/* ---------------------- Extern Variables  ---------------------------- */

extern char **AttrList    ;
extern char **AttrTypes   ;
extern char **AttrSynonym ;
extern int  NumAttribs    ;
extern	char ViewOrTblList[][6];

extern  int 	PDU_comm_attribs;
extern	int	PDU_ComputedID;
extern	int	sel_row;
extern	int	row_num;
extern  int     PDU_value_pulldown;
extern  int	NumCatalogs;
extern	char	*s_text;
extern	char	*PDU_value_list[605];
extern  int     max_rows_rtvd;
Form	cur_form_f;
extern Form  PDU_calling_form;

extern struct	PDUrefresh	*refresh ;

/* --------------------------------------------------------------------- */

char **param_val;
int  no_of_param_vals;

static int glob_rows ;

init_forms (int form1_id, int form2_id, Form *fp1, Form *fp2, int flag)
{
	int	sts;

	/* Create the forms */
	int	selprt_notification ();
	int	exp_list_notification ();
	int	mdprt_notification ();

	if( flag == 0 )
  		sts=FIf_new(form1_id,"MOPartSelec2", selprt_notification, fp1);
	else
  		sts=FIf_new(form1_id,"MOPartSelec2", mdprt_notification, fp1);

  	if ( sts ) 
  	{	
    		fprintf(stderr,"MOPartSelec2 FORM CREATION ERROR %d\n",sts );
    		return(FALSE);
  	}

  	sts = FIf_new ( form2_id, "MOListing",exp_list_notification, fp2);
  	if ( sts ) 
  	{	
    		fprintf(stderr,"MOListing FORM CREATION ERROR %d\n",sts );
    		return(FALSE);
  	}

        return(1);
}


add_to_puldwn_list(Form fp, char *output_string, int num_rows)
	
	/* This routine adds entries from output_string to array 
	   if search is on common attributes and values are DISTINCT */
{
	/* A part with a view as the data_table has its ID as a string
	  of text and column names beginning with 'C:' .
	  The values of these columns are substituted in the string.
	  Since, in a parameter by parameter search, all the column
	  values might not have been retrieved, we donot allow user
	  to do a search on this field					*/

	char  	*ptr ;
        char    *msg;
       
	ptr = strtok(output_string,"~");
	if (!strncmp (ptr, "C:", 2)){
                msg = (char *)PDUtranslate_message(PDM_E_ATTR_VALUE_GEN_FUNC);
                FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,TRUE);
		return (0);
	}

	if(no_of_param_vals == 0 )
		param_val = (char **)malloc( num_rows * sizeof(char *));

	else if( PDU_comm_attribs )
		param_val = (char **)realloc(param_val,(no_of_param_vals+num_rows)*
							sizeof(char *));

	while( ptr != NULL ){
		
 		if(  strcmp(ptr,"nil") &&
 		     is_a_new_entry(ptr,param_val,no_of_param_vals) ) {
/*		if(is_a_new_entry(ptr,param_val,no_of_param_vals)) {*/
	                param_val[no_of_param_vals] = (char *)malloc( strlen(ptr) + 1) ;
        	        strcpy(param_val[no_of_param_vals++], ptr);
		}
                ptr = strtok( NULL, "~");
	}
	return(1);
}

display_few(Form fp, int form_num, int mcf_label, int mcf_row, int mcf_col, 
							int pos, int *sel_flg)
{
	/* This function displays valid fields for the 
	   parameter selected with given search criteria */

	/* display pull down list */

	*sel_flg = 0;

        _pdm_debug("no_of_param_vals = %d", (char *)no_of_param_vals);

/* MJG - TR 139417952 - Sometimes no_of_param_vals is a negative number.
   Check for > 0 */

        if( no_of_param_vals > 0 ) {
		pull_down(fp, form_num, mcf_label, mcf_row, mcf_col,DATA_COL, 
			  param_val, no_of_param_vals, pos, sel_flg); 

		FreeArrayPtr(param_val,no_of_param_vals);
	
		no_of_param_vals = 0;
	}
        else
          PDUmessage(PDM_E_NO_ATTR_VALUES, 's');

}


#define COMP_FORM      101

extern access();




/******************************************************************************/

set_table_field(Form fp, char *table_name, int glabel, 
		int starting_row, MEMptr data_bufr)

/* Formats the data on fp from output_string
   Displays the records in the multicolumn fields of sub form     */

{
	char *value ;
	char **data_ptr ;
	short i ;
	int col, start_col;

	/* set in select mode */
	if(starting_row == 0 ) {
		/* Create additional columns if required */
                if (NumCatalogs == 1)
                insert_additional_columns(fp,glabel,data_bufr -> columns );
                else
                insert_additional_columns(fp,glabel,data_bufr -> columns+1 );

		for( i = 0 ; i < data_bufr -> columns+1  ; i = i + 1  ) 
        		FIfld_set_mode(fp,glabel,i,FI_SINGLE_SELECT);

		FImcf_set_select(fp,glabel,0,1); 
		sel_row = 0 ;
	}

	/* set multicolumn fields */
	if(NumCatalogs > 1 )
		start_col = 1 ;
	else
		start_col = 0 ;

	data_ptr = (char **)data_bufr -> data_ptr ;

	for( i = 0 ; i < data_bufr -> rows ; ++i ) {

		if( NumCatalogs > 1)
			FIfld_set_text(fp, glabel, starting_row+i, 0, table_name, FALSE);

		for(col = start_col ; col < data_bufr -> columns ; col = col + 1  ) {
			value = data_ptr[i * (data_bufr -> columns) + col - start_col];
			_pdm_debug("value = %s",value);
			if( strcmp(value ,"nil") != 0 ) 
				FIfld_set_text(fp, glabel, starting_row+i, col, value,0);
		}
	}

/* Check the first row, col by col to see if the ID is of 'Compute ID' type 
	if( NumCatalogs == 1 ){
		for (col = 0; col < data_bufr -> columns ; col = col + 1){
			if (!Get_text (fp, glabel, 0, col)) return (0);
			if (!strncmp (s_text, "C:", 2)){
				PDU_ComputedID = TRUE;
				break;
			}
		}
		if ( col == data_bufr -> columns) {  Computalble ID not found 
			PDU_ComputedID = FALSE;			
			return (1);
		}
		ComputeID (fp,glabel,col, s_text, starting_row);
	}
*/
	return(1);
}



exp_list_notification (f_label,g_label,value,fp)
int f_label, g_label;
double value ;
Form   fp    ;
{
	int	row, col, pos;

/* ALR TR 139415196 

	if( (g_label == SUB_TABLE)  && value < 0 ) {
		FImcf_get_active_col ( fp, g_label, &col, &pos );
		FImcf_set_active_col ( fp, PARAMETERS, col, pos);
		FIg_display(fp,PARAMETERS);
		return ;
	}
*/

	switch ( g_label )  {

		case FI_ACCEPT:
			FIg_set_state_off(fp, FI_ACCEPT);
			FIf_erase(fp);

			if( ! GetSelectedRow(fp,SUB_TABLE,&row))
				break;

			get_row_from_mcf (row + 1, NumAttribs, fp, SUB_TABLE);
			FIg_set_state_off ( cur_form_f, EXP_LIST ); 
			break;

		case SUB_TABLE:
			FImcf_get_active_col ( fp, g_label, &col, &pos );
			FIfld_get_active_row ( fp, g_label, &row, &pos );

			/* col is forced to 1 always!! Probably a bug in FORMS ? */
			FImcf_set_select(fp,g_label,row,1);
                         /* ALR  TR 139415196 */
                        FImcf_set_scroll_link(fp,SUB_TABLE,PARAMETERS);
			break;

		case FI_CANCEL: 
			FIg_set_state_off(fp, FI_CANCEL);
			FIf_erase(fp);
			FIg_set_state_off ( cur_form_f, EXP_LIST ); 
                        PDU_calling_form = 0;
			break;
	} 

}



get_row_from_mcf (row, no_of_fields, sub_fp, MCF_LABEL)
int	row, no_of_fields;
Form	sub_fp;
int	MCF_LABEL;
{

	/* gets the values for all the parameters of the part by reading  the 
	   specified row 
	   AND
	   puts them in the value column of the form			      */

	int	mcf_col, scol = 0 , j = 0 ;

        _pdm_debug("in the function get_row_from_mcf", 0);

	if( row == 0 )
	{
                _pdm_debug("exiting: row = 0", 0);
		FIfld_set_value (cur_form_f, PART_INDEX, 0, 0, 0, FALSE);
		return;
	}

	/* Check if the starting column is catalog */
	if( Get_text(sub_fp, PARAMETERS,0,0))
		if(!strcmp(s_text,"Catalog"))
			scol = 1;

	_pdm_debug("row from which the values are read: %d", row-1 )	;

        _pdm_debug("no_of_fields = %d", (char *)no_of_fields);

	for (mcf_col = scol; mcf_col < no_of_fields + scol ; mcf_col = mcf_col + 1 ){
	   if(!Get_text (sub_fp, MCF_LABEL, (row - 1), mcf_col)) {
                _pdm_debug("Get_text failed", 0);
           	FIfld_set_text(cur_form_f, TABLE,j++, DATA_COL,"",FALSE);
		continue;
	   }

	   /* The parameters are placed vertically on the master form	*/

           FIfld_set_text(cur_form_f, TABLE,j++, DATA_COL,s_text,FALSE);

	   _pdm_debug("text from exp list: %s", s_text);

	}
	
	row_num = row;
	FIfld_set_value (cur_form_f, PART_INDEX, 0, 0, (double )row, FALSE);

	/* TR#139306731,32 */
	if( row > 1 )
	{
		FIg_enable( cur_form_f, EXP_LIST );
		FIg_enable( cur_form_f, PLUS );
		FIg_enable( cur_form_f, MINUS );
	}

	if( scol )  {   /* reset catalog */

		Get_text(sub_fp,SUB_TABLE,row-1,0);

		mystrcpy(&refresh -> rev_catalog,s_text);
	}

	/* If not in search across common attributes break */
        if( scol ){
                scol = 0;
                FIg_get_state(sub_fp,MOVE_YES,&scol);

		_pdm_debug("state: %d", scol );

                if( scol ){
			row_num = 0; /* Fix for TR#139222295 */
                        UpdateRefreshStr(cur_form_f,TABLE);
                        rest_on_cat_selection(cur_form_f,2);
                }
	}
}

set_active_form_ptr(Form fp)
{
	cur_form_f = fp;
}

get_active_form_ptr( Form *fp )
{
	*fp = cur_form_f;
}


set_sub_form_params(fp, parameters, cat_attr, attr_name, no_cat_attr, flag)
Form 	fp ;
int	parameters, flag ;
char	**cat_attr;
char	**attr_name;
int	no_cat_attr;
{

       int i ;

       insert_additional_columns(fp,parameters, no_cat_attr + flag);

	_pdm_debug("Returned from insert_add_columns,Numattrs = %d", no_cat_attr);

       if( flag )
                FIfld_set_text(fp,parameters,0,0,"Catalog",FALSE);
		
       for( i = flag ; i < no_cat_attr; i = i + 1 ) 
	{
                if (flag)
                {
		_pdm_debug("Attriblist= %s", cat_attr[(i - 1)] );
                if (strlen(cat_attr[(i - 1)]))
                  FIfld_set_text(fp,parameters,0,i, cat_attr[(i - 1)], FALSE);
                else
                  FIfld_set_text(fp,parameters,0,i, attr_name[(i - 1)], FALSE);
                }
                else
                {
		_pdm_debug("Attriblist= %s", cat_attr[i] );
                if (strlen(cat_attr[i]))
                  FIfld_set_text(fp,parameters,0,i, cat_attr[i], FALSE);
                else
                  FIfld_set_text(fp,parameters,0,i, attr_name[i], FALSE);
                }
	}
}
	
/******************************************************************************/

reset_forms(Form fp1, Form fp2,int mcf,char *catname, char *project, int numattr, char **attrdesc, char **attrlist )
{
	int i;
	char 	*cat_desc = NULL;
_pdm_debug("inside reset_form \n",0);
        if(fp2 ) FIg_reset (fp2, mcf ); 
	if( fp1) FIg_reset (fp1, PART_INDEX);
	if( catname != NULL && strcmp(catname,"")){

		GetCatalogDesc(catname,&cat_desc);
        if (!strcmp (cat_desc, "NULL"))
		FIfld_set_text(fp1, CAT_DESC, 0, 0, "", TRUE);
        else
		FIfld_set_text(fp1, CAT_DESC, 0, 0, cat_desc, TRUE);
		if(cat_desc) free (cat_desc);
		if( !PDU_comm_attribs )
			FIfld_set_text(fp1, CATALOG, 0, 0, catname, TRUE);
		else /* Fix for TR#139301544 */
			FIfld_set_text(fp1, CAT_DESC, 0, 0, "", TRUE);
                /* ALR  TR139313182 */
/* TR # 13931 3704.	30/Nov/93 - raj.	*/
/*                if (strcmp(project,"") != 0)	*/
                if (project != NULL && strcmp(project,"") != 0)
	           FIfld_set_text(fp1, PROJECT, 0, 0, project, TRUE);
		display_attribs(fp1,mcf,numattr,attrdesc,attrlist);

		for( i = 0 ; i < numattr ; ++i ) {
			FIfld_set_text(fp1,TABLE,i,1,"",FALSE);
			FIfld_set_text(fp1,TABLE,i,3,"",FALSE);
		}
	}

}

extern EXPsubstitute();
extern parse_expr();

extern free_ptrs();


remove_path(str)
char str[];
{

	char *tmp , *ptr ;

	ptr = strrchr(str,':');

	if( ptr != NULL ) {
		ptr = ptr + 1 ;

		tmp = (char *)malloc(strlen(ptr) + 1 );
		strcpy(tmp,ptr );

		strcpy(str,tmp);
	
		free( tmp );
	}
}

extern GRcvt_exp_to_wrk();
double conv_factor ;
                  

from_cat_to_work_units(i,des_units,formula)
int i ;
char formula[], des_units[] ;
{
	double a ;

	if( i == 2 ) return ;

	if (strcmp(des_units,"inch") != 0 && strcmp(des_units,"mm") != 0 )
                 return;

	get_conv_factor(des_units);

	sscanf(formula,"%lf",&a);

	sprintf(formula,"%g",a*conv_factor);/*TR#139306576 - changed format from lf to g*/

}

from_work_to_cat_units(i,des_units,formula)
int i ;
char formula[] , des_units[];
{

	double a ;

#ifdef DEBUG
	write("i,des_units,formula: ", i,des_units,formula,"\n");
#endif

	if( i == 2 ) return ;

	if (strcmp(des_units,"inch") != 0 && strcmp(des_units,"mm") != 0 )
                 return;

	get_conv_factor(des_units) ;

	sscanf(formula,"%lf",&a);

	sprintf(formula,"%lf",a / conv_factor);
}

get_conv_factor(des_units)
char des_units[];
{
	IGRlong mesg ;

	GRcvt_exp_to_wrk(&mesg, GRIO_DISTANCE, 2,
                         1.0,des_units,&conv_factor);
#ifdef DEBUG
	write("conv_factor: ", conv_factor, " for units: " , des_units, "\n");
#endif
}


void define_Aoperator(char *ope_str, char *ordering_type)
{

	if( !strcmp ( ope_str, "closest >")){
		glob_rows =1 ;
		strcpy(ope_str,"#>");
	}
	else if(!strcmp(ope_str,"closest <")){
		glob_rows =1 ;
		strcpy(ordering_type," DESC ");
		strcpy(ope_str,"#<");
	}
}

void define_Foperator(ope_str)
char *ope_str  ;
{

	if( !strcmp ( ope_str, "#>"))
		strcpy(ope_str,"closest >");
	else if(!strcmp(ope_str,"#<"))
		strcpy(ope_str,"closest <");
}

input_operator(fp,posi,mcf_row, type)
Form fp;
int posi, mcf_row;
char *type;
{
	int i, status ,max_rows, mcf_flag;
	char *pdwn_txt[10];

	pdwn_txt[0] = "=" ;
	pdwn_txt[1] = ">" ;
	pdwn_txt[2] = "<" ;
	pdwn_txt[3] = ">=" ;	
	pdwn_txt[4] = "<=" ;
	pdwn_txt[5] = "closest >" ;
	pdwn_txt[6] = "closest <" ;
	pdwn_txt[7] = "between" ;

	mcf_flag = 1 ;
	i = 0 ;
	max_rows = 8 ;

	if( strncmp ( type, "char", 4 ) == 0 )
	{ 
		pdwn_txt[8] = " like" ;
		max_rows = 9;
	}

      	pull_main (SPpart_F, fp, TABLE, 
		   posi, OPER_COL,
		   pdwn_txt, max_rows,
                   mcf_flag, 
		   0,
		   max_rows, &status, &i);

	if(status)
            FIfld_set_text(fp, TABLE, mcf_row, OPER_COL, pdwn_txt[i], 1);

	return (1);
}


warn_box(w_message)
char *w_message ;

{
/*	int 	status ;*/

	void warn_notification();

        FI_msg_box("WARNING",FI_YELLOW,w_message,FI_BLACK);


/*
	status = FIf_new ( WARN_F, "MOWarn",warn_notification, &warning_f);
	if ( status ) 
	{	
		fprintf(stderr,"FORM CREATE ERROR %d\n",status );
		return(FALSE);
	}

	FIfld_set_text(warning_f,12,0,0,w_message,TRUE);

	FIf_display ( warning_f) ;
*/
}


void warn_notification(int f_label, int g_label, double value, Form fp)
{
	if(g_label == FI_ACCEPT){
		FIf_erase( warning_f );
		FIf_delete( warning_f );
	}
}


	
	
AddToPuldwnList(char **list_of_vals, int list_len)
	
	/* This routine adds entries from output_string to array if search is
           on common attributes and values are DISTINCT 		     */
{
	if(no_of_param_vals == 0 )
		param_val = (char **)malloc( list_len * sizeof(char *));

	else if( PDU_comm_attribs )
		param_val = (char **)realloc(param_val,(no_of_param_vals+list_len)*
							sizeof(char *));

	while (list_len > 0){
		if(is_a_new_entry(list_of_vals[list_len], param_val, no_of_param_vals)){
	                param_val[no_of_param_vals] = (char *)malloc( strlen(list_of_vals[list_len]) + 1) ;
        	        strcpy(param_val[no_of_param_vals++], list_of_vals[list_len--]);
		}
	}
}


extern MEMptr PDUmacro_lib_list ;

copy_and_load_macro_lib(char *catname)
{

	int  i, err_code, max_rows =1, sts ;
	char **data_ptr, query[256], *output_str,*ptr , *macrocat, *macropartno,*macrorev ;

	_pdm_debug("Entered copy_and_load_macro_lib",0);

	PALstatus_msg(PDR_S_LdLb);

	if( PDUmacro_lib_list ) {

		MEMbuild_array(PDUmacro_lib_list);

		data_ptr  = (char **)PDUmacro_lib_list ->data_ptr ;

		/* check whether catalog entry already exists in buffer */

		for( i = 0 ; i < PDUmacro_lib_list -> rows ;  ++i ) 
			if(!strcmp(data_ptr[i*PDUmacro_lib_list ->columns],catname)){
/* 13941 8047. Begin. */
				if (!attach_macro_lib(data_ptr[i*PDUmacro_lib_list -> columns+4]))
				{
                                  _pdm_debug("Can not attach macro lib", 0);
                                  /* See if mac lib is local. */
                                  if (IsLocalFileDeleted(data_ptr[i*PDUmacro_lib_list -> columns+4]))
                                  {
                                    /* Local file IS deleted, remove entry from PDUmacro_lib_list. */
                                    PDUupdate_copy_macro_lib_bufr(catname);
                                    	_pdm_debug("before PDUget_param_data",0);

					if( (sts = PDUget_param_data(catname ) ) != 
						PDM_S_SUCCESS){
						PALstatus_msg(PDR_E_NoMlib);
						_pdm_debug("Error getting files local\n",0);
						return(0);
					}
					PDUmessage(PDM_E_CLEAR_FIELD, 's');
					_pdm_debug("after PDUget_param_data: SUCCESS",0);
					
					return(1);
                                  }
                                  return(0);
                                }
/* 13941 8047. End. */
                                return(1);
			}

		_pdm_debug("Macro library name %s not in list", catname);

		/* get macro_cat, macro_rev and macro_partno for the given catalog */

		sprintf(query,"select p_macrocat, p_macropartno , p_macrorev from pdmparamloc where n_catalogname = '%s'", 
								catname);

		_pdm_debug(" query for macro lib: %s", query );

		sts = RISquery(query,&max_rows,&output_str,&err_code);

		_pdm_debug("output: %s", output_str);

		if(sts < 0 )
			free( output_str);
		else{
			ptr = strtok(output_str,"~");
	
			macrocat = (char *) malloc(strlen(ptr)+1);
			strcpy(macrocat,ptr);

			ptr = strtok(NULL,"~");
	
			macropartno = malloc(strlen(ptr)+1);
			strcpy(macropartno,ptr);

			ptr = strtok(NULL,"~");

			macrorev = malloc(strlen(ptr)+1);
			strcpy(macrorev,ptr);

			free( output_str);

			for( i = 0 ; i < PDUmacro_lib_list -> rows; ++i ) {
				if(!strcmp(data_ptr[i*PDUmacro_lib_list ->columns+1],macrocat) &&
				!strcmp(data_ptr[i*PDUmacro_lib_list ->columns+2],macropartno) &&
				!strcmp(data_ptr[i*PDUmacro_lib_list ->columns+3],macrorev) ) {
/* 13941 8047. Begin. */
					if (!attach_macro_lib(data_ptr[i*PDUmacro_lib_list -> columns+4]))
					{
                                          _pdm_debug("Can not attach mac lib", 0);
                                  	  /* See if mac lib is local. */
                                          if (IsLocalFileDeleted(data_ptr[i*PDUmacro_lib_list -> columns+4]))
                                          {
                                            /* Local file IS deleted, remove entry from PDUmacro_lib_list. */
                                            PDUupdate_copy_macro_lib_bufr(catname);
                                            	_pdm_debug("before PDUget_param_data",0);

						if( (sts = PDUget_param_data(catname ) ) != 
							PDM_S_SUCCESS){
							PALstatus_msg(PDR_E_NoMlib);
							_pdm_debug("Error getting files local\n",0);
							return(0);
						}
						PDUmessage(PDM_E_CLEAR_FIELD, 's');
						_pdm_debug("after PDUget_param_data: SUCCESS",0);
						
						return(1);
                                          }
                                          return(0);
                                        }
/* 13941 8047. End. */
					_pdm_debug( "Found match in PDUmacro_lib_list",0);

					free(macrorev);
					free(macrocat);
					free(macropartno);
					PDUmessage(PDM_E_CLEAR_FIELD, 's');
					return(1);
				}
			}

			free(macrorev);
			free(macrocat);
			free(macropartno);
		}
	}				
	
	/* This function will determine the macro_cat, macro_part and macro_rev
           based on catalog name and copy all files associated with this part to
           local directory and any files copied local with file type 'cpio' will
           be unbundled and all macro libraries attached and add the new entry
           in PDUmacro_lib_list buffer 
	*/

	_pdm_debug("before PDUget_param_data",0);

	if( (sts = PDUget_param_data(catname ) ) != 
		PDM_S_SUCCESS){
		PALstatus_msg(PDR_E_NoMlib);
		_pdm_debug("Error getting files local\n",0);
		return(0);
	}
	PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug("after PDUget_param_data: SUCCESS",0);

	return(1);

}


GetValsForAttribs(Form fp, int glabel, int col)

	/* Routine to get values of all attributes given part no, part revision
           and catalog
	*/
{
	int max_rows = 1 , err_code , sts, alloc_size = 1024 , i ;
	char *query, *outstr, *ptr, tmpstr[128] ;

	if( !refresh -> rev_revision )
		return(0);

	query = malloc( alloc_size );

	strcpy(query,"select ");

	for( i = 0 ; i < NumAttribs ; ++i ) {

		strcpy( tmpstr, AttrList[i] );

		if( i < NumAttribs - 1 )
			strcat( tmpstr," , ");

		if( strlen(query) + strlen(tmpstr) + 1 > alloc_size ){

			alloc_size = strlen(query) + strlen(tmpstr) + 1 + 64;

			query = realloc(query,alloc_size);
		}

		strcat(query,tmpstr);
	}

	sprintf(tmpstr," from %s where n_itemname='", refresh -> rev_catalog);

	if( strlen(query) + strlen(tmpstr) + 1 > alloc_size ){

		alloc_size = strlen(query) + strlen(tmpstr) + 1 + 128;

		query = realloc(query,alloc_size);
	}

	strcat(query,tmpstr);

	sprintf(tmpstr,"%s' and n_itemrev='", refresh -> rev_partid);

	if( strlen(query) + strlen(tmpstr) + 1 > alloc_size ){

		alloc_size = strlen(query) + strlen(tmpstr) + 1 + 128;

		query = realloc(query,alloc_size);
	}

	strcat(query,tmpstr);

	sprintf(tmpstr,"%s'", refresh -> rev_revision);
				
	if( strlen(query) + strlen(tmpstr) + 1 > alloc_size ){

		alloc_size = strlen(query) + strlen(tmpstr) + 1 + 128;

		query = realloc(query,alloc_size);
	}

	strcat(query,tmpstr);

	sts = RISquery(query,&max_rows,&outstr,&err_code);

	if( sts < 0 ) {
		free(outstr);
		RIS_box(err_code);
		return(0);
	}

	free( query );
	ptr = strtok(outstr, "~");
	i = 0;
	while(ptr != NULL ){

/* TR # 1393 08999.	Avoid 'nil' or 'NULL'.	*/
		if ((!strcmp (ptr, "nil")) || (!strcmp (ptr, "NULL")))
			FIfld_set_text(fp,glabel,i,col,"",FALSE);
		else
			FIfld_set_text(fp,glabel,i,col,ptr,FALSE);

		++i ;
		ptr = strtok(NULL,"~");

	}

	free(outstr);
	return(1);			
}



SetCatAttribs(Form fp, int glabel)

	/* Having selected a catalog get attribute list and update form  */
{
	int  tbl_no , i ;

	/* Get n_tableno for the catalog */
	if( ! GetCatTableNo(refresh -> rev_catalog,&tbl_no,ViewOrTblList[0]))
		return(0);

#ifdef DEBUG
	printf(" Numattribs %d table no %d\n", NumAttribs, tbl_no );
#endif

	if( NumAttribs != 0 ) {
		FreeArrayPtr(AttrList,NumAttribs);
		FreeArrayPtr(AttrSynonym,NumAttribs);
		FreeArrayPtr(AttrTypes,NumAttribs);
		NumAttribs = 0 ;
	}

	/* Query nfmattributes table for attributes given table no. */
	if( ! GetCatAttribs(tbl_no,&AttrList,&AttrSynonym, &AttrTypes,&NumAttribs))
		return(0);

	_pdm_debug("After get catalog attributes %d",NumAttribs);

        /*  MJG - check AttrSynonym for nil values */
        for (i = 0; i < NumAttribs; ++i)
           if (strcmp(AttrSynonym[i], "nil") == 0)
             strcpy(AttrSynonym[i], "");

	display_attribs(fp,glabel,NumAttribs,AttrSynonym,AttrList);

    return(1);

}


display_attribs(Form fp,int glabel,int numattr, char **attrsyn, char **attrlst)
{
	/* Display the attribute synonyms (description ) in the first column
           of MCF
	*/

	int i ;

	FIg_reset(fp,glabel);
	FIg_reset(fp,PART_INDEX); /* TR#139307974 */
	/* TR#139306730,31,32 */
	FIg_disable(fp, SAVE_CRT );
	FIg_disable(fp, PLUS );
	FIg_disable(fp, MINUS );
	FIg_disable(fp, EXP_LIST );

	for( i = 0 ; i < numattr ; i = i + 1 ){
		if( (strlen(attrsyn[i]) > 1) && strcmp( attrsyn[i],"nil" ) )
			FIfld_set_text(fp,glabel,i,0,attrsyn[i],FALSE);
		else
			FIfld_set_text(fp,glabel,i,0,attrlst[i],FALSE);

		FIfld_set_text(fp,glabel,i,SEARCH_COL,"",FALSE);
		FIfld_set_text(fp,glabel,i,DATA_COL,"",FALSE);
	}

}

puldwn_menu(mcf_or_not, list_len, display_len, form, g_label, list, ndx)
Form	form;
int 	*ndx, g_label, list_len, mcf_or_not, display_len;
char 	*list[];
{
      	/* for given text list, this function displays a 
	   pull down list and returns the index selected */

      	int 		sts;

      	if (list_len < 14)
		display_len = list_len;
      	else
		display_len = 13;

      	pull_main (SPpart_F, form, g_label, 
		   ATTR_COL, ATTR_COL,
		   list, list_len,
                   mcf_or_not, 
		   0,
		   display_len, &sts, ndx);

      	return(sts);
}

extern int PALsavecrit;

gname_notif(int f_label,int g_label,double value,Form fp)
{
int status;
int i;
int list_size;
int list_row;
MEMptr ret_bufr;
char   **ret_data = NULL;
        switch(g_label){

                case LIST_BTN:
 
                status = PDUlist_report_buffer(CAT_SEARCH_LIST, &ret_bufr);
                _pdm_status("PDUlist_report_buffer", status);
                if (status != PDM_S_SUCCESS)
                  return(0);
                else if (ret_bufr == NULL || ret_bufr->rows == 0 )
		{
		  PDUmessage(PDM_E_NO_CRITERIA_DEFINED, 's');/* TR#139308858 */
                  return(0);
		}

                status = MEMbuild_array(ret_bufr);
                _pdm_status("MEMbuild_array", status);
                if (status != MEM_S_SUCCESS)
                  return(0);

                ret_data = (char **)ret_bufr->data_ptr;
                for (i = 0; i < ret_bufr->rows; i++)
                  PDUfill_in_string(&PDU_value_list[i], ret_data[i]);
                list_size = ret_bufr->rows;

	        FIfld_set_max_num_rows(fp, 14,list_size);

	        GRcreate_pull_down_list(102, fp,14,
                         list_size,8,PDU_value_list, 0,1,
                         &PDU_value_pulldown);

                GRchange_pull_down_text(PDU_value_pulldown, PDU_value_list, 
                                        list_size);
                GRproc_pull_down_list(PDU_value_pulldown);
                return(0);

                case 14:
                        list_row = value - 1;
                        FIg_set_text(fp,KEYIN_FIELD,PDU_value_list[list_row]);
			/*FIg_set_state_off( fp, LIST_BTN);*/
                        return(0);
                     
		case KEYIN_FIELD: /* TR#1393 07715 */
                    if( !Get_text( fp, KEYIN_FIELD, 0, 0 ) )
                        return(0);
        	    if( !PALsavecrit ) /* Restore Criteria */
		    {
			/* Validate the criteria name keyedin */
	                status = PDUlist_report_buffer(CAT_SEARCH_LIST, &ret_bufr);
                        _pdm_status("PDUlist_report_buffer", status);
                        if (status != PDM_S_SUCCESS)
                          return(0);
                        else if (ret_bufr == NULL || ret_bufr->rows == 0 )
        		{
	        	  PDUmessage(PDM_E_NO_CRITERIA_DEFINED, 's');
                          FIf_erase(fp);
                          return(0);
        		}

                        status = MEMbuild_array(ret_bufr);
                        _pdm_status("MEMbuild_array", status);
                        if (status != MEM_S_SUCCESS)
                          return(0);

                        ret_data = (char **)ret_bufr->data_ptr;
                        for (i = 0; i < ret_bufr->rows; i++)
                            if( !strcmp( ret_data[i], s_text ))
                                break;
                        if( i == ret_bufr->rows )                
                        {
                            PDUmessage( PDM_E_CRT_DOESNT_EXIST, 's');
                            FIg_set_text( fp, KEYIN_FIELD, "" );
                        }
                    }
                    else /* Save Criteria */  /* TR#139307053 */
                    {
			remove_blanks( s_text );
			FIg_set_text( fp, KEYIN_FIELD, s_text );
		    }
                    break;
                case FI_CANCEL:
                        GRdelete_pull_down_list(PDU_value_pulldown);
                        Restore_save_load_buttons(cur_form_f);
                        FIf_delete(fp);
                        return(0);

                case FI_ACCEPT:
                        GRdelete_pull_down_list(PDU_value_pulldown);
                        FIf_erase(fp);
                        if( Get_text(fp,11,0,0)) {
                                _pdm_debug("search_name: ", s_text);
                                if( PALsavecrit )
                                        SaveCriteria(cur_form_f,s_text,NumAttribs);
                                else
                                        RestoreCriteria(cur_form_f,s_text,NumAttribs);
                        }
                        FIf_delete(fp);
                        return(0);
        }
	return(1);
}

GetSelectedRow(Form fp,int glabel,int *srow)
{
	int pos, row ;

	_pdm_debug( "max_rows_rtvd = %d", max_rows_rtvd );

	if( max_rows_rtvd == 0 )
		return(0);

        for(row = 0 ; row < max_rows_rtvd ; ++row ){
                FImcf_get_select ( fp, glabel, row, &pos );

	_pdm_debug("row selection mode: %d", pos );

               if( pos )
 	              break;
        }
        if( row == max_rows_rtvd )
               --row ;

	*srow = row ;

	return(1);
}

set_sub_form_params_for_union(fp, parameters, lcl_bufr, flag)
Form    fp ;
int     parameters, flag ;
MEMptr  lcl_bufr;
{

       int i ;
       char ** cat_attr = NULL;
       int index;

        _pdm_debug("In the function set_sub_form_params_for_union", 0);

        if (PDMdebug_on)
          MEMprint_buffers("lcl_bufr", lcl_bufr, PDU_DEBUG_FILE);

       _pdm_debug("calling insert_additional_columns", 0);
       if (lcl_bufr)
         insert_additional_columns(fp,parameters, lcl_bufr->columns + flag);
	 _pdm_debug("Returned from insert_add_columns,Numattrs = %d",lcl_bufr->columns);

        if(lcl_bufr)
          {
           MEMbuild_array(lcl_bufr);
           cat_attr = (char **) lcl_bufr->column_ptr;
          }

       if( flag )
         {
         _pdm_debug("setting Catalog text on form", 0);
         FIfld_set_text(fp,parameters,0,0,"Catalog",FALSE);
         }

       _pdm_debug("lcl_bufr->columns = %d", (char *)lcl_bufr->columns);

       for (index = 0; index < NumAttribs; ++index)
          _pdm_debug("Synonym= %s", AttrSynonym[index] );

       if (lcl_bufr)
         {
         _pdm_debug("setting attribute text on form", 0);
         for( i = flag + 1 ; i < lcl_bufr->columns + 1; i = i + 1 )
          {
               if (flag)
                 {
                 if (AttrSynonym[i-2] && (strlen(AttrSynonym[i-2])))
                   {
                   FIfld_set_text(fp,parameters,0,i-1, AttrSynonym[i-2], FALSE);
                   _pdm_debug("Attriblist= %s", AttrSynonym[i-2] );
                   }
                 else
                   {
                   _pdm_debug("Attriblist= %s", cat_attr[(i - 1)] );
                   FIfld_set_text(fp,parameters,0,i-1,cat_attr[(i - 1)],FALSE);
                   }
                 }
               else
                 {
                 if (AttrSynonym[i-1] && (strlen(AttrSynonym[i-1])))
                   {
                   FIfld_set_text(fp,parameters,0,i-1, AttrSynonym[i-1], FALSE);
                   _pdm_debug("Attriblist= %s", AttrSynonym[i-1] );
                   }
                 else
                   {
                   _pdm_debug("Attriblist= %s", cat_attr[i] );
                   FIfld_set_text(fp,parameters,0,i-1, cat_attr[i], FALSE);
                   }
                 }
          }
        }
        _pdm_debug("exiting set_sub_form_params_for_union", 0);
}

set_table_field_for_union_or_format(Form fp, char **table_names, int glabel, 
		int starting_row, MEMptr data_bufr)

/* Formats the data on fp from output_string
   Displays the records in the multicolumn fields of sub form     */

{
	char *value ;
	char **data_ptr ;
	short i ;
	int col, start_col;
        long status;

        _pdm_debug("in the function set_table_field_for_union_or_format", 0);

        _pdm_debug("starting row = %d", (char *)starting_row);
        _pdm_debug("NumCatalogs = %d", (char *)NumCatalogs);

         status = MEMbuild_array(data_bufr);
          if(status != MEM_S_SUCCESS)
           {
        _pdm_debug("MEMbuild_array failed status = %d", (char *)status);
            return(0);
           }

	/* set in select mode */
	if(starting_row == 0 ) {
		/* Create additional columns if required */
                if (NumCatalogs == 1)
                insert_additional_columns(fp,glabel,data_bufr -> columns );
                else
                insert_additional_columns(fp,glabel,data_bufr -> columns+1 );

		for( i = 0 ; i < data_bufr -> columns+1  ; i = i + 1  ) 
        		FIfld_set_mode(fp,glabel,i,FI_SINGLE_SELECT);

		FImcf_set_select(fp,glabel,0,1); 
		sel_row = 0 ;
	}

	/* set multicolumn fields */
/*
	if(NumCatalogs > 1 )
		start_col = 1 ;
	else
*/
		start_col = 0 ;

        _pdm_debug("setting up data_bufr", 0);
	data_ptr = (char **)data_bufr -> data_ptr ;

	for( i = 0 ; i < data_bufr -> rows ; ++i )
           {
	   if ( NumCatalogs > 1)
             {
	     value = data_ptr[i * (data_bufr -> columns) + 0];
	     _pdm_debug("catalog value = %s",value);
	     if( strcmp(value ,"nil") != 0 ) 
	       FIfld_set_text(fp, glabel, starting_row+i, 0, value,0);
             }

	   for(col = start_col ; col < data_bufr -> columns ; col = col + 1  )
              {
	      value = data_ptr[i * (data_bufr -> columns) + col - start_col];
	      _pdm_debug("value = %s",value);
	      if( strcmp(value ,"nil") != 0 ) 
	        FIfld_set_text(fp, glabel, starting_row+i, col, value,0);
	      }
	    }

        _pdm_debug("after setting text on exp form", 0);

/* Check the first row, col by col to see if the ID is of 'Compute ID' type 
	if( NumCatalogs == 1 ){
		for (col = 0; col < data_bufr -> columns ; col = col + 1){
			if (!Get_text (fp, glabel, 0, col)) return (0);
			if (!strncmp (s_text, "C:", 2)){
				PDU_ComputedID = TRUE;
				break;
			}
		}
		if ( col == data_bufr -> columns) {  Computalble ID not found 
			PDU_ComputedID = FALSE;			
			return (1);
		}
		ComputeID (fp,glabel,col, s_text, starting_row);
	}
*/
        _pdm_debug("Exit -  set_table_field_for_union_or_format", 0);
	return(1);
}

/* 13941 8047. */
/*
 * This function finds out if a given file is local.
 */

IsLocalFileDeleted(char *filename)
{
  long    status = PDM_S_SUCCESS;
  char    local_files_path[256];
  char    full_name[256];
  struct  stat file_status;
  extern struct PDUuser	*user;

  /* Construct local files full path */
  strcpy(local_files_path, user->wrkst_cwd);
  strcat(local_files_path, "/");
  _pdm_debug("local files full path = <%s>", local_files_path);

  sprintf(full_name, "%s%s", local_files_path, filename);
  status = stat(full_name, &file_status);
  if (status == 0)
  {
    _pdm_debug("file <%s> exists locally", full_name);
    return(0);
  }
  else
  {
    _pdm_debug("file <%s> does not exist locally", full_name);
    return(1);
  }
}

/* TR# 139419562. New functions added.	25/may/94 - raj.	*/

int PDUcreate_dynamic_data_bufr ( dynamic_data_bufr )
MEMptr *dynamic_data_bufr;
/*
 * This function creates a buffer to be used for default
 * values of dynamic attributes. It contains the following columns:
 *	n_name		char(20)
 *	n_datatype	char(20)
 *	n_synonym	char(40)
 *	n_value		char(40)
 *
*/
{

    MEMptr	attr = NULL;
    char	s[128];
    long	status;

    _pdm_debug("Enter PDMcreate_dynamic_data_bufr",0);

    *dynamic_data_bufr = NULL;

    status = MEMopen( &attr, PDM_BUFFER_SIZE );
    if( status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        sprintf (s, "%s %d",
        "MEMopen failed status ", status);
        _pdm_debug("%s", s);
        return( status );
    }

    status = MEMwrite_format( attr, "n_name", "char(32)" );
    if( status != MEM_S_SUCCESS)
      goto wrapup;

    status = MEMwrite_format( attr, "n_datatype", "char(32)" );
    if( status != MEM_S_SUCCESS)
      goto wrapup;

    status = MEMwrite_format( attr, "n_synonym", "char(40)" );
    if( status != MEM_S_SUCCESS)
      goto wrapup;

    status = MEMwrite_format( attr, "n_value", "char(40)" );
    if( status != MEM_S_SUCCESS)
      goto wrapup;

    *dynamic_data_bufr = attr;

    _pdm_debug("Exit PDMcreate_dynamic_data_bufr",0);

    return(status);

wrapup:
    /* Failure.	*/
    MEMclose( &attr );
    sprintf (s, "%s %d",
    "MEMwrite_format failed status ", status);
    _pdm_debug(s);
    status = PDM_E_WRITE_FORMAT;

    _pdm_debug("Exit PDMcreate_dynamic_data_bufr",0);

    return( status );
}

int PDUwrite_dynamic_data_bufr(dynamic_coll, dynamic_attr_bufr, dynamic_data_bufr)
MEMptr dynamic_attr_bufr, *dynamic_data_bufr;
struct GRid *dynamic_coll;
/*
 * This function makes up a buffer with values for dynamic attributes.
 * For each attribute in the input buffer of attributes, it gets the
 * values from the dynamic collection and writes it to the buffer.
 */
{
  char	**attr_ptr, row_to_add[256], *value;
  int	cols, i, alloc_size;
  long	sts;

  _pdm_debug("Enter PDUwrite_dynamic_data_bufr", 0);
  _pdm_debug("Dynamic collection id: <%d>", dynamic_coll->objid);  

  if (dynamic_attr_bufr)
  {
    if (sts = MEMbuild_array(dynamic_attr_bufr) != MEM_S_SUCCESS)
    {
      _pdm_debug("MEMbuild_array_error: status = %d",sts );
      return(0);
    }
    if(PDMdebug_on)
      MEMprint_buffer( "dynamic_attr_bufr: ", dynamic_attr_bufr, PDU_DEBUG_FILE );
  }
  else
  {
    _pdm_debug("dynamic_attr_bufr is NULL");
    return(1);
  }
  
  attr_ptr	= (char **) dynamic_attr_bufr->data_ptr ;
  cols		= dynamic_attr_bufr->columns;  

  for( i = 0 ; i < dynamic_attr_bufr->rows; ++i )
  {
    _pdm_debug("attribute name    : <%s>", attr_ptr[(cols * i)]);
    _pdm_debug("attribute type    : <%s>", attr_ptr[(cols * i) + 1]);
    _pdm_debug("attribute synonym : <%s>", attr_ptr[(cols * i) + 2]);
    
    /* Get attribute value from dynamic collection.	*/
    alloc_size = 32;
    value = malloc(alloc_size);
    if(!value)
    {
      _pdm_debug("Unable to allocate memmory", 0);
      return(0);
    }
    value[0] = '\0' ;
    if(!GetACrgAttribVal(dynamic_coll, attr_ptr[(cols * i)], &value, &alloc_size))
        return(0);
    value[strlen(value)-1]= '\0';
    _pdm_debug("value: <%s>", value);
    
    /* make up string with attribute's name, type, synonym and default value.	*/
    strcpy(row_to_add, attr_ptr[(cols * i)]);
    strcat(row_to_add, "\1");
    strcat(row_to_add, attr_ptr[(cols * i) + 1]);
    strcat(row_to_add, "\1");
    strcat(row_to_add, attr_ptr[(cols * i) + 2]);
    strcat(row_to_add, "\1");
    strcat(row_to_add, value);
    strcat(row_to_add, "\1");
    
    free(value);
    
    _pdm_debug("Add to data buffer : <%s>", row_to_add);
    
    if( (sts = MEMwrite(*dynamic_data_bufr, row_to_add)) != MEM_S_SUCCESS)
    {
      _pdm_debug("MEMwrite Error : status %d\n",sts);
      MEMclose(dynamic_data_bufr);
      return(0);
    }
    
    _pdm_debug("%d row added to data buffer", i);
  }
  
  _pdm_debug("Completed adding rows to data buffer", 0);

  if(dynamic_data_bufr && PDMdebug_on)
    MEMprint_buffer( "dynamic_data_bufr : ", *dynamic_data_bufr, PDU_DEBUG_FILE );

  _pdm_debug("Exit PDUwrite_dynamic_data_bufr", 0);
  
  return(1);
}

/* TR# 139419562. End of New functions. 25/may/94 - raj.	*/

