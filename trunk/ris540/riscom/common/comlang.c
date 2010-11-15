/*
** NAME:       comlang.c
** AUTHORS:	  Hitesh R. Patel
** CREATION DATE:	5/93
** ABSTRACT:
**     This file handles all language information.
**     The ris language config file is read for all language conversions.
**     These information will be maintained in a list of ris_lang_info 
**     structures. Functions are provided to extract information from this
**     list. This list is static to this file.
**
** REVISION HISTORY:
**
**  11/94:	Replaced the call RIScom_issgchar with RIScom_isleadbyte
**			for INTERNATIONALIZATION support. Paula
**
**	03/95:	Changed RIScom_get_lang_info to return the first language in the
**			langs file if the language being searched for is not in the list.
**			At this time, this is english.
**
** 4/96:	Added RIScom_get_code_page() for I18N.  Related to TR 439600180
**		Ashley B. 
** 5/96 	Changed code page functionality so that now the code page is 
** 		received from the langs file
** 7/96         Fixed code error in getting code page. Ashley
*/


/*
** INCLUDES
*/
#include <stdio.h>
#include <stdlib.h>
#if defined(WIN32)
#include <windows.h>
#include <locale.h>
#include "complat.prt"
#endif
#include "riscom.h"
#include "risdebug.h"
#include "rismem.h"
#include "rispath.h"
#include "risstjmp.h"
#include "ris_err.h"
#include "ris.h"

/*
** DEFINES
*/


#define CONFIG_COMMENT_SYMBOL '#' /* Default comment symbol in config file */
#define CONFIG_DELIMITER     '|' /* Default delimiter symbol in config file */
#define LINE_BUFFER_SIZE     512 /* ID + NAME + 8 + ID + NAME */

typedef struct ris_lang_info
{
   int	     ris_lang_id;  /* ris language id */
   char        *ris_lang_name;	       /* ris language name */
   char        *ris_lang_dir;	    /* ris language directory */
   int	     os_lang_id;      /* os language id */ 
   int        code_page;   /* ANSI code page Ashley 5-96 */ 
   char        *os_lang_name;	    /* os language name */
   struct ris_lang_info *next;
} ris_lang_info;

/*
** VARIABLES
*/
static	  FILE	      *RIS_config_fp = 0;  /* config file pointer */
static	  struct ris_lang_info *RIS_languages = 0; /* list of ris_lang_info */
static	  int	      RIS_init_langs = 0; /* initialize config file */

/*
** FUNCTIONS
*/

/*
** FUNCTION PROTOTYPES
*/
#define comlang_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comlang.prt"
#include "comstcmi.prt"
#include "comwrap.prt"
#include "comuni.prt"
#include "sys.prt"
#if defined(WIN32)
#include <windows.h>
#endif

/******************************************************************************/

/*
** This function returns ris language id for a given ris language name
*/
extern int RIScom_ris_lang_code(
   char *name)
{
   struct ris_lang_info *langp;

   COM_DBG(("RIScom_lang_code(name:<%s>)\n", name));

   langp = RIScom_get_lang_info(RIS_LANGUAGE_NAME, (void *)name);

   if( langp ) 
   {
      COM_DBG(("RIScom_lang_code:returning <%d>)\n", langp->ris_lang_id));
      return(langp->ris_lang_id);
   }
   else
   {
      COM_DBG(("RIScom_lang_code:returning -1\n"));
      return(-1);
   }
}

/******************************************************************************/

/*
** This function returns ris language name for a given ris language id
*/
extern char *RIScom_ris_lang_name(
   int code)
{
   struct ris_lang_info *langp;

   COM_DBG(("RIScom_lang_name(code:%d)\n", code));
   langp = RIScom_get_lang_info(RIS_LANGUAGE_ID,(void *)&code);
   if( langp )
   {
      COM_DBG(("RIScom_lang_code:returning <%s>)\n", langp->ris_lang_name));
      return(langp->ris_lang_name);
   }
   COM_DBG(("RIScom_lang_code:returning NULL\n"));
   return(NULL);
}

/******************************************************************************/

