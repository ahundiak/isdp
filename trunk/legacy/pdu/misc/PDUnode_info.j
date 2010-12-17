#include	<pwd.h>
#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUuser.h>
#include	<PDUerror.h>
#include	<PDUmacros.h>
#include	<MEMerrordef.h>
#include	<FCdata.h>
#include	<FCdef.h>
#include	<sunorip32.h>
#include	<string.h>
#include	<PDUstorage.h>

extern struct PDUstorage *storage;
extern struct PDUuser *user;

int PDUget_user_node_info()
  {
    int				status;
    char			*username;
    struct passwd 		*user_info;
    char			*cwd;
    char			node[512];
    char                        *nodename = NULL;
    char			*getlogin();
    struct passwd 		*getpwnam();
    char			*PDUgetcwd();
    unsigned short		getuid();
    struct passwd 		*getpwuid();
    extern struct PDUrefresh 	*refresh;
    struct FC_login_data_st	form_data;
    char			*password;
    char			*remote_path; 
    char			*remote_node;
    char			*get_remote_path();
    int    			flag;
    char                        salt[3];
    char                        *key_in_pwd = NULL;
/*
   username = (char *) malloc (50);
   username = getlogin();

   _pdm_debug("getlogin returns <%d>", username);
   _pdm_debug("username = <%s>", username);
   
   if (!username)
     return(PDM_E_WRKST_USER);
*/

   user_info = (struct passwd *) malloc ( sizeof(struct passwd));
   user_info = getpwuid(getuid());

/*
   user_info = getpwnam(username);

   _pdm_debug("getpwnam returns <%d>", user_info);
   _pdm_debug("password = <%s>", user_info->pw_passwd);
*/
   if (user_info == 0)
     return(PDM_E_WRKST_PASSWD);

   username = user_info->pw_name;
   password = user_info->pw_passwd;

   if (strcmp(user_info->pw_passwd,""))
     {
      _pdm_debug("password from refresh area = <%s>",refresh->wrkst_passwd);
      _pdm_debug("password from user_info = <%s>",user_info->pw_passwd);

      /* extract the first two characters from password and loaded into salt */
      salt[0] = password[0];
      salt[1] = password[1];
      salt[2] = '\0';

      _pdm_debug("salt = <%s>",salt);

      /* set type of form and the number of rows and columns of form data */
      form_data.num_of_rows = 3;

      /* indicate that input is expected but there is no checklist in form */
      form_data.attr_list_expected = NO_ATTR_LIST;

      /* define the form location on screen and the title of form */       
      form_data.form_x = 80;
/* BETH CSS5.0 
      form_data.form_y = 80; */
      form_data.form_y = 134;
/* end BETH */
      sprintf(form_data.title,"Enter password for login  %.10s on workstation", 
				username);

      /* allocate space in memory for the form data and initialize */
      form_data.data = (char **) malloc ( 3 * sizeof(char *));
      memset(form_data.data, NULL, 3 * sizeof(char *));

      form_data.data[0] = NULL;
      PDUfill_in_string(&form_data.data[0], username);
 
      /* add a loop to verify password */
      flag = TRUE;
      while (flag)
            { 
             form_data.data[1] = NULL;
/*
             status = FC_process_login_form ( &om_stat, &form_data );
             _pdm_status("FC_process_login_form", status);
*/
             /* encrypt keyed_in password */
             _pdm_debug("form_data.data[1] = <%s>",form_data.data[1]);

             key_in_pwd = (char *)crypt(form_data.data[1],salt);
             _pdm_debug("encrypted key_in password = <%s>",key_in_pwd);
        
             if (status == PDM_I_FORM_CANCEL)
             return(status);

             if (strcmp(key_in_pwd,password) == 0)
                {
                 _pdm_debug("passwords match",0);
                 flag = FALSE;
                }

             else
                {
                 _pdm_debug("passwords do not match",0);
                 PDUmessage(PDM_E_INVALID_PASSWD,'s');
                }

            }

      password = form_data.data[1];
     }


   cwd = PDUgetcwd((char *)NULL, 64);    

   _pdm_debug("getcwd returns <%d>", cwd);
   _pdm_debug("cwd = <%s>", cwd);

   if ((!cwd) || (strcmp(cwd,"") ==0))
     return(PDM_E_WRKST_CWD);

   remote_path = get_remote_path(cwd, &remote_node);

   if (strlen(remote_path) > 0)
     {
      _pdm_debug("get_remote_path returns <%d>", remote_path);
      _pdm_debug("remote_path = <%s>", remote_path);
      _pdm_debug("remote_node = <%s>", remote_node);

       PDUfill_in_string(&refresh->wrkst_username, username);
       PDUfill_in_string(&refresh->wrkst_passwd, password);
       PDUfill_in_string(&refresh->wrkst_cwd, remote_path);
       PDUfill_in_string(&refresh->wrkst_node, remote_node);
       return(PDM_S_SUCCESS);
     }

/* Vasu 21.2.92 - Alternative mechanism to get the local node name */

#ifdef SUN

  status = PDUget_sun_nodename ( &nodename );
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

   _pdm_debug("PDUget_sun_nodename returns status = <%d>", status);
   _pdm_debug("Nodename = <%s>", nodename);

  if (status)
    {
      _pdm_debug("PDUget_sun_nodename returns status = <%s>", status);
      return(PDM_E_WRKST_NODE);
    }

#endif

/* Vasu 21.02.92 - End addition */

#ifdef IP32

   status = clh_vbyop("template", "Nodename", node, 512);

   _pdm_debug("clh_vbyop returns status = <%d>", status);
   _pdm_debug("Nodename = <%s>", node);

   if (status)
     {
       _pdm_debug("clh_vbyop returns status = <%s>", status);
       return(PDM_E_WRKST_NODE);
     }  

#endif

   else
     {
     _pdm_debug("username = <%s>", username);
     _pdm_debug("password = <%s>", password);
     _pdm_debug("cwd = <%s>", cwd);
     _pdm_debug("node = <%s>", node);

       PDUfill_in_string(&refresh->wrkst_username, username);
       PDUfill_in_string(&refresh->wrkst_passwd, password);
       PDUfill_in_string(&refresh->wrkst_cwd, cwd);
       PDUfill_in_string(&refresh->wrkst_node, node);
     }
   return(PDM_S_SUCCESS);

  }

