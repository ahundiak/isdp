/***********************************************************************
 *                                                                     *
 *  PDU status structure -                                             *
 *                                                                     *
 *  A structure is provided to allow multiple statuses returned        *
 *  from lower level sub-systems to be reported and translated         *
 *  into appropriate output for the user.                              *
 *                                                                     *
 ***********************************************************************/

typedef struct PDUsts_st
 {
  long  command;
  long  PDUstatus;
  long  PDMrstatus;
  long  PDMsstatus;
  long  NFMstatus;
  long  SQLstatus;
  long  MEMstatus;
  long  NETstatus;
} *PDUsts_ptr;
