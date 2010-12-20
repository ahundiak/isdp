#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <pwd.h>

#include "PDUerror.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "PDUstorage.h"
#include "NFMstruct.h"
#include "SQLproto.h"

#include "ris.h"

#include "PDMproto.h"
#include "PDUproto.h"
#include "PDUpdmrpro.h"
#include "PDUuser.h"
#include "PDMmessage.h"


#define	     UNIX	1

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;
extern struct PDUstorage *storage;
extern char    *dba_errtxt, *dba_support;
extern struct NFMglobal_st NFMglobal;
extern char     glob_var[100];
extern long     NFM_PL_LOCK;
extern char     RIS_parms_filename[];

extern void RISget_schema_file_location(schema_file_parms *parms);

/* ALR  8/5/93. This is for an api function to check if user is logged in */
/* Global variable for login flag */
extern int      PDU_IS_LOGGED_IN;

/*
 * DESCRIPTION: Logs in  a user to the NFM schema.
 * 
 * PARAMETERS:  PDMexecptr       PDMexec;
 * 
 * INPUT:	PDMexec
 * 
 * The following fields of PDMexec are REQUIRED.
 * 
 * PDMexec->ws_buffer This buffer should contain the attr_list and data_list
 * returned by NFMquery_login_attributes
 * 
 * OUTPUT:
 * 
 * PDMexec->return_buffer
 * 
 * The user_id is returned in return_buffer
 * 
 * RETURN CODES:
 * 
 * PDM_S_SUCCESS    		SUCCESS PDM_E_RESET_BUFFER		MEM
 * problems PDM_E_COPY_BUFFER PDM_E_WRITE_ROW
 * 
 * PDM_E_NUMBER_OF_BUFFERS  No. of Input buffers is incorrect
 * 
 * PDM_E_LOGIN				NFM function to login failed
 * 
 * - Kumar Narayanan
 */

int             PDMlogin (
	                 long *user_id
                         )
{
   char           *fn = "PDMlogin";
   char           *fname = "PDMlogin";
   long            status;
   char            sql_str[300];
   char            pdmenv[40];
   char            saname[14], n_saname[14];
   int             to_sano;
   int             n_userno;
   char           *env_var_name;
   char            dba_path[45];
   char            env_file[80];
   char            string[1024];
   char            s[1024];
   char            *msg = NULL;
   char            *s_ptr = NULL;
   char            *token1 = NULL;
   struct stat buf;
   FILE            *fp = NULL;

/* 12/14/95 MJG */
#if defined (sparc) && defined (__Sol2__) && !defined (i386)
   char  path[80];
   pid_t child = 0;
   mode_t mode;
   register int ret_status;
   int   fildes[2];
   struct passwd *pwd = NULL;
   char  ris_path[80];
   char  parms_filename[80];
#endif

   char            *ingr_loc=NULL;

   /* Added support for SGI port MaC */
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
   struct stat     file_status;
   char            dir_entry_name[512];
   extern struct PDUuser *user;

#endif
   schema_file_parms parms;

   char         *parms_file_loc;

   if ((parms_file_loc = ((char *)getenv ("RIS_PARAMETERS"))) == 0) {
      _PDMdebug (fn, "RIS_PARAMETERS is not set at start of pdmlogin\n");
       }
   else {
   _PDMdebug (fn, "parameters file location at start of pdmlogin[%s]\n", parms_file_loc);
      }

   PDMreset_dots ();

   _PDMdebug (fn, "ENTER:\n");
   msg = (char *)PDUtranslate_message(PDS_M_LOGGING_IN);
   /*msg = (char *)PDUtranslate_message(PDS_M_DEBUG_ON_OFF);*/
   sprintf (glob_var, "%s %s", msg,PDMexec->revision);
   PDMupdate_dots ();
   /*status = unlink ("/usr/tmp/parameters");*/
   status = unlink ("/usr/tmp/parameters");
   status = unlink ("/usr/tmp/parms");
   if (status)
      _PDMdebug (fname, "Unlink file </usr/tmp/parameters> : errno <%d>\n", 
                                                                     errno);

   _PDMdebug (fname, "RIS_parms_filename [%s]\n", RIS_parms_filename);

/*  12/14/95 MJG - copy the RIS parms file to /usr/tmp - 
                   workround for RIS problem */
#if defined (sparc) && defined (__Sol2__) && !defined (i386)

     _PDMdebug(fname, "get the RIS path\n");
     ris_path[0] = '\0';
     status = PDUget_ris_path(ris_path);
     _PDMdebug(fname, "PDUget_ris_path returns = <%d>\n", status);

     _PDMdebug(fname, "RIS path = <%s>\n", ris_path);

     sprintf(parms_filename, "%s/%s", ris_path, "parms");
     _PDMdebug(fname, "parms file path = <%s>\n", parms_filename);
     {

     _PDMdebug(fname, "make sure RIS parms file exists\n");
     status = stat ( parms_filename, &file_status );
     _PDMdebug(fname, "stat returns %d \n", status);

     /* file exists */
     if ( status == 0 )
       {
       _pdm_debug("file %s was found", parms_filename);
       status = PDM_S_SUCCESS;

       _PDMdebug(fname, "copying RIS parms file to /usr/tmp\n");
       _PDMdebug(fname, "Do a unix copy\n");
       path[0] = '\0';
       strcpy(path, "/bin/cp");
       _PDMdebug(fname, "Path is <%s>\n", path);
       if (pipe(fildes) == 0)
          {
          if (ret_status = vfork())
             {
             if (ret_status != -1)
                {
                close(fildes[0]);
                close(fildes[1]);
                }
             }
          else
             {
             _PDMdebug(fname, "copying file <%s>\n", parms_filename);
             close(fileno(stdout));
             dup(fildes[1]);
             close(fildes[1]);
             execl(path,path,parms_filename, "/usr/tmp/parameters",(char *)0);
             }
          }
       status = stat("/usr/tmp/parameters", &file_status);
       _PDMdebug(fname, "stat returns %d \n", status);

       if (status == 0)
         {
         status == PDM_S_SUCCESS;

         _PDMdebug(fname, "changing mode of new file\n");
         mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP | S_IWOTH;
         if (!chmod("/usr/tmp/parameters", mode))
            _PDMdebug(fname, "successfully changed file permissions\n");
         else
            _PDMdebug(fname, "failed to change file permissions\n");
         }
       else
         _PDMdebug(fname, "error copying RIS parms file\n");
       }
     else
       _PDMdebug(fname, "error locating RIS parms file\n");
   }
#endif

   pdmenv[0] = '\0';
/*
   RIS_parms_filename[0] = '\0';
   NFMlog_off();
     _PDMdebug(fname, "calling RISterminate\n");
   RISterminate();
     _PDMdebug(fname, "after RISterminate\n");
*/

/* 12/1/95 MJG - check to see if using NFM-generated NFMenv.dat file */
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)

   env_file[0] = '\0';

