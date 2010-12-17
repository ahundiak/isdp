#include "machine.h"
#include <ctype.h>
#include <time.h>

#include "SCstruct.h"
#include "SCextern.h"
#include "SCrap.h"
#include "DEBUG.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

#define FULL_TABLE	0
#define LINE_UP		1
#define LINE_DOWN	2

#define MAX_COLUMN_COUNT	80
#define KEYIN_BUFFER_SIZE	10

extern WINDOW *cmd_win;
/*WINDOW *win;*/
struct SCfree_data_st *data;	/* data passed to forms controller */
int data_count;			/* number of elements in data array */
int row_offset;			/* row offset for scrolling */
int col_offset;			/* column offset for scrolling */
int max_row_offset;		/* maximum row offset for scrolling */
int max_col_offset;		/* maximum column offset for scrolling */
int num_rows_in_form;		/* number of rows in form */
int num_cols_in_form;		/* number of columns in form */
int scroll_offset;		/* width of columns scrolled off to the left */
int freeze_width;		/* width of frozen columns */
int display_width;		/* width of displayed data */

int cur_row,cur_col;
int col_too_wide;
int page_x,page_y;

int  vertical_print;		/* flag for printing vertically */

char string[81];
chtype ch;

int SCprocess_free_form(user_data, print_file)
struct SCfree_data_st *user_data;
char   *print_file;
  {
    int  i;
    int  total_width;		/* Total width of ALL data */

    char page_str[4];

    data           = user_data;
    vertical_print = 0;

    if( strlen( print_file ) )
    {
	strcpy( SCprint_file, print_file );
  	if( SCdebug )
	    fprintf(SCconsole, "SC -- SCprint_file <%s>\n", SCprint_file);
    }

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Entering SCprocess_form\n");
        fprintf(SCconsole,"SC --   title = <%s>\n",data->title);
        fprintf(SCconsole,"SC --   num_of_cols = %d\n",data->num_of_cols);
        fprintf(SCconsole,"SC --   num_of_rows = %d\n",data->num_of_rows);
        fprintf(SCconsole,"SC --   freeze_col_count = %d\n",
                data->freeze_cols_count);
        fprintf(SCconsole,"SC --   freeze_rows_count = %d\n",
                data->freeze_rows_count);
        fprintf(SCconsole,"SC --   select_set_expected = %d\n",
                   data->select_set_expected);
        for (i=0;i<data->num_of_cols;i++)
          {
            fprintf(SCconsole,"SC -- Col %2d  Pos:%3d  Size:%3d  Just:%3d\n",
                    i,
                    data->col_pos[i],
                    data->col_size[i],
                    data->col_just[i]);
          }
        fprintf(SCconsole,"SC --   max_indent = %d\n",data->max_indent);
      }

    SCfree_win = newwin(19,80,5,0);
    keypad(SCfree_win,TRUE);

    data_count = data->num_of_cols * data->num_of_rows;
    col_offset = 0;
    row_offset = 0;
    cur_row = 0;
    cur_col = 0;

/* get current number of columns in form */
    num_cols_in_form = 0;
    for (i=0;i<data->num_of_cols; i++)
      {
        if ((data->col_pos[i] +
            data->col_size[i]) > MAX_COLUMN_COUNT)
          break;
        num_cols_in_form++;
      }

    i = data->num_of_cols - 1;
    total_width = data->col_pos[i] + data->col_size[i];
    if( total_width > 132 )
	vertical_print = TRUE;
    /* KT - April 2, 1990 */
/*
    if (num_cols_in_form > 1)
*/
        freeze_width = data->col_pos[data->freeze_cols_count];
/*
    else
        freeze_width = data->col_size[0];
*/

    scroll_offset = data->col_pos[col_offset + data->freeze_cols_count];

    display_width = data->col_pos[num_cols_in_form-1 + col_offset] +
                    data->col_size[num_cols_in_form-1 + col_offset];

