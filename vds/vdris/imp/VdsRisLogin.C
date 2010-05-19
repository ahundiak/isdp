/* $Id: VdsRisLogin.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsRisLogin.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsRisLogin.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
 * Revision 1.5  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.4  1995/12/20  19:46:44  pinnacle
 * Replaced: vdris/imp/VdsRisLogin.C for:  by jwfrosch for vds.240
 *
 * Revision 1.3  1995/11/29  13:53:52  pinnacle
 * Replaced: ./vdris/imp/VdsRisLogin.C for:  by ksundar for vds.240
 *
 * Revision 1.2  1995/09/25  23:10:14  pinnacle
 * Replaced: vdris/imp/VdsRisLogin.C for:  by sundar for vds.240
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
 *	08/17/92	Mallik	Creation
 *	12/20/95	HF	Added VDdebug.h & __<fnc. calls>
 *					(Intel Solaris database problem)
 *	04/10/96	tlb	Use VDS memory allocation checking
 *				Add prototypes
 *				VdsPtrStrcpy - add 1 to strlen
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
#include	<FI.h>
#include	"VDSris_def.h"
#include	"MEMstruct.h"
#include	"MEMerrordef.h"
#include	"NFMerrordef.h"
#include	"PDUerror.h"
#include	"PDUuser.h"
#include	"vdbmacros.h"

#include	"VX_FIproto.h"
#include	"VDdebug.h"
#include	"VDmem.h"
#include	"v_risproto.h"

//#define		VD_DEBUG	1

#define		LOGIN_FORM	10

#define 	MAX_TEXT_LEN	25	// 15 IS TOO SMALL !!!!
#define		MAX_PROJ_LEN	40

extern struct PDUuser *user;
//extern char	VDSenvir_name[];
char	VDSenvir_name  [MAX_TEXT_LEN + 1] = "";
char 	VDSproject_name[MAX_PROJ_LEN + 1] = "";   // Not used at ALL in this file 


/* Gadgets */

#define	USERNAME	14
#define	PASSWORD	15
#define	ENVIRONMENT	16

#define	PROJECT		13

static char	project[81];
static char	username   [MAX_TEXT_LEN + 1];
static char	passwd     [MAX_TEXT_LEN + 1];
static char	environ    [MAX_TEXT_LEN + 1];
static char	old_environ[MAX_TEXT_LEN + 1];

static int VDris_Get_text ( fp, g_label, text, text_size )
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char ** text;          /* The text contained in the field */
       int   * text_size;     /* The space allocated for the text */
{
    int status;
    int text_len;
    int field_type;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;

  __enterFunction ( name = "VDris_Get_text" );

    FIg_get_type ( fp, g_label, &field_type );

    if ( field_type == FI_MULTI_COL )
    {
        /* Get the col for the MCF */

        FImcf_get_active_col ( fp, g_label, &col, &pos );

    }

    /* Get the row for the field or MCF */

    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    /* Increment text_len because of NULL */

    text_len++;

    if ( *text_size < text_len )
    {
        if ( *text_size > 0 )
        {
           /* Realloc space for larger string */
           *text = _REALLOC ( *text, text_len, char );
        }
        else
        {
           /* Calloc space for string */
           *text = _CALLOC ( text_len, char );
        }
        *text_size = text_len;
    }

    if ( ! * text )
    {
      *text_size = 0;

  __exit_error_Function ( name = "VDris_Get_text" );

      return ( FI_NO_MEMORY );
    }

    status = FIfld_get_text ( fp, g_label, row, col, *text_size,
                            (unsigned char *)(*text), &select_flag, &pos );

  __exitFunction ( name = "VDris_Get_text" );

    return ( status );
}



