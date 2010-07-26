/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME        EX_cmdattach
 
     Abstract:          This function takes a module type and a table of
                        command table control information as input, reads
                        the command table file and loads the corresponding
                        command index table and command table.

-----
%SC%

        status = EX_cmdattach ( &msg, module_type, &cmd_cntrl )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

     module_type IGRlong         - module type.

   *cmd_cntrl struct EX_cmd_cntrl - command control table.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        - return code:
                                   EXSUCC - succeeded.
                                   EXe_mod_type - error module type.
                                   EXe_cmd_cntrl_addr - error in command
                                                        control table addr.
                                   EXe_cmd_file - error in command file
                                                        name.
                                   EXe_no_cmdmem - no memory available.
                                   EXe_empty_file - command file is empty.

   *cmd_cntrl struct EX_cmd_cntrl - command control table.


     value =    TRUE if succeeded
                FALSE if failed.


----*/
/*EH*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <igrtypedef.h>
#include <OMminimum.h>
#include <ex.h>
#include <exdef.h>
#include <expriv.h>
#include <exmacros.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <exlanguage.h>
#include <exlocale.h>
#include <UMS.h>
#include <exproto.h>
#define debug 0
#define BUFSIZE   256

extern char                   CS_path_name[];
extern struct EX_cmd_cntrl    *EX_cmdlist_ptr;
extern struct EXevent_queue   *event_queue_front;
extern struct EXevent_queue   *event_queue_back;

extern struct diacritic       *EX_diacritic;
extern int                    EX_ndiacritic;
IGRint EX_cmdattach ( msg, module_type, cmd_cntrl )

IGRlong         *msg;
IGRlong         module_type;
struct EX_cmd_cntrl **cmd_cntrl;

{
    FILE        *fp, *fp1, *lang_fp;
    IGRint  status , line_num, msgnum;
    IGRlong     i , j;
    IGRlong     cmd_count,total_cmd_count;
    IGRchar     file_name[257];
    IGRchar     f_name[257];
    IGRchar     mystring[80];
    IGRchar     path[80],language[80],lang_path[257];
    IGRchar     s[BUFSIZE];
    struct EX_cmd *cmd;

    struct EX_cmd_cntrl *cmd_list;     /* ptr to current entry */
    struct EX_cmd_cntrl *prevcmd;      /* ptr to previous entry */

    char *start,*end , *tmpptr, *outstr, *outpath, *new_line;
    int line_not_end;

    char *del;
    char *cmd_string, cmdbuf[56];
    int  mystatus;
    int  debug_flag, diacritic_found;
    int nbytes, no_real_commands;

    CSclear_cache();/*clear the command cache*/
    status = FALSE;
    debug_flag = 0;
    if ( EX_cmdlist_ptr == NULL )
    { 
      /* first link in list */
      EX_cmdinit(module_type,&cmd_list);
      EX_cmdlist_ptr = cmd_list;
      *cmd_cntrl = EX_cmdlist_ptr;
      ++(*cmd_cntrl)->reference_count;
    }
    else
    {   
     /* search through link list for command table to see if already there */
        cmd_list = EX_cmdlist_ptr;
        while (cmd_list->mod_type != module_type)
         {
           if (cmd_list->next !=0 )
              cmd_list = cmd_list->next;
           else
            {
           /* create entry in link list to create table */
              prevcmd = cmd_list;
              EX_cmdinit(module_type,&cmd_list);
              prevcmd -> next = cmd_list;
            } 
         } /* while not correct module_type */
        *cmd_cntrl = cmd_list;
        ++(*cmd_cntrl)->reference_count;
    }

 if ((*cmd_cntrl)->reference_count==1)
 {
    diacritic_found = 0;    
    status = TRUE;
    total_cmd_count = 0;
    for( j=0; status == TRUE; j++)
    {
        if( status = ex$get_path(index=j,path=path,len= sizeof(path) ) )
	{
	    strcpy(f_name,path);
	    strcat(f_name,"config/");
	    strcpy(file_name, f_name);
	    strcat(file_name, "cmd_tbl_list");

        if ( !diacritic_found )
         {
         EX_inq_language(language);
         strcpy(lang_path,f_name);
         strcat(lang_path,language);
         strcat(lang_path,"/flscharmap");
         if ( ( lang_fp = fopen ( lang_path , "r") ) )
           {
           while ( fgets ( s,BUFSIZE,lang_fp ) != NULL )
            {
            if ( s[0] != '#' )
            EX_ndiacritic++;
            }
           fseek ( lang_fp, 0 , 0 );/*position to top*/
           if ( ! ( EX_diacritic = ( struct diacritic *) 
		       malloc ( EX_ndiacritic * sizeof ( struct diacritic ) ))) 
             {
	         printf("no memory for diacritic table\n");
	         status = FALSE;
	         *msg = EXe_no_cmdmem;
             }
           else
             {
             EX_ndiacritic = 0;
             while ( fgets ( s,BUFSIZE,lang_fp ) != NULL )
              {
              if ( s[0] == '#' )continue;
              EX_diacritic[EX_ndiacritic].diacritic = s[0];
              new_line = strchr ( s , '\n' );
              if ( new_line )
                {
                *new_line = 0;
                }
              new_line = strchr ( s , ' ' );/*look for blank*/
              if (!new_line ) continue;
              else new_line++;
              
              EX_diacritic[EX_ndiacritic].nbytes = strlen ( new_line );
              if (EX_diacritic[EX_ndiacritic].nbytes > EX_MAX_DIACRITIC)
                      EX_diacritic[EX_ndiacritic].nbytes = EX_MAX_DIACRITIC;
              strncpy ( EX_diacritic[EX_ndiacritic].lower_char, new_line,
                                    EX_MAX_DIACRITIC );            
              EX_ndiacritic++;
              }
            diacritic_found = TRUE;
            fclose ( lang_fp );
           }/*end if have memory*/
          }/*end if diacritic table found*/
         }

	    if ( ( fp1 = fopen ( file_name, "r" )))
	    {
                while( fgets(s, BUFSIZE, fp1) != NULL )
		{
		    if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') 
							   || (s[0] == '\n'))
         			   continue;

		    mystring[0] = '\0';
		    strcpy(file_name, f_name);
                    sscanf( s,"%s",mystring);
		    if ( mystring[0] == '/' )
		    {
		      strcpy(file_name,mystring);
		    }
		    else
		    {
		      strcat(file_name, mystring);
		    }

		    if ( ( fp = fopen ( file_name, "r" ) ) )
		    {

			cmd_count = 0;
			while ( fgets(s, BUFSIZE, fp) != NULL )
			{ 
			   if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') || (s[0] == '\n'))
 			      continue;
			   ++cmd_count;
			}
			if ( cmd_count <= 0 )
			{
			    printf("cmd_count <= 0 in <%s>\n",file_name);
			}
			total_cmd_count += cmd_count;
			fclose(fp);
		    }
                }
		fclose(fp1);
	    }

	}
    }/* end for each path */

    if ( total_cmd_count <= 0 )
    {
	printf("cmd_count <= 0\n");
	status = FALSE;
	*msg = EXFAIL;
	return(status);
    }
    no_real_commands = total_cmd_count;
    if ( ! ( cmd = ( struct EX_cmd *) 
		   malloc ( total_cmd_count * sizeof ( struct EX_cmd ) ))) 
    {
	printf("no memory for cmd\n");
	status = FALSE;
	*msg = EXe_no_cmdmem;
    }
    else
    {
      (*cmd_cntrl)->no_of_cmd = 0;
      i = 0;
      status = TRUE;
      for( j=0; status == TRUE; j++)
      {
	if( status = ex$get_path(index=j ,path=path,len=sizeof(path) ) )
	{
	    strcpy(f_name,path);
	    strcat(f_name,"config/");
	    strcpy(file_name, f_name);
	    strcat(file_name, "cmd_tbl_list");

	    if ( ( fp1 = fopen ( file_name, "r" )))
	    {
/*  printf("\nreading  <%s>\n",file_name);            */
                while( fgets(s, BUFSIZE, fp1) != NULL )
		{
		    if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') 
							   || (s[0] == '\n'))
         			   continue;
		     
		    mystring[0] = '\0';
		    strcpy(file_name, f_name);
                    sscanf( s,"%s",mystring);
		    if ( mystring[0] == '/' )
		    {
		      strcpy(file_name,mystring);
		    }
		    else
		    {
		      strcat(file_name, mystring);
		    }

		   if ( ( fp = fopen ( file_name, "r" ) ))
		   {
/*  printf("\nAttaching <%s>\n",file_name); */

		      EX_cmdgetptr(path, &outpath);
	
		      line_num = 0;               
		      while ( fgets(s, BUFSIZE, fp) != NULL )
		      { 
			 ++line_num;
			 line_not_end = 1;
			 if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') 
							   || (s[0] == '\n'))
         			   continue;
	    
			/* init cmd[i]  */

			cmd[i].msg_key_ptr= NULL;
			cmd[i].command_name_ptr=NULL;
			cmd[i].command_key[0] = '\0';
			cmd[i].class_name[0]='\0';
			cmd[i].type=0;
			cmd[i].exec_flag = 0;
			cmd[i].immediate_flag = 0;
			cmd[i].path = NULL;
			cmd[i].input_string = NULL;
                        cmd[i].invis_cmd = 0;
                        cmd[i].dload_name_ptr = NULL;
				    
			/* get command_name  */
			if( line_not_end )
			{
                           if ( s[0] == '^' )
			   {
			   	start = &s[1];
			   	end = &s[1];
                                cmd[i].invis_cmd = 1;
			   }
			   else
			   {
				start = s;
				end = s;
			   }
	    
			   for(;*end != ',' && *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
			   if (*start == '"')
			   {
				tmpptr = end;
				start++;
				*(--tmpptr) = '\0';
			        nbytes = strlen(start);
			        EX_cmdgetptr(start, &cmd_string);
                    mystatus = UMS_S_SUCCESS;
			   }
			   else
			   {
				/* no double quotes , translate from msgfile */
				cmdbuf[0] = '\0';

                msgnum = strtol(start,(char **)NULL,0);
                          
				mystatus = MSget_message(msgnum, &cmd_string, 
				            &nbytes);


				if ( mystatus != UMS_S_SUCCESS )
				{
				   printf("\nIn cmdserver attach, message key %s not found in message files\n",start);
				}
			   }
			   cmd[i].command_name_ptr =  cmd_string;
  		           cmd[i].command_nbytes =  nbytes;
			}
			else
			{
			    printf("command table line %d missing fields 1\n",line_num);
			}
          if ( mystatus == UMS_S_SUCCESS )
           {	    
	    
			/* get command_key  */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   for(;*end != ',' &&  *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
			   strncpy(cmd[i].command_key, start,10);
			   cmd[i].command_key[10]='\0';

			}
			else
			{
			    printf("command table line %d missing fields 2\n",line_num);
			}
	    
			/* get class_name  */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   for(;*end != ',' && *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
			   strncpy(cmd[i].class_name, start,12);
			   cmd[i].class_name[12]='\0';

 			}
	    
			/* get type  */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   for(;*end != ',' && *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
           		   if( start != end )cmd[i].type =
                                strtol(start,(char **)NULL,0);

	 		}		 
		     
			/* get exec_flag  */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   for(;*end != ',' && *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
			   if( start != end )cmd[i].exec_flag = atoi(start);

			}		 

			/* get immediate_flag  */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   for(;*end != ',' && *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
			   if( start != end )cmd[i].immediate_flag = atoi(start);

			}		 


			/* get input_string  */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   del = start;
                           if( *del == '\n' ) line_not_end = 0;
                           if( *del != ',' && line_not_end )
			   {
 			      end++;
			      if( *end == '\n') line_not_end = 0;
                              if( line_not_end )
			      { 
			        for(;*end != *del && *end != '\n' && *end != ','; end++);
			        if( *end == '\n') line_not_end = 0;
			        *end++ = '\0';
			        if( *end == '\n') line_not_end = 0;
			        strcpy(mystring,start+1);
			        EX_cmdgetptr(mystring, &outstr);
			        cmd[i].input_string = outstr;
			      }
                           }
			}
			/* get dload_name */
			if( line_not_end )
			{
			   end++;
			   start = end;
			   for(;*end != ',' && *end != '\n'; end++);
			   if( *end == '\n') line_not_end = 0;
			   *end = '\0';
                           if( start != end )
			   {
			     strcpy(mystring,start);
			     EX_cmdgetptr(mystring, &outstr);
			     cmd[i].dload_name_ptr = outstr;
			   }
			}
			 

			/* get path  */	     
			cmd[i].path = outpath;
	
if( debug_flag )
{
 printf( "\nmsg_key=<%s>\ncommand_name=<%s>\ncommand_key=<%s>\nclass_name=<%s>\n",
			       cmd[i].msg_key_ptr,
			       cmd[i].command_name_ptr,
   			       cmd[i].command_key,
			       cmd[i].class_name);
 printf( "type=<%d>\nexec_flag=<%d>\nimmediate_flag=<%d>\npath=<%s>\ninput_string=<%s>\ninvis_cmd=<%d>\ndload_name=<%s>\n",
			       cmd[i].type,
			       cmd[i].exec_flag,
			       cmd[i].immediate_flag,
			       cmd[i].path,
  			       cmd[i].input_string,
			       cmd[i].invis_cmd,
			       cmd[i].dload_name_ptr);
}
			   
			 ++i;
			(*cmd_cntrl)->no_of_cmd++;
          }/*end if have a valid command*/
		 } /* while read table */
		      fclose(fp);
	
	   } /* open command table */

                } /* while read cmd_tbl_list */
		fclose(fp1);
	    } /* end open cmd_tbl_list */
	}  /* get path */

      }/* end for each path */

      if ( (*cmd_cntrl)->no_of_cmd  != 0 )
      {
	  (*cmd_cntrl)->reference_count = 1;
	  (*cmd_cntrl)->cmd = cmd;
	  status = TRUE;
	  *msg = EXSUCC;
      }
      else
      {
	  (*cmd_cntrl)->cmd = NULL;
	  (*cmd_cntrl)->cmd_ndx = NULL;
	  free ( cmd );
	  *msg = EXe_empty_file;
	  status = FALSE;
      }
    }
  } /* malloc success create new table */
  else
  {
     /* table already exist */
     status = TRUE;
     *msg = EXSUCC;
  }

  return ( status );
} /* end EX_cmdattach */