/* get max_col_offset */
    max_col_offset = data->num_of_cols;
    for (i=data->num_of_cols-1;i>=0;i--)
      {
        if (data->col_pos[i] <
           (total_width - MAX_COLUMN_COUNT + freeze_width))
          break;
        max_col_offset--;
      }
    max_col_offset -= data->freeze_cols_count;

    num_rows_in_form = 10;
    max_row_offset = (data->num_of_rows - 1)/10 * 10;


    if (data->num_of_rows <= num_rows_in_form)
      { /* no vertical scrolling */
      }
    else
      { /* Vertical scrolling */
        sprintf(page_str,"%d",row_offset/10 + 1);
      }

    if (data->select_set_expected == SELECT_SET_SINGLE_ROW)
      for(i=0;i<data->num_of_rows;i++)
        if (data->select_set[i])
          {
            clear_array_except(i,
                               data->select_set,
                               data->num_of_rows);
            break;
          }

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- data_count = %d\n",data_count);
        fprintf(SCconsole,"SC -- num_cols_in_form = %d\n",num_cols_in_form);
        fprintf(SCconsole,"SC -- num_rows_in_form = %d\n",num_rows_in_form);
        fprintf(SCconsole,"SC -- total_width = %d\n",total_width);
        fprintf(SCconsole,"SC -- display_width = %d\n",display_width);
        fprintf(SCconsole,"SC -- freeze_width = %d\n",freeze_width);
        fprintf(SCconsole,"SC -- max_col_offset = %d\n",max_col_offset);
        fprintf(SCconsole,"SC -- max_row_offset = %d\n",max_row_offset);

/*
        if (data->select_set_expected)
          {
            fprintf(SCconsole,
                    "SC -- select_set_expected = %d\n",
                    data->select_set_expected);
            for (i=0;i<data->num_of_rows;i++)
              {
                fprintf(SCconsole,
                        "SC -- select_set[%d] = %d\n",
                        i,
                        data->select_set[i]);
              }
          }
*/

      }

    SCfill_free_header(SETUP);

    SCfill_free_table(FULL_TABLE);

    wrefresh(SCfree_win);


    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Entering input loop\n");
      }

    SCfree_form_input();

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Exiting SCprocess_form\n");
      }
    return (0);
  }  /* process_form */

int SCfill_free_table(mode)
int mode;
  {
    int count;
    int row,col,pos;
    int c_offset;
    int string_pos;
    int indent_offset;
    int string_size;
    int start = 0;
    int stop = 0;

    char indent_string[MAX_COLUMN_COUNT+1];

    if (col_offset < max_col_offset)
      string_size = MAX_COLUMN_COUNT;
    else
      string_size = display_width;

    string[string_size] = 0;

    switch (mode)
      {
        case FULL_TABLE:
          start = 0;
          stop = num_rows_in_form - 1;
          break;
        case LINE_UP:
          start = cur_row - row_offset;
          stop = cur_row - row_offset + 1;
          break;
        case LINE_DOWN:
          start = cur_row - row_offset - 1;
          stop = cur_row - row_offset;
          break;
      }

    for (row = start;row <= stop;row++)
      {
        memset(string,' ',string_size);
        for (col=0;col<num_cols_in_form;col++)
          {
            if (col < data->freeze_cols_count)
              {
                c_offset = 0;
                string_pos = data->col_pos[col + c_offset];
              }
            else
              {
                c_offset = col_offset;
                string_pos = data->col_pos[col + c_offset] -
                             scroll_offset + freeze_width;
              }
            pos = (row + row_offset) * data->num_of_cols +
                   col + c_offset;
            if (pos < data_count && data->data[pos] != NULL)
              {
                if (col + c_offset == 0  && data->max_indent > 0)
                  {
                    if (data->indent_level[row+row_offset] > 
                        data->max_indent)
                      {
                        indent_offset = (data->max_indent - 1) * 2;
                      }
                    else
                      {
                        indent_offset = 
                        (data->indent_level[row+row_offset] - 1) * 2;
                      }
                    memset(indent_string,' ',indent_offset);
                    sprintf(&indent_string[indent_offset],"%d. %s",
                            data->indent_level[row+row_offset],
                            data->data[pos]);
                    data_in_string(string_pos,
                                   data->col_size[col+c_offset],
                                   LEFT_JUSTIFIED,
                                   indent_string,string,string_size);
                  } /* if col + c_offset == 0 && max_indent > 0 */
                else
                  {
                    data_in_string(string_pos,
                                   data->col_size[col+c_offset],
                                   data->col_just[col+c_offset],
                                   data->data[pos],string,
                                   string_size);
                  }
              }
          } /* column for loop */

        if (row == cur_row - row_offset)
          wattron(SCfree_win,A_REVERSE);

        if (data->select_set_expected)
          {
            count = row + row_offset;
            if (count < data->num_of_rows && data->select_set[count])
              {
                wattron(SCfree_win,A_UNDERLINE);
              }
          }
        wmove(SCfree_win,row+6,0);
        wclrtoeol(SCfree_win);
        waddstr(SCfree_win,string);
        wattrset(SCfree_win,0);
        if (mode != FULL_TABLE)
          wrefresh(SCfree_win);
      } /* for row loop */
    return (0);
  } /*  fill_free_table */

