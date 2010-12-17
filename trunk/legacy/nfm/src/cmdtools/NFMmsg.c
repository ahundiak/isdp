#include "machine.h"
#include "stdio.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

long _NFMload_message (item_name, item_rev, operation, flag)

/***

  This is an old function from I/NFM 2.X.X. It will be eliminated when time
  comes.

***/

char *item_name, *item_rev;
int  operation;  /* 0 - checkin, 1 - checkout, 2 - copy */
                 /* 3 - checkin member, 4 checkin set, */
                 /* 5 - checkout member, 6 checkout set, */
char *flag;      /* n_coout value or n_pendingflag value */

{
  char *fname="_NFMload_message";

  _NFMdebug ( (fname, "ENTER: item_name = %s.%s operation = %d, flag = %s\n", 
                              item_name, item_rev, operation, flag) );

  if (!strcmp (flag, "O") && (operation == 1))
  {
    ERRload_struct (NFM, NFM_E_COI_STATUS_O, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COI_STATUS_O\n"));
  }
  else if ( (!strcmp (flag, "S") || !strcmp (flag, "SN") )
       && (operation == 1))
  {
    ERRload_struct (NFM, NFM_E_COI_STATUS_S, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COI_STATUS_S\n"));
  }
  else if ( (!strcmp (flag, "M") || !strcmp (flag, "MN") )
       && (operation == 1))
  {
    ERRload_struct (NFM, NFM_E_COI_STATUS_M, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COI_STATUS_M\n"));
  }
  else if (!strcmp (flag, "I") && (operation == 0))
  {
    _NFMdebug ( (fname, "format <%s> item_name <%s> item_rev <%s>\n",
                         "%s%s", item_name, item_rev) ); 
    ERRload_struct (NFM, NFM_E_CII_STATUS_I, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CII_STATUS_I\n"));
  }
  else if ((!strcmp (flag, "S") || !strcmp (flag, "SN") )
           && (operation == 0))
  {
    ERRload_struct (NFM, NFM_E_CII_STATUS_S, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CII_STATUS_S\n"));
  }
  else if ((!strcmp (flag, "M") || !strcmp (flag, "MN") )
           && (operation == 0))
  {
    ERRload_struct (NFM, NFM_E_CII_STATUS_M, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CII_STATUS_M\n"));
  }
  else if (!strcmp (flag, "O") && (operation == 3))
  {
    ERRload_struct (NFM, NFM_E_CIM_STATUS_O, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CIM_STATUS_O\n"));
  }
  else if ((!strcmp (flag, "S") || !strcmp (flag, "SN") )
           && (operation == 3))
  {
    ERRload_struct (NFM, NFM_E_CIM_STATUS_S, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CIM_STATUS_S\n"));
  }
  else if (!strcmp (flag, "O") && (operation == 4))
  {
    ERRload_struct (NFM, NFM_E_CIS_STATUS_O, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CIS_STATUS_O\n"));
  }
  else if ((!strcmp (flag, "M") || !strcmp (flag, "MN") )
           && (operation == 4))
  {
    ERRload_struct (NFM, NFM_E_CIS_STATUS_M, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CIS_STATUS_M\n"));
  }
  else if (!strcmp (flag, "O") && (operation == 6))
  {
    ERRload_struct (NFM, NFM_E_COS_STATUS_O, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COS_STATUS_O\n"));
  }
  else if ((!strcmp (flag, "S") || !strcmp (flag, "SN") )
           && (operation == 6))
  {
    ERRload_struct (NFM, NFM_E_COS_STATUS_S, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COS_STATUS_S\n"));
  }
  else if ((!strcmp (flag, "M") || !strcmp (flag, "MN") )
           && (operation == 6))
  {
    ERRload_struct (NFM, NFM_E_COS_STATUS_M, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COS_STATUS_M\n"));
  }
  else if ( (!strcmp (flag, "M") || !strcmp (flag, "MN") )
            && (operation == 5))
  {
    ERRload_struct (NFM, NFM_E_COM_STATUS_M, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COM_STATUS_M\n"));
  }
  else if ( (!strcmp (flag, "S") || !strcmp (flag, "SN") )
            && (operation == 5))
  {
    ERRload_struct (NFM, NFM_E_COM_STATUS_S, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COM_STATUS_S\n"));
  }
  else if ( !strcmp (flag, "O") && (operation == 5))
  {
    ERRload_struct (NFM, NFM_E_COM_STATUS_O, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COM_STATUS_O\n"));
  }
  else if (!strcmp (flag, "") && ((operation == 1) || (operation == 5) ||
                                  (operation == 6) ) )
  {
    ERRload_struct (NFM, NFM_E_COI_STATUS_NULL, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_COI_STATUS_NULL\n"));
  }
  else if (!strcmp (flag, "TI") || !strcmp (flag, "TO") )
  {
    ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_TEMP_UNAVAILABLE\n"));
  }
  else if (!strcmp (flag, "") && (operation == 2))
  {
    ERRload_struct (NFM, NFM_E_CPI_STATUS_NULL, "%s%s", item_name, item_rev);
    _NFMdebug ( (fname, "NFM_E_CPI_STATUS_NULL\n"));
  }
  else if (!strcmp (flag, "IA")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CII_PENDINGFLAG_IA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IA")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_IA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IA")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_IA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IB")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CII_PENDINGFLAG_IB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IB")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_IB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IB")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_IB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IR")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CII_PENDINGFLAG_IR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IR")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_IR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "IR")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_IR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "ID")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CII_PENDINGFLAG_ID, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "ID")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_ID, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "ID")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_ID, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SA")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CIS_PENDINGFLAG_SA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SA")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_SA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SA")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SB")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CIS_PENDINGFLAG_SB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SB")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_SB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SB")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SR")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CIS_PENDINGFLAG_SR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "SR")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_SR, "%s%s", item_name, item_rev);

  }
  else if (!strcmp (flag, "SR")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MA")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CIM_PENDINGFLAG_MA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MA")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_MA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MA")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MA, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MB")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CIM_PENDINGFLAG_MB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MB")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_MB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MB")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MB, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MR")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CIM_PENDINGFLAG_MR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MR")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_MR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "MR")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MR, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "A")  && (operation == 0) )
  {
    ERRload_struct (NFM, NFM_E_CII_ARCHIVE_A, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "A")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COI_ARCHIVE_A, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "A")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPI_ARCHIVE_A, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "B")  && (operation == 1) )
  {
    ERRload_struct (NFM, NFM_E_COI_ARCHIVE_B, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "B")  && (operation == 2) )
  {
    ERRload_struct (NFM, NFM_E_CPI_ARCHIVE_B, "%s%s", item_name, item_rev);
  }
  else if (!strcmp (flag, "PA") )
  {
    ERRload_struct (NFM, NFM_E_PROJ_FLAG_ARCHIVE, NULL); 
  }
  else if (!strcmp (flag, "PB") )
  {
    ERRload_struct (NFM, NFM_E_PROJ_FLAG_BACKUP, NULL); 
  }
  else if (!strcmp (flag, "PR") )
  {
    ERRload_struct (NFM, NFM_E_PROJ_FLAG_RESTORE, NULL); 
  }
  else if (!strcmp (flag, "pA") )
  {
    ERRload_struct (NFM, NFM_E_ITEM_FLAG_ARCHIVE, NULL); 
  }
  else if (!strcmp (flag, "pB") )
  {
    ERRload_struct (NFM, NFM_E_ITEM_FLAG_BACKUP, NULL); 
  }
  else if (!strcmp (flag, "pR") )
  {
    ERRload_struct (NFM, NFM_E_ITEM_FLAG_RESTORE, NULL); 
  }
  else
  {
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Command failed");
  }
  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