/*
** This function returns ris language directory for a given ris language id
*/
extern char *RIScom_ris_lang_dir(
   int code)
{
   struct ris_lang_info *langp;

   COM_DBG(("RIScom_lang_dir(code:%d)\n", code));
   langp = RIScom_get_lang_info(RIS_LANGUAGE_ID,(void *)&code);
   if( langp )
   {
      COM_DBG(("RIScom_lang_code:returning <%s>)\n", langp->ris_lang_dir));
      return(langp->ris_lang_dir);
   }
   COM_DBG(("RIScom_lang_code:returning NULL\n"));
   return(NULL);
}

/******************************************************************************/

/*
** This function returns default ris language name.
** For non-NT systems it "english" (RIS_DEFAULT_LANGUAGE).
** For NT systems it uses LOCALE information and then maps to corresponding ris
** language name.
*/
extern char *RIScom_default_ris_langname()
{
#if defined(WIN32)
   struct ris_lang_info *langp;
   int os_id;
#endif
   COM_DBG(("RIScom_default_ris_langname()\n"));
   /*
   ** Return the default language
   */
#if defined(unix) || defined(DOS)
   return(RIS_DEFAULT_LANGUAGE);
#endif
#if defined(WIN32)
   /*
   ** Get NT language, map it to RIS language and then return RIS language
   */
   os_id = strtol(get_locale_info(LOCALE_ILANGUAGE), (char **)0, 16);

   langp = RIScom_get_lang_info(OS_LANGUAGE_ID,(void *)&os_id);
   if( !langp )
   {
      LONGJMP(RIS_E_INTERNAL_ERROR);
   }
   COM_DBG(("RIScom_default_ris_langname:returning <%s>\n", 
      langp->ris_lang_name));
   return(langp->ris_lang_name);
#endif
}

extern int RIScom_get_code_page(
/*
** This function returns a ANSI code page given a ris language ID
*/
   int RIS_language_code)
{
   struct ris_lang_info *langp;

   COM_DBG(("RIScom_get_code_page(lang_id:<%d>)\n", RIS_language_code));

   langp = RIScom_get_lang_info(RIS_LANGUAGE_ID, (void *)&RIS_language_code);

   if( langp ) 
   {
      COM_DBG(("RIScom_get_code_page:returning <%d>)\n", langp->code_page));
      return(langp->code_page);
   }
   else
   {
      COM_DBG(("RIScom_get_code_page:returning -1\n"));
      return(-1);
   }
}

/******************************************************************************/