/*--------------------------------------------*/

int EX_file_create_list( entry , num_of_entry )
char **entry;      /* array of pointers to command string */
int *num_of_entry; /* on input is the size or entry,
                      on output is the number of entries found  */
/* return 1 for success, 0 fail */
{
   struct EX_cmd_cntrl *cmd_cntrl;

   IGRlong     lo;
   register long   hi;
   register int    i;
   int num_found;


   cmd_cntrl = EX_cmdlist_ptr;
   num_found = 0;
   lo = 0;
   hi = cmd_cntrl->no_of_cmd;

   for ( i = lo; i < hi; ++i )
   {
      if(( (cmd_cntrl->cmd[i].exec_flag & EX_FCREATE) == EX_FCREATE )   
        && (cmd_cntrl->cmd[i].invis_cmd == 0 ) )
      {
/*
          printf("IN create_list <%x> <%s>\n",  cmd_cntrl->cmd[i].command_name_ptr,
				   cmd_cntrl->cmd[i].command_name_ptr);
*/

        num_found++;
	  if (num_found > *num_of_entry) /* array size not large enough */
	  {
	     return(0);
	  }
          else
	  {
	      entry[num_found - 1] = cmd_cntrl->cmd[i].command_name_ptr;
	  }
      }
   }
   *num_of_entry = num_found;
   return(1);
}





