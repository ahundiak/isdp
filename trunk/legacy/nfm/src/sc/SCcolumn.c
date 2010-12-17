#include "machine.h"
#include <ctype.h>
#include <time.h>

#include "SCstruct.h"
#include "SCextern.h"
#include "SCrap.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

#define ROWS_IN_FORM	11
#define COLS_IN_FORM	2

/*WINDOW *win;*/			/* window id */
struct SCcolumn_data_st *data;	/* data passed to forms controller */
int data_count;			/* number of elements in data array */
int row_offset;			/* row offset for scrolling */
int max_row_offset;		/* maximum row offset for scrolling */
int first_pos;
int last_pos;
int cur_pos;

int start_x,start_y;

int SCprocess_column_form(user_data, print_file)
struct SCcolumn_data_st *user_data;
char   *print_file;
  {

    data = user_data;

    if( strlen( print_file ) )
    {
	strcpy( SCprint_file, print_file );
	if( SCdebug )
            fprintf(SCconsole,"SC -- SCprint_file <%s>\n",SCprint_file);
    }

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Entering SCprocess_column_form\n");
        fprintf(SCconsole,"SC -- title = <%s>\n",data->title);
        fprintf(SCconsole,"SC -- num_of_rows = %d\n",data->num_of_rows);
        fprintf(SCconsole,"SC -- num_of_cols = %d\n",data->num_of_cols);
        fprintf(SCconsole,"SC -- freeze_rows_count = %d\n",
                data->freeze_rows_count);
        fprintf(SCconsole,"SC -- new_rows_expected = %d\n",
                data->new_rows_expected);
        fprintf(SCconsole,"SC -- select_set_expected = %d\n",
                data->select_set_expected);

/*
        if (data->select_set_expected)
          for(i=0;i<data->num_of_rows;i++)
            fprintf(SCconsole,"SC -- select_set[%d] = %d\n",i,
                    data->select_set[i]);

        for(i=0;i<data->num_of_rows*data->num_of_cols;i++)
          fprintf(SCconsole,"SC -- KT -- hidden[%d] = %d\n",i,
                  data->hidden[i]);

        for(i=0;i<data->num_of_rows * data->num_of_cols;i++)
          fprintf(SCconsole,"SC -- selectable[%d] = %d\n",i,data->selectable[i]);

        for(i=0;i<data->num_of_rows * data->num_of_cols;i++)
          if (data->data[i] != NULL)
            fprintf(SCconsole,"SC -- data[%d] = <%s>\n",i,data->data[i]);
          else
            fprintf(SCconsole,"SC -- data[%d] = NULL\n",i);
*/
      }

    SCcol_win = newwin(16,80,5,0);
    keypad(SCcol_win,TRUE);
  
    data_count = data->num_of_cols * data->num_of_rows;
    row_offset = 0;
    max_row_offset = data->num_of_rows - ROWS_IN_FORM;
/*
    if (max_row_offset < 0)
      max_row_offset = 0;
*/
      
    if (SCdebug)
      {
         fprintf(SCconsole,"SC -- num_of_rows = %d\n",data->num_of_rows);
         fprintf(SCconsole,"SC -- data_count = %d\n",data_count);
         fprintf(SCconsole,"SC -- max_row_offset = %d\n",max_row_offset);
      }

    if (data->new_rows_expected)
      {
        SCadd_a_null_row(SETUP);
      }

/*
    if (SCdebug)
      {
        if (data->select_set_expected)
          {
            for (i=0;i<data->num_of_rows;i++)
              fprintf(SCconsole,"SC -- select_set[%d] = %d\n",i,
                      data->select_set[i]);
          }
      }
*/

    SCfill_in_title(SCcol_win,data->title);

    SCfill_column_table(SETUP);

    SCcolumn_form_input();

