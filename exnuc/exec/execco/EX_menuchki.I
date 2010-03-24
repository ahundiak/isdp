class implementation EX_menuchk;

#include <stdio.h>
#include <string.h>
#include <exmacros.h>
#include <execmsg.h>
#include <expriv.h>
#define debug 0
#define BUFSIZE 256
#define DDT(X)  

/***********************************************************************/
/************************* EX_funcky wakeup method *********************/
/***********************************************************************/

method wakeup(int pos)
{
    UI_message("Check Menu");
/*   ex$message(msgnumb = EX_M_PrintCmd); */
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_funcky execute method ********************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
%safe
  FILE *fp, *fp1, *fp2 = NULL;
%endsafe

  long msg;
  long lo, hi;
  int i, status, len, ppl_first;
  int line_num, found_flag;
  int resp, cmd_tbl_error_count = 0;
  int menu_error_count = 0;
  int entry_count, sym_num;
  int input_line_error, num_read;
  
  char file_name[256];
  char s[BUFSIZE];
  char keyin[80];
  char area[80];
  char menu_error[80];
  char tbl_error[80];
  char ppl_file[80];
  char ppl_file2[80];
  char blanks[130];
  char outline[130];
  char outline2[256];
  char *start_ptr, *end_ptr;
  
  struct EX_cmd *cmd, cmdstr;
  struct EX_cmd_cntrl *EX_menulist_ptr;
  struct EX_cmd_cntrl *cmd_cntrl;
  extern struct EX_cmd_cntrl *EX_cmdlist_ptr;
  
  cmd_cntrl = EX_cmdlist_ptr;
  strcpy(menu_error, "menu_error");
  strcpy(tbl_error,  "table_error");
  strcpy(ppl_file ,  "menucheck.u" );
  strcpy(ppl_file2 ,  "tablecheck.u" );
  
  ppl_first = 1;
  
  /* init menulist */
  EX_cmdinit( -1, &EX_menulist_ptr);
  ++(EX_menulist_ptr->reference_count);
  for( i=0; i < 130; blanks[i]=' ', i++);
  blanks[129] = '\0';



  
  file_name[0] = '\0';
  /* get menu dump file name */
  MS_dump_menus(file_name); 
  /*  strcpy( file_name,"/usr/tmp/menu_dump"); */
  

  if( file_name[0] == '\0') 
  {
     printf( "Error getting menu dump file\n");
     *response = TERMINATE;
     return(0);
  }

                            
  if ( ( fp = (FILE *) fopen ( file_name, "r" ) ) )
  {
      entry_count = 0;
      while ( fgets(s, BUFSIZE, fp) != NULL )
      { 
	   if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') || (s[0] == '\n'))
 			      continue;
	   ++entry_count;
      }
      if ( entry_count <= 0 )
      {
         printf("entry_count <= 0 in <%s>\n",file_name);
      }
      fclose(fp);
  }
  else
  {
     printf( "In EX_menuchk can not open <%s>\n",file_name);
     *response = TERMINATE;
     return(0);
  }
  /* load menu button entry */
  
  if ( ! ( cmd = ( struct EX_cmd *) 
		   malloc ( entry_count * sizeof ( struct EX_cmd ) ))) 
  {
	printf("no memory for menu button entry\n");
	UI_status("no memory for menu button entry");	
        *response = TERMINATE;
        return(0);
  }
  else
  {
      EX_menulist_ptr->no_of_cmd = 0;
      i = 0;
      status = TRUE;
               
      if ( ( fp = (FILE *) fopen ( file_name, "r" ) ))
      {
         line_num = 0;
         menu_error_count = 0;
	                
         if( ( fp1 = (FILE *) fopen( menu_error,"w") ))
         {

            while ( fgets(s, BUFSIZE, fp) != NULL )
	    { 
	       ++line_num;
	       if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') 
							   || (s[0] == '\n'))
         		   continue;
	      /* init cmd[i]  */
               input_line_error = 0;
               cmd[i].msg_key_ptr= NULL;
	       cmd[i].command_name_ptr=NULL;
	       cmd[i].command_key[0] = '\0';
	       cmd[i].class_name[0]='\0';
	       cmd[i].type=0;                    /* response */
	       cmd[i].exec_flag = 0;
	       cmd[i].immediate_flag = 0;
	       cmd[i].path = NULL;
	       cmd[i].input_string = NULL;
	       cmd[i].invis_cmd = 0;

             /* get response from menu dump file*/
               num_read = sscanf(s, "%d %*s", &resp);
	       if( num_read != 1 )
	       {
	          input_line_error = 1;
		  printf("%s error in line <%d>\n<%s>\n",file_name,line_num,s);
	       }


             /* get string */
               start_ptr = strchr(s,'"');
	       end_ptr   = strchr(start_ptr+1,'"');
               len = end_ptr - start_ptr - 1;

	       if ( len > 0 && start_ptr != 0 && end_ptr != 0 )
	       {
	          strncpy(keyin,start_ptr+1,len);
                  keyin[len] = '\0';
		}
		else
		{
                   input_line_error = 1;
		   printf("%s error in line <%d>\n<%s>\n",file_name,line_num,s);
		   keyin[0] = '\0';
		}

             /* get area name */
	        start_ptr = strchr( end_ptr+1,'"');
		end_ptr   = strchr( start_ptr+1,'"');
                len = end_ptr - start_ptr - 1;

 	        if ( len > 0  && start_ptr != 0 && end_ptr != 0 )
	        {
	          strncpy(area,start_ptr+1,len);
                  area[len] = '\0';
		}
		else
		{
                   input_line_error = 1;
		   printf("%s error in line <%d>\n<%s>\n",file_name,line_num,s);
		   area[0] = '\0';
		}

            /* get sym number */
               sym_num = -1;
               if( !input_line_error )
	       {
                   num_read = sscanf(end_ptr+1, "%d", &sym_num);
	           if( num_read != 1 )
	           {
	              input_line_error = 1;
                      printf("%s error in line <%d>\n<%s>\n",file_name,line_num,s);
	           }
	       }
               resp = resp & (~EX_HARDWARE_GENERATED);
	       cmd[i].type = resp;

	       if  ( resp == EX_CMD_KEY ) 
	       {
                  if ( strlen( keyin ) > 10 ) 
                  { 
	             if( menu_error_count == 0)
		     {
                 	fprintf( fp1,"%s\n\n\n","Following errors are found in menus " ) ; 
                        fprintf(fp1,"fields are:\n");
                        strcpy(outline,blanks);
                        strncpy(&outline[25], "<string>",8 );
                        strncpy(&outline[70], "<which area>",12);
                        strncpy(&outline[83], "<which symbol>",14);
                        fprintf(fp1,"%s\n\n",outline);
                     }
                     ++menu_error_count;
                     printf( "cmdkey too long -- %s",s); 
                     EX_print_menu_line( fp1,blanks, "cmdkey too long -- ",resp,keyin,area,sym_num); 
                  } 
                  strncpy( cmd[i].command_key,keyin,11); 
                  cmd[i].command_key[12] = '\0';
	       }
	       else
	       {
                  if ( strlen ( keyin ) > 55 ) 
                  { 
	             if( menu_error_count == 0)
		     {
                 	fprintf( fp1,"%s\n\n\n","Following errors are found in menus " ) ; 
                        fprintf(fp1,"fields are:\n");
                        strcpy(outline,blanks);
                        sprintf(&outline[25],"%s", "<string>" );
                        strncpy(&outline[70], "<which area>",12);
                        strncpy(&outline[83], "<which symbol>",14);
                        fprintf(fp1,"%s\n\n",outline);

                     }
                     ++menu_error_count;
                     printf ( "cmdname too long -- %s",s ); 
                     EX_print_menu_line( fp1,blanks, "cmdname too long -- ",resp,keyin,area,sym_num); 
                     fprintf ( fp1 , "cmdname too long -- %s",s ); 
                  } 
                  EX_cmdgetptr(keyin,&( cmd[i].command_name_ptr) ); 
	       }
             /* generate ppl file */
               if( ppl_first == 1 )
	       {
		  ppl_first = 0;
                  if( ( fp2 = (FILE *) fopen( ppl_file,"w") ))
                  {
		     fprintf( fp2,"%s\n","#include \"ciminimum.h\"\n#include \"cimacros.h\"");
		     fprintf( fp2,"%s\n","char filename[100];");
                     fprintf( fp2,"%s\n","extern int EX_ci_test_start();\n");
                     fprintf( fp2,"%s\n","extern int EX_ci_test_end();\n");
                     fprintf( fp2,"%s\n","main()\n{\n");
                     fprintf( fp2,"%s\n","message(\"Testing menu buttons\");");
                     fprintf( fp2,"%s\n","prompt(\"Key-in error logging file name >\");");
                     fprintf( fp2,"%s\n","ci$get(string = filename);");
                     fprintf( fp2,"%s\n","EX_ci_test_start( filename);\n");
		  }
		  else
		  { 
		     ppl_first = 2; /* error no output */
		     printf( "EX_menuchk can not open ppl file <%s> for write\n",ppl_file);
		  }
	       }
	       else if( ppl_first == 0 )
	       {
                 if ( resp == EX_CMD_KEY )
		 {
 sprintf(outline2,"  ci$put(cmd_key=\"%s\");",cmd[i].command_key);
                 }
		 else
		 {
 sprintf(outline2,"  ci$put(cmd=\"%s\");",cmd[i].command_name_ptr);
		 }
                 fprintf(fp2,"%s\n",outline2);
                 fprintf(fp2,"%s\n","  ci$put(response=TERMINATE);");
               }

               DDT(printf( "\n------%s",s ););  
               DDT(printf( "cmd-name = <%s>\n",cmd[i].command_name_ptr );); 
               DDT(printf( "cmd-key  = <%s>\n",cmd[i].command_key );); 
               DDT(printf( "before srch\n" );); 

	       found_flag = EX_cmdsrch( &msg, EX_cmdlist_ptr, keyin, &cmdstr,&resp);

               DDT(printf( "found_flag = <%d>\n",found_flag );); 

	       if( found_flag < 0 )
	       {
	           if( menu_error_count == 0)
		   {
                 	fprintf( fp1,"%s\n\n\n","Following errors are found in menus " ) ; 
                        fprintf(fp1,"fields are:\n");
                        strcpy(outline,blanks);
                        sprintf(&outline[25],"%s", "<string>" );
                        strncpy(&outline[70], "<which area>",12);
                        strncpy(&outline[83], "<which symbol>",14);
                        fprintf(fp1,"%s\n\n",outline);
                   }
		   printf("not found error -- %s",s);
                   EX_print_menu_line( fp1,blanks, "not found error -- ",resp,keyin,area,sym_num); 
		   ++menu_error_count;
	       }
	       ++i;
	       ++(EX_menulist_ptr->no_of_cmd);
	     } /* end while read */
             if( EX_menulist_ptr -> no_of_cmd != 0 ) 
             { 
                EX_menulist_ptr -> cmd = cmd ; 
             } 
           } /* end fp1 */
	   fclose(fp1);
	}
	if( menu_error_count == 0)
	{
	     unlink(menu_error);
	     printf(" no error found in menu\n");
	}
	else
	{
	     printf("\nMenu entries not found in command table are listed in file <%s>\n",menu_error);
	}
        if ( ppl_first == 0 )
	{
           fprintf(fp2,"%s\n","EX_ci_test_end();\n");
	   fprintf(fp2,"%s\n"," } ");
	   fclose(fp2);
	}
	fclose(fp);
     }

