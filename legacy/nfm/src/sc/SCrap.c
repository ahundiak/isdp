#include "machine.h"
#ifdef OS_SUNOS
#include "/usr/5include/curses.h"  /* Added by SSRS - 19/10/93 */
#else
#include <curses.h>
#endif
#include <ctype.h>
#include <errno.h>
#include "SCextern.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

#define WINDOW_LINES	10
#define WINDOW_COLS		40
#define WINDOW_Y		5
#define WINDOW_X		20

#define EXIT			0
#define START_RECORDING	1
#define START_PLAYBACK	2
#define STOP_RECORDING	3
#define STOP_PLAYBACK	4
#define PLAYBACK_MODE	5

#define NO_PLAYBACK		0
#define IMMEDIATE		1
#define REAL_TIME		2
#define SINGLE_STEP		3

int rap_enabled = 0;
int record = 0;
int playback = 0;
char msgstr[80];
FILE *record_fp,*playback_fp;
WINDOW *rapwin = NULL;

FILE *fopen();
static void rap_menu();

static void insert_centered_string(dst,width,src)
char *dst;
char *src;
{
	int len;


	memset(dst,' ',width);
	dst[width] = 0;

	if ((len = strlen(src)) > width) len = width;

	strncpy(dst + ((width - len + 1)/2),src,len);
}

static void draw_title_box()
{
	int i;
	char s[WINDOW_COLS];

	DrawBox(rapwin,0,0,WINDOW_LINES,WINDOW_COLS);
	insert_centered_string(s,WINDOW_COLS-2,"RECORD AND PLAYBACK");
	mvwaddstr(rapwin,1,1,s);

    wattron(rapwin,A_ALTCHARSET);
    wmove(rapwin,2,0);
    waddch(rapwin,ACS_LTEE);
    for (i = 0; i < WINDOW_COLS - 2; i++)
      waddch(rapwin,ACS_HLINE);
    waddch(rapwin,ACS_RTEE);

    wmove(rapwin,7,0);
    waddch(rapwin,ACS_LTEE);
    for (i = 0; i < WINDOW_COLS - 2; i++)
      waddch(rapwin,ACS_HLINE);
    waddch(rapwin,ACS_RTEE);

    wattroff(rapwin,A_ALTCHARSET);
}


static void clear_line(n)
int n;
{
	int i;
	
    wattrset(rapwin,0);
    wmove(rapwin,n,1);
    for (i = 0; i < WINDOW_COLS - 2; i++)
      waddch(rapwin,' ');
}


static void clear_display_area()
{
	int i;

	for (i = 3; i < 7; i++)
		clear_line(i);
}


static void clear_message_area()
{
	clear_line(8);
}


static void display_message()
{
	clear_message_area();
	mvwaddstr(rapwin,8,1,msgstr);
}


static int get_filename(filename)
char *filename;
{
	clear_display_area();
	strcpy(msgstr,"Enter filename");
	display_message();
	wrefresh(rapwin);

	if (getKeyin(rapwin,3,1,filename) <= 0)
		return(1);
	return(0);
}

static int get_playback_mode(mode)
int *mode;
{
	int y,x;
	int selectedIndex = 0;

	static char *list[] =
	{
		"                                        ",
		"                                        ",
		"                                        ",
		"                                        "
	};

	insert_centered_string(list[0],WINDOW_COLS-2,"Immediate");
	insert_centered_string(list[1],WINDOW_COLS-2,"Real time");
	insert_centered_string(list[2],WINDOW_COLS-2,"Single step");

   	y = 3;
   	x = 1;
	
	strcpy(msgstr,"Select playback mode");
	display_message();

	clear_display_area();

	if (ProcessVerticalList (rapwin,y,x,3,0,3,list,&selectedIndex))
		return(1);

	switch(selectedIndex)
	{

		case 0:
			*mode = IMMEDIATE;
			break;

		case 1:
			*mode = REAL_TIME;
			break;

		case 2:
			*mode = SINGLE_STEP;
			break;
	}
	return(0);
}


