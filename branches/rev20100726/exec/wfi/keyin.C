#include "exsysdep.h"
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <OMminimum.h>
#ifdef ENV5
#include <tools.h>
#include <FIproto_pub.h>
#endif
#include <ctype.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <msdef.h>
#include <ex.h>
#include <expriv.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <exlocale.h>
#include <exlocaledef.h>
#include <exmacros.h>
#include <exproto.h>
#ifdef NT
#include <io.h>
#endif
#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
#include <X11/keysym.h>
#include <X11/keysymdef.h>
#include "INGRkeysym.h"
#include <X11/Intrinsic.h>

#include "wl.h"
#include "exwl.h"

extern Display *EXdisplay;
extern Widget   EXtoplevel;

#endif

#define debug 0
#define  EX_MAX_FUNCKEY 135
#define  NOSPACE        1
#define  ONESPACE       0
#define  LOWERCASE      1
#define  SAMECASE       0 
#define ESCAPE_KEY      0x1b

extern short  EX_linebuffer_flag;
extern char   EX_keybuff[];
extern int    EX_index;
extern short EX_echo_flag;
extern char *bsearch();

extern int EX_kbd_wrt;
extern int EX_kbd_rd;
extern int EX_logkbd;


struct function_keycmd
{
   short valid;       
   short wait_flag;
   int   response;
   char  key_str[58];
};

struct EXmt /* match table */
{
    char   key[20];
    int    indx;
};
static int kbd_collapsed;

#ifdef X11
static int   EX_2nd_func = 0;
#endif
static struct function_keycmd keycmd_list[EX_MAX_FUNCKEY+1];
static struct EXmt match_table[] ={ 
                                  {"2ndfa1",0x11},
                                  {"2ndfa10",0x23},
                                  {"2ndfa11",0x25},
                                  {"2ndfa12",0x27},
                                  {"2ndfa13",0x29},
                                  {"2ndfa14",0x2b},
                                  {"2ndfa15",0x2d},
                                  {"2ndfa2",0x13},
                                  {"2ndfa3",0x15},
                                  {"2ndfa4",0x17},
                                  {"2ndfa5",0x19},
                                  {"2ndfa6",0x1b},
                                  {"2ndfa7",0x1d},
                                  {"2ndfa8",0x1f},
                                  {"2ndfa9",0x21},
                                  {"2ndfb1",0x2f},
                                  {"2ndfb10",0x41},
                                  {"2ndfb11",0x43},
                                  {"2ndfb12",0x45},
                                  {"2ndfb13",0x47},
                                  {"2ndfb14",0x49},
                                  {"2ndfb15",0x4b},
                                  {"2ndfb16",0x4d},
                                  {"2ndfb2",0x31},
                                  {"2ndfb3",0x33},
                                  {"2ndfb4",0x35},
                                  {"2ndfb5",0x37},
                                  {"2ndfb6",0x39},
                                  {"2ndfb7",0x3b},
                                  {"2ndfb8",0x3d},
                                  {"2ndfb9",0x3f},
                                  {"2ndfc1",0x4f},
                                  {"2ndfc10",0x61},
                                  {"2ndfc11",0x63},
                                  {"2ndfc12",0x65},
                                  {"2ndfc13",0x67},
                                  {"2ndfc14",0x69},
                                  {"2ndfc15",0x6b},
                                  {"2ndfc16",0x6d},
                                  {"2ndfc2",0x51},
                                  {"2ndfc3",0x53},
                                  {"2ndfc4",0x55},
                                  {"2ndfc5",0x57},
                                  {"2ndfc6",0x59},
                                  {"2ndfc7",0x5b},
                                  {"2ndfc8",0x5d},
                                  {"2ndfc9",0x5f},
                                  {"2ndfclearscreen",0x0f},
                                  {"2ndffind",0x0c},
                                  {"2ndfhelp",0x0e},
                                  {"2ndfhome",0x0f},
                                  {"2ndfinserthere",0x0d},
                                  {"2ndfnextscreen",0xffffff86},
                                  {"2ndfprevscreen",0x0b},
                                  {"2ndfprintscreen",0x09},
                                  {"2ndfremove",0x09},
                                  {"2ndfselect",0x0a},
                                  {"2ndfsetup",0x0e},
                                  {"a1",0x10},
                                  {"a10",0x22},
                                  {"a11",0x24},
                                  {"a12",0x26},
                                  {"a13",0x28},
                                  {"a14",0x2a},
                                  {"a15",0x2c},
                                  {"a2",0x12},
                                  {"a3",0x14},
                                  {"a4",0x16},
                                  {"a5",0x18},
                                  {"a6",0x1a},
                                  {"a7",0x1c},
                                  {"a8",0x1e},
                                  {"a9",0x20},
                                  {"b1",0x2e},
                                  {"b10",0x40},
                                  {"b11",0x42},
                                  {"b12",0x44},
                                  {"b13",0x46},
                                  {"b14",0x48},
                                  {"b15",0x4a},
                                  {"b16",0x4c},
                                  {"b2",0x30},
                                  {"b3",0x32},
                                  {"b4",0x34},
                                  {"b5",0x36},
                                  {"b6",0x38},
                                  {"b7",0x3a},
                                  {"b8",0x3c},
                                  {"b9",0x3e},
                                  {"c1",0x4e},
                                  {"c10",0x60},
                                  {"c11",0x62},
                                  {"c12",0x64},
                                  {"c13",0x66},
                                  {"c14",0x68},
                                  {"c15",0x6a},
                                  {"c16",0x6c},
                                  {"c2",0x50},
                                  {"c3",0x52},
                                  {"c4",0x54},
                                  {"c5",0x56},
                                  {"c6",0x58},
                                  {"c7",0x5a},
                                  {"c8",0x5c},
                                  {"c9",0x5e},
                                  {"clearscreen",0x08},
                                  {"find",0x04},
                                  {"help",0x07},
                                  {"home",0x08},
                                  {"inserthere",0x05},
                                  {"nextscreen",0x03},
                                  {"prevscreen",0x02},
                                  {"printscreen",0x06},
                                  {"remove",0x06},
                                  {"select",0x01},
                                  {"setup",0x07}
                              };

