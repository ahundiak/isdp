#ifdef ENV5
#include <tools.h>

#endif
#include <FI.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <exdef.h>
#include <journal.h>
#include <msdef.h>
#include <msmacros.h>
#include <execmsg.h>
#include <exproto.h>
#include <MS.h>

extern char EX_runname[];
extern int EX_batch_mode;
extern int EX_Gf_jnlon;
extern char EX_version[120];
static int save_jnl_on_exit;
static int clear_jnl_on_save;
static char jnlfile[15];
static char badfile[15];
static char save_jnl_file[15];
static int playback_time;
static int jnl_active;


int EX_init_rec_echo(filename)
char *filename;
{
if (EX_batch_mode == EX_INTERACT)
 {
  EX_init_record(filename);
  EX_init_echo(filename);
 }
return(1);
}

int EX_init_record(filename)
char *filename;
{
char path[256];	
char file_name[15];
char *newline;
int num_bytes;
char *char_stat;
char buffer[256];
char *equal_char;
FILE *fp;
int exclusive_flag;
int ret_sts;
char xscale[10];
char yscale[10];
char scale[256];
double double_x;
double double_y;
int nbytes;


jnl_active = 0; /*local active flag*/
exclusive_flag = 0;
playback_time = 0;
if ( EX_Gf_jnlon )
 {

 save_jnl_on_exit = 0;
 clear_jnl_on_save = 1;

 /*journal open and read it*/
 fp = fopen("journal", "r");
 if (fp)
  {
   while (char_stat = fgets(buffer,256, fp))
     {
        newline = strchr(buffer, '\n');
        if ( newline )
        {
            *newline = '\0';
        }
        if(!(strcmp("save_jnl_on_exit=y", buffer)))
          {
            save_jnl_on_exit = 1;
          }

        else if(!(strcmp("clear_jnl_on_save=n", buffer)))
          {
            clear_jnl_on_save = 0;
          }
        else if(!(strcmp("exclusive_use_of_jnl=y", buffer)))
          {
            exclusive_flag = 1;
          }
        else
          {/*lookingfor timer_playback*/
          equal_char = strchr (buffer, '=');
          if ( equal_char )
           {
           *equal_char = 0;
           equal_char++;
           if(!(strcmp("playback_time", buffer)))
           {
           playback_time = atoi( equal_char);
           }
          }
        }
      }/*end while*/
   fclose(fp); /* close file - journal */
   }        /*end of if journal*/
strncpy(file_name, filename, 15);
valid_filename(file_name, path);
strcpy(save_jnl_file, file_name);
strcpy(jnlfile, file_name);
strcpy (badfile,jnlfile);
strcat (badfile, ".abt");

strcat(jnlfile, ".jnl");
ret_sts = JNL_init_journal(jnlfile,exclusive_flag);	
if ( !ret_sts )
  {
   ex$message(msgnumb=EX_F_JNLExist);
   return(0);
  }
   nbytes = strlen(EX_runname);
   if (nbytes > 19)nbytes =19;
   JNL_record_info_event(JNL_CHAR,nbytes,EX_runname);
   jnl_active = 1; /*successful open set active flag*/
   num_bytes = strlen(EX_version);
   if ( num_bytes )
    {
    JNL_record_info_event(JNL_CHAR, num_bytes, EX_version);
    }
/*test to see if menus are scaled and put in journal file*/
xscale[0] = 0;
yscale[0] = 0;
IGE_get_menu_scaling_factors(&double_x,&double_y);
sprintf(xscale,"%.2f",double_x);
sprintf(yscale,"%.2f",double_y);
strcpy(scale,"Menus were scaled in this session - ");
strcat(scale,xscale);
strcat(scale," in x and ");
strcat(scale,yscale);
strcat(scale," in y");
num_bytes = strlen(scale);
if ( num_bytes )
    {
    JNL_record_info_event(JNL_CHAR, num_bytes, scale);
    }
 }
return(1);
}

EX_init_echo(filename)
char *filename;
{
char path[256];	
char file_name[15];
int status;
char pbkfile[15];
char runname[20];

if (jnl_active)
 {
  runname[0] = 0;
  strncpy(file_name, filename, 15);
  valid_filename(file_name, path);
  strcpy(pbkfile, file_name);
  strcat(pbkfile, ".pbk");
  status = JNL_init_playback(pbkfile,runname);
  if (status)
  {
  /*we are in playback mode*/
#ifdef ENV5
  if (playback_time )
     {
     JNL_set_timer_playback(playback_time);
     }
#endif
   /*test to see you are using same product*/
   status = strcmp(runname,EX_runname);
   if (status != 0)
    {
    JNL_close_jnl_pbk();
    printf("Replay of journaling disabled - products do not match\n");
    }
  }
 }
return(1);
}


int EX_close_rec_echo(flag)
int flag;
{
if ( jnl_active )
 {
  JNL_close_jnl_pbk();
  if ( flag )
   {/*if flag = 0 save regardless else test save flag*/
    if(!save_jnl_on_exit)
      {
      /*if one already open remove it*/
       EX_rm(jnlfile); 
      }	
    }
   else
    {
    /*had mem fault save as bad file*/
    EX_mv(jnlfile,badfile);
    }
  }/*end if journaling*/
return(1);
}

int EX_clear_jnl_on_save()
{

    if (jnl_active)
    {
        if ( clear_jnl_on_save )
        {
            JNL_close_jnl_pbk();
            EX_rm(jnlfile);
            EX_init_record(save_jnl_file);
            if(  EX_is_scn_menu_present() )
            {

#ifdef X11
                JNL_clear_windows();
#endif
                EX_construct_and_display_menus();
            }

        }
    }
    return(clear_jnl_on_save);
}

int EX_store_window_on_save()
{
if ( clear_jnl_on_save )
 {
  EX_record_windows();
 }
return(1);
}

int EX_clear_command_on_save()
{
return(clear_jnl_on_save);
}


int EX_restart_journal()
{
/*for rest of ems to know whether to take down form*/
return(clear_jnl_on_save);
}