int EX_shutdowncmd ( cmd_cntrl )

struct EX_cmd_cntrl *cmd_cntrl;
{
   IGRlong     lo;
   register long  hi;
   register int   i;
   long msg;
   long num_byte;
   int status;
   int resp;
   struct EXevent_queue *evq_front;
   struct EXevent_queue *evq_back;   

   evq_front = event_queue_front;
   evq_back = event_queue_back;   
   event_queue_front = NULL;
   event_queue_back  = NULL;

   lo = 0;
   hi = cmd_cntrl->no_of_cmd;

   for ( i = lo; i < hi; ++i )
   {
      if( (cmd_cntrl->cmd[i].exec_flag & EX_SHUTDOWN) == EX_SHUTDOWN )   
      {
	  num_byte = sizeof(cmd_cntrl->cmd[i].command_key) + 1;
	  resp = EX_CMD_KEY;
	  status = ex$putque( msg = &msg,
			      pos=BACK,
       			      response=&resp ,
			      byte=&num_byte,
			      buffer=cmd_cntrl->cmd[i].command_key ); 
	  if( ! (1&status))
	  {
 	     printf("IN cmdserver attach.C can not put q shutdown cmd %s\n",
				   cmd_cntrl->cmd[i].command_name_ptr);
	  }
      }
   }

