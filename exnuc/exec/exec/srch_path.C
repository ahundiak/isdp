#include <igrtypedef.h>
#include <OMerrordef.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include <ex.h>
#include <exdef.h>
#include <expriv.h>
#include <string.h>
#include <stdio.h>
#include <exproto.h>

#define ENTRY_SIZE 50

extern char EX_runname[];
extern char *EX_search_path;
static char *EX_product_path;
static char *old_EX_search_path = 0;

int EX_set_srch_path()
{
   int            s_len,
                  stotal_len,
                  p_len,
                  ptotal_len,  
                  num,
                  num_path,
                  user_path_len,
                  status,
                  errflag;
   struct EX_nl   *name,
                  *n1, *n2;    
   char           *s_path, *p_path,
                  *cc,
                  product_path[256],
                  config_path[256],  
                  srch_path[256],
                  srch_path1[256],
                  user_path[256];

   /*
   **  set up search path
   */

   errflag = 0;
   status = get_modtype_data(EX_runname, NULL, NULL, srch_path, NULL, NULL);
   if (status == TRUE)
   {
      name = NULL;
      name = (struct EX_nl *) om$malloc(size=sizeof(struct EX_nl));
      strcat(srch_path, ":");
      strcpy(srch_path1, srch_path);
      cc = strchr(srch_path, ':');
      num = (int) cc - (int) srch_path;
      strncpy(name->name, srch_path, num);
      name->name[num] = '\0';
      name->next = NULL;
      name->prev = NULL;

      /* verify the first entry of srch_path */

      status = get_modtype_data(name->name, NULL, NULL, NULL, NULL, NULL);
      if (status != TRUE)
      {
         printf("In EX_set_search_path can not find %s entry in product data\n", name->name);
         return(status);
      }

      EX_get_dependency(srch_path, name);
      EX_rm_dup_dep(srch_path1, name);
      n1 = name;
      num_path = 0;
      while (n1 != NULL)
      {
         num_path++;
         n1 = n1->next;
      }

      user_path[0] = '\0';
      user_path_len = 0;

      /* get user specified path first */

      EX_get_user_srch_path(user_path);
      if (user_path[0] != '\0')
      {
         if (user_path[strlen(user_path)-1] != '/')
            strcat(user_path, "/");
         user_path_len = strlen(user_path);
      }
      stotal_len = ENTRY_SIZE * num_path + user_path_len;
      ptotal_len = stotal_len + user_path_len;
      s_path = om$malloc(size=stotal_len);
      p_path = om$malloc( size=ptotal_len);
      if (user_path_len == 0)
      {
         *s_path = '\0';
         *p_path = '\0';
      }
      else
      {
         strcpy(s_path, user_path);
         strcpy(p_path, user_path);
         if (user_path[user_path_len-1] != ':')
         {
            strcat(s_path, ":");
            strcat(p_path, ":");
         }
      }

      n1 = name;
      while (n1 != NULL)
      {
         status = get_modtype_data(n1->name, NULL, NULL, NULL,
            config_path, product_path);
         if (status == TRUE)
         {
            /* check existence of config directory */

            status = EX_check_file(config_path, TRUE);

            /*  if( status != 0) errflag = 1;   0 -- file is good */
            /*   if error ignore the entry   */

            if (!status)
            {
               /* get first product path */ 

               if (config_path[strlen(config_path)-1] != '/')
                  strcat(config_path, "/");
               if (product_path[strlen(product_path)-1] != '/')
                  strcat(product_path, "/");
               s_len = strlen(config_path);
               p_len = strlen(product_path);
               stotal_len -= s_len;
               ptotal_len -= p_len;
               if (stotal_len > 1)
                  strcat(s_path, config_path);
               else
               {
                  s_path = (char *) om$realloc(ptr=s_path,
                     size=strlen(s_path) + s_len + 1 );
                  if (s_path == NULL)
                     printf("error loading config path, realloc failed\n");
                  else
                     strcat(s_path, config_path);
               }
               if (ptotal_len > 0)
                  strcat(p_path, product_path);
               else
               {
                  p_path = (char *) om$realloc(ptr=p_path,
                     size=strlen(p_path) + p_len + 1);
                  if (p_path == NULL)
                     printf("error loading product path, realloc failed\n");
                  else
                     strcat(p_path, product_path);
               }
               strcat(s_path, ":");
               strcat(p_path, ":");
            }
         }
         else
            errflag = 0; /* original = 1; but for pdu, we do not error out */
                         /* just ignore the entry  */
         n2 = n1;
         n1 = n1->next;
         om$dealloc(ptr=n2);
      }
      EX_search_path = s_path;
      EX_product_path = p_path;
   }
   else
   {
      errflag = 1;
      printf(" In EX_set_search_path can not find <%s> entry in product data file\n",EX_runname);
      printf(" Please change product_data file\n\n");
   }
   return(errflag ? 0 : 1);
}