/*
    if (SCdebug)
      {
        if (data->select_set_expected)
          for(i=0;i<data->num_of_rows;i++)
            fprintf(SCconsole,"SC -- select_set[%d] = %d\n",i,
                    data->select_set[i]);

        for(i=0;i<data->num_of_rows * data->num_of_cols;i++)
          fprintf(SCconsole,"SC -- selectable[%d] = %d\n",i,data->selectable[i]);

        for(i=0;i<data->num_of_rows * data->num_of_cols;i++)
          if (data->data[i] != NULL)
            fprintf(SCconsole,"SC -- data[%d] = <%s>\n",i,data->data[i]);
          else
            fprintf(SCconsole,"SC -- data[%d] = NULL\n",i);

        fprintf(SCconsole,"SC -- Exiting SC.process_column_form\n");
      }
*/

    return (0);
  }  /* SCprocess_column_form */

int SCcolumn_form_input()
  {
    int i;
    int x,y;
    int old_offset;
    int old_pos,new_pos;
    int ok_to_loop;
    int keyin_count;
    char keyin_string[500];
    char d_msg[80];
    chtype ch;
    int len,cur_col;
    int no_selectables = FALSE;

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Entering SCcolumn_form_input\n");
      }

    for (i=0;i<data_count;i++)
      if (data->selectable[i])
        {
          cur_pos = i;
          break;
        }
    if (i == data_count)
      {
        /* none of the fields are selectable */
        no_selectables = TRUE;
        cur_pos = data->freeze_rows_count * data->num_of_cols;
      }

    place_cursor();
    ok_to_loop = TRUE;
    keyin_count = 0;
    
    while(ok_to_loop)
      {
        old_pos = cur_pos;
        ch = getch_rap();

/*
        if (SCdebug)
          {
            fprintf(SCconsole,"ch = %d\n",ch);
          }
*/

        switch(ch)
          {
            case KEY_F(1):
            case KEY_F(6):  /* IntelPort workaround - srinivas 16th May 1995 */
            if (SCdebug) 
                fprintf(SCconsole,"Accept Key ch = %d\n",ch);
              /* ACCEPT */
              if (keyin_count)
                {
                  put_string(&data->data[cur_pos],keyin_string);
                }
              data->sts = FORM_ACCEPTED;
#ifdef OS_HPUX
   /* Curses changes - HP PORT - IGI - 30 Jun 94 */
	      wmove(SCcol_win,0,0);
	      wclrtobot(SCcol_win);
	      wrefresh(SCcol_win);
	      if(strcmp(getenv("TERM"), "hpterm") == 0 ||
	         strcmp(getenv("TERM"), "hp") == 0)
                 getch();
#endif
              delwin(SCcol_win);
              SCcol_win = NULL;
              ok_to_loop = FALSE;
              break;
            case KEY_F(2):
              /* PRINT */
	      SCprint_column_table();
              sprintf (d_msg, "Listing Generated: \"%s\"", SCprint_file); 
#ifdef OS_HPUX
              /* Curses changes - HP PORT - IGI - 30 Jun 94 */
	      if(strcmp(getenv("TERM"), "hpterm") == 0 ||
	         strcmp(getenv("TERM"), "hp") == 0)
                 getch();
#endif
              SCdisplay_msg (d_msg);
              break; 
            case KEY_F(3):
              /* ACCEPT */
              data->sts = FORM_CANCELED;
#ifdef OS_HPUX
   /* Curses changes - HP PORT - IGI - 30 Jun 94 */
	      wmove(SCcol_win,0,0);
	      wclrtobot(SCcol_win);
	      wrefresh(SCcol_win);
	      if(strcmp(getenv("TERM"), "hpterm") == 0 ||
	         strcmp(getenv("TERM"), "hp") == 0)
                 getch();
#endif
              delwin(SCcol_win);
              SCcol_win = NULL;
              ok_to_loop = FALSE;
              break;
            case KEY_F(4):
              /* Entire Form Selected */
              if (data->select_set_expected == SELECT_SET_MULTI_ROW)
                  {
                  data->sts = FORM_SELECTED;
#ifdef OS_HPUX
   /* Curses changes - HP PORT - IGI - 1 Jul 94 */
	          wmove(SCcol_win,0,0);
	          wclrtobot(SCcol_win);
	          wrefresh(SCcol_win);
	      if(strcmp(getenv("TERM"), "hpterm") == 0 ||
	         strcmp(getenv("TERM"), "hp") == 0)
                 getch();
#endif
                  delwin(SCcol_win);
                  SCcol_win = NULL;
                  ok_to_loop = FALSE;
                  }
              break;
            case 127:
            case 8:
              if (keyin_count > 0)
                {
                  keyin_count--;
                  keyin_string[keyin_count] = 0;
                  cur_col = cur_pos % data->num_of_cols;
                  if (keyin_count >= data->col_width[cur_col] - 1)
                    {
                      if (!data->hidden[cur_pos])
                        {
                        wmove(SCcol_win,start_y,start_x);
                        waddstr(SCcol_win,keyin_string +
                                (keyin_count - data->col_width[cur_col]) + 1);
                        }
                    }
                  else
                    {
                      if (!data->hidden[cur_pos])
                        {
                        getyx(SCcol_win,y,x);
                        mvwaddch(SCcol_win,y,x-1,' ');
                        wmove(SCcol_win,y,x-1);
                        }
                    }
                  wrefresh(SCcol_win);
                }
              break;
            case KEY_UP:
            case KEY_RIGHT:
            case KEY_LEFT:
              if (keyin_count)
                {
                  put_string(&data->data[cur_pos],keyin_string);
                  SCfill_column_table(RUN_TIME);
                  place_cursor();
                  keyin_count = 0;
                }
              switch(ch)
                {
                  case KEY_UP:
                    new_pos = cur_pos - data->num_of_cols;
                    if ((data->selectable[new_pos] || no_selectables) &&
                        new_pos >= data->freeze_rows_count * data->num_of_cols)
                      {
                        cur_pos = new_pos;
                        break;
                      }
                  case KEY_LEFT:
                    cur_pos --;
                    while(!(data->selectable[cur_pos]||no_selectables) &&
                          cur_pos >= data->freeze_rows_count * data->num_of_cols)
                      cur_pos --;
                    if (cur_pos < data->freeze_rows_count * data->num_of_cols)
                      cur_pos = old_pos;
                    break;
                  case KEY_RIGHT:
                    cur_pos ++;
                    while(!(data->selectable[cur_pos] || no_selectables) &&
                           cur_pos < data_count)
                      cur_pos++;
      
                    if (cur_pos >= data_count)
                      cur_pos = old_pos;
                    break;
                }
              old_offset = row_offset;
              if (cur_pos < first_pos)
                {
                  row_offset -=(ROWS_IN_FORM - data->freeze_rows_count)/2;
                  if (row_offset < 0)
                    row_offset = 0;
                }
              if (cur_pos > last_pos)
                {
                  row_offset +=(ROWS_IN_FORM - data->freeze_rows_count)/2;
                  if (row_offset > max_row_offset)
                    {
                      if (max_row_offset > 0)
                        row_offset = max_row_offset;
                      else
                        row_offset = 0;
                    }
                }
              if (row_offset != old_offset)
                SCfill_column_table(RUN_TIME);
              place_cursor();
              break;

            case KEY_DOWN:
            case '\n':
            case 13:
              if (keyin_count)
                {
                /* KT - treat like RETURN */
                  if (no_selectables == FALSE)
                    {
                      put_string(&data->data[cur_pos],keyin_string);
                      if (data->new_rows_expected)
                        {
                          if (cur_pos >= data_count - data->num_of_cols)
                            SCadd_a_null_row(SETUP);
                        }
                      keyin_count = 0;
                    }
                }

/**/
              switch(ch)
                {
                  case KEY_DOWN:
                    new_pos = cur_pos + data->num_of_cols;
                    if ((data->selectable[new_pos] || no_selectables) &&
                        new_pos >= data->freeze_rows_count * data->num_of_cols)
                      {
                        cur_pos = new_pos;
/* KT */
                        if (cur_pos >= data_count)
                          cur_pos = old_pos;
                        break;
                      }
/**/
                  case '\n':
                  case 13:
                    cur_pos ++;
                    while(!(data->selectable[cur_pos] || no_selectables) &&
                          cur_pos < data_count)
                      cur_pos++;

                    if (cur_pos >= data_count)
                      cur_pos = old_pos;
                    break;
                }
/**/

                old_offset = row_offset;
                if (cur_pos > last_pos)
                  {
                    row_offset +=(ROWS_IN_FORM - data->freeze_rows_count)/2;
                    if (row_offset > max_row_offset)
                      {
                        if (max_row_offset > 0)
                          row_offset = max_row_offset;
                        else
                          row_offset = 0;
                      }
                  }
/*
                if (row_offset != old_offset)
*/
                  SCfill_column_table(RUN_TIME);
                place_cursor();
/*
              else
                {
                  new_pos = cur_pos + data->num_of_cols;
                  new_pos = cur_pos++;
                  if ((data->selectable[new_pos] || no_selectables) &&
                      new_pos < data_count)
                    {
                      cur_pos = new_pos;
                    }
                  old_offset = row_offset;
                  if (cur_pos < first_pos)
                    {
                      row_offset -=(ROWS_IN_FORM - data->freeze_rows_count)/2;
                      if (row_offset < 0)
                        row_offset = 0;
                    }
                  if (cur_pos > last_pos)
                    {
                      row_offset +=(ROWS_IN_FORM - data->freeze_rows_count)/2;
                      if (row_offset > max_row_offset)
                        {
                          if (max_row_offset > 0)
                            row_offset = max_row_offset;
                          else
                            row_offset = 0;
                        }
                    }
                  if (row_offset != old_offset)
                    SCfill_column_table(RUN_TIME);
                  place_cursor();
                }
*/
              break;

	   /* work around for ENTER key on SCO/SUN/SOLARIS -- MVR 20 Dec 1993 */
            case KEY_F(5):
            case KEY_ENTER:
              if (data->select_set_expected)
                {
/* KT - 3/19/93 - Another workaround for "add files to item". This command 
                  calls SCprocess_column_form with SELECT_SET_MULTI_ROW!
                  It was never designed to work this way!
*/
                  if (data->select_set_expected == SELECT_SET_SINGLE_ROW)
                      {
                      if (data->select_set[cur_pos/data->num_of_cols])
                        data->select_set[cur_pos/data->num_of_cols] = 0;
                      else
                        data->select_set[cur_pos/data->num_of_cols] = 1;
                      SCfill_column_table(RUN_TIME);
                      place_cursor();
                      keyin_count = 0;
                      }
                }
              break;
            default:
              if (no_selectables == FALSE && isprint(ch))
                {
                  cur_col = cur_pos % data->num_of_cols;

                  if (keyin_count == 0)
                    {
                      /*len = strlen(data->data[cur_pos]);*/
	              /* These set of statements are replaced for the above
                         statement to avoid SEGV errorsometimes.
                         SSRS - 23/11/93
                      */
                      len = 0;
	              if(data->data[cur_pos] != NULL)
	                  len = strlen(data->data[cur_pos]);
	
                      if (len > data->col_width[cur_col])
                        len = data->col_width[cur_col];

                      for (i=0;i<len;i++)
                        waddch(SCcol_win,' ');
                      place_cursor();
                    }

/* 2/15/93 - KT - Causes signal 7 in "add_files_to_item". This function calls
                  SCprocess_column_form with 
                    select_set_expected = SELECT_SET_MULTI_ROW.
                  SCprocess_column_form was never supposed to handle this!
                  I searched ALL sc interface code, no other commands use this!
                  if (data->select_set_expected)
                    if (data->select_set[cur_pos/data->num_of_cols])
                      wattrset(SCcol_win,A_UNDERLINE);

*/

                  /* ignore any keyins after 500 */
                  if (keyin_count < 499)
                    {
                    keyin_string[keyin_count++] = ch;
                    keyin_string[keyin_count] = 0;
                    }
                    
                  if ((keyin_count >= data->col_width[cur_col]) &&
                      (!data->hidden[cur_pos]))
                    {
                      wmove(SCcol_win,start_y,start_x);
                      waddstr(SCcol_win,keyin_string +
                              (keyin_count - data->col_width[cur_col]) + 1);
                      wrefresh(SCcol_win);
                    }
                  else
                    {
                    /* display character if not hidden or ignored */
                    if ((!data->hidden[cur_pos]) && (keyin_count < 500))
                      {
                      wechochar(SCcol_win,ch);
                      }
                    }
                  wattrset(SCcol_win,0);
                }
              break;
          } /* switch */
      }
    if (data->new_rows_expected)
      {
        data->num_of_rows--;
        max_row_offset--;
        data_count -= data->num_of_cols;
      }
    return (0);
  }

