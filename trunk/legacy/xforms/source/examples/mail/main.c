#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <fcntl.h>
#include <X11/Xlib.h>
#include <FI.h>

#define NUM_NAMES 250

/* Main form */

#define NAME  	  11
#define ADDRESS   12
#define NAME_LIST 13
#define SEL_ALL   14
#define UNSEL_ALL 15
#define PATH      23
#define FILE_NAME 24
#define FILE_LIST 25
#define MAILING   26
#define SUB_FORM  27


/* Sub form */

#define SUBJECT   13
#define HEADER    14


Display		*display;

Form form;
Form subform;
int  names;

char current_dir[300];
char header[210];
char subject[210];

struct
  {
    char name[30];
    char address[50];
  } mail_table[NUM_NAMES];


#define QUESTION  100
#define DIRECTORY 101
#define C_CODE    102
#define EMPTY     103
#define SYMBOL    104
#define A_FORM    105
#define ASCII     106
#define EXEC      107
#define OBJECT    108


int get_file_type ( file )
  char *file;
{
	struct stat buf;

	int	fptr;
	int 	type = 0;

	/* Open the file */

	if ( ( fptr = open ( file, O_RDONLY ) ) == -1 )
	{
		type = QUESTION;
	}
	else if ( stat ( file, &buf ) == -1 )
	{
		type = QUESTION;
	}
	else if ( buf.st_size == 0 )
	{
		/* File is empty */

		type = EMPTY;
	}
	else 
	{
		short short1,short2,short3;

	        read ( fptr, &short1, 2 );
	        read ( fptr, &short2, 2 );
	        read ( fptr, &short3, 2 );

		if ( short2 == 46 )
		{
			type = DIRECTORY;
		}
		else if ( short2 == 25454 )
		{
			type = C_CODE;
		}
		else if ( ( short1 == 20294 ) && ( short2 == 21582 ) )
		{
			type = SYMBOL;
		}
		else if ( short1 == 383 ) 
		{
			if ( short2 == 2 )
				type = OBJECT;
			else
				type = EXEC;
		}
	        else if ( ( short2 == 18758 ) && ( short3 == 28518 ) )
		{
			type = A_FORM;
		}
		else
		{
			type = ASCII;
		}			
	}

	close ( fptr );

	return ( type );
}


build_file_list ()
{
  DIR	*dirp;

  struct dirent	*filep;

  int     index = 0;
  int	file_type;

  FIfld_set_num_rows( form, FILE_LIST, 0);

  if ( ( dirp = opendir ( current_dir ) ) != NULL )
    {
      while ( ( filep = readdir( dirp ) ) != NULL ) 
	{
	  if ( filep->d_name[0] != '.' )
	      {
		 /* Determine if the file is ascii format */
	
		 file_type = get_file_type ( filep->d_name );
	
		 if ( ( file_type == ASCII ) ||	
		      ( file_type == C_CODE ) ||
		      ( file_type == QUESTION ) )	
		
		   {
		         FIfld_set_text ( form, FILE_LIST, index++, 0, 
					  filep->d_name, 0 );
		   }
	      }
	}
	 
      closedir( dirp );
    }
}


unselect_all()
{
  int x;

  for ( x=0; x!=names; x++)	
	FIfld_set_select ( form, NAME_LIST, x, 0, 0 );
}

