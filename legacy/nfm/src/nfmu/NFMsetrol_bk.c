#include "machine.h"
#include <stdio.h>
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"

extern struct set_info1 *NFMset_list1;
extern struct attr_info1 *NFMcat_list;


long _NFMrollback_set ()

{

  char *fname="_NFMrollback_set";
  char sql_str[1024], value[50];
  long status, version;
  struct set_info1 *head_set1;
  struct attr_info1 *head_cat;

  _NFMdebug ( (fname, "ENTER: \n") );

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
    _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));

  /*
  for (head_set=NFMset_list; head_set != (struct set_info *)NULL;
       head_set=head_set->next)
  {    
    if (!strcmp (head_set->type, "P") )
    {
       sprintf (sql_str, "UPDATE %s SET n_status = '%s' WHERE %s = %s ",
                head_set->table_name, head_set->cat_item.n_coout.data_value,
                head_set->cat_item.n_itemno.attr_name,
                head_set->cat_item.n_itemno.data_value);

       status = NFMlock_table (head_set->table_name);
       if (status != NFM_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );

       status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname,"WARNING! 0x%.8x\n", status));

       status = SQLstmt ("COMMIT WORK");
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );
    }
  }
  */
  for (head_set1=NFMset_list1; head_set1 != (struct set_info1 *)NULL;
       head_set1=head_set1->next)
  {
    if (!strcmp (head_set1->type, "P") )
    {
      for (head_cat = NFMcat_list; head_cat != (struct attr_info1 *) NULL;
                               head_cat = head_cat->next)
      {
        _NFMdebug ((fname, "head_cat->table_no [%d], head_set->table_no [%d]\n",
                             head_cat->table_no, head_set1->table_no) );
        if (head_cat->table_no == head_set1->table_no)
          break;
      }
       sprintf (sql_str, "UPDATE %s SET n_status = '%s' WHERE %s = %s ",
                head_cat->table_name, head_set1->coout_v,
                head_cat->itemno_n,
                head_set1->itemno_v);

       status = NFMlock_table (head_cat->table_name);
       if (status != NFM_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );
       status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
       status = SQLstmt ("COMMIT WORK");
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));

    }

  }


  _NFMdebug ( (fname, "EXIT 0x%.8x", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}

long _NFMrollback_fcat_records ()

{

  char *fname="_NFMrollback_fcat_records";
  char sql_str[1024], value[50], fcat_name[61];
  char sql_str1[1024];
  long status, version;
  long cur_cat_no;
  struct set_info1 *head_set;
  struct attr_info1 *cur_cat;

  _NFMdebug ( (fname, "ENTER: \n") );

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
    _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));

  for (head_set=NFMset_list1; head_set != (struct set_info1 *)NULL;
       head_set=head_set->next)
  {
    if (!strcmp (head_set->type, "P") )
    {
       if (cur_cat_no != head_set->table_no)
       {
         for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
          cur_cat=cur_cat->next)
         if (cur_cat->table_no == head_set->table_no)
         {
           cur_cat_no = cur_cat->table_no;
           break;
         }
       }
       sprintf (sql_str, "DELETE FROM f_%s WHERE %s = ",
                cur_cat->table_name, cur_cat->itemnum_n);

       sprintf (sql_str1, "UPDATE f_%s SET n_fileco = 'Y' WHERE %s = ",
                cur_cat->table_name, cur_cat->itemnum_n);

       if (!strncmp (cur_cat->itemnum_d, "char", 4) )
       {
         strcat (sql_str, "'");
         strcat (sql_str, head_set->itemno_v);
         strcat (sql_str, "'");
         strcat (sql_str1, "'");
         strcat (sql_str1, head_set->itemno_v);
         strcat (sql_str1, "'");
       }
       else
       {
         strcat (sql_str, head_set->itemno_v);
         strcat (sql_str1, head_set->itemno_v);
       }
 
       strcat (sql_str, " AND ");
       strcat (sql_str, cur_cat->fileversion_n);
       strcat (sql_str, " = ");

       strcat (sql_str1, " AND ");
       strcat (sql_str1, cur_cat->fileversion_n);
       strcat (sql_str1, " = ");

       version = atol(head_set->fileversion_v) + 1;
       sprintf ( value, "%d", version);
       if (!strncmp (cur_cat->fileversion_d, "char", 4) )
       {
         strcat (sql_str, "'");
         strcat (sql_str, value);
         strcat (sql_str, "'");
         strcat (sql_str1, "'");
         strcat (sql_str1, value);
         strcat (sql_str1, "'");
       }
       else
       {
         strcat (sql_str, value);
         strcat (sql_str1, value);
       }
       sprintf (fcat_name, "f_%s", cur_cat->table_name);
       status = NFMlock_table (fcat_name);
       if (status != NFM_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status) );
       status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
       status = SQLstmt (sql_str1);
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname,"WARNING! 0x%.8x", status));
       status = SQLstmt ("COMMIT WORK");
       if (status != SQL_S_SUCCESS)
         _NFMdebug ( (fname, "WARNING! 0x%.8x\n", status));

    }

  }
 
  _NFMdebug ( (fname, "EXIT 0x%.8x", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