int SCfill_free_header(mode)
int mode;
  {
/*  At set up time, based on the freeze_width, create three freeze_strings which
    contain the text above the frozen column(s). When scrolling takes place,
    generate the header string without reguard to the frozen column(s).  Then
    place the freeze_strings over the generated strings. */

    int i,j,length;
    int start_pos,pos;


    static char *freeze_string1;
    static char *freeze_string2;
    static char *freeze_string3;

/*
    if (SCdebug)
      {
        fprintf(SCconsole,"Entering FC.fill_free_header()\n");
        fprintf(SCconsole,"scroll_offset = %d\n",scroll_offset);
        fprintf(SCconsole,"freeze_width = %d\n",freeze_width);
        fprintf(SCconsole,"display_width = %d\n",display_width);
      }
*/

    string[MAX_COLUMN_COUNT] = 0;

    SCfill_in_title(SCfree_win,data->title);

/* fill in header line 1 */
    i = 0;
    memset(string,' ',MAX_COLUMN_COUNT);
    while (data->h1_pos[i] != -1 )
      {
        start_pos = data->h1_pos[i] - scroll_offset + freeze_width;
        if (start_pos >= display_width)
          break;
        length = strlen(data->h1_data[i]);
        for(j=0;j<length;j++)
          {
            pos = start_pos + j;
            if (pos >= 0 && pos < display_width)
              string[pos] = data->h1_data[i][j];
          }
        i++;
      }

    if (mode == SETUP)
      {
        freeze_string1 = (char *)malloc(freeze_width + 1);
        for (i=0;i<freeze_width;i++)
          freeze_string1[i] = string[i];
        freeze_string1[i] = 0;
      }
    else
      {
        for (i=0;i<freeze_width;i++)
          string[i] = freeze_string1[i];
      }
    mvwaddstr(SCfree_win,3,0,string);


/* fill in header line 2 */
    i = 0;
    memset(string,' ',MAX_COLUMN_COUNT);
    while (data->h2_pos[i] != -1 )
      {
        start_pos = data->h2_pos[i] - scroll_offset + freeze_width;
        if (start_pos >= display_width)
          break;
        length = strlen(data->h2_data[i]);
        for(j=0;j<length;j++)
          {
            pos = start_pos + j;
            if (pos >= 0 && pos < display_width)
              string[pos] = data->h2_data[i][j];
          }
        i++;
      }

    if (mode == SETUP)
      {
        freeze_string2 = (char *)malloc(freeze_width + 1);
        for (i=0;i<freeze_width;i++)
          freeze_string2[i] = string[i];
        freeze_string2[i] = 0;
      }
    else
      {
        for (i=0;i<freeze_width;i++)
          string[i] = freeze_string2[i];
      }

    mvwaddstr(SCfree_win,4,0,string);

/* fill in header line 3 */
    i = 0;
    memset(string,' ',MAX_COLUMN_COUNT);
    while (data->h3_pos[i] != -1 )
      {
        start_pos = data->h3_pos[i] - scroll_offset + freeze_width;
        if (start_pos >= display_width)
          break;
        length = strlen(data->h3_data[i]);
        for(j=0;j<length;j++)
          {
            pos = start_pos + j;
            if (pos >= 0 && pos < display_width)
              string[pos] = data->h3_data[i][j];
          }
        i++;
      }

    if (mode == SETUP)
      {
        freeze_string3 = (char *)malloc(freeze_width + 1);
        for (i=0;i<freeze_width;i++)
          freeze_string3[i] = string[i];
        freeze_string3[i] = 0;
      }
    else
      {
        for (i=0;i<freeze_width;i++)
          string[i] = freeze_string3[i];
      }

    mvwaddstr(SCfree_win,5,0,string);

/*
    if (SCdebug)
      {
        fprintf(SCconsole,"freeze_string1 = <%s>\n",freeze_string1);
        fprintf(SCconsole,"freeze_string2 = <%s>\n",freeze_string2);
        fprintf(SCconsole,"freeze_string3 = <%s>\n",freeze_string3);
      }
*/
    return (0);
  }