#ifdef X11
static int EX_A[16]    = {  0x10,      /* a1 */
                            0x12,      /* a2 */
			    0x14,      /* a3 */
			    0x16,      /* a4 */
			    0x18,      /* a5 */
			    0x1a,      /* a6 */
			    0x1c,      /* a7 */
			    0x1e,      /* a8 */
			    0x20,      /* a9 */
                            0x22,      /* a10 */
                            0x24,      /* a11 */
                            0x26,      /* a12 */
                            0x28,      /* a13 */
                            0x2a,      /* a14 */
                            0x2c,      /* a15 */
                            0x0, };    /* a16 */

static int EX_B[16]    = {  0x2e,      /* b1 */
                            0x30,      /* b2 */
			    0x32,      /* b3 */
			    0x34,      /* b4 */
			    0x36,      /* b5 */
			    0x38,      /* b6 */
			    0x3a,      /* b7 */
			    0x3c,      /* b8 */
			    0x3e,      /* b9 */
                            0x40,      /* b10 */
                            0x42,      /* b11 */
                            0x44,      /* b12 */
                            0x46,      /* b13 */
                            0x48,      /* b14 */
                            0x4a,      /* b15 */
                            0x4c};     /* b16 */

static int EX_C[16]    = {  0x4e,      /* c1 */
                            0x50,      /* c2 */
			    0x52,      /* c3 */
			    0x54,      /* c4 */
			    0x56,      /* c5 */
			    0x58,      /* c6 */
			    0x5a,      /* c7 */
			    0x5c,      /* c8 */
			    0x5e,      /* c9 */
                            0x60,      /* c10 */
                            0x62,      /* c11 */
                            0x64,      /* c12 */
                            0x66,      /* c13 */
                            0x68,      /* c14 */
                            0x6a,      /* c15 */
                            0x6c};     /* c16 */

static int EX_FN[8] =   { XK_Select,
                         XK_Prior,
                         XK_Next,
			 XK_Find,
			 XK_Insert,
			 IXK_REMOVE,
			 XK_Help,
			 XK_Clear };
			 

static int EX_OT[8][2] =   {  { 0x01, 0x0a },     
                             { 0x02, 0x0b },
                             { 0x03, 0x6f },
			     { 0x04, 0x0c },
			     { 0x05, 0x0d },
			     { 0x06, 0x09 },
			     { 0x07, 0x0e },
			     { 0x08, 0x0f } };
#endif

#ifdef ENV5
static int count;
static char buffer;

 /* static struct iosb iosbptr; */

#define FUNCTION_key    0xfffffffe
#define SPECIAL_KEY     0xffffff8f
#endif
#define ESCAPE_key      033
#define CARRIAGE_return 015
#define BACK_space      010
#define DELETE_key      0177


/*******************************************************************/
/*                                                                 */
/*        EX_process_funckey()                                     */
/*                                                                 */
/*******************************************************************/

#ifdef NT
int EX_process_funckey( buf, mode,ks)
struct EX_logkbd_buf *buf;
int mode;
int ks;
#endif

#ifdef X11

int EX_process_funckey( buf, mode, ks)
struct EX_logkbd_buf *buf;
int mode;
KeySym ks;
#endif

#ifdef ENV5

int EX_process_funckey( buf, mode)
struct EX_logkbd_buf *buf;
int mode;
#endif

{
#ifdef ENV5
  int em;
#endif
  short entry;
  int status;
#ifdef X11
      entry = EX_get_funcky_entry( ks );
#endif
#ifdef ENV5
      EX_wait_for_next(KEYBOARD_EVENT, &em);
      EX_get_keyboard_data(&count);
      entry = (short)( (unsigned char) buffer);
#endif
      if (mode == EX_ALL_CHAR_MODE)
      {
   	  buf->nbytes = 2;
	  buf->data.buffer[0] = (char) 0xfc;
 	  buf->data.buffer[1] = (char) entry;
	  status = 2;
      }
    else
      {
      status = EX_translate_funckey1( entry, buf,mode );
      }
      return (status);

}


#if defined( __STDC__ )
int EX_translate_funckey1( short entry, struct EX_logkbd_buf *buf, int mode )
#else
int EX_translate_funckey1( entry , buf, mode)
short entry;
struct EX_logkbd_buf *buf;
int mode;
#endif
{
  int resp, cond;
  long ret,no_bytes;
  char resp_data[256];
  char out_buffer[256];   
  cond = 0;
  if( ( entry <= EX_MAX_FUNCKEY ) && (entry >= 0))
  {
      if(keycmd_list[entry].valid)
      {
         if( (mode == EX_ALL_ASCII_MODE) && 
             ( keycmd_list[entry].response == CMD_STRING ) &&
	     ( keycmd_list[entry].wait_flag == 1)   )
	 {  /* for fucntion key with wait_flag set  ex: "co=" */
            resp = EX_CMD_KEY | EX_HARDWARE_GENERATED;
            strcpy(resp_data,"EXDummy");
            no_bytes = 8;
            EXputq_back(&ret,&resp,&no_bytes,resp_data);

            EX_init_keyboard();
            strcat(EX_keybuff,keycmd_list[entry].key_str);
            EX_index += strlen(keycmd_list[entry].key_str);
            if (EX_echo_flag) 
	    {
               pad_escape(EX_keybuff, out_buffer);
	       UI_echo(out_buffer);
	    }
	    cond = 6;
	    return(cond);
	 }
	 else if( keycmd_list[entry].wait_flag)
         {
            EX_init_keyboard();
            if( keycmd_list[entry].response == CMD_STRING )
	    {
	       if( keycmd_list[entry].key_str[0] != ESCAPE_KEY )
	       {
	          EX_keybuff[EX_index] = ESCAPE_KEY;
                  ++EX_index;
	       }
	    }

            strcat(EX_keybuff,keycmd_list[entry].key_str);
            EX_index += strlen(keycmd_list[entry].key_str);
            if (EX_echo_flag) 
	    {
               pad_escape(EX_keybuff, out_buffer);
	       UI_echo(out_buffer);
	    }

            cond = 4;
	    return(cond);
         }
         else
         {
	    if(!(strcmp("fraction key",keycmd_list[entry].key_str)))
	    {
		buf->nbytes = 1;
		buf->data.buffer[0] = 1;/*control a in ascii*/
                cond = 1;
		return(cond);/*normal fraction key, not function key*/
	    }
 	    else
	    {
	      resp = keycmd_list[entry].response | EX_HARDWARE_GENERATED;
	      strcpy(resp_data,keycmd_list[entry].key_str);
	      no_bytes = strlen(resp_data) + 1; 
	      EXputq_back(&ret,&resp,&no_bytes,resp_data);
              cond = 2;
	    }
         }
      }
  }
  return(cond);
}