int SCfill_column_table(mode)
int mode;
  {

    int count;
    int row,col,i;
    int pos;
    int screen_col;
    int begin_col;
    int len;
    char string[500];
    char row_string[500];

/**/

    first_pos = (data->freeze_rows_count + row_offset) *
                       data->num_of_cols;

    for (row=0;row<ROWS_IN_FORM && row<data->num_of_rows;row++)
      {
        if (row >= data->freeze_rows_count || mode == SETUP)
          {
            row_string[0] = 0;
            screen_col = 0;
/*
            wmove (SCcol_win, row+3, screen_col);
            wclrtoeol (SCcol_win);
*/

            for (col=0;col<data->num_of_cols;col++)
               {
                pos = (row + row_offset) * data->num_of_cols + col;
                if (pos < data_count)
                  {
                    if (data->selectable[pos])
                      row_string[screen_col] = '[';
                    else
                      row_string[screen_col] = ' ';
                    screen_col++;
                    begin_col = screen_col;

                    if (data->select_set_expected)
                      { 
                        count = row + row_offset;
/*
                        if (data->select_set[count])
                          wattrset(SCcol_win,A_UNDERLINE);
*/
                      } /* if (select_set_expected) */

                    if (data->data[pos] != NULL)
                      {
                        if (!data->hidden[pos])
                          strcpy(string,data->data[pos]);
                        else
                          strcpy (string, "");
                        len = strlen(data->data[pos]);
                        if (len > data->col_width[col])
                          string[data->col_width[col]] = 0;
                      }
                    else
                      {
                      	for (i=0; i<data->col_width[col]; ++i)
                      	    {
                      	    string[i] = ' ';
                      	    }
                        string[data->col_width[col]] = 0;
                      }

                    for (i=0; string[i]!=0; ++i, ++screen_col)
                        {
                        row_string[screen_col] = string[i];
                        }
                    
                    for (i=screen_col; i<begin_col+data->col_width[col];
                         ++i, ++screen_col)
                        {
                        row_string[i] = ' ';
                        }

/*
                    wattrset(SCcol_win,0);
*/

                    if (data->selectable[pos])
                      row_string[screen_col] = ']';
                    else
                      row_string[screen_col] = ' ';
                    screen_col++;

                    last_pos = pos;
                  }
              }

            row_string[screen_col] = 0;
            mvwaddstr(SCcol_win, row+3, 0, row_string);

          } /* if (row >= data->freeze_rows_count || mode == SETUP) */
      } /* for (row=0;row<ROWS_IN_FORM && row<data->num_of_rows;row++) */

    wrefresh(SCcol_win);

    return (0);
  }