int	VdsLoginNotif(f_label, g_label, value, fp)
int	f_label;
int	g_label;
double	value;
Form	fp;
{
   static char	environ_name[20];
   int	sts;
   char	string[81];
   static	char	*text;
   static	int	text_size=0;

  __enterFunction ( name = "VdsLoginNotif" );

   FIg_set_text(fp, FI_PROMPT_FIELD, "");
   FIg_set_text(fp, FI_MSG_FIELD, "");

   switch ( g_label )
   {
      case FI_CANCEL:
         VdsRisDetach();
         VdsReset_ris_env();
         username[0] = 0;
         passwd[0]   = 0;
         environ[0]  = 0;
         old_environ[0]  = 0;
         FIf_delete(fp);
         FIf_erase(fp);
         break;

      case FI_RESET:
         username[0] = 0;
         FIg_set_text (fp, USERNAME, "");
         passwd[0]   = 0;
         FIg_set_text (fp, PASSWORD, "");
         environ[0]  = 0;
         FIg_set_text (fp, ENVIRONMENT, "");
         break;
      case PASSWORD:
         sts = VDris_Get_text ( fp, g_label, &text, &text_size);
         if (strlen(text) > MAX_TEXT_LEN) text[MAX_TEXT_LEN]=0;
         strcpy(passwd, text );
         break;

      case FI_ACCEPT:
      case USERNAME:
         sts = VDris_Get_text ( fp, USERNAME, &text, &text_size);
         if (strlen(text) > MAX_TEXT_LEN) text[MAX_TEXT_LEN]=0;
         strcpy(username, text );
         if((username == NULL) || (username[0] == 0))
         {
            FIg_set_text (fp, FI_PROMPT_FIELD, "Missing username");
            FIg_set_state_off( fp, FI_ACCEPT);
            break;
         }

	 if (g_label == USERNAME) break;

      case ENVIRONMENT:

         sts = VDris_Get_text ( fp, ENVIRONMENT, &text, &text_size);
         if (strlen(text) > MAX_TEXT_LEN) text[MAX_TEXT_LEN]=0;
         strcpy(environ, text );
         if((environ == NULL) || (environ[0] == 0))
         {
            FIg_set_text (fp, FI_PROMPT_FIELD, "Missing environment name");
            FIg_set_state_off( fp, FI_ACCEPT);
            break;
         }

         if (!VDScheck_environ(environ))
         {
            sprintf(string,"Invalid environment \"%s\"",environ);
            FIg_set_text (fp, FI_PROMPT_FIELD, string);
            FIg_set_state_off( fp, FI_ACCEPT);
            break;
         }

	 if (g_label == ENVIRONMENT) break;

         strcpy(environ_name,"pdme_");
         strcat(environ_name, environ );
         if( strcmp(environ,old_environ) )
         {
            sprintf(string,"Connecting to environment \"%s\"...",environ);
            FIg_set_text (fp, FI_PROMPT_FIELD, string);
            VdsRisDetach();
            VdsReset_ris_env();
            strcpy(VDSenvir_name,environ_name);
            sts = VdsRisConnect(environ_name);
            if( sts != 1) 
            {
               FIg_set_text (fp, FI_MSG_FIELD, "Ris Connection Not Successful");
               FIg_set_state_off( fp, FI_ACCEPT);
               break;
            }
         }
         strcpy(old_environ, environ);

         if ( !VDSvalid_user(username, passwd, string))
         {
            FIg_set_text (fp, FI_MSG_FIELD, string);
            FIg_set_state_off( fp, FI_ACCEPT);
            break;
         }

         VdsPtrStrcpy(&user->username,username);
         VdsPtrStrcpy(&user->passwd,passwd);
         VdsPtrStrcpy(&user->environment,environ);

         VDSset_login_defaults(username,environ,project);

         FIf_erase( fp);
         FIf_delete( fp);
         UI_status("Successful Connection");

      break;
   }

  __exitFunction ( name = "VdsLoginNotif" );

   return SUCCESS;
}

int   VDSRislogin()
{
   int     sts;
   int     xpos,ypos,row;
   char    **environments;
   MEMptr  env_buffer;
   Form	   login_id=NULL;
   
  __enterFunction ( name = "VDSRislogin" );

   sts = SUCCESS;
   environments = NULL;
   env_buffer = NULL;

   /* Get list of environments */
   if ( NFMls_nodes("pdme_",&env_buffer) != NFM_S_SUCCESS)
   {
      UI_status("Failed to get list of environments");
      sts= FAILURE;
      goto wrapup;
   }

   MEMbuild_array(env_buffer);

   if (env_buffer->rows <= 0)
   {
      UI_status("No environments available");
      sts = FAILURE;
      goto wrapup;
   }

   if ( FIf_new(LOGIN_FORM,"VDLogIn",VdsLoginNotif,&login_id) != FI_SUCCESS)
   {
      UI_status("Failed to create login form");
      sts = FAILURE;
      goto wrapup;
   }

   xpos = 306;
   ypos = 122;
   FIf_set_location( login_id, xpos, ypos);

   VDSget_login_defaults(username,environ,project);

   FIfld_set_text( login_id, USERNAME, 0, 0, username, 0);
   if (FIfld_set_list_num_rows(login_id,ENVIRONMENT,0,env_buffer->rows)
       != FI_SUCCESS)
   {
      UI_status("Failed to set number of rows in environment list");
      sts = FAILURE;
      goto wrapup;
   }
   environments=(char **)env_buffer->data_ptr;
   for (row = 0; row < env_buffer->rows; ++row)
   {
      if (VDfld_set_list_text( login_id,
                               ENVIRONMENT,
                               row,
                               0,
                               environments[(env_buffer->columns * row)],
                               1) != FI_SUCCESS)
      {
         UI_status("Failed to set text in environment list");
         sts = FAILURE;
         goto wrapup;
      }
   }
   FIfld_set_text( login_id, ENVIRONMENT, 0, 0, environ, 0);

   if ( FIf_display( login_id ) != FI_SUCCESS)
   {
         UI_status("Failed to display login form");
         sts = FAILURE;
         goto wrapup;
   }
   if (!strcmp(username, ""))
         FIfld_pos_cursor(login_id, USERNAME, 0, 0, 0, 0, 1, 1);
   else
         FIfld_pos_cursor(login_id, PASSWORD, 0, 0, 0, 0, 1, 1);

wrapup:
        if (env_buffer != NULL)  MEMclose(&env_buffer);
   
  __exitFunction ( name = "VDSRislogin" );

   return sts;
}

