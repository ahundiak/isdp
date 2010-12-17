#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "PDUerror.h"
#include "NFMstruct.h"
/* added to accomodate NFM3.0 changes MaC */
#include "NFMitems.h"
#include "PDMproto.h"


extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];


long PDMexp_copy_bufr (copy_bufr, exp_copy_bufr)

MEMptr copy_bufr;
MEMptr *exp_copy_bufr;

{
  /***
     Written to support copy assembly

    This function will expand the members of the copy_bufr to full blown structure which needs to be copied (based on the passed in catnos, item_nos.  It scans
for the attribute p_action and looks for a "Y" before expanding it. It then
queries the assembly indicator to see whether it can be expanded. It doesn't
check for the explode indicator. p_explode is a placement specific information
which does not apply for regular copy.

     HISTORY:
      06/05/92 - Kumar Narayanan - creation.
  ***/

  char *fname="PDMexp_copy_bufr";  
  char *fn="PDMexp_copy_bufr";  
  char          a_row[512], ass_ind[5];
  char          **copy_data, **column_ptr, **exp_data;
  char          **mul_data;
  int           level, mul, add_row = 1;
  short         i,n1,n2,n3,n4,n5,n6,n7, n8,nxi, ex, exi;
  long          status;
  int           nchildren;
  char          part[40],rev[40],type[15];
  struct        NFMmembers      *parent_struct;
  struct        NFMset_member *cur_mem, *temp_mem, *mem;
  struct        NFMset_member *head, *end;
  MEMptr        mul_files = NULL;


    _PDMdebug (fname, "Enter:\n");
status = MEMbuild_array(copy_bufr);
  if(status != MEM_S_SUCCESS)
   {
    _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
    return (status);
    }
  copy_data = (char **)copy_bufr->data_ptr;
  column_ptr = (char **)copy_bufr->column_ptr;
        n1 = -1;
        n2 = -1;
        n3 = -1;
        n4 = -1;
        n5 = -1;
        n6 = -1;
        n7 = -1;
        n8 = -1;

      for(i=0; i < copy_bufr->columns; i++)
       {
                if (!strcmp(column_ptr[i], "n_catalogno"))
                        n1 = i;
                else if (!strcmp(column_ptr[i], "n_itemno"))
                        n2 = i;
                else if (!strcmp(column_ptr[i], "n_catalogname"))
                        n3 = i;
                else if (!strcmp(column_ptr[i], "n_itemname"))
                        n4 = i;
                else if (!strcmp(column_ptr[i], "n_itemrev"))
                        n5 = i;
                else if (!strcmp(column_ptr[i], "n_cofilename"))
                        n6 = i;
                else if (!strcmp(column_ptr[i], "p_action"))
                        n7 = i;
                else if (!strcmp(column_ptr[i], "p_parttype"))
                        n8 = i;
        }
if (n1 == -1 || n2 == -1 ||
            n3 == -1 || n4 == -1 ||
            n5 == -1 || n6 == -1 || n7 == -1 || n8 == -1){
                _PDMdebug(fname, " %s %s \n",
                        "PDMcopy_part_files : ", "Failed to set offsets");
                return (PDM_E_BUFFER_FORMAT);
        }

status = MEMopen(exp_copy_bufr,512);
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(exp_copy_bufr);
                sprintf(s,"MEMopen failed status %d \n",status);
                PDMdebug(s);
                return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(*exp_copy_bufr,"n_catalogno","integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"n_itemno","integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"n_catalogname","char(20)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"n_itemname","char(40)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"n_itemrev","char(40)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"n_cofilename","char(14)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"p_parttype","char(2)");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(*exp_copy_bufr,"p_action","char(20)");
   if(status != MEM_S_SUCCESS) {
                MEMclose(exp_copy_bufr);
                sprintf(s,"MEMwrite_format failed status %d \n",status);
                PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
   }

  for(i=0; i < copy_bufr->rows; i++)
     {
            nxi = i * copy_bufr->columns;
      if(strcmp(copy_data[nxi+n7],"N"))
      {

       ass_ind[0] = '\0';
  status = PDMget_assembly_ind (copy_data[nxi+n3], copy_data[nxi+n4], 
				copy_data[nxi+n5],  ass_ind);
  if (status != SQL_S_SUCCESS) {
    _PDMdebug  (fname, "SQLquery 0x%.8x\n", status) ;
     continue;
      }

     if( (!strcmp(ass_ind,"Y")) || (!strcmp(ass_ind,"y"))) {
          /*
        sprintf(a_row,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        copy_data[nxi+n1], copy_data[nxi+n2], copy_data[nxi+n3],
        copy_data[nxi+n4], copy_data[nxi+n5], copy_data[nxi+n6],
        copy_data[nxi+n8], copy_data[nxi+n7]);
         _PDMdebug  (fname, "a_row-> %s\n", a_row) ;
         status = MEMwrite(*exp_copy_bufr,a_row);
         if(status != MEM_S_SUCCESS) {
            _PDMdebug (fn, "MEMwrite failed status %d\n", status);
            return (status);
            }
            */
/* load the struct with 1st level children_info */

head = end = (struct NFMset_member *) calloc (1, sizeof (struct NFMset_member));
parent_struct = (struct NFMmembers *) calloc (1, sizeof (struct NFMmembers));
         if (head == (struct NFMset_member *) NULL ||
         parent_struct == (struct NFMmembers *) NULL) {
                _PDMdebug (fn, "Allocating %d failed \n", head?
                (copy_bufr->rows *sizeof(struct NFMmembers)):
                sizeof (struct NFMset_member));
               return (NFM_E_MALLOC);
                }

  _PDMdebug (fn, "Loading Parent structure ...\n");
  nchildren = 1;
  head->level = 0;
  head->flag = 1;
   /*load parent_struct */
  parent_struct->cat_no = head->cat_no = atoi(copy_data[nxi+n1]);
  parent_struct->item_no = head->item_no = atoi(copy_data[nxi+n2]);
      head->cat_no = parent_struct->cat_no;
      head->item_no = parent_struct->item_no;
      strcpy (head->cat_name, copy_data[nxi+n3]);
      strcpy (head->item_name, copy_data[nxi+n4]);
      strcpy (head->item_rev, copy_data[nxi+n5]);
      strcpy (head->co_filename, copy_data[nxi+n6]);
    
  strcpy (head->type, "P");
  strcpy (parent_struct->type, "P");

  _PDMprint_setmember ("head", head);
 /* algorithm for level is:
       Info re. all the children for an assembly below the specified
       level no will be retrieved. If the level specified is 3 and
       the assy has 5 levels, leaves of the last 2 level will not be retrieved.
    */
        level = 0;

    _PDMdebug (fn, "Parent struct loaded ..\n \
                    before PDMretrieve_set_members;\n\
                    nchildren = %d\n", nchildren);

        status = PDMexp_retrieve_set_members (parent_struct, 1, level,
                                       head, end, &nchildren);

     if ( (status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) ) {
            _PDMdebug (fn,
              "PDMXretrieve_set_members failed status %d\n", status);
            return (status);
            }

PDMupdate_dots();
         /* printing the linked list */

    _PDMdebug (fn, "list from PDMretrieve_set_members\n");
    for ( mem = head; mem != (struct NFMset_member * ) NULL; mem = mem->next) 
    {
     _PDMprint_setmember ("mem", mem);
           status = PDMi_get_partnum_rev_type (mem->cat_name, 
                                                 mem->item_no,
                                                  part, rev, type);

            if(status != PDM_S_SUCCESS) {
            _PDMdebug (fn,
              "PDMquery_catalog_part_rev failed status %d\n", status);
              continue;
            }
             
           status = PDMget_mul_file(mem->cat_name,mem->item_no,&mul_files);
            if(status != PDM_S_SUCCESS) {
            _PDMdebug (fn,
              "PDMgwt_mul_file failed status %d\n", status);
              continue;
            }
          status = MEMbuild_array(mul_files);
          if(status != MEM_S_SUCCESS) {
           _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
            return (status);
             }
           mul_data = (char **)mul_files->data_ptr;
      for(mul=0; mul < mul_files->rows; mul++) 
         {
             /* Make sure you don't enter a duplicate 
                Found in NAVAIR dry run - kumar 11/23/92*/
             status = MEMbuild_array(*exp_copy_bufr);
              if(status != MEM_S_SUCCESS)
               {
          _PDMdebug (fname, "MEMbuild_array - exp_copy_bufr: 0x%.8x\n", status);
                return (status);
               }
               add_row = 1;
               exp_data = (char **)(*exp_copy_bufr)->data_ptr;
              for(ex = 0; ex < (*exp_copy_bufr)->rows; ex++)
                {
                  exi = ex * (*exp_copy_bufr)->columns;
               if (!strcmp(exp_data[exi + 2], mem->cat_name) &&
                   !strcmp(exp_data[exi + 3], part) &&
                   !strcmp(exp_data[exi + 4], rev)  &&
                   !strcmp(exp_data[exi + 5], mul_data[mul])) 
                       {
                                add_row = 0;
                                break;
                        }
                }
                 if(add_row == 1) /* If there is no duplicate */
                {
         a_row[0] = '\0';
        sprintf(a_row,"%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1",
         mem->cat_no, mem->item_no, mem->cat_name, part, rev,
              mul_data[mul], type, "");
    _PDMdebug  (fname, "a_row-> %s\n", a_row) ;
                status = MEMwrite(*exp_copy_bufr,a_row);
                    if(status != MEM_S_SUCCESS)
                    {
                    _PDMdebug (fn,
                    "MEMwrite failed status %d\n", status);
                    return (status);
                    }
                } /* If there is no duplicate */
          }/* For multiple files of the part */
         MEMclose(&mul_files);
      } /* For all the children of the part */
 
        PDMupdate_dots();
        _PDMdebug (fn, "freeing NFMset_member struct ...\n");
        for (cur_mem = head; cur_mem != (struct NFMset_member *) NULL;)
           {
            temp_mem = cur_mem;
            cur_mem = cur_mem->next;
            _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n",
                            temp_mem->cat_name, temp_mem->item_name);
            free ( temp_mem );
           }
            free (parent_struct);
        } /* If it is an assembly */
      else {
    /* the assy_indicator is not set ....*/

/*
        sprintf(a_row,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
    copy_data[nxi+n1],copy_data[nxi+n2],copy_data[nxi+n3],copy_data[nxi+n4], copy_data[nxi+n5], copy_data[nxi+n6], copy_data[nxi+n7]);
*/
     sprintf(a_row,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
     copy_data[nxi+n1], copy_data[nxi+n2], copy_data[nxi+n3],
     copy_data[nxi+n4], copy_data[nxi+n5], copy_data[nxi+n6],
     copy_data[nxi+n8], copy_data[nxi+n7]);
    _PDMdebug  (fname, "a_row-> %s\n", a_row) ;
     status = MEMwrite(*exp_copy_bufr,a_row);
          if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status %d\n", status);
           return (status);
           }
         }
       } /* If PDU says "expand the part " */
        else
          {
        sprintf(a_row,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
        copy_data[nxi+n1], copy_data[nxi+n2], copy_data[nxi+n3],
        copy_data[nxi+n4], copy_data[nxi+n5], copy_data[nxi+n6],
        copy_data[nxi+n8], copy_data[nxi+n7]);
         _PDMdebug  (fname, "a_row-> %s\n", a_row) ;
         status = MEMwrite(*exp_copy_bufr,a_row);
         if(status != MEM_S_SUCCESS) {
            _PDMdebug (fn, "MEMwrite failed status %d\n", status);
            return (status);
            }
          }
       } /* Inside the for loop */
  _PDMdebug  (fname, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}

