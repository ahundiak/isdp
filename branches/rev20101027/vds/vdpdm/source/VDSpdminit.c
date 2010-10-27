/* $Id: VDSpdminit.c,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / VDSpdminit.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpdminit.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

		/**************************************/
		/*                                    */
		/*      VDSpdminit.c                  */
		/*                                    */
		/**************************************/

/* CHANGE HISTORY */
/* 04-MAY-1992  MALLIK		  Remove the argument for path */

#include	<stdio.h>
#include	<errno.h>
#include 	<sys/utsname.h>
#include 	<sys/types.h>
#include 	<sys/stat.h>
#include	"NFMerrordef.h"
#include 	"VDSdbstr.h"
#include 	"VDSdbmsg.h"
#include	"VDSdberrdef.h"
#include	"VDSpdminit.h"

#define NULLSTR		""
#define	DEBUG_OFF	"nodbg"
#define	DEFAULT_DIR	"files"
#define	HEARD_PATH	"/usr/lib/nodes/heard/"
#define ARG_INPUT 	"VDSpdminit   : [env] [login] [passwd] [debug]"
#define ARG_DEFAULT	"defaults :                [\"\"]    [nodbg]"

#define	ERROR		0
#define	SUCCESS		1

long 		VDSuser_id;
char		VDS_DEBUG_FILE[80];
int		VDSdebug_on = 0;

static	char	s[1024];

main ( argc, argv)

int			argc;
char 			*argv[];

/* argv[1] 	             / PDM environment name 		*/
/* argv[2] 		     / NFM administrator login 		*/
/* argv[3] 		     / NFM administrator passwd 	*/
/* argv[4] 	             / PDM debug option 		*/

