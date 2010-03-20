/*************************/
/* setup.c, $Revision: 1.14 $   */
/*************************/

#if defined(i86pc)
#include <sys/utsname.h>  /* add for ingr root (moved for ISL only) */
#endif

#include "FImin.h"
#include "FEI.h"

#include <stdio.h>
#include <ctype.h> /*** need this for isspace() ***/

#define NDEBUG 1
#include <assert.h> 

#include "FS.h"        /* dmb:01/11/93: Was FSX.h */
#include "FSBmap.h"    /* dmb:01/11/93: Was FSXBmap.h */

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

#if !defined(i86pc)
#include <sys/utsname.h>  /* add for ingr root */
#endif

#define WIDEST_CHAR 'M'
#define WIDEST_WCHAR 0xb0a1

#define FI_FS_FONTS_FIRST	1
#define FI_X_FONTS_FIRST	2


extern int _FI_symbol_path_size;
extern int _FI_symbol_path_index;
extern char ** _FI_symbol_path;

#ifdef __hpux

FSEnter()
{
}

int FSXDrawText( Display *display, int      screen, Window   window,
	GC       gc, Font     font_id, char    *text, int      length,
	double   xpos, double   ypos, double  *next_x, double  *next_y)
{
  return(0);
}

FSGetBmapInfo ()
{
}
int FSXDrawChar (Display *display, int screen, Window window, GC gc,
	Font font_id, short ch, double xpos, double ypos, 
	double *next_x, double *next_y)
{
  return(0);
}
FSGetTextVect ()
{
}
FSReadCharMapFile ()
{
}
FSNewFont ()
{
}
#endif

/******************************************************************/
/* GMD 1/14/92    Added FI_set_select_button call                 */
/*                This call allows you to specify which of the    */
/*                mouse buttons (1, 2, or 3) that will be used    */
/*                as the selection button.  The default is 2.     */
/******************************************************************/

int FI_set_select_button ( int button )
{
   if ( (button < 1) || (button > 3) )
    {
      return (FI_ILLEGAL_VALUES);
    }

   _FI_select_button = button;

   return (FI_SUCCESS);
}

int FI_get_select_button ( int *button )
{
   *button = _FI_select_button;

   return (FI_SUCCESS);
}


static void _FI_get_path ( char   path[],
                           char  *path_dir[],
                           int    path_dir_index )
{
  int	ii;


  for ( ii = 0; ii < path_dir_index; ii++ )
    {
      if ( ii == 0 )
	{
	  strcpy ( path, path_dir[ii] );
	}
      else
	{
	  strcat ( path, ":" );

	  strcat ( path, path_dir[ii] );
	}
    }
}



static int _FI_get_path_length (char  *path_dir[],
                                int    path_dir_index)
{
  int	ii;
  int	path_length = 0;

  for ( ii = 0; ii < path_dir_index; ii++ )
    {
      /**************************************************************
      fprintf ( stderr, "_FI_get_path_length:  path_dir[%d] = '%s'\n",
						ii, path_dir[ii] );
      **************************************************************/

      path_length +=  strlen ( path_dir[ii] );

      /**************************************************************
      fprintf ( stderr,
	"_FI_get_path_length:  path_length = %d\n", path_length );
      **************************************************************/
    }

	/*** add in length of all the ":" and null on end ***/
  path_length += path_dir_index ;

	/***  if the path is null, then add 1 to it for the null ***/
  if ( path_length == 0 )
    path_length = 1;

  /**************************************************************
  fprintf ( stderr,
    "_FI_get_path_length:  FINAL path_length = %d\n\n", path_length );
  **************************************************************/

  return ( path_length );
}


void _FI_parse_unix_path (char *path,
                          char ***dirs,
                          int  *num_dirs)
{
   int num;
   int length;
   int space_available;
   char *char_ptr;
   char *prev_ptr;

   *num_dirs = 0;

   /* Remove leading colons and spaces */

   for (;;)
   {
	  if ((path[0]== ':') || isspace(path[0]))
	     {
		 strcpy (path, &path[1]);
	     }
	  else
	     {
		 break;
	     }
   }

   /* Remove trailing colons */

   for (;;)
   {
	  length = strlen (path) - 1;

	  if ((path[length]== ':') || isspace(path[length]))
            {
		 path[length]= (char) NULL;
            }
	  else
            {
		 break;
            }
   }

   /* Initially calloc space for 10 directories */

   space_available = 10;

   *dirs = (char **) calloc (10, sizeof (char *));

   prev_ptr = path;

   if (path[0]!= (char) NULL)
   {
	  char_ptr = strchr (path, ':');

	  if (char_ptr == NULL)
	  {
         /* Only one path */

		 (*dirs)[0]= (char *) calloc (strlen (path) + 2, sizeof (char));

		 strcpy ((*dirs)[0], path);
		 strcat ((*dirs)[0], "/");

		 *num_dirs = 1;
	  }
	  else
	  {
         /* More than one path */

		 for (;;)
		 {
			num = char_ptr - prev_ptr;

			(*dirs)[*num_dirs]= (char *) calloc (num + 2, sizeof (char));

			strncpy ((*dirs)[*num_dirs], prev_ptr, num);
			strcat ((*dirs)[*num_dirs], "/");

			prev_ptr = ++char_ptr;

            /* Skip over double :'s */

			for (;;)
			{
			   if (*prev_ptr != ':')
			     {
				  break;
			     }

			   prev_ptr++;
			   char_ptr++;
			}

			(*num_dirs) ++;

			if (*num_dirs == (space_available - 1))
			{
			   space_available += 10;

			   *dirs = (char **) realloc (*dirs, sizeof (char *) * space_available);
			}

			char_ptr = strchr (char_ptr, ':');

			if (char_ptr == NULL)
			{
			   num = strlen (prev_ptr);

			   (*dirs)[*num_dirs]= (char *) calloc (num + 2, sizeof (char));

               /* Copy last directory */

			   strncpy ((*dirs)[*num_dirs], prev_ptr, num);
			   strcat ((*dirs)[*num_dirs], "/");

			   (*num_dirs) ++;

			   break;
			}
		 }
	  }
   }
}

int FI_set_quiet_mode_on (void)
{
   FI_display_mode = FALSE;
   return (FI_SUCCESS);
}

int FI_set_quiet_mode_off (void)
{
   FI_display_mode = TRUE;
   return (FI_SUCCESS);
}

int FI_get_quiet_mode (int *quiet_mode)
{
   *quiet_mode = ! FI_display_mode;
   return (FI_SUCCESS);
}

int FI_set_record_notification_routine (int (*routine) ())
{
   _FI_record_notification_routine = routine;
   return (FI_SUCCESS);
}

int FI_get_record_notification_routine (int (**routine) ())
{
   *routine = _FI_record_notification_routine;
   return (FI_SUCCESS);
}

int FI_set_form_path (char *form_path)
{
   int xx;

   if (_FI_num_form_dirs)
   {
      /* Free directories */

	  for (xx = 0; xx < _FI_num_form_dirs; xx++)
            {
		 _FI_s_free (_FI_form_path[xx]);
            }

	  _FI_s_free ( (char *) _FI_form_path);
   }

   _FI_parse_unix_path (form_path, &_FI_form_path, &_FI_num_form_dirs);

   return (FI_SUCCESS);
}


int _FI_is_in_list (char **list,
                    int    num_list,
                    char  *string)
{
   int ii;
   int nchar = 0;

/* dmb:05/21/91:Sun X font paths don't usually have a trailing '/'. */
/*              Clipper X font paths always do. */

   nchar = strlen (string);
   if (*(string + nchar - 1) == '/')
   {
      nchar -= 1;
   }

   for (ii = 0; ii < num_list; ii++)
   {
     if (! strncmp (list[ii], string, nchar))
     {
       return (1);
     }
   }
   return (0);
}

