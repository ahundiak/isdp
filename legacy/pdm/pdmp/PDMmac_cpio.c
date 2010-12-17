#include  <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <malloc.h>
#include <errno.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "PDUris_incl.h"
#include "PDMtypes.h"
#include "PDUerror.h"
#include "WFstruct.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"


extern int      PDMdebug_on;
extern struct WFstruct WFinfo;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];
static long     status;
extern PDMexec_ptr PDMexec;
/*
           BUNDLE THE *.e's INTO A CPIO FILE 

All *.e's s associated to the macro library ied to local as a cpio file.
It's not a rule that they have to be a cpio file. If the file_type
of the macro is other than "CPIO" then those files won't be unbundled.

- Kumar Narayanan

*/

int PDMbundle_macros(cwd, cpio_file, macros)
char  *cwd;
char  *cpio_file;  /*Macros  to be unbundled */
MEMptr macros;
{
    char        line[1024];
    char        line_2[51];
    char        **data;
    int         i;
    long      stat_loc ;
    static char *fname = "PDMbundle_macros";

    _PDMdebug( fname, "%s\n", "Entering ..." );

status = MEMbuild_array (macros) ;
  if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fname, "MEMbuild_array : status = <0x%.8>\n", status);
      return (PDM_E_BUILD_ARRAY);
    }
  data = (char **) macros -> data_ptr;
    strcpy( line, "find " );

   for (i = 0; i < macros->rows ; i++){
            strcat( line, cwd );
            strcat( line, "\\" );
            strcat( line, data[i] );
            strcat( line, " " );
            }
    sprintf( line_2, " -print | cpio -o > %s", cpio_file );
    strcat( line, line_2);
    strcat( line, " 2>&1" );


      status = (long) vfork () ;
      if (status == 0)
        {
          _PDMdebug (fname,"Executing a %s\n", line) ;
          status = (long) execl (line, (char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl failed %d\n", errno);
              exit(0);
            }
        } 
        else
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
          return (status) ;
        }


     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           {
         _PDMdebug (fname, "Receipt of a signal from child process%d\n", errno);
           }
         else
           {
             _PDMdebug (fname, "wait for the child process failed %d\n", errno);
           }
         return (status) ;
       }

       /* the other option is to call PDMsystem 
          status = PDMsystem (line) ;
          if (status == PDM_S_SUCCESS)
            {
              _PDMdebug (fname, "execl failed \n");
              return(status);
            }
         */

    _PDMdebug( fname, "%s\n", "Exiting ..." );

    return( PDM_S_SUCCESS );
}

/* Kumar Narayanan - Execs a system call */

int PDMsystem(shell_str)
        char *shell_str;
{
        char *fname="PDMsystem";
        long status, length ;
        char tmp[25],tmp2[15];
        char *sys_str;

        _PDMdebug(fname,"Entry: shell_str <%s> \n",shell_str);
        length = strlen(shell_str) + 50;
        sys_str = (char *) malloc(length);
        if(sys_str == (char *)0)
        {
                _PDMdebug(fname,"Malloc failed for string size <%d>: status <0x%.8x>\n",length,NFM_E_MALLOC);
                return(NFM_E_MALLOC);
        }
        strcpy(tmp2,"PDMsyst1XXXXXX");
        mktemp(tmp2);
        sprintf(tmp,"/usr/tmp/%s",tmp2);
        sprintf(sys_str,"%s > %s 2>&1",shell_str,tmp);
        status = system(sys_str);
status = system(sys_str);
        if(status)
        {
                _PDMdebug(fname,"System  failed for shell_str <%s> : \
errno <%d> status <%d>:Error_file <%s>\n", shell_str,errno,status,tmp);
                free(sys_str);
                return(NFM_E_SYSTEM);
        }
        free(sys_str);
        unlink(tmp);
        _PDMdebug(fname,"SUCCESSFUL: status <0x%.8x>\n",PDM_S_SUCCESS);
        return(PDM_S_SUCCESS);
}


