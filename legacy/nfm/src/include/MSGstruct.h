#ifndef MSGPTR_H
#define MSGPTR_H
  typedef struct  msg_struct
   {
     int     debug_on;
     char    debug_file [48];
     long    error_no;
     char    error_msg  [80];
   } MSGptr;
#endif
