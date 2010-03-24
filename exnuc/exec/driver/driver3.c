#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <ipcl.h>
#include <errno.h>
#include <string.h>
#include "exsysdep.h"

extern void  *malloc(); /* Changed type to void JWW 2-Jun-92 */
extern void  free();

#define lowbyte(w)   ((w) & 0377)
#define highbyte(w)  lowbyte((w) >> 8)
#define TOCHILD_MTYP 888
#define APP_MTYP     555
#define DEL_MTYP     444
#define REDIR_INPUT   1
#define REDIR_OUTPUT  2
#define CREATE_PIPE   4

struct pnode
{
   int pid;
   struct pnode *next;
};

struct pipenode
{
   char np[80];
   struct pipenode *next;
};

key_t IGE_msgqkey;

char  msg_qid[20] = "DRIVERQID=";
char  np1_envname[30];
char  np2_envname[30];

int   pkgpid, childpid, qid;
int   wait_flag;

static struct pnode     *cpid_list = 0;
static struct pipenode  *pipe_list = 0;


static char *tindex(str, pattern)
char  *str, *pattern;
{
   register char *s, *p;

   for( ; *str != '\0'; str++)
   {
      for (s = str, p = pattern; *p != '\0' && *p == *s; p++, s++) ;
      if (*p == '\0')
         return(str);
   }
   return(0);
}


void add_pipe( phead, filename)
struct pipenode   **phead;
char              *filename;
{
   struct pipenode *t;

   t = *phead;
   while ((t != NULL) && strcmp(filename, t->np))
   {
      t = t->next;
   }

   if (t == NULL)
   {
      t = (struct pipenode *) malloc(sizeof(struct pipenode));
      strcpy(t->np, filename);
      t->next = *phead;
      *phead = t;
   }
}


void clean_pipe (phead)
struct pipenode **phead;
{
   struct pipenode  *t;

   while (*phead != NULL)
   {
      t = *phead;
      unlink( t->np );
      *phead = (*phead)->next;
      free((char *) t);        
   }
}


void igesegv()
{
   if (pkgpid > 0) /* we got a child out there */
   {
      kill(pkgpid, SIGTERM);  
      driver_clean_up();
      exit(1);
   }
}


void igeintr()
{
   if (pkgpid > 0) /* we got a child out there */
   {
      driver_clean_up();
      exit(1);
   }
}
void igehup()
{
   void     clean_pid();
   if (pkgpid > 0) /* we got a child out there */
   {
      clean_pid(&cpid_list);
      driver_clean_up();
      IPCL_exit();
      exit(1);
   }
}


void igecld()
{
   int    status, code, pid, retu;
   struct forkresp
   {
      long  mtype;
      int   status;
      int   errno;
      int   childpid;
   } buf1;
   void     clean_pid();
   void     del_pid();
    
   status = 0; 
   pid = wait(&status);
   if (pkgpid == pid) /* package dead */
   {
      if ((code = lowbyte(status)) == 0)
      {
         code = highbyte(status);
      }
      else
      {
         if ((code == 0177))
         {
            code = highbyte(status);
         }
      }

      clean_pid(&cpid_list);
      driver_clean_up();
#if defined (SUNOS5) || defined (IRIX5)
IGE_rm_sem();
#else
      IPCL_exit();
#endif
      exit(code);
   }
   else
   {
      signal(SIGCLD, (void (*)()) igecld);
      del_pid( &cpid_list, pid);
      if (pid == childpid)
      {
         if (wait_flag)
	 {
            buf1.status = 1;
            buf1.errno = status;
            buf1.mtype = TOCHILD_MTYP;
            retu = msgsnd(qid, (struct msgbuf *) &buf1,
               (sizeof(struct forkresp) - sizeof(long)), 0);  
            wait_flag = 0;
            if ( retu == -1)
            {
               perror("ERROR:IN sigcld send msg to wait process");
               printf("errno = %d\n",errno);
            }
         }

         if (lowbyte(status) != 0)
         {
            if ((code = status & 0177) < 19)
            {
               printf("signal %d rcvd by child",code);
            }
            if ((status & 0200) == 0200)
            {
               printf("-core dumped");
            }
	    printf("\n");
         }
      }
   }
}


