/* Do not alter this SPC information: $Revision: 1.8.3.1 $ */
/*
**	NAME:							intprep.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").   Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "risasync.h"
#include "riscom.h"
#include "risflags.h"
#include "rismem.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intprep_c
#include "appclear.prt"
#include "appcli.prt"
#include "appid.prt"
#include "appinit.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrng.prt"
#include "comumsg.prt"
#include "interror.prt"
#include "intprep.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************
 * DisguisePasswords looks for user passwords by searching for keywords
 * and a '.' in the query string and returns a new query string in 
 * which passwords are replaced with X's so that when queries are
 * written to a risrecrd output file, passwords will not be revealed.
 *  MAB. 9/1/1994
 */

extern void DisguisePasswords(char *old_query, char *new_query)
{
   char *temp_new;

/** mms - Do not print passwords to debug
   INT_DBG(("entering DisguisePasswords(old_query: <%s>, new_query: <%s>\n",
            old_query, new_query));
***/            

   /*
   ** check if the query string for each of the following formats:
   ** 1.  alter schema <schname> modify schema password <new_passwd>
   ** 2.  alter schema <schname> modify user password <new_passwd>
   ** 3.  alter schema <schname> modify db2 password <new_passwd> 
   ** 4.  create/open/declare/default/drop schema <schema>.<passwd>  
   **       user <username>.<passwd>  osuser <name>.<passwd> 
   ** 
   ** Note:  if the format of this statment changes, then this operation
   **   will most likely fail. 
   */

   strcpy(new_query, old_query);
   RIScom_uppercase( strlen(new_query), (unsigned char *)new_query );

   if ( (temp_new = strstr(new_query,"MODIFY SCHEMA PASSWORD")) != NULL ) /**itbokic 3/30 */
      temp_new += strlen("MODIFY SCHEMA PASSWORD");
  
   else if ( (temp_new = strstr(new_query,"MODIFY USER PASSWORD")) != NULL )/**itbokic 3/30 */
      temp_new += strlen("MODIFY USER PASSWORD");
 
   else if ( (temp_new = strstr(new_query,"MODIFY DB2 PASSWORD")) != NULL )/**itbokic 3/30 */
      temp_new += strlen("MODIFY USER PASSWORD");
 
   /* 
   ** skip over white space between 'password' and the password
   */
   while ( temp_new && isspace(*temp_new) && *temp_new != '\0' )/**itbokic 3/30 */
     temp_new++;

   while ( temp_new && !isspace(*temp_new) && *temp_new != '\0' )/**itbokic 3/30 */
      *(temp_new++) = 'X'; 
   
   /*
   **  search new_query for 'user <username>[.password]
   */ 
   temp_new = new_query;

   while ( *temp_new != '\0' && (temp_new = strstr(temp_new,"USER")) != NULL )/**itbokic 3/30 */
   {
      /* skip past the word 'USER' */
      temp_new += strlen("USER");


      /* skip over white space */
      while ( isspace(*temp_new)  && *temp_new != '\0' && temp_new != NULL)/**itbokic 3/30 */
         temp_new++;

      /*
      ** look for a '.'   if found, then X-out the following password
      */
      while ( !isspace(*temp_new) && *temp_new != '\0' ) /**itbokic 3/30 */
      {
         if ( *temp_new == '.' )
         {
            temp_new++;
            for ( ; !isspace(*temp_new) && *temp_new != '\0'; temp_new++ ) /**itbokic 3/30 */
               *temp_new = 'X';
         }
         else
            temp_new++;
      }  
   } 


   /*
   **  search new_query for 'user <username>[.password]
   */ 
   temp_new = new_query;

   while ( *temp_new != '\0' && (temp_new = strstr(temp_new,"SCHEMA")) != NULL )/**itbokic 3/30 */
   {
      /* skip past the word 'SCHEMA' */
      temp_new += strlen("SCHEMA");

      /* skip over white space */
      while ( isspace(*temp_new)  && *temp_new != '\0' && temp_new != NULL)/**itbokic 3/30 */
         temp_new++;

      /*
      ** look for a '.'   if found, then X-out the following password
      */
      while ( !isspace(*temp_new) && *temp_new != '\0' )/**itbokic 3/30 */
      {
         if ( *temp_new == '.' )
         {
            temp_new++;
            for ( ; !isspace(*temp_new) && *temp_new != '\0'; temp_new++ )/**itbokic 3/30 */
               *temp_new = 'X';
         }
         else
            temp_new++;
      } 
   }

   INT_DBG((" exiting DisguisePasswords -- new_query: <%s>\n",new_query ));
}