int SCfree_form_input()
  {
    int i;
    int old_row;
    int old_row_offset,old_col_offset;
    int ok_to_loop;
    int page_flag;
    int keyin_count;
    char keyin_buffer[KEYIN_BUFFER_SIZE];
    char d_msg[80];

    if (SCdebug)
      {
        fprintf(SCconsole,"SC -- Entering SCfree_form_input\n");
      }

    col_too_wide = FALSE;

    keyin_count = 0;
    page_flag = FALSE;

    place_cur();
    ok_to_loop = TRUE;

    while(ok_to_loop)
      {
        ch = getch_rap();
        SCclear_msg();
/*
        if (SCdebug)
          {
            fprintf(SCconsole,"ch = %d\n",ch);
          }
*/

        switch(ch)
          {
            case KEY_F(1):
            case KEY_F(6):  /* IntelPort workaround - srinivas 22/5/95 */ 
              /* ACCEPT */
              data->sts = FORM_ACCEPTED;
              wmove (SCfree_win,18,0);
              wclrtoeol (SCfree_win);
              wrefresh (SCfree_win);
#ifdef OS_HPUX
     /* Curses changes - HP PORT - IGI - 30 Jun 94 */
	      wmove(SCfree_win,0,0);
	      wclrtobot(SCfree_win);
	      wrefresh(SCfree_win);
              if(strcmp(getenv("TERM"), "hpterm") == 0 ||
                 strcmp(getenv("TERM"), "hp") == 0)
	         getch();
#endif 	
              delwin(SCfree_win);
              SCfree_win = NULL;
              ok_to_loop = FALSE;
              break;
            case KEY_F(2):
              /* PRINT */
	      if( vertical_print )
		SCprint_vertical_table( );
	      else
	        SCprint_free_table( SETUP );
              sprintf (d_msg, "Listing Generated: \"%s\"", SCprint_file);
#ifdef OS_HPUX
              /* Curses changes - HP PORT - IGI - 30 jun 94 */
              if(strcmp(getenv("TERM"), "hpterm") == 0 ||
                 strcmp(getenv("TERM"), "hp") == 0)
	         getch();
#endif
              SCdisplay_msg (d_msg);
              break;
            case KEY_F(3):
              /* ACCEPT */
              data->sts = FORM_CANCELED;
              wmove (SCfree_win,18,0);
              wclrtoeol (SCfree_win);
              wrefresh (SCfree_win);
#ifdef OS_HPUX
     /* Curses changes - HP PORT - IGI - 30 Jun 94 */
	      wmove(SCfree_win,0,0);
	      wclrtobot(SCfree_win);
	      wrefresh(SCfree_win);
              if(strcmp(getenv("TERM"), "hpterm") == 0 ||
                 strcmp(getenv("TERM"), "hp") == 0)
	         getch();
#endif 	
              delwin(SCfree_win);
              SCfree_win = NULL;
              ok_to_loop = FALSE;
              break;
            case KEY_F(4):
              /* Entire Form Selected */
              if (data->select_set_expected == SELECT_SET_MULTI_ROW)
                  {
                  data->sts = FORM_SELECTED;
                  wmove (SCfree_win,18,0);
                  wclrtoeol (SCfree_win);
                  wrefresh (SCfree_win);
#ifdef OS_HPUX
   /* Curses changes - HP PORT - IGI - 1 Jul 94 */
	          wmove(SCfree_win,0,0);
	          wclrtobot(SCfree_win);
	          wrefresh(SCfree_win);
                  if(strcmp(getenv("TERM"), "hpterm") == 0 ||
                     strcmp(getenv("TERM"), "hp") == 0)
	             getch();
#endif
                  delwin(SCfree_win);
                  SCfree_win = NULL;
                  ok_to_loop = FALSE;
                  }
              break;
            case KEY_UP:
            case KEY_DOWN:
              old_row = cur_row;
              old_row_offset = row_offset;
              switch(ch)
                {
                  case KEY_UP:
                    cur_row--;
                    if (cur_row < 0)
                      cur_row = 0;
                    break;
                  case KEY_DOWN:
                    cur_row++;
                    break;
                } /* inner switch */


              if (cur_row >= data->num_of_rows)
                {
                  cur_row = data->num_of_rows - 1;
                  if (max_row_offset > 0)
                    {
                      row_offset++;
                      if (row_offset > max_row_offset)
                        row_offset = max_row_offset;
                    }
                  else
                    row_offset = 0;
                }
              else if (cur_row < row_offset)
                {
                  row_offset --;
                  if (row_offset < 0)
                    row_offset = 0;
                }
              else if (cur_row >= row_offset + num_rows_in_form)
                {
                  row_offset ++;
                  if (row_offset > max_row_offset)
                    {
                      if (max_row_offset > 0)
                        row_offset = max_row_offset;
                      else
                        row_offset = 0;
                    }
                }

              if (row_offset != old_row_offset)
                SCfill_free_table(FULL_TABLE);
              else if (cur_row < old_row)
                SCfill_free_table(LINE_UP);
              else if (cur_row > old_row)
                SCfill_free_table(LINE_DOWN);
            
              place_cur();
              break;

            case KEY_RIGHT:
            case KEY_LEFT:
              old_col_offset = col_offset;
              switch(ch)
                {
                  case KEY_LEFT:
                    col_offset--;
                    if (col_offset < 0)
                      col_offset = 0;
                    break;
                  case KEY_RIGHT:
                    col_offset++;
                    if (col_offset > max_col_offset)
                      {
                        if (max_col_offset > 0)
                          col_offset = max_col_offset;
                        else
                          col_offset = 0;
                      }
                    break;
                } /* inner switch */

              if (col_offset != old_col_offset)
                {
                  /* get current number of columns in form */
                  num_cols_in_form = data->freeze_cols_count;

                  /* KT - April 2, 1990 */
/*
                  if (num_cols_in_form > 1)
*/
                      freeze_width = data->col_pos[data->freeze_cols_count];
/*
                  else
                      freeze_width = data->col_size[0];
*/

                  scroll_offset =
                          data->col_pos[col_offset + data->freeze_cols_count];
          
                  i = col_offset + data->freeze_cols_count;
                  for (;i<data->num_of_cols; i++)
                    {
                      if ((data->col_pos[i] +
                           data->col_size[i] -
                           scroll_offset + freeze_width) > MAX_COLUMN_COUNT)
                        break;
                      num_cols_in_form++;
                    }

                  i = num_cols_in_form - 1 + col_offset;
                  display_width = data->col_pos[i] +
                                        data->col_size[i] -
                                        scroll_offset + freeze_width;

/* if there is not enough room to display any columns to the right
   of the frozen columns, display it anyway and display an error
   message */
                  if (num_cols_in_form == data->freeze_cols_count)
                    {
                      col_too_wide = TRUE;
                      num_cols_in_form++;
                      display_width = MAX_COLUMN_COUNT;
                      SCdisplay_msg("Warning: Not enough space to display entire column on right hand side");
		      break;
                    }
                  else
                    col_too_wide = FALSE;

                  SCfill_free_header(RUN_TIME);
                  SCfill_free_table(FULL_TABLE);
                }
              place_cur();
              break;

     /* work around for KEY_ENTER on SCO, SUN and SOLARIS -- MVR 20 Dec 1993  */
            case KEY_F(5):
            case KEY_ENTER:
              if (data->select_set_expected)
                {
                  if (data->select_set[cur_row])
                    data->select_set[cur_row] = 0;
                  else
                    {
                      data->select_set[cur_row] = 1;
                      if (data->select_set_expected == SELECT_SET_SINGLE_ROW)
                        {
                          clear_array_except(cur_row,data->select_set,
                                             data->num_of_rows);
                        }
                    }
                  SCfill_free_table(FULL_TABLE);
                  place_cur();
                }
              break;

            case 21: /* ctrl u */
              row_offset -= num_rows_in_form;
              if (row_offset < 0)
                row_offset = 0;

              cur_row -= num_rows_in_form;
              if (cur_row < 0)
                cur_row = 0;

              SCfill_free_table(FULL_TABLE);
              place_cur();
              break;

            case 4: /* ctrl d */
              row_offset += num_rows_in_form;
              if (row_offset > max_row_offset)
                row_offset = max_row_offset;

              cur_row += num_rows_in_form;
              if (cur_row > data->num_of_rows - 1)
                cur_row = data->num_of_rows - 1;

              SCfill_free_table(FULL_TABLE);
              place_cur();
              break;
            case 16: /* ctrl p */
              page_flag = TRUE;
              keyin_count = 0;
              update_page_string(keyin_count,keyin_buffer);
              break;
            case '\n':
            case 13:
              if (page_flag)
                {
                  page_flag = FALSE;
                  if (keyin_count)
                    {
                      row_offset = (atoi(keyin_buffer) - 1) * num_rows_in_form;
                      if (row_offset > max_row_offset)
                        row_offset = max_row_offset;
                      else if (row_offset < 0)
                        row_offset = 0;
                      cur_row = row_offset;
                    }
                  SCfill_free_table(FULL_TABLE);
                  place_cur();
                }
              break;
            case 127: /* delete */
            case 8:
              if (page_flag && keyin_count > 0)
                {
                  keyin_buffer[--keyin_count] = 0;
                  update_page_string(keyin_count,keyin_buffer);
                }
              break;
            default:
              if (isdigit(ch) && page_flag)
                {
                  if (keyin_count == KEYIN_BUFFER_SIZE - 1)
                    {
                      SCdisplay_msg("Invalid keyin:  Too many digits for a page number");
                      page_flag = FALSE;
                      place_cur();
                      break;
                    }
                  keyin_buffer[keyin_count++] = ch;
                  keyin_buffer[keyin_count] = 0;
                  update_page_string(keyin_count,keyin_buffer);
                }
              break;
          } /* switch */
      }
    return (0);
  }

