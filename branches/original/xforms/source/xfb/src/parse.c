/***********************************

		 parse.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/


#include <sys/types.h>
#include <stdio.h>

#include <dirent.h>
#include "NFBpriv.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


extern struct dpb_struct dpb;
extern char language[80];
extern char execute_dir[200];

extern int SYM_dir_count;
extern char SYM_search_directory[200][256];

/**************************************/
/* */
/* Global variables used in parsing */
/* */
/**************************************/

FILE *startup_file;
char token[255];
int token_type;
char line[255];
int line_ptr;
int end_of_file;
int old_line_ptr;


static void Get_next_line();


/**************************************/

static void Get_next_line(void)
{
  char *get_status;

  line_ptr = 0;
  old_line_ptr = 0;

  get_status = fgets (line, 255, startup_file);

  if (get_status == NULL)
    end_of_file = 1;
}

/*-------------------------------------------------------------------------*/

int Get_token (void)
{
  int token_found;
  int x;
  char t_str[200];
  int hex_data;

  token_found = -1;

  for (x = line_ptr; x < strlen(line); x++)
    if ((line[x] == ' ') ||
        (line[x] == '\n') || /* line feed */
    (line[x] == '\t') || /* TAB */
    (line[x] == '\r')) /* Carriage Return */
    {
      /* do Nothing */
    }
    else
    {
      token_found = x;
      x = strlen(line);
    }

  while ((token_found == -1) &&
      (!(end_of_file)))
  {
    Get_next_line();

    for (x = 0; x < strlen(line); x++)
      if ((line[x] == ' ') ||
          (line[x] == '\n') || /* line feed */
      (line[x] == '\t') || /* TAB */
      (line[x] == '\r')) /* Carriage Return */
      {
        /* Do nothing */
      }
      else
      {
        token_found = x;
        x = strlen(line);
      }
  }

  if (token_found == -1)
    return (2); /* At the end of file */
  else
  {
    old_line_ptr = token_found;
    line_ptr = token_found;
    token[0] = '\0';

    if (line[line_ptr] == ':')
    {
      token_type = KEYWORD_TOKEN;

      for (x = line_ptr + 1; x < strlen(line); x++)
        if (line[x] == ':')
        {
          strncpy (token, &line[line_ptr], (x - line_ptr) + 1);
          token [(x - line_ptr) + 1] = '\0';
          line_ptr = x + 1;
          x = strlen(line);
        }

      if (token[0] == '\0')
      {
        strcpy (token, &line[line_ptr]);
        line_ptr = strlen(line);
      }

      return (1); /* token found */
    }

    if (line[line_ptr] == '"')
    {
      token_type = STRING_TOKEN;

      for (x = line_ptr + 1; x < strlen(line); x++)
        if (line[x] == '"')
        {
          strncpy (token, &line[line_ptr], (x - line_ptr) + 1);
          token [(x - line_ptr) + 1] = '\0';
          line_ptr = x + 1;
          x = strlen(line);
        }
      if (token[0] == '\0')
      {
        strcpy (token, &line[line_ptr]);
        line_ptr = strlen(line);
      }
      return (1); /* token found */
    }

    if ((line[line_ptr] == '0') &&
        ((line[line_ptr + 1] == 'x') ||
        (line[line_ptr + 1] == 'X')))
    {
      for (x = line_ptr + 2; x < strlen(line); x++)
        if ((!(isdigit(line[x]))) &&
            (!((line[x] >= 65) &&
            (line[x] <= 70))) &&
            (!((line[x] >= 97) &&
            (line[x] <= 102))))
        {
          strncpy (t_str, &line[line_ptr], (x - line_ptr));

          if (t_str[1] == 'X')
            t_str[1] = 'x';

          sscanf (t_str, "0x%x", &hex_data);

          sprintf (token, "%d", hex_data);

          line_ptr = x;
          x = strlen(line);
        }

      token_type = INTEGER_TOKEN;
      return(1);
    }

    if (isdigit (line[line_ptr]))
    {
      token_type = INTEGER_TOKEN;

      for (x = line_ptr + 1; x < strlen(line); x++)
        if (!(isdigit(line[x])))
        {
          strncpy (token, &line[line_ptr], (x - line_ptr));
          token [x - line_ptr] = '\0';
          line_ptr = x;
          x = strlen(line);
        }
      return (1); /* token found */
    }

    /******************************************************/
    /* */
    /* If it made it this far, it must be an OTHER_TOKEN */
    /* */
    /******************************************************/

    token_type = OTHER_TOKEN;

    token[0] = line[line_ptr];
    token[1] = '\0';
    line_ptr += 1;
    return (1); /* token found */
  }
}