int mail_letters()
{
  int x;
  int a;	
  int pos;
  int letters;
  int sel_flag;
  int select;

  char command[2048];
  char letter[256];
  char file_name[17];
  char temp_string[300];

  char *file    = "/usr/tmp/mailer001";

  if ( current_dir[0] == NULL ) 
    {
      return(0);
    }

	/* See how many letters to mail */

  FIfld_get_num_rows ( form, FILE_LIST, &letters );

  for(a=0; a!=letters; a++)
    {
	FIfld_get_text ( form, FILE_LIST, a, 0, 16, file_name,
			   &sel_flag, &pos );

	if ( ! sel_flag ) continue;

  	strcpy ( letter, current_dir );
  	strcat ( letter, "/" );
	strcat ( letter, file_name );

	FIfld_set_active_row ( form, FILE_LIST, a, 5 );

 	for ( x=0; x!=names; x++)
	  {
	     FIfld_get_select ( form, NAME_LIST, x, 0, &select );

             if ( select )
	     {
	        FIfld_set_active_row ( form, NAME_LIST, x, 5 );	

	  	FIg_display ( form, MAILING );

		FIg_set_text ( form, FILE_NAME, file_name );
		FIg_set_text ( form, NAME,    mail_table[x].name );
		FIg_set_text ( form, ADDRESS, mail_table[x].address );

		sprintf(temp_string,header,mail_table[x].name);
		
#ifdef CLIX
		sprintf(command, "echo \"\" > %s;\
			          echo \"%s\" >> %s;\
				  echo \"\" >> %s;\
				  cat %s >> %s;\
				  elm -s \"%s\" %s < %s", 
				  file,
				  temp_string, file,
				  file,
				  letter, file,
				  subject, mail_table[x].address, file );
#elif SUN
		sprintf(command, "echo \"\" > %s;\
			          echo \"%s\" >> %s;\
				  echo \"\" >> %s;\
				  cat %s >> %s;\
				  mail -s \"%s\" %s < %s",
				  file,
				  temp_string, file,
				  file,
				  letter, file,
				  subject, mail_table[x].address, file );
#endif		
		system ( command );
	     }
	  }
    }

	/* Clear fields */

  FIg_set_text ( form, FILE_NAME, "" );
  FIg_set_text ( form, NAME, "" );
  FIg_set_text ( form, ADDRESS, "" );

  FIg_erase ( form, MAILING );
}

clean_up()
{
  if ( subform )
    FIf_erase ( subform );

  FIf_erase ( form );
  XCloseDisplay( display );
  exit(0);
}

select_all()
{
  int x;

  for ( x=0; x!=names; x++)	
	FIfld_set_select ( form, NAME_LIST, x, 0, 1 );
}


void save_param()
{
  FILE *fout;

  if ( ( fout = fopen ( "mail.data", "w" ) ) != 0 )
    fprintf ( fout, "%s\n%s",subject,header);

  fclose ( fout );
}

void sub_notify ( form_label, gadget_label, value, form )
  int form_label;
  int gadget_label;
  double value;
  Form   form;
{
  switch ( gadget_label )
    {
	case FI_ACCEPT:
		FIf_erase ( form );
		break;

	case SUBJECT:
		FIg_get_text ( form, SUBJECT, subject );
		save_param();
		break;

	case HEADER:
		FIg_get_text ( form, HEADER, header );
		save_param();
		break;
    }
}


notify ( form_label, gadget_label, value, form )
  int form_label;
  int gadget_label;
  double value;
  Form   form;
{
  switch ( gadget_label )
    {
	case FI_CANCEL:
		clean_up();
		break;

	case FI_EXECUTE:
		mail_letters();
		break;

	case PATH:
		FIg_get_text ( form, PATH, current_dir );
		build_file_list();
		break;

	case SEL_ALL:
		select_all();
		break;

	case UNSEL_ALL:
		unselect_all();
		break;

	case SUB_FORM:
		FIg_set_state_off ( subform, FI_ACCEPT );
		FIf_display ( subform );

    FIg_set_text ( subform, HEADER, header );
    FIg_set_text ( subform, SUBJECT, subject );


		break;
    }
}