int SCadd_a_null_row(mode)
int mode;
  {
    int i,j;
    int new_row;
    int *l_select_set;
    int *l_selectable;
    int *l_hidden;
    char **l_data;

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Entering add_a_null_row()\n");
      }


    data->num_of_rows++;
    max_row_offset++;
    data_count += data->num_of_cols;

/* per row items */
    /* save current values */
    if (data->select_set_expected)
      {
        l_select_set = data->select_set;

        /* malloc space for new values */
        data->select_set = (int *)malloc(sizeof(int) * data->num_of_rows);
    
        /* copy old values into new space */
        for (i=0;i<data->num_of_rows - 1;i++)
          {
            data->select_set[i] = l_select_set[i];
          }

        /* set new value */
        data->select_set[i] = 0;
    
        /* free old space */
        free(l_select_set);
      }

/* per data items */
    /* save current values */
    l_selectable = data->selectable;
    l_hidden = data->hidden;
/*
    l_fn_ptr = data->fn_ptr;
    l_fn_arg = data->fn_arg;
*/
    l_data = data->data;

    /* malloc space for new values */
    data->selectable = (int *)malloc(sizeof(int) * data_count);
    data->hidden = (int *)malloc(sizeof(int) * data_count);
/*
    data->fn_ptr = (int *)malloc(sizeof(int *) * data_count);
    data->fn_arg = (char *)malloc(sizeof(char *) * data_count);
*/
    data->data = (char **)malloc(sizeof(char *) * data_count);

    /* copy old values into new space */
    for (i=0;i<data_count - data->num_of_cols;i++)
      {
        data->selectable[i] = l_selectable[i];
        data->hidden[i] = l_hidden[i];
/*
        data->fn_ptr[i] = l_fn_ptr[i];
        data->fn_arg[i] = l_fn_arg[i];
*/
        data->data[i] = l_data[i];
      }

    /* set new value */
    for (j=0;j<data->num_of_cols;j++)
      {
        data->selectable[i+j] = 1;
        data->hidden[i+j] = 0;
/*
        data->fn_ptr[i+j] = data->new_fn_ptr[j];
        data->fn_arg[i+j] = data->new_fn_arg[j];
*/
	data->data[i+j] = (char *) malloc (2);
	strcpy (data->data[i+j], "");
      }

    /* free old space */
    free(l_selectable);
    free(l_hidden);