char * FI_get_ingr_root(char * ingr_root)
{
  /* dmb:04/09/93:Adding for CR#249202403: Remove hardcoded paths. */
  char *ingr_home = NULL;

  ingr_home = getenv("INGRHOME");

/*  if ( strcmp(ingr_home, "") == 0) sml:11-23-93 comment out*/
  if ( ingr_home == NULL || (ingr_home != NULL && strcmp(ingr_home, "") == 0))
  /* sml:11-23-93 uncomment above condition */
  {
    struct utsname name;
    int sts;


	/*****************************************************/
	/* sml:10-08-93 use uname to find system info  NO TR */
	/*****************************************************/

    sts = uname(&name);

    /* if it's Solaris */
    if ( (strcmp(name.sysname, "SunOS") == 0) && 
         (name.release[0] == '5'))
    {
      strcpy(ingr_root,"/opt/ingr");
    }
    /* else if it's IRIX 5.x */
    else if ( (strcmp(name.sysname, "IRIX") == 0) && 
         (name.release[0] == '5'))
    {
      strcpy(ingr_root,"/var/opt/ingr");
    }
    /* if it's anything else */         /* sml:11-23-93 added else */
    else
    {
      strcpy(ingr_root,"/usr/ip32");
    }
    

/***************
#if defined(FI_USE_INGRHOME)
    strcpy(ingr_root,"/opt/ingr");
#else
    strcpy(ingr_root,"/usr");
#endif
***************/
/*     fprintf(stdout,"INGRHOME is NOT set\n"); */
/*     fprintf(stdout,"INGRROOT defaulted to %s\n", ingr_root); */
  }
  else
  {
    char *tmp_ch_p = NULL;

    /* dmb:04/25/93:Don't use strtok. It has nasty side effects!!! */
    /* strcpy(ingr_root,strtok(ingr_home,":")); */

    tmp_ch_p = strchr(ingr_home,':');
    if ( tmp_ch_p == NULL )
    {
      /* One directory - no ':'s */

      strcpy(ingr_root,ingr_home);
    }
    else
    {
      /* Multiple directories - at least one ':'. Take the first only */

      int leng = 0;

      leng = tmp_ch_p - ingr_home;
      strncpy(ingr_root,ingr_home,leng);
      /* dmb:04/25/93:...just in case ingr_root starts with junk in it. */
      *(ingr_root + leng) = (char) NULL;
    }

/*     fprintf(stdout,"INGRHOME is set to %s\n", ingr_home); */
/*     fprintf(stdout,"INGRROOT is set to %s\n", ingr_root); */
  }
  return(ingr_root);
}


int _FI_set_generic_path (char   *path,
                          char ***path_list,
                          int    *num_paths)
{
   int	xx;


   /* Now add forms symbol location onto their defined path */

/* This will automatically add ingr_root to the path */

   strcpy (FI_data, path);
   strcat (FI_data, ":");

/*   strcat (FI_data, ":/usr/lib/xformsrt"); dmb:04/09/93:orig */
/* dmb:04/09/93:Adding for CR#249202403: Remove hardcoded paths. */
   {
     char ingr_root[256] = { (char ) NULL};

     strcat (FI_data, FI_get_ingr_root(ingr_root));
/* fprintf(stderr,"_FI_set_generic_path adding %s\n",ingr_root); */
   }

   strcat (FI_data, "/lib/xformsrt");

/*dmb:04/09/93:This won't usually be there, but it should't hurt, either */
   strcat (FI_data, ":/usr/lib/xformsrt");

/* dmb:04/09/93:end addition */

   if (*num_paths)
   {
      /* Free directories */

	  for (xx = 0; xx < *num_paths; xx++)
            {
		 _FI_s_free ((*path_list)[xx]);
            }

	  _FI_s_free ( (char *) *path_list);
   }

   _FI_parse_unix_path (FI_data, path_list, num_paths);

   return (FI_SUCCESS);

/* dmb:05/23/91:Users must install fonts in fonts/misc for now. */
/*   return (FI_SUCCESS); */

/* #define USING_THIS_PART 1 */
#ifdef USING_THIS_PART
 /*********************************************************************/
 /*** X11-5/3/90-XSetFontPath()will not take effect unless the file ***/
 /*** 'fonts.dir' resides in that directory. This file specifies    ***/
 /*** the aliases to the .snf files in that directory.              ***/
 /*********************************************************************/

#ifdef USING_THIS_PART_TOO
   for(ii = 0; ii < *num_paths; ii++)
   {
     sprintf(FI_data, "%sfonts.dir",(*path_list)[ii]);
   
     if(access(FI_data, 0)!= 0)
     {
       fprintf(stderr , "FORMS--Warning, %s does not exist\n", FI_data);
     }
   }
#endif   

   /*** X11-4/12/90 Get the current font path and add this ***/
   /*** to the FI paths.					***/
   /*** Tell the X server where to find the fonts 		***/
   /*** ( Using snf fonts to store the symbols ).		***/

   XGrabServer(_FI_display); /** For timing **/

   X_paths = XGetFontPath(_FI_display, &num_X_paths);
   xx = num_X_paths;

	/** X11-5/4/90-Reduce the number of directories	***/
	/*** if they're already in the list		***/

   for(ii = 0; ii < num_X_paths; ii++)
   {
     if(_FI_is_in_list(*path_list, *num_paths, X_paths[ii]))
     {
      xx--;
     }
   }

   if(xx)
   {
     *path_list =(char **)realloc(*path_list, sizeof(char *)*(*num_paths + xx));

     /** X11-4/23/90-Append Directories already found **/
     for(ii = 0 , jj = 0; ii < num_X_paths; ii++)
     {
       if(! _FI_is_in_list(*path_list, *num_paths, X_paths[ii]))
       {
          (*path_list)[jj++ + *num_paths]=(char *)strdup(X_paths[ii]);
       }
     }
     *num_paths += xx;
   }

   if(XSetFontPath(_FI_display, *path_list, *num_paths)== BadValue)
   {
     XSetFontPath(_FI_display, X_paths, num_X_paths);
     status = FI_ILLEGAL_VALUES;
   }

   XUngrabServer(_FI_display);

   if(X_paths)
   {
     XFreeFontPath(X_paths);
   }
   return(status);
#endif
}


int FI_set_symbol_path (char *symbol_path)
{
   int status = FI_SUCCESS;

   char enhanced_symbol_path[1024];
   char ingr_root[256];

  /************************************************/
  /* sml:08-16-93                                 */
  /* Add $INGRHOME capability                     */
  /* set up enhanced path to always have default  */
  /* path to fall back on                         */
  /************************************************/
  FI_get_ingr_root(ingr_root);
  strcpy(enhanced_symbol_path, symbol_path);
  strcat(enhanced_symbol_path,":");
  strcat(enhanced_symbol_path, ingr_root);
  strcat(enhanced_symbol_path, "/lib/xformsrt:/usr/lib/xformsrt");


   /**************************************************/
   /* sml:01-10-94:TR 249304932 Fix Purify errors    */
   /*  Free this memory before callocing more in     */
   /*  _FI_parse_unix_path                           */
   /**************************************************/

   if (_FI_symbol_path_index)
   {
	  int xx;

      /* Free directories */

	  for (xx = 0; xx < _FI_symbol_path_index; xx++)
            {
		 _FI_s_free ((_FI_symbol_path)[xx]);
            }

	  _FI_s_free ( (char *) _FI_symbol_path);
   }

  _FI_symbol_path_index = 0;

  _FI_parse_unix_path ( enhanced_symbol_path, /*symbol_path,*/
			& _FI_symbol_path,
			& _FI_symbol_path_index );
/*
   status = _FI_set_generic_path (path, &_FI_symbol_path, &_FI_num_sym_dirs);
*/
  return (status);
}


/* don't trust _FI_is_in_list, as it doesn't handle multiple trailing slashes,
   paths that are substrings of other paths, etc */
