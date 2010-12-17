/*
      Module:    PDMinitial.c                                          
      Author:    Ramakant Reddy
      Date:      1, September 1989                                      

	  Modified/Revamped on 22 OCT 1990 by Kumar.
	  Modified/Revamped on 2 NOV 1991 by Kumar.
	  Modified on 1 Aug 1992 for Parametric/Reports support by Kumar.

     The purpose of this initializer is to initiliaze PDM as an 
     application on top of NFM. Before initializing PDM, NFM schema(s)
     should have been generated, i.e., the database <nfm> with all the 
     relations should exist.

	 PDMinit does the following:

(a)  It creates PDM specific tables, templates (grouping of
     attributes) through NFM calls.

(b)  It creates required system catalogs.

(c)  It loads PDM default workflow.

Following are the tables created.

     (a). pdmcit
     (b). pdmboms
     (c). pdmbommap
     (d). pdmcatalogs
	 (e). pdmparameters
	 (f). pdmparamloc
     (g). pdmtables
     (h). pdmfilename (contains system generated number to be used as a
                       filename by PDU)
     (i). pdmfnattrmap (contains the mapping between the attribute and the ppl
                       filename )
     pj). pdmparts_rpt (contains the default template needed for partlist 
                        reports )
     (j). pdmsumbom_rpt (contains the default template needed for summary 
                        bom)
     (k). pdmexpbom_rpt (contains the default template needed for exploded
                        summary bom )
     (l). pdmbom_rpt (contains the default template needed for  bom )
     (m). pdmloc_rpt (contains the default template needed for List Of Catalogs)
     (n). pdmlop_rpt (contains the default template needed for List Of Parts in
                      a given catalog)
     (o). pdmwhereimm_rpt (contains the default template needed for Where used
                           immediate [ all levels ]for a given part )
     (p). pdmwherehigh_rpt (contains the default template needed for Where used
                           highest [ 1- level ]for a given part )
	
Following templates are also created

     (a). pdmcatalog0
	 (b). pdmcatalog1    Doesn't contain file catalog attributes 
     (c). pdmbomcontent
	 (d). pdmviews
	 
Also creates a PDM-catalog for PARAMETRIC SYSTEM

	(a). pdmlibraries

The function needs the following ASCII files.
	
	 PDMloc.attr	PDMloc.data
	 PDMcit.attr	PDMcit.data
	 PDMbom.attr    PDMbom.data
	 PDMcat.nfm 	PDMcat.pdm    
	 PDMboms.attr   PDMboms.data
	 PDMmap.attr	PDMmap.data
	 PDMviews.attr	PDMviews.data
	 PDMparam.attr	PDMparam.data
	 PDMflys.attr	PDMflys.data
	 PDMfile.attr	PDMfile.data
	 PDMpart.attr	PDMpart.data
	 PDMfmgr.attr	PDMfmgr.data
	 PDMcat1.nfm

The following WorkFlow files

	 PDMcmd.sdp
	 PDMwf.sdp

 NOTES:

		A(n) NFM table/template can be created through three types 
	of buffers (Attribute Sub-System). These three buffers are 
	created in PDMinit by file input. The main reason being users
	can tailor these files to suit their needs. The above list of
	files are expected by the PDMinit executable.

	Also when creating a Catalog template the template of NFM 
	is to be included. However the n_names,n_synonyms .. can be 
	changed and application dependent attributes can be added.
	This ofcourse lets the application use NFM functions to do 
	the basic set of operations on app. catalogs.

	It is to be noted that the rest of the relations (&templates)
    are solely used by PDM server to provide the functionality 
	underlying  the PDM product.
*/

#include <stdio.h>
#include <errno.h>
#include <time.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
/* Beth added for new debug 7/13/91 */
#include "DEBUG.h"
#include "NFMstruct.h"

#define		TRUE			 1
#define		FALSE			 0

#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"

#include "PDMmach_id.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDMinit.h"
#include "MSGstruct.h"
#include "PDMproto.h"

/* local definitions */
/******** FIRST FORM *********/
#define S_ENVIRONMENT 0
#define S_USERNAME    1
#define S_PASSWD      2
#define S_PDMDEBUG    3
#define ECHO_S 0
#define NOECHO 1


#define	NOT !

static  int		status;     
static  char    s[1024];

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern  struct  msg_struct   INITmsg_ptr;
extern	struct NETuser_struct NETusr_info;

int		PDMdebug_on;
char            PDM_DEBUG_FILE[100];
extern  struct NFMglobal_st NFMglobal ; 
extern char PDM_REPORTS[200];
extern char PDM_PPLFILES[200];
PDMpart_ptr PDMpart;


int		offsets[30];
char	*attr_names[30];
int		no_cols;
char    **def_buf;
	char		nfmlogin[20] = "";
	char		nfmpasswd[35] = "";
	char		pdmenv[20] = "";
	char		env[20] = "";