#if defined (i386) || defined (__sgi)

   ingr_loc = ((char *)getenv ("INGRHOME"));
   if (!ingr_loc)
     {
     _PDMdebug(fname, "ERROR:  INGRHOME is not set\n");
     return(PDM_E_INGRHOME_NOT_SET);
     }
   _PDMdebug(fname, "INGRHOME = <%s>\n", ingr_loc);
   sprintf(env_file, "%s/%s", ingr_loc, "nfm/NFMenv.dat");
#endif

#if defined (sparc) && defined (__Sol2__) && !defined (i386)
   pwd = getpwnam( "nfmadmin" );
   if (!pwd)
     {
     _PDMdebug(fname, "ERROR getting NFM path\n");
     return(PDM_E_NFMADMIN_ACCOUNT);
     }
   _PDMdebug(fname, "NFM path = <%s>\n", pwd->pw_dir);
   sprintf(env_file, "%s/%s", pwd->pw_dir, "clh_info/NFMenv.dat");
#endif

   _PDMdebug(fname, "ENV file = <%s>\n", env_file);

   if (stat (env_file, &buf))
     {
     _PDMdebug(fname, "NFMenv.dat file is not loaded\n");
     status = PDM_E_NFM_DAT_FILE;
     PDUmessage(status, 's');
     return(status);
     }

   _PDMdebug(fname,"Checking buf.st_size\n");
   if (buf.st_size == 0)
     {
        _PDMdebug(fname,"env_file is empty\n");
           return (NFM_E_OPEN_FILE);
     }

   _PDMdebug(fname, "opening env file\n");
   if((fp=fopen(env_file,"r")) == (FILE *)0)
     {
     _PDMdebug(fname,"Cannot open file <%s>: errno <%d>\n",env_file,errno);
     return (NFM_E_OPEN_FILE);
     }

   _PDMdebug(fname, "processing env file\n");
   while((s_ptr=fgets(string,1023,fp)) != (char *)0)
     {
     _PDMdebug(fname, "before sprintf\n");
     s[0] = '\0';
     sprintf(s, "string = <%s>\n", string);
     PDMdebug(s);

     if(string[0] == '#')
       {
        _PDMdebug(fname, "skipping comment line\n");
       continue;
       }
     else if(!strncmp(string,"::",2))
       {
        _PDMdebug(fname, "skipping :: delimeter\n");
       continue;
       }
     else
       {
       token1 = (char *)strtok(string,"\001");
       _PDMdebug(fname, "before sprintf\n");
       s[0] = '\0';
       sprintf(s, "token1 = <%s>\n", token1);
       PDMdebug(s);

       _PDMdebug(fname, "looking for cntl A delimeter\n");
       if(token1 == (char *)0)
         {
         _PDMdebug(fname,"ctl A delimiter not found \n");
         continue;
         }
       if(!strncmp("pdms_",token1,5))
         {
         _PDMdebug(fname,"skipping pdms entry \n");
         continue;
         }
       if(!strncmp("pdme_",token1,5))
         {
         _PDMdebug(fname, "setting pdmenv to pdme_\n");
         sprintf (pdmenv, "pdme_%s", PDMexec->revision);
         break;
         }
       else if(!strncmp("nfme_",token1,5))
         {
         _PDMdebug(fname, "setting pdmenv to nfme_\n");
         sprintf (pdmenv, "nfme_%s", PDMexec->revision);
         break;
         }
       else
         _PDMdebug(fname,"ERROR:  can't set nfmenv type\n");

       }
       string[0] = '\0';
       token1 = (char *) NULL;
     }
   fclose(fp);
