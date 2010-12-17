#include	<string.h>
#include	<ctype.h>
#include	<time.h>
#include 	"PALglbs.h"
#include	<OMlimits.h>
#include	<PDUintdef.h>
#include	<PDUint.h>
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif

#include	<igrtypedef.h>
#include	<exdef.h>
#include        <MEMerrordef.h>
#include        <PDUforms.h>
#include        <PDUfile_def.h>
#include        <PDUuser.h>
#include        <sys/types.h>
#include        <sys/stat.h>
#include 	"PDUstr.h"
#include 	"PDUstorage.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"


/*#include "PDUproto.h" */
#include "PALfunkpro.h"
#include "PALpdmrpro.h"




extern MEMptr PDU_func_buffer;
extern MEMptr PDU_dyn_data_bufr;
extern MEMptr PDU_dyn_attr_bufr;
extern MEMptr PDU_dyn_value_bufr;
extern struct PDUstorage *storage;
extern char   PDU_attr_value[]; 
extern char   *PDU_value_list[605];
extern char *s_text ;

PALretrieve_dyn_info(char *catalog, char *partid, char *partrev)
{

	int sts ;
	char *p_explode = NULL ;

	if (PDU_dyn_attr_bufr)
		MEMclose(&PDU_dyn_attr_bufr);

	if (PDU_dyn_data_bufr)
		MEMclose(&PDU_dyn_data_bufr);

	if (PDU_dyn_value_bufr)
		MEMclose(&PDU_dyn_value_bufr);

	sts = PDMquery_dynamic_attrs(catalog, partid,partrev, &PDU_dyn_attr_bufr,
                                 &PDU_dyn_data_bufr, &PDU_dyn_value_bufr,
                                 &p_explode);
	_pdm_status("PDMquery_dynamic_attr", sts);

	if (sts != PDM_S_SUCCESS)
		return(sts);

	if (PDU_dyn_attr_bufr)  {

		_pdm_debug("dynamic attributes were defined", 0);
		if (PDU_func_buffer)
			MEMclose(&PDU_func_buffer);

		sts = PDMmove_functions(catalog, storage->storage_name,
                             &PDU_func_buffer);

		_pdm_status("PDMmove_functions", sts);

		if ((PDU_func_buffer) && (PDM_debug_on))
		MEMprint_buffer("functions buffer", PDU_func_buffer, PDU_DEBUG_FILE);
	}

	return(sts);
}

int PALset_attribute_type(no_dyn_attr,dyn_attr_list, dyn_attr_desc,
						dyn_star_type, fp, glabel, start_row)