/*
    free(l_fn_ptr);
    free(l_fn_arg);
*/
    free(l_data);

    if (mode == RUN_TIME)
      {
        new_row = data->num_of_rows - 1;

        if (new_row < ROWS_IN_FORM)
          { /* need to display a new row */
            SCfill_column_table(RUN_TIME);
          }
    
        if (SCdebug)
          {
            fprintf(SCconsole,"SC -- After add_a_null_row() . . .\n");
            fprintf(SCconsole,"SC -- num_of_rows = %d\n",data->num_of_rows);
            fprintf(SCconsole,"SC -- data_count = %d\n",data_count);
            fprintf(SCconsole,"SC -- max_row_offset = %d\n",max_row_offset);
          }
      }
    return (0);
  }

int SCfill_in_title (win,title)
WINDOW *win;
char *title;
  {
    int i,len;

    if (title != NULL)
      {
        len = strlen(title);

        wmove(win,0,0);
        for (i=0;i<80 && i<len;i++)
          waddch(win,title[i]);

/*
        wmove(win,1,0);
        for (;i<len;i++)
          waddch(win,title[i]);
*/
      }
    return (0);
  }

int place_cursor()
  {
    int i,y,x;

    y = cur_pos/data->num_of_cols;
    x = cur_pos%data->num_of_cols;

    start_y = y - row_offset + 3;
    start_x = 0;
    i = 0;

    while (1)
      {
        start_x++;
        if (i == x)
          break;
        start_x += data->col_width[i];
        start_x++;
        i++;
      }

    wmove(SCcol_win,start_y,start_x);
    wrefresh(SCcol_win);

    return (0);
 }

