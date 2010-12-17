#include "machine.h"
#include "NFMsysinc.h"

 MSGptr         NFMmsg_ptr  = {0, "/dev/console", 0, ""};

 MSGptr         INITmsg_ptr = {1, "/dev/console", 0, ""};

 static struct NFMattributes NFMattr = 
           { 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 
            11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
            22, 23, 24, 25, 26, 27, 28, 29, 30};

 long NFMsql_lock = 0;

 _sql_error (status)
   long    status;
   {
      /*
      unsigned int   context_code, sql_code;

      context_code = (unsigned int) (status >> 16);
      sql_code     = (unsigned int) (status & 0x0000ffff);
      */

      _NFM_num ("SQL ERROR : Status             = < 0x%.8x >  ", status      );

      /*
      _NFM_num ("SQL ERROR : SQL     error code = <%d>  ", sql_code    );
      _NFM_num ("SQL ERROR : Context error code = <%d>\n", context_code);
      */
   }


 _INIT_str (str, var)
  char  *str, *var;
  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (INITmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (INITmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFM INIT : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }
 

 _INIT_num (str, var)
  char  *str;
  long  var;
  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (INITmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (INITmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFM INIT : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

 _NFM_num (str, var)
  char  *str;
  long  var;
  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (NFMmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (NFMmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFM : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

 _NFM_str (str, var)
  char  *str, *var;
  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (NFMmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (NFMmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFM : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

 long NFMerror (err)
   long   err;
   {
     _NFM_num ("NFM ERROR : ERROR NUMBER : <%d>\n", err);

     switch (err)
      {
        default :
          strncpy (NFMmsg_ptr.error_msg, "ERROR ERROR", 78);
          break;
      }
     
     NFMmsg_ptr.error_msg [79] = 0;
     NFMmsg_ptr.error_no       = err;

     return (err);
   }

long _SER_str (str, var)
  char  *str, *var;
{
    FILE   *NFMdbg_ptr, *fopen ();

    NFMdbg_ptr = fopen ("/usr/tmp/NFMserver.log", "a");
    if (NFMdbg_ptr)
      {
	fprintf (NFMdbg_ptr, str, var);
	fprintf (NFMdbg_ptr, " ");
	fclose  (NFMdbg_ptr);
      }
  }


long _SER_num (str, var)
  char  *str, *var;
{
    FILE   *NFMdbg_ptr, *fopen ();

    NFMdbg_ptr = fopen ("/usr/tmp/NFMserver.log", "a");
    if (NFMdbg_ptr)
      {
	fprintf (NFMdbg_ptr, str, var);
	fprintf (NFMdbg_ptr, " "); 
	fclose  (NFMdbg_ptr);
      }
  }