/*
** This function returns LOCALE information from registry. LOCALE type can be
** any piece of locale information e.g., LOCALE_ILANGUAGE, LOCALE_SLANGUAGE etc
**/
#if defined(WIN32)
static char *get_locale_info(
   LCTYPE locale_type)
{
   typedef int (*PFNDLL)(LCID,LCTYPE,LPSTR,int);//Win95
   LCID    lcid;    /* LOCALE identifier */
   WCHAR   wide_locale[RIS_MAX_LANGNAME_SIZE];
      /* LOCALE information (UNICODE) */
   LPWSTR  lp_wide;	/* pointer to wide_locale */
   static   CHAR multi_locale[RIS_MAX_LANGNAME_SIZE];  
      /* LOCALE information (MULTI-BYTE)*/
   LPSTR   lp_multi;	   /* pointer to multi_localte */
   int		wide_length;	  /* sizeof LOCALE information (UNICODE) */
   int		multi_length;	  /* sizeof LOCALE information (MULTI) */
   int		status;        /* return status from WIN32 API */
   BOOL    ifdef_flag;		  /* default conversions indicator */
   HANDLE hLibrary;//Win95
   PFNDLL lpGetLocaleInfo;//Win95

   COM_DBG(("get_locale_info(locale_type:%d)\n", locale_type));

    /*
    ** Find out what the user's language preference is by reading the LCID
    ** from the current default locale.
    */
    lcid = LOCALE_USER_DEFAULT;
    lp_wide = &wide_locale[0];

    if ((status = SETJMP()) != 0 )
    {
      RESETJMP();
      return(NULL);
    }

    if ( (RIScom_get_platform() == IS_CHICAGO) || (RIScom_get_platform() == IS_WIN32S) )
    {
      // get the kernel32.dll
      hLibrary = LoadLibrary("KERNEL32.DLL");//Win95
      if (!hLibrary)
      {
       COM_DBG(("Could not load kernel32.dll\n", wide_length));
       LONGJMP(RIS_E_ERROR_FROM_LOCALE);
      }
      lpGetLocaleInfo = (PFNDLL)GetProcAddress(hLibrary,"GetLocaleInfoA");//Win95

       /*
       ** Get number of chars required
       */
       // get the kernel32.dll

      wide_length = (*lpGetLocaleInfo)((LCID)lcid, /* LOCALE identifier  */
      (LCTYPE)locale_type,    /* type of information */
      (LPSTR)NULL,	/* address of buffer   */
      (int)0);	    /* sizeof buffer	   */
 
       COM_DBG(("get_locale_info:wide_length=%d\n", wide_length));
 
       if( !wide_length )
       {
	  FreeLibrary(hLibrary);
	  LONGJMP(RIS_E_ERROR_FROM_LOCALE);
       }
 
       /*
       ** Get Locale Info
       */
       status = (*lpGetLocaleInfo)((LCID)lcid,	  /* LOCALE identifier	 */
       (LCTYPE)locale_type,   /* type of information */
       (LPSTR)multi_locale,    /* address of buffer   */
       (int)wide_length);  /* sizeof buffer */
      if (status == 0)
       {
	 FreeLibrary(hLibrary);
	LONGJMP(RIS_E_ERROR_FROM_LOCALE);
       }
    
       RESETJMP();
       COM_DBG(("get_locale_info: returning multi_locale:<%s>\n", multi_locale));
       FreeLibrary(hLibrary);
       return(multi_locale);
    }
 
    /* for non-Windows95 systems */

   /*
   ** Get number of chars required
   */
    wide_length = GetLocaleInfoW(lcid,	    /* LOCALE identifier   */
   locale_type,     /* type of information */
   NULL,       /* address of buffer   */
   0);	    /* sizeof buffer	*/

   COM_DBG(("get_locale_info:wide_length=%d\n", wide_length));

   if( !wide_length )
   {
      LONGJMP(RIS_E_ERROR_FROM_LOCALE);
   }

   /*
   ** Get Locale Info
   */
   status = GetLocaleInfoW(lcid,     /* LOCALE identifier   */
   locale_type,    /* type of information */
   lp_wide, /* address of buffer   */
   wide_length);   /* sizeof buffer	 */
    if (status == 0)
   {
      LONGJMP(RIS_E_ERROR_FROM_LOCALE);
   }
   if( RIScom_debug )
   {
      int i;
      COM_DBG(("get_locale_info: UNICODE STRING->"));
      for(i = 0; i < wide_length-1; i++ )
    COM_DBG(("%c", wide_locale[i]));
      COM_DBG(("\n"));
   }

   lp_multi = &multi_locale[0];

   /*
   ** Get number of chars required
   */
    multi_length = WideCharToMultiByte(CP_ACP, /* code page */
    0,	      /* mapping flags */
    lp_wide,	/* address of wide-char str */
    wide_length,  /* number of chars in str */
    NULL,	  /* address of multi str */
    0,	       /* number of char in multi str */
    NULL,	 /* address of default */
    &ifdef_flag); /* address of ifdefflag */


   COM_DBG(("get_locale_info:multi_length=%d\n", multi_length));

   if( !multi_length )
   {
      LONGJMP(RIS_E_ERROR_FROM_LOCALE);
   }

   /*
   ** Convert form UNICODE to mutlibyte using ASCII-code page
   */
   status = WideCharToMultiByte(CP_ACP,       /* code page */
    0,	      /* mapping flags */
    lp_wide,	/* address of wide-char str */
    wide_length,  /* number of chars in str */
    lp_multi,  /* address of multi str */
    multi_length, /* number of char in multi str */
    NULL,	 /* address of default */
    &ifdef_flag); /* address of ifdefflag */

    if (status == 0)
   {
      LONGJMP(RIS_E_ERROR_FROM_LOCALE);
   }

   RESETJMP();
   COM_DBG(("get_locale_info: returning multi_locale:<%s>\n", multi_locale));
   return(multi_locale);
}
#endif

/******************************************************************************/

