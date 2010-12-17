#include <stdio.h>
#include <malloc.h>
#include "FIdyn.h"
#include "PALmsg.h"
#include "PALglbs.h"
#include "PDUstr.h"
#include "MEMerrordef.h"
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"

/*#include "PDUproto.h" */
#include "PALfunkpro.h"
#include "PALpdmrpro.h"

char *s_text ;
static int  text_size = 0;

extern char **	AttrList ;
extern char **	AttrSynonym;
extern char **	AttrTypes ;
extern  int	NumAttribs ;
extern  int	no_of_param_vals ;
extern  int	NoSlctd ;
extern  int	NumCatalogs;
extern  int	MacroDisplayed;
extern  struct  PDUrefresh *refresh;
extern MEMptr PDU_dyn_attr_bufr;
extern Form     ModifyPartForm;
extern Form     place_part_f;
extern int 	PDU_cat_selected ,PDU_comm_attribs ;
extern char     PDM_old_dir[];

/*	17/may/94 - raj.	*/
extern	char	**AttrValsRep_PPart;

remove_blanks(char *st)
{

	/* This routine remove ALL blanks from a given string */

	int i , j ;
	char *temp_st ;

	j = 0 ;

	temp_st = (char *)malloc(strlen(st) + 1);

	for( i = 0 ; st[i] != '\0' && st[i] != '\n' ; i=i+1 ) 
		if( st[i] != ' ' ) {
			temp_st[j] = st[i] ;
			j = j + 1  ;
		}

	temp_st[j] = '\0' ;
	strcpy(st,temp_st);

	free( temp_st );
}

Get_text(Form fp, int g_lable, int trow, int tcol)

	/* Routine to get text (if any) from a given gadget ( row and col in case
	   of MCF) .   Returns 1 if found any text else 0

	   The text is stored in a global char pointer 's_text', whose memory is
	   allocated dynamically on need basis.
	*/

{
	int text_len, row_position ;
	int select_flag;


	FIfld_get_text_length ( fp, g_lable, trow, tcol, &text_len );

	if( text_len < 2 ) 
		return(0);

	text_len = text_len + 1 ;

	if( text_size == 0  )
		s_text = (char *)malloc(text_len + 1 );
	else if (text_size < text_len )
		s_text = (char *)realloc(s_text, text_len + 1  );

	text_size = text_len ;
	
	FIfld_get_text ( fp, g_lable, trow, tcol, text_len,
                     (unsigned char *) s_text, &select_flag, &row_position );

	return(1);
}

pull_down(Form fp, int form_no, int mcf_label, int mcf_row, int mcf_col,
	 int out_col, char **param_val, int no_of_entries, int pos, int *status)

{
	/* Displays list of  values in a pull down menu. The value 
	   selected will be displayed in the gadget.
	*/

	int i, max_rows, mcf_flag;

	mcf_flag = 1 ;
	i = 0 ;
	max_rows = 11 ;

	pull_main(form_no, fp, mcf_label, pos, 0, param_val, no_of_entries,
                               mcf_flag, 0, max_rows, status, &i );

	if(*status)
        /* Changed by kumar for KK 061593 
       	FIfld_set_text(fp, mcf_label, mcf_row, out_col, param_val[i], 1);
        */
        {
         /* If user selects NULL from list, do not display anything. */
          if (strcmp(param_val[i], "NULL"))
       	FIfld_set_text(fp, mcf_label, mcf_row, out_col, param_val[i], 1);
         }

}

add_quotes(char *str)
	         /* Adds ' ' (quotes) to string */
{
	char *tem ;
	int i ;

	if( str[0] == '\'')return ;

	tem = (char *) malloc(strlen(str) + 5 );

	tem[0] = '\'' ;

	for( i = 0 ; str[i] != '\0' ; i = i + 1 ) 
		tem[i+1] = str[i] ;

	tem[i+1] = '\'' ;
	tem[i+2] = '\0' ;

	strcpy(str,tem);

	free(tem);
}


char *to_lower(char *st)
{
        /* this function converts a string from upper to lower case */

	int i ;

	for(i=0 ; st[i] != '\0' ; ++i )
		st[i] = tolower(st[i]) ;

	return(st);
}

insert_additional_columns(Form fp, int glabel, int tot_num)

	/* This routine inserts additional columns in a MCF DYNAMICALLY
	   if tot_num of columns required > existing no. of columns

	*/
{

	int num_cols, i;
	long	attr_mask;

	FImcf_get_num_cols(fp,glabel,&num_cols);
	
        if( num_cols >= tot_num )
                {
                for (i = (tot_num - 1); i < num_cols; i++)
                   FImcf_delete_col(fp, glabel, tot_num);
                return(1);
                }

	/* Get attribute mask of first column and set all attribute
	   mask of all the new columns added to this 
	*/

	FIfld_get_attr(fp,glabel,0,&attr_mask);


	_pdm_debug("columns to be added %d", tot_num - num_cols );

        for( i = num_cols ; i < tot_num ; i = i + 1 ){

                FImcf_insert_col(fp, glabel, i,10,FI_REVIEW,FI_ALPHA);
                FIfld_get_attr(fp,glabel,i,&attr_mask);
                attr_mask = attr_mask | FI_DISPLAY_HSCROLL;
                FIfld_set_attr(fp,glabel,i,attr_mask);
        }

	return(1);	
}