#ifdef X11

int EX_get_funcky_entry( ks )
KeySym ks;
{
     register int i;
     int entry = -1;
     if ( ks >= XK_F1 && ks <= XK_F16 )
     {
	entry =  EX_C[ks - XK_F1] + EX_2nd_func;
     }
     else if ( ks >= IXK_A1 && ks <= IXK_A15 )
     {
        entry = EX_A[ks - IXK_A1] + EX_2nd_func;
     }
     else if ( ks >= IXK_B1 && ks <= IXK_B16 )
     {
        entry = EX_B[ks - IXK_B1] + EX_2nd_func;
     }
     else
     {
        for (i = 0; i< 8; i++ )
	{
	   if ( ks == EX_FN[i] )
	   {
	      entry = EX_OT[i][EX_2nd_func];
	      break;
	   }
	}
     }
     return(entry);
}  
#endif

#if defined( __STDC__ )
int EX_translate_funckey( short entry, struct EX_logkbd_buf *buf )
#else
int EX_translate_funckey( entry , buf)
short entry;
struct EX_logkbd_buf *buf;
#endif
{
  int resp, cond;
  long ret,no_bytes;
  char resp_data[256];
  char out_buffer[256];   
      cond = 0;
      if( ( entry <= EX_MAX_FUNCKEY ) && (entry >= 0))
      {
          if(keycmd_list[entry].valid)
          {
             if( keycmd_list[entry].wait_flag)
             {
                EX_init_keyboard();
                strcat(EX_keybuff,keycmd_list[entry].key_str);
                EX_index += strlen(keycmd_list[entry].key_str);
                if (EX_echo_flag)
		{
                   pad_escape(EX_keybuff, out_buffer);
                   UI_echo(out_buffer);
		}
             }
             else
             {
		if(!(strcmp("fraction key",keycmd_list[entry].key_str)))
		{
		    buf->nbytes = 1;
		    buf->data.buffer[0] = 1;/*control a in ascii*/
                    cond = 1;
		    return(cond);/*normal fraction key, not function key*/
		}
 	        else
		{
		  resp = keycmd_list[entry].response | EX_HARDWARE_GENERATED;
		  strcpy(resp_data,keycmd_list[entry].key_str);
		  no_bytes = strlen(resp_data) + 1; 
		  EXputq_back(&ret,&resp,&no_bytes,resp_data);
		}
             }
	     cond = 2;
          }
      }
      return(cond);
}



extern char  EX_keyin_cmd[EX_RCL_MAX_ENTRY][EX_RCL_MAX_LEN]; /* 10 cmds , 80 char each */

extern int EX_entry;
extern int EX_entry_full;


/*******************************************************************/
/*                                                                 */
/*        EX_init_keyboard()                                       */
/*                                                                 */
/*******************************************************************/

int EX_init_keyboard()
{
  register int j;
#ifdef ENV5
  EX_set_keyboard_buffer(&buffer,1);
#endif
  EX_index = 0;
  EX_linebuffer_flag = 0;
  for(j=0; j<257; j++)  EX_keybuff[j] = '\0';

  return 1;
}

static int cmdcmp (x,z)
char *x;
struct EXmt *z;  
{
   char *y;
   y = z->key;
   return(strcmp(x,y));
}


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  EX_load_funckey
 
     Abstract:   This function will load the function key definition
                 into the static memory keycmd_list
-----
%SC%

      value = EX_load_funckey( msg, file_name )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *file_name     char         pointer to file_name


-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        - return code:
                                   EXSUCC - succeeded.



     value =    TRUE if succeeded
                FALSE if failed.

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:

-----
%CH%
     CHANGE HISTORY:
      ht  7/24/86       creation date.  
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#define BUFSIZE  512

IGRint EX_load_funckey ( type, file_name )

int             type;   /* EX_INIT or EX_UPDATE */
IGRchar         *file_name;

{
    IGRint      status;
    IGRint      response;
    IGRlong     i;
    IGRint      line_num;
    IGRint      ended;
    IGRint      num_read;
    IGRshort    indx;
    struct EXmt  *tent;
    FILE        *fp;
    char  keynam[30];
    char  s[BUFSIZE];
    short waitf;
    char  key_str[257];

    int tnum = sizeof( match_table) / sizeof(struct EXmt);
    status = TRUE;

    /* initialize each key entry to not valid */
    if ( type == EX_INIT )
    {
	for( i = 0; i < EX_MAX_FUNCKEY; i++)
	{
	   keycmd_list[i].valid = 0;          
	}
    }
    if (! ( fp = fopen ( file_name, "r" )))
    {
/*
        perror("1error opening funckey file");
        printf("error opening funckey file\n");
        printf("file_name = %s   fp=%x\n",file_name,fp);
*/
        status = FALSE;
    }
    else
    {
       ended = FALSE;
       line_num = 0;
       
       while( fgets(s, BUFSIZE, fp) != NULL )
       {
           line_num++;
           if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') || (s[0] == '\n'))
         	      continue;
           if ( (num_read = sscanf(s,"%[^,],%ld,%hd,%[^\n]\n",
                        keynam, &response, &waitf, key_str )) == 4 )  
           {
               EX_clean_str( keynam,NOSPACE,LOWERCASE);
               tent = (struct EXmt *) bsearch(keynam,match_table,tnum,
                                sizeof(struct EXmt),cmdcmp);
               if (tent) 
               {
                  indx =  (short)((unsigned char) tent->indx);
                  if (indx < EX_MAX_FUNCKEY)
                  {
                      keycmd_list[indx].valid = 1;  
                      keycmd_list[indx].response = response;
                      keycmd_list[indx].wait_flag = waitf;
                      EX_clean_str(key_str,ONESPACE,SAMECASE);
                      strcpy(keycmd_list[indx].key_str,key_str);
                  }
               }
               else
               {
                   printf("\nfunction key name not found - %s\n",keynam);
               }
	   }
           else  /* something wrong with function_file */
           {
                printf("\nwrong entry in function_key\n");
                printf("possible error in entry %d, field %d\n",line_num,num_read+1);
	/*	printf("--keyname = %s\n",keynam);
		printf("--keysstr = %s\n",key_str);
		printf("--response= %d\n",response);
		printf("--wait_flag=%d\n",waitf);      */
	   }
       }
       fclose(fp);   
    }
    return ( status );
} /* end EX_load_funckey */