static void playback_delay(count)
int count;
{
	int i;
	chtype ch2;

	switch (playback)
	{
		case IMMEDIATE:
			if ((ch2 = getch()) == 0x12)
			{
				rap_menu();
				playback_delay(count);
				return;
			}
			break;

		case REAL_TIME:
			for (i = 0; i < count; i++)
			{
				ch2 = getch();
				if (ch2 == 0x13) /* HOLD SCREEN */
				{
					do
						ch2 = getch();
					while (ch2 != 0x13 && ch2 != 0x11);
				}
				else if (ch2 == 0x12)
				{
					rap_menu();
					playback_delay(count);
					return;
				}
			}
			break;

		case SINGLE_STEP:
			do
			{
				ch2 = getch();

				if (ch2 == 0x12)
				{
					rap_menu();
					playback_delay(count);
					return;
				}
			} 
			while (ch2 == ERR);
			break;

		default:
			break;
	}
}


extern void init_rap( user_rap )
 	int  user_rap;
{
	if (user_rap)
	{
		rap_enabled = 1;
		nodelay(stdscr,1);
	}
	else
	{
		rap_enabled = 0;
	}
}


extern chtype getch_rap()
{
	int count = 0;
	chtype ch;

	if (rap_enabled)
	{
		if (playback)
		{
			if (fread((char *)&ch,1,sizeof(ch),playback_fp) == 0)
			{
				playback = NO_PLAYBACK;
				fclose(playback_fp);
			}
			if (fread((char *)&count,1,sizeof(count),playback_fp) == 0)
			{
				playback = NO_PLAYBACK;
				fclose(playback_fp);
			}
		}

		if (playback)
			playback_delay(count);

		if (!playback)
		{
			while (1)
			{
				if ((ch = getch()) == ERR) count++;
				else if (ch == 0x12)
				{
					count = 0;
					rap_menu();
					if (playback)
					{
						ch = getch_rap();
						return(ch);
					}
				}
				else break;
			}
		}

		if (record)
		{
			fwrite((char *)&ch,1,sizeof(ch),record_fp);
			fwrite((char *)&count,1,sizeof(count),record_fp);
		}
	}
	else /* rap is not enabled */
	{
		ch = getch();
	}

	return(ch);
}


extern char *stop_record()
{
	char *returnValue = NULL;

	fclose(record_fp);
	record = 0;

  	return(returnValue);
}

extern char *start_record(filename)
char *filename;
{
	char *returnValue = NULL;
	static char errstr[80];

	if (record)
	{
		sprintf(errstr,"Already recording");
		returnValue = errstr;
	}
	else if ((record_fp = fopen(filename,"w")) == NULL)
	{
		sprintf(errstr,"Unable to open \"%s\"",filename);
		returnValue = errstr;
	}
	else
	{
		record = 1;
	}
	return(returnValue);
}


extern char *start_playback(filename,mode)
char *filename;
int mode;
{
	char *returnValue = NULL;
	static char errstr[80];

	if (playback)
	{
		sprintf(errstr,"Already playing back");
		returnValue = errstr;
	}
	else if ((playback_fp = fopen(filename,"r")) == NULL)
	{
		sprintf(errstr,"Unable to open \"%s\"",filename);
		returnValue = errstr;
	}
	else if (mode != IMMEDIATE && mode != REAL_TIME && mode != SINGLE_STEP)
	{
		sprintf(errstr,"Invalid mode <%d>",mode);
		returnValue = errstr;
	}
	else
	{
		playback = mode;
	}
	return(returnValue);
}


extern char  *stop_playback()
{
        fclose(playback_fp);
        playback = NO_PLAYBACK;
	return( NULL );
}


