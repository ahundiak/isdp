#include "machine.h"
#include "NFMnfmt_inc.h"

long NFMls_nodes (type, output_buffer)
  char		*type;
  MEMptr	*output_buffer;
  {
	long	status;

	static	char *fname = "NFMls_nodes";

	/*  Local functions  */

	long	NFMfind_files ();

/* HP PORT - IGI - 10 Jun 94 */

#if  (defined(OS_SUNOS) || defined(OS_SOLARIS) ||  \
      defined(OS_SCO_UNIX) || defined(OS_HPUX) )
      long    NFMget_entries ();      /* Added for sparc - Vasu */
#endif
	long	NFMsort_buffer ();

	/*  External functions  */

	long	MEMopen ();
	long	MEMwrite_format ();
	long	MEMclose ();

	_NFMdebug((fname, "Entry:type = <%s> MEMptr *output_buffer <%x>\n", type,*output_buffer));

	/*  Open output_buffer  */

	if ((status = MEMopen (output_buffer, MEM_SIZE)) != MEM_S_SUCCESS)
	  {
		_NFMdebug ((fname, "MEMopen = <0x%.8x>\n", status));
		status = NFM_E_MEM_ERR;
		ERRload_struct(NFM,status,"%s%s%s%x","MEMopen",fname,"status",status);
		return (status);
	  }

	if ((status = MEMwrite_format
		(*output_buffer, "name", "char(14)")) != MEM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
		status = NFM_E_MEM_ERR;
		ERRload_struct(NFM,status,"%s%s%s%s","MEMwrite_format",fname,"name","name");
		return (status);
	  }

	/*  Get all files in the local directory first  */
	
/* HP PORT - IGI - 10 Jun 94 */

#if  (defined(OS_SUNOS) || defined(OS_SOLARIS) ||  \
      defined(OS_SCO_UNIX) || defined(OS_HPUX) )

        /*  Added code to get information from NFMenv.dat and	NFMser.dat */
        /*  for the sparc -  Vasu 10.11.93                                 */
        /* 'local' added as first argument - SSRS - 4/12/93              */

        if ((status = NFMget_entries ("local",  type,  *output_buffer)) != NFM_S_SUCCESS)
          {
                MEMclose (output_buffer);
                _NFMdebug ((fname,  "NFMget_entries =	<0x%.8x>\n",  status));
                return (status);
          }
     if ((status = NFMget_entries ("heard",  type,  *output_buffer)) != NFM_S_SUCCESS)
          {
                MEMclose (output_buffer);
                _NFMdebug ((fname,  "NFMget_entries = <0x%.8x>\n",  status));
                return (status);
          }
