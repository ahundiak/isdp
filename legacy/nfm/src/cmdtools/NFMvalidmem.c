#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMapi.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "NFMstruct.h"

long NFMvalid_user_and_members_to_be (user_no, members_to_define,
                                     members_info)
long user_no;
long members_to_define;
struct NFMmember_info *members_info;

{
  char *fname="NFMvalid_user_and_members_to_be";
  char **data1, **data2;
  char sql_str[1024], dumb_str[2], warn_str[1024];
  long status, dumb_value;
  long co_no=-1, cpf_no=-1, i, load_warning, index;
  MEMptr list1=NULL, list2=NULL;

  _NFMdebug ((fname, "ENTER: user_no = %d\n\
                      if the item is to be added as primary\n\
                        -- check the user against <CO> permission\n\
                      else if the item is to be added as secondary\n\
                        -- check the user against <CPFile> permission\n",
                      user_no));

  sprintf (sql_str, "%s %s %s",
           "select n_commandno, n_commandname, n_nfmcommandno, n_entity from",
           "nfmcommands where n_commandname = 'Check Out Item' or",
           "n_commandname = 'Copy Item Files'");

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR,
                                   dumb_str, &dumb_value, &list1);
  if (status == SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ((fname, "Cannot find command #s for CO & CPFiles\n"));
    ERRload_struct (NFM, NFM_E_DSM_NO_COMMAND, "%s",
            "Check Out Item, Copy Item Files");
    return (NFM_E_DSM_NO_COMMAND);
  } 
  else if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "failed to retrieve command #s for CO and CPFiles\n"));
    return (status);
  }

  data1 = (char **) list1->data_ptr;

  for (i = 0; i < list1->rows; i++)
  {
    index = i * list1->columns;
    _NFMdebug ((fname, "command name = %s\n", data1[index+1]));
    if (!strncmp (data1[index+1], "Check Out Item", 14))
    {
      co_no = atol (data1[index]);
      _NFMdebug ((fname, "CO command number = %d\n", co_no));
    }
    else if (!strncmp (data1[index+1], "Copy Item Files", 15))
    {
      cpf_no = atol (data1[index]);
      _NFMdebug ((fname, "CPFiles command number = %d\n", cpf_no));
    }
  }

  MEMclose (&list1);

  for (i = load_warning = 0; i < members_to_define; i++)
  {
    _NFMdebug ((fname, "item %s.%s, type [%s]\n",
                (members_info+i)->item_name, (members_info+i)->item_rev,
                (members_info+i)->type));
    sprintf (sql_str, "%s %s %s %s %s '%s' %s '%s' %s %s %s",
      "select a.n_itemno, a.n_stateno, a.n_aclno, c.n_workflowno,",
      "c.n_workflowname, b.n_statename, d.n_aclname from",
      (members_info+i)->catalog_name, "a, nfmstates b, nfmworkflow c,",
      "nfmacls d where a.n_itemname =", (members_info+i)->item_name,
      "and a.n_itemrev =", (members_info+i)->item_rev, "and a.n_stateno = ",
      "b.n_stateno and d.n_workflowno = c.n_workflowno and",
      "a.n_aclno = d.n_aclno");

    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str, 
                                 &dumb_value, &list1);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list1);
      load_warning++;
      strcat (warn_str, " ");
      strcat (warn_str, (members_info+i)->item_name);
      strcat (warn_str, ".");
      strcat (warn_str, (members_info+i)->item_rev);
      _NFMdebug ((fname, "query failed, do not add this member\n"));
      (members_info+i)->operation = 0;
      continue;
    }
   
    data1 = (char **) list1->data_ptr;
    if (!strcmp ((members_info+i)->type, "P"))
    {
      _NFMdebug ((fname, "adding as primary, check the user against CO\n"));
      sprintf (sql_str, 
        "%s %s %s %d %s %s %s %s %s",
        "select a.n_transitionno, a.n_tostate, a.n_transitionname,",
        "b.n_statename from nfmtransitions a, nfmstates b where",
        "a.n_commandno =", co_no, "and a.n_workflowno =", data1[3],
        "and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate =",
        data1[1], ") and a.n_tostate = b.n_stateno");
    }
    else if (!strcmp ((members_info+i)->type, "S"))
    {
      _NFMdebug ((fname, 
                  "adding as secondary, check the user against CPFiles\n"));
      sprintf (sql_str, 
        "%s %s %s %d %s %s %s %s %s",
        "select a.n_transitionno, a.n_tostate, a.n_transitionname,",
        "b.n_statename from nfmtransitions a, nfmstates b where",
        "a.n_commandno =", cpf_no, "and a.n_workflowno =", data1[3],
        "and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate =",
        data1[1], ") and a.n_tostate = b.n_stateno");
    }
    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR,
                                 dumb_str, &dumb_value, &list2);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list1);
      MEMclose (&list2);
      load_warning++;
      strcat (warn_str, " ");
      strcat (warn_str, (members_info+i)->item_name);
      strcat (warn_str, ".");
      strcat (warn_str, (members_info+i)->item_rev);
      _NFMdebug ((fname, "query failed, do not add this member\n"));
      (members_info+i)->operation = 0;
      continue;
    }

    data2 = (char **) list2->data_ptr;
    sprintf (sql_str, "%s %s %s %s %d %s %s %s",
      "select b.n_userno from nfmaccess a, nfmaclusers b where",
      "a.n_transitionno =", data2[0], "and b.n_userno =",
      user_no, "and b.n_aclno =", data1[2],
      "and a.n_classno = b.n_classno");

    MEMclose (&list2);

    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR,
                                 dumb_str, &dumb_value, &list2);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list1);
      MEMclose (&list2);
      load_warning++;
      strcat (warn_str, " ");
      strcat (warn_str, (members_info+i)->item_name);
      strcat (warn_str, ".");
      strcat (warn_str, (members_info+i)->item_rev);
      _NFMdebug ((fname, "query failed, do not add this member\n"));
      (members_info+i)->operation = 0;
      continue;
    }
    MEMclose (&list1);
    MEMclose (&list2);
  }
  if (load_warning == members_to_define)
  {
    _NFMdebug ((fname, "No member could be addded\n"));
    ERRload_struct (NFM, NFM_E_DSM_NULL, "", NULL);
    return (NFM_E_DSM_NULL);
  }
  else if (load_warning)
  {
    _NFMdebug ((fname, "one/some item(s) cannot be added as member(s)\n"));
    ERRload_struct (NFM, NFM_W_DSM_NA, "%s", warn_str);
  }
  _NFMdebug ((fname, "EXIT successfully, load_warning = %d\n",
              load_warning));
  return (NFM_S_SUCCESS);
}