static int _FI_path_in_pathlist
(
		char		*pcTestPath,
		char		*pcPathList
)
{
		char		*pcCurPath;
		int		iFoundPath = 0,
				iTestPathLen;

  /* ensure that both strings passed in are good */
  assert(pcTestPath);
  assert(pcPathList);
  /* set up char pointer to step through strings with */
  pcCurPath = pcPathList;
  iTestPathLen = strlen(pcTestPath);
  /* ignore trailing slashes on input path */
  while ( pcTestPath[iTestPathLen - 1] == '/') --iTestPathLen;
  while (pcCurPath && !iFoundPath)
  {
    if (!strncmp(pcTestPath, pcCurPath, iTestPathLen))
    {
      pcCurPath += iTestPathLen;
      /* ignore trailing slashes on path in list */
      while (*pcCurPath == '/') ++pcCurPath;
      /* match only if nothing but slashes on path in list after match */
/*      iFoundPath = (!*pcCurPath || *pcCurPath == ":"); */
      iFoundPath = (!*pcCurPath || *pcCurPath == ':');
    }
    if (!iFoundPath)	/* step to next path */
    {
      pcCurPath = strchr(pcCurPath, ':');
/*      if (pcCurPath > 0) ++pcCurPath; */
      if (pcCurPath > (char *)0) ++pcCurPath;
    }
  }
  return(iFoundPath);
} /* _FI_path_in_pathlist */



int FI_append_form_path (char * form_path)
{
  int	status = FI_SUCCESS;
  char t_str[3000];

  assert(form_path);
  FI_get_form_path (t_str);
  if ( ! _FI_path_in_pathlist(form_path, t_str) )
  {
    /* if the form_path list is too large, it will overrun t_str */
    assert(strlen(t_str) + strlen(form_path) < sizeof(t_str));
    strcat (t_str, ":");
    strcat (t_str, form_path);
    _FI_parse_unix_path ( t_str, & _FI_form_path, & _FI_num_form_dirs );
  }
  return ( status );
}


int FI_append_symbol_path (char *symbol_path)
{
  int	status = FI_SUCCESS;
  char t_str[3000];

  assert(symbol_path);
  FI_get_symbol_path (t_str);
  if ( ! _FI_path_in_pathlist(symbol_path, t_str) )
  {
    /* if the symbol_path list is too large, it will overrun t_str */
    assert(strlen(t_str) + strlen(symbol_path) < sizeof(t_str));
    strcat (t_str, ":");
    strcat (t_str, symbol_path);

    _FI_parse_unix_path ( t_str,
				& _FI_symbol_path,
				& _FI_symbol_path_index );
  }
  return ( status );
}




int FI_get_form_path (char   form_path[])
{
  _FI_get_path ( form_path, _FI_form_path, _FI_num_form_dirs );

  return ( FI_SUCCESS );
}



int FI_get_form_path_length (int   *form_path_length)
{
  * form_path_length = _FI_get_path_length ( _FI_form_path,
						_FI_num_form_dirs );
  return ( FI_SUCCESS );
}



int FI_get_symbol_path (char  symbol_path[])
{
  _FI_get_path ( symbol_path, _FI_symbol_path, _FI_symbol_path_index );

  return ( FI_SUCCESS );
}



int FI_get_symbol_path_length (int  *symbol_path_length)
{
  * symbol_path_length = _FI_get_path_length ( _FI_symbol_path,
						_FI_symbol_path_index );
  return ( FI_SUCCESS );
}


int FI_set_font_path (char *path)
{
   int status = FI_SUCCESS;

   char enhanced_font_path[1024];
   char ingr_root[256];

  /************************************************/
  /* sml:08-16-93                                 */
  /* Add $INGRHOME capability                     */
  /* set up enhanced path to always have default  */
  /* path to fall back on                         */
  /************************************************/
  FI_get_ingr_root(ingr_root);
  strcpy(enhanced_font_path, path);
  strcat(enhanced_font_path,":");
  strcat(enhanced_font_path, ingr_root);
  strcat(enhanced_font_path, "/resrc/bsfont:/usr/ip32/resrc/bsfont");

   status = _FI_set_generic_path (enhanced_font_path, /*path,*/
		 &_FI_font_path, &_FI_num_font_dirs);

   return (status);
}


int FI_set_FSfont_path (char *FSfont_path)
{
   int xx;

   char enhanced_FSfont_path[1024];
   char ingr_root[256];

  /************************************************/
  /* sml:08-16-93                                 */
  /* Add $INGRHOME capability                     */
  /* set up enhanced path to always have default  */
  /* path to fall back on                         */
  /************************************************/
  FI_get_ingr_root(ingr_root);
  strcpy(enhanced_FSfont_path, FSfont_path);
  strcat(enhanced_FSfont_path,":");
  strcat(enhanced_FSfont_path, ingr_root);
  strcat(enhanced_FSfont_path, 
	"/resrc/fontserver/typeface:/usr/ip32/resrc/fontserver/typeface");

   if (_FI_num_FSfont_dirs)
   {
      /* Free directories */

	  for (xx = 0; xx < _FI_num_FSfont_dirs; xx++)
	    {
		 _FI_s_free (_FI_FSfont_path[xx]);
	    }

	  _FI_s_free ( (char *) _FI_FSfont_path);
   }

   _FI_parse_unix_path (enhanced_FSfont_path, /*FSfont_path,*/
		 &_FI_FSfont_path, &_FI_num_FSfont_dirs);

   return (FI_SUCCESS);
}

int FI_set_charmap_path (char *charmap_path)
{
   int xx;

   char enhanced_charmap_path[1024];
   char ingr_root[256];

  /************************************************/
  /* sml:08-16-93                                 */
  /* Add $INGRHOME capability                     */
  /* set up enhanced path to always have default  */
  /* path to fall back on                         */
  /************************************************/
  FI_get_ingr_root(ingr_root);
  strcpy(enhanced_charmap_path, charmap_path);
  strcat(enhanced_charmap_path,":");
  strcat(enhanced_charmap_path, ingr_root);
  strcat(enhanced_charmap_path, 
	"/resrc/fontserver/charmap:/usr/ip32/resrc/fontserver/charmap");

   if (_FI_num_charmap_dirs)
   {
      /* Free directories */

	  for (xx = 0; xx < _FI_num_charmap_dirs; xx++)
	    {
		 _FI_s_free (_FI_charmap_path[xx]);
	    }

	  _FI_s_free ( (char *) _FI_charmap_path);
   }

   _FI_parse_unix_path (enhanced_charmap_path, /*charmap_path,*/
		 &_FI_charmap_path, &_FI_num_charmap_dirs);

   return (FI_SUCCESS);
}


/* sml:09-30-92/07-07-93  ***************************************/
/*	This function aliases Fontserver fonts to closest	*/
/*      X server fonts.                                         */
/****************************************************************/