/*****************************************************************************/
/* This code commented out 12/08/92 by GLC in version 2.2 with the advent of */
/* full libxc support of dynamic loading.  Code has been retained here for   */
/* future reference should the need arise.				     */
/*****************************************************************************/
#if 0
#if defined(_SUNOS)
/*****************************************************************************/
/* The following supports LD_PRELOAD for dynamic loading on SUN workstations */
/* only.  This code may go away if a better method comes along later.        */
/*****************************************************************************/

#include <sys/param.h>
#include <dirent.h>
#include <hash.h>
#include <vla.h>

extern char *stralloc ();

struct prod {
              struct prod *next;
              char        *run_name;
              char        *srch_path;
              char        *config_path;
              short        dep;        /* dependent nodes (index in "dep")   */
              short        files;      /* dload file list (index in "flist") */
              short        fcnt;       /* number of dload files              */
              short        visit;      /* have we been here?                 */
};

struct prod       *EX_product_list;
struct prod        root;
char             **flist;
vla(struct prod *) dep;
int                ndx = 0;          /* next alloc from dep */
int                rndx;             /* "ndx" before rid_ghosts */
int                visit_val = 2;    /* value for first visit */
char               dir[MAXPATHLEN];
char		  *ldenv;
int		   ldlen, ldalloc;
int		   show_preloads = 0; /* set to non-zero to print files */


#define  LDINC  256


int EX_read_product_data()
{
   FILE		*fp;
/*   int               index;*/
   struct prod	**prodDef;
   char		*pdata, *ptr, *eol,
		*fname = NULL;
   char		*sep = " \t";   /* seperator string for strtok */
   char		buff[MAXPATHLEN];
   struct stat	statbuf;

   /* See if user has specified an alternate product_data file */

/*   if (!(fname = getenv("EXPRODUCTDATA")))*/
   {
      strcpy(&buff[0], "/usr/ip32/product_data");  /* Default file name */
      fname = &buff[0];
   }
   if (stat(fname, &statbuf) == -1)
   {
      fprintf(stderr, "IGEstartup: stat system call failed for <%s>\n",
         fname);
      perror("");
      return(0);
   }
   if (!(fp = (FILE *) fopen(fname, "r")))
   {
      fprintf(stderr, "IGEstartup: could not open <%s>\n", fname);
      perror("");
      return(0);
   }
   if (!(pdata = (char *) malloc(statbuf.st_size + 1)))
   {
      fprintf(stderr, "IGEstartup: could not allocate %d bytes for product info.\n",
         statbuf.st_size + 1);
      fclose(fp);
      return(0);
   }

   /* Read all of the product_data file */

   if (fread(pdata, 1, statbuf.st_size, fp) != statbuf.st_size)
   {
      fprintf(stderr, "IGEstartup: could not read <%s>.\n", fname);
      fclose(fp);
      return(0);
   }
   fclose(fp);
   pdata[statbuf.st_size] = '\0';  /* To halt runaway strchr calls */
/*   if (!(EX_product_data_info = (char *) calloc(statbuf.st_size, 1)))
   {
      fprintf(stderr, "IGEstartup: could not allocate %d bytes for product info.\n",
         statbuf.st_size);
      return(0);
   }
   index = 0;
*/

   prodDef = &EX_product_list;
   for (ptr = pdata; eol = strchr (ptr, '\n'); ptr = eol + 1) {
     *eol = '\0';
     if (*ptr == '#')
       continue;

     if (ptr = strchr (ptr, '"')) {
       char *run_name    = strtok (++ptr, "\"");
       char *logo        = strtok (0, sep);
       char *module      = strtok (0, sep);
       char *srch_path   = strtok (0, sep);
       char *config_path = strtok (0, sep);

       if (run_name && logo && module && srch_path && config_path) {

         /* allocate a node */

         if (!((*prodDef) = (struct prod *)
                      calloc(sizeof(struct prod), 1))) {
           fprintf(stderr, "IGE_startup: Could not allocate product definition structure\n");
           return(0);
         }
         (*prodDef)->next = NULL;

         /* fill in info */

         if (config_path[strlen (config_path) - 1] != '/') {
           strcpy (buff, config_path);
           strcat (config_path = buff, "/");
         }
         if ( !((*prodDef)->run_name    = stralloc (run_name))    ||
              !((*prodDef)->srch_path   = stralloc (srch_path))   ||
              !((*prodDef)->config_path = stralloc (config_path))    ) {
           fprintf(stderr, "IGE_startup: Could not allocate a string.\n");
           return(0);
         }

         /* point to next */

         prodDef= &(*prodDef)->next;
       }
     }
   }

   free(pdata);  /* Unverified copy of product_data file */
   return(1);
}