main(argc,argv)
int	 argc;
char *argv[];
{
	long		user_id = 0;
	char		s[1024];
        int             p_catno,i =0 , y = 0;
        UNIT_INFO       acq_data;
	int toggles[NFM_DEBUG_SUBSYSTEMS];
        char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
	MEMptr list;
	FILE	*fopen(), *owned_file;
        DIR     *infile;
#if defined (sco)
	char	pdm_proddir[200];
        char    *PDM_DIR;
	char	*PDMSDP_CMD_FILE;
	char	*PDMSDP_PART_FILE;
#endif
	MEMptr	 attr_list = NULL;
	MEMptr	 data_list = NULL;
	MEMptr	 value_list = NULL;
	MEMptr	 wf_list = NULL;
        MSGptr	 app_ptr;
/*********** BLANK FORM ONE  *******************************/
  static char *other_titles[] ={"-----------------------------------",
                                  "" ,
                                  "Control C - To Terminate installation now",
                                  "PF1       - To Resume installation now",
                                  "Backspace/Delete - To delete",
                                  NULL } ;

  static char *titles_new[] = { "Environment name",
                                  "User name",
                                  "Password",
                                  "PDM/SQL Debug",
                                  NULL } ;

  static char *def_val[] = { "",
                               "nfmadmin",
                               "",
                               "/dev/null",
                               NULL
                               } ;

  static short attrs[] = {   ECHO_S,
                               ECHO_S,
                               NOECHO,
                               ECHO_S,
                               NULL
                               } ;

  static char *extra_char[] = { "_",
                                  "_",
                                  "_",
                                  "_/.,",
                                  NULL
                                  } ;

	PDMdebug("ENTER:PDMinitialize\n");


#if defined (sco)
        PDMdebug("Create SCO specific PDM_DIR");
        status = PDMget_proddir(pdm_proddir);
	printf ("%s \n", pdm_proddir);
        if ((status != PDM_S_SUCCESS) && (!pdm_proddir))
          {
              printf("PDMget_proddir failed %s \n", pdm_proddir);
	      return status;
          }
        PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+1);
	if (!PDM_DIR) {
		printf ("Malloc failed for PDM_DIR \n");
		return status;
	}
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");

	PDMSDP_CMD_FILE = (char *)malloc(strlen(PDM_DIR)+1+strlen("PDMcmd.sdp")+1);
	if (!PDMSDP_CMD_FILE) {
		PDMdebug("Malloc failed for PDMSDP_CMD_FILE \n");
	}
	sprintf(PDMSDP_CMD_FILE, "%s%s%s", PDM_DIR, DELIM, "PDMcmd.sdp");
	
	PDMSDP_PART_FILE = (char *)malloc(strlen(PDM_DIR)+1+strlen("PDMwf.sdp")+1);
	if (!PDMSDP_PART_FILE) {
		PDMdebug("Malloc failed for PDMSDP_PART_FILE \n");
	} 
	sprintf(PDMSDP_PART_FILE, "%s%s%s", PDM_DIR, DELIM, "PDMwf.sdp");
#endif