int place_cur()
  {

    SCdisplay_cur_pos();
    wrefresh(SCfree_win);
    wmove(cmd_win,1,0);
    wrefresh(cmd_win);

    return (0);
  }

int SCdisplay_cur_pos()
  {
    int len;

    /* len is retrieved using strlen(),  instead of from sprintf */
    /* Vasu - 15.11.93 */

#ifdef OS_SUNOS
    sprintf(string, "Page %d of %d", row_offset/10 + 1, 
                  data->num_of_rows/10 + 1);
    len = strlen (string);
#else
    len = sprintf(string, "Page %d of %d", row_offset/10 + 1, 
                  data->num_of_rows/10 + 1);
#endif

    wmove(SCfree_win,18,0);
    wclrtoeol(SCfree_win);
    waddstr(SCfree_win,string);
#ifdef OS_SUNOS
    sprintf(string, " Row %d of %d", cur_row + 1, data->num_of_rows);
    len = strlen (string);
#else
    len = sprintf(string, " Row %d of %d", cur_row + 1, data->num_of_rows);
#endif
    wmove(SCfree_win,18,79 - len);
    waddstr(SCfree_win,string);

    return (0);
  }

int update_page_string(count,buffer)
int count;
char *buffer;
  {
    int len;

    if (count == 0)
#ifdef OS_SUNOS
      {
      sprintf(string, "Page  of %d", data->num_of_rows/10 + 1);
      len = strlen (string);
      }
#else
      len = sprintf(string, "Page  of %d", data->num_of_rows/10 + 1);
#endif
    else
#ifdef OS_SUNOS
      {
      sprintf(string, "Page %d of %d", atoi(buffer), 
                    data->num_of_rows/10 + 1);
      len = strlen (string);
      }
#else
      len = sprintf(string, "Page %d of %d", atoi(buffer), 
                    data->num_of_rows/10 + 1);
#endif
      
    wmove(SCfree_win,18,0);
    wclrtoeol(SCfree_win);
    waddstr(SCfree_win,string);
#ifdef OS_SUNOS
    sprintf(string, " Row %d of %d", cur_row + 1, data->num_of_rows);
    len =strlen (string);
#else
    len = sprintf(string, " Row %d of %d", cur_row + 1, data->num_of_rows);
#endif
    wmove(SCfree_win,18,79 - len);
    waddstr(SCfree_win,string);

    wmove(SCfree_win,18,5 + count);
    wrefresh(SCfree_win);

    return (0);
  }

