#include "NFMschema.h"

struct CVTglobal_st
{
  char date_type [50] ;                  /* AMERICAN or ANSI */
  char schema_name [15] ;                /* schema name */
  char schema_passwd [51] ;              /* schema passwd - decrypted */
  char log_file [15] ;                   /* log file */
  short NFM_STOP_CONVERT ;               /* init to 0 ; 1 = stop */
  char database [20] ;                   /* make of database */
  char catalog [NFM_CATALOGNAME+1] ;     /* catalogname */
  char f_catalog [NFM_CATALOGNAME+1] ;   /* catalogname */
  char o_catalog [NFM_CATALOGNAME+1] ;   /* catalogname */
  char o_f_catalog [NFM_CATALOGNAME+1] ; /* catalogname */
  char env_name [14] ;                   /* environment name */
  int  num_of_attr;
  struct CVTattr_st *root_attr ;
}; 


struct CVTtables_st
{
	char table_name[100];
};

struct CVTattr_st
{
	char attr_name[100];
	struct CVTattr_st *next_attr;
};