   if( evq_front != NULL )
   {
      if(event_queue_back != NULL && event_queue_front != NULL)
      {
	event_queue_back->next = evq_front;
	evq_front->prev = event_queue_back;
	event_queue_back = evq_back; 
      }
      else
      {
        event_queue_front = evq_front ;
        event_queue_back  = evq_back;
      }
   }

   return(1);
} /* EX_shutdowncmd */      

static char cmd_buffer[UMS_MAX_BUFLEN];

int EX_get_cmd_info( string, mode, cmdstr)
char *string;
int mode;
struct EX_cmd  *cmdstr;
{

    long  msg;
    int   found_flag;
    int   resp;    
    int   ret;
    struct EX_cmd cmd;
    char  keyin[1024];  /*max char allowed from input queue*/
    char *where_equal_is;

    where_equal_is = strchr(string, '=');

    if ( where_equal_is != NULL )
    {
        ret = where_equal_is - string;
        if ( ret > 1023 )
             ret = 1023;
        strncpy( keyin,string , ret);
        keyin[ret] = '\0';
    }
    else
    {
        ret = strlen(string);
        if ( ret > 1023 )
             ret = 1023;
        strncpy(keyin,string,ret);
        keyin[ret] = '\0';
    }

    found_flag = 0;
    ret = 1;
    resp = mode;
    found_flag = EX_cmdsrch(&msg,EX_cmdlist_ptr,keyin,&cmd,&resp);
    if( found_flag >= 0)
    {
        if( cmdstr != NULL )
  	     {
            *cmdstr = cmd;
            cmdstr->command_name_ptr = &cmd_buffer[0];            
            strncpy(cmd_buffer,cmd.command_name_ptr,cmd.command_nbytes);
            cmd_buffer[cmd.command_nbytes] = 0;
	     }
        ret = 1;
    }
    else ret = 0;
    return(ret);
}