/*     EX_print_cmd1("menu_table",EX_menulist_ptr);  */

   /* now checking command table */
    ppl_first = 1;   
    
    if( ( fp1 = (FILE *) fopen( tbl_error,"w") ) )
    {
      /* generate ppl file */
       if( ppl_first == 1 )
       {
	  ppl_first = 0;
          if( fp2 = (FILE *) fopen( ppl_file2,"w") )
          {
	    fprintf( fp2,"%s\n","#include \"ciminimum.h\"\n#include \"cimacros.h\"");
            fprintf( fp2,"%s\n","char filename[100];");
            fprintf( fp2,"%s\n","extern int EX_ci_test_start();\n");
            fprintf( fp2,"%s\n","extern int EX_ci_test_end();\n");
            fprintf( fp2,"%s\n","main()\n{\n");
            fprintf( fp2,"%s\n","message(\"Testing command tables\");");
            fprintf( fp2,"%s\n","prompt(\"Key-in error logging file name >\");");
            fprintf( fp2,"%s\n","ci$get(string = filename);");
            fprintf( fp2,"%s\n","EX_ci_test_start( filename);\n");
	  }
	  else
	  { 
	    ppl_first = 2; /* error no output */
	    printf( "EX_menuchk can not open ppl file <%s> for write\n",ppl_file2);
	  }
	}


       lo = 0;
       hi = EX_cmdlist_ptr -> no_of_cmd;
       cmd_cntrl = EX_cmdlist_ptr ; 
       resp = EX_CMD_KEY;
       cmd_tbl_error_count = 0;
       for( i = lo; i < hi; ++i )
       {
          if( cmd_cntrl->cmd[i].invis_cmd == 0 )
	  {   
              if( ppl_first == 0 )
              {
 sprintf(outline2,"  ci$put(cmd_key=\"%s\") ;",cmd_cntrl->cmd[i].command_key);
                 fprintf(fp2,"%s\n",outline2);
                 fprintf(fp2,"%s\n","  ci$put(response=TERMINATE);");
              }

            strcpy( keyin, cmd_cntrl->cmd[i].command_key);
            DDT(printf( "\n-----cmd-key  = <%s>\n",cmd_cntrl->cmd[i].command_key );); 
            DDT(printf( "before srch\n" );); 

	    found_flag = EX_cmdsrch( &msg, EX_menulist_ptr,keyin,&cmdstr, &resp);
            
            DDT(printf( "found_flag = <%d>\n",found_flag );); 

            if( found_flag < 0 )
	    {
	       if( cmd_tbl_error_count == 0)
	       {
	         fprintf(fp1,"%s\n\n","Following command table entries are not referenced by menu button");
                 fprintf(fp,"fields are:\n");
	         strcpy(outline,blanks);
                 strncpy(outline, "<class_name>", 12 );
                 strncpy(&outline[20], "<msg_key>",9 );
	         strncpy(&outline[50], "<command_key>", 13);
	         strncpy(&outline[70], "<command_name>",14);
                 fprintf(fp,"%s\n\n",outline);
               }	     
	       strcpy(outline, blanks);
	       strncpy(outline, cmd_cntrl->cmd[i].class_name, strlen(cmd_cntrl->cmd[i].class_name) );	  	  	  
               if( cmd_cntrl->cmd[i].msg_key_ptr == NULL)
	       {
	           strncpy( &outline[20],"------------",12);
	       }
	       else
	       {
                  strncpy(&outline[20], cmd_cntrl->cmd[i].msg_key_ptr, strlen(cmd_cntrl->cmd[i].msg_key_ptr) );
	       }
               if( strlen(cmd_cntrl->cmd[i].command_key) == 0)
	       {
	          strncpy( &outline[50],"------------",12);
	       }
	       else
	       {
                  strncpy(&outline[50], cmd_cntrl->cmd[i].command_key, strlen(cmd_cntrl->cmd[i].command_key) );
	       }
	       strncpy(&outline[70], cmd_cntrl->cmd[i].command_name_ptr, strlen(cmd_cntrl->cmd[i].command_name_ptr) );
               printf("%s\n",outline);
               fprintf(fp1,"%s\n",outline);
               ++cmd_tbl_error_count;
            }
	  }
        }
        if ( ppl_first == 0 )
	{
           fprintf(fp2,"%s\n","EX_ci_test_end();\n");
	   fprintf(fp2,"%s\n"," } ");
	   fclose(fp2);
	}

     }
     fclose(fp1);
     if( menu_error_count == 0)
     {
         printf(" no error found in menu\n");
     }
     else
     {
        printf("\nMenu entries not found in command table are listed in file <%s>\n",menu_error);
     }

     if( cmd_tbl_error_count == 0)
     {
         unlink(tbl_error);
         printf("No error found in command table\n");
     }
     else
     {
         printf("Entries of command table not referenced by menu are listed in file <%s>\n",tbl_error);
     }
     *response = TERMINATE;
     return(1);
}

