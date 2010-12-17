#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include "SCstruct.h"
#include "SCextern.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

extern int rap_enabled;
extern int record;
extern int playback;

int put_string(to_string,cp_string)
char **to_string;
char *cp_string;
  {

    if (*to_string != NULL)
      {
        free(*to_string);
        *to_string = NULL;
      }
    if (cp_string != NULL)
      {
        *to_string = (char *)malloc(strlen(cp_string) + 1);
        strcpy(*to_string,cp_string);
      }
    return (0);
  }

int SCdisplay_msg(s)
char *s;
  {
    int i,len;
    int x,y;
    /* KT - files for message output */
    char message_file[20];
    FILE *messages;

    getsyx(y,x);
    memset(SCmsg_string,' ',80);
    SCmsg_string[80] = 0;

    len = strlen(s);
    if (len > 78)
      len = 78;

    memcpy(SCmsg_string+1,s,len);

    for(i=1;i<=len;i++)
      if (SCmsg_string[i] == '\n')
        SCmsg_string[i] = ' ';

    if (SCdebug)
      fprintf(SCconsole,"SCmsg_string = <%s>\n",SCmsg_string);
    mvwaddstr(SCmsg_win,0,0,SCmsg_string);
/*
    wnoutrefresh(SCmsg_win);
    setsyx(y,x);
    doupdate();
*/

    setsyx(y,x);
    wrefresh(SCmsg_win);

    /* if rap_enabled, write message to file */
    /* KT - 3/18/93 - rap_enabled may be set even though record and playback 
                      are turned off - only open message file if RAP is
                      enabled AND either record or playback is also enabled
    */
    if ((rap_enabled) && ((record) || (playback)))
        {
        if (record)
            strcpy (message_file, "./ATPrecord.msg");
        else if (playback)
            strcpy (message_file, "./ATPplaybk.msg");

        if ((messages = fopen (message_file,"a")) == NULL)
            {
            fprintf(stderr,"%s: unable to open \"%s\" for ATP messages\n",
                    "SC", message_file);
            exit(1);
            }
        fprintf (messages, "ATP: <%s>\n", s);
        fclose (messages);
        }

    return (0);
  }

int SCclear_msg()
  {
    int x,y;

    getsyx(y,x);
    memset(SCmsg_string,' ',80);
    SCmsg_string[80] = 0;

    mvwaddstr(SCmsg_win,0,0,SCmsg_string);

    setsyx(y,x);
    wrefresh(SCmsg_win);

    return (0);
  }

int SCdisplay_ref(s)
char *s;
  {
    int i,len;
    int x,y;

    getsyx(y,x);
    memset(SCref_string,' ',80);
    SCref_string[80] = 0;

    len = strlen(s);
    if (len > 78)
      len = 78;

    memcpy(SCref_string+1,s,len);

    for(i=1;i<=len;i++)
      if (SCref_string[i] == '\n')
        SCref_string[i] = ' ';

    if (SCdebug)
      fprintf(SCconsole,"SCref_string = <%s>\n",SCref_string);
    mvwaddstr(SCref_win,0,0,SCref_string);

/*
    wnoutrefresh(SCref_win);
    setsyx(y,x);
    doupdate();
*/

    setsyx(y,x);
    wrefresh(SCref_win);

    return (0);
  }

int SCclear_ref()
  {
    int x,y;

    getsyx(y,x);
    memset(SCref_string,' ',80);
    SCref_string[80] = 0;

    mvwaddstr(SCref_win,0,0,SCref_string);

/*
    wnoutrefresh(SCref_win);
    setsyx(y,x);
    doupdate();
*/

    setsyx(y,x);
    wrefresh(SCref_win);

    return (0);
  }

int SCdisplay_err(s)
char *s;
  {
    int i,len;
    int x,y;

    getsyx(y,x);
    memset(SCerr_string,' ',80);
    SCerr_string[80] = 0;

    len = strlen(s);
    if (len > 78)
      len = 78;

    memcpy(SCerr_string+1,s,len);

    for(i=1;i<=len;i++)
      if (SCerr_string[i] == '\n')
        SCerr_string[i] = ' ';

    if (SCdebug)
      fprintf(SCconsole,"SCerr_string = <%s>\n",SCerr_string);
    mvwaddstr(SCerr_win,0,0,SCerr_string);

/*
    wnoutrefresh(SCerr_win);
    setsyx(y,x);
    doupdate();
*/

    setsyx(y,x);
    wrefresh(SCerr_win);

    return (0);
  }

