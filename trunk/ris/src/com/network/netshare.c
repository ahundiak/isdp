/*
**      NAME:                                                   netshare.c
**      AUTHORS:                                                Dave Michal
**      CREATION DATE:                                  5/90
**      ABSTRACT:
**              Shared network routines.
**      
**      REVISION HISTORY:
**      1.  MAB 3/14/94 -- added check for 'access is denied' when 
**                         replacing old schema file on nt system.
**
**		11/94:	Added INTERNATIONALIZATION support. Paula
**
**		Surjit Sahoo (Jan 10, 1995)
**
**			Now, verbose mode is turned on for clipper during ftp.
**			This would help us trap a ftp message (FILE_NOT_FOUND)
**			which can now be identified by ftp error number 550 in
**			stead of replying on the error message. Solved a bunch
**			of TRs related to locating a schema file on NT machine.
**			An NT machine always reported the error as "The system
**			cannot find the file specified." in stead of the usual
**			"No such file ... " which confused all UNIX clients.
**
**		01/95:	Changed the control character '^M' to 0xD.  The NT editors
**				convert the '^M' character to an actual carriage return.  Paula 
**		01/25/95	rlk	changed DETACHED_PROCESS to NULL for Win95
**
**		02/07/95  -- Radha Shivakumar
**				Deleted the change made by Surjit as hard-coding the strings
**				to compare with will affect the I18N support. Also, SHMEM NT
**				code is unnecessary as the netlocal.c file which deals with
**				the SHMEM code has some changes for NT section of the code 
**				thereby removing all calls to NET_execute_command for that 
**				section of the code	
**
**		03/24/95  -- Radha Shivakumar
**				changed the CreateHow variable to be DETACHED_PROCESS and not
**				NULL as the CreateProcess (on Windows 95) fails if it is set 
**				to NULL 
**
*/

/*
**      INCLUDES
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>

#include "ris.h"
#include "risnet.h"
#include "riscom.h"
#include "riscom_macro.h"

#define RISEXPORT

/******************************************************************************/

/* ARGS_USED */
extern void NET_execute_command(
	net_s   *net,
	char    *command,
	int     error_code,
	void    (*error_function)(),
	char    *alt_string,
	int     alt_error_code)
{
	int     i = 0;
#if defined (unix) || defined (vms)
	int     found_error;
	char    c;
	char    errbuf[160];
	char    *token2 = 0;
	char	*errstr = 0;
	FILE    *errfile;
#endif
#if defined(WIN32)
	SECURITY_ATTRIBUTES	sa;
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
	HANDLE hReadPipe, hWritePipe;  			/* handles to the anonymous pipe */
	BOOL				bSuccess;
	char				chReadBuffer[2048];	/* pipe read buffer */
	DWORD				cchReadBuffer;		/* # bytes read & to write */
	int     			found_error;
	int     			alt_size;
	char    			*str;
	DWORD				createHow;			/* creation flags for diff of Win95 and NT */
#endif

	NET_DBG(("NET_execute_command(net:0x%x command:<%s>)\n", net, command));

#if defined(unix)
    if (!(errfile=NET_popen(command,"r")))
    {
		(*error_function)(net,error_code,"");
		return;
    }

	/*
	** Ftp always returns success so we must check stdout and stderr for errors.
	** There are some messages that need to be ingored these begin with "Connected",
	** "Please", "Verbose", "220" and "Using" and "ftp>".
	*/

	if (net->protocol == TCP)
	{
		while ((c = (char)(NET_getc(errfile))) != EOF)
		{
			/*
			** get the first token
			*/
			errbuf[0] = c;
			for(i = 1;
				i < sizeof(errbuf) - 1 && 
				(c = (char)(NET_getc(errfile))) != EOF &&
					!isspace(c);
				i++)
			{
				errbuf[i] = c;
			}

			/*
			** We want the second token too; as
			** one of the messages we want to ignore is :
			** "<number> bytes received ..."
			*/
			if (isspace(c))
			{
				errbuf[i++] = c;
				token2 = &errbuf[i];

				/*
				** Get the second token
				*/
				for (;
					 i < sizeof(errbuf) - 1 && 
					 (c = (char)NET_getc(errfile)) != EOF &&
					 !isspace(c);
					i++)
				{
					errbuf[i] = c;
				}
			}

			/*
			** First two tokens are null-terminated just to be printed.
			**/
			errbuf[i] = '\0';
			NET_DBG(("TCP/IP (FTP Output): First 2 tokens:<%s>\n", errbuf));

			/*
			** check for messages that should be ignored
			** 550 (which used to be ignored) is FILE_NOT_FOUND
			** and should NEVER be ignored on any unix machine.
			**
			** TR#249407620           Surjit (Jan 10, 1995)
			*/

			if (strncmp(errbuf,"Connected",sizeof("Connected")-1) &&
			 strncmp(errbuf,"Please",sizeof("Please")-1) &&
			 strncmp(errbuf,"Verbose",sizeof("Verbose")-1) &&
			 strncmp(errbuf,"220",sizeof("220")-1) &&
			 strncmp(errbuf,"ftp>",sizeof("ftp>")-1) &&
			 strncmp(errbuf,"local",sizeof("local")-1) &&
			 strncmp(errbuf,"150",sizeof("150")-1) &&
			 strncmp(errbuf,"200",sizeof("200")-1) &&
			 strncmp(errbuf,"221",sizeof("221")-1) &&
			 strncmp(errbuf,"226",sizeof("226")-1) &&
			 strncmp(errbuf,"230",sizeof("230")-1) &&
			 strncmp(errbuf,"250",sizeof("250")-1) &&
			 strncmp(errbuf,"257",sizeof("257")-1) &&
			 strncmp(errbuf,"331",sizeof("331")-1) &&
			 strncmp(token2, "bytes", sizeof("bytes")-1) &&
#if defined (sco)
			 strncmp(errbuf,"239",sizeof("239")-1) &&
			 strncmp(errbuf,"netout:",sizeof("netout:")-1) &&
#endif
			 strncmp(errbuf,"Using",sizeof("Using")-1))
			{
				/* found an error, get the rest of the message */
				if (c != '\n')
				{
					if (isspace(c))
					{
						errbuf[i++] = c;
					}
					errstr = &errbuf[i];	/* points to the OS error text */
					for(;i < sizeof(errbuf)-1 &&
						(c=(char)(NET_getc(errfile))) != EOF && c != '\n';i++)
					{
						errbuf[i] = c;
					}
					errbuf[i] = '\0';
				}

				/* skip any more input */
				while ((c=(char)(NET_getc(errfile))) != EOF);

				break;
			}

			/* ignoring this message, dispose the rest of it */

			i=0;
			if (c != '\n')
			{
				while ((c=(char)(NET_getc(errfile))) != EOF && c != '\n');
			}
		}
		NET_pclose(errfile);
		found_error = i;
	}
	else
	{
		for (i=0;i < sizeof(errbuf)-1 && 
			 (c=(char)(NET_getc(errfile))) != EOF;i++)
		{
			errbuf[i] = c;
		}
		errbuf[i] = '\0';
		NET_DBG(("NET_execute_command: errbuf:<%s>\n", errbuf));
		found_error = NET_pclose(errfile);
	}

	if (found_error)
	{
		int alt_error_found = 0;
#if defined(Soli)
		int alt_size = (alt_string == 0 ) ? 0:strlen(alt_string);
#else
		int alt_size = strlen(alt_string);
#endif
		char *str = 0;

		if (alt_string)
		{
			for(str=errbuf;*str;str++)
			{
				if (strncmp(str,alt_string,alt_size) == 0)
				{
					alt_error_found = 1;
					break;
				}
			}

		}

		if (alt_error_found)
			(*error_function)(net,alt_error_code,errbuf);
		else
			(*error_function)(net, error_code, errbuf);
		return;
	}
#endif  /* all unix machines */

	NET_DBG(("NET_execute_command: complete\n"));
	return;
}