#else
	if ((status = NFMfind_files
	("/usr/lib/nodes/local", type, *output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname, "NFMfind_files = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get all files in the heard directory  */

	if ((status = NFMfind_files
		("/usr/lib/nodes/heard", type, *output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname, "NFMfind_files: status = <0x%.8x>\n", status));
		return (status);
	  }

#endif

	/*  Sort the buffer alphabetically  */

	if ((status = NFMsort_buffer (*output_buffer)) != NFM_S_SUCCESS)
	  {
		MEMclose (output_buffer);
		_NFMdebug ((fname, "NFMsort_buffer: status = <0x%.8x>\n", status));
		return (status);
	  }

	_NFMdebug ((fname, "SUCCESSFUL <0x%.8x>\n", NFM_S_SUCCESS));
	return (NFM_S_SUCCESS);
  }


long NFMfind_files (dirname, filename, output_buffer)
  char		*dirname;
  char		*filename;
  MEMptr	output_buffer;
  {
	int		i;
	DIR		*infile;
	long	status;
	char	**data_ptr;
	short	found;
	struct	dirent *dirp;

	static	char *fname = "NFMfind_files";

	/*  External functions  */

	extern	long MEMwrite ();
	extern	long MEMbuild_array ();

	_NFMdebug ((fname, "Entry:dirname = <%s>:filename = <%s>\n", dirname,filename));

	if ((infile = opendir (dirname)) == NULL)
	  {
                _NFMdebug((fname,"Error opening directory file <%s>:errno <%d>\
status <0x%.8x>\n",dirname,errno,NFM_E_OPEN_FILE));
		status = NFM_E_OPEN_FILE;
		ERRload_struct(NFM,status,"%s",dirname);
		return (status);
	  }

	while ((dirp = readdir (infile)) != NULL)
	  {
		if ((strncmp (dirp->d_name, filename, strlen (filename))) != 0)
			continue;

		_NFMdebug ((fname, "found <%s>\n", dirp->d_name));

		if ((status = MEMbuild_array (output_buffer)) != MEM_S_SUCCESS)
		  {
			_NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
			closedir (infile);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",fname,"status",status);
			status = NFM_E_MEM_ERR;
			return (status);
		  }

		data_ptr = (char **) output_buffer->data_ptr;

		/*  See if the filename already exists in the buffer  */

		for (i = 0, found = 0; i < output_buffer->rows; ++i)
		  {
			if ((strcmp (data_ptr[i],
				&(dirp->d_name)[strlen (filename)])) == 0)
			  {
				found = 1;
				break;
			  }
		  }

		if (found == 1) continue;

		/*  Strip off the filename before writing  */

		if ((status = MEMwrite (output_buffer,
			&(dirp->d_name)[strlen (filename)])) != MEM_S_SUCCESS)
		  {
			_NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
			closedir (infile);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite",fname,"status",status);
			status = NFM_E_MEM_ERR;
			return (status);
		  }
	  }

	closedir (infile);

	_NFMdebug ((fname, "SUCCESSFUL <0x%.8x>\n", NFM_S_SUCCESS));
	return (NFM_S_SUCCESS);
  }


long NFMsort_buffer (buffer)
  MEMptr	buffer;
  {
	int		i, j;
	int		size;
	long	status;
	char	*temp, **data_ptr;

	static	char *fname = "NFMsort_buffer";

	/*  External functions  */

	extern	long MEMbuild_array ();

	/*  Prepare the buffer for reading  */
	_NFMdebug((fname,"Entry: MEMptr Buffer <%x>\n",buffer));

	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
		status = NFM_E_MEM_ERR;
		ERRload_struct(NFM,status,"%s%s%s%x","MEMbuild_array",fname,"status",status);
		return (status);
	  }

	data_ptr = (char **) buffer->format_ptr;
	sscanf (data_ptr[0], "char(%d)", &size);

	_NFMdebug ((fname, "size = <>\n", size));
	if (size <= 0)
	  {
		_NFMdebug ((fname, "size of char column is invalid\n"));
		status = NFM_E_MEM_ERR;
		ERRload_struct(NFM,status,"%s%s%s%d","Column size",fname,"size",size);
		return (NFM_E_MEM_ERR);
	  }

	/*  Allocate space for a temporary array  */

	if ((temp = (char *) malloc (size + 1)) == NULL)
	  {
		_NFMdebug ((fname,"malloc failed; size = <%d>:status <0x%.8x>\n", size + 1,NFM_E_MALLOC));
		status = NFM_E_MALLOC;
		ERRload_struct(NFM,status,"%d",size);
		return (status);
	  }

	/*  Sort the buffer  */

	data_ptr = (char **) buffer->data_ptr;
	for (i = 0; i < buffer->rows - 1; ++i)
	  {
		for (j = i + 1; j < buffer->rows; ++j)
		  {
			if ((strcmp (data_ptr[i], data_ptr[j])) > 0)
			  {
				/*  Swap the 2 rows  */

				strcpy (temp, data_ptr[i]);
				strcpy (data_ptr[i], data_ptr[j]);
				strcpy (data_ptr[j], temp);
			  }
		  }
	  }

	/*  Free the allocated space  */

	if (temp) free (temp);

	_NFMdebug ((fname, "SUCCESSFUL <0x%.8x>\n", NFM_S_SUCCESS));
	return (NFM_S_SUCCESS);
  }


/* HP PORT - IGI - 10 Jun 94 */

#if  (defined(OS_SUNOS) || defined(OS_SOLARIS) ||  \
      defined(OS_SCO_UNIX) || defined(OS_HPUX) )

#include "NFMenv.h"   /* 4/12/93 SSRS */
#include <pwd.h>

