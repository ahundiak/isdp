#include "machine.h"
#include "xref.h"
#include "NFMf_xferinc.h"

extern struct REFLIST *head;

long _NFMget_acad_files(acad_file, file_list)

char *acad_file;
MEMptr *file_list;

{
  char *fname="_NFMget_acad_files";
  char xfile[FILE_LEN+1], xname[FILE_LEN+2], xpath[FILE_LEN+1];
  char s_xname[FILE_LEN+2];
  long	 num_xrefs, i,  status, flag;
  struct xref_st *xrefs=NULL;

  _NFMdebug ((fname, "Enter: file [%s]\n\
              initad...\n", acad_file));
  initad();

  _NFMdebug ((fname, "InitAvEng...\n"));

  InitAvEng(4096,4096,4096); 

  _NFMdebug ((fname, "GetXrefs...\n"));

  status = GetXrefs( acad_file, &num_xrefs, &xrefs );

  if (status )
  {
    _NFMdebug ((fname, "GetXrefs %x\n", status));
    return (status);
  }

  _NFMdebug ((fname, " [%d] xrefs\n", num_xrefs));

  for ( i = 0; i < num_xrefs; ++i )
  {
    _NFMdebug ((fname, "xref = %s\n", xrefs[i].name));

    /* xfile == whatever is returned, possible a file name with 
                relative/absolute path;
       xname == file name only;
       xpath == path only */

    strcpy  (xfile, xrefs[i].name);
    status = _NFMget_path_file (xfile, xpath, xname, &flag);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failed: 0x%.8x\n", status));
      return (status);
    }
    _NFMdebug ((fname, "xfile [%s] xname [%s] xpath [%s]\n",
                        xfile, xname, xpath));
    status = _NFMcheck_for_uniqueness (xpath, xname);
    if (status == NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Extracted acad file [%s]\n", xname));
      /* 7/30/94 remove extra .dwg */
      strcpy (s_xname, &xname[strlen(xname)-8]);
      NFMchange_case (s_xname, 1);
      _NFMdebug ((fname, "changed case [%s]\n", s_xname));
      if (! strcmp (s_xname, ".dwg.dwg"))
      {
        strncpy (s_xname, xname, strlen(xname) -4);
        s_xname[strlen(xname)-4] = '\0';
        strcpy (xname, s_xname);
        _NFMdebug ((fname, "new acad file name [%s]\n", xname));
      }
      status = MEMwrite (*file_list, xname);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite: 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }
      strcpy (xname, "\0");
    }
  }
  free ( xrefs );
  _NFMfree_REF_struct ();

  CloseAvEng(); 

  _NFMdebug ((fname, "Exit successful\n"));
  return (NFM_S_SUCCESS);
}

long NFMfs_get_acad_files(in_list, out_list)
MEMptr in_list, *out_list;
{

	char *fname="NFMfs_get_acad_files";
	long status;
	char file_name[NFM_COFILENAME+1];
	char format_str[15];
	char **data_ptr, **col_ptr;

	_NFMdebug((fname, "Entry:\n"));
	if(status = MEMbuild_array(in_list) != MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEMbuild_array = <0x%.8lx>\n",status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}

	data_ptr = (char **)in_list->data_ptr;
        col_ptr = (char **) in_list->column_ptr;

	if((strcmp(col_ptr[0], "n_filename")) || (in_list->columns != 1))
	{
		_NFMdebug((fname,"Currupted Micro station buffer\n"));
		status = NFM_E_CORRUPTED_BUFFERS;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}
	strncpy(file_name,data_ptr[0], NFM_COFILENAME);
	file_name[NFM_COFILENAME] = NULL;

	if((status = MEMopen(out_list,MEM_SIZE)) != MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEMopen = <0x%.8lx>\n",status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}
	sprintf(format_str, "char(%d)", NFM_COFILENAME);
	if((status = MEMwrite_format
			(*out_list,"att_file",format_str)) != MEM_S_SUCCESS)
	{
		MEMclose(out_list);
		_NFMdebug((fname,"MEMwrite_format = <0x%.8lx>\n",status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}
	if((status =
	       _NFMget_acad_files(file_name,out_list)) != NFM_S_SUCCESS)
	{
		MEMclose(out_list);
		_NFMdebug((fname,"Get micro files = <0x%.8lx>\n",status));
		return(status);
	}
	_NFMdebug((fname, "SUCCESSFUL Completion\n"));
	return(NFM_S_SUCCESS);
}