void PDUload_storage_area()
{
	storage->storage_name = 0;
	PDUfill_in_string(&storage->storage_name, "");
	PDUfill_in_string(&storage->node_name, user->wrkst_node);
/* Mychelle this should be the workstation user 10/06/92  - beth */
/*	PDUfill_in_string(&storage->user_name, user->username);*/
	PDUfill_in_string(&storage->user_name, user->wrkst_username);
	PDUfill_in_string(&storage->passwd, user->wrkst_passwd);
	PDUfill_in_string(&storage->path_name, user->wrkst_cwd);
}

int PDUget_storage_buffer(storage_area)
  MEMptr		*storage_area;
  {
    int				status = PDM_S_SUCCESS;
    char			*string;
    int				char_index;
    extern struct PDUuser	*user;

    status = PDMopen_buffer(4, storage_area);
    _pdm_status("PDMopen_buffer", status);

    if ( status == PDM_S_SUCCESS )
      {
        string = (char *) malloc ((*storage_area)->row_size);
        memset(string, NULL, (*storage_area)->row_size);
        
        char_index = 0;
        
        string[char_index++] = PDM_BUFFER_TERM;
        string[char_index++] = PDM_BUFFER_TERM;
        
        PDUadd_buffer_string(string, &char_index, user->wrkst_node);
        PDUadd_buffer_string(string, &char_index, user->wrkst_username);
        /*PDUadd_buffer_string(string, &char_index, user->wrkst_passwd);*/
        string[char_index++] = PDM_BUFFER_TERM;
        /*string[char_index++] = '\1';*/
        PDUadd_buffer_string(string, &char_index, user->wrkst_cwd);

        _pdm_debug("string = <%s>", string);

        status = MEMwrite(*storage_area, string);
        _pdm_status("MEMwrite", status);

        if (status != MEM_S_SUCCESS)
          {
            free(string);
            return(PDM_E_WRITE_BUFFER);
          }
      }
    else
      return(PDM_E_OPEN_BUFFER);

    return(PDM_S_SUCCESS);
  }

int PDUget_sun_nodename(node)
char  **node;
{
  FILE   *hostfile;
  char   *path = NULL;
  char   *nodename = NULL;
  int    status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDUget_sun_nodename", 0);

  PDUfill_in_string(&path, "/etc/hostname.le0");
  _pdm_debug("Path = <%s>", path);

  hostfile = fopen ("/etc/hostname.le0", "r");
  if (!hostfile)
    {
    _pdm_debug("Error opening /etc/hostname.le0 file", 0);
    status = PDM_E_OPEN_FILE;
    return(status);
    }

  status = PDUread_refresh_file(&nodename, path, hostfile);
  if (status != PDM_S_SUCCESS)
    {
    fclose(hostfile);
    return(status);
    } 

  _pdm_debug("node name = <%s>", nodename);
  if ((nodename) && (strlen(nodename)))
    {
    PDUfill_in_string(node, nodename);
    _pdm_debug("node name (after PDUfill_in_string) = <%s>", *node);
    }
  else
    {
    status = PDM_E_WRKST_NODE;
    return(status);
    }

  return(status);
}

void PDUprint_storage_area()
{
	_pdm_debug("STORAGE AREA", 0);
        _pdm_debug("storage->storage_no     = <%d>", storage->storage_no);
        _pdm_debug("storage->storage_name   = <%s>", storage->storage_name);
        _pdm_debug("storage->node_name      = <%s>", storage->node_name);
        _pdm_debug("storage->user_name      = <%s>", storage->user_name);
        _pdm_debug("storage->passwd         = <%s>", storage->passwd);
        _pdm_debug("storage->path_name      = <%s>", storage->path_name);
}