char * _FI_font_alias ( char *name, int size )
{
  /***************************
  char name[128];
  char * period_loc;

  strcpy(name, fontname);
  period_loc = strrchr(name, '.');
  if (!period_loc)
	return(NULL);

  size = atoi(period_loc + 1);
  period_loc[0] = '\0';
  ***************************/

  if ( strcmp(name, "mono821b") == 0 )
    {
      switch ( size )
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
	  case 9:
	  case 10:
	  case 11:
	  case 12:
	  case 13:
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("7x13bold");
	    /* return ("-misc-fixed-bold-r-normal--13-120-75-75-c-70-iso8859-1");*/
	    /*break;*/ 

	  case 18:
	  case 19:
	  case 20:
	  case 21:
	  case 22:
	  case 23:
	    return ("9x15bold");
	    /* return ("-misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-1");*/
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	    return ("8x16");
	    /* return ("-sony-fixed-medium-r-normal--16-120-100-100-c-80-jisx0201.1976-0"); */
	    /*break;*/  

	  default:
	    return ("12x24");
	    /* return ("-sony-fixed-medium-r-normal--24-170-100-100-c-120-jisx0201.1976-0");*/
	    /*break;*/  

	} /* end switch on size */
    } /* end if mono821b */

  else if ( strcmp(name, "mono821") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
	  case 9:
	  case 10:
	  case 11:
	  case 12:
	  case 13:
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("7x13");
	    /* return ("-misc-fixed-medium-r-normal--13-100-100-100-c-80-iso8859-1");*/
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	    return ("9x15");
	    /* return ("-misc-fixed-medium-r-normal--14-110-100-100-c-70-iso8859-1");*/
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	    return ("8x16");
	    /* return ("-sony-fixed-medium-r-normal--16-120-100-100-c-80-jisx0201.1976-0");*/
	    /*break;*/  

	  default:
	    return ("12x24");
	    /* return ("-sony-fixed-medium-r-normal--24-170-100-100-c-120-jisx0201.1976-0");*/
	    /*break;*/  

	} /* end switch size */

    } /* end else if mono821 */

  else if ( strcmp(name, "dutch801") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
	  case 9:
		return("-adobe-times-medium-i-normal--8-80-75-75-p-42-iso8859-1");

	  case 10:
		return("-adobe-times-medium-r-normal--10-100-75-75-p-54-iso8859-1");

	  case 11:
		return("-adobe-times-medium-r-normal--11-80-100-100-p-54-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-times-medium-r-normal--12-120-75-75-p-64-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-times-medium-r-normal--14-140-75-75-p-74-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	    return ("-adobe-times-medium-r-normal--18-180-75-75-p-94-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-times-medium-r-normal--20-140-100-100-p-96-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-times-medium-r-normal--25-180-100-100-p-125-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-times-medium-r-normal--34-240-100-100-p-170-iso8859-1");


	} /* end switch size */

    } /* end else if dutch801 */

  else if ( strcmp(name, "dutch801i") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
	  case 9:
	  case 10:
		return("-adobe-times-medium-i-normal--10-100-75-75-p-52-iso8859-1");

	  case 11:
		return("-adobe-times-medium-i-normal--11-80-100-100-p-52-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-times-medium-i-normal--12-120-75-75-p-63-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-times-medium-i-normal--14-140-75-75-p-73-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-times-medium-i-normal--18-180-75-75-p-94-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-times-medium-i-normal--20-140-100-100-p-94-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-times-medium-i-normal--25-180-100-100-p-125-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-times-medium-i-normal--34-240-100-100-p-168-iso8859-1");


	} /* end switch size */

  } /* end else if dutch801i */

  else if ( strcmp(name, "dutch801b") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
		return("-adobe-times-bold-r-normal--8-80-75-75-p-47-iso8859-1");

	  case 9:
	  case 10:
		return("-adobe-times-bold-r-normal--10-100-75-75-p-57-iso8859-1");

	  case 11:
		return("-adobe-times-bold-r-normal--11-80-100-100-p-57-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-times-bold-r-normal--12-120-75-75-p-67-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-times-bold-r-normal--14-140-75-75-p-77-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-times-bold-r-normal--18-180-75-75-p-99-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-times-bold-r-normal--20-140-100-100-p-100-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-times-bold-r-normal--24-240-75-75-p-132-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-times-bold-r-normal--34-240-100-100-p-177-iso8859-1");


	} /* end switch size */

  } /* end else if dutch801b */

  else if ( strcmp(name, "dutch801bi") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
		return("-adobe-times-bold-i-normal--8-80-75-75-p-47-iso8859-1");

	  case 9:
	  case 10:
		return("-adobe-times-bold-i-normal--10-100-75-75-p-57-iso8859-1");

	  case 11:
		return("-adobe-times-bold-i-normal--11-80-100-100-p-57-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-times-bold-i-normal--12-120-75-75-p-68-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-times-bold-i-normal--14-140-75-75-p-77-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-times-bold-i-normal--18-180-75-75-p-98-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-times-bold-i-normal--20-140-100-100-p-98-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-times-bold-i-normal--24-240-75-75-p-128-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-times-bold-i-normal--34-240-100-100-p-170-iso8859-1");


	} /* end switch size */

  } /* end else if dutch801bi */

  else if ( strcmp(name, "swiss742") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
		return("-adobe-helvetica-medium-r-normal--8-80-75-75-p-46-iso8859-1");

	  case 9:
	  case 10:
		return("-adobe-helvetica-medium-r-normal--10-100-75-75-p-56-iso8859-1");

	  case 11:
		return("-adobe-helvetica-medium-r-normal--11-80-100-100-p-56-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-helvetica-medium-r-normal--14-140-75-75-p-77-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-helvetica-medium-r-normal--20-140-100-100-p-100-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-helvetica-medium-r-normal--24-240-75-75-p-130-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-helvetica-medium-r-normal--34-240-100-100-p-176-iso8859-1");


	} /* end switch size */

  } /* end else if swiss742 */

  else if ( strcmp(name, "swiss742i") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
		return("-adobe-helvetica-medium-o-normal--8-80-75-75-p-47-iso8859-1");

	  case 9:
	  case 10:
		return("-adobe-helvetica-medium-o-normal--10-100-75-75-p-57-iso8859-1");

	  case 11:
		return("-adobe-helvetica-medium-o-normal--11-80-100-100-p-57-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-helvetica-medium-o-normal--12-120-75-75-p-67-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-helvetica-medium-o-normal--14-140-75-75-p-78-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-helvetica-medium-o-normal--18-180-75-75-p-98-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-helvetica-medium-o-normal--20-140-100-100-p-98-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-helvetica-medium-o-normal--24-240-75-75-p-130-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-helvetica-medium-o-normal--34-240-100-100-p-176-iso8859-1");


	} /* end switch size */

  } /* end else if swiss742i */

  else if ( strcmp(name, "swiss742b") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
		return("-adobe-helvetica-bold-r-normal--8-80-75-75-p-50-iso8859-1");

	  case 9:
	  case 10:
		return("-adobe-helvetica-bold-r-normal--10-100-75-75-p-60-iso8859-1");

	  case 11:
		return("-adobe-helvetica-bold-r-normal--11-80-100-100-p-60-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-helvetica-bold-r-normal--20-140-100-100-p-105-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-helvetica-bold-r-normal--24-240-75-75-p-138-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-helvetica-bold-r-normal--34-240-100-100-p-182-iso8859-1");


	} /* end switch size */

  } /* end else if swiss742b */

  else if ( strcmp(name, "swiss742bi") == 0 )
    {
      switch(size)
	{
	  case 0:
	  case 1:
	  case 2:
	  case 3:
	  case 4:
	  case 5:
	  case 6:
	  case 7:
	  case 8:
		return("-adobe-helvetica-bold-o-normal--8-80-75-75-p-50-iso8859-1");

	  case 9:
	  case 10:
		return("-adobe-helvetica-bold-o-normal--10-100-75-75-p-60-iso8859-1");

	  case 11:
		return("-adobe-helvetica-bold-o-normal--11-80-100-100-p-60-iso8859-1");

	  case 12:
	  case 13:
	    return("-adobe-helvetica-bold-o-normal--12-120-75-75-p-69-iso8859-1");
	    /*break;*/  
	
	  case 14:
	  case 15:
	  case 16:
	  case 17:
	    return ("-adobe-helvetica-bold-o-normal--14-140-75-75-p-82-iso8859-1");
	    /*break;*/  

	  case 18:
	  case 19:
	  case 20:
	  case 21:	
	     return ("-adobe-helvetica-bold-o-normal--18-180-75-75-p-104-iso8859-1");
	    /*break;*/  

	  case 22:
	  case 23:
	    return ("-adobe-helvetica-bold-o-normal--20-140-100-100-p-103-iso8859-1");
	    /*break;*/  

	  case 24:
	  case 25:
	  case 26:
	  case 27:
	  case 28:
	  case 29:
	  case 30:
	  case 31:
	  case 32:
	  case 33:
	  case 34:
	  case 35:
	     return ("-adobe-helvetica-bold-o-normal--24-240-75-75-p-138-iso8859-1");
	    /*break;*/  

	  default:
	    return ("-adobe-helvetica-bold-o-normal--34-240-100-100-p-182-iso8859-1");


	} /* end switch size */

  } /* end else if swiss742bi */

  else
    {
      return("7x13");
    }
}

	/**********************************************************/
	/*** Choose the font whose bodysize is the closest	***/
	/*** to the one given. If there is a tie, then the	***/
	/*** smaller of the two is chosen. The name of the	***/
	/*** closest font is returned in FI_data		***/
	/**********************************************************/

