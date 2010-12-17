#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"

char     title[80];

long search_across_catalogs_partial ()

{
int    i,j=0;
long   status;
int    more_items = TRUE;
int    cursor_status;
long   save_status;
long   ret_status;
long   NFAnew_display_simple_data();
long   row_size;
char   fmt[20];
char   new_cat[NFM_CATALOGNAME+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
char   old_cat[NFM_CATALOGNAME+1];
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   **data_cat;
NFMlist display_struct;
struct SCfree_data_st data;
struct SCfree_data_st new_data;
MEMptr catalog_list = NULL;
MEMptr syn_list     = NULL;
MEMptr data_list    = NULL;
MEMptr fake_list    = NULL;

static char *fname = "NFAsearch_across_catalogs_partial";

    SCdisplay_msg ("Working..");    


    strcpy (old_cat, NFMcatalog);
    strcpy (old_item, NFMitem);
    strcpy (old_rev, NFMrev);
    strcpy (new_cat, NFMcatalog);
    strcpy (new_item, NFMitem);
    strcpy (new_rev, NFMrev);


    status = NFMRdisplay_catalogs ( "", "", NFM_FULL_DISPLAY, 
				    &syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
    	return (status);
        }

    strcpy( title, "Choose Catalogs to be Searched" ); 

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
                   SELECT_SET_MULTI_ROW, title );

   /* MEMprint_buffers("datanew", data_list, "/dev/console");    */
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }
    MEMclose( &syn_list );
    MEMclose( &data_list );

    status = MEMopen( &catalog_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME);
    status = MEMwrite_format (catalog_list, "n_catalogname", fmt);
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
	MEMclose( &catalog_list );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    for (i=0; i<data.num_of_rows; ++i)
     {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
    	      status = MEMwrite (catalog_list, data.data[j]);
              if( status != MEM_S_SUCCESS )
      	       {
         		 _NFIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        		 MEMclose( &catalog_list );
    	    	 ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
          		 return( NFM_E_MEM );
                }
             }
         }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

     status = NFMRblock_multiple_catalog_search ( catalog_list, NFMsearch_name,
		NFMsort_name, &data_list, &syn_list, NFMRglobal.query_rows);
		
      save_status = status;

     _NFIdebug((fname, " save status is <0x%.8x>\n", save_status));
 
     _NFIdebug((fname, " GET HERE AND BREAK\n"));