/*****************************************************************************/

extern void RISAPI RISXint_prepare(
	short	*stmt_id,
	char	*query,
	int		clear_flag,
	int		static_flag)
{
	int				sts;
	int				len;
	static  short	temp_id;
        char  *new_query;

	INT_DBG(("RISint_prepare(*stmt_id:%d query:<> clear_flag:%d "
		"static_flag:%d)\n", *stmt_id, clear_flag, static_flag));


       /***          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         NOTE:  We can NOT print out the query here because it reveils
         passwords into the dbg files when doing "declare schema" type
         statements! If you add it, remove it before checkin! 

       7/12/94 ***/

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "PREPARE\n");
		fprintf(RIS_RAP, "stmt_id:%d:\n", *stmt_id);
		/* 1996.07.10:Alan Barksdale:TR439601444 */
		new_query = (char *)SYS_MALLOC(strlen(query) + 1);
		DisguisePasswords(query, new_query);
		fprintf(RIS_RAP, "start query:\n%s\nstop query:\n", new_query);
		SYS_FREE(new_query);
		fprintf(RIS_RAP, "clear_flag:%d\n", clear_flag);
		fprintf(RIS_RAP, "static_flag:%d\n", static_flag);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	temp_id = -1;

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (temp_id != -1)
		{
			RISapp_clear(&temp_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT,
				SYNC_MODE);
		}
		SET_RISCA(sts);
		RISrap_return_BEGIN();
			fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
		RISrap_return_END();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	if (!RIS_net)
	{
		RISapp_start_client();
	}

	if (*stmt_id != -1)
	{
		if (static_flag == RIS_STATIC_STMT)
		{
			RESETJMP();
			INT_DBG(("RISint_prepare: complete\n"));
			SET_RISCA(RIS_SUCCESS);
			RISrap_return_BEGIN();
				fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
			RISrap_return_END();
			RIS_RETURN();
		}
		else
		{
			RISapp_clear(stmt_id,DONT_SET_SQLCODE,CLEAR_CLIENT,SYNC_MODE);
		}
	}

	temp_id = RISapp_new_stmt(clear_flag, static_flag);

	/*
	**	save the query
	*/
	len = strlen(query) + 1;
	if (len > RIS_MAX_STMT_LEN)
	{
		sprintf(RIS_ERRMSGC,
			RIScom_umsg(RIS_E_THE_MAXIMUM_NUMBER_OF_CHARACTERS) ,
			RIS_MAX_STMT_LEN - 1);
		LONGJMP(RIS_E_QUERY_TOO_LONG);
	}
	RIS_stmt->query = ALLOCB(len);
	memcpy(RIS_stmt->query, query, len);
	RIScom_fix_space(RIS_stmt->query);

	/*
	**	Save the stmt_id address
	*/
	RIS_stmt->stmt_id_addr = stmt_id;

	RISapp_prep_to_buf(len, query);
	RISapp_send_rec();

	*stmt_id = RIS_current_stmt_id;

	RESETJMP();

	INT_DBG(("RISint_prepare: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return_BEGIN();
		fprintf(RIS_RAP, "new_stmt_id:%d\n", *stmt_id);
	RISrap_return_END();
	RIS_RETURN();
}

/******************************************************************************/