int _FI_find_closest_font ( char *name, int size )
{
  int    sts = -1;
  int    ii, num_fonts;
  int    diff = 65535;
  int    num;
  char **Xfont_list, *ptr;

  if ( ! size )	/* X fonts not implemented */
    {
      return ( sts );
    }

  /* sml:09-30-92/07-07-93  ***********************************/
  /*   Check to see if this font has been mapped to a         */
  /*   different X server font                                */
  /************************************************************/

  Xfont_list = XListFonts ( _FI_display,
				_FI_font_alias ( name, size ), 2, 
				&num_fonts );

  if ( Xfont_list )
    {
      strcpy ( FI_data, Xfont_list[0] );
      XFreeFontNames ( Xfont_list );
      return ( FI_SUCCESS );
    }

  /****************************************************************/
  /* sml:09-30-92/07-07-93	go on to closest-size algorithm   */
  /*                            as before                         */
  /****************************************************************/

  ptr = strchr ( name, '.' );
  if ( ptr++ )
    {
      *ptr = 0;
    }

  strcat ( name, "*" );	/* attach wildcard */

  Xfont_list = XListFonts ( _FI_display, name, 20, &num_fonts );

                               /* sml:09-30-92/07-07-93	 */
  name[strlen(name)-1] = '\0'; /* take * off end of name */

  for ( ii = 0; ii < num_fonts; ii++ )
   {
     ptr = strchr ( Xfont_list[ii], '.' );
     if ( ptr )
       {
	 num = atoi (ptr + 1) - size;
	 if (	(ABS(num) < ABS(diff))		 		||
		( (ABS(num) == ABS(diff)) && (num < diff) )	 )
	   {
	    diff = num;
	    strcpy ( FI_data, Xfont_list[ii] );
	    sts = 0;
	   }
      }
   }

  if ( Xfont_list )
    {
      XFreeFontNames ( Xfont_list );
    }
  else
    {
      sts = -1;
    }

  /**************************************************************
  if ( sts != 0 )
    {
      fprintf ( stderr,
	"_FI_find_closest_font ( '%s', %d ), sts = %d\n",
	name, size, sts );
    }
  ***************************************************************/

  return ( sts );
}