int EX_print_cmd( file_name )
char *file_name;
{
   struct EX_cmd_cntrl *cmd_cntrl;
    FILE        *fp;
   IGRlong     lo;
   register long   hi;
   register int    i;
   char blanks[130];
   char outline[130];
#define  SECOND_COL      16
#define  THIRD_COL       36
#define  FOURTH_COL      56


   for ( i=0; i<130; blanks[i] = ' ', i++);   
   blanks[129] = '\0';
   cmd_cntrl = EX_cmdlist_ptr;

   lo = 0;
   hi = cmd_cntrl->no_of_cmd;

   if (! ( fp = fopen ( file_name, "w" )))
   {
       printf("In EX_print_cmd error opening %s\n",file_name);
       return(0); 
   }
   else
   {
       fprintf(fp,"fields are:\n");
	  strcpy(outline,blanks);
	  strncpy(outline, "<class_name>", 12 );
          strncpy(&outline[SECOND_COL], "<dload_name>",12 );
	  strncpy(&outline[THIRD_COL], "<command_key>", 13);
	  strncpy(&outline[FOURTH_COL], "<command_name>",14);


       fprintf(fp,"%s\n\n",outline);
       
       for ( i = lo; i < hi; ++i )
       {
          if( cmd_cntrl->cmd[i].invis_cmd == 0 )
	  {
	      strcpy(outline, blanks);
	      strncpy(outline, cmd_cntrl->cmd[i].class_name, strlen(cmd_cntrl->cmd[i].class_name) );	  	  	  

              if(cmd_cntrl->cmd[i].dload_name_ptr == NULL )
	      {
    	         strncpy(&outline[SECOND_COL], "                    ",20 );
	      }
	      else
	      {
    	         strncpy(&outline[SECOND_COL], cmd_cntrl->cmd[i].dload_name_ptr, strlen(cmd_cntrl->cmd[i].dload_name_ptr) );
	      }
	      if( strlen(cmd_cntrl->cmd[i].command_key) == 0)
	      {
		 strncpy( &outline[THIRD_COL],"------------",12);
	      }
	      else
	      {
		 strncpy(&outline[THIRD_COL], cmd_cntrl->cmd[i].command_key, strlen(cmd_cntrl->cmd[i].command_key) );
	      }

	      strncpy(&outline[FOURTH_COL], cmd_cntrl->cmd[i].command_name_ptr, 
                              cmd_cntrl->cmd[i].command_nbytes );
	      fprintf(fp,"%s\n",outline);
          }
      }
      fclose(fp);
   }
   return(1);
}