/*
	if (_NFMdebug_st.NFIdebug_on)
     {
      MEMprint_buffers ("data list", data_list,_NFMdebug_st.NFIdebug_file) ;
      MEMprint_buffers ("syn list", syn_list, _NFMdebug_st.NFIdebug_file) ;
     }

*/
     if ((status != NFM_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
      {
        cursor_status = NFMRblock_multiple_catalog_search ( catalog_list,
          NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
    	 MEMclose (&data_list);
    	 MEMclose (&syn_list);
    	 _NFIdebug((fname,  "the Return is <0x%.8x>\n", status));
         return (status);
      }		
		
       _NFIdebug((fname, " No.of rows is <%d>\n", NFMRglobal.query_rows));

      strcpy( title, "List of I/NFM Items" );

      status = NFAnew_display_simple_data (&new_data, syn_list, data_list,
                   SELECT_SET_SINGLE_ROW, title );

   /*  MEMprint_buffers("data_listf", data_list, "/dev/console");
     MEMprint_buffers("syn_listf", syn_list, "/dev/console");*/

/*   call cursor_status inside of status != NFI_S_SUCCESS) */

     if( status != NFI_S_SUCCESS )
      {
    	_NFIdebug((fname,  " Failed in here"));

        cursor_status = NFMRblock_multiple_catalog_search ( catalog_list,
        NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
      }


    if (status == NFI_W_COMMAND_CANCELLED)
    {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        cursor_status = NFMRblock_multiple_catalog_search ( catalog_list, 
            NFMsearch_name, NFMsort_name, &data_list, &syn_list, 
                  0);
      _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n",cursor_status));
       MEMclose( &data_list );
       MEMclose( &syn_list );
       return( NFI_W_COMMAND_CANCELLED );
     }
    else if( save_status == NFM_I_NO_MORE_BUFFERS )
    {
        more_items = FALSE;
        _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
    }
    else if(status != NFI_S_SUCCESS)
    {
      _NFIdebug(( fname,  "NFAdisplay_elements : <0x%.8x>\n",  status));
      cursor_status = NFMRblock_multiple_catalog_search ( catalog_list,
      NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
      MEMclose( &syn_list );
      MEMclose( &data_list );
      return (status);
     }

     for (i=0; i<new_data.num_of_rows; ++i)
      {
  	    _NFIdebug ((fname,  "the value of i is <%d>\n", i));
        j = i * new_data.num_of_cols;
        if (new_data.select_set[i] == 1)
         {
            more_items = FALSE;
            cursor_status =  NFMRblock_multiple_catalog_search (catalog_list,
              NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
         /*     MEMprint_buffers("data2", data_list, "/dev/console");*/

            _NFIdebug(( fname,"Cursor Close Status <0x%.8x>\n",cursor_status));

               strcpy (new_cat, new_data.data[j]);           
               strcpy ( new_item, new_data.data[j+1]);
               strcpy ( new_rev, new_data.data[j+2]);
               break;
              }
           }

    if ((strcmp (new_cat, old_cat) !=0) ||
        (strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
    {
        strcpy (NFMcatalog, new_cat);
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
    }

    while( more_items )
     {
           status = NFMRblock_multiple_catalog_search (catalog_list,
            NFMsearch_name, NFMsort_name, &data_list, &fake_list,
             NFMRglobal.query_rows);

           save_status = status;
           _NFIdebug((fname,  "sec save status <0x%.8x>\n", save_status));

           if ((status != NFM_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
            {
              cursor_status = NFMRblock_multiple_catalog_search ( catalog_list,
              NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
              MEMclose (&data_list);
              MEMclose (&syn_list);
             _NFIdebug(( fname, "NFMRblock_multiple return :<0x%.8x>\n",status));
              return(status);
            }
           
        status = NFAnew_display_simple_data (&new_data,  syn_list,  data_list, 
                SELECT_SET_SINGLE_ROW,  title );

     /*    MEMprint_buffers("syn_list",  syn_list,  "/dev/console");
         MEMprint_buffers("data_list",  data_list,  "/dev/console");*/

        if (status != NFI_S_SUCCESS) 
         {
           cursor_status = NFMRblock_multiple_catalog_search ( catalog_list,
            NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
            MEMclose (&syn_list);
            MEMclose (&data_list);
            _NFIdebug(( fname, "NFMRblock_multiple :<0x%.8x>\n",status));
            return(status);
         }

         if (status == NFI_W_COMMAND_CANCELLED)
         {
            _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
             cursor_status =  NFMRblock_multiple_catalog_search (catalog_list,
             NFMsearch_name, NFMsort_name,&data_list, &syn_list,
                     0);
            _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n",cursor_status ));

            MEMclose( &data_list );
            MEMclose( &syn_list );
            return( NFI_W_COMMAND_CANCELLED );
           }
        else if( save_status == NFM_I_NO_MORE_BUFFERS )
        {

          more_items = FALSE;
         _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
        }

        else if(status != NFI_S_SUCCESS)
        {
          cursor_status = NFMRblock_multiple_catalog_search ( catalog_list,
           NFMsearch_name, NFMsort_name, &data_list, &syn_list, 0);
          _NFIdebug(( fname,  "NFAdisplay_elements : <0x%.8x>\n",  status));
          MEMclose( &syn_list );
          MEMclose( &data_list );
          return (status);
        }

  _NFIdebug((fname,  " what is No of new rows <%d>\n", new_data.num_of_rows));


        for (i=0; i<new_data.num_of_rows; ++i)
        {
   	     _NFIdebug((fname,  "is i <%d>\n", i));
         j = i * new_data.num_of_cols;
         if (new_data.select_set[i] == 1) 
            {
              strcpy (new_cat, new_data.data[j]);
              strcpy (new_item, new_data.data[j+1]);
              strcpy (new_rev, new_data.data[j+2]);
              more_items = FALSE;
              cursor_status =  NFMRblock_multiple_catalog_search  (
              catalog_list, NFMsearch_name, NFMsort_name,&data_list, 
                            &syn_list, 0);
          /*    MEMprint_buffers("data3", data_list, "/dev/console");*/
              _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", cursor_status ));
                break;
            }
        }

    if ((strcmp (new_cat, old_cat) !=0) ||
        (strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
    {
        strcpy (NFMcatalog, new_cat);
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
    }

 _NFIdebug((fname, "new_data %x, new_data.data %x, no_rows <%d>, no_cols <%d>\n",new_data, new_data.data, new_data.num_of_rows, new_data.num_of_cols));
        
    NFAfree_list (new_data.data, new_data.num_of_rows, new_data.num_of_cols);
    free (new_data.data);

    _NFIdebug(( fname, "%s\n", "Get another listing" ));
   }

    MEMclose( &syn_list);
    MEMclose( &data_list);
           
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));

    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