int FI_load_font ( char * fontname,
                   int    bodysize,
                   int  * actual_bodysize,
                   Font * font_id,
                   int  * font_type )
{
  int      num_fonts;
  char  ** Xfont_list;
  char     t_str[2000];
  int 	   status;
  FontSpec fontspec;
  char	   cm[200]   /* = {NULL} */;
  int	   font_found = 0;
  int	   typeface_dir_index, charmap_dir_index = 0;
  int	   xx, yy;
  int      converted_bodysize;
  /*char	   cm_path[256]; not used */

	/************************************/
	/* Convert m2 number to Raster size */
	/************************************/

  if ( _FI_font_available (fontname, bodysize, font_id, font_type) )
    {
      return ( FI_SUCCESS );
    }

  if ( bodysize < 0 )
   {
     *font_id = (Font) -1;
     *actual_bodysize = -1;

	/****************************************/
	/* sml:04-16-93	Display message here	*/
	/****************************************/

     /*************************************************************
     fprintf(stderr, "Can't load font %s with size %d\n", fontname,
		bodysize);
     *************************************************************/

     return ( FI_LOAD_FONT_ERROR );
   }

	/* sml:09-30-92/07-07-93 *************************/
	/*	Try this without using Fontserver fonts  */
	/*************************************************/

  if ( FI_font_strategy == FI_FS_FONTS_FIRST )
  {
     /***************************************************************/
     /* First check to see if the fontname exists as a *.tf in the  */
     /* /usr/ip32/resrc/fontserver/typeface directory.  If is does  */
     /* then look to see if a *.cm file exists in the               */
     /* /usr/ip32/resrc/fontserver/charmap directory.  If the       */
     /* *.cm file exists, it will be considered a 16 bit font.      */
     /* If no *.cm file exists but the *.tf is found, use dec.cm    */
     /* as the charmap and consider it an 8 bit Fontserver font.    */
     /***************************************************************/

    for ( xx = 0; xx < _FI_num_FSfont_dirs; xx++ )
      {
        strcpy ( t_str, _FI_FSfont_path[xx] );
        strcat ( t_str, "/" );
        strcat ( t_str, fontname );
        strcat ( t_str, ".tf" );

        if ( access (t_str, 0) == 0 )   /* Found Fontserver typeface */
	  {
	    typeface_dir_index = xx;

            *font_type = FI_FS_8_BIT_FONT_TYPE ;

            for ( yy = 0; yy < _FI_num_charmap_dirs; yy++ )
              {
                strcpy ( t_str, _FI_charmap_path[yy] );
                strcat ( t_str, "/" );
                strcat ( t_str, fontname );
                strcat ( t_str, ".cm" );

                if ( access (t_str, 0) == 0 ) /* 16 bit charmap found */
                  {
                    *font_type = FI_FS_7_OR_16_BIT_FONT_TYPE ;
                    charmap_dir_index = yy;
                    break;
                  }
	      }

            strcpy ( cm, "ascii" );

            strcpy ( t_str, _FI_FSfont_path[typeface_dir_index] );
            strcat ( t_str, "/" );
            strcat ( t_str, fontname );

            fontspec.typeface  = t_str;
/* sml:01-04-94	don't use path for charMap
            FI_get_ingr_root(cm_path);
            strcat(cm_path, "/resrc/fontserver/charmap/dec");
            fontspec.charMap = cm_path;
*/
            fontspec.charMap   = "dec"; 
            fontspec.bodySize  = (double) bodysize;
            fontspec.resFactor = 1.0; 
            fontspec.aspect    = 1.0;
            fontspec.rotation  = 0.0;
            fontspec.slant     = 0.0;

		 /* smL:08-17-92 add shared flag */
		 /* sml:04-16-93 no shared flag for new FS */
		 /* sml:01-04-94 no DEMAND flag for new FS */
            fontspec.flags = /*FS_DEMAND |*/
							 FS_NO_KERN /*| FS_SHARED */;

            if ( *font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )
              {
                /* char *cm_ptr; */

                strcpy ( cm, _FI_charmap_path[charmap_dir_index] );
                strcat ( cm, fontname);
                strcat ( cm, ".cm" );
                fontspec.charMap = fontname;

  		    /* smL:08-17-92 no shared flag for 16-bit fonts */
		    /* sml:04-19-93	add FS_NO_KERN flag */
         	fontspec.flags = FS_DEMAND | FS_NO_KERN;

                /***  sml:04-21-93 **********************************/
                /***	not necessary anymore, according to Bailey Brown

 	        status = FSReadCharMapFile(cm, &fontspec.charMap);
	 
	        if ( status )
	          {
	            fprintf(stderr,"Error reading %s: %d\n",cm,status);
	          }
                ******************************************************/
             }

	   /******** sml:06-09-93 ************************************/
           /*******	might need this for 16-bit font test 
	   cm_ptr = "china.cm";
	   fontspec.charMap = cm_ptr;
           ***********************************************************/

           /***************  sml:01-06-93 leave to test new fs later
	   printf("\n");
	   printf("fontspec.typeface:  %s\n", fontspec.typeface);
	   printf("fontspec.bodySize:  %lf\n", fontspec.bodySize);
	   printf("fontspec.resFactor:  %lf\n", fontspec.resFactor);
	   printf("fontspec.aspect:  %lf\n", fontspec.aspect);
	   printf("fontspec.rotation:  %lf\n", fontspec.rotation);
	   printf("fontspec.slant:  %lf\n", fontspec.slant);
	   printf("fontspec.charMap:  %s\n", fontspec.charMap);
	   printf("fontspec.flags:  %x\n", fontspec.flags);
	   printf("\n");
	   system("date");
           ****************/

 	   status = FSNewFont ( &fontspec, NULL, font_id );

           /****************  sml:01-06-93 leave to test new fs later
	   system("date");
	   printf("\n");
           *****************/

	   if ( status )
	     {
                fprintf ( stderr, "Error %d getting font '%s': %d\n",
			status, fontname );
               *font_id = None;
	     }
           else
	     {
               font_found = 1;
	     }

	    break;  /* out of for loop */

	  } /* Found Fontserver typeface */

     } /* for loop */
  } /*  if ( FI_font_strategy == FI_FS_FONTS_FIRST ) */

  else /* font strategy is X fonts first */
  {
    /* Find X Server font by this name */

    /** X11-4/23/90-Only need the name **/

    if ( bodysize )
      {
        converted_bodysize = (int) (((float) bodysize * 1.2 ) + 0.5 );
        sprintf ( FI_data, "%s.%d", fontname, converted_bodysize );
      }
    else
      {
        converted_bodysize = 0;
        sprintf ( FI_data, "%s", fontname );
      }

	/*** X11-6/19/90-Check the server to make sure the font	***/
	/***  is there or else XLoadFont() will die		***/

    Xfont_list = XListFonts ( _FI_display, FI_data, 2, &num_fonts );

    if ( Xfont_list )
      {
        XFreeFontNames ( Xfont_list );
      }

    if ( num_fonts == 1 )
      {
         /* X11-4/17/90-Load the font named font file */
	 /* FI_data is set in _FI_find_closest_font */

       *font_id = XLoadFont (_FI_display, FI_data);
       *font_type = FI_RASTER_8_BIT_FONT_TYPE ;  /* 8 bit, .snf font */
      }
    else
      {
        if ( _FI_find_closest_font (fontname, bodysize) == FI_SUCCESS )
	  {
		/* X11-4/17/90-Load the font named font file */
		/* FI_data is set in _FI_find_closest_font */

	    *font_id = XLoadFont (_FI_display, FI_data);
	    *font_type = FI_RASTER_8_BIT_FONT_TYPE ;  /* 8 bit, .snf font */

		/* return (FI_SUCCESS); */
	  }
	else
	  {
	    /*	sml:09-30-92/07-07-93 ********************************
		Try this after checking X server fonts and/or aliases
	    *********************************************************/

		/***************************************************/
		/*  First check to see if the fontname exists as a */
		/* .tf in the /usr/ip32/resrc/fontserver/typeface  */
		/* directory.  If it does, then look to see if a   */
		/* .cm file exists in the                          */
		/* /usr/ip32/resrc/fontserver/charmap directory.   */
		/*   If the .cm file exists, it will be considered */
		/* a 16 bit font.  If no .cm file exists, but the  */
		/* .tf is found, use dec.cm as the charmap and	   */
		/* consider it an 8 bit Fontserver font.           */
		/***************************************************/

	    for ( xx = 0; xx < _FI_num_FSfont_dirs; xx++ )
  	      {
	        strcpy (t_str, _FI_FSfont_path[xx]);
	        strcat (t_str, "/");
	        strcat (t_str, fontname);
	        strcat (t_str, ".tf");

	        if ( access (t_str, 0) == 0 )   /* Found Fontserver typeface */
 	 	  {
 		    typeface_dir_index = xx;
		    xx = 1000;

		    *font_type = 1;

                    for ( yy = 0; yy < _FI_num_charmap_dirs; yy++ )
                      {
                        strcpy ( t_str, _FI_charmap_path[yy] );
                        strcat ( t_str, "/" );
                        strcat ( t_str, fontname );
                        strcat ( t_str, ".cm" );

                        if (access (t_str, 0) == 0)   /* 16 bit charmap found */
                          {
                            *font_type = 2;
                            charmap_dir_index = yy;
                            break;
                          }
                      } /* end for yy <= FI_num_charmap_dir */

                    strcpy ( cm, "ascii" );
   
                   strcpy ( t_str, _FI_FSfont_path[typeface_dir_index]);
                    strcat ( t_str, "/");
                    strcat ( t_str, fontname);

                    fontspec.typeface = t_str;
                    fontspec.charMap = "dec";
                    fontspec.bodySize = (double)bodysize;
                    fontspec.resFactor = 1.0; 
                    fontspec.aspect = 1.0;
                    fontspec.rotation = 0.0;
                    fontspec.slant = 0.0;

  		    /* smL:08-17-92 add shared flag */
		    /* sml:04-16-93	take it back out for new FS */
                    fontspec.flags = FS_DEMAND /*| FS_SHARED*/ ;

                    if ( *font_type == 2 )
                      {
                        strcpy (cm, _FI_charmap_path[charmap_dir_index]);
                        strcat (cm, fontname);
                        strcat (cm, ".cm");

			fontspec.charMap = fontname;
  			/* smL:08-17-92 no shared flag for 16-bit fonts */
         	        fontspec.flags = FS_DEMAND;
		
		        /***  sml:04-21-93 *****************************/
		        /** not necessary anymore, according to Bailey Brown

   	    	        status = FSReadCharMapFile(cm, &fontspec.charMap);
	 
	                if ( status )
    	                  {
	       		    fprintf ( stderr,
				"Error reading %s: %d\n", cm, status);
	    	          }
                        ************************************************/
        	      } /* end if *font_type == 2 */

	   	    status = FSNewFont (&fontspec, NULL, font_id);
	  	    if ( status )
	  	      {
                        fprintf ( stderr,
			  "Error %d getting font '%s'\n",
			  status, fontname );

                        *font_id = None;
			/*   *font_id = (Font) -1;  */	

	    	        *actual_bodysize = -1;

			  /********************************************/
			  /* sml:04-16-93   Display message here      */
			  /********************************************/

		        fprintf ( stderr,
			  "Can't load font %s with size %d\n", fontname,
				bodysize);

	   	        return (FI_LOAD_FONT_ERROR);
	              }
                    else
		      {
                        font_found = 1;
		      }
		  } /* end if can access t_str */
              } /* end for x <= _FI_num_FSfont_dirs */
	  } /* end if _FI_find_closest_font fails for X server fonts */

	/* end of putting FS stuff after X server fonts ***************/

     }  /*end else if num_fonts != 1 */

  } /* end else if font strategy is X font first */

  if ( *font_id != None )
    {
	/* Add the font to the font look up table */

        /* dmb:03/04/91:  ********************************************/
	/* FI declares _FI_fonts[i].fontname as a character array    */

      /* strcpy(_FI_fonts[_FI_next_font].fontname, _FI_s_new(fontname)); */
      _FI_fonts[_FI_next_font].fontname = _FI_s_new (fontname);
      _FI_fonts[_FI_next_font].bodysize = bodysize;
      _FI_fonts[_FI_next_font].font_id = *font_id;
      _FI_fonts[_FI_next_font].font_type = *font_type;
      _FI_next_font++;

	/* Check the font array size */

      if ( _FI_next_font >= _FI_font_array_size )
	  {
	    _FI_font_array_size += 5;
	    _FI_fonts = (struct _FI_font_st *) realloc (_FI_fonts,
		_FI_font_array_size * sizeof (struct _FI_font_st));
	  }
    }
  else
    {
	  /******************************************************/
	  /* sml:04-16-93	Display message here                */
	  /******************************************************/
      fprintf ( stderr, "Can't load font '%s' with size %d\n",
		fontname, bodysize );

      return ( FI_LOAD_FONT_ERROR );
    }

	/***********************************************/
	/* Convert actual_bodysize to M-SQUARED number */
	/***********************************************/

  if ( bodysize )
    {
      *actual_bodysize = bodysize;
    }
  else
    {
      *actual_bodysize = 0.0;
    }

#if 0
  if ( strcmp(fontname, "china") == 0 )
    {
      int sts;
      char text[20];
      char * ch_ptr;
      double w, h;

      ch_ptr = text;
      ch_ptr[0] = 0xb0;
      ch_ptr[1] = 0xa1;
      ch_ptr[2] = 0;

      sts = FSGetTextVect ( *font_id, ch_ptr, 1, 0.0, 0.0, &w, &h );

      sts = FI_calc_text(fid, ch_ptr, 1, &ht, &wd, &ls, ftype);
    }
#endif

  return ( FI_SUCCESS );
}


/** OBSOLETE **/
/* ARGSUSED */
int FI_set_keyboard_buffer (char *buffer, int   size)
{
   /* FI_keyin_buffer = buffer; */

   return ( FI_SUCCESS );
}