INITmsg_ptr.debug_on = 0;
/*RIS_char_col_check_off_flag = 1;*/
strcpy(NFMglobal.NFMversion,"");
     if(argc == 4)
        {
        PDMheading();
                sprintf(nfmlogin,"%s",argv[1]);
                sprintf(nfmpasswd,"%s",argv[2]);
                sprintf(pdmenv,"nfme_%s",argv[3]);
                strcpy(env,argv[3]);
        }
   else if(argc == 5)
    {
        PDMheading();
                fprintf(stdout,"DEBUG ON .....\n\n\n");
                fflush(stdout);
                sprintf(nfmlogin,"%s",argv[1]);
                sprintf(nfmpasswd,"%s",argv[2]);
                sprintf(pdmenv,"nfme_%s",argv[3]);
                strcpy(env,argv[3]);
                PDMdebug_on = 1;
         if((strlen(argv[4]) < 7 ) || (strlen(argv[4]) > 98))
              {
               if ((infile = opendir(argv[4])) == NULL)
                {
                if ((owned_file = fopen(argv[4], "w")) == NULL) 
                strcpy(PDM_DEBUG_FILE,"/usr/tmp/pdm.dbg");
                else
                   {
                   fclose(owned_file);
                   strcpy(PDM_DEBUG_FILE,"%s",argv[4]);
                   }
                }
                else
                {
                closedir(infile);
                sprintf(PDM_DEBUG_FILE,"%s/%s", argv[4], "pdm.dbg");
                 }
               }
         else
             {
               if ((infile = opendir(argv[4])) == NULL)
                {
                if ((owned_file = fopen(argv[4], "w")) == NULL) 
                strcpy(PDM_DEBUG_FILE,"/usr/tmp/pdm.dbg");
                else
                   {
                   fclose(owned_file);
                   strcpy(PDM_DEBUG_FILE,argv[4]);
                   }
                }
                else
                {
                closedir(infile);
                sprintf(PDM_DEBUG_FILE,"%s/%s", argv[4], "pdm.dbg");
                 }
             }
                 fprintf(stdout,"DEBUGS ARE IN %s\n",PDM_DEBUG_FILE);
                 fflush(stdout);
                NFMmsg_ptr.debug_on = 1;
                MEMmsg_ptr.debug_on = 1;
                INITmsg_ptr.debug_on = 1;

                strcpy(NFMmsg_ptr.debug_file,PDM_DEBUG_FILE);
                /* NFM 30 DEBUG ON */
		_NFMdebug_st.NFMdebug_on =1 ;
		_NFMdebug_st.SQLdebug_on =1 ;
		_NFMdebug_st.NETSdebug_on =1 ;
		strcpy(_NFMdebug_st.NETSdebug_file, PDM_DEBUG_FILE) ;
		strcpy(_NFMdebug_st.NFMdebug_file, PDM_DEBUG_FILE) ;
		strcpy(_NFMdebug_st.SQLdebug_file, PDM_DEBUG_FILE) ;

	toggles [6] = 1;    /*NET deb on */
	toggles [8] = 1;    /*NFM deb on */
	toggles [9] = 1;    /*SQL deb on */
	toggles [11] = 1;   /*MEMS deb on */
	toggles [14] = 1;   /*ERRS deb on */
	toggles [3] = 1;    /*NET deb on */

	strcpy (files[8], PDM_DEBUG_FILE);
	sprintf (files[11], "mem.dbg");
	sprintf (files[6], "/usr/tmp/net.dbg");
	sprintf (files[9], PDM_DEBUG_FILE);
	sprintf (files[14],"err.dbg");
	sprintf (files[3], "/usr/tmp/netc.dbg");

    NFMall_debug (toggles, files);

    MEMopen (&list, 1000);
    MEMclose (&list);
    }
    else 
    {
/*
    fprintf(stdout,"USAGE : %s <username> <passwd> <envname> <server> <debug option>\n",
                argv[0]);
                exit(0);
*/
/* copy default multidimensional array */
      for (i=0; def_val[i] != NULL; i++)  ;

      def_buf = (char **) malloc (i * sizeof (char *)) ;
      memset (def_buf, NULL, i*sizeof (char *)) ;

       for (y=0; y<i; y++)
        {
          def_buf[y] = (char *) malloc (strlen(def_val[y]) + 1) ;
          strcpy (def_buf[y], def_val[y]) ;
        }

        PDMheading();
      menu("I/PDM 3.0 Installation",titles_new, def_buf, attrs,
           extra_char, &acq_data, other_titles) ;

         sprintf(pdmenv,"nfme_%s",acq_data.data[S_ENVIRONMENT]);
          strcpy(env,acq_data.data[S_ENVIRONMENT]);
      strcpy (nfmlogin, acq_data.data [S_USERNAME]) ;
      strcpy (nfmpasswd, acq_data.data [S_PASSWD]) ;
      strcpy(PDM_DEBUG_FILE,acq_data.data[S_PDMDEBUG]);
          if((strcmp(PDM_DEBUG_FILE,"") )  && (strlen(PDM_DEBUG_FILE) ))
             {
               if ((infile = opendir(PDM_DEBUG_FILE)) == NULL)
                {
                if ((owned_file = fopen(PDM_DEBUG_FILE, "w")) == NULL)
                strcpy(PDM_DEBUG_FILE,"/usr/tmp/pdm.dbg");
                else fclose(owned_file);
                }
                else
                {
                closedir(infile);
                strcat(PDM_DEBUG_FILE,"/");
                strcat(PDM_DEBUG_FILE,"pdm.dbg");
                 }
             }
for (y=0; y<i; y++) if (acq_data.data[y]) free (acq_data.data[y]) ;
      if (acq_data.data) free (acq_data.data) ;
    }

       if( (strcmp(PDM_DEBUG_FILE,"/dev/null") ) &&
          (strcmp(PDM_DEBUG_FILE,"") )  && (strlen(PDM_DEBUG_FILE) ))
          
          {
                PDMdebug_on = 1;
                NFMmsg_ptr.debug_on = 1;
                MEMmsg_ptr.debug_on = 1;
                INITmsg_ptr.debug_on = 1;

                strcpy(NFMmsg_ptr.debug_file,PDM_DEBUG_FILE);
                /* NFM 30 DEBUG ON */
		_NFMdebug_st.NFMdebug_on =1 ;
		_NFMdebug_st.SQLdebug_on =1 ;
		_NFMdebug_st.NETSdebug_on =1 ;
		strcpy(_NFMdebug_st.NETSdebug_file, "/usr/tmp/net.dbg") ;
		strcpy(_NFMdebug_st.NFMdebug_file, PDM_DEBUG_FILE) ;
		strcpy(_NFMdebug_st.SQLdebug_file, PDM_DEBUG_FILE) ;

	toggles [6] = 1;    /*NET deb on */
	toggles [8] = 1;    /*NFM deb on */
	toggles [9] = 1;    /*SQL deb on */
	toggles [11] = 1;   /*MEMS deb on */
	toggles [14] = 1;   /*ERRS deb on */
	toggles [3] = 1;    /*NET deb on */

	strcpy (files[8], PDM_DEBUG_FILE);
	sprintf (files[11], "/usr/tmp/mem.dbg");
	sprintf (files[6], "/usr/tmp/net.dbg");
	sprintf (files[9], PDM_DEBUG_FILE);
	sprintf (files[14],"/usr/tmp/err.dbg");
	sprintf (files[3], "/usr/tmp/netc.dbg");

    NFMall_debug (toggles, files);

    }

	/* initialize globals so that upon exit the calling function
	   can make sense out of them */


   if(!strlen(nfmlogin))
   {
             fprintf(stderr,"Username is null\n");  
		PDMdebug("PDMinitialize: \n");	
		sprintf (s, "Input username(s) are null \n");
		PDMdebug(s);
		status = PDM_E_NULL_LOGINS;
		return(status);
   }
	/* env_file in future has to be made selectable */

   if(PDMdebug_on)
   {
   		sprintf(s,"PDMinitialize:NFM user -> %s\n",nfmlogin);
   		PDMdebug(s);
		sprintf(s,"PDMintialize:NFM password -> %s\n",nfmpasswd);
		PDMdebug(s);
		sprintf(s,"PDMintialize:PDM env -> %s\n",pdmenv);
		PDMdebug(s);
		sprintf(s,"PDMintialize:PDM cmd file -> %s\n",PDMSDP_CMD_FILE);
		PDMdebug(s);
		sprintf(s,"PDMintialize:PDM wf file -> %s\n",PDMSDP_PART_FILE);
		PDMdebug(s);
   }
           if(strlen(pdmenv) > 14) 
             {
             fprintf(stderr,"Environment string length can't be more than 9 characters\n"); ; 
             fflush(stdout);
             PDMdebug("EXIT:PDMinitialize\n");
             exit(0);
              }
             
   /*  Login to NFM  */

	
   status = NFMlog_in (nfmlogin,nfmpasswd,pdmenv, "PDM");
   if (status != NFM_S_SUCCESS)
   {
       fprintf(stderr,"COULD NOT LOGIN IN TO I/NFM - ");
        switch(status)
         {
       case (NFM_E_BAD_NODE):     
             fprintf(stderr,"Invalid environment node\n"); break; 
       case(NFM_E_BAD_PROTOCOL): 
          fprintf(stderr,"Could not connect using current network protocol\n"); 
                         break;
      case( NFM_E_BAD_USER )   : 
                        fprintf(stderr,"Invalid user name\n"); break;
     case( NFM_E_BAD_ENV )   :
                     fprintf(stderr,"Invalid environment name\n");
                        break; 
     case( NFM_E_CLH )   :
                fprintf(stderr,"Environment nodename is not known\n");
                        break; 
      case( NFM_E_USER_PASSWD )   : 
                       fprintf(stderr,"Invalid passwd \n"); break;
     default  : fprintf(stderr,"Run again with debug on: Contact Intergraph Support\n");
         }
       MEMclose(&attr_list);
	   MEMclose(&data_list);MEMclose(&value_list);
       PDMdebug("PDMinitialize:\n ");	
       sprintf (s, "NFMlogin failed status : %d\n", user_id);
       PDMdebug(s);
       status = PDM_E_LOGIN;
       return(status);
    }
    MEMclose(&attr_list);MEMclose(&data_list);
	MEMclose(&value_list);
	MEMclose(&wf_list);
    attr_list  = NULL;
   	data_list  = NULL;
    value_list  = NULL;
       fprintf(stdout,"LOGGED IN TO I/NFM \n");
