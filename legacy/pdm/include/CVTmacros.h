/* CVT debug include file */

#include	<stdio.h>

extern FILE *CVTconsole;
extern int  _CVTdebug_;

#define _CVT_dbg(message, variable) \
    if ( _CVTdebug_ ) \
     { \
       fprintf(CVTconsole, "CVT : "); \
       fprintf(CVTconsole, (message), (variable)); \
       fprintf(CVTconsole, "\n"); \
     }
#define CVT_DATA     -1
#define CVT_NO_DATA  -2
#define NO_ROWS      -3

typedef struct   {
  int num_of_rows, num_of_cols ;
  char **data ;
} UNIT_INFO ;

typedef struct  {
   short name, datatype, synonym, nfmname ;
   short opentonfm, application, read, write ;
   short update, delete, null, keyin ;
   short checkin, checkout, seqno, listno ;
} INDEX ;


#define ECHO_S 0
#define NOECHO 1

typedef struct Unit_Data 
{
  long index ;
  char *data ;
  struct  Unit_Data *next, *prev ;
}  UNIT_DATA ;



#define MSG_ABORTED "Interrupt\n"
/*  Global NFM structure  */

typedef struct NFMglobal_st {
  short debug_on ;
  char  debug_file[50] ;
} NFMglobal;

#define S_ENV           0
#define S_USR_NAME      1
#define S_PASSWD        2
#define S_OLD_DB        3
#define S_ACTIVITY      4
#define S_LOG           5
#define S_NFM_DBG       6
#define S_SQL_DBG       7
#define S_MEM_DBG       8
#define S_OLD_SQL_DBG   9
#define S_CVT_DBG      10
#define S_NET_DBG      11