int FI_get_form (Window  window, Form   * form)
{
  int window_index;

  *form = 0;

  window_index = _FI_Xwindow_to_index (window);  /* X11-4/12/90 */

  if ((window_index < 0) || (window_index > MAX_WINDOW))
    {
      return (FI_NO_SUCH_FORM);
    }

  if ( FI_sr_area_num )
    {
      *form = (Form) FI_sr_forms[FI_sr_area_num];
    }
  else
    {
      *form = (Form) FI_forms[window_index];
    }

  if ( *form == 0 )
    {
      return ( FI_NO_SUCH_FORM );
    }

    return (FI_SUCCESS);
}


int FI_get_form_by_name (char  *name, Form  * form_ptr)
{
  int ii;
  int count;

  Form last_form_found = NULL;

  *form_ptr = NULL;

  if ((name == NULL) || (name[0]== (char ) NULL))
    {
      return (FI_NO_SUCH_FORM);
    }

   /* See if there is more than one form with same name */

  count = 0;

  for (ii = 0; ii < (int) _FI_form_list->FIgroup.size; ii++)
    {
      struct FIform_obj *form = (struct FIform_obj *)
				_FI_form_list->FIgroup.gadgets[ii];

      if ( form  && (form->name) && (form->name[0]!= (char ) NULL) &&
			(strcmp (form->name, name) == 0))
	{
	  count++;
	  last_form_found = (Form) form;
	}
    }

  if (count == 0)
    {
	  return (FI_NO_SUCH_FORM);
    }

  for (ii = 0; ii < (int) _FI_form_list->FIgroup.size; ii++)
    {
      struct FIform_obj *form = (struct FIform_obj *)
			_FI_form_list->FIgroup.gadgets[ii];

      if ( form  && (form->name) && (form->name[0]!= (char) NULL) &&
				(strcmp (form->name, name) == 0))
	{
		/* If there is another form with same name and   */
		/* the current form is not displayed then get    */
		/* the next one                                  */

	   if ((count > 1)	/* &&(form->win_no == -1)*/)
	     {
		count--;
		continue;
	     }
	   else
	     {
		*form_ptr = (Form) form;
		break;
	     }
	}
    }

	/*** There was not a form that was displayed so		***/
	/*** return the form last referenced in the list	***/

  if ( *form_ptr == 0 )
     {
	   *form_ptr = last_form_found;
     }

  return (FI_SUCCESS);
}


/* Added array of stipple patterns    GMD 3/13/92   */

int _FI_create_pixmaps ( Window  window, int     screen )
{
   int width, height;

   XQueryBestStipple (_FI_display, window, 32, 32, 
			(unsigned int *)&width,
			(unsigned int *) &height);

   if ( width != 32 )
   {
/* fprintf (stderr , "Best stipple width = %d(using 32)\n", width); */
	  width = 32;
   }

   if (height != 32)
   {
/* fprintf (stderr , "Best stipple height = %d(using 32)\n", height); */
	  height = 32;
   }

   _FIpix_gray12_array[screen] =
        XCreateBitmapFromData (_FI_display, window, 
			(char *) _FIgray12, width, height);

   _FIpix_gray50_array[screen] =
        XCreateBitmapFromData (_FI_display, window, 
			(char *) _FIgray50, width, height);

   _FIpix_gray75_array[screen] =
        XCreateBitmapFromData (_FI_display, window, 
			(char *) _FIgray75, width, height);

   _FIpix_required_array[screen] =
        XCreateBitmapFromData (_FI_display, window, 
			(char *) _FI_enable_pttn3, width, height);

  return ( FI_SUCCESS );
}



void FI_select_FS_fonts_first ( )
{
  FI_font_strategy = FI_FS_FONTS_FIRST;
}


void FI_select_X_fonts_first ( )
{
  FI_font_strategy = FI_X_FONTS_FIRST;
}