fflush(stdout);

#if !defined (sco)
  /*  Validate the user through NFM  */
       status = PDMcreate_env_file(env);
        if(status != PDM_S_SUCCESS)
          {
          PDMdebug("Invalid permission on /usr/lib/nodes/owned \n");
          }
#endif	

    status = PDMadd_reports_dir ();
    if (status != PDM_S_SUCCESS)
    {
                fprintf(stderr,"COULD NOT CREATE REPORTS DIR\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMadd_reports_dir failed : 0x%.8x\n",status);
		fprintf(stderr,"PDMadd_reports_dir failed : 0x%.8x\n",status);
		PDMdebug(s);
		return (status);
    }

    /*  Create pdmcit table and  the template */
    status = PDMcreate_required_table (user_id, PDM_CIT);
    if (status != PDM_S_SUCCESS)
    {
                fprintf(stderr,"COULD NOT CREATE PDMCIT TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed : 0x%.8x\n",status);
		fprintf(stderr,"PDMcreate_required_table failed : 0x%.8x\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,1);
		return (status);
    }
     fprintf(stdout,"CREATED PDMCIT TABLE\n");
fflush(stdout);

    /*  Create PDM's BOM Information Table  */

    status = PDMcreate_required_table(user_id,PDM_BOMSINFO);
    if (status != PDM_S_SUCCESS)
    {
                fprintf(stderr,"COULD NOT CREATE PDMBOMS TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,1);
		return (status);
   }

     fprintf(stdout,"CREATED PDMBOMS TABLE\n");
fflush(stdout);
   /*  Create pdmbommap Table for user map info */

   status = PDMcreate_required_table(user_id, PDM_BOMMAP);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMBOMMAP TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,2);
		return (status);
   }

     fprintf(stdout,"CREATED PDMBOMMAP TABLE\n");
fflush(stdout);
   /*  Create pdmcatalogs Table (previously pdm_loc) */
			/*  also the template  */

   status = PDMcreate_required_table (user_id,PDM_LOC);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMLOC TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,3);
		return (status);
   }

     fprintf(stdout,"CREATED PDMLOC TABLE\n");
fflush(stdout);
   /*  Load the PDM catalog required attributes into NFM  */

   status = PDMcreate_catalog_template1(user_id);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE CATALOG TEMPLATE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_catalog_templates failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,4);
		return (status);
   }

     fprintf(stdout,"CREATED CATALOG TEMPLATE\n");
fflush(stdout);
   /*  Load the PDM catalog required attributes into NFM  */
/*
   status = PDMcreate_catalog_template2(user_id);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE ATTRIBUTE TEMPLATE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_catalog_template2 failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,5);
		return (status);
   }
*/
     fprintf(stdout,"CREATED ATTRIBUTE TEMPLATE\n");
fflush(stdout);
   /*  Load the PDM bomcontent template into NFM  */

   status = PDMcreate_required_template(user_id,PDM_BOM);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE BOMCONTENT TEMPLATE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_template failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,6);
		return (status);
  }

     fprintf(stdout,"CREATED BOMCONTENT TEMPLATE\n");