/* Routine to dump column structure to SCprint_file - JM - Oct. 10, 1990
 */
int SCprint_column_table()
  {
    FILE *fopen();
    FILE *outfile;
 
    int count;
    int row,col,i;
    int pos;
    int screen_col;
    int begin_col;
    int len;

    char string[500];
    char row_string[500];

    long   now_time;
    
    struct tm *the_stamp;

    if (SCdebug)
    {
        fprintf(SCconsole,"SC -- Entering SCprint_column_table\n");
	fprintf(SCconsole,"SC -- Print File <%s>\n", SCprint_file );
	fprintf(SCconsole,"SC -- Num of rows <%d>\n", data->num_of_rows );
    }

    if( ( outfile = fopen( SCprint_file, "a" )) == NULL )
  	return( 1 );

    memset( string, '-', 80 );
    fprintf( outfile, "\n\n%s\n", string );

/*  Date/time stamp
 */
    time( &now_time );
    the_stamp = localtime( &now_time );
/******************************************************************************
/* Year 2000 Fixes - Ravi 30 May 1998
/* Replacing 2 digit year with 4 digit year.
/* Adding 1900 to tm_year.
/* Print format changed from .2d to .4d for tm_year.
******************************************************************************/
/*
    sprintf( string, "  Date --> %.2d/%.2d/%.2d  Time --> %.2d:%.2d:%.2d",
	     (the_stamp->tm_mon)+1, the_stamp->tm_mday, the_stamp->tm_year,
              the_stamp->tm_hour, the_stamp->tm_min, the_stamp->tm_sec );
*/

    sprintf( string, "  Date --> %.2d/%.2d/%.4d  Time --> %.2d:%.2d:%.2d",
	     (the_stamp->tm_mon)+1, the_stamp->tm_mday, the_stamp->tm_year+1900,
              the_stamp->tm_hour, the_stamp->tm_min, the_stamp->tm_sec );

/* End of Year 2000 Fixes */

    fprintf( outfile, "\n%s\n", string );

/*  Fill in title 
 */
    if (data->title != NULL)
	fprintf( outfile, "\n%s\n\n", data->title );

    first_pos = (data->freeze_rows_count + row_offset) *
                       data->num_of_cols;

    for (row=0;row<data->num_of_rows;row++)
      {
       if (row >= data->freeze_rows_count)
          {
            row_string[0] = 0;
            screen_col = 0;

            for (col=0;col<data->num_of_cols;col++)
               {
                pos = (row + row_offset) * data->num_of_cols + col;
                if (pos < data_count)
                  {
                    if (data->selectable[pos])
                      row_string[screen_col] = '[';
                    else
                      row_string[screen_col] = ' ';
                    screen_col++;
                    begin_col = screen_col;

                    if (data->select_set_expected)
                      { 
                        count = row + row_offset;
                      } /* if (select_set_expected) */

                    if (data->data[pos] != NULL)
                      {
                        if (!data->hidden[pos])
                          strcpy(string,data->data[pos]);
                        else
                          strcpy (string, "");
                        len = strlen(data->data[pos]);
                        if (len > data->col_width[col])
                          string[data->col_width[col]] = 0;
                      }
                    else
                      {
                      	for (i=0; i<data->col_width[col]; ++i)
                      	    {
                      	    string[i] = ' ';
                      	    }
                        string[data->col_width[col]] = 0;
                      }

                    for (i=0; string[i]!=0; ++i, ++screen_col)
                        {
                        row_string[screen_col] = string[i];
                        }
                    
                    for (i=screen_col; i<begin_col+data->col_width[col];
                         ++i, ++screen_col)
                        {
                        row_string[i] = ' ';
                        }
                    if (data->selectable[pos])
                      row_string[screen_col] = ']';
                    else
                      row_string[screen_col] = ' ';
                    screen_col++;

                    last_pos = pos;
                  }
              }

            row_string[screen_col] = 0;

	    fprintf( outfile, "%s\n", row_string );
 	}
      } /* for (row=0;row<data->num_of_rows;row++) */

    fclose( outfile );
    return( 0 );
  }