static char **get_dload_files (directory, argv, argcp)
char  *directory,
      **argv;
int   *argcp;
{
   DIR            *dirp;
   struct dirent  *dp;
   int            len;
   int            nbytes;
   int            argc = *argcp;
   char           buff[MAXPATHLEN];

   if (dirp = opendir (directory))
   {
      strcpy(buff, directory);
      strcat(buff, "/");
      nbytes = strlen(buff);
      while (dp = readdir(dirp))
      {
         len = strlen (dp->d_name);

#if defined(_CLIX)
         if (len >= 2 && 'o' == *(dp->d_name + len-1) && '.' ==
            *(dp->d_name + len-2))
         {
#elif defined(_SUNOS)
         if (len >= 3 && 'o' == *(dp->d_name + len-1) && 's' ==
            *(dp->d_name + len-2) && '.' == *(dp->d_name + len-3))
         {
#endif

            strcpy(&buff[nbytes], dp->d_name);
            if (!(++argc % 20))
               argv = (char **)realloc (argv, (argc + 20) * sizeof (char *));
            strcpy(argv[argc - 1] = (char *) malloc(strlen(buff) + 1), buff);
         }
      }
      closedir(dirp);
   }

   argv[*argcp = argc] = 0;
   return argv;
}

/**********************************************************************/
/***** FOR DEBUGGING ONLY

void print_them (prod)

struct prod *prod;
{
    int cnt, ndx;

    printf ("\n====================================================\n");
    printf ("run_name    = %s\n", prod->run_name);
    printf ("srch_path   = %s\n", prod->srch_path);
    printf ("config_path = %s\n", prod->config_path);
    printf ("fcnt        = %d\n", prod->fcnt);
    printf ("visit       = %d\n", prod->visit);
    ndx = prod->dep;
    printf ("DEPENEDCIES:\n");
    while (Vdat(dep)[ndx])
      printf ("\t%s\n", Vdat(dep)[ndx++]->run_name);
    ndx = prod->files;
    cnt = prod->fcnt;
    printf ("FILE LIST:\n");
    while (cnt--)
      printf ("\t%s\n", flist[ndx++]);

    ndx = prod->dep;
    while (Vdat(dep)[ndx])
      print_them (Vdat(dep)[ndx++]);
}

*************************************************************/

void rid_ghosts (prod)

struct prod *prod;
{
  struct prod *sib;
  int          sibndx;
  int          save_ndx;

  prod->visit = visit_val;
  save_ndx    = ndx;
  for (sibndx = prod->dep; sib = Vdat(dep)[sibndx]; sibndx++) {
    if (sib->visit < visit_val)
      if (sib->fcnt)
        (Vndx(dep,ndx++) = sib)->visit = visit_val;
      else rid_ghosts (sib);
  }

  if (prod->fcnt || prod == &root) {
    Vndx(dep,ndx++) = 0;
    prod->dep = save_ndx;
    visit_val++;
    for (sibndx = prod->dep; sib = Vdat(dep)[sibndx]; sibndx++)
      if (sib->dep < rndx)
        rid_ghosts (sib);
  }
}


void build_list (prod, depth)

struct prod *prod;
int          depth;
{
  struct prod *sib;
  int          ndx, cnt;

  for (ndx = prod->dep; sib = Vdat(dep)[ndx]; ndx++)
    if (sib->visit < visit_val)
      build_list (sib, depth + 1);

  if (depth > 1) {
    prod->visit = visit_val;
    for (cnt = prod->fcnt, ndx = prod->files; cnt--; ndx++) {
      int need = strlen (flist[ndx]) + 1;

      if (ldlen + need > ldalloc)
        ldenv = (char *)realloc (ldenv, ldalloc += need + LDINC);
      if (show_preloads)
        printf ("%s\n", flist[ndx]);
      strcpy (&ldenv[ldlen], flist[ndx]);
      ldenv[ldlen += need] = '\0';
      ldenv[ldlen - 1]     = ' ';
    }
  }
}


do_ldpreload ()
{
  struct prod *prod;
  HASHTABLE   *htab;
  int          fcnt = 0;

  EX_read_product_data ();
  flist = (char **)malloc (20 * sizeof (char *));
  ldenv = (char *)malloc (ldalloc = LDINC);
  strcpy (ldenv, "LD_PRELOAD=");
  ldlen = strlen (ldenv);

  /* construct hash table on the run name */

  htab = hashinit (struct prod, 100, hashc, strcmp, run_name, INDKEY | NOMEM);
  for (prod = EX_product_list; prod; prod = prod->next) {
    hashadd (htab, prod, 0);
    prod->visit = 0;
  }

  /* build the dependency graph */

  Vinit (dep, 50, 50);
  for (prod = EX_product_list; prod; prod = prod->next) {
    char *colon;
    char *ptr = strchr (prod->srch_path, ':');

    strcpy (dir, prod->config_path);
    strcat (dir, "config/dload/init");
    prod->files = fcnt;
    flist = get_dload_files (dir, flist, &fcnt);
    prod->fcnt = fcnt - prod->files;

    prod->dep = ndx;
    while (ptr) {
      if (colon = strchr (++ptr, ':'))
        *colon = '\0';
      if (Vndx(dep,ndx) = (struct prod *)hashlookup (htab, ptr))
        Vdat(dep)[ndx++]->visit = 1;
      ptr = colon;
    }
    Vndx(dep,ndx++) = 0;
  }

  /* make a dependency list for the "root" nodes (this allows for a consistent
     traversal algorithm) */

  root.dep  = rndx = ndx;
  for (prod = EX_product_list; prod; prod = prod->next)
    if (!prod->visit) {
      Vndx(dep,ndx++) = prod;
      prod->visit = 1;
    }
  Vndx(dep,ndx++) = 0;

  /* get rid of "ghost" nodes and then build the dload file list */

  rid_ghosts (&root);
  visit_val++;
  build_list (&root, 0);

  printf ("%s\n", ldenv);
  putenv (ldenv);
}
/*****************************************************************************/
#endif
#endif

main(argc,argv)
int argc;
char *argv[];
{
   int   sid, i, j, len, min,
         newargc, num_ptr;
   char  *newargv[100];    /*argument for package ex: ems */
   char  *temp, *first_ptr, *second_ptr,
         *blank,
         *start,
         *o_ptr[10],
         *bptr, *cptr, *dptr, *fptr, *sptr,
         *tt;
   char  omipcl[50],
         qid_char[10];

   if(argc < 2)
   {
      printf("USAGE:  drive package [ arguments for package ]\n");
      exit(1);
   }

   /* Create a message queue that will be used to communicate between
    * this drive process and the processes it forks (Model & stop sign
    * process).  First generate a unique message queue key based on
    * process id, then add a large number to it to (we hope) make the
    * queue id unique from other message queue ids on the system.
    */

   IGE_msgqkey = (key_t) (1296600000 + getpid());
   if( (qid = IGE_set_msgque()) == -1 )
   { 
      printf("IGE driver cannot set up msg queue\n");
      exit(1);
   }

   /* create semaphore */
   if( (sid = IGE_set_sem()) == -1 )
   { 
      printf("IGE driver cannot set up semphore\n");
      driver_clean_up();
      exit(1);
   }

   sprintf(qid_char,"%d",qid);
   strcat(msg_qid,qid_char);
   if( putenv( msg_qid ) !=0 )
   {
      printf("IN IGEdriver unable to put qid env\n");
      driver_clean_up();
      IGE_rm_sem();
      exit(1);
   }

   /* now to create package child process */

   signal(SIGINT, SIG_IGN);
   signal(SIGCLD, (void (*)()) igecld);
   signal(SIGSEGV,(void (*)()) igesegv);
   signal(SIGHUP,(void (*)()) igehup);
   pkgpid = -1;

   argc--;
   argv++;
  
   if (!(pkgpid = fork()))
   {
      /* reconstruct argument in case -C specified */
      for( i = 0 , len = 0; i < argc; ++i )
      {
         len += strlen(argv[i]);
      }
      temp = (char *) malloc(len+argc+1);
      if ( temp )
      {
         *temp = '\0';
         strcat( temp,argv[0]);
         for( i = 1 ; i < argc ; ++i )
         {
            strcat(  temp," ");
            strcat( temp,argv[i]);
         }
      }      

      /* extract -C  argument */

      first_ptr = tindex( temp," -C" );
      second_ptr = first_ptr;
      if( first_ptr == 0 )   /* no -C flag */
      {
         newargc = argc;
         for( i=0; i < argc; ++i )
         {
            newargv[i] = argv[i];
         }
      }
      else   /* -C specified */
      {
         /* now is the arguments before -C */
         newargc = 0;
         blank = 0;
         start = temp;
         j = 0;
         while (  blank < first_ptr )
         { 
            blank = strchr(start,' ');
            if ( blank != 0 )
            {
               if ( blank <= first_ptr)
               {
                  *blank = '\0';
                  newargv[newargc] = start;
                  ++newargc;
                  start =  ++blank;
               }
            }
            else
            {
               newargv[newargc] = start;
               ++newargc;
               blank = first_ptr ;  /* stop the while loop */
            }	       
         }

         /* now is the -C argument */
         newargv[newargc] = first_ptr+1; 
         ++newargc;
         if( *(first_ptr+3) == ' ')
         { 
            *(first_ptr+3) = '\0';
            second_ptr =first_ptr + 4;
            newargv[newargc] = second_ptr;
            ++newargc;
         }

         for(i=0;i<5;++i) o_ptr[i] = 0;

         /* now the arguments after -C string */       
         /* if there is any -c .... stuff     */
         /* put in o_ptr array and sort it    */
	
         num_ptr = 0;
         bptr = tindex(second_ptr," -b");
         if( bptr )   o_ptr[num_ptr++] = bptr;
         cptr = tindex(second_ptr," -c");
         if( cptr )   o_ptr[num_ptr++] = cptr;
         dptr = tindex(second_ptr," -d");
         if( dptr )   o_ptr[num_ptr++] = dptr;
         fptr = tindex(second_ptr," -f");
         if( fptr )   o_ptr[num_ptr++] = fptr;
         sptr = tindex(second_ptr," -s");
         if( sptr )   o_ptr[num_ptr++] = sptr;

         /* use selection sort of all the ptrs */
         for( i= 0; i< num_ptr - 1 ; ++i)
         {
            min = i;
            for( j = i+ 1; j< num_ptr; ++j)
            {
               if ( o_ptr[j] < o_ptr[min] ) 
               {
                  tt = o_ptr[min];
                  o_ptr[min] = o_ptr[j];
                  o_ptr[j] = tt;
               }
            }
         }
         blank = o_ptr[0];
         if( blank != 0 )
         {
            *blank = '\0';
            ++blank;
         }

         /* process arguments after -C argument string */

         while (blank != 0 )  /* more argumenus */
         {
            newargv[newargc]=blank;
            ++newargc; 
            blank=strchr(blank,' ');
            if (blank) *blank++ = '\0';
         }
         newargv[newargc] = 0;
      }

      sprintf(omipcl, "OMipcl=%d", (int) IGE_msgqkey);
      newargv[newargc] = omipcl;
      newargv[newargc+1] = '\0';

#if 0
      do_ldpreload ();
#endif
      execvp( newargv[0], newargv );
      printf("unable to execvp <%s>\n",newargv[0]);
      perror("execvp 1 failed");
      driver_clean_up();
      IGE_rm_sem();
      exit(1);
   }
   else if (pkgpid == -1)
   {
      perror("driver fork 1 failed"); 
      driver_clean_up();
      IGE_rm_sem();
      exit(1);
   }

   while(1)
   {
      IGEdriver_waitmsg(qid);
   }
}



int IGEdriver_waitmsg(qid)
int qid;
{

#define MAX_MSG    512
#define DELIM_LEN  7
#define DELIM      "_D_e_L_"

   int status,len, i;
   int oldmask=0;
   struct  forkmsg
   {
      long mtype;
      int  wait_flag;
      int  redir_io;
      int  mask;      /* child umask val */
      int  argc;
      int  delete_flag;
      char np1[80];   /* named pipe to be created */
      char np2[80];   /* named pipe to be created */
      char mtext[512];     
   } buf;
   struct  forkresp
   {
      long mtype;
      int  status;
      int  errno;
      int  childpid;
   } buf1;

   char  *pp1, *pp2, *getenv();
   char  *ptr, *ptr1;
   char  *cargv[50];  /* argument for child process ex: stopproc */
   int   fd1, fd2;
   int   dmtyp;
   int   retu;
   int   goahead;

   void add_pid();

/*   strcpy(np1_envname, "NAMEDPIPE1");
   strcpy(np2_envname, "NAMEDPIPE2");   
*/
   np1_envname[0] = np2_envname[0] = NULL;

   dmtyp = -(IPCL_MTYP);
   len = sizeof(struct forkmsg) - sizeof(long);
   status = msgrcv( qid, &buf, len, dmtyp, 0);
   if ( status != -1)
   {
      /* rcvd fork msg , set up fork */

      if ( buf.mtype == IPCL_MTYP )
      {
         struct IPCL_msgbuf *pipcl;
         pipcl = (struct IPCL_msgbuf *) &buf;
         IPCL_deathrow( pipcl );
      }
      else if( buf.mtype == DEL_MTYP )
      {
         IGE_rm_sem();
      }
      else   /* should check buf.mtype == APP_MTYP , but that will */
             /* make old app image can not use the new driver      */
      {
         ptr1 = buf.mtext;
         for ( i = 0 ; i < buf.argc; i++)
         {
            cargv[i] =  ptr1;
            ptr = tindex(ptr1,DELIM);  
            ptr1 = ptr + DELIM_LEN;
            *(--ptr) = '\0';
         }
         cargv[i] = '\0';

         if ( buf.mask != -1 )
            oldmask = umask(buf.mask);

         if ( (buf.wait_flag) && !(buf.redir_io) ) 
         {
            wait_flag = buf.wait_flag;
         }
         if ((buf.redir_io & CREATE_PIPE) == CREATE_PIPE )
         {
            char *filename;
            char *equal_sign;

            if (buf.np1[0] != '\0')    /* Named pipe specified */
            {
               equal_sign = strchr(buf.np1, '=');
               if ( equal_sign )
               {
                  *equal_sign = '\0';
                  filename = ++equal_sign;

                  while( *filename == ' ')
                     filename++; 
                  while( *(--equal_sign) == ' ' )
                     *equal_sign = '\0';

                  status = create_pipe(buf.np1, filename); /* create, putenv , add to list */
                  if( status ) 
                  {
                     if ((buf.redir_io & REDIR_INPUT) == REDIR_INPUT )
                     {
                        strcpy(np1_envname,buf.np1);
                     }
                  }
                  else
                  {
                     printf("In IGEdriver can not create pipe <%s> ",filename);
                     perror(" ");
                     return(-1);
                  }
               }
            }
            if (buf.np2[0] != '\0')    /* Named pipe specified */
            {
               equal_sign = strchr(buf.np2, '=');
               if( equal_sign )
               {
                  *equal_sign = '\0';
                  filename = ++equal_sign;
                  while( *filename == ' ') filename++; 
                  while( *(--equal_sign) == ' ' ) *equal_sign = '\0';

                  status = create_pipe(buf.np2, filename); /* create, putenv , add to list */
                  if(status ) 
                  {
                     if ((buf.redir_io & REDIR_OUTPUT) == REDIR_OUTPUT )
                     {
                        strcpy(np2_envname,buf.np2);
                     }
                  }
                  else
                  {
                     printf("In IGEdriver can not create pipe <%s> ",filename);
                     perror(" ");
                     return(-1);
                  }
               }
            }
         }

         switch(childpid = fork())
         {
            case -1:
               if ( buf.mask != -1 )  buf.mask =  umask(oldmask);
	       buf1.status = 0;
	       buf1.errno = errno;
	       buf1.mtype = TOCHILD_MTYP;
	       buf1.childpid = 0;
	       retu = msgsnd( qid,(struct msgbuf *)&buf1,
                  (sizeof(struct forkresp) - sizeof(long)), 0);
	       if( retu == -1)
	       {
		 perror("In waitmsg msgsnd return fork status error");    
	       }
               perror("fork other child failed");
               return -1;
    
            case 0:  
               goahead = 1;
	       buf1.status = 1;  /* 1 for success */
	       buf1.errno = 0;   /* 0 for no error */
	       buf1.mtype = TOCHILD_MTYP;
	       buf1.childpid = getpid();
               
	       /* check the existence of image */
	       retu = access( cargv[0],1); /* check for executable */
	       if  ( retu == -1 )
	       {
	           /* file is not there or not executable */
		   buf1.status = 0;
		   buf1.errno = errno;
		   printf("IN driver can not access <%s> \n",cargv[0]);
		   perror("ERROR :");
                   goahead = 0;
	       }
	           	   
	       retu = msgsnd(qid, (struct msgbuf *) &buf1,
                  (sizeof(struct forkresp) - sizeof(long)), 0);
	       if (retu == -1)
	       {
		  perror("In waitmsg msgsnd child return fork status");    
	       }
    
               if (goahead == 0) return(-1);
	       
	       if ((buf.redir_io & REDIR_INPUT) == REDIR_INPUT)
	       {
		  if (pp1 = getenv(np1_envname))
		  {
    
                     /* open named pipe 1 for read */

                     fd1 = open(pp1,O_RDONLY);
                     if(fd1 == 0)
                     {
                        perror("In waitmsg child cannot access pipe NP1");
                        exit(4);
                     }
                     if( close(0) == -1 )
                     {
                        perror("IN child can not close 0");
                        exit(7);
                     }
                     if( dup(fd1) == -1)
                     {
                        printf("IN waitmsg child can not dup 0\n");
                        exit(8);
                     }
                     if( close(fd1) == -1)
                     {
                        printf("IN waitmsg can not close fd0 or fd1\n");
                     }
                  }
	       }  /* end of redir input*/
	       if ((buf.redir_io & REDIR_OUTPUT) == REDIR_OUTPUT)
	       {
		  if (pp2 = getenv(np2_envname))
		  {
                     /* open named pipe 2 for write */

                     fd2 = open(pp2,O_WRONLY | O_TRUNC);

                     if (fd2 == 0)
                     {
                        perror("In waitmsg child cannot access pipe NP2");
                        exit(4);
                     }

                     if (close(1) == -1)
                     {
                        perror("IN child can not close 1");
                        exit(7);
                     }
                     if (dup(fd2) == -1)
                     {
                        printf("IN waitmsg child can not dup 1\n");
                        exit(8);
                     }
                     if (close(fd2) == -1)
                     {
                        printf("IN waitmsg can not close fd1 or fd2\n");
                     }
                  }
	       }  /* end of redir output */

	       retu = execvp(cargv[0],cargv);
	       if (retu == -1)
	       {
		  printf("IN driver execvp <%s> failed\n",cargv[0]);
		  perror("ERROR :");
	       }
	       break;

            default:   /* parent paress */
               if ( buf.mask != -1 )  buf.mask =  umask(oldmask);
	       break;
         } /* end of switch */
         if (buf.delete_flag != 0 ) add_pid( &cpid_list,   childpid );
      }
   }
   return(1);
}


void add_pid( phead, i)
struct pnode **phead;
int i;
{
   struct pnode *t;
   
   t = *phead;
   while ( t!= NULL && t->pid != i )
   {
	t = t->next;
   }

   if( t == NULL )
   {
       t= ( struct pnode *) malloc( sizeof(struct pnode) );
       t->pid = i;
       t->next = *phead;
       *phead = t;
   }
}

void del_pid( phead, i)
struct pnode **phead;
int i;
{
   struct pnode *t, *temp;

   if ( *phead != NULL )
   {
      if( (*phead)->pid == i )
      {
          temp = *phead;
          *phead = (*phead) -> next;
	  free( (char *) temp);
      }
      else
      {
         t = *phead;
         while( t->next != NULL && t->next->pid != i)
         {
            t = t->next;
         }
         if ( t->next != NULL )
         {
            temp = t->next;
            t->next = t->next->next;
            free( (char *) temp);
         }
      }
   }
}


void clean_pid (phead)
struct pnode **phead;
{
   struct pnode  *t;
   while ( *phead != NULL )
   {
      t = *phead;
      kill(t->pid, SIGTERM);
      *phead = (*phead)->next;
      free( (char *) t);        
   }
}

int driver_clean_up()
{
   clean_pipe(&pipe_list);
   IGE_rm_msgque();
   return(1);
}



int create_pipe ( env, filename )
char *env, *filename;
{
   register char  *string; 
   int            status, retstat;

   retstat = 1;

   status = mknod(filename, 0666 | S_IFIFO,0);
   if (status != 0)
   {
      unlink(filename);
      status = mknod(filename, 0666 | S_IFIFO,0); /* create brand new */
      if(status != 0)
         retstat = 0;
   }
   if (retstat != 0)     /* created, now putenv */
   {
      string = (char *) malloc( strlen (env) + strlen(filename) + 10 );
      if ( string != NULL )
      {
         strcpy(string,env);
         strcat(string,"=");
         strcat(string,filename);

         status = putenv( string );
         if ( status !=0 )
         {
            retstat = 0;
            unlink(filename);
         }
         else   /* add to pipe list */
         {
            add_pipe(&pipe_list,filename);
         }
      }
      else
      {
         retstat = 0;
         unlink(filename);
      }
   }
   return(retstat);
}