int SCprint_free_table(mode)
int mode;
  {
    FILE   *fopen();
    FILE   *outfile;

    int row,col,pos;
    int c_offset;
    int string_pos;
    int indent_offset;
    int string_size;
    int start,stop;
    int i,j,length;
    int start_pos;

    long   now_time;
    
    struct tm *the_stamp;

    char indent_string[MAX_COLUMN_COUNT+1];

    static char *freeze_string1;
    static char *freeze_string2;
    static char *freeze_string3;

    if( ( outfile = fopen( SCprint_file, "a")) == NULL )
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

    string[MAX_COLUMN_COUNT] = 0;

/*  Fill in title
 */
    if (data->title != NULL)
        fprintf( outfile, "\n%s\n\n", data->title );

/* fill in header line 1 */
    i = 0;
    memset(string,' ',MAX_COLUMN_COUNT);
    while (data->h1_pos[i] != -1 )
      {
        start_pos = data->h1_pos[i] - scroll_offset + freeze_width;
        if (start_pos >= display_width)
          break;
        length = strlen(data->h1_data[i]);
        for(j=0;j<length;j++)
          {
            pos = start_pos + j;
            if (pos >= 0 && pos < display_width)
              string[pos] = data->h1_data[i][j];
          }
        i++;
      }

    if (mode == SETUP)
      {
        freeze_string1 = (char *)malloc(freeze_width + 1);
        for (i=0;i<freeze_width;i++)
          freeze_string1[i] = string[i];
        freeze_string1[i] = 0;
      }
    else
      {
        for (i=0;i<freeze_width;i++)
          string[i] = freeze_string1[i];
      }
    fprintf( outfile, "%s\n", string );

/* fill in header line 2 */
    i = 0;
    memset(string,' ',MAX_COLUMN_COUNT);
    while (data->h2_pos[i] != -1 )
      {
        start_pos = data->h2_pos[i] - scroll_offset + freeze_width;
        if (start_pos >= display_width)
          break;
        length = strlen(data->h2_data[i]);
        for(j=0;j<length;j++)
          {
            pos = start_pos + j;
            if (pos >= 0 && pos < display_width)
              string[pos] = data->h2_data[i][j];
          }
        i++;
      }

    if (mode == SETUP)
      {
        freeze_string2 = (char *)malloc(freeze_width + 1);
        for (i=0;i<freeze_width;i++)
          freeze_string2[i] = string[i];
        freeze_string2[i] = 0;
      }
    else
      {
        for (i=0;i<freeze_width;i++)
          string[i] = freeze_string2[i];
      }
    fprintf( outfile, "%s\n", string );

/* fill in header line 3 */
    i = 0;
    memset(string,' ',MAX_COLUMN_COUNT);
    while (data->h3_pos[i] != -1 )
      {
        start_pos = data->h3_pos[i] - scroll_offset + freeze_width;
        if (start_pos >= display_width)
          break;
        length = strlen(data->h3_data[i]);
        for(j=0;j<length;j++)
          {
            pos = start_pos + j;
            if (pos >= 0 && pos < display_width)
              string[pos] = data->h3_data[i][j];
          }
        i++;
      }

    if (mode == SETUP)
      {
        freeze_string3 = (char *)malloc(freeze_width + 1);
        for (i=0;i<freeze_width;i++)
          freeze_string3[i] = string[i];
        freeze_string3[i] = 0;
      }
    else
      {
        for (i=0;i<freeze_width;i++)
          string[i] = freeze_string3[i];
      }
    fprintf( outfile, "%s\n", string );

/*  Fill in free form table 
 */
    if (col_offset < max_col_offset)
      string_size = MAX_COLUMN_COUNT;
    else
      string_size = display_width;

    string[string_size] = 0;

    start = 0;
    stop = data->num_of_rows - 1;

    for (row = start;row <= stop;row++)
      {
        memset(string,' ',string_size);
        for (col=0;col<num_cols_in_form;col++)
          {
            if (col < data->freeze_cols_count)
              {
                c_offset = 0;
                string_pos = data->col_pos[col + c_offset];
              }
            else
              {
                c_offset = col_offset;
                string_pos = data->col_pos[col + c_offset] -
                             scroll_offset + freeze_width;
              }
            pos = (row + row_offset) * data->num_of_cols +
                   col + c_offset;
            if (pos < data_count && data->data[pos] != NULL)
              {
                if (col + c_offset == 0  && data->max_indent > 0)
                  {
                    if (data->indent_level[row+row_offset] > 
                        data->max_indent)
                      {
                        indent_offset = (data->max_indent - 1) * 2;
                      }
                    else
                      {
                        indent_offset = 
                        (data->indent_level[row+row_offset] - 1) * 2;
                      }
                    memset(indent_string,' ',indent_offset);
                    sprintf(&indent_string[indent_offset],"%d. %s",
                            data->indent_level[row+row_offset],
                            data->data[pos]);
                    data_in_string(string_pos,
                                   data->col_size[col+c_offset],
                                   LEFT_JUSTIFIED,
                                   indent_string,string,string_size);
                  } /* if col + c_offset == 0 && max_indent > 0 */
                else
                  {
                    data_in_string(string_pos,
                                   data->col_size[col+c_offset],
                                   data->col_just[col+c_offset],
                                   data->data[pos],string,
                                   string_size);
                  }
              }
          } /* column for loop */

	fprintf( outfile, "%s\n", string );
      } /* for row loop */

    fclose( outfile );
    return( 0 );

  } /*  fill_free_table */