load_mail_list( mail_list )
  char * mail_list;
{
    FILE *fin;

    int status;

    char alias[50];
    char equal[50];
    char first_name[50];
    char last_name[50];
    char address[50];

    if ( ( fin = fopen ( mail_list, "r" ) ) != NULL )
    {
	printf("load_mail_list:  after (and inside) fopen\n");
	for ( ;; )
	{
	printf("load_mail_list:  names = %d\n", names);
	  status = fscanf ( fin, "%s%s%s%s%s%s",
		    alias,equal,first_name,last_name,equal,address );
	printf("load_mail_list:  after fscanf\n");	
	    /* Build table of name and addresses */

	  strcpy ( mail_table[names].name, first_name );
	  strcat ( mail_table[names].name, " " );
	  strcat ( mail_table[names].name, last_name );

	  strcpy ( mail_table[names].address, address );
	printf("load_mail_list:  after strcpy's\n");	
		/* Fill in list on form */

	  if ( ( status != 6 ) || ( status == EOF ) )
	    {
	      break;
	    }
	printf("load_mail_list:  after if status\n");	

	printf("load_mail_list:  current name:  /%s/\n", mail_table[names].name);
	status = FIfld_set_text ( form, NAME_LIST, names, 0, 
				mail_table[names].name, 0 );
    if (status != FI_SUCCESS)
      printf("load_mail_list:  FIfld_set_text error - %d \n", status);
	printf("load_mail_list:  after FIfld_set_text\n");	

	  names++;

	}

      fclose ( fin );
	printf("load_mail_list:  after fclose\n");	
    }
    else
    {
	fprintf(stderr,"Unable to open mail list file: %s\n",mail_list);
	clean_up();
    }

    if ( names == 0 )
    {
	fprintf(stderr,"Mail list file is empty: %s\n",mail_list);
	clean_up();
    }
}

void default_header_subj()
{
    /* Set the Header and Subject to default */
   
    strcpy ( header, "Mail for %s" );
    strcpy ( subject, "General mail" );
}


main ( argc, argv )
  int argc;
  char **argv;
{
    FILE *fin;

	int	sts, dispsts;
    char		*display_name = "";


	Form form;



    if ( (display=XOpenDisplay(display_name)) == None )
    {
    	fprintf( stderr, "%s: cannot connect to X server %s\n",
    		XDisplayName(display_name) );
    	exit( -1 );
    }

    FSEnter ( display, 0 );

	FI_enter( display, NULL, NULL );

    if ( argc < 2 )
    {
	fprintf(stderr,"Usage: %s <mail list file>\n",argv[0]);
	exit(0);
    }

    sts = FIf_new ( 0, "mail.form", notify, &form );
    if ( sts ) 
    {
	fprintf(stderr,"%s: Unable to load \"mail.form\" - sts = %d\n",	
			argv[0],sts );	
	exit(0);
    }

    sts = FIf_new ( 0, "mail.subform", sub_notify, &subform );
    if ( sts ) 
    {
	fprintf(stderr,"%s: Unable to load \"mail.subform\" - sts = %d\n",	
			argv[0],sts );	
	exit(0);
    }

    if ( ( fin = fopen ( "mail.data", "r" ) ) != 0 )
    {

	    char * sts;

	    /* Read in the Header and Subject */

	    sts = fgets ( subject, 200, fin );
	    if ( ! sts  ) default_header_subj();

	    subject[strlen(subject)-1] = NULL;

	    if ( sts )
	    {
		    sts = fgets ( header, 200, fin );
		    if ( ! sts  )  default_header_subj();
	    }
    }
    else    default_header_subj();

    fclose ( fin );

    dispsts = FIf_display ( form );
	printf("after FIf_display(%d)\n", dispsts);	
	if (dispsts != FI_SUCCESS)
		exit(0);
/*
    getcwd ( current_dir, 256 );
    FIg_set_text ( form, PATH, current_dir );
    
    load_mail_list ( argv[1] );
	printf("after load_mail_list\n");
    build_file_list();
	printf("after build_file_list\n");
*/
	if( !dispsts )
		FI_process_forms( );
	printf("after FI_process_forms\n");		

	XCloseDisplay( display );
	printf("after XCloseDisplay\n");		
}