/*
** This function returns language information known to ris (ris_lang_info list)
** read form language config file.
** Output: char pointer to piece of language infor asked for
** Input: 1. output_type = type of info required (stated in rislang.h)
** 2. input_type  = type of info matched against (stated in rislang.h)
** 3. inptr   = char pointer pointing to input information
*/
extern struct ris_lang_info *RIScom_get_lang_info(
	int input_type,
	void *inptr)
{
	struct ris_lang_info *langp;
	int found_flag = 0;

	COM_DBG(("RIScom_get_lang_info(input_type:%d inptr:0x%x)\n", 
			input_type, inptr));

	if( !RIS_languages )
	{
		LONGJMP(RIS_E_LANGCONFIG_NOT_INITIALIZED);
	}

	for( langp = RIS_languages; langp ; langp = langp->next )
	{
		switch(input_type)
		{
		    case RIS_LANGUAGE_ID:
				if( *(int *)inptr == langp->ris_lang_id ) 
				{
					found_flag = 1;
				}
			    break;

			case RIS_LANGUAGE_NAME:
				if( !RIScom_strncmp_ic(inptr,langp->ris_lang_name,
					strlen(langp->ris_lang_name)) )
				{
					found_flag = 1;
				}
				break;

			case RIS_LANGUAGE_DIR:
				if( !RIScom_strncmp_ic(inptr,langp->ris_lang_dir,
					strlen(langp->ris_lang_dir)) )
				{
					found_flag = 1;
				}
		    	break;

			case OS_LANGUAGE_ID:
		       /*
		       ** OS language ids are preserved as they are and therefore 
		       ** should be retreived as they are
		       */
				if( *(int *)inptr == langp->os_lang_id )
				{
					found_flag = 1;
				}
				break;


			case OS_LANGUAGE_NAME:
				/*
				** OS language names are preserved as they are and therefore 
				** should be retreived as they are
				*/
				if( !strncmp(inptr,langp->os_lang_name,
					strlen(langp->os_lang_name)) )
				{
					found_flag = 1;
				}
				break;
	
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);  
				break;
	     } /* end switch */

		if( found_flag )
		{
			COM_DBG(("RIScom_get_lang_info: returning langp:0x%x\n", langp)); 
			return(langp);
		}
	}/* end for */
	langp = RIS_languages;   
	COM_DBG(("RIScom_get_lang_info: returning default language <%s>\n",
				langp->ris_lang_name));
	return(langp);
}

/******************************************************************************/

/*
** Static function to read next line from ris language config file
*/
extern void RIScom_initialize_langs(
	char *path)
{
	int		sts;
	char	*buffer;
	char	filepath[RIS_MAX_PATH_SIZE];

	COM_DBG(("RIScom_initialize_langs(path:<%s>)\n", path));

	if( RIS_init_langs )
	{
		COM_DBG(("RIScom_initialize_langs: already initialized.\n"));
		return;
	}
#ifdef vms
	sprintf(filepath,"%s%s", path, CONFIG_FILE_NAME);
#else
	sprintf(filepath,"%s%c%s", path, PATH_CHAR, CONFIG_FILE_NAME);
#endif
	if ((RIS_config_fp = RIScom_fopen(filepath, "r")) == NULL)
	{
		LONGJMP(RIS_E_CANT_OPEN_LANGCONFIG_FILE);
	}

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		RIScom_term_langs();
		RIScom_fclose(RIS_config_fp);
		LONGJMP(sts);
	}

	if ((buffer = read_next_line()) == NULL)
	{
		/*
		**	Empty file, that's not ok.
		*/
		LONGJMP(RIS_E_CANT_OPEN_LANGCONFIG_FILE);
	}

	while ((buffer = read_next_line()) != NULL)
	{
		if (*buffer == CONFIG_COMMENT_SYMBOL || *buffer == '\n' )
		{
			/* IGNORE THIS LINE */
		}
		else
		{
			/* ALLOCT STRUCT */
			read_lang_info(buffer);
		}
	}

	RESETJMP();
	/*
	** commenting this out; uncomment if you really need this -surjit (03/96)
	**
	** put PRINT_ALL_RIS_LANG_INFO ifdef to make code cleaner - Ashley 4/96
	*/
#ifdef PRINT_ALL_RIS_LANG_INFO
	 print_all_ris_lang_info();