int no_dyn_attr ;
char **dyn_attr_list, **dyn_attr_desc;
int dyn_star_type[] ;
Form fp;
int glabel, start_row  ;
{
  int sts, i,j;
  char **attr_data = NULL;
  char **data_data = NULL;
  char **func_data = NULL;
  char string[170];
  int  n_attr_col,cnt;
  int  num_rows = 0;
  int FOUND = FALSE;
  char buff[100];

	sts = MEMbuild_array(PDU_dyn_attr_bufr);
	_pdm_status("MEMbuild_array(PDU_dyn_attr_bufr)", sts);

	if (sts != MEM_S_SUCCESS)
		return(PDM_E_BUILD_BUFFER_ARRAY);

	sts = MEMbuild_array(PDU_dyn_data_bufr);
	_pdm_status("MEMbuild_array(PDU_dyn_data_bufr)", sts);

	if (sts != MEM_S_SUCCESS)
		return(PDM_E_BUILD_BUFFER_ARRAY);

	attr_data = (char **) PDU_dyn_attr_bufr->data_ptr;
	data_data = (char **) PDU_dyn_data_bufr->data_ptr;

	_pdm_debug("PDU_dyn_attr_bufr->rows = <%d>", PDU_dyn_attr_bufr->rows);

	n_attr_col = PDU_DYN_WRITE_COL;

	for( i = 0 ; i < no_dyn_attr ; ++i )
		dyn_star_type[i] = 0 ;
    
	for (i = 0; i < no_dyn_attr ; i++)  {

		if( !PALget_coresp_col_indx(dyn_attr_list[i],&cnt))
			continue;

		_pdm_debug("found attribute in buffer: %d",cnt );

		if (strcmp(data_data[(PDU_dyn_data_bufr->columns * cnt) + 
                    PDU_DYN_LISTNO_COL], "") != 0)
                  {
		  dyn_star_type[i] = 2 ;/* assoc pull down list */
		  sprintf(string,"*%s", dyn_attr_desc[i]);
		  FIfld_set_text(fp,glabel,start_row+i,1,string, FALSE);
		 }
                else if ((strcmp(data_data[(PDU_dyn_data_bufr->columns * cnt) + 
                         PDU_DYN_MIN_VAL_COL], "") != 0) ||
                         (strcmp(data_data[(PDU_dyn_data_bufr->columns * cnt) + 
                         PDU_DYN_MAX_VAL_COL], "") != 0))
                  {
                  sprintf(string,"%s", dyn_attr_desc[i]);
                  sprintf(buff, "(min: %s ,  max: %s)",
                          data_data[(PDU_dyn_data_bufr->columns * cnt) + 
                          PDU_DYN_MIN_VAL_COL], 
                          data_data[(PDU_dyn_data_bufr->columns * cnt) +
                          PDU_DYN_MAX_VAL_COL]);
                  strcat( string, buff );
                   _pdm_debug("string = <%s>", string);
                  FIfld_set_text(fp, glabel, start_row+i, 1, string, FALSE);
                  dyn_star_type[i] = 3 ;
                  }
		else if(!strcmp(data_data[(PDU_dyn_data_bufr->columns * cnt) + 
                  PDU_DYN_LISTNO_COL], "")
          	     && (PDU_func_buffer)) {

			_pdm_debug("check for function", 0);

			sts = MEMbuild_array(PDU_func_buffer);

			_pdm_status("MEMbuild_array", sts);

			if (sts != MEM_S_SUCCESS)
                          return(PDM_E_BUILD_BUFFER_ARRAY);

			func_data = (char **)PDU_func_buffer->data_ptr;

			FOUND = FALSE;

			for (j = 0; j < PDU_func_buffer->rows; j++)  {
/* TR# 139420299. 19/june/94 - raj.	*/
/*				if (!strcmp(attr_data[cnt + PDU_DYN_ATTR_COL],*/
				if (!strcmp(attr_data[(PDU_dyn_attr_bufr->columns * cnt) + PDU_DYN_ATTR_COL],
					func_data[(PDU_func_buffer->columns * j) ]))   {

				   FOUND = TRUE;
				   dyn_star_type[i] = 1;  /* func type */
				   sprintf(string,"*%s", dyn_attr_desc[i]);
				   FIfld_set_text(fp,glabel,start_row+i,1,
								string,FALSE);
				}
				break;
			}
         	}

		else 

				dyn_star_type[i] = 0 ;  /* No special processing */

		_pdm_debug("PDU_dyn_data_bufr->columns %d", PDU_dyn_data_bufr->columns);
	        _pdm_debug("Filling in dynamic data col", 0);

	       	num_rows = num_rows + 1;

	} /* end of for loop */

	return(PDM_S_SUCCESS);
}

PALget_coresp_col_indx(char *dyn_attr_name,int *cnt)
{

	int i;
	char **data_ptr;

	data_ptr = (char **) PDU_dyn_attr_bufr -> data_ptr ;

	_pdm_debug("dyn attr name: %s", dyn_attr_name );

	for( i = 0  ; i < PDU_dyn_attr_bufr -> rows ; ++i )

		if( !strcmp(dyn_attr_name, data_ptr[(PDU_dyn_attr_bufr->columns * i) + PDU_DYN_ATTR_COL])){

				*cnt = i ;
				return(1);
		}

	return(0);
}
				