int FI_enter (Display  *display,
              Colormap  cmap,
              int       cmap_size)
{
   int xx;  /*, x, y; not used */
   int screen_index, cmap_index;
   int dummy, sts;
   int screen_num = DefaultScreen(display);	/* X11-4/17/90 */
   Font dummy_fontID;
   int dummy_font_type;
   char *path_name;
   char temp_path[1000];
  char * ch, *wch;
  char * font_strat_env;

	/***********************************************/
	/* Check to see if the system is setup already */
	/***********************************************/

   if (! _FI_system_set_up)
   {
	  _FI_system_set_up = 1;
   }
   else
     {
	  return (FI_SUCCESS);
     }


   _FI_display = display;

	/************************************/
	/* Create group to store forms into */
	/************************************/

   _FI_form_list = (struct FIgroup_obj *) calloc ( 1,
					sizeof (struct FIgroup_obj));

	/*****************************/
	/* Alloc space for the forms */
	/*****************************/

   _FI_grp_alloc ( _FI_form_list, 28 );


	/**********************************/
	/* Set up the default symbol path */
	/**********************************/

   { /* dmb:04/09/93:Adding for CR#249202403 */

/*   FI_set_symbol_path(".:../sym:/usr/lib/xformsrt");dmb:04/09/93:orig */
/* dmb:04/09/93:Adding for CR#249202403 */

     char tmp_path[256] = { (char ) NULL};
     char ingr_root[256] = { (char) NULL};

     /* Get ingr_root once */
     FI_get_ingr_root(ingr_root);

     strcpy (tmp_path,".:../sym:");
     strcat (tmp_path, ingr_root);
     strcat (tmp_path,"/lib/xformsrt:/usr/lib/xformsrt");

	/**********************************/
	/* Set up the default symbol path */
	/**********************************/

     FI_set_symbol_path(tmp_path);

/* dmb:04/09/93:end addition */

	/********************************/
	/* Set up the default form path */
	/********************************/

   FI_set_form_path (".:../forms");

	/* sml:08-14-92/07-07-93 ************************/
	/*    set up widest ASCII and 16-bit chars      */
	/************************************************/
  ch = getenv ( "WIDEST_CHAR" );
  wch = getenv ( "WIDEST_WCHAR" );
  if( ch == NULL )
    {
       FI_define_widest_char ( WIDEST_CHAR );
    }
  else
    {
       FI_define_widest_char ( ch[0] );
    }

  if ( wch == NULL )
    {
        FI_define_widest_wchar ( (short) WIDEST_WCHAR );
    }
  else
    {
      int	temp_int;
      short	temp_short;

      temp_int = atoi(wch);
      temp_short = (short) temp_int;

      FI_define_widest_wchar ( temp_short );
    }

	/*****************************************************/
	/*** Check FS environment variables for Bill Case  ***/
	/*** GMD 2/4/92 **************************************/


/* dmb:04/09/93:Adding for CR#249202403 */
     *tmp_path= (char) NULL;
     strcat (tmp_path, ingr_root);
     strcat (tmp_path, "/resrc/fontserver/typeface");   
/* dmb:04/09/93:end addition */

  path_name = getenv ("FS_TFPATH");
  if ( path_name == NULL )
   {
/*      FI_set_FSfont_path ("/usr/ip32/resrc/fontserver/typeface"); */
      FI_set_FSfont_path (tmp_path);
   }
  else
   {
/*      strcpy (temp_path, "/usr/ip32/resrc/fontserver/typeface:"); */
      strcpy (temp_path, tmp_path );
      strcat (temp_path, ":");

      strcat (temp_path, path_name);
      FI_set_FSfont_path (temp_path);
 /* dmb:04/13/93:fprintf(stderr,"FI_set_FSfont_path to %s\n",temp_path); */
  }


/* dmb:04/09/93:Adding for CR#249202403 */
     *tmp_path= (char) NULL;
/*     strcpy (tmp_path, FI_get_ingr_root(ingr_root)); */
     strcat (tmp_path, ingr_root);
     strcat (tmp_path, "/resrc/fontserver/charmap");   
/* dmb:04/09/93:end addition */

  path_name = getenv ("FS_CMPATH");
  if (path_name == NULL)
   {
/*      FI_set_charmap_path ("/usr/ip32/resrc/fontserver/charmap"); */
      FI_set_charmap_path (tmp_path);
   }
  else
   {
/*      strcpy (temp_path, "/usr/ip32/resrc/fontserver/charmap:"); */
      strcpy (temp_path, tmp_path );
      strcat (temp_path, ":");

      strcat (temp_path, path_name);
      FI_set_charmap_path (temp_path);
   }

/*
      FI_set_FSfont_path ("/usr/ip32/resrc/fontserver/typeface");
      FI_set_charmap_path ("/usr/ip32/resrc/fontserver/charmap");
*/

   } /* dmb:04/09/93:Adding for CR#249202403 */

   /* Determine what size forms to create relative to the screen size */
   /* X11-4/17/90 */

   FI_current_screen_width  = DisplayWidth ( _FI_display, screen_num );
   FI_current_screen_height = DisplayHeight ( _FI_display, screen_num );


	/********************************/
	/* Initialize the window arrays */
	/********************************/

  for ( xx = 0; xx < MAX_WINDOW; xx++ )
   {
      FI_forms[xx]= FALSE;
      FI_sr_forms[xx]= FALSE;

      _FI_index_to_Xwindow[xx]= None;
   }

	/*****************************/
	/* Set Save Restore defaults */
	/*****************************/

   FI_sr_mode = OFF;
   FI_sr_win_num = -1;
   FI_sr_area_num = 0;

	/***********************************/
	/* Set symbol array initially to 5 */
	/***********************************/

   _FI_symbol_array_size = 5;
   _FI_symbols = (struct _FI_sym_st *) calloc ( _FI_symbol_array_size,
					sizeof (struct _FI_sym_st) );

	/***********************************/
	/* Set font array initially to 5   */
	/***********************************/

  _FI_font_array_size = 5;
  _FI_fonts = (struct _FI_font_st *) calloc ( _FI_font_array_size,
					sizeof (struct _FI_font_st) );

  _FI_next_font = 0;
  _FI_next_symbol = 0;


  /*****************************************/
  /*** Check environment variables to	***/
  /*** determine font search order.	***/
  /********************** SML:07-07-93 ******/

  font_strat_env = getenv ( "FI_FONT_CHOICE" );
  if ( font_strat_env )	/* env variable is set */
  {
    if ( strcmp ( font_strat_env, "X" ) == 0 )
    {
      FI_select_X_fonts_first();
    }
    else /* default to FS fonts */
    {
        FI_select_FS_fonts_first();
    }
  } /* end if font_strat_env */

  else  /* FI_FONT_CHOICE not set */
  {
    
    /*****************************************/
    /*** sml:11-10-94 NO TR                ***/
    /*** Default to using X fonts on SCO   ***/
    /*** and HPUX.                         ***/
    /*****************************************/

    struct utsname name;
    uname(&name);
    if ( (strcmp(name.sysname, "HP-UX") == 0) ||
	 (strcmp(name.machine, "i386") == 0))
    {
      FI_select_X_fonts_first();
    }
    
    /*****************************************/
    /*** Default to using FontServer fonts ***/
    /*****************************************/
    else if (!FI_font_strategy)  /* not set by function call */
    {
	  FI_select_FS_fonts_first();	  
    }
  } /* end else if */

	/**************************/
	/* Load the default fonts */
	/**************************/

  sts = FI_load_font ( "mono821", 15, &dummy, &dummy_fontID,
					&dummy_font_type );
  if ( sts )
    {
      sts = FI_load_font ( "fixed", 0, &dummy, &dummy_fontID,
						&dummy_font_type );
      if ( sts )
        {
	  return ( sts );
        }
    }

  sts = FI_load_font ( "dutch801", 15, &dummy, &dummy_fontID,
					&dummy_font_type );
  if ( sts )
   {
      sts = FI_load_font ( "variable", 0, &dummy, &dummy_fontID,
						&dummy_font_type );
      if ( sts )
        {
	  return (sts);
	}
   }

   /******************************************************************/
   /* If cmap == NULL, then find out if there is a currently active  */
   /* color table and use it.  This call requires that you specify   */
   /* a window, so I am creating a form here so that I will have a   */
   /* window number to specify.      GMD 3/3/92                      */
   /*                                                                */
   /* JAJ:06/28/93 -- I removed the ridiculous window creation/      */
   /* deletion stuff and replaced it with                            */
   /*    RootWindowOfScreen(DefaultScreenOfDisplay(_FI_display))     */
   /******************************************************************/

  if ( cmap == (Colormap) NULL )
    {
      int num;
      Colormap *my_cmap;

      cmap = DefaultColormap ( _FI_display, screen_num );
      cmap_size = DisplayCells ( _FI_display, screen_num );

      my_cmap = XListInstalledColormaps ( _FI_display,
				RootWindow (_FI_display, screen_num ),
				&num );
      if ( my_cmap && (my_cmap[0] != cmap) && (num > 0) )
        {
          cmap = my_cmap[0];
        }

      XFree ( (caddr_t) my_cmap );   /*** JAJ:06/28/93 ***/
   }

   _FI_cmap = cmap;

   FI_colormap_notify ( _FI_cmap, cmap_size );

		/*****************************/
		/* Create array of colormaps */
		/*****************************/

   for ( screen_index = 0;
		screen_index < ScreenCount (_FI_display);
							screen_index++ )
   {
      if ( cmap == DefaultColormap (_FI_display, screen_num) )
      {
         _FI_cmap_array[screen_index] =
			DefaultColormap ( _FI_display, screen_index );
      }
      else
      {
        if ( DisplayCells ( _FI_display, screen_index ) < cmap_size )
	  {
            _FI_cmap_array[screen_index] =
			DefaultColormap ( _FI_display, screen_index );
	  }
        else
          {
            /* XColor colorcell_def;   old 4-second loop way */
	    XColor *colorcell_def;

            colorcell_def = (XColor *) calloc ( cmap_size,
                                               sizeof(XColor) );

#if 0   /**********************************************************/
	/***   sml:07-28-92	don't create new colormap	***/ 
	/***		This creates color probs in EMS		***/
	/**********************************************************/

            _FI_cmap_array[screen_index] = XCreateColormap (_FI_display,
                                   RootWindow (_FI_display,
							screen_index),
                                   DefaultVisual (_FI_display,
							screen_index),
                                   AllocAll);
#endif  /**********************************************************/

	    _FI_cmap_array[screen_index] = _FI_cmap;

#if 0   /**********************************************************/

		/*********************************************/
		/*** This loop takes 4 seconds to complete ***/
		/*** Replacing it with XQueryColors and    ***/
		/***   XStoreColors ( note "s" suffixes )  ***/
		/************************  JAJ:06/28/93  *****/
            for (y = 0; y < cmap_size; y++)
            {
               colorcell_def.pixel = y;
               XQueryColor ( _FI_display, cmap, &colorcell_def);
               XStoreColor ( _FI_display, _FI_cmap_array[screen_index],
						&colorcell_def );
            }                 
#endif   /**********************************************************/

            for ( cmap_index=0 ; cmap_index < cmap_size ; cmap_index++ )
	      {
		colorcell_def[cmap_index].pixel = cmap_index;
              }

            XQueryColors ( _FI_display, cmap, colorcell_def,
						cmap_size );
            XStoreColors ( _FI_display, _FI_cmap_array[screen_index],
					colorcell_def, cmap_size );
	    free ( colorcell_def );
         }
      }
   }

	/*************************************************************/
	/* Create _FI_text_gc for use by XFontserver in drawing text */
	/*************************************************************/

   _FI_text_gc = XCreateGC ( _FI_display,
				RootWindow ( _FI_display, screen_num ),
				None, None );

  return ( FI_SUCCESS );
}


/*********************************************************************/
/* sml:12-22-93:NO TR Do this to avoid multiply defined symbol error */
/*  in archive and unfound symbol error in shared library            */
/*  This is real solution to TR 249305428.                           */
/*********************************************************************/

void _FI_call_FSReadCharMapFile()
{
  FontSpec fontspec;
  char           cm[200]   /* = {NULL} */;
  int status;
 
  fontspec.typeface = "mono821b";
  fontspec.charMap = "dec";
  fontspec.bodySize = 15.0;
  fontspec.resFactor = 1.0; 
  fontspec.aspect = 1.0;
  fontspec.rotation = 0.0;
  fontspec.slant = 0.0;
  fontspec.charMap = "ascii";
  fontspec.flags = FS_DEMAND; 

  status = FSReadCharMapFile(cm, &fontspec.charMap);
}