/* VDSget_login_defaults reads default values from file .vds_def.dat in
   current working directory*/
int VDSget_login_defaults(username,environ,project)

char username[];       /* Default username              (O)*/
char environ[];        /* Default environment           (O)*/
char project[];        /* Default project               (O)*/

{
        int     i;
   char   string[81];
   FILE    *file_ptr;

  __enterFunction ( name = "VDSget_login_defaults" );

   strcpy(username,"");
   strcpy(environ,"");
   strcpy(project,"");

        /* Open .vds_def.dat for reading */
        file_ptr = (FILE *)fopen(".vds_def.dat","r");
        if( file_ptr == NULL )
	{
  __exitFunction ( name = "VDSget_login_defaults" );
	  return 1;
	}

   for (i=0;i<3;i=i+1)
        {
      if ( !fgets ( string, 80, file_ptr)) break;
      /*Remove Newline char*/
      string[strlen(string)-1]=NULL;

      if (i == 0) strcpy(username,string);
      if (i == 1) strcpy(environ,string);
      if (i == 2) strcpy(project,string);
   }
   fclose(file_ptr);

  __exitFunction ( name = "VDSget_login_defaults" );

        return 1;
}

/* VDSset_login_defaults writes default values to file .vds_def.dat in
   current working directory*/
int VDSset_login_defaults(username,environ,project)

char username[];       /* Default username              (I)*/
char environ[];        /* Default environment           (I)*/
char project[];        /* Default project               (I)*/

{
        FILE    *file_ptr;

        /* Open .vds_def.dat for writing */
        file_ptr = (FILE *)fopen(".vds_def.dat","w");
        if( file_ptr == NULL ) return 0;
        fprintf (file_ptr, "%s\n", username);
        fprintf (file_ptr, "%s\n", environ);
        fprintf (file_ptr, "%s\n", project);
   fclose(file_ptr);

        return 1;
}

/*****************************************************************************
VdsPtrStrcpy - String copy to a char pointer
*/
int VdsPtrStrcpy( outstring, string )
  char    **outstring; /* Address of output string   (I/O) */
  char    *string;     /* Character string to be copied (I)   */

{
  if (( *outstring != NULL ) && (strcmp(*outstring,"")))
  {
    _FREE (*outstring);
    *outstring = "";
  }

  if (( string != NULL ) && (strcmp(string,"")))
  {
    *outstring = _MALLOC ( 1+strlen(string),  char);
    if ( *outstring == NULL)
    {
       printf("Unable to allocate needed memory\n");
       return 0;
    }
    strcpy (*outstring, string);
  }

  return 1;
}


/* VDScheck_environ checks if environment is valid*/

int VDScheck_environ(environment)

char environment[];   /* Environment name to be checked  (I) */

/*  Returns 1 if OK
            0 if error;
*/
{
   int row,sts;
   char    **environments;
   MEMptr  env_buffer;

  __enterFunction ( name = "VDScheck_environ" );

   sts = 0;
   environments = NULL;
   env_buffer = NULL;

   /* Get list of environments */
   if ( NFMls_nodes("pdme_",&env_buffer) != NFM_S_SUCCESS)
   {
      UI_status("Failed to get list of environments");
      sts = 0;
      goto wrapup;
   }

   MEMbuild_array(env_buffer);

   if (env_buffer->rows <= 0)
   {
      UI_status("No environments available");
      sts = 0;
      goto wrapup;
   }
   environments=(char **)env_buffer->data_ptr;
   for (row = 0; row < env_buffer->rows; ++row)
   {
      if (!strcmp(environment,environments[(env_buffer->columns * row)]))
      {
         sts = 1;
         goto wrapup;
      }
   }
wrapup:
   if (env_buffer != NULL)  MEMclose(&env_buffer);

  __exitFunction ( name = "VDScheck_environ" );

   return sts;
}

/*

int VdsGetProjectName()
{
   int    sts=SUCCESS;
   int    xpos,ypos,row;
   char	  **buf=NULL;
   int	  num,ret_msg;
   Form	  Proj_id=NULL;
   char	  where[100];

  __enterFunction ( name = "VdsGetProjectName" );

   if(VDSverify_login() != PDM_S_SUCCESS )
   {
	UI_status("User not logged into the database");
	sts = FAILURE;
  __exit_error_Function ( name = "VdsGetProjectName" );
	return sts;
   }
   strcpy(where,"prj_no=0");
   ret_msg = 
    vdb$RisSelect(  select       =     "prj_number",
                    table_name   =     "vds_project",
                    where        =     where,
                    order        =     NULL,
                    group        =     NULL,
                    numselect    =     1,
                    p_numrows    =     &num,
                    p_buffer     =     &buf );

   if( ret_msg  != 1)
   {
      UI_status("Failed to get list of Projects");
      sts = 0;
   }

   strcpy( VDSproject_num, buf[0] );
   vdb$RisFreeBuffer ( buffer  =     buf, 
                       size    =     num);
  __exitFunction ( name = "VdsGetProjectName" );

   return 1;
}
*/
