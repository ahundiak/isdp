#include "machine.h"
/************************************************************************
*				NFMlist_f				*
*	Thi procedure generates a list consisting of			*
*	n_catalogname, n_itemname, n_itemrev , n_cofilename ,		*
*	n_cifilename , and n_saname.					*
*	If a user defined n_cifilename is not present an entry for the	*
*	nfmdefined n_cifilename is created				*
************************************************************************/
#include "DEBUG.h"

#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "NFMsacdef.h"
#include "NFMdef.h"
#include "NFIerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "ERR.h"
#include "NFMschema.h"

#define FIRST_TIME	1  
extern char NFMprint_file[];

long NFMlist_f(user_id,cat_sort_str,
			item_sort_str, out_buffer_list)
	long user_id;
	MEMptr	*out_buffer_list;
	char *item_sort_str, *cat_sort_str;
{
	long status = 0,type=0,i=0,j=0,flag=0,length=0,size=0,offset=0;
	MEMptr cat_list=MEMNULL,out_list=MEMNULL,interim_list= MEMNULL ;
	char temp[SIZE],*return_str;
	char **format,**data,**column,**column_ptr,*fname="NFMlist_f";
    struct SCfree_data_st fdata;
	long return_status= NFM_S_SUCCESS;
    int  tot_data;
    int  count;
    int  pos;
	return_status= NFM_S_SUCCESS;
	flag = FIRST_TIME ;

    _NFMdebug((fname,"Entry>> user_id %d Catalog Sort string %s\n\
Item sort string %s Out buffer pointer %d\n",user_id,cat_sort_str,item_sort_str,out_buffer_list));

    /* check if the list pointer is NULL */

    if(out_buffer_list == MEMPTRNULL)
     {
        _NFMdebug((fname,"Output buffer pointer Address is <%d>\n",out_buffer_list));

     /*Error processor Error here */

    status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","output buffer pointer");

    if(status!=ERR_S_SUCCESS)

    _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
    return(NFM_E_NULL_OUTPUT_MEMPTR);

   }

   /* make sure that the list is NULL  at entry point*/
   if(*out_buffer_list != MEMNULL)
    {
     _NFMdebug((fname,"<<<<WARNING>>>> Output buffer pointer  is <%d>(NOT NULL)\n",*out_buffer_list));

    _NFMdebug((fname,"<<<<WARNING>>>> MEMclose on Output buffer <%d>\n",*out_buffer_list));

      /* set out_buffer_list to NULL */

       MEMclose(out_buffer_list);
     }

/* check if the list pointer is NULL */

/* GET LIST OF CATALOGS */

 if((status=NFMlist_cat_names(66636,&cat_list,"",cat_sort_str,1))!=NFM_S_SUCCESS)
  {
     _NFMdebug((fname,"Failed to obtain list of catalogs\n"));
     return(status);
   }
  if((status=MEMbuild_array(cat_list))!=MEM_S_SUCCESS)
   {
      _NFMdebug((fname,"MEMbuild array failed for cat_list"));
      status=ERRload_struct(NFM,NFM_E_MEM,"");
      if(status!=ERR_S_SUCCESS)
        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
        MEMclose(&cat_list);
        return(NFM_E_MEM);
    }

  data = (char **)cat_list->data_ptr;
  format = (char **) cat_list->format_ptr;
  column_ptr = (char **) cat_list ->column_ptr;

/* get the length of n_catalogname */
  if (cat_list->columns > 0)
   {
      if (! strncmp (format [0], "char",     4))
         sscanf(format[0],"%5s%d",temp,&length);
         if(length <= 0 ) length = NFM_ITEMNAME;
    }
   else length = NFM_ITEMNAME;

   fdata.num_of_rows = cat_list->rows;
   fdata.num_of_cols = 2;
   tot_data = fdata.num_of_cols * fdata.num_of_rows;
   fdata.freeze_rows_count = 0;
   fdata.freeze_cols_count =0;
   fdata.max_indent = 0;
   fdata.select_set_expected = SELECT_SET_MULTI_ROW;
   fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
   memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));

   fdata.col_size[0] = 15;
   fdata.col_size[1] = 15;

   fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
   memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));

   pos =0;
   for (i=0; i<cat_list->columns; ++i)
        {
        fdata.col_pos[i] = pos;
        pos += fdata.col_size[i] + 2;
        }

   fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
   memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));

   fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
   memset (fdata.h1_pos, 0, sizeof (int) + 1);
   fdata.h1_pos[0] = 0;
   fdata.h1_pos[1] = -1;

   fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
   memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
   for (i=0; i<cat_list->columns; ++i)
        fdata.h2_pos[i] = fdata.col_pos[i];

   fdata.h2_pos[i] = -1;

   fdata.h3_pos = (int*)malloc( sizeof(int) * 2);
   memset( fdata.h3_pos, 0, sizeof(int) * 2);
   fdata.h3_pos[0] = 0;
   fdata.h3_pos[1] = -1;

   fdata.h1_data = (char**) malloc ( sizeof(char*) );
   memset( fdata.h1_data, NULL, (sizeof (char*)));
   NFMput_string( &fdata.h1_data[0], "" );

   fdata.h2_data = (char**) malloc( tot_data * (sizeof(char*)));
   memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
   for (i=0; i<cat_list->columns; ++i)
        NFMput_string (&fdata.h2_data[i], column_ptr[i]);

   fdata.h3_data = (char**)malloc( sizeof(char*) );
   memset( fdata.h3_data, NULL, (sizeof(char*)));
   NFMput_string( &fdata.h3_data[0], "" );

    sprintf (fdata.title, "%s","Select Desired catalog/catalogs");

    fdata.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( fdata.select_set, 0 , (tot_data * sizeof(int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        NFMput_string (&fdata.data[i], data[i]);

    SCdisplay_ref("<PF1> To Select Individual Catalog(s) Or <PF4> For All Catalogs.");

    SCclear_msg();
    status = SCprocess_free_form (&fdata, NFMprint_file);
    SCclear_ref();

    if(fdata.sts == FORM_CANCELED)
     {
       _NFMdebug((fname,  "Cancel from form. Return."));
       NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
       free (fdata.data);
       ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
       return (NFI_W_FORM_CANCELED);
     }

    count = 0;

    SCdisplay_msg("Working..");

    /*for ( i=0 ; i <cat_list->rows*cat_list->columns; i++)*/
    /* The for-loop should be executed  (number of catalog) times,
       which means  the condition should be 'i < cat_list->rows'
       SSRS 3 May 94 */
    for ( i=0 ; i <cat_list->rows; i++)
       {
         if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
          {
            count = i * fdata.num_of_cols;
  
            status = NFMitem_list(&out_list,fdata.data[count],fdata.data[count+1],item_sort_str);
          }

          else
            continue;

   	        if(status==NFM_S_SUCCESS)
    	   {
    		 if(flag!=FIRST_TIME) 
			 status=NFMadd_col_val(user_id,out_list,&interim_list,fdata.data[count]);
		  else
		   {
  		 	 status =NFMadd_col(user_id,out_list,"char",length,&interim_list,"n_catalogname" );
   		 if(status!=NFM_S_SUCCESS)
 		   {
    		 _NFMdebug((fname,"Add column failed status=\
<0x%.8x> for catalog %s\n",status,fdata.data[count]));
    		 MEMclose(&interim_list);
    	   }
		 else
		   {
		 	status = NFMadd_col_val(user_id,out_list,&interim_list,fdata.data[count]);
			if(status!=NFM_S_SUCCESS)
			_NFMdebug((fname,"Failed to add value\
for catalog %s status=<0x%.8x>\n",fdata.data[count],status));
     		}
			if(status==NFM_S_SUCCESS)
					flag++;
			}
/* ERRLOAD done by add_col functions 
			if(status!=NFM_S_SUCCESS )
			{
    		  status=ERRload_struct(NFM,NFM_E_MEM,"");
 			  if(status!=ERR_S_SUCCESS)
                _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			}
*/
		}
		else
/* NFMgen_list will load context specific information 
      _NFMdebug((fname,"List Item failed for catalog %s status =<0x%.8x>\n",fdata[count],status));
*/
/* Reset the memory pointers after closing the memory */
		MEMclose(&out_list);
		out_list = MEMNULL;
	}
	MEMclose(&out_list);
/* change cifilename and remove n_fileno */
        if((status=MEMbuild_array(interim_list))!=MEM_S_SUCCESS)
        {
           _NFMdebug((fname,"MEMbuild array failed for interim_list"));
            status=ERRload_struct(NFM,NFM_E_MEM,"");
            if(status!=ERR_S_SUCCESS)
            _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
            MEMclose(&interim_list);
            MEMclose(&cat_list);
            return(NFM_E_MEM);
         }
        data = (char **)interim_list->data_ptr;
        format = (char **) interim_list->format_ptr;
	column = (char **) interim_list->column_ptr;
/* Open a memory area */
	if((status=MEMopen(out_buffer_list,4*MEM_SIZE)) != MEM_S_SUCCESS)
        {
                _NFMdebug((fname,"MEMopen failed for out_list\
                 status = <0x%.8x>\n" , status));
                status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                MEMclose(&interim_list);
                MEMclose(&cat_list);
                return(NFM_E_MEM);
        }
	size = 0;
        for(i=0 ; i < interim_list-> columns - 1; i++)
        {
		length = 0;
		if (! strncmp (format [i], "integer",  7)) length = 15;
          	else if (! strncmp (format [i], "smallint", 8)) length = 15;
          	else if (! strncmp (format [i], "double",   6)) length = 50;
          	else if (! strncmp (format [i], "real",     4)) length = 50;
          	else if (! strncmp (format [i], "char",     4))
                  	sscanf (format [i], "%5s%d", temp, &length);
		if(length <= 0)
		{
			_NFMdebug((fname,"Failed to get length of attribute <%d>\n",i));
                	status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Format length 0");
                	if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                	MEMclose(&interim_list);
	                MEMclose(&cat_list);
	                MEMclose(out_buffer_list);
			
			return(NFM_E_FAILURE);
		}		
		size = size + length +2;
          if((status=MEMwrite_format(*out_buffer_list , column[i] , format[i]))!= MEM_S_SUCCESS)
           {
              _NFMdebug((fname,"MEMwrite_format failed for out_list\
column <%s> status = <0x%.8x>\n" , status));
              status=ERRload_struct(NFM,NFM_E_MEM,"");
              if(status!=ERR_S_SUCCESS)
                _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
              	MEMclose(&interim_list);
                MEMclose(&cat_list);
                MEMclose(out_buffer_list);
                return(NFM_E_MEM);
            }
        }
	size = size + 2*SIZE;
	if((return_str = (char *)malloc(size)) == (char *)0)
	{
     _NFMdebug((fname,"Failed to malloc <%d> bytes for MEMwrite string\n",size));
     status = ERRload_struct(NFM,NFM_E_MALLOC,"%s","Add column Value 1");
     if(status!=ERR_S_SUCCESS)
         _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
     MEMclose(&interim_list);
     MEMclose(&cat_list);
     MEMclose(out_buffer_list);
     return(NFM_E_MALLOC);
	}

    for(i=0;i< interim_list->rows ; i++ )
      {
        offset = i * interim_list->columns ;
		strcpy(return_str,"");
        for(j=0;j < interim_list->columns-1 ; j++)
          {
             strcat(return_str,data[offset+j]);
              strcat(return_str,"\1");
           }
            if((status=MEMwrite(*out_buffer_list , return_str))!=MEM_S_SUCCESS)
             {
               _NFMdebug((fname,"MEMwrite failed for out_list\
               status = <0x%.8x> string=%s\n" , status,return_str));
               status=ERRload_struct(NFM,NFM_E_MEM,"");
               if(status!=ERR_S_SUCCESS)
                _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
           		MEMclose(&interim_list);
	            MEMclose(&cat_list);
                free(return_str);
   		        MEMclose(out_buffer_list);
                return(NFM_E_MEM);
               }

        }


	MEMclose(&interim_list);
    MEMclose(&cat_list);
    free(return_str);
    SCclear_msg();
    _NFMdebug((fname,"Exit >> SUCCESSFUL\n"));
	return(return_status);
}