/*******************************************************************/
/*                                                                 */
/*        EX_updaate_funcky                                        */
/*                                                                 */
/*******************************************************************/

int EX_update_funcky(
IGRchar *keynam,
IGRint  response,
IGRshort  waitf,
IGRchar *key_str)
{
    IGRint      status;
    IGRshort    indx;
    struct EXmt *tent;
    int tnum = sizeof( match_table) / sizeof(struct EXmt);
 
    status = TRUE;

    EX_clean_str( keynam,NOSPACE,LOWERCASE);
    tent = 0;
    tent = (struct EXmt *) bsearch(keynam,match_table,tnum,
                     sizeof(struct EXmt),cmdcmp);
    if (tent) 
    {
        indx =  (short)((unsigned char) tent->indx);
        if (indx < EX_MAX_FUNCKEY)
        {
            keycmd_list[indx].valid = 1;  
            keycmd_list[indx].response = response;
            keycmd_list[indx].wait_flag = waitf;
            EX_clean_str(key_str,ONESPACE,SAMECASE);
            strcpy(keycmd_list[indx].key_str,key_str);
        }
    }
    else
    {
        printf("\nfunction key name not found - %s\n",keynam);
        status = 0;    /* function key name not found */
    }
    return(1);
}






int  pad_escape( buffer,outbuffer )
char *buffer;
char *outbuffer;
{

   register int len, j, i;

   j = 0;
   len = strlen(buffer);
   for ( i = 0; i < len; i++)
   {
       if (buffer[i] == ESCAPE_key)
       {
	  outbuffer[j] = 0;
	  strcat(outbuffer, "<esc>");
	  j += 5;
       }
       else
       {
	  outbuffer[j] = buffer[i];
	  j++;
       }
   }
   outbuffer[j] = 0;
   return(1);
} /* pad_escape */



int strip_esc_key(response_data)
char *response_data;
{
  char tempstr[257];

  if ((!EX_logkbd) || (kbd_collapsed))
  {
    strcpy ( tempstr, &response_data[1]);
    strcpy ( response_data, tempstr);
  }
    return(1);
} /* strip_escape */

/*******************************************************************/
/*                                                                 */
/*        EX_keybd_process_return                                  */
/*                                                                 */
/*******************************************************************/

static int rrindex,current ; 
static char  rest[EX_RCL_MAX_LEN];
static EX_rest_first = 1;

#define EX_CTRL_F    0x6  /* forward 1 char*/
#define EX_CTRL_B    0x2  /* back one char */
#define EX_CTRL_P    0x10 /* previous line */
#define EX_CTRL_N    0xe  /* next line     */
#define EX_CTRL_A    0x1  /* begin of line */
#define EX_CTRL_E    0x5  /* end of line   */
#define EX_CTRL_D    0x4  /* delete 1 char */
#define EX_CTRL_G    0x7  /* return to norm*/ 
#define EX_CTRL_H    0x8  /* return to norm*/ 
#define EX_CTRL_K    0xb  /* delet to EOL  */ 

