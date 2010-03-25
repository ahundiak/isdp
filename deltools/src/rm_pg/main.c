#include	<stdlib.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#ifdef SunOS_4
#include <5curses.h>
#else
#include <curses.h>
#endif
#include "main.h"

extern	char	*sys_errlist[];

extern	int	pageno;
extern	long	offsets[MAXPAGE];
extern	long	sect_offsets[MAXSECTIONS][MAXSPAGE];
extern	int	sect_page;
extern	int	num_sections;
extern	char	sect_array[MAXSECTIONS][MAXSECTION_LEN];
extern	int	displaying_a_section;
extern	int	found_end_of_section;
extern	char	last_word[MAXLINE];

int	sect_ind = 0;
WINDOW	*bottom, *help;
int	search_from_start = FALSE;
FILE	*fd;

#ifndef MY_OWN_BOX
void my_box(win, v, h)
WINDOW *win;
chtype v;
chtype h;
{
        int curx, cury;
        getyx(win, cury, curx);
        box(win, v, h); 
        wattron(win, A_ALTCHARSET);
        mvwaddch(win, 0, 0, 'l'); 
        mvwaddch(win, win->_maxy-1, 0, 'm');
        mvwaddch(win, 0, win->_maxx-1, 'k');
        mvwaddch(win, win->_maxy-1, win->_maxx-1, 'j');
        wattroff(win, A_ALTCHARSET);
        move(cury, curx);
}
#endif


main(argc, argv)
int	argc;
char	*argv[];