fflush(stdout);
   /*  Load the PDM pdmviews template into NFM  */

   status = PDMcreate_required_template(user_id,PDM_VIEW);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE VIEWS TEMPLATE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_template failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,7);
		return (status);
   }

     fprintf(stdout,"CREATED VIEWS TEMPLATE\n");
fflush(stdout);
   /*  Create Parametrics Tables and Templates */

   /* Create pdmparamloc table */

   status = PDMcreate_required_table (user_id,PDM_PARAMLOC);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMPARAMLOC TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,8);
		return (status);
   }
     fprintf(stdout,"CREATED PDMPARAMLOC TABLE\n");
fflush(stdout);

   /* Create pdmparameters table */
   status = PDMcreate_required_table (user_id,PDM_PARAMETERS);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDM_PARAMETERS TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,9);
		return (status);
   }
     fprintf(stdout,"CREATED PDM_PARAMETERS TABLE\n");
fflush(stdout);
/* Create the  template for drawing sheets 
   status = PDMcreate_drawing_template(user_id);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE DRAW TEMPLATE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_template failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,10);
		return (status);
   }

     fprintf(stdout,"CREATED DRAW TEMPLATE\n");
fflush(stdout);

    Create a drawing catalog (A-PDMDWG CATALOG Type) table 

   status = PDMi_create_drawing_catalog(user_id,"pdmdrawing","C");
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMDRAWINGS CATALOG\n");
                fprintf(stderr,"Cleaning up....\n");
                NFMdelete_catalog(user_id,"pdmdrawing",&p_catno);
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMi_create_drawing_catalog failed : %d\n",status);
		PDMdebug(s);
		 PDMinit_cleanup(user_id,11);
   }

     fprintf(stdout,"CREATED PDM_DRAWINGS CATALOG\n");
fflush(stdout);
 */

   /*  Load the PSU reports into RIS */  

   status = PDMcreate_rptopts();
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE REPORT TABLES\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_rptopts failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,12);
		return (status);
   }

     fprintf(stdout,"CREATED REPORT TABLES\n");
fflush(stdout);

   /* Create pdmtables table */
   status = PDMcreate_required_table (user_id,PDM_TABLES);
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMTABLES TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMcreate_required_table failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,13);
		return (status);
   }

     fprintf(stdout,"CREATED PDMTABLES TABLE\n");
fflush(stdout);
  
   /* Create pdmlibraries (A-PDM CATALOG Type) table */

   status = PDMi_create_pdm_catalog(user_id, "pdmlibraries", "C");
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMSEEDFILES CATALOG\n");
                fprintf(stderr,"Cleaning up....\n");
                NFMdelete_catalog(user_id,"pdmseedfiles",&p_catno);
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMi_create_pdm_catalog failed : %d\n",status);
		PDMdebug(s);
		 PDMinit_cleanup(user_id,14);
		return (status);
   }
     fprintf(stdout,"CREATED PDMLIBRARIES CATALOG\n");
fflush(stdout);
   status = PDMi_create_pdm_catalog(user_id,"pdmseedfiles","C");
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMSEEDFILES CATALOG\n");
                fprintf(stderr,"Cleaning up....\n");
                NFMdelete_catalog(user_id,"pdmseedfiles",&p_catno);
		PDMdebug("PDMinitialize: \n");
		sprintf(s,"PDMi_create_pdm_catalog failed : %d\n",status);
		PDMdebug(s);
		 PDMinit_cleanup(user_id,14);
		return (status);
   }

     fprintf(stdout,"CREATED PDMSEEDFILES CATALOG\n");
fflush(stdout);

/*end addition 2/9/92 -> MaC Drawing sheet Support */

   /* Create pdmfilename table */

   /* This table contains one column and one row.
      The value stored in the table will be of type character, and will
      consist of a 14 digit number.
      The range of the filename/number is 00000000000000 to 99999999999999. */

   status = PDMcreate_pdmfilename_table ("pdmfilename");
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE PDMFILENAMES TABLE\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
                sprintf(s,"PDMcreate_pdmfilename_table failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,16);
		return(status);
   }
     fprintf(stdout,"CREATED PDMFILENAMES TABLE\n");
fflush(stdout);
   status = PDMcreate_reports_tables ();
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE REPORT FORMAT TABLES\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
                sprintf(s,"PDMcreate_reports_table failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,16);
		return(status);
  }
     fprintf(stdout,"CREATED REPORT FORMAT  TABLES\n");