/*--------------------------------------------------------------------------*/

void process_sympath_keyword(void)
{
  DIR *dirp;
  char sympath[255];
  char t_str[400];
  char new_string[4000];

  new_string[0] = 0;
  token_type = OTHER_TOKEN;

  while ((token_type != KEYWORD_TOKEN) &&
      (!(end_of_file)))
  {
    Get_token();

    if (token_type == STRING_TOKEN)
    {
      strcpy (sympath, &token[1]); /* Chop off the double quote */
      sympath[strlen(sympath)-1] = 0; /* characters on either end. */

      strcpy (t_str, sympath);
      strcpy (sympath, expand_shell_vars (t_str));

      dirp = opendir (sympath);
      if (dirp == NULL)
        fprintf (stderr, "Unable to open SYM directory: %s\n", sympath);
      else
      {
        strcpy (&SYM_search_directory[SYM_dir_count][0], sympath);
        SYM_dir_count++;
        closedir (dirp);
        strcat (new_string, ":");
        strcat (new_string, sympath);
      }
    }
  }
  line_ptr = old_line_ptr; /* Re-use the keyword token */

  if (strlen (new_string) > 0)
    FI_append_symbol_path (new_string);
}

/*------------------------------------------------------------------------*/

void process_dpb_keyword(void)
{
  char pathname[200], t_str[200];
  int status;
  FILE *load_pv_file;
  struct dpb_struct test_dpb;
  char c;

  token_type = OTHER_TOKEN;

  while ((token_type != STRING_TOKEN) && (!end_of_file))
  {
    Get_token();

    if (token_type == STRING_TOKEN)
    {
      strcpy (pathname, &token[1]);
      pathname[strlen(pathname)-1] = '\0';

      strcpy (t_str, pathname);
      strcpy (pathname, expand_shell_vars (t_str));

      load_pv_file = fopen (pathname, "r");

      if (load_pv_file == NULL)
      {
        fprintf (stderr,
            "dpb load error-- no such file: %s\n", pathname);
      }
      else
      {
        status = fread (&test_dpb, sizeof (test_dpb), 1, load_pv_file);

        if (status == 0)
          fprintf (stderr, "invalid dpb file: %s\n", pathname);
        else
        {
          status = fread (&c, 1, 1, load_pv_file);

          if (status != 0)
            fprintf (stderr, "invalid dpb file: %s\n", pathname);
          else
            memcpy (&dpb, &test_dpb, sizeof (test_dpb));
        }

        fclose (load_pv_file);
      }
    }
  }
  line_ptr = old_line_ptr;
}

/*------------------------------------------------------------------------*/

void process_language_keyword(void)
{
  DIR *dirp;
  char test_language[80];
  char test_dir[255];

  token_type = OTHER_TOKEN;

  while ((token_type != KEYWORD_TOKEN) &&
      (!(end_of_file)))
  {
    Get_token();

    if (token_type == STRING_TOKEN)
    {
      strcpy (test_language, &token[1]); /* Cut the double quote */
      test_language[strlen(test_language)-1] = 0; /* chars on both ends. */

      strcpy (test_dir, execute_dir);
      strcat (test_dir, "/config/");
      strcat (test_dir, test_language);

      dirp = opendir (test_dir);
      if (dirp == NULL)
      {
        fprintf (stderr, 
            "Invalid language - no directory: %s\n", test_dir);
      }
      else
      {
        strcpy (language, test_language);
        closedir (dirp);
      }
    }
  }

  line_ptr = old_line_ptr; /* Re-use the keyword token */
}