process_dyn_attrs_mcf(int form_num, Form fp, int glabel, int row , int indx , 
	int *dyn_star_type, char *atrname)
{

	char *function_name = NULL , **list_data;
        char *msg;
	int sts,cnt, i, pos = 0, sel_flg;
        int status;
	double val1,val2 , act_val;
        int act_col = 0;
        int act_pos = 0;
        MEMptr list_buffer = NULL;
        extern struct PDUrefresh *refresh;

	/* TR# 13941 6416.	*/
	char	val1_str[32], val2_str[32];
	
	FIfld_set_text(fp,FI_MSG_FIELD,0,0,NULL_STRING,FALSE);

	if( !Get_text(fp,glabel,row,1))
		return(1);                 /* No special processing */

        FImcf_get_active_col(fp, glabel, &act_col, &act_pos);
	_pdm_debug("special processing for attr : %s", atrname );

	/* TR# 139420446. 19/Dec/94 - raj. Validate input for ordinary attributes. BEGIN. */
	if(( dyn_star_type[indx] == 0 ) && (act_col == 2))
	{
	  /* Now, validate input.	*/
            int status, attr_row;
            char *datatype = NULL;
            char **attr_data = NULL;
            char *usr_input = NULL;
            
            /* find attr_name in attr_buffer */
            if(!PDU_dyn_attr_bufr)
            {
              _pdm_debug("PDU_dyn_attr_bufr is NULL", 0);
              goto wrapup;
            }
              
            status = MEMbuild_array(PDU_dyn_attr_bufr);
            _pdm_status("MEMbuild_array", status);
            if (status != MEM_S_SUCCESS)
              goto wrapup;

/*          if (PDMdebug_on)
		MEMprint_buffer( "PDU_dyn_attr_bufr: ", PDU_dyn_attr_bufr, PDU_DEBUG_FILE ); */

            attr_row = PDUfind_attr_in_buffer(PDU_dyn_attr_bufr, atrname);
            
            if (attr_row == -1)
              goto wrapup;
            
            attr_data = (char **)PDU_dyn_attr_bufr->data_ptr;
            
            PDUfill_in_string(&datatype, attr_data[(PDU_dyn_attr_bufr->columns  * attr_row ) +
                              PDU_DYN_DATA_COL]);

            /* Get user input from value column on form. */
            if( !Get_text(fp,glabel,row,2))
              goto wrapup;

            if ((usr_input = (char *) malloc ((strlen(s_text) + 1) * sizeof (char))) ==NULL)
              { _pdm_debug("Unable to allocate memory", 0); return(0); }

            strcpy(usr_input, s_text);
            _pdm_debug("act_val= %s", usr_input);

            status = PDUvalidate_value(usr_input, datatype);
            _pdm_status("PDUvalidate_value", status);

            if (usr_input)
              free ((char *) usr_input);
            if (datatype)
              free ((char *) datatype);

	    if (status != PDM_S_SUCCESS)
	    {
	      msg = (char *)PDUtranslate_message(status);
              FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
              return(0);
            }
	}
	else 
	/* TR# 139420446. 19/Dec/94 - raj. Validate input for ordinary attributes. END. */

	if(( dyn_star_type[indx] == 1 ) && (act_col != 2)){    /* exec function */
		
		/* Get function associated */
		sts = PDUcheck_for_function(atrname, &function_name, PDU_func_buffer);
		_pdm_status("PDUcheck_for_function", sts);

		if (sts) {
		       sts = PDUprocess_function(function_name);
			_pdm_status("PDUprocess_function", sts);

			if( sts )
				FIfld_set_text(fp,glabel,row,2,PDU_attr_value,
									FALSE);
		}
       }

	else if(( dyn_star_type[indx] == 2 )  && (act_col != 2)){  /* Bring up pull down list of values */

		_pdm_debug("In the function PDUprocess_pulldown_list", 0);

		if( PALget_coresp_col_indx(atrname,&cnt)){
			
			_pdm_debug("row = %d", cnt);
                        status = PDMget_list_buffer(refresh->rev_catalog,
                                                    atrname,
                                                    &list_buffer);
                        _pdm_status("PDMget_list_buffer", status);
                        if (status != PDM_S_SUCCESS)
                          return(status);
                        else if (list_buffer == NULL)
                          return(PDM_E_NULL_BUFFER);
                        else if (list_buffer->rows == 0)
                          return(PDM_E_NULL_BUFFER);
                         MEMbuild_array(list_buffer);
			_pdm_debug("Convert buffer_number to integer", 0);

			list_data = (char **)list_buffer->data_ptr;
			_pdm_debug("Static list of values defined", 0);

			for (i = 0; i < list_buffer->rows; i ++)
				PDUfill_in_string(&PDU_value_list[i], list_data[list_buffer->columns * i ]);
	
				/* Display pull down list and let user select one */

				pull_main(form_num, fp, glabel, pos,1, 
			  		PDU_value_list, list_buffer->rows, 1, 0, 8, &sts, &sel_flg); 

				if( sts )
					FIfld_set_text(fp,glabel,row,2,PDU_value_list[sel_flg],FALSE);
			}
		}

	else if( dyn_star_type[indx] == 3 ) {

		if(! Get_text(fp,glabel,row,1))
			return(0);

			function_name = strtok(s_text,":");
			function_name = strtok(NULL,",");
			
			_pdm_debug("val1 = %s", function_name);
			/* TR# 13941 6416.	*/
			strcpy(val1_str, function_name);

			sscanf(function_name, "%lf", &val1 );		

			function_name = strtok(NULL,":");
			function_name = strtok(NULL,")");
			_pdm_debug("val2 = %s", function_name);

			/* TR# 13941 6416.	*/
			strcpy(val2_str, function_name);

			sscanf(function_name, "%lf", &val2 );		

	
			if( !Get_text(fp,glabel,row,2))
				return(0);
			_pdm_debug("act_val= %s", s_text);
			sscanf(s_text,"%lf", &act_val );

			/* TR# 13941 6416.	*/			
/* This might cause problems when one of the ranges is not defined.
*			if( act_val >= val1 && act_val <= val2 )
*				return(1);
*/
			/* Min value not defined.	*/
			if (PALall_blanks(val1_str) && !PALall_blanks(val2_str))
			{
                          if(act_val <= val2 )
                             return(1);
                        }
       			/* Max value not defined.	*/
                        else if (!PALall_blanks(val1_str) && PALall_blanks(val2_str))
                        {
				if( act_val >= val1)
				   return(1);                          
                        }
                        /* Both Min and Max defined.	*/
                        else if (!PALall_blanks(val1_str) && !PALall_blanks(val2_str))
                        {
                          if( act_val >= val1 && act_val <= val2 )
                             return(1);
                        }
/*
			FIfld_set_text(fp,glabel,row,2,tmpstr,FALSE);
*/

                        msg = (char *)PDUtranslate_message(PDM_E_BAD_DATA);
			FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
			return(0);
		}
		/* If user attempts to key in for list type attrs:
		   Clear value and output message.			*/
		else if(( dyn_star_type[indx] == 2 )  && (act_col == 2))
		{
		  char	*usr_input;
		  
		  _pdm_debug("Processing uesr key-in for list type attribute", 0);
		  
		  /* Return 0 if nothing is entered so that original
		     value will be posted by the calling function. 	*/
		  if( !Get_text(fp,glabel,row,2))
		    return(0);

                  if ((usr_input = (char *) malloc ((strlen(s_text) + 1) * sizeof (char))) ==NULL)
                    { _pdm_debug("Unable to allocate memory", 0); return(0); }

                  strcpy(usr_input, s_text);
                  _pdm_debug("user input: <%s>", usr_input);

		  /* Get synonym of attribute. */
		  if( !Get_text(fp,glabel,row,1))
		  {
		    free ((char *) usr_input);
                    return(1);
                  }
		    
		    
		  status = PDUvalidate_dyn_data_value(s_text, usr_input, refresh->rev_catalog, 
                                       PDU_dyn_attr_bufr, 
                                       PDU_dyn_data_bufr);
                  _pdm_status("PDUvalidate_dyn_data_value", status);
                  
                  free ((char *) usr_input);
                  
                  if (status != PDM_S_SUCCESS)
                  {
                    /* Clear value keyed in.	*/
                    FIfld_set_text(fp,glabel,row,2, "",FALSE);
                    /* message to user that value must be in list. */
                    msg = (char *)PDUtranslate_message(status);
                    FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
                    return(0);
                  }
                }
wrapup:
	return( 1 );	
}

 int  PALall_blanks(char *string)
{
	int	cnt, len = strlen (string);

	for (cnt = 0; cnt < len; cnt++)
		if (isspace (string[cnt]))
			continue;
		else
			break;

	if (cnt == len)
		return (1);
	else
		return (0);
}

