#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "PDUstr.h"
#include "PDUuser.h"
#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUproto.h"

extern	struct PDUrefresh *refresh;
extern	struct PDUuser *user;
extern  short  PDU_refresh_loaded;
extern  short  PDU_use_suffix;
extern  char  *PDU_file_suffix;

int PDUdefine_refresh ()
{
	int		status = PDM_S_SUCCESS;
	char	path[512];
	char	suffix_flag[3];
	FILE	*outfile, *fopen ();


        _pdm_debug("copying current working directory", 0);
        _pdm_debug("current working directory = <%s>", user->wrkst_cwd);

        strcpy(path, user->wrkst_cwd);
	strcat (path, "/.refresh.dat");
        _pdm_debug("file path = <%s>", path);

	if ((outfile = fopen (path, "w")) == NULL)
	  {
		_pdm_debug ("PDUdefine_refresh: error opening <%s>", path);
		_pdm_debug ("PDUdefine_refresh: errno = <%d>", (char *)errno);
		return (PDM_E_OPEN_FILE);
	  }

	status = PDUwrite_refresh_file (user->environment, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (user->username, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_project, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_catalog, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_partid, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_revision, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_description, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_parttype, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (refresh->rev_filename, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (user->environment, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (user->username, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

        sprintf(suffix_flag, "%d", PDU_use_suffix);
	status = PDUwrite_refresh_file (suffix_flag, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

	status = PDUwrite_refresh_file (PDU_file_suffix, outfile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (outfile);
		return (status);
	  }

        _pdm_debug("Closing ascii file and returning SUCCESS", 0);
	fclose (outfile);
	return (PDM_S_SUCCESS);
  }


int PDUget_refresh ()
{
	int		status = PDM_S_SUCCESS;
	char	path[512];
	FILE	*infile, *fopen ();
	struct	stat buf;
        char    *old_environment = NULL;
        char    *environment = NULL;
        char    *old_username = NULL;
        char    *username = NULL;
        char    *suffix_flag = NULL;

        _pdm_debug("copying current working directory", 0);
        _pdm_debug("current working directory = <%s>", user->wrkst_cwd);

        strcpy(path, user->wrkst_cwd);
	strcat (path, "/.refresh.dat");
        _pdm_debug("file path = <%s>", path);

	if (stat (path, &buf))
	  {
		_pdm_debug ("PDUget_refresh: stat failed; errno = %d", 
                             (char *)errno);
		_pdm_debug ("PDUget_refresh: returning %d", 
                            (char *)PDM_E_OPEN_FILE);
		return (PDM_E_OPEN_FILE);
	  }

	if (buf.st_size == 0)
	  {
		_pdm_debug ("PDUget_refresh: file is empty", 0);

		refresh->rev_project = NULL;
		refresh->rev_catalog = NULL;
		refresh->rev_partid = NULL;
		refresh->rev_revision = NULL;
		refresh->rev_description = NULL;
		refresh->rev_parttype = NULL;
		refresh->rev_filename = NULL;

		_pdm_debug ("PDUget_refresh: returning %d", 
                            (char *)PDM_S_SUCCESS);
		return (PDM_S_SUCCESS);
	  }

	if ((infile = fopen (path, "r")) == NULL)
	  {
		_pdm_debug ("PDUget_refresh: error opening <%s>", path);
		_pdm_debug ("PDUget_refresh: errno = <%d>", (char *)errno);
		return (PDM_E_OPEN_FILE);
	  }

	status = PDUread_refresh_file (&environment, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&username, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_project, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_catalog, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_partid, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_revision, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_description, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_parttype, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&refresh->rev_filename, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&old_environment, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&old_username, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

        if ((strcmp(old_environment, user->environment) != 0))
          {
          status = PDM_E_DIFFERENT_SERVER;
          PDU_refresh_loaded = FALSE;
          return(status);
          }
        else if ((strcmp(old_username, user->username) != 0))
          {
          status = PDM_E_DIFFERENT_SERVER;
          PDU_refresh_loaded = FALSE;
          return(status);
          }

	status = PDUread_refresh_file (&suffix_flag, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
                PDU_use_suffix = TRUE;
		fclose (infile);
		return (status);
	  }
        if (strlen(suffix_flag))
          PDU_use_suffix = atoi(suffix_flag);
        else
          PDU_use_suffix = TRUE;

	status = PDUread_refresh_file (&PDU_file_suffix, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }
        _pdm_debug("suffix_flag = %d", (char *)suffix_flag);
        _pdm_debug("PDU_file_suffix = >%s>", PDU_file_suffix);

        _pdm_debug("Closing ascii file and returning SUCCESS", 0);
	fclose (infile);
	return (PDM_S_SUCCESS);
  }


int PDUwrite_refresh_file (char *field, FILE *outfile)
{
  if (field == NULL)
	{
	  fprintf (outfile, "\n");
		_pdm_debug ("PDUwrite_refresh_file: field is NULL", 0);
	}
	else
	{
		fprintf (outfile, "%s\n", field);
		_pdm_debug ("PDUwrite_refresh_file: field = <%s>", field);
	}
	return (PDM_S_SUCCESS);
}
int PDUread_refresh_file (field, path, infile)
  char	**field;
  char	*path;
  FILE	*infile;
  {
	char	s[1024];
	char	*myfgets ();

	if ((myfgets (s, 1024, infile)) == NULL)
	  {
		_pdm_debug ("PDUread_refresh_file: error reading <%s>", path);
		return (PDM_E_READ_FILE);
	  }

	if (s == NULL)
	  {
		*field = NULL;
	  }
	else if (strcmp (s, "") == 0)
	  {
		*field = NULL;
	  }
	else
	  {
		if ((*field = (char *) malloc (strlen (s) + 1)) == NULL)
		  {
			_pdm_debug ("PDUread_refresh_file: error mallocing <%d> bytes",
				(char *)strlen (s) + 1);
			return (PDM_E_COULD_NOT_MALLOC);
		  }

		strcpy (*field, s);
	        _pdm_debug ("PDUread_refresh_file: field = <%s>", *field);
	  }

	  return (PDM_S_SUCCESS);
  }

/**************************************************************************

    Function: myfgets

      Author: Terry McIntyre

        Date: 10/29/87

   Arguments: char *s -- the return string
              int n -- the maximum number of characters to be transferred
              FILE *stream -- input stream

   Description: myfgets is the same as fgets except the '\n' is
                removed from the returned string.

***************************************************************************/
char *myfgets(char *s, int n, FILE *stream)
{
  char *sts,*strchr();

  if ((sts = fgets(s,n,stream)) == NULL) return(sts);

  if ((sts = strchr(s,'\n'))    == NULL) return(s);
  *sts = 0;

  return(s);
}

int PDUget_login_form_data ()
{
  int    status = PDM_S_SUCCESS;
  char   path[512];
  FILE  *infile, *fopen ();
  struct stat buf;
  char  *cwd = NULL;
  char  *teststr = NULL;

  _pdm_debug("in the function PDUget_login_form_data", 0);

  cwd = ((char *)getenv ("PWD"));
  if (!cwd)
  {
    _pdm_debug("error retrieving CWD", 0);
    return(PDM_E_WRKST_CWD);
  }
  strcpy(path, cwd);
	strcat(path, "/.refresh.dat");
  _pdm_debug("file path = <%s>", path);

	if (stat (path, &buf))
	{
		_pdm_debug ("PDUget_login_form_data: stat failed; errno = %d",  (char *)errno);
		_pdm_debug ("PDUget_login_form_data: returning %d",             (char *)PDM_E_OPEN_FILE);
		return (PDM_E_OPEN_FILE);
	}

	if (buf.st_size == 0)
	{
    user->environment = NULL;
	  user->username    = NULL;
		return (PDM_S_SUCCESS);
	}

	if ((infile = fopen (path, "r")) == NULL)
	{
		_pdm_debug ("PDUget_login_form_data: error opening <%s>", path);
		_pdm_debug ("PDUget_login_form_data: errno = <%d>", (char *)errno);
		return (PDM_E_OPEN_FILE);
	}

	status = PDUread_refresh_file (&user->environment, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

	status = PDUread_refresh_file (&user->username, path, infile);
	if (status != PDM_S_SUCCESS)
	  {
		fclose (infile);
		return (status);
	  }

  _pdm_debug("Closing ascii file and returning SUCCESS", 0);
	fclose (infile);
	return (PDM_S_SUCCESS);
}
