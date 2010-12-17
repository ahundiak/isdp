#include "NFMschema.h"
/* MSSP - 29 Dec 93. changed UNIX to OS_UNIX */
#ifdef OS_UNIX
#else
typedef struct  msg_struct
{
     int     debug_on;
     char    debug_file [48];
     long    error_no;
     char    error_msg  [80];
} CLIptr;

typedef struct NFMwf_info
{
     short     temp;
};

typedef struct NFMoperation
{
     short     temp;
};
#endif

typedef struct entry
{
    char  word[21];
    long   type;
};

typedef struct add_item_info
{
  char item [NFM_ITEMNAME+1] ;
  char rev [NFM_ITEMREV +1];
  char description [NFM_DESCRIPTION+1] ;
  char version [20]  ;
  char  aclname [NFM_ACLNAME+1] ;
  char  localfile [NFM_COFILENAME+1] ;
  char  filetype [NFM_FILETYPE+1] ;
  char  cisaname [NFM_SANAME+1] ;
  char  cifile [NFM_CIFILENAME+1] ;
} ;