#endif
	RIScom_fclose(RIS_config_fp);
	RIS_init_langs = 1;
	COM_DBG(("RIScom_initialize_langs: returning\n"));
}

/******************************************************************************/

/*
** Cleanup variables
*/
extern void RIScom_term_langs()
{
	struct ris_lang_info	*langp;
	struct ris_lang_info	*savep;

	COM_DBG(("RIScom_term_langs()\n"));

	langp = RIS_languages;
	while( langp )
	{
		savep = langp->next;
		if(langp->ris_lang_name) SYS_FREE(langp->ris_lang_name);
		if(langp->ris_lang_dir)  SYS_FREE(langp->ris_lang_dir);
		if(langp->os_lang_name)  SYS_FREE(langp->os_lang_name);
		SYS_FREE((char *)langp);
		langp = savep;
	}
	RIS_init_langs = 0;
	RIS_languages = 0;

	COM_DBG(("RIScom_term_langs: returning\n"));
}

/******************************************************************************/

/*
** Static function to read next line from ris language config file
*/
static char *read_next_line()
{
	auto	char	*src;
	auto	char	*dst;
	auto	char	temp[LINE_BUFFER_SIZE];
	static	char	buffer[LINE_BUFFER_SIZE];

	temp[LINE_BUFFER_SIZE - 2] = 0;
	if (RIScom_fgets(temp, LINE_BUFFER_SIZE, RIS_config_fp) == NULL)
	{
		return NULL;
	}
	if (temp[LINE_BUFFER_SIZE - 2] && temp[LINE_BUFFER_SIZE - 2] != '\n')
	{
		LONGJMP(RIS_E_LANGCONFIG_LINE_TOO_LONG);
	}

	for (dst = buffer, src = temp; *src; src++)
	{
		if (!RIScom_isascii(*src) && RIScom_isleadbyte(*src))
		{
			LONGJMP(RIS_E_NON_ASCII_IN_LANGCONFIG);
		}
		*dst++ = *src;
	}
	*dst = '\0';

	return buffer;
}

/******************************************************************************/

