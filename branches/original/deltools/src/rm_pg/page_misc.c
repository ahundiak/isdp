#include	<stdlib.h>
#ifdef SunOS_4
#include <5curses.h>
#else
#include <curses.h>
#endif
#include "main.h"
    
extern	WINDOW *bottom, *help;

long	offsets[MAXPAGE];
long	sect_offsets[MAXSECTIONS][MAXSPAGE];
int	pageno;

write_page(rm, fd)

WINDOW *rm;
FILE   *fd;

{
    char	linebuf[256];
    int 	line;
    
    wmove(rm, 1, 1);
    
    for (line = 1; line < (LINES-10); line++) {
	if (!fgets(linebuf, sizeof linebuf, fd)) {
	    wclrtobot(rm);
#ifndef MY_OWN_BOX
	    box(rm, 0, 0);
#else
	    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
	    if (pageno != 0)	/* if not showing the first screen */
		mvwaddch(rm, 0, 2, ACS_UARROW);
	    mvwaddch(rm, LINES-10, 2, ACS_HLINE);
	    wnoutrefresh(rm);
	    move(LINES, 0);
	    doupdate();
	    return(0);
	}
	mvwprintw(rm, line, 1, "%s", linebuf);
    }
    
#ifndef MY_OWN_BOX
    box(rm, 0, 0);
#else
    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
    if (pageno != 0)	/* if not showing the first screen */
	mvwaddch(rm, 0, 2, ACS_UARROW);
    mvwaddch(rm, LINES-10, 2, ACS_DARROW);
    wnoutrefresh(rm);
    doupdate();
    return(1);
} /* write_page */



search_page(rm, fd, row)

WINDOW *rm;
FILE   *fd;
int	row;

{
    char	linebuf[256];
    int 	line;
    
    wmove(rm, 1, 1);
    
    for (line = 1; line < (LINES-10); line++) {
	if (!fgets(linebuf, sizeof linebuf, fd)) {
	    wattroff(rm, A_BOLD);
	    wclrtobot(rm);
#ifndef MY_OWN_BOX
	    box(rm, 0, 0);
#else
	    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
	    wnoutrefresh(rm);
	    move(LINES, 0);
	    doupdate();
	    return;
	}
	
	if (line == row)
	    wattron(rm, A_BOLD);
	else if (line == row +1)
	    wattroff(rm, A_BOLD);
	
	mvwprintw(rm, line, 1, "%s", linebuf);
    }
    
#ifndef MY_OWN_BOX
    box(rm, 0, 0);
#else
    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
    wnoutrefresh(rm);
    doupdate();
} /* write_page */



show_help(rm)

WINDOW *rm;

{
    int	line = 1;
    int	ch;
    
    werase(rm);
    
    mvwaddstr(rm, line++, 1, "  The up and down arrows scroll the display up and down.  To view the README ");
    mvwaddstr(rm, line++, 1, "  file by sections use the left and right arrows.  When viewing multiple");
    mvwaddstr(rm, line++, 1, "  files, \"n\" and \"p\" move to the next and previous file.  To exit the ");
    mvwaddstr(rm, line++, 1, "  README browser type a lower case \"q\".");
    line++;

    mvwaddstr(rm, line++, 1, "  To search for a word type a \"/\", and then at the prompt type the word");
    mvwaddstr(rm, line++, 1, "  followed by a <Return>.  If the word is found within the README file,");
    mvwaddstr(rm, line++, 1, "  the line of text where the word is located will be highlighted");
    line++;

    mvwaddstr(rm, line++, 1, "  To save the currently displayed section to a file type a lower case");
    mvwaddstr(rm, line++, 1, "  \"s\", and then at the prompt type in the name of the file followed");
    mvwaddstr(rm, line++, 1, "  by a <Return>.");
    line++;

    werase(help);
    mvwaddstr(help, 1, 1, " Press the space bar to continue");
    mvwaddstr(help, 2, 1, " Press \"q\" to exit the program");
#ifndef MY_OWN_BOX
    box(help, 0, 0);
#else
    my_box(help, ACS_VLINE, ACS_HLINE);
#endif
    wrefresh(help);

#ifndef MY_OWN_BOX
    box(rm, 0, 0);
#else
    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
    wnoutrefresh(rm);
    doupdate();
    
    ch = wgetch(bottom);
    while ((ch != ' ') && (ch != 'q'))
	ch = wgetch(bottom);
    
    if (ch == 'q')
	done();
    else {
	werase(help);
	mvwaddstr(help, 1, 1, "Up/Down Arrows scroll README");
	mvwaddstr(help, 2, 1, "Right/Left Arrows scroll Sections");
	mvwaddstr(help, 3, 1, "q=Quit ?=Help /=Search s=Save");
#ifndef MY_OWN_BOX
	box(help, 0, 0);
#else
	my_box(help, ACS_VLINE, ACS_HLINE);
#endif
	wrefresh(help);
    }

} /* show_help */
