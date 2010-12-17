#include "machine.h"
#ifdef OS_SUNOS
#include "/usr/5include/curses.h"   /* Added by SSRS - 19/10/93 */
#else
#include <curses.h>
#endif
#include <ctype.h>

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */ 
#include "NFMcurses.h"
#endif

extern void DrawBox(win,y,x,height,width)
WINDOW *win;
int y,x;
int height;
int width;
{
	int i;

	wattron(win,A_ALTCHARSET);

	wmove(win,y,x);
	waddch(win,ACS_ULCORNER);
	for (i = 0; i < width - 2; i++) waddch(win,ACS_HLINE);
	waddch(win,ACS_URCORNER);
	y++;

	for (i = 0; i < height - 2; i++)
	{
		wmove(win,y,x);
		waddch(win,ACS_VLINE);
		wmove(win,y,x + width - 1);
		waddch(win,ACS_VLINE);
		y++;
	}

	wmove(win,y,x);
	waddch(win,ACS_LLCORNER);
	for (i = 0; i < width - 2; i++) waddch(win,ACS_HLINE);
	waddch(win,ACS_LRCORNER);
	y++;

	wattroff(win,A_ALTCHARSET);
}


DisplayVerticalList (win,yorg,xorg,displayCount,displayWidth,borderFlag,
					 count,list,cur, scrollOffset)
WINDOW *win;
int yorg;
int xorg;
int displayCount;
int displayWidth;
int borderFlag;
int count;
char *list[];
int cur;
int scrollOffset;
{
	int i;
	int index;

	if (count < displayCount) displayCount = count;

	if (borderFlag)
	{
		wattrset(win,A_BOLD);
		DrawBox(win,yorg,xorg,displayCount + 2,displayWidth + 2);
		yorg++; 
		xorg++;
	}

	for (i=0;i<displayCount;i++)
	{
		index = i + scrollOffset;
		wattrset(win,0);
		if (index == cur) wstandout(win);
		mvwaddstr(win,yorg+i,xorg,list[index]);
	}
	move(23,79);
}


int ProcessVerticalList (win,yorg,xorg,displayCount,borderFlag,
						 count,list,selectedIndex)
WINDOW *win;
int yorg;
int xorg;
int displayCount;
int borderFlag;
int count;
char *list[];
int *selectedIndex;
{
	int i;
	int cur;
	int scrollOffset;
	int len,maxWidth = 0;
	chtype ch;
	
	for (i = 0; i < count ; i++)
		if ((len = strlen(list[i])) > maxWidth) maxWidth = len;

	if (*selectedIndex >= 0 && *selectedIndex < count)
		cur = *selectedIndex;
	else
		cur = 0;

	scrollOffset = 0;
	if (cur >= scrollOffset + displayCount)
		scrollOffset = cur - (displayCount - 1);

	DisplayVerticalList (win, yorg, xorg, displayCount, maxWidth, borderFlag, 
						 count, list, cur, scrollOffset);
	wrefresh(win);

	while (1)
	{
		ch = getch();

		switch(ch)
		{
			case ERR:
				continue;

			case 27:
				getch();
				getch();
				break;

			case KEY_F(4):
			case 24:
				return(-1);

			case '\n':
				*selectedIndex = cur;
				return(0);

			case KEY_DOWN:
				if (cur + 1 < count)
				{
					cur++;
					if (cur >= scrollOffset + displayCount)
					scrollOffset = cur - (displayCount - 1);
				}
				break;

			case KEY_UP:
				if (cur - 1 >= 0)
				{
					cur--;
					if (cur < scrollOffset)
					scrollOffset = cur;
				}
				break;

			default:
				break;
		}

		DisplayVerticalList (win,yorg, xorg, displayCount, maxWidth,
			borderFlag, count, list, cur, scrollOffset);
		wrefresh(win);
	} /* while (1) */
}


int getKeyin(win,y,x,string)
WINDOW *win;
int y,x;
char *string;
{
	char s[80];
	char c;
	chtype ch;
	int count;
	
	count = 0;
	s[0] = 0;
	wmove(win,y,x);
	wrefresh(win);

	while(1)
	{
		ch = getch();

		c = (char)ch;

		switch(c)
		{
			case 27:
				getch();
				getch();
				break;

			case 24:
				return(-1);
				
			case '\n':
				strcpy(string,s);
				return(count);

			case 127:
				if (count > 0)
				{
					count--;
					s[count] = 0;
					wmove(win,y,x+count);
					wechochar(win,' ');
					wmove(win,y,x+count);
					wrefresh(win);
				}
				break;

			default:
				if (isprint(c))
				{
					wechochar(win,ch);
					s[count] = c;
					count++;
					s[count] = 0;
					wrefresh(win);
				}
		}
	}
}
