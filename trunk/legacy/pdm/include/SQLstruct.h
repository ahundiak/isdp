/* #include "RISlimits.h" */
#define uchar unsigned char

struct SQLglobal_st
{
  char ris_print_format[50] ;              /* ris print format */
  long DBerror_no ;                        /* DB error no */
  char DBerror_msg [80] ;                  /* Db error msg */
  char	db_type;                           /* Db type */
  
};