fflush(stdout);
   status = PDMmap_attribute_function ();
   if (status != PDM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT CREATE ATTRIBUTE FUNCTION MAP\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
                sprintf(s,"PDMmap_attribute_function failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,17);
		return(status);
    }
   status = PDMcreate_nfmpdmcat_view ();
   if (status != PDM_S_SUCCESS)
   {
              fprintf(stderr,"COULD NOT CREATE NFMCATALOGS-PDMCATALOGS VIEW\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMdebug("PDMinitialize: \n");
                sprintf(s,"PDMcreate_nfmpdmcat_view failed : %d\n",status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,18);
		return(status);
    }
     fprintf(stdout,"CREATED ATTRIBUTE-FUNCTION MAP  TABLE\n");
fflush(stdout);

	/* Create Required Indices */

	sprintf(s,"%s",	
	"CREATE INDEX i_pdmcit1 ON pdmcit (p_citno)");
	status = SQLstmt(s);
        if(status == SQL_S_SUCCESS)
        {
            sprintf(s,"%s", "CREATE INDEX i_pdmcit3 ON pdmcit (p_pdcno)");
                 status = SQLstmt(s);
        }
    if(status == SQL_S_SUCCESS)
        {
            sprintf(s,"%s", "CREATE INDEX i_pdmname ON nfmattributes (n_name,n_datatype)");
                 status = SQLstmt(s);
        }
    if(status == SQL_S_SUCCESS)
        {
            sprintf(s,"%s", "CREATE INDEX i_pdmcit2 ON pdmcit (p_childno,p_attached)");
                 status = SQLstmt(s);
        }
    if(status == SQL_S_SUCCESS)
	{
	    sprintf(s,"%s",	
		"CREATE UNIQUE INDEX i_pdmloc1 ON pdmcatalogs (n_catalogno)");	
		 status = SQLstmt(s);
	    sprintf(s,"%s",	
		"CREATE INDEX i_pdmloc2 ON pdmcatalogs (p_level1)");	
		 status = SQLstmt(s);
	    sprintf(s,"%s",	
		"CREATE INDEX i_pdmloc3 ON pdmcatalogs (p_level2)");	
		 status = SQLstmt(s);
	    sprintf(s,"%s",	
		"CREATE INDEX i_pdmloc4 ON pdmcatalogs (p_level3)");	
		 status = SQLstmt(s);
	}
/*
    if(status == SQL_S_SUCCESS)
	{
	    sprintf(s,"%s",	
		"CREATE UNIQUE INDEX i_pdmflys1 ON pdmfamilies (p_familyno)");	
		status = SQLstmt(s);
	}
*/
    if(status == SQL_S_SUCCESS)
	{
	    sprintf(s,"%s %s",	
		"CREATE UNIQUE INDEX i_pdmboms1 ON pdmboms ",
		"(n_catalogno,n_itemno)");
		status = SQLstmt(s);
	}
    if(status == SQL_S_SUCCESS)
	{
	    sprintf(s,"%s %s",	
		"CREATE UNIQUE INDEX i_pdmbommap ON pdmbommap ",
		"(p_mapattrno,n_catalogno,p_mapattrno)");
		SQLstmt(s);
	}
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"Could not create A  index <%d>\n",status);
		PDMdebug(s);
                fprintf(stderr,"COULD NOT CREATE INDEX\n");
                fprintf(stderr,"Cleaning up....\n");
		PDMinit_cleanup(user_id,18);
		return(PDM_E_FAILURE);
	}
     fprintf(stdout,"CREATED INDEXES\n");
fflush(stdout);


   /* turn off auto commit */

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"PDMstop_transaction failed status %d\n",
		status);
		PDMdebug(s);
		PDMinit_cleanup(user_id,17);
		return(status);
   }

   /* load PDM work flow */

   status = WFvalidate_user_access(user_id,"Add Commands","", 
				"","", "", "");
   if (status != NFM_S_SUCCESS)
   {
       PDMdebug("PDMinitialize: \n");	
       sprintf (s, "%s %s %d\n",
	   "NFMvalidate_user_access ",
	   "failed status ", status);
       PDMdebug (s);
	   goto wrapup;
   }
   status = WFload_commands(user_id,"PDM",PDMSDP_CMD_FILE);
   if (status != NFM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT LOAD WORKFLOW COMMNADS\n");
                fprintf(stderr,"Cleaning up....\n");
		sprintf(s,"WFload_commands failed status %d\n",status);
		PDMdebug(s);
		goto wrapup;
   }   
   fprintf(stdout,"WORKFLOW COMMANDS LOADED\n");
fflush(stdout);
   app_ptr.error_no = NFM_S_SUCCESS;
   status = WFset_to_state (user_id,"PDM",app_ptr);
   if (status != NFM_S_SUCCESS)
   {
		goto wrapup;
   }   

  /*  Validate the user through NFM  */

   status = WFvalidate_user_access(user_id,"Load Workflow","", 
				"","", "", "");
   if (status != NFM_S_SUCCESS)
   {
       PDMdebug("PDMinitialize: \n");	
       sprintf (s, "%s %s %d\n",
	   "NFMvalidate_user_access ",
	   "failed status ", status);
       PDMdebug (s);
	   goto wrapup;
   }

   status = WFload_workflow(user_id,"PDM",PDMSDP_PART_FILE);
   if (status != NFM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT LOAD WORKFLOW\n");
                fprintf(stderr,"Cleaning up....\n");
		sprintf(s,"WFload_workflow failed status %d\n",status);
		PDMdebug(s);
		goto wrapup;
   }   
  app_ptr.error_no = NFM_S_SUCCESS;
  status = WFset_to_state (user_id,"PDM",app_ptr);
  if (status != NFM_S_SUCCESS)
  {
	goto wrapup;
  }   
   status = WFvalidate_user_access(user_id,"Add Access Control List","", 
				"","", "", "");
   if (status != NFM_S_SUCCESS)
   {
       PDMdebug("PDMinitialize: \n");	
       sprintf (s, "%s %s %d\n",
	   "NFMvalidate_user_access ",
	   "failed status ", status);
       PDMdebug (s);
	   goto wrapup;
   }
