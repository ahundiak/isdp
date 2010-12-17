#include "machine.h"
#include "stdio.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"


long _NFMload_error_message (item_name, item_rev, operation, operand, flag,
                             flag2)

char *item_name, *item_rev;
int  operation;  /* I: NFM_CHECK_IN, NFM_CHECK_OUT, or NFM_COPYFILES 
                       NFM_DEFINE_FILE, NFM_DEFINE_MEMBER,
                       NFM_CANCEL_CHECK_OUT, NFM_SAVE_FILES */
int  operand;    /* I: NFM_ITEM, NFM_SET, NFM_PRIMARY_MEMBER */
char *flag;      /* I: n_status value or n_pendingflag value */
char *flag2;      /* I: n_status value or n_pendingflag value */

{
  char *fname="_NFMload_error_message";

  _NFMdebug ( (fname, "ENTER: item_name = %s.%s operation = %d, \n\
                              operand = %d flag = %s\n", 
                              item_name, item_rev, operation, operand, flag) );
  switch (operation)
  {
    case NFM_CHECK_IN:
      switch (operand)
      {
        case NFM_ITEM:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin item, item is being accessed\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_CII_STATUS_S, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                        "Can't checkin item, item is checked out as set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN"))
          {
            ERRload_struct (NFM, NFM_E_CII_STATUS_M, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                        "Can't checkin item, item is checked out as member\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            if (!strcmp (flag2, "A"))
            {
              ERRload_struct (NFM, NFM_E_CII_ARCHIVE_A, "%s%s", item_name,
                              item_rev);
              _NFMdebug ((fname, "Can't checkin item, item is archived\n"));
            }
            else
            {
              ERRload_struct (NFM, NFM_E_CII_STATUS_I, "%s%s", item_name,
                              item_rev);
              _NFMdebug ((fname, "Can't checkin item, item is checked in\n"));
            }
          }
          break;
        case NFM_SET:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin set, set is being accessed\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_CIS_STATUS_M, "%s%s", 
                 item_name, item_rev);
            _NFMdebug ((fname, "Can't checkin set, item is M\n"));
          }
          else if (!strcmp (flag, "O"))
          {
            ERRload_struct (NFM, NFM_E_CIS_STATUS_O, "%s%s", 
                 item_name, item_rev);
            _NFMdebug ((fname, "Can't checkin set, item is O\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            if (!strcmp (flag2, "A"))
            {
              ERRload_struct (NFM, NFM_E_CIS_ARCHIVE_A, "%s%s", item_name,
                              item_rev);
              _NFMdebug ((fname, "Can't checkin item, item is archived\n"));
            }
            else
            {
              ERRload_struct (NFM, NFM_E_CIS_STATUS_I, "%s%s", 
                              item_name, item_rev);
              _NFMdebug ((fname, "Can't checkin set, item is I\n"));
            }
          }
          break;
        case NFM_PRIMARY_MEMBER:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin set, set is being accessed\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN"))
          {
            ERRload_struct (NFM, NFM_E_CIM_STATUS_S, "%s%s", 
                 item_name, item_rev);
            _NFMdebug ((fname, "Can't checkin set, item is M\n"));
          }
          else if (!strcmp (flag, "O"))
          {
            ERRload_struct (NFM, NFM_E_CIM_STATUS_O, "%s%s", 
                 item_name, item_rev);
            _NFMdebug ((fname, "Can't checkin set, item is O\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            if (!strcmp (flag2, "A"))
            {
              ERRload_struct (NFM, NFM_E_CIM_ARCHIVE_A, "%s%s", item_name,
                              item_rev);
              _NFMdebug ((fname, "Can't checkin item, item is archived\n"));
            }
            else
            {
              ERRload_struct (NFM, NFM_E_CIM_STATUS_I, "%s%s", 
                              item_name, item_rev);
              _NFMdebug ((fname, "Can't checkin set, item is I\n"));
            }
          }
          break;
      }
      break;
    case NFM_CHECK_OUT:
      switch (operand)
      {
        case NFM_ITEM:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin item, item is being accessed\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_COI_STATUS_S, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
              "Can't checkout item, item is checked out as a set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_COI_STATUS_M, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
              "Can't checkout item, item is checked out as a member\n"));
          }
          else if (!strcmp (flag, "O") || !strcmp (flag, "ON") )
          {
            ERRload_struct (NFM, NFM_E_COI_STATUS_O, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
              "Can't checkout item, item is checked out as an item\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_COI_ARCHIVE_A, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, item is archived\n"));
          }
          else if (!strcmp (flag, "IA"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_IA, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for archive\n"));
          }
          else if (!strcmp (flag, "IB"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_IB, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for backup\n"));
          }
          else if (!strcmp (flag, "IR"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_IR, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for restore\n"));
          }
          else if (!strcmp (flag, "ID"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_ID, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for delete\n"));
          }
          else if (!strcmp (flag, "SA"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_SA, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for archive as a set\n"));
          }
          else if (!strcmp (flag, "SB"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_SB, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for backup as a set\n"));
          }
          else if (!strcmp (flag, "SR"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_SR, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for restore as a set\n"));
          }
          else if (!strcmp (flag, "MA"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_MA, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for archive as a mem of a set\n"));
          }
          else if (!strcmp (flag, "MB"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_MB, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for backup as a mem of a set\n"));
          }
          else if (!strcmp (flag, "MR"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_MR, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for restore as a mem of a set\n"));
          }
          else if (!strcmp (flag, "PA"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_PA, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for archive as a project\n"));
          }
          else if (!strcmp (flag, "PB"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_PB, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for backup as a project\n"));
          }
          else if (!strcmp (flag, "PR"))
          {
            ERRload_struct (NFM, NFM_E_COI_PENDINGFLAG_PR, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, flagged for restore as a project\n"));
          }
          else if (!strcmp (flag, "Y") || !strcmp (flag, "C") )
          {
            ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't checkout item, item is locked\n"));
          }
          break;
        case NFM_SET:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkout set, set is being accessed\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM,  NFM_E_COS_STATUS_S, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                       "Can't checkout set, set is checked out as set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM,  NFM_E_COS_STATUS_M, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                       "Can't checkout set, set is checked out as member\n"));
          }
          else if (!strcmp (flag, "O") || !strcmp(flag, "ON") )
          {
            ERRload_struct (NFM,  NFM_E_COS_STATUS_O, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                       "Can't checkout set, set is checked out as item\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM,  NFM_E_COS_ARCHIVE_A, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                       "Can't checkout set, set is archived\n"));
          }
          else if (!strcmp (flag, "Y") || !strcmp (flag, "C") )
          {
            ERRload_struct (NFM,  NFM_E_ITEM_LOCKED, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                    "Can't checkout this set, it is locked\n"));
          }
          else if (!strcmp (flag, "IA"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_IA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the set, it is flagged for archive\n"));
          }
          else if (!strcmp (flag, "IB"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_IB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the set, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "IR"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_IR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the set, it is flagged for restore\n"));
          }
          else if (!strcmp (flag, "ID"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_ID, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the set, it is flagged for delete\n"));
          }
          else if (!strcmp (flag, "SA"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_SA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the set, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "SB"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_SB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the set, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "SR"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_SR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the set, it is flagged for restore\n"));
          }
          else if (!strcmp (flag, "MA"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_MA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't chekout the set, it is flagged for archive\n"));
          }
          else if (!strcmp (flag, "MB"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_MB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the set, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "MR"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_MR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the set, it is flagged for restore\n"));
          }
          else if (!strcmp (flag, "PA"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_PA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the set, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "PB"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_PB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the set, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "PR"))
          {
            ERRload_struct (NFM, NFM_E_COS_PENDINGFLAG_PR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the set, it is flagged for restore\n"));
          }
          break;
        case NFM_PRIMARY_MEMBER:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                 "Can't checkout this primary member, it is being accessed\n"));
          }
          else if (!strcmp (flag, "O"))
          {
            ERRload_struct (NFM,  NFM_E_COPM_STATUS_O, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is checked out as item\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM,  NFM_E_COPM_STATUS_S, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is checked out as set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM,  NFM_E_COPM_STATUS_M, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member,it's checked out as member\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM,  NFM_E_COPM_ARCHIVE_A, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                    "Can't checkout this primary member, it is archived\n"));
          }
          else if (!strcmp (flag, "Y") || !strcmp (flag, "C") )
          {
            ERRload_struct (NFM,  NFM_E_COPM_LOCK_YC, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                    "Can't checkout this primary member, it is locked\n"));
          }
          else if (!strcmp (flag, "IA"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_IA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out the primary member, it is flagged for archive\n"));
          }
          else if (!strcmp (flag, "IB"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_IB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary membe, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "IR"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_IR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary membe, it is flagged for restore\n"));
          }
          else if (!strcmp (flag, "ID"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_ID, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is flagged for delete\n"));
          }
          else if (!strcmp (flag, "SA"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_SA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't check out this primary member, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "SB"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_SB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary membe, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "SR"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_SR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is flagged for restore\n"));
          }
          else if (!strcmp (flag, "MA"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_MA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't chekout this primary member, it is flagged for archive\n"));
          }
          else if (!strcmp (flag, "MB"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_MB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary membe, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "MR"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_MR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is flagged for restore\n"));
          }
          else if (!strcmp (flag, "PA"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_PA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "PB"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_PB, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is flagged for backup\n"));
          }
          else if (!strcmp (flag, "PR"))
          {
            ERRload_struct (NFM, NFM_E_COPM_PENDINGFLAG_PR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this primary member, it is flagged for restore\n"));
          }
          break;
        case NFM_SECONDARY_MEMBER:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
              "Can't checkout this secondary member, it is being accessed\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM,  NFM_W_COSM_ARCHIVE_A, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                    "Can't checkout this secondary member, it is archived\n"));
          }
          else if (!strcmp (flag, "Y") || !strcmp (flag, "C") )
          {
            ERRload_struct (NFM,  NFM_W_COSM_LOCK_YC, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                    "Can't checkout this secondary member, it is locked\n"));
          }
          else if (!strcmp (flag, "IA"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_IA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the secondary member, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "IR"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_IR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this secondary membe, it's flagged for restore\n"));
          }
          else if (!strcmp (flag, "ID"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_ID, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout this secondary member, it's flagged for delete\n"));
          }
          else if (!strcmp (flag, "SA"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_SA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the secondary member, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "SR"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_SR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the secondary member, it's flagged for restore\n"));
          }
          else if (!strcmp (flag, "MA"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_MA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't chekout the secondary member, it is flagged for archive\n"));
          }
          else if (!strcmp (flag, "MR"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_MR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the secondary member, it's flagged for restore\n"));
          }
          else if (!strcmp (flag, "PA"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_PA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the secondary member, it's flagged for archive\n"));
          }
          else if (!strcmp (flag, "PR"))
          {
            ERRload_struct (NFM, NFM_W_COSM_PENDINGFLAG_PR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
            "Can't checkout the secondary member, it's flagged for restore\n"));
          }
          break;
      } 
      break;
    case NFM_COPYFILES:
      switch (operand)
      {
        case NFM_ITEM:
          if (!strlen (flag) || !strcmp (flag, "SN") || !strcmp (flag, "MN"))
          {
            ERRload_struct (NFM, NFM_E_CPI_STATUS_NULL, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item doesn't have files\n"));
          }
          else if (!strcmp (flag, "TI") || !strcmp (flag, "TF") )
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is being accessed\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_CPI_ARCHIVE_A, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is archived\n"));
          }
          else if (!strcmp (flag, "IA"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_IA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for archive\n"));

          }
          else if (!strcmp (flag, "IR"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_IR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for restore\n"));
          }
          else if (!strcmp (flag, "ID"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_ID, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for delete\n"));
          }
          else if (!strcmp (flag, "SA"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_SA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "SR"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_SR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for restore\n"));
          }
          else if (!strcmp (flag, "MA"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_MA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "MR"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_MR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for restore\n"));
          }
          else if (!strcmp (flag, "PA"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_PA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "PR"))
          {
            ERRload_struct (NFM, NFM_E_CPI_PENDINGFLAG_PR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, Item is flagged for restore\n"));
          }
          break;
        case NFM_PRIMARY_MEMBER:
          if (strlen (flag) && !strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "", NULL);
            _NFMdebug ((fname, "Can't copy, PM is not available\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_CPM_ARCHIVE_A, "",  NULL);
            _NFMdebug ((fname, "Can't copy, PM is archived\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'A'))
          {
            ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MA, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "PM is flagged for archive\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] ==  'R'))
          {
            ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MR, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "PM is flagged for restore\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'D'))
          {
            ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MD, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "PM is flagged for delete\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'B'))
          {
            ERRload_struct (NFM, NFM_E_CPM_PENDINGFLAG_MB, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "PM is flagged for backup\n"));
          }
          break;
        case NFM_SECONDARY_MEMBER:
          if (!strlen (flag) || !strcmp (flag, "SN") || !strcmp (flag, "MN"))
          {
            ERRload_struct (NFM, NFM_W_CPSM_STATUS_NULL, "", NULL);
            _NFMdebug ((fname, "Can't copy, SM doesn't have files\n"));
          }
          else if (!strcmp (flag, "TI") || !strcmp (flag, "TF") )
          {
            ERRload_struct (NFM, NFM_W_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't copy, SM is being accessed\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_W_CPSM_ARCHIVE_A, "",  NULL);
            _NFMdebug ((fname, "Can't copy, SM is archived\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'A'))
          {
            ERRload_struct (NFM, NFM_W_CPSM_PENDINGFLAG_A, "", NULL);
            _NFMdebug ((fname, "SM is flagged for archive\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'R'))
          {
            ERRload_struct (NFM, NFM_W_CPSM_PENDINGFLAG_R, "", NULL);
            _NFMdebug ((fname, "SM is flagged for restore\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'D'))
          {
            ERRload_struct (NFM, NFM_W_CPSM_PENDINGFLAG_D, "", NULL);
            _NFMdebug ((fname, "SM is flagged for delete\n"));
          }
          break;
        case NFM_SET:
          if (strlen (flag) && !strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "", NULL);
            _NFMdebug ((fname, "Can't copy, set is not available\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_CPS_ARCHIVE_A, "",  NULL);
            _NFMdebug ((fname, "Can't copy, Set is archived\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'A'))
          {
            ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SA, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "Set is flagged for archive\n"));
          }
          else if ((strlen (flag) == 2) &&  (flag[1] == 'R'))
          {
            ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SR, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "Set is flagged for restore\n"));
          }
          else if ((strlen (flag) == 2) &&  (flag[1] == 'D'))
          {
            ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SD, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "Set is flagged for delete\n"));
          }
          else if ((strlen (flag) == 2) && (flag[1] == 'B'))
          {
            ERRload_struct (NFM, NFM_E_CPS_PENDINGFLAG_SB, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "Set is flagged for backup\n"));
          }
          break;
      }
      break;
    case NFM_PLOT_ITEM:
      switch (operand)
      {
        case NFM_ITEM:
          if (!strlen (flag) || !strcmp (flag, "SN") || !strcmp (flag, "MN")||
              !strcmp (flag, "ON") )
          {
            ERRload_struct (NFM, NFM_E_PI_STATUS_NULL, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item doesn't have files\n"));
          }
          else if (!strcmp (flag, "TI") || !strcmp (flag, "TF") )
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is being accessed\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_PI_ARCHIVE_A, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is archived\n"));
          }
          else if (!strcmp (flag, "IA"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_IA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "IR"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_IR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for restore\n"));
          }
          else if (!strcmp (flag, "ID"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_ID, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for delete\n"));
          }
          else if (!strcmp (flag, "SA"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_SA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "SR"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_SR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for restore\n"));
          }
          else if (!strcmp (flag, "MA"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_MA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "MR"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_MR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for restore\n"));
          }
          else if (!strcmp (flag, "PA"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_PA, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for archive\n"));
          }
          else if (!strcmp (flag, "PR"))
          {
            ERRload_struct (NFM, NFM_E_PI_PENDINGFLAG_PR, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't plot, Item is flagged for restore\n"));
          }
          break;
        case NFM_SET:
          break;
      }
      break;
    case NFM_DEFINE_FILE:
      switch (operand)
      {
        case NFM_ADD_FILE_TO_ITEM:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't add, Item is being accessed\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_DFI_STATUS_I, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't add, Item's status = %s\n", flag));
          }
          break;
        case NFM_DELETE_FILE_FROM_ITEM:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't delete, Item is being accessed\n"));
          }
          else if (!strcmp (flag, "O") || !strcmp (flag, "ON") ||
                   !strcmp (flag, "M") ||
                   !strcmp (flag, "S") || !strcmp (flag, "MN") ||
                   !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_DFI_STATUS_OUT, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
                     "Can't delete, Item is checked out as item/member/set\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_ITEM_ARCHIVED, "%s", item_name);
            _NFMdebug ((fname, 
                "Can't delete, item is archived\n"));
          }
          break; 
        case NFM_CHANGE_FILE_INFORMATION:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't delete, Item is being accessed\n"));
          }
      }
      break;
    case NFM_DEFINE_MEMBER:
      switch (operand)
      {
        case NFM_SET:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't define member, status = %s\n", flag));
          }
          else if (!strcmp (flag, "O"))
          {
            ERRload_struct (NFM, NFM_E_DSM_STATUS_O, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "Can't define member, item is checked out\n")); 
          }
          else if ( !strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_DSM_STATUS_S, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is checked out as set\n")); 
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_DSM_STATUS_M, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
                       "Can't define member, item is checked out as member\n")); 
          }
          else if (!strcmp (flag, "Y"))
          {
            ERRload_struct (NFM, NFM_E_DSM_LOCK_Y, "%s%s", item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is locked without copy\n"));
          }
          else if (!strcmp (flag, "C"))
          {
            ERRload_struct (NFM, NFM_E_DSM_LOCK_C, "%s%s", item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is locked with copy\n"));
          }
          else if (!strcmp (flag, "A"))
          {
            ERRload_struct (NFM, NFM_E_DSM_ARCHIVE_STATE_A, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, "Can't define member, item is archived\n"));
          }
          else if ( strlen (flag) == 2 && flag[1] ==  'A')
          {
            ERRload_struct (NFM, NFM_E_DSM_PENDING_FLAG_A, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is flagged for archive\n"));
          }
          else if (strlen (flag) == 2 && flag[1] == 'B')
          {
            ERRload_struct (NFM, NFM_E_DSM_PENDING_FLAG_B, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is flagged for back-up\n"));
          }
          else if (strlen (flag) == 2 && flag[1] == 'R')
          {
            ERRload_struct (NFM, NFM_E_DSM_PENDING_FLAG_R, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is flagged for restore\n"));
          }
          else if (strlen (flag) == 2 && flag[1] == 'D')
          {
            ERRload_struct (NFM, NFM_E_DSM_PENDING_FLAG_D, "%s%s",
                            item_name, item_rev);
            _NFMdebug ((fname, 
                        "Can't define member, item is flagged for delete\n"));
          }
          break;
      }
      break; 
    case NFM_CANCEL_CHECK_OUT:
      switch (operand)
      {
        case NFM_ITEM:
          if (!strlen (flag))
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
               "Failed to cancel checked out item, item is not checked out"); 
            _NFMdebug ((fname, 
             "Can't cancel check-out-item, item is never in\n"));
          }
          else if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin item, item is being accessed\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                    "Failed to cancel checked out item, item is checked in");
            _NFMdebug ((fname, "Can't cancel check-out-item, \n\
                                item is checked in\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
             "Failed to cancel checked out item, item is checked out as set"); 
            _NFMdebug ((fname, 
                  "Can't cancel check-out-item, item is checked out as set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
            "Failed to cancel checked out item, item is checked out as a member of a set");
            _NFMdebug ((fname, 
               "Can't cancel check-out-item, item is checked out as member\n"));
          }
          break;
        case NFM_SET:
          if (!strlen (flag))
          {
            ERRload_struct (NFM, NFM_E_CCOS_NULL, "", NULL);
            _NFMdebug ((fname, 
             "Can't cancel check-out-set, set is never in\n"));
          }
          else if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't cancel set, set is being accessed\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_CCOS_STATUS_I, "", NULL); 
            _NFMdebug ((fname, "Can't cancel check-out-set, \n\
                                set is checked in\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_CCOS_M, "%s", NULL);

            _NFMdebug ((fname, 
               "Can't cancel check-out-set, set is checked out as member\n"));
          }
          else if (!strcmp (flag, "O") || !strcmp (flag, "ON"))
          {
             ERRload_struct (NFM, NFM_E_CCOS_O, "", NULL );
             _NFMdebug ((fname, 
              "Failed to cancel CO set, set is checked out as an item"));
          }
          break;
        case NFM_PRIMARY_MEMBER:
          if (!strlen (flag))
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
               "Failed to cancel checked out primary member, item is not checked out"); 
            _NFMdebug ((fname, 
             "Can't cancel check-out-item, item is never in\n"));
          }
          else if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin primary member, primary member is being accessed\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_CCOS_PM_I, "", NULL);
            _NFMdebug ((fname, "Can't cancel check-out-item, \n\
                                item is checked in\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
             "Failed to cancel checked out primary member, primary member is checked out as set"); 
            _NFMdebug ((fname, 
                  "Can't cancel check-out-item, item is checked out as set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
            "Failed to cancel checked out primary member, primary member is checked out as a member of a set");
            _NFMdebug ((fname, 
               "Can't cancel check-out-item, item is checked out as member\n"));
          }
          break;
      }
      break;
    case NFM_SAVE_FILES:
      switch (operand)
      {
        case NFM_ITEM:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin item, item is being accessed\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN") )
          {
            ERRload_struct (NFM, NFM_E_SIF_STATUS_S, "", NULL);
            _NFMdebug ((fname, 
               "Can't save item's files, item is checked out as set\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN"))
          {
            ERRload_struct (NFM, NFM_E_SIF_STATUS_M, "",  NULL);
            _NFMdebug ((fname, 
               "Can't save item files, item is checked out as member\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_SIF_STATUS_I, "", NULL);
            _NFMdebug ((fname, 
               "Can't save item's files, item is checked in\n"));
          }
          else if (strlen (flag) < 1)
          {
            ERRload_struct (NFM, NFM_E_SIF_STATUS_NULL, "", NULL);
            _NFMdebug ((fname, 
               "Can't save item's files, item is never checked in\n"));
          }
          break;
        case NFM_SET:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, 
               "Can't save set files, set is being accessed\n"));
          }
          else if (!strcmp (flag, "M") || !strcmp (flag, "MN") )
          {
            ERRload_struct (NFM, NFM_E_SSF_STATUS_M, "", NULL);
            _NFMdebug ((fname, 
               "Can't save set files, item is cwchecked out as a memberM\n"));
          }
          else if (!strcmp (flag, "O"))
          {
            ERRload_struct (NFM, NFM_E_SSF_STATUS_O, "", NULL);
            _NFMdebug ((fname, 
               "Can't save set files, item is checked out as an item\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_SSF_STATUS_I, "", NULL);
            _NFMdebug ((fname, 
               "Can't save set files, item is not checked out\n"));
          }
          break;
        case NFM_PRIMARY_MEMBER:
          if (!strncmp (flag, "T", 1))
          {
            ERRload_struct (NFM, NFM_E_TEMP_UNAVAILABLE, "%s%s", item_name,
                            item_rev);
            _NFMdebug ((fname, "Can't checkin set, set is being accessed\n"));
          }
          else if (!strcmp (flag, "S") || !strcmp (flag, "SN"))
          {
            ERRload_struct (NFM, NFM_E_SMF_STATUS_S, "%s%s", 
                 item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't save member's files, member is checked out as a set\n"));
          }
          else if (!strcmp (flag, "O"))
          {
            ERRload_struct (NFM, NFM_E_SMF_STATUS_O, "%s%s", 
                 item_name, item_rev);
            _NFMdebug ((fname, 
              "Can't save member's files, member is checked out as an item\n"));
          }
          else if (!strcmp (flag, "I"))
          {
            ERRload_struct (NFM, NFM_E_SMF_STATUS_I, "%s%s", 
                            item_name, item_rev);
            _NFMdebug ((fname, 
               "Can't save member's files, member is not checked out\n"));
          }
          break;
      }
      break;
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