int EX_get_srch_path1(runname, flag, buff, size)
char  *runname;       /* product_name */
int   flag;           /* 0 condensed form ( dependency list ) */
                      /* 1 full unix dir path seperated by :  */
char  *buff;          /* place to put the result              */
int   *size;          /* on input size of buff,               */
                      /* on output                            */
		      /*  set to 0 if procuct name not found  */
                      /*  set to needed size if size too small*/
                      /* return 0 for fail                    */
		      /*        1 for success                 */
{
   int            s_len,
                  stotal_len,
                  p_len,
                  num,
                  num_path,
                  user_path_len,
                  status,
                  errflag,
                  cond_len,
                  tmp_len;
   struct EX_nl   *name,
                  *n1, *n2;    
   char           *s_path,
                  product_path[256],
                  config_path[256],  
                  srch_path[256],
                  srch_path1[256],
                  user_path[256],
                  *cc;

   buff[0] = 0;
   errflag = 0;
   status = get_modtype_data(runname, NULL, NULL, srch_path, NULL, NULL);
   if (status == TRUE)
   {
      name = NULL;
      name = (struct EX_nl *) om$malloc (size=sizeof(struct EX_nl));
      strcat(srch_path, ":");
      strcpy(srch_path1, srch_path);
      cc = strchr(srch_path, ':');
      num = (int) cc - (int) srch_path;
      strncpy(name->name, srch_path, num);
      name->name[num] = '\0';
      name->next = NULL;
      name->prev = NULL;

      /* verify the first entry of srch_path */

      status = get_modtype_data(name->name, NULL, NULL, NULL, NULL, NULL);
      if (status != TRUE)
      {
         *size = 0;
         return(status);
      }

      EX_get_dependency(srch_path, name);
      EX_rm_dup_dep(srch_path1, name);
      n1 = name;
      tmp_len = *size;
      *size = 0;
      if (flag == 0) /* need condensed list */  
      {   
         while (n1 != NULL)
         {
            strcat(buff, n1->name);
            strcat(buff, ":");
            cond_len = strlen(n1->name) + 1;
            *size += cond_len;
            if (*size > tmp_len) /* buff size not large enough */
               errflag = 1;
            n2 = n1;
            n1 = n1->next;
            om$dealloc(ptr=n2);
         }
         return(errflag ? 0 : 1);
      }

      n1 = name;
      num_path = 0;
      while (n1 != NULL)
      {
         num_path++;
         n1 = n1->next;
      }

      user_path[0] = '\0';
      user_path_len = 0;

      /* get user specified path first */

      EX_get_user_srch_path(user_path);
      if (user_path[0] != '\0')
         user_path_len = strlen(user_path);
      stotal_len = ENTRY_SIZE *  num_path + user_path_len;
      s_path = om$malloc(size=stotal_len);
      if (user_path_len == 0)
         *s_path = '\0';      
      else
      {
         strcpy(s_path, user_path);
         if (user_path[user_path_len-1] != ':')
            strcat(s_path, ":");
      }

      *s_path = '\0';      
      n1 = name;
      while (n1 != NULL) 
      {
         status = get_modtype_data(n1->name, NULL, NULL, NULL,
            config_path, product_path);
         if (status == TRUE)
         {
            /* check existence of config directory */

            status = EX_check_file(config_path, TRUE);

            /*  if( status != 0) errflag = 1;   0 -- file is good */
            /*   if error ignore the entry   */

            if (!status)
            {
               /* get first product path */ 

               if (config_path[strlen(config_path)-1] != '/')
                  strcat(config_path, "/");
               s_len = strlen(config_path);
               stotal_len -= s_len;
               if (stotal_len > 1 )
                  strcat(s_path, config_path);
               else
               {
                  s_path = (char *) om$realloc(ptr=s_path,
                     size=strlen(s_path) + s_len + 1 );
                  if (s_path == NULL)
                     printf("error loading config path, realloc failed\n");
                  else
                     strcat(s_path, config_path);
               }
               strcat(s_path, ":");
            }
         }
         else
            errflag = 0; /* original = 1; but for pdu, we do not error out */
                         /* just ignore the entry  */
         n2 = n1;
         n1 = n1->next;
         om$dealloc(ptr=n2);
      }    
      p_len = strlen(s_path);
      if (p_len < tmp_len)
         strcpy(buff, s_path);
      else
      {
         *size = p_len + 1;
         errflag = 1;          /* fail */ 
      }
      om$dealloc(ptr=s_path);
   }
   else
   {
      *size = 0;
      errflag = 1;
   }
   return(errflag ? 0 : 1);
}