{
	char		login[MAX_WORD];
	char		env[MAX_WORD];
	char		passwd[MAX_WORD];
	char		debug[MAX_WORD];
	int		p_catno;
	int		VDSstatus = VDS_S_SUCCESS;

	if ( argc < 3)
	{
		printf ("%s\n%s\n", ARG_INPUT, ARG_DEFAULT);
		return (ERROR);
	}


	/* treatement of arguments */
	switch (argc)
	{
	case 3:
		strcpy ( env, argv[1] );
		strcpy ( login, argv[2] );
		strcpy ( passwd,NULLSTR);
		strcpy ( debug, DEBUG_OFF);
		break;
	case 4:
		strcpy ( env, argv[1] );
		strcpy ( login, argv[2] );
		strcpy ( passwd,argv[3]);
		strcpy ( debug, DEBUG_OFF);
		break;
	case 5:
		strcpy ( env, argv[1] );
		strcpy ( login, argv[2] );
		strcpy ( passwd,argv[3]);
		strcpy ( debug, argv[4]);
		break;

	default:
		printf ("%s\n%s\n", ARG_INPUT, ARG_DEFAULT);
		return (ERROR);
	}

	if (strcmp(debug,"debug") == 0)  /* Set Debug flag ON */
	{
		VDSset_debug_on();
		VDSdebug_on = 1;
	}

	printf ("%s\n", VDS_S10 );
	VDSstatus = VDSlogin ( login, passwd, env );
	if ( VDSstatus != VDS_S_SUCCESS )
	{
        	sprintf(s, "Login Not Successful. VDSstatus = %x\n", VDSstatus);
        	VDSdebug(s);
        	goto quit;
	}
	VDSstatus = VDSget_user_id( login, &VDSuser_id );
	if ( VDSstatus != VDS_S_SUCCESS )
	{
		sprintf(s, "Cannot get User Id. VDSstatus = %x\n", VDSstatus);
        	VDSdebug(s);
        	goto quit;
	}
	VDSstatus = VDScreate_env_file ( env );
	if( VDSstatus != VDS_S_SUCCESS )
	{
		VDSdebug("Invalid Permission on /usr/lib/nodes/owned \n");
		goto quit;
	}

	/* Create pdmcatalogs Table */
	VDSstatus = VDScreate_required_table ( VDSuser_id, VDSPDM_LOC );
	if ( VDSstatus != VDS_S_SUCCESS )
	{
		fprintf(stderr,"COULD NOT CREATE PDMLOC TABLE\n");
		fprintf(stderr,"Cleaning up....\n");
		VDSdebug("PDMinitialize: \n");
		sprintf(s,"VDScreate_required_table failed : %x\n",VDSstatus);
		VDSdebug(s);
		VDSinit_cleanup(VDSuser_id,1);
		return (VDSstatus);
	}
	fprintf (stdout,"CREATED PDMCATALOGS TABLE\n");

	/* Load the PDM catalog required attributes into NFM */
	VDSstatus = VDScreate_catalog_template1 ( VDSuser_id );
	if ( VDSstatus != VDS_S_SUCCESS )
	{
		fprintf(stderr,"COULD NOT CREATE CATALOG TEMPLATE\n");
		fprintf(stderr,"Cleaning up....\n");
		VDSdebug("PDMinitialize: \n");
		sprintf(s,"VDScreate_catalog_template failed : %x\n",VDSstatus);
		VDSdebug(s);
		VDSinit_cleanup(VDSuser_id,2);
		return (VDSstatus);
	}
	fprintf (stdout,"CREATED PDMCATALOG TEMPLATE\n");


	/* Create pdmparamloc Table */

	VDSstatus = VDScreate_required_table ( VDSuser_id, VDSPDM_PARAMLOC );
	if ( VDSstatus != VDS_S_SUCCESS )
	{
		fprintf(stderr,"COULD NOT CREATE PDMPARAMLOC TABLE\n");
		fprintf(stderr,"Cleaning up....\n");
		VDSdebug("PDMinitialize: \n");
		sprintf(s,"VDScreate_required_table failed : %d\n",VDSstatus);
		VDSdebug(s);
		VDSinit_cleanup(VDSuser_id,3);
		return (VDSstatus);
	}
	fprintf (stdout,"CREATED PDMPARAMLOC TABLE\n");

	/* Create pdmparameters Table */

	VDSstatus = VDScreate_required_table ( VDSuser_id, VDSPDM_PARAMETERS );
	if ( VDSstatus != VDS_S_SUCCESS )
	{
		fprintf(stderr,"COULD NOT CREATE PDMPARAMETERS TABLE\n");
		fprintf(stderr,"Cleaning up....\n");
		VDSdebug("PDMinitialize: \n");
		sprintf(s,"VDScreate_required_table failed : %d\n",VDSstatus);
		VDSdebug(s);
		VDSinit_cleanup(VDSuser_id,4);
		return (VDSstatus);
	}
	fprintf (stdout,"CREATED PDMPARAMETERS TABLE\n");

	VDSstatus = VDSi_create_pdm_catalog(VDSuser_id,"pdmlibraries","M");
	if (VDSstatus != VDS_S_SUCCESS)
	{
		fprintf(stderr,"COULD NOT CREATE PDMLIBRARIES CATALOG\n");
		fprintf(stderr,"Cleaning up....\n");
		NFMdelete_catalog(VDSuser_id,"pdmlibraries",&p_catno);
		VDSdebug("PDMinitialize: \n");
		sprintf(s,"PDMi_create_pdm_catalog failed : %d\n",VDSstatus);
		VDSdebug(s);
		VDSinit_cleanup(VDSuser_id,4);
               	return (VDSstatus);
	}
	fprintf(stdout,"CREATED PDMLIBRARIES CATALOG\n");
	fflush(stdout);

	sprintf(s,"%s"," CREATE UNIQUE INDEX i_pdmloc1 ON pdmcatalogs (n_catalogno)");
	VDSstatus = VDSexecute_sql_stmt(s);
	sprintf(s,"%s", "CREATE INDEX i_pdmname ON nfmattributes (n_name,n_datatype)");
        VDSstatus = VDSexecute_sql_stmt(s);

	 s[0]=0;
	sprintf(s,"INSERT INTO nfmsyscat(n_rowno,n_infotype,n_description) VALUES(4,'PDM','2.2.0')");
    	VDSstatus = VDSexecute_sql_stmt(s);

   	fprintf(stdout," SUCCESSFUL INITIALIZATION OF PDM\n");
	fflush(stdout);
	VDSdebug("EXIT:PDMinitialize\n");
	NFMlogoff();
	return (SUCCESS);

quit:
	NFMlogoff();
	return (ERROR);
}


int	VDSinit_cleanup ( user_id, id )
long	user_id;
int	id;
{
	char	sql_str[100];
	int	status;

	switch(id)
	{
	case 1:		goto step1;
	case 2:		goto step2;
	case 3:		goto step3;
	case 4:		goto step4;
	default:
			return ( VDS_E_FAILURE );
	}
step4:
	sprintf(sql_str,"DROP TABLE pdmparameters");
	status = VDSexecute_sql_stmt(sql_str);
	if( status != SUCCESS )
	{
		VDSdebug("System is Corrupted\n");
	}
	else
	{
		VDSdebug("Deleted table pdmparameters\n");
	}
step3:
	sprintf(sql_str,"DROP TABLE pdmparamloc");
	status = VDSexecute_sql_stmt(sql_str);
	if( status != SUCCESS )
	{
		VDSdebug("System is Corrupted\n");
	}
	else
	{
		VDSdebug("Deleted table pdmparamloc\n");
	}
step2:
	status = NFMdelete_template ("t_appl", "catalog","PDM");
	status = NFMdelete_template ("t_appl", "catalog","PDM");
	if(status != NFM_S_SUCCESS )
	{
		sprintf(s,"NFMdelete_template failed catalog <t_appl> %x\n",status);
		VDSdebug(s);
		VDSdebug("System is Corrupted\n");
	}
	else
	{
		VDSdebug("Deleted template t_appl of catalog\n");
	}

step1:
	status = NFMdelete_table (user_id,"pdmcatalogs","pdmcatalogs");
	if(status != NFM_S_SUCCESS)
	{
        	sprintf(s,"NFMdelete_table failed  <pdmcatalogs> %x\n",status);
		VDSdebug(s);
		VDSdebug("System is corrupted\n");
	}
	else
	{
		VDSdebug("Deleted Table pdmcatalogs\n");
	}
	return VDS_S_SUCCESS;
}