static void rap_menu()
{
	int x,y;
	int mode;
	int count;
	int ok_to_loop;
	int selectedIndex = 0;
	int action[6];
	int cur_x,cur_y;
	char *sts;
	char filename[256];
	static char *list[] =
	{
		"                                        ",
		"                                        ",
		"                                        ",
		"                                        "
	};

	if (SCcol_win != NULL)
        {
	    getyx(SCcol_win,cur_y,cur_x);
        }
	else if (SCfree_win != NULL)
        {
	    getyx(SCcol_win,cur_y,cur_x);
        }
	else
        {
	    getsyx(cur_y,cur_x);
        }
	
	if (rapwin == NULL)
		rapwin = newwin(WINDOW_LINES,WINDOW_COLS,WINDOW_Y,WINDOW_X);

	draw_title_box();
	strcpy(msgstr,"Make a selection");

	ok_to_loop = 1;
	while (ok_to_loop)
	{
		count = 0;
		if (record)
		{
			insert_centered_string(list[count],WINDOW_COLS-2,"Stop Recording");
			action[count] = STOP_RECORDING;
			count ++;
		}
		else
		{
			insert_centered_string(list[count],WINDOW_COLS-2,"Start Recording");
			action[count] = START_RECORDING;
			count ++;
		}
	
		if (playback)
		{
			insert_centered_string(list[count],WINDOW_COLS-2,"Stop Playback");
			action[count] = STOP_PLAYBACK;
			count ++;
			insert_centered_string(list[count],WINDOW_COLS-2,
				"Modify Playback Mode");
			action[count] = PLAYBACK_MODE;
			count ++;
		}
		else
		{
			insert_centered_string(list[count],WINDOW_COLS-2,"Start Playback");
			action[count] = START_PLAYBACK;
			count ++;
		}
	
		insert_centered_string(list[count],WINDOW_COLS-2,"Exit");
		action[count] = EXIT;
		count ++;
		
    	y = 3;
    	x = 1;
	
		clear_display_area();
		display_message();
		if (selectedIndex == -1)
			selectedIndex += count; /* count - 1 */
		else
			selectedIndex = 0;
		if (ProcessVerticalList (rapwin,y,x,count,0,count,list,&selectedIndex))
			break;
	
		switch(action[selectedIndex])
		{
			case EXIT:
				ok_to_loop = 0;
				break;
	
			case START_RECORDING:
				if (get_filename(filename))
				{
					sprintf(msgstr,"Filename not entered");
				}
				else if ((sts = start_record(filename)) != NULL)
				{
					strcpy(msgstr,sts);
				}
				else
				{
					sprintf(msgstr,"Recording to \"%s\"",filename);
					selectedIndex = -1;
				}
				break;

			case STOP_RECORDING:
				fclose(record_fp);
				record = 0;
				sprintf(msgstr,"Recording stopped");
				selectedIndex = -1;
				break;
	
			case START_PLAYBACK:
				if (get_filename(filename))
				{
					sprintf(msgstr,"Filename not entered");
				}
				else if (get_playback_mode(&mode))
				{
					sprintf(msgstr,"Playback mode not selected");
				}
				else if ((sts = start_playback(filename,mode)) != NULL)
				{
					strcpy(msgstr,sts);
				}
				else
				{
					sprintf(msgstr,"Playback from \"%s\"",filename);
					selectedIndex = -1;
				}
				break;
	
			case STOP_PLAYBACK:
				fclose(playback_fp);
				playback = NO_PLAYBACK;
				sprintf(msgstr,"Playback stopped");
				selectedIndex = -1;
				break;
	
			case PLAYBACK_MODE:
				if (get_playback_mode(&mode))
				{
					sprintf(msgstr,"Playback mode not selected");
					selectedIndex = -1;
				}
				else
				{
					switch (mode)
					{
						case IMMEDIATE:
							sprintf(msgstr,"Playback mode: Immediate");
							break;

						case REAL_TIME:
							sprintf(msgstr,"Playback mode: Real time");
							break;

						case SINGLE_STEP:
							sprintf(msgstr,"Playback mode: Single step");
							break;

					}
					playback = mode;
					selectedIndex = -1;
				}
				break;
		}
	}

	if (rapwin != NULL)
	{
		delwin(rapwin);
		rapwin = NULL;
	}

	if (SCcol_win != NULL)
        {
	    touchwin(SCcol_win);
	    wmove(SCcol_win,cur_y,cur_x);
	    wrefresh(SCcol_win);
        }
	else if (SCfree_win != NULL)
        {
	    touchwin(SCfree_win);
	    wmove(SCfree_win,cur_y,cur_x);
	    wrefresh(SCfree_win);
        }
	else
        {
	    touchline(stdscr,WINDOW_Y,WINDOW_LINES);
	    setsyx(cur_y,cur_x);
	    wrefresh(stdscr);
        }
}