#else

   _PDMdebug(fname, "defaulting pdmenv to pdme_ for CLIX\n");
   sprintf (pdmenv, "pdme_%s", PDMexec->revision);
#endif

   if (PDMdebug_on)
      PDMprint_storage_area ();

   /* ALR 2/7/94 Added support for INGRHOME */

   env_var_name = (char *) getenv ("INGRHOME");

   sprintf (dba_path, "%s/pdu/dbasupport\0", env_var_name);

   dba_support = (char *) strdup (dba_path);

   PDMupdate_dots ();

   PDMupdate_dots ();

   /* Kumar Better error messages - 9/30/92 */

   /* Added support for SGI port MaC */

#if defined (i386) || defined (__sgi)
   g_error("Not using this");
   //status = NFMunix_log_in (PDMexec->catalog, PDMexec->part_num, pdmenv, "PDM");
   if (status != NFM_S_SUCCESS)
#else
   status = NFMlog_in (PDMexec->catalog, PDMexec->part_num, pdmenv, "PDM");
   if (status != NFM_S_SUCCESS)
#endif
   {
     /* TR# 139315093. 18/Jan/95 - raj.	*/
     int istatus;

      msg = (char *)PDUtranslate_message(PDS_M_LOG_IN_FAILED);
      UI_status (msg);

     /*
      * TR# 139315093. 18/Jan/95 - raj.	Do not use 'status' since it holds
      * return status from NFMlog_in(), which is used later.
      */
/* 11/29/95 - MJG - DO NOT set the RIS_PARAMETERS variable */

      PDMdebug ("COULD NOT LOGIN IN TO I/NFM - \n");


      switch (status) {
      	case (NFM_E_BAD_NODE):
	 	PDMdebug ("Invalid server\n");
	 	return (NFM_E_BAD_NODE);
      	case (NFM_E_BAD_PROTOCOL):
	 	PDMdebug ("Could not connect using current protocol\n");
	 	return (NFM_E_BAD_PROTOCOL);
      	case (NFM_E_BAD_USER):
	 	PDMdebug ("Invalid user name\n");
	 	return (NFM_E_BAD_USER);
      	case (NFM_E_BAD_ENV):
	 	PDMdebug ("Invalid environment name\n");
	 	return (NFM_E_BAD_ENV);
      	case (NFM_E_CLH):
	 	PDMdebug ("Clearing House entry incorrect\n");
	 	PDMdebug ("Check for entries in /usr/lib/nodes/heard \
                           for pdme_<envronment> and pdms_<server>\n");
	 	PDMdebug ("Check for entries in /etc/hosts for \
                           pdme_<envronment> and pdms_<server>\n");
	 	return (NFM_E_CLH);
      	case (NFM_E_USER_PASSWD):
	 	PDMdebug ("Invalid passwd \n");
	 	return (NFM_E_USER_PASSWD);
      	case (NFM_E_SQL_QUERY):
	 	PDMdebug ("Could not open underlying DBMS\n");
	 	PDMdebug ("\t1. If informix online, check whether tbinit \
                            process is running\n");
	 	PDMdebug ("2. If oracle, check whether dbwr,lgwr,smon,\
                            pmon,arch processes is running\n");
	 	PDMdebug ("3. Check whether /usr/ip32/ris/schemas file \
                            exists\n");
	 	PDMdebug ("4. Check for correct TCP address and XNS entries\
                             in /usr/ip32/ris/schemas for pdme_<environment>\
                             and pdms_<server>\n");
	 	_PDMdebug (fname, "NFMlogin failed status : 0x%.8x\n", status);
	 	return (PDM_E_OPEN_DB);
      	case (NFM_E_SQL_STMT):
	 	PDMdebug ("Could not open underlying DBMS\n");
	 	PDMdebug ("1. If informix online, check whether tbinit \
                            process is running\n");
	 	PDMdebug ("2. If oracle, check whether dbwr,lgwr,smon,pmon,a\
                            rch processes is running\n");
	 	PDMdebug ("3. Check whether /usr/ip32/ris/schemas \
                            file exists\n");
	 	PDMdebug ("4. Check for correct TCP address and XNS entries \
                            in /usr/ip32/ris/schemas for pdme_<environment> \
                            and pdms_<server>\n");
	 	_PDMdebug (fname, "NFMlogin failed status : 0x%.8x\n", status);
	 	return (PDM_E_OPEN_DB);
      	default:
	 	{
	    	PDMdebug ("1. Check whether /usr/ip32/ris/schemas file \
                            exists\n");
	    	PDMdebug ("2. Check for entries in /usr/lib/nodes/heard \
                            for pdme_<environment> and pdms_<server>\n");
	    	PDMdebug ("3. Check for entries in /etc/hosts for \
                            pdme_<environment> and pdms_<server>\n");
	    	PDMdebug ("4. Check for correct TCP address and XNS entries \
                            in /usr/ip32/ris/schemas for pdme_<environment> \
                            and pdms_<server>\n");
	    	PDMdebug ("5. Check whether a PDMdatabase is initialized \
                            properly\n");
	    	PDMdebug ("If this doesn't help: Contact Intergraph Support\n");
	    	_PDMdebug (fname, "NFMlogin failed status : 0x%.8x\n", status);
	 	}

     /* Added fix to get the existing schema information. MaC */

        RISget_schema_file_location (&parms);
     
     /* Passwords should not be printed in the debug files MaC 070894
     */
        _PDMdebug (fn,
       "parms struct:\n\t%s [%c]\n\t%s [%s]\n\t%s [%s]\n\t%s [%s]\n\t%s [%s]\n",
        "parms.protocol", parms.protocol,
        "parms.address", parms.address,
        "parms.username", parms.username,
        "parms.password", parms.username,
        "parms.filename", parms.filename);
     
     
/* 11/29/95  MJG - Do not reset the parms file 

        parms.protocol = 'M';
        strcpy (parms.address, "");
        strcpy (parms.username, "");
        strcpy (parms.password, "");
        strcpy (parms.filename, "schemas");
     
       if ((status = (int)putenv ("RIS_PARAMETERS=/usr/tmp/parameters")) != 0) {
           _PDMdebug (fn, 
           "Failed to set the RIS_PARAMETERS to /usr/tmp/parameters <%d>\n", 
                                                         status);
        }
        RISlocate_schema_file (&parms);
*/

      }
      return (status);
   }

   n_userno = NFMglobal.NFMuserno;

   PDMupdate_dots ();
   _PDMdebug (fname, "user_no = %d; \n", n_userno);
   *user_id = n_userno;

   if ((parms_file_loc = ((char *)getenv ("RIS_PARAMETERS"))) == 0) {
      _PDMdebug (fn, "RIS_PARAMETERS is not set\n");
       }
   else {
   _PDMdebug (fn, "parameters file location after nfmlogin [%s]\n", 
                                                          parms_file_loc);
      }

   /*
    * added 1/15/92 to insert sano and saname (working area) into storage
    * buffer. Instead of querying for working area everytime we
    * checkin/out/copy, we get it during the login time, add it to the
    * nfmstoragearea table and keep it in storage buffer for future use
    * (during that session, ofcourse!)
    */

   status = PDMlogin_find_sainfo (&to_sano, n_saname);
   if (status != PDM_S_SUCCESS && status != PDM_I_NO_SAREA_FOUND) {
      _PDMdebug (fname, "Invalid storageareas in NFMSTORAGEAREA table \n");
      _PDMdebug (fn, "PDMlogin_find_sainfo Failed status = %d\n", status);
      NFMlogoff ();
      if (status == PDM_E_DUPL_BAD_STORAGE_AREA
	  || status == PDM_E_DUPL_STORAGE_AREA)
	 return (PDM_E_DUPL_STORAGE_AREA);
      return (status);
   }

   PDMupdate_dots ();

   if (status == PDM_I_NO_SAREA_FOUND) {
      status = _NFMadd_temp_sa (PDMexec->user_id, storage->node_name,
		   storage->user_name, storage->path_name, storage->passwd);
      if (status != NFM_S_SUCCESS) {
	 _PDMdebug (fn, "_NFMadd_temp_sa failed %d\n", status);
	 NFMlogoff ();
	 _PDMdebug (fn, "Could not add the current working directory as\
                                a storagearea\n");
	 _PDMdebug (fn, "Check the node entry in nfmnodes table\n");
	 return (PDM_E_BAD_STRG);
      }

      PDMupdate_dots ();

      status = PDMi_find_storageno_name (&to_sano, n_saname);
      if (status != PDM_S_SUCCESS) {
	 PDMdebug ("Could not add the current working directory \
                   as a storagearea\n");
	 PDMdebug ("Check the node entry in nfmnodes table\n");
	 _PDMdebug (fn, "PDMi_find_storageno_name failed %d\n", status);
	 NFMlogoff ();
	 return (PDM_E_BAD_STRG);
      }

      /*
       * added to change the sa_type from T to W to support NFM3.0 ci/co
       * etc..
       */

      PDMupdate_dots ();
      sprintf (sql_str,
"UPDATE NFMSTORAGEAREA SET n_type = 'W' WHERE  n_sano = %d AND n_saname = '%s'",
	       to_sano, n_saname);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
	 _PDMdebug (fname, "SQLstmt failed status %d\n", status);
	 return (PDM_E_SQL_STMT);
      }
   }

   PDMupdate_dots ();

   storage->storage_no = to_sano;

   saname[0] = '\0';

   sprintf (saname, "%s", n_saname);

   PDUfill_in_string (&storage->storage_name, saname);

   if (PDMdebug_on)
      PDMprint_storage_area ();

   PDU_IS_LOGGED_IN = 1;
   _PDMdebug (fname, "EXIT: \n");
   return (PDM_S_SUCCESS);
}