int VDScreate_env_file (env)
char *env;
{
     static char *fname = "VDScreate_env_file" ;
     long     status;
     FILE     *fopen (), *in_file, *out_file;
     char     str [100];
     long     stat_loc ;
     struct   stat buf;
     char     NFM_ENV_FILE[200];
     char     PDM_ENV_FILE[200];
     char     *c_status;

     sprintf (NFM_ENV_FILE, "/usr/lib/nodes/owned/nfme_%s", env);
     sprintf (PDM_ENV_FILE, "/usr/lib/nodes/owned/pdme_%s", env);

     c_status = (char *) stat (NFM_ENV_FILE, &buf) ;
     if (c_status)
       {
         sprintf(s,"/usr/lib/nodes/owned/nfme_%s was not found \n",env) ;
	 VDSdebug(s);
         printf("/usr/lib/nodes/owned/nfme_%s was not found \n",env) ;
         printf("Reinitialize I/NFM properly\n\n",env) ;
         return (NFM_E_OPEN_FILE) ;
       }
      in_file = fopen (NFM_ENV_FILE, "r");
      if (! in_file)
       {
         sprintf (s, "fopen %s: errno  = <%d>\n", NFM_ENV_FILE,errno);
	 VDSdebug(s);
         return (NFM_E_OPEN_FILE);
       }
      if ((out_file = fopen (PDM_ENV_FILE, "w+")) == NULL)
      {
	 status = NET_E_OPEN_FILENAME;
         unlink (PDM_ENV_FILE);
       	 printf("\nPDMinit should be owned by root with sticky bit set\n\n") ;
         sprintf (s, "fopen %s: errno  = <%d>\n", PDM_ENV_FILE,errno);
	 VDSdebug(s);
         return (status);
      }
     
     while ( fgets(str, 100, in_file) != NULL)
            fputs(str, out_file);
   
      status = fclose (in_file);
      if (status) /* OK */
      {
        sprintf (s, "fopen %s: errno  = <%d>\n", NFM_ENV_FILE,status);
	VDSdebug(s);
        status = NET_E_CLOSE_FILE;
        return (status);
      }
       
      status = fclose (out_file);
      if (status) /* OK */
      {
        sprintf (s, "fopen %s: errno  = <%d>\n", PDM_ENV_FILE,status);
	VDSdebug(s);
        status = NET_E_CLOSE_FILE;
        return (status);
      }
    
      str[0]=0;

      status = (long) vfork () ;
      if (status == 0)
        {
          sprintf (str, "pdme_%s", env) ;
          sprintf (s,"Executing a /usr/bin/clh -u %s\n", str) ;
	  VDSdebug(s);
          status = (long) execl ("/usr/bin/clh", "/usr/bin/clh", "-u",
                                 str, (char *) 0) ;
          if (status == -1)
            {
              sprintf (s, "execl failed %d\n", errno);
	      VDSdebug(s);
              exit (0) ;
            }
        } if (status == -1)
        {
          sprintf (s, "vfork failed %d\n", errno);
	  VDSdebug(s);
          return (status) ;
        }


     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           {
		sprintf(s, "Receipt of a signal from child process%d\n", errno);
		VDSdebug(s);
           }
         else
           {
             sprintf (s, "wait for the child process failed %d\n", errno);
	     VDSdebug(s);
           }
         return (status) ;
       }

    printf("UPDATED CLEARINGHOUSE FOR ENVIRONMENT %s \n",env); 

       status = (long) vfork () ;
      if (status == 0)
        {
          status = (long) execl ("/usr/ip32/inc/namex", "/usr/ip32/inc/namex",
                                 (char *) 0) ;
          if (status == -1)
            {
              sprintf (s, "execl for namex failed %d\n", errno);
	      VDSdebug(s);
              exit (0) ;
            }
        }

    printf("BROADCASTING THE NEW ENVIRONMENT AND SERVER \n"); 

      if (status == -1)
        {
          sprintf (s, "vfork failed %d\n", errno);
	  VDSdebug(s);
          return (status) ;
        }

      sprintf (s, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      VDSdebug(s);
      return (VDS_S_SUCCESS);
   }