long NFMget_entries (source, filename,  output_buffer)
  char          *source;  /* added by SSRS 4/12/93 */
  char          *filename;
  MEMptr        output_buffer;
  {
        int             i;
        long    status;
        char    **data_ptr;
        short   found;
        struct passwd *pwd;

        FILE    *infile = NULL;

        char    *strtok(),  line[256],  *token,  *csts,  datafile[64];

        static  char *fname = "NFMget_entries";

        /*  External functions  */

        extern  long MEMwrite ();
        extern  long MEMbuild_array ();

      _NFMdebug ((fname,  "Entry:filename = <%s>\n",  filename));

      pwd = getpwnam( "nfmadmin" );

      /* comparision with nfmc_ added -- SSRS 4.12.93 */
      if ( strcmp (filename,  "nfms_") == 0 ||
           strcmp (filename,  "nfmc_") == 0 )
        {
            /* strcpy (datafile,  "/usr/ip32/nfm/NFMser.dat");*/
             sprintf(datafile,  "%s/%s/%s",  pwd->pw_dir, ENV_PATH,  SER_FILE);
        }

        /* Comparision with 'local' and 'heard' added. - SSRS - 4/12/93 */
        else if ( strcmp (filename,  "nfme_") == 0  )
             {
                if( strcmp( source,  "owned") == 0 ||
                  strcmp( source,  "local") == 0 )
              {
                  /*strcpy (datafile, "/usr/ip32/nfm/NFMowne.dat");*/
                  sprintf(datafile,  "%s/%s/%s",  pwd->pw_dir, ENV_PATH,  OWNENV_FILE);
              }
              if( strcmp( source,  "heard") == 0 )
               {
                 /*strcpy (datafile, "/usr/ip32/nfm/NFMenv.dat");*/
                 sprintf(datafile,  "%s/%s/%s",  pwd->pw_dir, ENV_PATH,  ENV_FILE);
               }
           }
           else
               _NFMdebug((fname, "Unknown nfm-prefix <%s>:\n", filename));

        if ((infile = fopen (datafile,  "r")) == NULL)
          {
            _NFMdebug((fname, "Error opening <%s>: errno <%d> \
status <0x%.8x>\n", datafile, errno, NFM_E_OPEN_FILE));
            status = NFM_E_OPEN_FILE;
            ERRload_struct(NFM, status, datafile);
            return (status);
          }

        for (;;)
          {
                csts = fgets (line,  256,  infile);
                if ( !csts )
                  {
                        /* ERROR or EOF */
                        break;
                  }

                /* Get the first entry only,  as it is the name of the */
                /* server / environment         - Vasu                */

                if ( ! (token = strtok (line,  "\001")) )
                 {
                        /* ERROR */
                 }

                if ((strncmp (token,  filename,  strlen (filename))) != 0)
                        continue;

                _NFMdebug ((fname,  "found <%s>\n",  token));

                if ((status = MEMbuild_array (output_buffer)) != MEM_S_SUCCESS)
                  {
                     _NFMdebug ((fname,  "MEMbuild_array =<0x%.8x>\n",  
                      status));
                      fclose (infile);
                      ERRload_struct(NFM, NFM_E_MEM_ERR, "%s%s%s%x", 
                     "MEMbuild_array", fname, "status", status);
                     status = NFM_E_MEM_ERR;
                     return (status);
                  }

                data_ptr = (char **) output_buffer->data_ptr;

                /*  See if the filename already exists in the buffer  */

                for (i = 0,  found = 0; i < output_buffer->rows; ++i)
                  {
                        if ((strcmp (data_ptr[i], 
                                &token[strlen (filename)])) == 0)
                          {
                                found = 1;
                                break;
                          }
                  }

                if (found == 1) continue;

                /*  Strip off the filename before writing  */

                if ((status = MEMwrite (output_buffer, 
                        &token[strlen (filename)])) != MEM_S_SUCCESS)
                  {
                        _NFMdebug ((fname,  "MEMwrite = <0x%.8x>\n",  status));
                        fclose (infile);
                        ERRload_struct(NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite", fname, "status", status);
                        status = NFM_E_MEM_ERR;
                        return (status);
                  }
          }

        fclose (infile);

        _NFMdebug ((fname,  "SUCCESSFUL <0x%.8x>\n",  NFM_S_SUCCESS));
        return (NFM_S_SUCCESS);
  }

#endif