int 
SCprint_vertical_table( )
{
    FILE   *fopen();
    FILE   *outfile;

    int    i;
    int    j;
    int    big_col;
    char   vert_string[132];
    long   now_time;
    
    struct tm *the_stamp;

    if( SCdebug )
        fprintf(SCconsole,"SC -- Enter SCprint_vertical_table\n");

    if( ( outfile = fopen( SCprint_file, "a")) == NULL )
	return( 1 );

    memset( vert_string, '-', 80 );
    fprintf( outfile, "\n\n%s\n", vert_string );

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
    sprintf( vert_string,"  Date --> %.2d/%.2d/%.2d  Time --> %.2d:%.2d:%.2d", 
	     (the_stamp->tm_mon)+1, the_stamp->tm_mday, the_stamp->tm_year,
              the_stamp->tm_hour, the_stamp->tm_min, the_stamp->tm_sec );
*/

    sprintf( vert_string,"  Date --> %.2d/%.2d/%.4d  Time --> %.2d:%.2d:%.2d", 
	     (the_stamp->tm_mon)+1, the_stamp->tm_mday, the_stamp->tm_year+1900,
              the_stamp->tm_hour, the_stamp->tm_min, the_stamp->tm_sec );

/* End of Year 2000 Fixes */

    fprintf( outfile, "\n%s\n", vert_string );

/*  Fill in title
 */
    if (data->title != NULL)
        fprintf( outfile, "\n%s\n\n", data->title );

/*  Get largest column size
 */
    big_col = 0;
    
    for( i=0; i<data->num_of_cols; ++i )
	if( data->col_size[i] > big_col )
	    big_col = data->col_size[i];

    for( j=0; j<(data->num_of_rows*data->num_of_cols); j+=data->num_of_cols )
    {
        for( i=0; i<data->num_of_cols; ++i )
        {
            sprintf( vert_string, "%-*s    %-s", big_col, data->h2_data[i],
		     data->data[j+i] );
	    if (SCdebug)
                fprintf(SCconsole,"SC -- str <%s>\n", vert_string);

	    fprintf( outfile, "%s\n", vert_string );	
        }
	memset( vert_string, '-', 80 );
        fprintf( outfile, "\n%s\n\n", vert_string );	
    }
    fclose( outfile );

    if( SCdebug )
        fprintf(SCconsole,"SC -- Exit SCprint_vertical_table\n");
	
    return( 0 );
}   