/*
   status = PDMload_acl(user_id,nfmlogin,
				"PDM_PART_WORKFLOW","PDM_PART_ACL");
*/
   status = WFload_acl(user_id,nfmlogin,
				"PDM_PART_WORKFLOW","PDM_PART_ACL");
   if (status != NFM_S_SUCCESS)
   {
                fprintf(stderr,"COULD NOT LOAD ACL\n");
                fprintf(stderr,"Cleaning up....\n");
		sprintf(s,"WFload_acl failed status %d\n",status);
		PDMdebug(s);
		goto wrapup;
   }   
   fprintf(stdout,"ACL LOADED\n");
fflush(stdout);
  app_ptr.error_no = NFM_S_SUCCESS;
  status = WFset_to_state (user_id,"PDM",app_ptr);
  if (status != NFM_S_SUCCESS)
  {
	goto wrapup;
  }   

   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"PDMstart_transaction failed status %d\n",
		status);
		PDMdebug(s);
		goto wrapup;
   }

   s[0] = '\0';
    sprintf(s,"INSERT INTO nfmsyscat(n_rowno,n_infotype,n_description) VALUES(4,'PDM','2.2.0')");
    status = SQLstmt(s);

   fprintf(stdout," SUCCESSFUL INITIALIZATION OF I/PDM\n"); 
fflush(stdout);
   PDMdebug("EXIT:PDMinitialize\n");
    NFMlogoff();
   return (PDM_S_SUCCESS);

wrapup:

   status = PDMrollback_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"%s %s %d \n",
		"PDMrollback_transaction failed ",
		" status ",status);
		PDMdebug(s);
   }

   /* cleanup PDM initialization */

	PDMinit_cleanup(user_id,17);

          NFMlogoff();
	return(PDM_E_FAILURE);
}

int  PDMinit_cleanup(user_id,id)
long user_id;
int  id;
{
   int   p_catno;
   char  sql_str[100];
   char  *fname = "PDMinit_cleanup";
  
	switch(id)
    {
		case 1 :    goto step1;
		case 2 :    goto step2;
		case 3 :    goto step3;
		case 4 :    goto step4;
		case 5 :    goto step5;
		case 6 :    goto step6;
		case 7 :    goto step7;
		case 8 :    goto step8;
		case 9 :    goto step9;
		case 10 :    goto step10;
		case 11 :    goto step11;
		case 12 :    goto step12;
		case 13 :    goto step13;
		case 14 :    goto step14;
                case 16 :    goto step16;
                case 17 :    goto step17;
                case 18 :    goto step18;
		default:
				 return(PDM_E_FAILURE);
	}
step18:
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmcit1");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmcit2");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmcit3");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmname");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmloc1");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmloc2");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmloc3");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmloc4");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmboms1");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmbommap");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP INDEX i_pdmflys1");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP VIEW nfmpdmcat");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmfnattrmap");
                 status = SQLstmt(sql_str);

step17:
                 sprintf(sql_str,"%s", "DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmexpbom_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmloc_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmparts_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmwhereimm_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmwherehigh_rpt");
                 status = SQLstmt(sql_str);
                 sprintf(sql_str,"%s", "DROP TABLE pdmbom_rpt");
                 status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
		sprintf(s,"Delete report tables failed %d\n",status);
                  PDMdebug(s);
	         PDMdebug("System is corrupted\n");
                }
	else
		{
		PDMdebug("Deleted report format tables\n");
	        }
             
step16:
         sprintf(sql_str,"DROP TABLE pdmfilename");
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"Delete_table failed  <pdmfilename>                                %d\n",status);
             		PDMdebug(s);
			PDMdebug("System is corrupted\n");
                }
	else
		{
		PDMdebug("Deleted Table pdmfilename\n");
	}

step14:
	status = NFMdelete_catalog(user_id,"pdmlibraries",&p_catno);
		if(status != NFM_S_SUCCESS)
		{
  		sprintf(s,"NFMdelete_catalog failed  <pdmlibraries> %d\n",
			status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
        }
        else
		{
	       PDMdebug("Deleted catalog pdmlibaries\n");
        }
	status = NFMdelete_catalog(user_id,"pdmseedfiles",&p_catno);
		if(status != NFM_S_SUCCESS)
		{
  		sprintf(s,"NFMdelete_catalog failed  <pdmseedfiles> %d\n",
			status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
        }
        else
		{
	       PDMdebug("Deleted catalog pdmseedfiles\n");
        }
	
step13:
		status = NFMdelete_table (user_id, "pdmtables","pdmtables");
		if(status != NFM_S_SUCCESS)
		{
	  		sprintf(s,"NFMdelete_table failed <pdmtables> %d\n",status);
	  		PDMdebug(s);
	  		PDMdebug("System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Table pdmtables\n");
        }

step12:
             
         sprintf(sql_str,"DROP TABLE psurptopts");
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			PDMdebug("System is corrupted\n");
                }
	else
		{
		PDMdebug("Deleted Table psurptopts\n");
	}
         sprintf(sql_str,"DROP TABLE psurptlist");
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			PDMdebug("System is corrupted\n");
                }
	else
		{
		PDMdebug("Deleted Table psurptlist\n");
	}

step11:
        /*
	status = NFMdelete_catalog(user_id,"pdmdrawings",&p_catno);
	if(status != NFM_S_SUCCESS)
	{
  		sprintf(s,"NFMdelete_catalog failed  <pdmlibraries> %d\n",
		status);
  		PDMdebug(s);
  		PDMdebug("PDM : System is corrupted\n");
        }
        else
		{
	       PDMdebug("Deleted catalog pdmlibraries\n");
        }
        */