int             PDMreset_ris_env ()
{
   char           *RIS_ENV = NULL, *dummy_ptr = NULL;
   int             size, status;
   char           *fname = "PDMreset_ris_env";
   char           *env_var_name;
   char            ris_path[45];

   size = 96;
   _PDMdebug (fname, "Enter");

   dummy_ptr = (char *) getenv ("RIS_ENV");

   if (dummy_ptr == (char *) 0) {
      return (PDM_S_SUCCESS);

   }

   /* ALR 2/7/94 Added support for INGRHOME */

   env_var_name = (char *) getenv ("INGRHOME");

   /*sprintf (ris_path, "%s/ris/parameters\0", env_var_name);*/
   sprintf (ris_path, "%s/ris/parms\0", env_var_name);

   if ((strcmp (ris_path, (char *)getenv ("RIS_PARAMETERS"))) == 0) {
      return (PDM_S_SUCCESS);
   }


   if ((RIS_ENV = (char *) malloc (size)) == (char *) 0) {
      RIS_ENV = dummy_ptr;
      return (-1);
   }

   /*sprintf (RIS_ENV, "RIS_PARAMETERS=%s/ris/parameters\0", env_var_name);*/
   sprintf (ris_path, "%s/ris/parms\0", env_var_name);

   /* set the environment variable to the parameters file */

   if ((status = (int) putenv (RIS_ENV)) != 0) {
      fprintf (stderr, "Failed to define environment variable %s status <%d>\n"
                               , RIS_ENV, status);
      free (RIS_ENV);
      RIS_ENV = dummy_ptr;
      return (-1);
   }

   if (dummy_ptr != (char *) 0)
      free (dummy_ptr);
   _PDMdebug (fname, "Exit");
   return (PDM_S_SUCCESS);
}