void rap_exec_process ()
{
    int i, j, k;
    int pstatus;
    int process;
    int post_exec_stat;
    chtype ch;
    char process_str[250];
    char args[10][30];  /* only support 10 arguments */

    /* This can only be done from playback mode when RAP is ON */
    if (SCdebug)
        fprintf (SCconsole, "SC: Enter rap_exec_process\n");
    if (rap_enabled)
        {
        if (playback)
            {
            /* intialize args array */
            if (SCdebug)
                fprintf (SCconsole, "SC: initialize args array\n");
            for (i=0; i<10; ++i)
                strcpy (args[i], "");
            process_str[0] = 0;
            i = 0;
            if (SCdebug)
                fprintf (SCconsole, "SC: read process name\n");
            do
                { /* read process name */
                if (fread((char *)&ch,1,sizeof(ch),playback_fp) == 0)
                    {
                    playback = NO_PLAYBACK;
                    fclose(playback_fp);
                    }
                process_str[i++] = ch;
                }
            while ((ch != '\n') && (ch != ' '));  /* carriage return or space */
            process_str[i-1] = '\0';
            if (SCdebug)
                fprintf (SCconsole, "SC: process: <%s>\n", process_str);

            if (SCdebug)
                fprintf (SCconsole, "SC: read arguments\n");
            for (j=0; j<10; ++j)
                { /* read arguments */
                if (ch == '\n')
                    break;
                else
                    {
                    k = 0;
                    do
                        {
                        if (fread((char *)&ch,1,sizeof(ch),playback_fp) == 0)
                            {
                            playback = NO_PLAYBACK;
                            fclose(playback_fp);
                            }
                        args[j][k++] = ch;
                        }
                    while ((ch != '\n') && (ch != ' '));  /* return or space */
                    args[j][k-1] = '\0';
                    if (SCdebug)
                        fprintf (SCconsole, "SC: args[%d]: <%s>\n", j, args[j]);
                    }
                }
            if (SCdebug)
                fprintf (SCconsole, "SC: Execute Process <%s> 1:<%s> 2:<%s> \
3:<%s> 4:<%s> 5:<%s> 6:<%s> 7:<%s> 8:<%s> 9:<%s> 10:<%s>\n", process_str,
args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
args[9]);

            /* execute the process */
            pstatus = 0;

/* following added for SCO port */

#ifdef OS_SCO_UNIX
            process = fork ();
#else
            process = vfork ();
#endif

            if (process > 0)         /* parent */
                wait (&pstatus);

            else if (process == 0)   /* child */
                {
                /* execute process */

                execlp (process_str, process_str, args[0], args[1], args[2],
                        args[3], args[4], args[5], args[6], args[7], args[8],
                        args[9], (char *)0);

                post_exec_stat = errno;
                }

            else if (process == 1)     /* can't create process. */
                {
                }

            }  /* end if playback */
        }  /* end if rap_enabled */

    return;
}