EX_keybd_process_return(response_data,num_char)
char *response_data;
int  num_char;
{
  int i,j;
  char out_buffer[257];
  
  if ( EX_rest_first )
  {
     EX_rest_first = 0;
     rrindex = EX_RCL_MAX_LEN - 1;
     rest[rrindex] = '\0';
     rest[rrindex-1] = '|';
     current = EX_entry;
  }

  if ((!EX_logkbd) || (kbd_collapsed))
  {
    /* we process keyboard only if no logical keyboard */
  
     for(i = 0; i< num_char; i++ )
     {
        switch (response_data[i])
        {
           case CARRIAGE_return :

                EX_keybuff[EX_index] = 0;
                EX_index += 1;
                EX_linebuffer_flag = 1;
                strcat(EX_keybuff,&rest[rrindex]);

                if( EX_keybuff[0] != '\0')
		{
                   strcpy(EX_keyin_cmd[EX_entry],EX_keybuff);
	 	   EX_entry++;
                   current = EX_entry; 
		   if(EX_entry >= EX_RCL_MAX_ENTRY)
	  	   {
		      EX_entry = 0;
		      EX_entry_full = 1;
                   }
		}
                for (j = rrindex - 1; j < EX_RCL_MAX_LEN; ++j) rest[j] = '\0';
		rest[ EX_RCL_MAX_LEN - 2 ] = '|';
                rrindex = EX_RCL_MAX_LEN - 1;
                break;
    

	   case EX_CTRL_B :
       case EX_LEFT_ARROW :
                if ( EX_index > 0 )
		{
  	            EX_index--;
	  	    rrindex--;
	            rest[rrindex] = EX_keybuff[EX_index];
		    rest[rrindex-1] = '|';
		    EX_keybuff[EX_index] = '\0';
		}
		break;

           case EX_CTRL_A:
                while( EX_index > 0 )
		{
  	            EX_index--;
	  	    rrindex--;
	            rest[rrindex] = EX_keybuff[EX_index];
		    rest[rrindex-1] = '|';
		    EX_keybuff[EX_index] = '\0';
		}
		break;

	   case EX_CTRL_F :
       case EX_RIGHT_ARROW :
                if ( rrindex < EX_RCL_MAX_LEN - 1)
		{
                   EX_keybuff[EX_index++] = rest[rrindex];
                   rest[rrindex-1] = '\0';
		   rest[rrindex++] = '|';
	        }
                break;

	   case EX_CTRL_E :
                while ( rrindex < EX_RCL_MAX_LEN - 1)
		{
                   EX_keybuff[EX_index++] = rest[rrindex];
                   rest[rrindex-1] = '\0';
		   rest[rrindex++] = '|';
	        }
                break;
    
           case DELETE_key  :
           case EX_CTRL_H  :
                if(EX_index > 0 )
		{
		   EX_index--;
                   EX_keybuff[EX_index] = '\0';
		}
                break;

           case EX_CTRL_D  :
                if(rrindex < EX_RCL_MAX_LEN - 1  )
		{
		   rest[rrindex-1] = '\0';
		   rest[rrindex] = '|';
		   rrindex++;
		}
                break;

           case EX_CTRL_P :
                for (j = rrindex - 1; j < EX_RCL_MAX_LEN; ++j) rest[j] = '\0';
                rrindex = EX_RCL_MAX_LEN - 1;
		rest[rrindex - 1] = '|';

                current--;
		if ( current < 0 )
		{
		    if( EX_entry_full == 1 )
		    {
		        current = EX_RCL_MAX_ENTRY - 1;
		    }
		    else
		    {
#ifdef X11
              XBell(EXdisplay,0);
#endif
#ifdef ENV5
		      keybd_bell(0);
#endif
		      current = 0;
		    }
		}
                if ( current != EX_entry )
		{
                   EX_init_keyboard();
		   strcpy(EX_keybuff,EX_keyin_cmd[current]);
		   EX_index = strlen(EX_keybuff);
		}
		else
		{
#ifdef X11
		   XBell(EXdisplay,0);	
#endif
#ifdef ENV5
		   keybd_bell(0);
#endif
		   current++;
		}
		break;

           case EX_CTRL_N :
                for (j = rrindex - 1; j < EX_RCL_MAX_LEN; ++j) rest[j] = '\0';
                rrindex = EX_RCL_MAX_LEN - 1;
		rest[rrindex - 1] = '|';

                if (current != EX_entry) current++;
  	        if ( current >= EX_RCL_MAX_ENTRY ) current = 0;

                if ( current == EX_entry )
		{
#ifdef X11
		   XBell(EXdisplay,0);
#endif
#ifdef ENV5
		   keybd_bell(0);
#endif
                   EX_init_keyboard();  
		}
                else
		{
                   EX_init_keyboard();
		   strcpy(EX_keybuff,EX_keyin_cmd[current]);
		   EX_index = strlen(EX_keybuff);
		}
		break;

           case EX_CTRL_G :
                for (j = rrindex - 1; j < EX_RCL_MAX_LEN; ++j) rest[j] = '\0';
                rrindex = EX_RCL_MAX_LEN - 1;
		rest[rrindex - 1] = '|';
                current = EX_entry;
                EX_init_keyboard();  
                break;

           case EX_CTRL_K :
                for (j = rrindex - 1; j < EX_RCL_MAX_LEN; ++j) rest[j] = '\0';
                rrindex = EX_RCL_MAX_LEN - 1;
		rest[rrindex - 1] = '|';
                break;
				
           default :
                if(EX_index<257)
                {
                   EX_keybuff[EX_index] = response_data[i];
                   EX_index += 1;
                }
                break;
          }
     }

     if (EX_echo_flag) 
     {
        if (EX_linebuffer_flag)
        {
           UI_echo(" ");
        }
        else
        {
           pad_escape(EX_keybuff, out_buffer);
           strcat(out_buffer,&rest[rrindex-1]);
           UI_echo(out_buffer);
        }
     }
  }/*end if no logical keyboard exists*/
  return(1);
}




/*******************************************************************/
/*                                                                 */
/*        EX_get_kbd_input                                         */
/*                                                                 */
/*******************************************************************/

#ifdef X11

int EX_get_kbd_input( event,response_data, num_char, mode)
XEvent *event;
char *response_data;
int *num_char;
int mode;
#endif

#ifdef NT

int EX_get_kbd_input(response_data, num_char, mode)
char *response_data;
int *num_char;
int mode;
#endif

#ifdef ENV5

int EX_get_kbd_input(response_data, num_char, mode)
char *response_data;
int *num_char;
int mode;
#endif

{
     struct EX_logkbd_buf kbd_buffer;
     int ii;
     int ret_code = 1;
#ifdef X11
     ret_code = EX_get_kybd_data ( event, &kbd_buffer, mode, 0); 
#endif
#ifdef ENV5
     ret_code = EX_get_kybd_data (&kbd_buffer, mode, 0); 
#endif

     if (ret_code != 6 )
     {
        for (ii = 0; ii < kbd_buffer.nbytes ; ii++) 
        {
           response_data[*num_char] = kbd_buffer.data.buffer[ii];
           (*num_char)++;
           response_data[*num_char] = '\0';
        }
     }
     return(ret_code);
}

#ifdef X11
#if defined (SPARC)

/*******************************************************************
 *  I got this function from SUN because on SPARC workstations, the
 *  keypad equals '=' button on type 4 keyboards and the keypad minus
 *  '-' on type 5 keyboards are mapped to the same keysym.  
 *
 *  Mike Lanier:  Oct. 13, 1995
 *******************************************************************/

/******************************************************************
 * US Solution Center
 * Sun Microsystems Computer Corporation, Mountain View, CA.
 *
 * Example Program
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted,
 * provided that this permission notice appears in all copies and in
 * supporting documentation, and that the name of Sun not be used in
 * advertising or publicity pertaining to distribution of the software
 * without specific prior written permission. Sun makes no representa-
 * tions about the suitability of this software for any purpose. It is
 * provided "as is" without any express or implied warranty.
 *
 * SUN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FIT-
 * NESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL SUN BE LI-
 * ABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
 * ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
 * THE USE OR PERFORMANCE OF THIS SOFTWARE.
 ******************************************************************
 *
 * File: kbtype.c
 *
 * Owner:  Kevin Chu
 *
 * Description:
 *
 *      Use this program to tell what type of keyboard the
 *      system is using.
 *
 *      This program will get the type and layout of the keyboard.
 *      Type-4, 101A, and type-5 all have a "type" of 4, but
 *      the layout is different.
 *
 *      Type    Layout  Keyboard
 *      ---------------------------
 *      4       0       Sun US Type 4 keyboard
 *      4       1       Also Sun US Type 4 keyboard
 *      4       19      Sun 101A
 *      4       33      Type 5 US
 *      4       34      Type 5 UNIX
 *
 *      There are others.  See the file:
 *
 *              $OPENWINHOME/share/etc/keytables/keytable.map
 *
 *****************************************************************/
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/kbd.h>
#include <sys/kbio.h>

