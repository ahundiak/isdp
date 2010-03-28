#include <stdio.h>
#include <sys/types.h>
#include <sys/dir.h>
#include <fcntl.h>


#define STRINGSIZE 256
#define printhelp fprintf(stderr,"%s: <cmd list file> <input dir> [-s <output dir> [-l <log file>]\n",argv[0])



struct keystruct
{
   char type;
   char cmd_key[80];
   union 
   {
      char sub_key[80];
      char version[80];
   } action;
} ;

char *pathcat(char *, char *);
void read_filenames(char *sourcedir, char *files[], int *num_files);
void read_cmd_keys(struct keystruct [], int *, char *);
int isdotu(char *file);

main (int argc, char *argv[])
{
   struct keystruct keys[500];
   char sourcefile[STRINGSIZE], sourcedir[STRINGSIZE], targetdir[STRINGSIZE], logfile[STRINGSIZE];
   FILE *inputfd=0, *logfd=0;
   char *files[1000],line[STRINGSIZE];
   int num_keys, num_files, filecount, line_count,cmd_count,update=0;

   /* parse the command line */

   if ((argc != 3) && (argc != 5) && (argc != 7))
   {
      printhelp;
      exit(0);
   }
   else
   {
      int i=3; 

      strncpy(logfile,"./check_cmds.log",STRINGSIZE);

      /* grab source file name and input directory */

      strncpy(sourcefile, argv[1], STRINGSIZE);
      strncpy(sourcedir, argv[2], STRINGSIZE);

      while (i<argc)
      {
	 switch ( argv[i][0] )
	 {
	   case '-' :
	   {
	      switch ( argv[i][1] )
	      {
		 case 's' :
		 {
		    strncpy(targetdir,argv[i+1],STRINGSIZE);
		    i+=2;
		    update=1;
		    break;
		 }
		 case 'l' :
		 {
		    strncpy(logfile,argv[i+1],STRINGSIZE);
                    i+=2;
		    break;
		 }
		 default :
		 {
		    printhelp;
		    exit(0);
		    break;
		 }
	      } /* switch argv[i][1] */
	      break;
	   }
	   default :
	   {
	      printhelp;
	      exit(0);
	      break;
	   }

	} /* switch argv[i][0] */
     } /* while */
   } 

   /* Open up the input and log files */

   if (( inputfd = fopen(sourcefile,"r") ) == NULL)
   {
      fprintf(stderr,"Cannot open %s\n",sourcefile);
      exit(0);
   }

   if (( logfd = fopen(logfile,"w") ) == NULL)
   {
      fprintf(stderr,"Cannot open %s, logging to standard out\n",logfile);
      logfd=stdout;
   }
   
   read_cmd_keys(keys, &num_keys, sourcefile);
   read_filenames(sourcedir,(char **) files, &num_files);

   for (filecount=0;filecount<num_files;filecount++)
   {
      FILE *fd_in, *fd_out=0;

      if (( fd_in = fopen(pathcat(sourcedir,files[filecount]),"r") ) == NULL)
      {
	 fprintf(stderr,"Cannot open %s\n",pathcat(sourcedir,files[filecount]));
	 continue;
      }
      
      if (update)
      {
	 if (( fd_out = fopen(pathcat(targetdir,files[filecount]),"w") ) == NULL)
	 {
	    fprintf(stderr,"Cannot open %s\n",pathcat(targetdir,files[filecount]));
	    continue;
	 }
      }

      fprintf(logfd,"\n%s\n",files[filecount]);
      line_count=1;

      while ( fgets(line, STRINGSIZE, fd_in) )
      {
	 char *ptr;
	 int changed=0;

	 for (cmd_count=0;cmd_count<num_keys;cmd_count++)
	 {
	    if (ptr=(char *)strstr(line, keys[cmd_count].cmd_key))
	    {
	       switch (keys[cmd_count].type)
	       {

		  case 'R' : 
		     fprintf(logfd,"\tline %5i\t%s\tRetired\n",line_count,keys[cmd_count].cmd_key);
		     break;
		  case 'V' :
		     fprintf(logfd,"\tline %5i\t%s\tScheduled for retirement in %s\n",line_count,keys[cmd_count].cmd_key,keys[cmd_count].action.version);
		     break;
		  case 'S' :
		     if (fd_out)
		     {
			char *p1,string1[1024];
			int i=0;

			p1=line;

			while (p1!=ptr)
			{
			   string1[i++]=*p1++;
			}

			string1[i]='\0';
			strcat(string1,keys[cmd_count].action.sub_key);

			while (isalnum(*ptr)||(*ptr=='_'))
			{
			  ptr++;
		        } 

			strcat(string1,ptr);

			fprintf(fd_out,"%s",string1);
			changed=1;
			fprintf(logfd,"\tline %5i\t%s\tChanged to %s\n",line_count,keys[cmd_count].cmd_key,keys[cmd_count].action.sub_key);
		     }
		     else
			fprintf(logfd,"\tline %5i\t%s\tRetired - Substitute Available\n",line_count,keys[cmd_count].cmd_key);
		     break;
	       }
	    }
	 }
	 if (changed)
	    changed=0;
	 else if (fd_out)
	    fprintf(fd_out,"%s",line);
         line_count++;
      }
      fclose(fd_in);
      if (fd_out) fclose (fd_out);
   } /* end of loop of file names */
   if (logfd!=stdout) fclose(logfd);
}