/******************************************************************************/

extern void NET_error(net_s *net, int code)
{
	NET_DBG(("NET_error(net:0x%x code:%d)\n", net, code));

	net->error_code = code;
	strcpy(net->error_string, NET_error_msg(net->error_code));

	switch((unsigned int)code)
	{
		case NET_E_CANT_GET_SHM_SEG:
		case NET_E_CANT_GET_SHM_SEG_NT:
		case NET_E_CANT_GET_SEM_SET:
		case NET_E_CANT_ATTACH_SHM_SEG:
		case NET_E_CANT_ATTACH_SHM_SEG_NT:
		case NET_E_CANT_DETACH_SHM_SEG:
		case NET_E_CANT_REMOVE_SEM_SET:
		case NET_E_CANT_REMOVE_SHM_SEG:
			if (errno)
			{
				net->net_error_code = errno;
				strcpy(net->net_error_string, strerror(errno));
			}
			else
			{
				net->net_error_code = 0;
				net->net_error_string[0] = '\0';
			}
			break;
	}

	NET_DBG(("NET_error: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error: net->net_error_string:<%s>\n", net->net_error_string));
	NET_DBG(("NET_error: complete\n"));
}

/******************************************************************************/

/*
**  Get difference of time from current time with respect to start_time and
**  timeout seconds
*/
extern time_t NET_get_remaining_time(time_t  *start_time, time_t  timeout)
{
    time_t  curr_time = 0;
    time_t  difference = 0;

    NET_DBG(("NET_get_remaining_time(*start_time:%d timeout:%d\n",
	    *start_time, start_time));
    time(&curr_time);
    NET_DBG(("NET_get_remaining_time: curr_time:%d\n", curr_time));

    difference = timeout - (curr_time - *start_time);

	/*
	** For next iteration
	*/
	*start_time = curr_time;

    NET_DBG(("NET_get_remaining_time: returning difference:%d\n", difference));
    return difference;
}

/******************************************************************************/

extern int NET_strcmp_ic(char *s1, char *s2)
{

#ifdef WIN32
	wchar_t	*tmp_s1;
	wchar_t	*tmp_s2;	
	wint_t	c1;
	wint_t	c2;
	wint_t	ret;

	/* sending 0 to indicate null terminated string */

	RIScom_multiwide ( &RISwide_ptr, &s1, &RISwide_size, MULTITOWIDE, 0);
	RIScom_multiwide ( &RISwide_ptr2, &s2, &RISwide_size2, MULTITOWIDE, 0);

	tmp_s1 = RISwide_ptr;
	tmp_s2 = RISwide_ptr2;

#else
	char 	*tmp_s1;
	char	*tmp_s2;
	int 	ret;
	int 	c1;
	int 	c2;

	tmp_s1 = s1;
	tmp_s2 = s2;
#endif

	while(1)
	{
		if (ISUPPER(*tmp_s1))
		{
			c1 = TOLOWER(*tmp_s1);
		}
		else
		{
			c1 = *tmp_s1;
		}

		if (ISUPPER(*tmp_s2))
		{
			c2 = TOLOWER(*tmp_s2);
		}
		else
		{
			c2 = *tmp_s2;
		}

		if ((ret = c1 - c2) != 0)
		{
			break;
		}
		if (*tmp_s1 == 0) /* which implies *s2 == 0 */
		{
			break;
		}
		tmp_s1++;
		tmp_s2++;
	}
	return ((int)ret);
}
/******************************************************************************/