int SCclear_err()
  {
    int x,y;

    getsyx(y,x);
    memset(SCerr_string,' ',80);
    SCerr_string[80] = 0;

    mvwaddstr(SCerr_win,0,0,SCerr_string);

/*
    wnoutrefresh(SCerr_win);
    setsyx(y,x);
    doupdate();
*/

    setsyx(y,x);
    wrefresh(SCerr_win);

    return (0);
  }

int SCclear_col_form()
  {

if (SCdebug) fprintf (SCconsole, "Enter SCclear_col_form.\n");

    SCcol_win = newwin(16,80,5,0);
    wclrtobot (SCcol_win);
    wrefresh (SCcol_win);
    delwin(SCcol_win);
    SCcol_win = NULL;

if (SCdebug) fprintf (SCconsole, "Exit SCclear_col_form.\n");
    return (0);
  }


int SCclear_free_form()
  {

if (SCdebug) fprintf (SCconsole, "Enter SCclear_free_form.\n");

    SCfree_win = newwin(19,80,5,0);
    wclrtobot (SCfree_win);
    wrefresh (SCfree_win);
    delwin(SCfree_win);
    SCfree_win = NULL;

if (SCdebug) fprintf (SCconsole, "Exit SCclear_free_form.\n");
    return (0);
  }

int data_in_string(pos,width,just,data,string,string_len)
int pos,width,just;
char data[],string[];
int string_len;
  {
    int length;
    int diff;
    char temp[80];

    if (pos >= string_len)
      return (0);

    memset(temp,0,80);

    length = strlen(data);
    if (length >= width) {
      switch (just) {
        case LEFT_JUSTIFIED:
        case CENTER_JUSTIFIED:
          strncpy(temp,data,width);
          break;
        case RIGHT_JUSTIFIED:
          strncpy(temp,&data[length-width],width);
          break;
      }
    }
    else { /* length < width */
      switch (just) {
        case LEFT_JUSTIFIED:
          strncpy(temp,data,width);
          break;
        case CENTER_JUSTIFIED:
          diff = (width-length)/2;
          memset(temp,' ',diff);
          strncpy(&temp[diff],data,length);
          break;
        case RIGHT_JUSTIFIED:
          diff = width-length;
          memset(temp,' ',diff);
          strncpy(&temp[diff],data,length);
          break;
      }
    } /* length < width */

    length = strlen(temp);
    if ((pos + length) > string_len)
     length = string_len - pos;
    strncpy(&string[pos],temp,length);

    return (0);
}


clear_array_except(n,a,size)
int n;
int a[];
int size;
  {
    int i;

    for (i=0;i<size;i++)
      if (i != n)
        a[i] = 0;
  }

int strncmp_ignore_case(s1,s2,n)
char *s1;
char *s2;
int n;
  {
    int i;
    char c1,c2;

    for (i=0;i<n;i++)
      {
        if (isupper(s1[i]))
          c1 = tolower(s1[i]);
        else
          c1 = s1[i];

        if (isupper(s2[i]))
          c2 = tolower(s2[i]);
        else
          c2 = s2[i];

        if (c1 != c2)
          return(c1 - c2);

        if (c1 == 0 || c2 == 0)
          break;
      }
    return(0);
  }

char *SCfgets (s, n, stream)
  char   *s;
  int    n;
  FILE   *stream;
  {
    char *sts, *strchr ();

    if ((sts = fgets (s, n, stream)) == NULL)
        return (sts);

    if ((sts = strchr (s, '\n')) == NULL)
        return (s);

    *sts = NULL;

    return (s);
  }


#ifdef OS_HPUX

/* These two functions are not available in the curses library of
   HP9000s700 series of machines. These routines are written to
   simulate the functionality. IGI - 1 July 94
*/

wechochar(win, ch)
WINDOW *win;
int ch;
{
   waddch(win,(chtype) ch);
   wrefresh(win);
}

touchline(win,start,count)
WINDOW *win;
int start,count;
{
  
   WINDOW *swin;
  
   swin = subwin(win,count,80,start,0);
   touchwin(swin);
}
#endif
