#include "machine.h"
#include <stdio.h>
#include "SQLerrordef.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

#define MAX_RETRY            30
#define SHARE_LOCK_MAX_RETRY 50
#define RETRY_INTERVAL 1

long NFMlock_table (table_names)

/***

  This function will lock specified table(s). If it fails and reason == 
  "lock table statement is not the first statement of the transaction", 
  it issues "commit" statement before the retry. It does 30 tries in 
  interval of 1.


***/

char *table_names;

{
  char *fname="NFMlock_table";
  char sql_str[1024];
  int i;
  long status;

  _NFMdebug ( (fname, "ENTER: lock: %s\n", table_names) );
  sprintf (sql_str, "LOCK TABLES %s IN EXCLUSIVE MODE", table_names);
  status = SQLstmt (sql_str);
  if (status == SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
    return (NFM_S_SUCCESS);
  }
  else if (status == SQL_E_INVALID_LOCK_TABLES)
  {
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
      _NFMdebug ((fname, "SQLstmt (commit work): 0x%.8x\n", status));
  }
  for (i = 0; i < MAX_RETRY; i++)
  {
    sleep (RETRY_INTERVAL);
    status = SQLstmt (sql_str);
    if (status == SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
      return (NFM_S_SUCCESS);
    }
    else if (status == SQL_E_INVALID_LOCK_TABLES)
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLstmt (commit work): 0x%.8x\n", status));
    }
  }
  
  /* since RIS do not return a specific error status at this point (11/19/91),
     I/NFM needs to load this error so application (such as PDM/PDU) can
     get some error about locking table */

  ERRload_struct (NFM, NFM_E_LOCK_TABLE_FAILED, "", NULL);
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_E_LOCK_TABLE_FAILED) );
  return (NFM_E_LOCK_TABLE_FAILED);
}

long NFMsharelock_table (table_names)

/***

  This function will lock specified table(s). If it fails and reason == 
  "lock table statement is not the first statement of the transaction", 
  it issues "commit" statement before the retry. It does 30 tries in 
  interval of 1.

  Added For Duke Power Duplicate Problem -- Jujare 

***/

char *table_names;

{
  char *fname="NFMsharelock_table";
  char sql_str[1024];
  int i;
  long status;

  _NFMdebug ( (fname, "ENTER: lock: %s\n", table_names) );
  sprintf (sql_str, "LOCK TABLES %s IN SHARE MODE", table_names);
  status = SQLstmt (sql_str);
  if (status == SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
    return (NFM_S_SUCCESS);
  }
  else if (status == SQL_E_INVALID_LOCK_TABLES)
  {
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
      _NFMdebug ((fname, "SQLstmt (commit work): 0x%.8x\n", status));
  }
  for (i = 0; i < SHARE_LOCK_MAX_RETRY ; i++)
  {
    sleep (RETRY_INTERVAL);
    status = SQLstmt (sql_str);
    if (status == SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
      return (NFM_S_SUCCESS);
    }
    else if (status == SQL_E_INVALID_LOCK_TABLES)
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLstmt (commit work): 0x%.8x\n", status));
    }
  }
  
  /* since RIS do not return a specific error status at this point (11/19/91),
     I/NFM needs to load this error so application (such as PDM/PDU) can
     get some error about locking table */

  ERRload_struct (NFM, NFM_E_LOCK_TABLE_FAILED, "", NULL);
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_E_LOCK_TABLE_FAILED) );
  return (NFM_E_LOCK_TABLE_FAILED);
}