#define DEVKBD  "/dev/kbd"

static int	KeyboardType = 0;

static int	KeyboardTypeSPARC()
   {
   int     fd;
   int     type;
   int     layout;

   /*
    * If the variable 'KeyboardType' is NOT 0, then this is not the
    * first time this function has been called and, therefore, there
    * is no need to query the system again. I already have the answer
    */

   if (KeyboardType == 0)
      {

      /*
       *  If any of the following operations fails, assume that
       *  the keyboard is type 4.
       */

      if ((fd = open(DEVKBD, O_RDONLY)) < 0) 
         {
         type = 4;
         layout = 0;
         }

      else
      if (ioctl(fd, KIOCTYPE, &type) == -1) 
         {
         type = 4;
         layout = 0;
         }

      else
      if (ioctl(fd, KIOCLAYOUT, &layout) == -1) 
         {
         type = 4;
         layout = 0;
         }

#     if DEBUG
      printf("type = %d layout = %d\n", type, layout);
#     endif

      if( fd >= 0 ) close(fd);

      /*  
       *  Check for type 5, otherwise identify as a type 4
       */

      if( type == 4 && layout == 34 )
         KeyboardType = 5;

      else
         KeyboardType = 4;
      }

   return KeyboardType;
   }
#endif /* SPARC */

int EX_get_kybd_data (kevent,buf, mode, esc_flag)
XEvent *kevent;
struct EX_logkbd_buf *buf;
int mode;
int esc_flag;
#endif

#ifdef NT

int EX_get_kybd_data (buf, mode, esc_flag)
struct EX_logkbd_buf *buf;
int mode;
int esc_flag;
#endif

#ifdef ENV5

int EX_get_kybd_data (buf, mode, esc_flag)
struct EX_logkbd_buf *buf;
int mode;
int esc_flag;
#endif

{
   /*this routine reads hardware keyboard and puts into logkbd_buf*/

  int status,status2, nbytes;
#ifdef ENV5
  int event;
#endif

#ifdef X11
  int i;
  KeySym  ks;
  char str[256], *x_str ;
  XKeyEvent *e = (XKeyEvent *) kevent;
  nbytes = XLookupString( (XKeyEvent *)kevent,str ,255, &ks, NULL );
  /* printf(" nbytes %d\n",nbytes ); */
#if defined (SUNOS) || defined (IRIX)

#ifdef IRIX
  if ( ks == 0xff08 ) 
    {
     ks = 0xffff;
     nbytes = 1;
     str[0] = 0x7f;
    }
#endif

  if ( ks == 0x1005ff10 ) ks = XK_F11;
  else if ( ks == 0x1005ff11 ) ks = XK_F12;
  else if ( ks == 0xff6a ) ks = XK_F1;
  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff63 ))
   {
   nbytes = 1;
   str[0] = XK_0;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff9e ))
   {
   nbytes = 1;
   str[0] = XK_0;
   ks = 0;
   }

#if defined (INTEL)
  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff57 ))
   {
   nbytes = 1;
   str[0] = XK_1;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff56 ))
   {
   nbytes = 1;
   str[0] = XK_3;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffb5 ))
   {
   nbytes = 1;
   str[0] = XK_5;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff50 ))
   {
   nbytes = 1;
   str[0] = XK_7;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff55 ))
   {
   nbytes = 1;
   str[0] = XK_9;
   ks = 0;
   }

  else if ((( e->state & Mod3Mask ) &&  ( ks == 0xffff ))
                         && ( e->keycode == 0x6f ))
   {
   nbytes = 1;
   str[0] = XK_period;
   ks = 0;
   }

#endif /* INTEL */

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffde ))
   {
   nbytes = 1;
   str[0] = XK_1;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff54 ))
   {
   nbytes = 1;
   str[0] = XK_2;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffe0 ))
   {
   nbytes = 1;
   str[0] = XK_3;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff51 ))
   {
   nbytes = 1;
   str[0] = XK_4;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffdc ))
   {
   nbytes = 1;
   str[0] = XK_5;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff53 ))
   {
   nbytes = 1;
   str[0] = XK_6;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffd8 ))
   {
   nbytes = 1;
   str[0] = XK_7;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff52 ))
   {
   nbytes = 1;
   str[0] = XK_8;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffda ))
   {
   nbytes = 1;
   str[0] = XK_9;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffd5 ))
   {
   nbytes = 1;
   str[0] = XK_equal;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffd6 ))
   {
   nbytes = 1;
 
   /*
    *  On SPARC workstations, the keypad equals '=' on type 4 keyboards
    *  and the keypad minus '-' on type 5 keyboards are mapped to the
    *  same keysym.  In this case, I need to check the keyboard type
    *  to know how to interpret the event
    *
    *  Mike Lanier: Oct 13, 1995
    */
 
#  if defined (SPARC)
   if( KeyboardTypeSPARC() == 5 )
      str[0] = XK_minus;
   else
#  endif
      str[0] = XK_slash;

   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffd7 ))
   {
   nbytes = 1;
   str[0] = XK_asterisk;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffad ))
   {
   nbytes = 1;
   str[0] = XK_minus;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xffab ))
   {
   nbytes = 1;
   str[0] = XK_plus;
   ks = 0;
   }

  else if (( e->state & Mod3Mask ) &&  ( ks == 0xff8d ))
   {
   nbytes = 1;
   str[0] = 0x0d;
   ks = 0;
   }

  else if ((( e->state & Mod3Mask ) &&  ( ks == 0xffff ))
                         && ( e->keycode == 0x39 ))
   {
   nbytes = 1;
   str[0] = XK_period;
   ks = 0;
   }