static   char *tmp_dload_name;
/*static    char **argv; */
static    char *argv[10];   

#define ONESPACE 0
#define SAMECASE 0
    
EX_dload_setup( dload_name_ptr, argv_ptr, argc_ptr)
char *dload_name_ptr;
char ***argv_ptr;
int *argc_ptr;
{
  int i;
  int arg_count;
  char *start,*end;


    i = strlen(dload_name_ptr);
    if( i < 1 ) return(0);

    tmp_dload_name = (char *)malloc( i+1 );
    strcpy(tmp_dload_name,dload_name_ptr);
    EX_clean_str(tmp_dload_name, ONESPACE,SAMECASE);

    arg_count = 1;
    start = tmp_dload_name;
    while(*start != '\0')
    {
        if( *start++ == ' ' ) ++arg_count;
    }
    if ( arg_count > 10 )
     {
     arg_count = 10;
     printf ("dload - only 10 files allowed for loading per command\n");
     }
    *argc_ptr = arg_count;       


    /* argv = (char ** )malloc( sizeof(start) * (arg_count+1) ); */
    start = tmp_dload_name;
    end = start; 
    for ( i = 0; i< *argc_ptr; ++i)
    {
        for(;*end != ' ' && *end != '\0'; end++);
        *end = '\0';
	argv[i] = start;
        argv[i+1] = (char *)0;
	start = ++end;
    }
    *argv_ptr = argv;
    return(1);
}


EX_dload_free()
{
   /*free(argv);*/
   free(tmp_dload_name);
   return(1); 
}