/*
           UNBUNDLE THE CPIO FILE INTO *.e's

All *.e's s associated to the macro library are copied to local as a cpio file.
It's not a rule that they have to be a cpio file. If the file_type
of the macro is other than "CPIO" then those files won't be unbundled.

- Kumar Narayanan
*/

int PDMunbundle_macros(cpio_file)
char  *cpio_file;  /*Macros  to be unbundled */
{
    char        line[512];
    long      stat_loc ;
    struct stat    file_status;
    static char *fname = "PDMunbundle_macros";

    _PDMdebug( fname, "%s\n", "Entering ..." );

  status = stat ( cpio_file, &file_status );
  if (status)
    {
      _PDMdebug (fname, "File not found in cwd : status = <0x%.8>\n", status);
      return (PDM_E_FILE_NOT_FOUND);
    }
    sprintf( line, " cpio -ivumd < %s", cpio_file );
    strcat( line, " 2>&1" );


      status = (long) vfork () ;
      if (status == 0)
        {
          _PDMdebug (fname,"Executing a %s\n", line) ;
          status = (long) execl (line, (char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl failed %d\n", errno);
              exit (0) ;
            }
        }
        else
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
          return (status) ;
        }


     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           {
         _PDMdebug (fname, "Receipt of a signal from child process%d\n", errno);
           }
         else
           {
             _PDMdebug (fname, "wait for the child process failed %d\n", errno);
           }
         return (status) ;
       }
    _PDMdebug( fname, "%s\n", "Exiting ..." );

    return( PDM_S_SUCCESS );
}


int     PDMXdefine_parametric_assembly(param_cat,param_part,param_rev,assembly)

char *param_cat;
char *param_part;
char *param_rev;
MEMptr assembly;

{
        MEMptr          temp_buffer = NULL;
        MEMptr          bufr = NULL;
        char            n_setindicator[2];
        char            **columns, **data;
        char            p_quantity[50], sql_str[1024];
        char            s_citno[50];
        int             a1, a2, a3, a4, a5, a6, a7, a8;
        int             m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13;
        int             i,j,nx, nxj;
        int             catno = 0, partno = 0;

        PDMdebug("ENTER:PDMdefine_parametric_assembly\n");

/* expand the child buffer */

        status = MEMopen(&temp_buffer,1024);
        if(status != MEM_S_SUCCESS)
        {
                MEMclose(&assembly);
                sprintf(s,"MEMopen failed status %d\n",
                status); PDMdebug(s);
                return(PDM_E_OPEN_BUFFER);
        }
        status = MEMwrite_format(temp_buffer,"p_citno","integer");
        if(status == MEM_S_SUCCESS)
        status = MEMwrite_format(temp_buffer,"n_catalogno","integer");
        if(status == MEM_S_SUCCESS)
        status = MEMwrite_format(temp_buffer,"n_itemno","integer");
        if(status == MEM_S_SUCCESS)
        status = MEMwrite_format(temp_buffer,"pn_catalogno","integer");
        if(status == MEM_S_SUCCESS)
        status = MEMwrite_format(temp_buffer,"pn_itemno","integer");
        if(status == MEM_S_SUCCESS)
        status = MEMwrite_format(temp_buffer,"p_flag","char(1)");
        if(status != MEM_S_SUCCESS)
        {
                MEMclose(&temp_buffer); MEMclose(&assembly);
                sprintf(s,"MEMwrite_format failed status %d\n",
                status); PDMdebug(s);
                return(PDM_E_WRITE_FORMAT);
        }
        status = PDMexpand_copy_buffer(assembly,temp_buffer,&bufr);
        if(status != PDM_S_SUCCESS)
        {
                MEMclose(&temp_buffer); MEMclose(&assembly);
                sprintf(s,"PDMexpand_copy_buffer failed status %d\n",
                status); PDMdebug(s);
                return(status);
        }
        MEMclose(&assembly); MEMclose(&temp_buffer);

        if(PDMdebug_on)
        {
                MEMprint_buffer("bufr",bufr,PDM_DEBUG_FILE);
        }
/* check if part is an assembly */

        n_setindicator[0] = '\0';
        status = PDMquery_assembly_ind(param_cat, param_part,
                param_rev,n_setindicator);
        if(status != PDM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"PDMquery_assembly_ind failed status %d\n",status);
                PDMdebug(s);
                return(status);
        }


        /* load children's n_catalogno,n_itemno */

         status = PDMload_partnos(bufr);
        if(status != PDM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"PDMload_partnos failed status %d\n",
                status); PDMdebug(s);
                goto wrapup;
        }

        /* load parent's pn_catalogno,pn_itemno */

        status = PDMload_parentnos(catno,partno,bufr);
        if(status != PDM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"PDMload_parentnos failed status %d\n",status);
                PDMdebug(s);
                goto wrapup;
        }
 /* load buffer into nfmsetcit */
        status = PDMstop_transaction(1200);
        if(status != PDM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"PDMstop_transaction failed status %d\n",status);
                PDMdebug(s);
                return(status);
        }
       status = SQLstmt("LOCK TABLES pdmcit IN EXCLUSIVE MODE");
        if (status != SQL_S_SUCCESS) {
                SQLstmt("COMMIT WORK");
       status = SQLstmt("LOCK TABLES pdmcit IN EXCLUSIVE MODE");
                }
        if (status != SQL_S_SUCCESS) {
                sprintf(s,  "LOCK pdmcit SQLstmt failed status %d\n",  status);
                PDMdebug(s);
                return (PDM_E_LOCK_CIT);
        }
        /* if part is an assembly then drop its assembly structure */

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
        if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"y",1))