#endif
/*  status = FIdec_check_keysym( e->window, ks);
  if( status == 0 )  return(6);
  else
    FIdec_rebind_back();*/
  
  if ( ks == XK_Up )   { str[0] = EX_UP_ARROW;   /* up   */ nbytes = 1;}
  else if ( ks == XK_Left ) { str[0] = EX_LEFT_ARROW; /* left */ nbytes = 1;}
  else if ( ks == XK_Down ) { str[0] = EX_DOWN_ARROW; /* down */ nbytes = 1;}
  else if ( ks == XK_Right) { str[0] = EX_RIGHT_ARROW;/* right*/ nbytes = 1;}
  else if ( ( ks >= XK_F1          && ks <= XK_F35 )      || /* function key */
            ( ks >= XK_Home        && ks <= XK_Num_Lock ) ||
            ( ks >= IXK_2ND_FUNC_L && ks <= IXK_B16 )     ||
	    ( ks == XK_Clear )                            )
  {
     if( ( ks == IXK_2ND_FUNC_L)  || ( ks == IXK_2ND_FUNC_R)  )
     {
        EX_2nd_func = 1;
        buf->nbytes = 0;
        return(6);
     }

#if defined (SUNOS) || defined (IRIX)
   if ( e->state & ControlMask )
     {
       if ( ks == XK_F1 )ks = IXK_A1;
       if ( ks == XK_F2 )ks = IXK_A2;
       if ( ks == XK_F3 )ks = IXK_A3;
       if ( ks == XK_F4 )ks = IXK_A4;
       if ( ks == XK_F5 )ks = IXK_A5;
       if ( ks == XK_F6 )ks = IXK_A6;
       if ( ks == XK_F7 )ks = IXK_A7;
       if ( ks == XK_F8 )ks = IXK_A8;
       if ( ks == XK_F9 )ks = IXK_A9;
       if ( ks == XK_F10 )ks = IXK_A10;
       if ( ks == XK_F11 )ks = IXK_A11;
       if ( ks == XK_F12 )ks = IXK_A12;
     }
   else if ( e->state & ShiftMask )
     {
       if ( ks == XK_F1 )ks = IXK_B1;
       if ( ks == XK_F2 )ks = IXK_B2;
       if ( ks == XK_F3 )ks = IXK_B3;
       if ( ks == XK_F4 )ks = IXK_B4;
       if ( ks == XK_F5 )ks = IXK_B5;
       if ( ks == XK_F6 )ks = IXK_B6;
       if ( ks == XK_F7 )ks = IXK_B7;
       if ( ks == XK_F8 )ks = IXK_B8;
       if ( ks == XK_F9 )ks = IXK_B9;
       if ( ks == XK_F10 )ks = IXK_B10;
       if ( ks == XK_F11 )ks = IXK_B11;
       if ( ks == XK_F12 )ks = IXK_B12;
     }
#endif
     buf->data.buffer[0] = str[0];
     buf->nbytes = 1;
     status = EX_process_funckey(buf, mode, ks);
     return (status);
     /* status = 2 for function key exit */
  }        
  else if ( e->state & ControlMask )
  {
       if ( ks == XK_f || ks == XK_F ) str[0] = EX_CTRL_F;      
       if ( ks == XK_b || ks == XK_B ) str[0] = EX_CTRL_B;      
       if ( ks == XK_p || ks == XK_P ) str[0] = EX_CTRL_P;      
       if ( ks == XK_n || ks == XK_N ) str[0] = EX_CTRL_N;      
       if ( ks == XK_a || ks == XK_A ) str[0] = EX_CTRL_A;      
       if ( ks == XK_e || ks == XK_E ) str[0] = EX_CTRL_E;             
       if ( ks == XK_d || ks == XK_D ) str[0] = EX_CTRL_D;
       if ( ks == XK_g || ks == XK_G ) str[0] = EX_CTRL_G;      
       if ( ks == XK_h || ks == XK_H ) str[0] = EX_CTRL_H;      
       if ( ks == XK_k || ks == XK_K ) str[0] = EX_CTRL_K;
  }
  else if ( e->state & Mod1Mask )  /* alt key */
  {
     if( ks == XK_f || ks == XK_w || ks == XK_c || ks == XK_o || ks == XK_h )
     {
        int          msg;
        EXwindata   *exwindata;
        WLuint32     lwin;

        /* check for graphic window, we do not want forms window */

        msg = 1;  /* assume non graphics window */
       
        status = WLget_logical_window ( kevent->xany.window, &lwin );
        if (status == WL_SUCCESS)
        {
           status = WLget_user_data ( lwin, (void **)&exwindata, NULL );
           if (status == WL_SUCCESS)
           {
              if (exwindata->id == EX_GRAPHIC_WINDOW)
              {
                 msg = 0;
              }
           }
        }

        if (msg == 0 ) 
	{
            /* it is graphics or msg window */

            kevent->xany.window = XtWindow(EXtoplevel);
printf("menubar event  window=<%x>\n",kevent->xany.window);     
            XtDispatchEvent(kevent);
            return(6);
        }
     }
  }
  for( i = 0; i<nbytes; i++)
  {
     buf->data.buffer[i] = str[i];
  }
  buf->nbytes = nbytes;

  status = 1;

#endif
#ifdef ENV5
  EX_get_keyboard_data(&count);
  if (buffer == SPECIAL_KEY )
  {
     EX_wait_for_next(KEYBOARD_EVENT, &event);
     EX_get_keyboard_data(&count);
     if      ( (unsigned char) buffer == 0x41 ) buffer = EX_UP_ARROW; /* up   */
     else if ( (unsigned char) buffer == 0x44 ) buffer = EX_LEFT_ARROW; /* left */
     else if ( (unsigned char) buffer == 0x42 ) buffer = EX_DOWN_ARROW; /* down */
     else if ( (unsigned char) buffer == 0x43 ) buffer = EX_RIGHT_ARROW;/* right*/ 
     else if ( (unsigned char) buffer == 0x53 ) buffer = 0x2b;  /*  +   */
     else if ( (unsigned char) buffer == 0x52 ) buffer = 0x2a;  /*  *   */
     else if ( (unsigned char) buffer == 0x51 ) buffer = 0x2f;  /*  /   */
     else if( (( (unsigned char ) buffer >= 0x70 ) &&    
	  ( (unsigned char ) buffer <= 0x79 ) ) ||  /* 70-79 are 0-9  */
         (( (unsigned char ) buffer >= 0x6c ) &&    /* 6c = ,  6d = - */
  	  ( (unsigned char ) buffer <= 0x6e ) ) ||  /* 6e = .         */
	 (  (unsigned char ) buffer == 0x4d   ) ||  /* 4d = enter     */
	 (  (unsigned char ) buffer == 0xbd   )  )	/* bd = enter     */
     {
	 buffer &= 0x3f ;
     }

  }


  buf->data.buffer[0] = buffer;
  buf->nbytes = 1;
  status = 1;

  if (buffer == FUNCTION_key )
  {
     status = EX_process_funckey(buf, mode);
     return (status);
     /* status = 2 for function key exit */
  }
