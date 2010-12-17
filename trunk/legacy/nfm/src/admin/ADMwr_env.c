#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFIcommands.h"
#include <pwd.h>
/* Added header file for SUN/SCO port - SSRS - 7/12/93 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
#include "NFMenv.h"  
#endif
 
 long NFMcreate_env_node (nodename, schema)
 char   *nodename ;
 MEMptr schema;
   {
      long      status;
      FILE      *fopen (), *in_file,*env_file;
      char      own_env [100],tot_env[100];
      char      str [100];
      char      **data;
      static char *fname = "NFMcreate_env_node";
      struct passwd *pwd;

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
      /* Added code to write environment information to NFMowne.dat file.
         On Clipper writes information to /usr/lib/nodes/owned/nfme_* file.
         SSRS - 7/12/93
      */

      pwd = getpwnam( "nfmadmin" );
      sprintf (own_env, "%s/%s/%s", pwd->pw_dir, ENV_PATH, OWNENV_FILE); 
      sprintf (tot_env, "%s/%s/%s", pwd->pw_dir, ENV_PATH, ENV_FILE); 

      /* Before writing changed information we should delete existing 
         information regarding this environment                       
      */
      str[0] =0;
      sprintf(str, "nfme_%s", nodename);
      status = del_env("owned", str);      
      if (status < 0)
      {
         _NFMdebug ((fname, "Remove %s Failed\n", str));
         return (NFM_S_SUCCESS);
      }
      status = del_env("heard", str);      
      if (status < 0)
      {
         _NFMdebug ((fname, "Remove %s Failed\n", str));
         return (NFM_S_SUCCESS);
      }
      in_file = fopen (own_env, "a") ;
      env_file = fopen (tot_env, "a") ;
      if (env_file == NULL)
       {
         status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
         _NFMdebug ((fname, "fopen : errno  = <%d>\n", errno));
         _NFMdebug ((fname, "fopen : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
         return (NFM_E_OPEN_FILE); 
       }
#else
      sprintf (own_env, "/usr/lib/nodes/owned/nfme_%s", nodename); 
      in_file = fopen (own_env, "w") ;
#endif
      if (in_file == NULL)
       {
	 unlink(own_env);
         status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
         _NFMdebug ((fname, "fopen : errno  = <%d>\n", errno));
         _NFMdebug ((fname, "fopen : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
         return (NFM_E_OPEN_FILE); 
       }
/*      sprintf (lcl_env, "/usr/lib/nodes/local/nfme_%s", data [1]);
      sprintf (hrd_env, "/usr/lib/nodes/heard/nfme_%s", data [1]);
 */

/*      sprintf (own_env, "/usr/mehry/env/nfme_%s", nodename);*/

      _NFMdebug ((fname, "creating file %s\n",  own_env)) ;

/*      status = NETcreate_server_node (own_env, "", "", nodename);
      if (status != NET_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Net Cr Ser Node : status = <0x%.8x>\n", status));
         return (NFM_E_NET); 
       }

*/
       



  /*   ENCRYPT RDBMS TYPE*/     

      data = (char **) schema -> data_ptr ;

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
       fprintf (in_file, "nfme_%s\1NFM\1%s\1", nodename, data[2]);
       fprintf (env_file, "nfme_%s\1NFM\1%s\1", nodename, data[2]);
#else
       fprintf (in_file, "ADDRESS : %s\n", data[0]);      
       if (strcmp (data [1], "") != 0)
	   fprintf (in_file, "tcp_address : %s\n", data[1]);      
           fprintf (in_file, "Nodename : %s\n", data[2]);     

      str [0] = 0;
      status = NFMencrypt (data[3], str); /* was 3 before */
      if (status != NFM_S_SUCCESS)
	{
          unlink (own_env);
          _NFMdebug ((fname, "Encrypt failed : status = <0x%.8x>\n", status));
          return(status);
        }
      if (strcmp (data[3], "") != 0)
      fprintf ( in_file, "NETPROP11 : %s\n", str); 

      
  /*  ENCRYPT DBA DIR/HOME  */
/*
      str [0] = 0;
      status = NFMencrypt (data[4], str);
      if (status != NFM_S_SUCCESS)
	{
          unlink (own_env);
          _NFMdebug ((fname, "Encrypt failed : status = <0x%.8x>\n", status));
          return(status);
        }

       fprintf (in_file, "NETPROP12 : %s\n", str);  
*/
/*******/    

       /*   ENCRYPT RISDBA DB NAME/DIR  */
  if (strcmp (data [4],  "") != 0)
       fprintf (in_file, "NETPROP13 : %s\n", data[4]);      /* was 5 */

/******/

       /*   ENCRYPT RISDBA DB NAME/PATH  */
       if (strcmp (data [1],  "") != 0)
       fprintf (in_file, "NETPROP14 : %s\n", data[5]);  /* was 6 */

       /*   ENCRYPT RIS NETWORK  */

/********/

      /*   ENCRYPT SCH PWD */ 
/*
       str [0] = 0;
       status = NFMencrypt (data [7], str);
       
       if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

       fprintf (in_file, "NETPROP15 : %s\n", str);
*/
/********/

      /*   ENCRYPT RISDBA DB NAME/PATH */ 

       str [0] = 0;
       status = NFMencrypt (data [6], str); /* was 8 */
       
       if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

       fprintf (in_file, "NETPROP16 : %s\n", str);

#endif
/******/
      /*   ENCRYPT RISDBA USER */ 

/*
      str [0] = 0;
      status = NFMencrypt (data[11], str);  
      if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }
      fprintf (in_file, "NETPROP19 : %s\n", str);
*/

      /*   ENCRYPT RISDBA PWD */ 


      str [0] = 0;
      status = NFMencrypt (data[9], str);  /* was 12 */
      if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
      fprintf (in_file, "%s\1", str);
      fprintf (env_file, "%s\1", str);
#else
      fprintf (in_file, "NETPROP20 : %s\n", str);
#endif

/*****/

      /*   ENCRYPT RISDBA SCHEMA PASSWD */ 

      str [0] = 0;
      status = NFMencrypt (data[10], str);  /* was 13 */
      if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (NFM_E_NET);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
      fprintf (in_file, "%s\1", str);
      fprintf (env_file, "%s\1", str);
#else
      fprintf (in_file, "NETPROP21 : %s\n", str);
#endif

/*****/

      /*   ENCRYPT RIS NODE NAME */ 

       str [0] = 0;
       status = NFMencrypt (data [7], str);
       
       if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
       fprintf (in_file, "%s\1", str);
       fprintf (env_file, "%s\1", str);
#else
       fprintf (in_file, "NETPROP17 : %s\n", str);
#endif

/*******/

      /*   ENCRYPT RIS NETWORK */ 


      str [0] = 0;
      status = NFMencrypt (data[8], str);
      if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
      fprintf (in_file, "%s\1\n", str);
      fprintf (env_file, "%s\1\n", str);
#else
      fprintf (in_file, "NETPROP18 : %s\n", str);
#endif

      /*   ENCRYPT SCH NAME */ 

/*
      str [0] = 0;
      status = NFMencrypt (data[14], str);
      if (status !=NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }
      fprintf (in_file, "NETPROP22 : %s\n", str);
*/

/******/

      /*   ENCRYPT SCH PWD */ 
/*

      str [0] = 0;
      status = NFMencrypt (data[15], str);
      if (status != NFM_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }
      fprintf (in_file, "NETPROP23 : %s\n", str);
*/

/******/

      /*   ENCRYPT USR NAME */ 

/*
      str [0] = 0;
      status = NETencrypt (data[16], str);
      if (status != NET_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }
      fprintf (in_file, "NETPROP24 : %s\n", str);
*/
/*****/

      /*   ENCRYPT PWD */ 

      /*   ENCRYPT DEFAULT SCHEMA NAME */ 
      /*   ENCRYPT DEF SCHEMA PWD */ 
/*

      str [0] = 0;
      status = NETencrypt (data[17], str);
      if (status !=NET_S_SUCCESS)
       {
         unlink (own_env);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status);        
       }
      fprintf (in_file, "NETPROP25 : %s\n", str);
*/

/******/
    
      status = fclose (in_file);
      if (status)
       {
         unlink (own_env);
         status = NFMerror (NFM_E_CLOSE_FILE);
         _NFMdebug ((fname, "fclose : errno  = <%d>\n", errno));
         _NFMdebug ((fname, "fclose : status = <0x%.8x>\n", status));
         return (status);
       }
/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
      status = fclose (env_file);
      if (status)
       {
         status = NFMerror (NFM_E_CLOSE_FILE);
         _NFMdebug ((fname, "fclose : errno  = <%d>\n", errno));
         _NFMdebug ((fname, "fclose : status = <0x%.8x>\n", status));
         return (status);
       }
#endif


/*     status = (long) vfork() ;
     if (status == 0)
       {
         sprintf (str, "nfme_%s", node_name) ;
         status = (long) execl ("/usr/bin/clh", "/usr/bin/clh", "-u",
                                str, (char *) 0) ;
         if (status == -1)
           {
             _NFMdebug ((fname, "execl failed : errno %d\n", errno));
             exit (0) ;
           }
       }

     if (status == -1)
      {
         _NFMdebug ((fname, "vfork failed : errno %d\n", errno));
         return (NFM_E_FAILURE) ;
       }

     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           _NFMdebug ((fname, "Receipt of a signal %d\n", errno));
         else
            _NFMdebug ((fname, "wait failed %d\n", errno));
         return (NFM_E_FAILURE) ;
       }


     status = (long) vfork() ;
     if (status == 0)
       {
         status = (long) execl ("/usr/bin/namex", "/usr/bin/namex",
                                (char *) 0) ;
         if (status == -1)
           {
             _NFMdebug ((fname, "execl failed : errno %d\n", errno));
             exit (0) ;
           }
}

     if (status == -1)
       {
         _NFMdebug ((fname, "vfork failed : errno %d\n", errno));
         return (NFM_E_FAILURE) ;
       }

     status = (long) wait (&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           _NFMdebug ((fname, "Receipt of a signal %d\n", errno));
         else
           _NFMdebug ((fname, "wait failed %d\n", errno));
         return (NFM_E_FAILURE) ;
       }
*/
    return (NFM_S_SUCCESS);
}