*/
        if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"y",1) ||
           !strncmp(n_setindicator,"A",1) || !strncmp(n_setindicator,"a",1))
        {
                status = PDMdron_setindicator(catno,partno);
                if(status != PDM_S_SUCCESS )
                {
                        MEMclose(&bufr);
                        sprintf(s,"PDMdron_setindicator failed status %d\n",
                        status); PDMdebug(s);
                        goto wrapup;
                }
        }

        status = PDMload_set_members(PDMexec->user_id,bufr);
        if(status != PDM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"PDMload_set_members failed status %d\n",status);
                PDMdebug(s);
                goto wrapup;
        }
        if(PDMdebug_on)
        {
                MEMprint_buffer("bufr after PDMload_set_members ",
                                                bufr,PDM_DEBUG_FILE);
        }

 status = MEMbuild_array(bufr);
        if(status != MEM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"MEMbuild_array failed status %d\n",
                status); PDMdebug(s);
                status = PDM_E_BUILD_ARRAY;
                goto wrapup;
        }
        a1 = -1; a2 = -1; a3 = -1; a4 = -1;
        a5 = -1; a6 = -1; a7 = -1; a8 = -1;
        m1 = -1; m2 = -1; m3 = -1; m4 = -1;
        m5 = -1; m6 = -1; m7 = -1; m8 = -1;
        m9 = -1; m10 = -1; m11 = -1; m12 = -1; m13 = -1;

        data = (char **) bufr->data_ptr;
        columns = (char **) bufr->column_ptr;
        for(i=0;i<bufr->columns;i++)
        {
                if(!strcmp(columns[i],"p_citno"))         a1 = i;
        else    if(!strcmp(columns[i],"p_flag"))          a4 = i;
        else    if(!strcmp(columns[i],"n_catalogno"))     a5 = i;
        else    if(!strcmp(columns[i],"n_itemno"))        a6 = i;
        else    if(!strcmp(columns[i],"pn_catalogno"))    a7 = i;
        else    if(!strcmp(columns[i],"pn_itemno"))       a8 = i;
        else    if (!strcmp(columns[i], "n_catalogname")) m1 = i;
        else    if (!strcmp(columns[i], "n_itemname")) m2 = i;
        else    if (!strcmp(columns[i], "n_itemrev")) m3 = i;
        else    if (!strcmp(columns[i], "p_quantity")) m4 = i;
        else    if (!strcmp(columns[i], "p_history")) m5 = i;
        else    if (!strcmp(columns[i], "p_childno")) m6 = i;
        else    if (!strcmp(columns[i], "p_usageid")) m7 = i;
        else    if (!strcmp(columns[i], "p_tagno")) m8 = i;
        else    if (!strcmp(columns[i], "p_alttagno")) m9 = i;
        else    if (!strcmp(columns[i], "p_incbom")) m10 = i;
        else    if (!strcmp(columns[i], "p_explode")) m11 = i;
        else    if (!strcmp(columns[i], "p_attached")) m12 = i;
        else    if (!strcmp(columns[i], "n_cofilename")) m13 = i;
        }

        if(a1 == -1 || a4 == -1 ||
           a5 == -1 || a6 == -1 || a7 == -1 || a8 == -1 ||
           m1 == -1 || m2 == -1 || m3 == -1 || m4 == -1 ||
            m5 == -1 || m6 == -1 || m9 == -1 ||
      m7 == -1 || m8 == -1 ||  m10 == -1 ||
            m11 == -1 || m12 == -1 || m13 == -1 )
        {
                MEMclose(&bufr);
                sprintf(s,"Couldnot set offsets in bufr\n");
                PDMdebug(s);
                status = PDM_E_BUFFER_FORMAT;
                goto wrapup;
        }

        /* next insert pdmcit entries */

        for(i=0;i<bufr->rows;i++)
        {
                nx = i * bufr->columns;
                if(strlen(data[nx+m4]))
                {
                        strcpy(p_quantity,data[nx+m4]);
                }
                else
                {
                        sprintf(p_quantity,"%d",1);
                }

                /* set p_citno */

                if(!strcmp(data[nx+a4],"D"))
                {
                        for(j=0;j<bufr->rows;j++)
                        {
                                nxj = j * bufr->columns;
                                if(!strcmp(data[nx+a5],data[nxj+a5]) &&
                                   !strcmp(data[nx+a6],data[nxj+a6]) &&
                                   !strcmp(data[nx+a7],data[nxj+a7]) &&
                                   !strcmp(data[nx+a8],data[nxj+a8]))
                                {
                                        if(!strlen(data[nxj+a4]))
                                        {
                                                strcpy(s_citno,data[nxj+a1]);
                                                break;
                                        }
                                }
                        }
                }
                else
                {
                        strcpy(s_citno,data[nx+a1]);
                }
        sprintf(sql_str,"%s (%s) VALUES(%s,'%s','%s',%s,'%s',%s,'%s','%s','%s','%s','%s','%s')", "INSERT INTO pdmcit ", "p_citno,p_attached,p_history,p_quantity,p_usageid,p_tagno,p_alt tagno,p_incbom,p_explode,n_catalogname,n_itemname,n_itemrev", s_citno,data[nx+m12],data[nx+m5],p_quantity,data[nx+m7],data[nx+m8],data
[nx+m9],data[nx+m10],data[nx+m11],data[nx+m1],data[nx+m2],data[nx+m3]);
                status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                {
                        MEMclose(&bufr);
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                        status = PDM_E_SQL_STMT;
                        goto wrapup;
                }
        }
        MEMclose(&bufr);

        /* set n_setindicator */

        status = PDMset_n_setindicator(PDMexec->catalog,PDMexec->part_num, PDMexec->revision,"Y");
        if(status != PDM_S_SUCCESS)
        {
                sprintf(s,"PDMset_n_setindicator failed status %d\n",
                status); PDMdebug(s);
                goto wrapup;
        }
        status = PDMstart_transaction(1200);
        if(status != PDM_S_SUCCESS)
        {
                sprintf(s,"PDMstart_transaction failed status \n",status);
                PDMdebug(s);
                return(status);
        }
        PDMdebug("EXIT:PDMdefine_parametric_assembly\n");
        return(PDM_S_SUCCESS);

 wrapup:

        sprintf(s,
        "ERROR:PDMdefine_assembly_strucuture status %d\n",status);
        PDMdebug(s);
        if(PDMrollback_transaction(1200) != PDM_S_SUCCESS)
        {
                sprintf(s,"PDMrollback_transaction failed status \n",status);
                PDMdebug(s);
        }
        return(status);
}