#endif
  kbd_collapsed = 0;
#ifdef ENV5
  if (EX_logkbd )
#endif
#ifdef X11
  if ((EX_logkbd ) && nbytes )
#endif
  {
      /* there is a logical keyboard send keys to it */
      status2 = kill (EX_logkbd,0);
      if (status2 != -1)
      {
        /* status false the process is up and running */
          buf->rc = 3;
	  buf->nbytes = 1;
#ifndef NT
	  status2 =  write(EX_kbd_wrt,buf,sizeof(struct EX_logkbd_buf));
	  status2 = kill (EX_logkbd,SIGUSR1);
#else
	  status2 =  _write(EX_kbd_wrt,buf,sizeof(struct EX_logkbd_buf));
#endif
	  /*  printf ("draft write to np1 status = %d\n",status);*/
	  /*  printf ("write to  np1 buffer = %c\n",buf->data.buffer[0]);*/
	  nbytes = sizeof (struct EX_logkbd_buf);		
	  buf->data.buffer[0] = 0;
#ifndef NT
	  status2 =  read(EX_kbd_rd,buf,nbytes);
#else
	  status2 =  _read(EX_kbd_rd,buf,nbytes);
#endif
	  /*  printf ("draft read  np2 buf = %s\n",buf->data.buffer);*/
	  if (!buf->nbytes)
          {
 	     status = 0;
          }
          else
          {
	    /* if logical keyboard sent back keys-same as cr for english?*/
	     if (buf->rc == 3)
	     {
		kbd_collapsed = 1; /*this is data as we sent it*/
	     }
	     else
	     {
		kbd_collapsed = 1;/*this is for refresh of message strip*/
		nbytes = buf->nbytes;
		buf->data.buffer[nbytes] = 0;/*null*/
		EX_linebuffer_flag = 1; 
		status = 1;/*have keys*/
	     }
     	  }/*end if buf->nbytes true*/
      }/*end if keyboard process exists*/
      else
      {
         /* keyboard used to exist but must have terminated */
         EX_logkbd = 0;
      }
  }/*end if EX_logkbd*/
  if (( !EX_logkbd ) || (kbd_collapsed))
  {
#ifdef ENV5
    if (( buffer == ESCAPE_KEY ) && (esc_flag))
#endif
#ifdef X11
    if (( ks == XK_Escape ) && (esc_flag))
#endif
    {
      EX_keybuff[0] = ESCAPE_KEY;
      EX_keybuff[1] = 0;
      EX_index = 1;
      buf->nbytes = 0;
      status = 3;/*exit for dymanics*/
     }
  }/*end if no log keyboard or it is collapsed*/
  return(status);
}

#ifdef X11

int EX_clear_keyin()
{
    XEvent  event;
    while( XCheckMaskEvent( EXdisplay, KeyPressMask | KeyReleaseMask, &event));
    return(1);
}
#endif
#ifdef ENV5

int EX_clear_keyin()
{
    int count;
    int event;
    
    EX_get_keyboard_data(&count);
    if (buffer == FUNCTION_key )
    {
       EX_get_keyboard_data(&count);
    }
    else  if (buffer == SPECIAL_KEY )
    {
       EX_wait_for_next(KEYBOARD_EVENT, &event);
       EX_get_keyboard_data(&count);
    }
    return(1);
}
#endif
int EX_is_logkbd_inactive() 
{
    int status;
    status = ( !EX_logkbd  || kbd_collapsed );
    return( status );
}
#ifdef ENV5
#include <math.h>
#include <errno.h>

extern double strtod();

int EX_cut_calc_input()
{
   char kbuf[257];
   register char *tmp;
   char *tmp1;
   double xx;
   char out[50];
   int i;
   int found;
   char *end;

   
   for( i = 0; i < 50; out[i]=0,++i);  
   strcpy( kbuf, EX_keybuff);
   tmp = 0;
   tmp = strrchr(kbuf,',');
   end = (char *) (kbuf + EX_index) ;

   if( tmp == 0 ) /* there is no */
   {
       tmp = strrchr(kbuf,'=');
       if ( tmp == 0)
       {
          tmp = kbuf;
       }
       else
       {
          tmp++;
       }
   }
   else
   {
     tmp++;
   }
   errno = 0;
   xx=0;

   /* check for "1space2space3space" , we want the last number */
   found = 1;
   sprintf(out,"%d\n",0);
   while( ( (int) tmp <  (int )end ) )
   {
       xx = strtod( tmp, &tmp1 );
      if( ((int)tmp <  (int) end ) && ( (int ) tmp != (int) tmp1 ) &&  ( errno != ERANGE ) )
      {
         *tmp1++ = 0; 
         strcpy(out,tmp);
         found = 1; 
         tmp = tmp1;
      }
      else
      {
	while( ( (int) tmp1 < (int) end ) && ( !isdigit( *tmp1) ) )
	{
	  tmp1++;
	  tmp = tmp1;
	}
      }
   }

   found = Put_scrap("TEXT",out,strlen(out));

   return(1); 
}


int EX_paste_calc_input()
{
   char *out;
   register int i;
   int siz,indx;
   int status;

   status = Get_scrap("TEXT",(char *) 0, &siz,&indx);

   if( status == NULL )
   {
     if( siz == 0 && indx == -1 )
     {
        /* no data available, do nothing */
         return(1);
     }
     else
     {  out = (char *)malloc (siz + 5);/*add 5 for possible escape character*/
        status=Get_scrap("TEXT",out,&siz,&indx);
        for( i = 0; i< siz && EX_index < 255 ; ++i)
        {
            EX_keybuff[EX_index] = out[i];
            EX_index++;
        }
        EX_keybuff[EX_index] =  0;
        if (EX_echo_flag) 
        {
         if (out[0] == ESCAPE_key)
           {
	       strcpy(out, "<esc>");
           strcat(out,&EX_keybuff[1]);
           UI_echo(out);
           }
          else
           {
           UI_echo(EX_keybuff);
           }
        }

        if (out)
         {
         free (out);
         }
     }
   }
   return(1); 
}
#endif






