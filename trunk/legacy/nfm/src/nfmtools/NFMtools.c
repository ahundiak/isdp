#include "machine.h"
#include <stdio.h>
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NDXstruct.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMfill_index
 
 Abstract:
      This function will fill a structure with the indexes into an
      attribute buffer.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other - Failure
*/
 
long NFMfill_index (attr_list, index)

MEMptr  attr_list;   /* i - an attribute buffer */
NDXptr  *index;      /* o - the address of a structure of indexes into the 
                            attribute buffer */

{
int  i;
char **column_ptr;
static char *fname = "NFMfill_index";

    column_ptr = (char **) attr_list->column_ptr;

    for (i=0; i<attr_list->columns; ++i)
        {
             if (strcmp (column_ptr[i], "n_name") == 0)
	       {
		 _NFMdebug ((fname, "n_name is %d\n", i));
                 index->name = i;
		 index->nfm = i ;
	       }
        else if (strcmp (column_ptr[i], "n_datatype") == 0)
                 index->dt = i;
        else if (strcmp (column_ptr[i], "n_synonym") == 0)
                 index->syn = i;
        else if (strcmp (column_ptr[i], "n_nfmname") == 0)
                 index->nfm = i;
        else if (strcmp (column_ptr[i], "n_opentonfm") == 0)
                 index->open = i;
        else if (strcmp (column_ptr[i], "n_application") == 0)
                 index->app = i;
        else if (strcmp (column_ptr[i], "n_read") == 0)
                 index->r = i;
        else if (strcmp (column_ptr[i], "n_write") == 0)
                 index->w = i;
        else if (strcmp (column_ptr[i], "n_update") == 0)
                 index->u = i;
        else if (strcmp (column_ptr[i], "n_delete") == 0)
                 index->d = i;
        else if (strcmp (column_ptr[i], "n_null") == 0)
                 index->nul = i;
        else if (strcmp (column_ptr[i], "n_keyin") == 0)
                 index->key = i;
        else if (strcmp (column_ptr[i], "n_checkin") == 0)
                 index->in = i;
        else if (strcmp (column_ptr[i], "n_checkout") == 0)
                 index->out = i;
        else if (strcmp (column_ptr[i], "n_seqno") == 0)
                 index->seq = i;
        else if (strcmp (column_ptr[i], "n_listno") == 0)
                 index->list = i;
        else if (strcmp (column_ptr[i], "n_adviceno") == 0)
                 index->key = i;
        else if (strcmp (column_ptr[i], "n_valueno") == 0)
                 index->list = i;
        }

    return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMfill_new_index
 
 Abstract:
      This function will fill a structure with the indexes into an
      attribute buffer (for change commands).
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    1-15-1990    Creation
     
 */
 
long NFMfill_new_index (attr_list, index)

MEMptr  attr_list;   /* i - an attribute buffer */
NDXnewptr  *index;   /* o - the address of a structure of indexes into the 
                            attribute buffer */

{
int  i;
char **column_ptr;

    column_ptr = (char **) attr_list->column_ptr;

    for (i=0; i<attr_list->columns; ++i)
        {
             if (strcmp (column_ptr[i], "n_name") == 0)
                 index->name = i;
        else if (strcmp (column_ptr[i], "n_datatype") == 0)
                 index->dt = i;
        else if (strcmp (column_ptr[i], "n_synonym") == 0)
                 index->syn = i;
        else if (strcmp (column_ptr[i], "n_nfmname") == 0)
                 index->nfm = i;
        else if (strcmp (column_ptr[i], "n_opentonfm") == 0)
                 index->open = i;
        else if (strcmp (column_ptr[i], "n_application") == 0)
                 index->app = i;
        else if (strcmp (column_ptr[i], "n_read") == 0)
                 index->r = i;
        else if (strcmp (column_ptr[i], "n_write") == 0)
                 index->w = i;
        else if (strcmp (column_ptr[i], "n_update") == 0)
                 index->u = i;
        else if (strcmp (column_ptr[i], "n_delete") == 0)
                 index->d = i;
        else if (strcmp (column_ptr[i], "n_null") == 0)
                 index->nul = i;
        else if (strcmp (column_ptr[i], "n_keyin") == 0)
                 index->key = i;
        else if (strcmp (column_ptr[i], "n_adviceno") == 0)
                 index->key = i;
        else if (strcmp (column_ptr[i], "n_checkin") == 0)
                 index->in = i;
        else if (strcmp (column_ptr[i], "n_checkout") == 0)
                 index->out = i;
        else if (strcmp (column_ptr[i], "n_seqno") == 0)
                 index->seq = i;
        else if (strcmp (column_ptr[i], "n_listno") == 0)
                 index->list = i;
        else if (strcmp (column_ptr[i], "n_valueno") == 0)
                 index->list = i;
        else if (strcmp (column_ptr[i], "new_n_name") == 0)
                 index->new_name = i;
        else if (strcmp (column_ptr[i], "new_n_datatype") == 0)
                 index->new_dt = i;
        else if (strcmp (column_ptr[i], "new_n_synonym") == 0)
                 index->new_syn = i;
        else if (strcmp (column_ptr[i], "new_n_opentonfm") == 0)
                 index->new_open = i;
        else if (strcmp (column_ptr[i], "new_n_application") == 0)
                 index->new_app = i;
        else if (strcmp (column_ptr[i], "new_n_read") == 0)
                 index->new_r = i;
        else if (strcmp (column_ptr[i], "new_n_write") == 0)
                 index->new_w = i;
        else if (strcmp (column_ptr[i], "new_n_update") == 0)
                 index->new_u = i;
        else if (strcmp (column_ptr[i], "new_n_delete") == 0)
                 index->new_d = i;
        else if (strcmp (column_ptr[i], "new_n_null") == 0)
                 index->new_nul = i;
        else if (strcmp (column_ptr[i], "new_n_keyin") == 0)
                 index->new_key = i;
        else if (strcmp (column_ptr[i], "new_n_checkin") == 0)
                 index->new_in = i;
        else if (strcmp (column_ptr[i], "new_n_checkout") == 0)
                 index->new_out = i;
        else if (strcmp (column_ptr[i], "new_n_seqno") == 0)
                 index->new_seq = i;
        else if (strcmp (column_ptr[i], "new_n_listno") == 0)
                 index->new_list = i;
        }

    return (NFM_S_SUCCESS);
}


long NFMfill_newer_index (attr_list, index)

MEMptr  attr_list;   /* i - an attribute buffer */
NDXnptr *index;      /* o - the address of a structure of indexes into the 
                            attribute buffer */
{
int  i;
char **column_ptr;

    column_ptr = (char **) attr_list->column_ptr;

    for (i=0; i<attr_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_synonym") == 0)
                 index->syn = i;
        else if (strcmp (column_ptr[i], "n_null") == 0)
                 index->null = i;
        else if (strcmp (column_ptr[i], "n_read") == 0)
                 index->r = i;
        else if (strcmp (column_ptr[i], "n_adviseno") == 0)
                 index->advise = i;
        else if (strcmp (column_ptr[i], "n_valueno") == 0)
                 index->list = i;
        }

    return (NFM_S_SUCCESS);
}