step10:
		status = NFMdelete_template ("t_basic","catalog", 
					     "PDMDWG"); 
 	       PDMdebug("Deleted Table pdmdraw t_basic template\n");

		status = NFMdelete_template ("t_appl","catalog", 
					     "PDMDWG"); 
 	       PDMdebug("Deleted Table pdmdraw t_appl template\n");

		status = NFMdelete_template ("t_basic","f_catalog", 
					     "PDMDWG"); 

 	       PDMdebug("Deleted Table pdmdrawf t_basic template\n");

		status = NFMdelete_template ("t_appl","f_catalog", 
					     "PDMDWG"); 

 	       PDMdebug("Deleted Table pdmdrawf t_appl template\n");
   status = NFMdelete_table (user_id, "pdmparameters","pdmparameters");
        if(status != NFM_S_SUCCESS)
        {
         sprintf(sql_str,"DROP TABLE pdmparameters");
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			PDMdebug("System is corrupted\n");
                }
	else
		{
		PDMdebug("Deleted Table psurptopts\n");
	}
        }

step9:
        status = NFMdelete_table (user_id, "pdmparamloc","pdmparamloc");
        if(status != NFM_S_SUCCESS)
        {
         sprintf(sql_str,"DROP TABLE pdmparamloc");
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			PDMdebug("System is corrupted\n");
                }
	else
		{
		PDMdebug("Deleted Table psurptopts\n");
	}
       }
step8:
		status = NFMdelete_template ("t_appltable","v_template", 
					     "PDM"); 
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMdelete_template failed  <pdmviews> %d\n",
					status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Template pdmviews\n");
        }
step7:
		status = NFMdelete_template ("t_appltable", "bom_template",
					     "BOM"); 
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMdelete_template failed  <pdmbomcontent> %d\n",
					status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Template pdmbomcontent\n");
        }
step6:
		status = NFMdelete_template ("t_basic", "catalog","PDM"); 
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMdelete_template failed  <pdmcatalog1> %d\n",
					status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted template PDM t_basic fo catalog\n");
        }
		status = NFMdelete_template ("t_basic", "f_catalog","PDM"); 
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMdelete_template failed  <pdmcatalog1> %d\n",
					status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted template PDM t_basic for f_catalog n\n");
        }

step5:
		status = NFMdelete_template ("t_appl", "catalog","PDM"); 
		status = NFMdelete_template ("t_appl", "f_catalog","PDM"); 
		if(status != NFM_S_SUCCESS)
		{
			sprintf(s,"NFMdelete_template failed catalog <t_appl>%d\n",
					status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted template t_appl of catalog\n");
        }
step4:
		status = NFMdelete_table (user_id,"pdmcatalogs","pdmcatalogs");
		if(status != NFM_S_SUCCESS)
		{
  			sprintf(s,"NFMdelete_table failed  <pdmcatalogs> %d\n",status);
  			PDMdebug(s);
  			PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Table pdmcatalogs\n");
        }
step3:
		status = NFMdelete_table (user_id,"pdmbommap","pdmbommap");
		if(status != NFM_S_SUCCESS)
		{
  			sprintf(s,"NFMdelete_table failed  <pdmbommap> %d\n",status);
  			PDMdebug(s);
  			PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Table pdmbommap\n");
        }
step2:
		status = NFMdelete_table (user_id, "pdmboms", "pdmboms");
		if(status != NFM_S_SUCCESS)
		{
 		    sprintf(s,"NFMdelete_table failed  <pdmboms> %d\n",status);
	  		PDMdebug(s);
	  		PDMdebug("PDM : System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Table pdmboms\n");
        }
step1:
#if defined(sco)
      status = (long) fork () ;
#else
      status = (long) vfork () ;
#endif
      if (status == 0)
        {
          _PDMdebug (fname,"Executing a /bin/rm -r %s\n",
                     PDM_REPORTS) ;
          status = (long) execl ("/bin/rm", "/bin/rm", "-r",
                                 PDM_REPORTS, (char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl failed %d\n", errno);
            }
        } if (status == -1)
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
        }
#if defined(sco)
      status = (long) fork () ;
#else
      status = (long) vfork () ;
#endif
      if (status == 0)
        {
          _PDMdebug (fname,"Executing a /bin/rm -r %s\n",
                     PDM_PPLFILES) ;
          status = (long) execl ("/bin/rm", "/bin/rm", "-r",
                                 PDM_PPLFILES, (char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl failed %d\n", errno);
            }
        } if (status == -1)
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
        }
sprintf(sql_str,"delete from nfmstoragearea where n_saname = 'RIS templates'");
                 status = SQLstmt(sql_str);
sprintf(sql_str,"delete from nfmstoragearea where n_saname = 'PDM functions'");
                 status = SQLstmt(sql_str);
		status = NFMdelete_table (user_id, "pdmcit","pdmcit");
		if(status != NFM_S_SUCCESS)
		{
	  		sprintf(s,"NFMdelete_table failed <pdmcit> %d\n",status);
	  		PDMdebug(s);
	  		PDMdebug("System is corrupted\n");
		}
        else
		{
 	       PDMdebug("Deleted Table pdmcit\n");
        }
	return(PDM_S_SUCCESS);
}