int EX_print_cmd1( file_name , cmd_cntrl)
char *file_name;
   struct EX_cmd_cntrl *cmd_cntrl;
{
%safe
   FILE        *fp;
%endsafe

   IGRlong     lo;
   register long   hi;
   register int    i;
   char blanks[130];
   char outline[130];


   for ( i=0; i<130; blanks[i] = ' ', i++);   
   blanks[129] = '\0';

   lo = 0;
   hi = cmd_cntrl->no_of_cmd;

   if (! ( fp = (FILE *) fopen ( file_name, "w" )))
   {
       printf("In EX_print_cmd error opening %s\n",file_name);
       return(0); 
   }
   else
   {
       fprintf(fp,"fields are:\n");
	  strcpy(outline,blanks);
	  strncpy(outline, "<class_name>", 12 );
	  strncpy(&outline[20], "<msg_key>",9 );
	  strncpy(&outline[50], "<command_key>", 13);
	  strncpy(&outline[70], "<command_name>",12);

       fprintf(fp,"%s\n\n",outline);
       
       for ( i = lo; i < hi; ++i )
       {
	  strcpy(outline, blanks);
	  strncpy(outline, cmd_cntrl->cmd[i].class_name, strlen(cmd_cntrl->cmd[i].class_name) );	  	  	  
          if( cmd_cntrl->cmd[i].msg_key_ptr == NULL)
	  {
	     strncpy( &outline[20],"------------",12);
	  }
	  else
	  {
             strncpy(&outline[20], cmd_cntrl->cmd[i].msg_key_ptr, strlen( cmd_cntrl->cmd[i].msg_key_ptr) );
	  }
          if( strlen(cmd_cntrl->cmd[i].command_key) == 0)
	  {
	     strncpy( &outline[50],"------------",12);
	  }
	  else
	  {
             strncpy(&outline[50], cmd_cntrl->cmd[i].command_key, strlen(cmd_cntrl->cmd[i].command_key) );
	  }
	  strncpy(&outline[70], cmd_cntrl->cmd[i].command_name_ptr, strlen(cmd_cntrl->cmd[i].command_name_ptr) );
          fprintf(fp,"%s\n",outline);
      }
      fclose(fp);
   }
   return(1);
}

int EX_print_menu_line( fp, blanks, reason, resp, keyin, area, sym_num)
FILE *fp;
char *blanks;
char *reason;
int resp;
char *keyin;
char *area;
int sym_num;
{
   char outline[130];
   char num[8];
	  strcpy(outline, blanks);
	  strncpy(outline, reason,strlen(reason));	  	  	  
	  sprintf( num,"%d",resp);
	  strncpy( &outline[20],num,strlen(num));
          strncpy( &outline[25], keyin, strlen(keyin) );
	  strncpy( &outline[70], area, strlen(area) );
          sprintf( &outline[83], "%d",sym_num);
          fprintf(fp,"%s\n",outline);

   return(1);
}


end implementation EX_menuchk;