add_level_button(Form fp, int ind, int *lab)

	/* Adds a button gadget next to current button */
{

	float bodysize ;
	double x,y ;
        char *temp = NULL;
	char tmp[5], TTfontname[15] ;
	struct standard_st param ;

	/* Get previous label's location. 1st button always present  */
	FIg_get_dlocation(fp,lab[ind-2],&x,&y);

	FIf_get_next_label(fp,&lab[ind -1]);

	FIg_new(fp,FI_BUTTON,lab[ind-1 ]);

	param.xlo = x+30   ; param.ylo = y ;

	param.xhi = param.xlo+30 ; param.yhi = y + 30 ;

	param.attr_mask = FI_TEXT_GADGET; 

	param.value = 0 ;

	FIg_get_font(fp,lab[ind-2],TTfontname,&bodysize); 
/*	strcpy(TTfontname,"swiss742b");‚ */

	_pdm_debug("fontname: %s", TTfontname );

	param.bodysize = bodysize  ;
	param.off_color = FI_BLACK ;
	param.on_color  = FI_WHITE ;

	param.fontname = TTfontname ;

	sprintf(tmp,"L%d",ind);
        PDUfill_in_string(&temp, tmp);

	param.text =  temp ;
	param.help_topic =  NULL ;
	param.command =  NULL ;
	param.user_pointer =  NULL ;

	FIg_set_standard_variables(fp,lab[ind-1],&param);

	FIg_activate(fp,lab[ind-1]);

	FIg_display(fp, lab[ind-1]);
}


is_a_new_entry(char *entry, char **ent_list, int ent_no)

	/* Checks whether 'entry' already exists in the array 'ent_list'
	   of size 'ent_no'. If found return 0 else return 1
	*/
{

	int i;
		
	for( i = 0 ; i < ent_no ; i = i + 1 ) {

		if( !strcmp(ent_list[i],entry))
			return(0);
	}

	return(1);
}


FreeArray(char **text_array, int no_rows)

	/* This routines frees memory allocated to list of char pointers */	
{
	int i;
	
	for( i = 0 ; i < no_rows ; i = i + 1 )
		if( text_array[i] != NULL )
			free( (char *) text_array[i] );

	if( text_array != NULL ) {
		free( (char *) text_array );
		text_array = NULL ;
	}

}

FreeArrayPtr(char **ary_list, int arsize)

	/* Free array of char * and char ** also  */
{
	int i ;

	for( i = 0 ; i < arsize ; i= i + 1 )
		if(ary_list[i] != NULL ) 
			free( (char *)ary_list[i]);

	if( ary_list != NULL ){
		free( (char *)ary_list);
		ary_list = NULL ;
	}
}

remove_brackets(str)
char str[];

{
    int i ;
    char *tmp;

    tmp = (char *)malloc(strlen(str) + 1 );

    for( i = 0 ; str[i] != '\0' && str[i] != '(' && str[i] != '='; i = i + 1 ) 
        tmp[i] = str[i] ;

    tmp[i] = '\0' ;

    strcpy(str,tmp);

    free( tmp);
}

RIS_box( err_code )
int err_code ;

{
      int msgnumb ;


      switch( err_code ) {
   
               case -1 :
                        msgnumb = PDR_E_InvldIDat ;
                        break;
 
               case -2 :
                        msgnumb = PDR_E_InvldODat ;
                        break ;
 
               default :
                        msgnumb = PDR_E_RisErr ;
                        break;
       }

	FlashMessage (msgnumb);


}



PALglbs_init()
{
	AttrList = NULL;
	AttrSynonym = NULL;
	AttrTypes = NULL;
	NumAttribs = 0;
	no_of_param_vals = 0;
	NoSlctd = 0;
	NumCatalogs = 0;
	MacroDisplayed = 0;
	refresh->cat_path = NULL;
	PDU_dyn_attr_bufr = NULL;
	ModifyPartForm = NULL;
	place_part_f = NULL;

	PDU_cat_selected = FALSE ;
	PDU_comm_attribs = FALSE ;

	PDM_old_dir[0] = '\0';

	/*	17/may/94 - raj.	*/
	AttrValsRep_PPart = NULL;

	init_selprt();
}

format_column(in_buffr, col_name, col_type)
MEMptr *in_buffr ;
char *col_name , *col_type ;
{

	long sts ;

	/* define column n */
	if( (sts = MEMwrite_format(*in_buffr,col_name,col_type)) != MEM_S_SUCCESS){
		_pdm_debug("MEMwrite_format Error : status %d",sts);
		MEMclose(in_buffr);
		return(0);
	}

	return(1);
}