{
    void	done(), perror(), exit();
    WINDOW	*rm, *top, *sect;
    int		ch;
    char	search_word[MAXLINE], filenm[MAXLINE];
    int		search_mode = FALSE;
    long	save_spot;
    char	cmd[MAXLINE];
    int		sts;
    int		i, j;
    int		argindex;
    int		processing_this_file;
    int		got_a_file;
    
    if (argc < 2) {
	fprintf(stderr, "usage: %s file [file2 file3...]\n", argv[0]);
	exit(1);
    }
    
    signal(SIGINT, done);
    
    initscr();
    noecho();
    cbreak();
    nonl(); 
    idlok(stdscr, TRUE);
    
    top = newwin(4, COLS, 0, 0);
#ifndef MY_OWN_BOX
    box(top, 0, 0);
#else
    my_box(top, ACS_VLINE, ACS_HLINE);
#endif
    wrefresh(top);
    
    rm = newwin(LINES-9, COLS, 4, 0);
#ifndef MY_OWN_BOX
    box(rm, 0, 0);
#else
    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
    wrefresh(rm);
    
    help = newwin(5, (COLS-1)/2, LINES-5, 0);
#ifndef MY_OWN_BOX
    box(help, 0, 0);
#else
    my_box(help, ACS_VLINE, ACS_HLINE);
#endif
    mvwaddstr(help, 1, 1, "Up/Down Arrows scroll README");
    mvwaddstr(help, 2, 1, "Right/Left Arrows scroll Sections");
    mvwaddstr(help, 3, 1, "q=Quit ?=Help /=Search s=Save");
    wrefresh(help);
    
    sect = newwin(3, (COLS-1)/2, LINES-5, COLS/2);
#ifndef MY_OWN_BOX
    box(sect, 0, 0);
#else
    my_box(sect, ACS_VLINE, ACS_HLINE);
#endif
    wrefresh(sect);
    
    bottom = newwin(3, (COLS-1)/2, LINES-2, COLS/2);
    wrefresh(bottom);
    
    argindex = 1;

    while (1) {
	if ((fd=fopen(argv[argindex], "r")) == NULL) {
	    werase(top);
#ifndef MY_OWN_BOX
	    box(top, 0, 0);
#else
	    my_box(top, ACS_VLINE, ACS_HLINE);
#endif
	    mvwprintw(top, 1, 1, "Could not open %s:", argv[argindex]);
	    mvwprintw(top, 2, 1, sys_errlist[errno]);
	    wrefresh(top);
	    got_a_file = 0;
	}
	else
	    got_a_file = 1;

	offsets[0] = 0;
	for (i = 1; i < MAXPAGE; i++)
	    offsets[i] = -1;
	
	for (i = 0; i < MAXSECTIONS; i++) {
	    sect_offsets[i][0] = 0;
	    for (j = 1; j < MAXSPAGE; j++)
		sect_offsets[i][j] = -1;
	}
    
	pageno = 0;
	sect_ind = 0;
    

	if (got_a_file) {
	    get_sections(argv[argindex]);

	    werase(top);
#ifndef MY_OWN_BOX
	    box(top, 0, 0);
#else
	    my_box(top, ACS_VLINE, ACS_HLINE);
#endif
	    show_current(top, argv[argindex]);
	    
	    write_page(rm, fd);
	    write_section(sect, sect_ind);
	}
    
	processing_this_file = 1;

	keypad(bottom, TRUE);

/* notimeout not available on HP. -- MVR 30 Apr 1994 */
#ifndef HP_UX
	notimeout(bottom, TRUE);
#endif

	wmove(bottom, 0, 1);
	ch = wgetch(bottom);
    
	while ((ch != 'q') && processing_this_file) {
	    wclrtoeol(bottom);
	    switch(ch) {
	    case 'n':
		if (argindex == (argc - 1)) {
		    /* There's no next file.  Indicate this... */
		    wprintw(bottom, "No next file.");
		    /* Do a refresh. Needed for HP -- MVR 3 May 1994 */
		    wrefresh(bottom);
		}
		else {
		    fclose(fd);
		    werase(rm);
#ifndef MY_OWN_BOX
		    box(rm, 0, 0);
#else
		    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
		    wrefresh(rm);
		    argindex++;
		    processing_this_file = 0;
		}
		break;
	    case 'p':
		if (argindex == 1) {
		    /* There's no previous file.  Indicate this... */
		    wprintw(bottom, "No previous file.");
		    /* Do a refresh. Needed for HP -- MVR 3 May 1994 */
		    wrefresh(bottom);
		}
		else {
		    fclose(fd);
		    werase(rm);
#ifndef MY_OWN_BOX
		    box(rm, 0, 0);
#else
		    my_box(rm, ACS_VLINE, ACS_HLINE);
#endif
		    wrefresh(rm);
		    argindex--;
		    processing_this_file = 0;
		}
		break;
	    case ' ':
	    case KEY_DOWN:
		if (got_a_file) {
		    if (displaying_a_section) { 
			if (sect_offsets[sect_ind][sect_page+1] == -1)
			    break;
		    
			sect_page++;
			find_section(rm, sect_ind, fd);
			*last_word = '\0';
		    }
		    else {
			if (offsets[pageno+1] == -1)
			    break;
			
			pageno++;
			fseek(fd, offsets[pageno], 0);
			write_page(rm, fd);
			search_from_start = FALSE;
			*last_word = '\0';
		    }
		}
		break;
		
	    case KEY_UP:
		if (got_a_file) {
		    if (displaying_a_section) {
			if (sect_page == 0)
			    break;
			sect_page--;
			
			fseek(fd, sect_offsets[sect_ind][sect_page], 0);
			find_section(rm, sect_ind, fd);
			*last_word = '\0';
		    }
		    else {
			if (pageno == 0)
			    break;
			pageno--;
			fseek(fd, offsets[pageno], 0);
			write_page(rm, fd);
			*last_word = '\0';
		    }
		}
		break;
		
	    case KEY_LEFT:
		if (got_a_file) {
		    if (sect_ind > 0)
			sect_ind--;
		    else
			sect_ind = num_sections;
		    
		    if (sect_ind > 0) {
			write_section(sect, sect_ind);
			rewind(fd);
			sect_page = 0;
			find_section(rm, sect_ind, fd);
			displaying_a_section = TRUE;
		    }
		    else {	 /* show entire readme */
			rewind(fd);
			pageno = 0;
			write_section(sect, sect_ind);
			write_page(rm, fd);
			search_from_start = TRUE;
			displaying_a_section = FALSE;
		    } /* else */
		}
		break;
		
	    case KEY_RIGHT:
		if (got_a_file) {
		    if (sect_ind < num_sections)
			sect_ind++;
		    else				/* wrap around */
			sect_ind = 0;  
		    
		    if (sect_ind > 0) {
			write_section(sect, sect_ind);
			rewind(fd);
			displaying_a_section = FALSE;
			sect_page = 0;
			find_section(rm, sect_ind, fd);
			displaying_a_section = TRUE;
		    }
		    else {	/* show entire readme */
			rewind(fd);
			pageno = 0;
			write_section(sect, sect_ind);
			write_page(rm, fd);
			search_from_start = TRUE;
			displaying_a_section = FALSE;
		    } /* else */
		}
		break;
		
	    case '/':
		if (got_a_file) {
		    nl();
		    waddstr(bottom, "Search for: ");
		    /* Do a refresh. Needed for HP -- MVR 3 May 1994 */
		    wrefresh(bottom);
		    echo();
		    wgetstr(bottom, search_word);
		
		    /* display entire readme */
		    if (displaying_a_section) {
			rewind(fd);
			sect_ind = 0;
			pageno = 0;
			write_section(sect, sect_ind);
			write_page(rm, fd);
			displaying_a_section = FALSE;
			rewind(fd);
			search_from_start = TRUE;
		    }
		    
		    sts = search_forward(rm, search_word, fd, 0);
		    
		    wmove(bottom, 0, 1);
		    wclrtoeol(bottom);
		    nonl(); 
		    noecho();
		    
		    if (!sts) {	/* if the string was not found */
			wprintw(bottom, "%s not found", search_word);
		    	/* Do a refresh. Needed for HP -- MVR 3 May 1994 */
		    	wrefresh(bottom);
			rewind(fd);
			pageno = 0;
			write_section(sect, sect_ind);
			write_page(rm, fd);
			search_from_start = TRUE;
			displaying_a_section = FALSE;
		    }
		}
		else {
		    mvwprintw(bottom, 0, 1, "Not displaying a file");
		    wrefresh(bottom);
		}
		break;
		
	    case 's':
		if (got_a_file) {
		    nl();
		    waddstr(bottom, "Filename: ");
		    /* Do a refresh. Needed for HP -- MVR 2 May 1994 */
		    wrefresh(bottom);
		    echo();
		    wgetstr(bottom, filenm);
		    
		    if (filenm[0] == '\0') {    /* bail out */
			wmove(bottom, 0, 1);
			wclrtoeol(bottom);
			nonl(); 
			noecho();
			break;
		    } /* if */
		    
		    
		    if (sect_ind == 0) {	/* if entire readme */
			sprintf(cmd, "cp %s %s", argv[1], filenm);
			system(cmd);
		    }
		    else {
			save_spot = ftell(fd);
			rewind(fd);
			save_to_file(fd, sect_ind, filenm);
			fseek(fd, save_spot, 0);
		    } 
		
		    wmove(bottom, 0, 1);
		    /* Clear to EOL and refresh the bottmom window -- MVR 3 May 1994 */
		    wclrtoeol(bottom);
		    wrefresh(bottom);
		    nonl(); 
		    noecho();
		    wprintw(bottom, "Section saved to %s", filenm);
		    /* Do a refresh. Needed for HP -- MVR 2 May 1994 */
		    wrefresh(bottom);
		}
		else {
		    mvwprintw(bottom, 0, 1, "Not displaying a file.");
		    wrefresh(bottom);
		}
		break;
		
	    case '?':
		show_help(rm);
		if (got_a_file) {
		    if (displaying_a_section) {
			fseek(fd, sect_offsets[sect_ind][sect_page], 0);
			find_section(rm, sect_ind, fd);
		    }
		    else {
			fseek(fd, offsets[pageno], 0);
			write_page(rm, fd);
		    }
		}
		break;
	    case KEY_CLEAR:
	    case '\014':		/* CTRL-L */
		wrefresh(curscr);
		break;
	    }
	    
	    if (!search_mode)
		wmove(bottom, 0, 1); 

	    if (processing_this_file)
		ch = wgetch(bottom);
	} 
	if (ch == 'q') 
	    done();
    }

} /* main */


void done()
{
    void exit();
    
    fclose(fd);
    move(LINES-1, 0);
    clrtoeol();
    refresh();
    endwin();
    exit(0);
} /* done*/