int EX_getpath(index, path, len, type)
int   index, len, type;
char  *path;
{
   int   i, status, num;
   char  *start,
         *ended = NULL;
   char  *start1 = NULL;

   status = TRUE;
   start = EX_search_path;
   if (type == EX_PRODUCT_PATH)
      start = EX_product_path;
   for (i=0; i<= index ; i++)
   {
      ended = strchr(start, ':');
      if (ended == NULL)
      {
         status = FALSE;
         break;
      }
      start1 = start;  /* save start pointer     */
      start = ended + 1; /* prepare for next loop  */
   }
   if (status)
   {
      num = ended - start1;        
      if (num < len - 1)
      {
         strncpy(path, start1, num);
         if (path[num - 1]!='/')
            path[num++] = '/';
         path[num] = '\0';
      }
      else
      {
         status = FALSE;
         printf("IN ex$get_path, length of given path too short(%d), need %d \n",len,num+1); 
      }
   }
   return(status);
}


int EX_get_srch_path(path, num_entry)
char  **path;
int   *num_entry;
{
   /* Caller get EX_search_path & product count */

   char	*temp;

   *num_entry = 0;      /* Initialize count of products in search path */
   temp = EX_search_path; 
   while (*temp)
   {
      if (temp = strchr(temp, ':'))    /* Products are separated by ':' */
         ++(*num_entry);
      ++temp;
   }

   if (path)
      *path = EX_search_path;
   return(1);
}


int EX_set_search_path(path) /* called by NC */
char  *path;
{
   char *srch_path;
   int status;
   int len;

   status = 0;
   len = strlen(path);
   srch_path = om$malloc(size=len+10);
   if (srch_path != NULL )
   {
       strcpy(srch_path, path);
       if( *(srch_path+len - 1) != ':' )
       {
         strcat(srch_path,":");
       }

       if( old_EX_search_path != NULL )
       {
          om$dealloc(ptr=old_EX_search_path);
       }
       old_EX_search_path = EX_search_path;
       EX_search_path = srch_path;
       status = 1; 
   }
   return(status);
}


int EX_restore_search_path()  /* called by NC */
{
    int status;

    status = 0;
    if ( old_EX_search_path != NULL )
    {
       om$dealloc(ptr=EX_search_path);
       EX_search_path = old_EX_search_path;
       old_EX_search_path = NULL;
       status = 1;
    }
    return(status);
}