void read_cmd_keys( struct keystruct keys[], int *num_keys, char *filename)
{
   FILE *fd;
   int rtn, line_no=1;
   *num_keys=0;

   if (!(fd = fopen(filename,"r")))
   {
       fprintf(stderr,"read_cmd_keys: Cannot open %s\n",filename);
       exit(0);
   }
   
   while ((rtn=fscanf(fd,"%1s",&keys[*num_keys].type)) != EOF)
   { 
     int err=0;
     switch (keys[*num_keys].type)
     {
	case 'R': err=fscanf(fd,"%s",&keys[*num_keys].cmd_key); err -=1; break;
	case 'S': err=fscanf(fd,"%s%s",&keys[*num_keys].cmd_key,&keys[*num_keys].action.sub_key); err -=2; break;
	case 'V': err=fscanf(fd,"%s%s",&keys[*num_keys].cmd_key,&keys[*num_keys].action.version); err -=2; break;
	default : break;
      }
      if (err)
      {
	 fprintf(stderr, "Error near line %i parsing %s\n", line_no, filename);
      }
      else (*num_keys)++;
      line_no++;
   }

   fclose(fd);
}

void read_filenames(char *sourcedir, char *files[], int *num_files)
{
   struct direct d;
   int fd;

   *num_files=0;

   if ((fd = open(sourcedir,O_RDONLY)) < 0)
   {
      fprintf(stderr,"Cannot find %s\n",sourcedir);
      exit(0);
   }

   while (read(fd, (char *)&d, sizeof(d))==sizeof(d))
     if (d.d_ino != 0)
     {
	if (strcmp(d.d_name,".")&&strcmp(d.d_name,"..")&&isdotu(d.d_name))
	{
	   char *p;
	   p = (char *) malloc(FILENAME_MAX * sizeof(char));
	   strncpy(p,d.d_name, FILENAME_MAX);
	   files[(*num_files)++] = p;
	}
     }

     close(fd);
     return;
}

char *pathcat(char *string1, char *string2)
{
   char *p, s[1024];

   s[0]='/';
   s[1]='\0';

   p = (char *) malloc(1024);

   strcpy(p,string1);

   return (char *)strcat(p,strcat(s,string2));
}

int isdotu(char *file)
{
   int i;
   char string[FILENAME_MAX+1];

   strncpy(string,file, FILENAME_MAX);
   i=strlen(string);

   return ((file[i-1]=='u')&&(file[i-2]=='.'));
}