/*
** Static function to read put info from ris language config file to 
** ris_lang_info list.
*/
static void read_lang_info(
	char *buffer)
{
	static	struct ris_lang_info	*last_langp = 0;
	struct	ris_lang_info        	*current_langp = 0;
	char	*strptr = buffer;
	char	*tokptr;
	char	*returnptr;
	int		length;
	char	delimiters[3];
	int		ris_lang_id = -1;
	char	ris_lang_name[RIS_MAX_LANGNAME_SIZE];
	char	ris_lang_dir[RIS_MAX_PATH_SIZE]; 
	int		os_lang_id = -1;
	int		code_page = -1;
	char	os_lang_name[RIS_MAX_LANGNAME_SIZE];


	delimiters[0] = CONFIG_DELIMITER;
	delimiters[1] = '\n';
	delimiters[2] = '\0';
   
	if( !strchr(buffer, CONFIG_DELIMITER) )
	{
		return;
	}
	if ((tokptr = strtok(strptr, delimiters)) != (char *)NULL)
	{
		returnptr = remove_lead_n_trail_spaces(tokptr);
		ris_lang_id = atoi(returnptr);
	}
	else
	{
		LONGJMP(RIS_E_MISSING_RIS_LANG_ID);
	}
	if ((tokptr = strtok(NULL, delimiters)) != (char *)NULL)
	{
		returnptr = remove_lead_n_trail_spaces(tokptr);
		length = strlen(returnptr);
		if( length > RIS_MAX_LANGNAME_SIZE )
		{
			LONGJMP(RIS_E_EXCEED_LANGNAME_SIZE);
		}
		strcpy(ris_lang_name,returnptr);
	}
	else
	{
		LONGJMP(RIS_E_MISSING_RIS_LANG_NAME);
	}
	if ((tokptr = strtok(NULL, delimiters)) != (char *)NULL)
	{
		returnptr = remove_lead_n_trail_spaces(tokptr);
		length = strlen(returnptr);
		if( length > RIS_MAX_DIRNAME_SIZE )
		{
			LONGJMP(RIS_E_EXCEED_DIRNAME_SIZE);
		}
		strcpy(ris_lang_dir,returnptr);
	}
	else
	{
		LONGJMP(RIS_E_MISSING_CONFIG_DIR);
	}
	if ((tokptr = strtok(NULL, delimiters)) != (char *)NULL)
	{
		returnptr = remove_lead_n_trail_spaces(tokptr);
		os_lang_id = strtol(returnptr, (char**)0, 16);
	}
	else
	{
		LONGJMP(RIS_E_MISSING_OS_LANG_ID);
	}
	if ((tokptr = strtok(NULL, delimiters)) != (char *)NULL)
	{  
/* Ashley 5-3-96 */
		returnptr = remove_lead_n_trail_spaces(tokptr);
		code_page = atoi(returnptr);
	}
	else
	{
		LONGJMP(RIS_E_MISSING_CODE_PAGE);
	}
	if ((tokptr = strtok(NULL, delimiters)) != (char *)NULL)
	{
		returnptr = remove_lead_n_trail_spaces(tokptr);
		length = strlen(returnptr);
		if( length > RIS_MAX_LANGNAME_SIZE )
		{
			LONGJMP(RIS_E_EXCEED_LANGNAME_SIZE);
		}
		strcpy(os_lang_name,returnptr);
	}
	else
	{
		LONGJMP(RIS_E_MISSING_OS_LANG_NAME);
	}
      
	/*
	** Allocate ris_lang_info structure in PERMENANT memory
	*/
	current_langp = 
		(struct ris_lang_info *) SYS_MALLOC(sizeof(struct ris_lang_info));
	length = strlen(ris_lang_name) + 1;
	current_langp->ris_lang_name = (char *) SYS_MALLOC(length);
	length = strlen(ris_lang_dir) + 1;
	current_langp->ris_lang_dir = (char *) SYS_MALLOC(length);
	length = strlen(os_lang_name) + 1;
	current_langp->os_lang_name = (char *) SYS_MALLOC(length);

	current_langp->ris_lang_id = ris_lang_id;
	strcpy(current_langp->ris_lang_name, ris_lang_name);
	strcpy(current_langp->ris_lang_dir, ris_lang_dir);
	current_langp->os_lang_id = os_lang_id;
	current_langp->code_page = code_page; /* Ashley 5-3-96 */
	strcpy(current_langp->os_lang_name, os_lang_name);
	current_langp->next = 0;

	if( !RIS_languages )
	{
		RIS_languages = current_langp;
	}
	else
	{
		last_langp->next = current_langp;
	}
	last_langp = current_langp;
}

/******************************************************************************/

/*
** Static function to strip leading and trailing spaces
*/
static char *remove_lead_n_trail_spaces(
	char *src)
{
	char *dst;
	char *lst;

	lst = src + (strlen(src) - 1);

	for(;;src++)
	{
		if( !RIScom_isspace(*src) ) break;
	}
	dst = src;
	for(;;lst--)
	{
		if( RIScom_isspace(*lst) ) 
		{
			continue;
		}
		else 
		{
			*(++lst) = '\0';
			break;
		}
	}

	return(dst);
}

/******************************************************************************/


/******************************************************************************/


#ifdef PRINT_ALL_RIS_LANG_INFO
/*
** Obvious
*/
static void print_all_ris_lang_info()
{
	struct ris_lang_info *langp;
	COM_DBG(("print_all_ris_lang_info - Begin\n"));
	for(langp = RIS_languages; langp; langp = langp->next )
	{
		print_ris_lang_info(langp);
	}
}

/******************************************************************************/

/*
** Obvious
*/
static void print_ris_lang_info(
	struct ris_lang_info *langp)
{
	COM_DBG(("ris_lang_id   = <%d>\n", langp->ris_lang_id));
	COM_DBG(("ris_lang_name = <%s>\n", langp->ris_lang_name));
	COM_DBG(("ris_lang_dir  = <%s>\n", langp->ris_lang_dir));
	COM_DBG(("os_lang_id    = <%d>\n", langp->os_lang_id));
	COM_DBG(("code_page    = <%d>\n", langp->code_page));
	COM_DBG(("os_lang_name  = <%s>\n", langp->os_lang_name));
}
#endif

/******************************************************************************/
