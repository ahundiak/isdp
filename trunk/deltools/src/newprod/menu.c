#include	<stdlib.h>
#include	<ctype.h>
#include	<signal.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#ifdef SunOS_4
#include	<5curses.h>
#else 
#include	<sys/ioctl.h>
#if defined(__clipper__) && defined(BSD_CURSES)
#include	<bsdcurses.h>
#else
#include	<curses.h>
#endif
#endif /* sun */
#if defined(SVR4) || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE)
#include	<termios.h>
#endif
#include	"defs.h"

/*
 * the default value for the top of the product scrolling region
 */
#define SCROLLTOP	5

extern char	*fsys_choose();
extern short	verbose;	/*if set, add'l error msgs generated*/
extern short	srcmedia;
extern short	makenode;
extern char	mountpoint[STRSIZ];
extern char	*cpu_types[];
extern struct stat statbuf;
extern unsigned long	my_arch;

extern FILE	*logf;

short	allvis = 0;
short	tmpallvis = 0;
short	justinvis = 0;
short	curses_is_running = 0;
static short	numbers = 0;
static short	locations = 0;

char *statustext[] = {
	"Needs updating",
	"System newer",
	"New",
	"Up to date",
	"Installed",
	"Errors",
	"Deliverable"
};

char *statusline[] = {
    "Arrows  <SPACE>=Select  a=Autoselect   c=Clear   r=Review   h=Help   u=Update\n<DELETE>=Return to Main menu   f=Choose file system   ?=Newprod help    q=Quit",
    "Arrows  <SPACE>=Select  a=Autoselect   c=Clear    /=Search for product name\nm = Enter All-products menu   f=Choose file system   ?=Newprod Help    q=Quit"};

int	class;
short	multimenu;
short	scrollbot;
short	scrolltop;

void newprodhelp(){
	extern char	*dashes;
	int line;

	clear(); 
	line = 0;

	mvprintw(line++, 0,"Use this keystroke     To invoke this action");
	mvprintw(line++, 0,"--------------------   ---------------------------------------------------------");
	mvprintw(line++, 0,"    <Return>,<Space> | Toggle SELECTION of a product or enter a sub-menu");
	mvprintw(line++, 0,"                a, A | AUTOSELECT all products that need to be updated");
	mvprintw(line++, 0,"                c, C | CLEAR all selected products");
	mvprintw(line++, 0,"                u, U | UPDATE selected products (U forces to chosen file system)");
	mvprintw(line++, 0,"                   h | HELP; display help on installing selected products");
	mvprintw(line++, 0,"                   r | REVIEW release notes of product at cursor");
	mvprintw(line++, 0,"<Backspace>,<Delete> | Return to MAIN CLASSIFICATION MENU");
	mvprintw(line++, 0,"                   l | LOCATIONS; display current locations of loaded products");
	mvprintw(line++, 0,"                   m | MENU; toggles between multi-menu and single-menu");
	mvprintw(line++, 0,"                   n | NUMBERS; toggles the display of product numbers on/off");
	if (makenode)
	    mvprintw(line++, 0,"                   p | PLATFORMS; display valid platforms for product");
	mvprintw(line++, 0,"                   i | Show INVISIBLE products");
	mvprintw(line++, 0,"           /<string> | SEARCH for a product name");
	mvprintw(line++, 0,"                   f | FILE SYSTEM; select file system to download products to");
	mvprintw(line++, 0,"         ! <command> | SHELL command; execute a command without exiting");
	mvprintw(line++, 0,"                q, e | QUIT; any selected products are not loaded");
	mvprintw(line++, 0,"            <Ctrl-L> | REFRESH the screen");
	mvprintw(line++, 0,"                v, V | VERBOSE; display more download messages");
	if (!makenode) {
		mvprintw(line++, 0,"          d, D, y, Y | DEFAULTS; install products using installation defaults");
		mvprintw(line++, 0,"                x, X | EXECUTE; display install script while executing");
		mvprintw(line++, 0,"                z, Z | Answer questions only -- no installation");
		mvprintw(line++, 0,"                       (Z forces to chosen file system)");
	}
	mvprintw(scrollbot, 0, dashes);
	mvprintw(scrollbot+1, 0,"<SPACE>=More help                    Any other key returns to the menu");
	refresh();

	if (getch() != ' ')
		return;

	clear(); 
	line = 0;

	mvprintw(line++, 0,"Moving the Cursor:");
	mvprintw(line++, 0,"------------------");
	mvprintw(line++, 0,"Newprod accepts arrow keys, vi keystrokes, and emacs keystrokes for\n");
	mvprintw(line++, 0,"moving the cursor.");

	move(line++, 0); 
	clrtoeol();

	mvprintw(line++, 0,"Action          Arrow Keys      vi keystroke    emacs keystroke");
	mvprintw(line++, 0,"--------------  -------------   ------------    -----------------");
	mvprintw(line++, 0,"UP a line       Up arrow        k               <Ctrl-P>");
	mvprintw(line++, 0,"DOWN a line     Down arrow      j               <Ctrl-N>");
	mvprintw(line++, 0,"BACK a page     Left arrow      <Ctrl-U>        <Ctrl-Z>, <ESC> V");
	mvprintw(line++, 0,"FORWARD a page  Right arrow     <Ctrl-D>        <Ctrl-V>");
	mvprintw(line++, 0,"TOP of the list                 T, 1            <ESC> <");
	mvprintw(line++, 0,"BOTTOM of the list              B, G            <ESC> >");

	move(line++, 0); 
	clrtoeol();

	mvprintw(line++, 0,"Status Flags");
	mvprintw(line++, 0,"------------");
	mvprintw(line++, 0,"Flag  Meaning");
	mvprintw(line++, 0,"----  --------------------------------------------------------------------");
	mvprintw(line++, 0," *    This product can be loaded without a CD/ROM load key");
	mvprintw(line++, 0," >    This product's CD/ROM load key has already been entered");
	mvprintw(line++, 0," ~    This product is loaded by another product and should not be selected");
	mvprintw(line++, 0," =    This product is a product that references other products");

mvprintw(scrollbot, 0, dashes);
mvprintw(scrollbot+1, 0, "Press any key to return to the menu: ");
refresh();

	getch();
}


int	visible(p, pptr)
struct prodnode	*p, *pptr;
{
	if (multimenu && strcmp(p->prodclass, pptr->prodclass))
		return(0);
	if (p->pstat & LOAD_ERRORS)
		return(1);
	if (allvis || tmpallvis)
		return(1);
	if (justinvis)
	    return(p->attr & ATTR_INVISIBLE);
	else {
	    if (!makenode) {
		    if (p->arch & my_arch)
			return(!(p->attr & ATTR_INVISIBLE));
		    else
			return(0);
	    }
	    else
		return(!(p->attr & ATTR_INVISIBLE));

	}
}

struct prodnode	*first(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;
	extern void statuserr();

	/*
	 * if were in the class menu, then return the first class pointer
	 */
	if (class)
		return(h->flink);

	/*
	 * return the first visible entry or one with errors
	 */
	for (p = h->flink; p != h; p = p->flink)
		if (visible(p, pptr))
			break;

	/*
	 * if we didn't find any entries, then go to allvis mode.
	 */
	if (p == h) {
		/*allvis = !allvis;*/
		statuserr("No products to show -- temporarily changing to 'All Visible' mode");
		tmpallvis = 1;
		p = first(pptr, h);
	}
	return(p);
}

struct prodnode	*next(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;

	if (class)
		return(pptr->flink);

	/*
	 * return the next visible entry or one with errors
	 */
	for (p = pptr->flink; p != h; p = p->flink)
		if (visible(p, pptr))
			break;

	return(p);
}

struct prodnode	*last(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;
	extern void statuserr();

	if (class)
		return(h->blink);

	/*
	 * otherwise, return the visible entry or one with errors
	 */
	for (p = h->blink; p != h; p = p->blink)
		if (visible(p, pptr))
			break;

	/*
	 * if we don't have any visible entries, then go to allvis mode.
	 */
	if (p == h) {
		/*		allvis = !allvis; */
		statuserr("No visible products -- temporarily changing to 'All Visible' mode");
		tmpallvis = 1;
		p = last(pptr, h);
	}
	return(p);
}

struct prodnode	*prev(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;

	if (class)
		return(pptr->blink);

	/*
	 * return the previous visible entry or one with errors
	 */
	for (p = pptr->blink; p != h; p = p->blink)
		if (visible(p, pptr))
			break;

	return(p);
}


char	*catstr(s1, s2)
char	*s1, *s2;
{
	static char result[STRSIZ*2];

	strcpy(result, s1);
	strcat(result, s2);

	return(result);
}

void	show_line(pptr, pos)
register struct prodnode	*pptr;
int	pos;
{
	char	archs[64];
	char	visichar[5];
	char	*statstr;
	int	i;

	if (class) {
		mvprintw(pos, 1, "%-54.54s %3d out of %3d selected",
			pptr->prodclass, pptr->pstat, pptr->blocksize);
		clrtoeol();
	} else {
		archs[0]=0;
		if (makenode) {
		    for (i = 0; (i < NUM_ARCH) && (*cpu_types[i] != '\0'); i++) {
			if ( pptr->arch & (1 << i)) {
			    strcat(archs, cpu_types[i]);
			    strcat(archs, " ");
			}
		    }
		}

	 	if (pptr->pstat & SELECTED)
			attrset(A_REVERSE);
		
		if (locations) {
		    if (numbers) {
			mvprintw(pos, 1, "%-9.9s %-15.15s %-21.21s %-11s ",
			     pptr->prodname, pptr->prodnumber, pptr->loadeddir,
			     pptr->loadedvers);
		    }
		    else {
			mvprintw(pos, 1, "%-12.12s %-34.34s %-11s ",
			     pptr->prodname, pptr->loadeddir,
			     pptr->loadedvers);
		    }
		}
		else {
		  if (makenode) {
		    if (numbers) {
			mvprintw(pos, 1, "%-9.9s %-15.15s %-15.15s %6d %-11s ",
			     pptr->prodname, pptr->prodnumber,
			     catstr(archs, pptr->prodtitle), pptr->blocksize/(makenode ? 2 : 1),
			     pptr->prodversion);
		    }
		    else {
			mvprintw(pos, 1, "%-12.12s %-27.27s %6d %-11s ",
			     pptr->prodname, 
			     catstr(archs, pptr->prodtitle), pptr->blocksize/(makenode ? 2 : 1),
			     pptr->prodversion);

		    }
		  }
		  else {
		    if (numbers) {
			mvprintw(pos, 1, "%-9.9s %-15.15s %-15.15s %6d %-11s ",
			     pptr->prodname, pptr->prodnumber,
			     pptr->prodtitle, pptr->blocksize/(makenode ? 2 : 1),
			     pptr->prodversion);
		    }
		    else {
			mvprintw(pos, 1, "%-12.12s %-27.27s %6d %-11s ",
			     pptr->prodname, 
			     pptr->prodtitle, pptr->blocksize/(makenode ? 2 : 1),
			     pptr->prodversion);

		    }
		  }
		}
		strcpy(visichar, "    ");
		if (pptr->attr & ATTR_INVISIBLE)
			visichar[0] =  '~';
		if (pptr->attr & ATTR_BOM)
			visichar[0] = '=';
		if (!makenode && !(pptr->arch & my_arch))
			visichar[1] = 'X';

		if (srcmedia == CDROM || srcmedia == NETCDROM) {
		    if (atoi(pptr->flags))
			visichar[2] = (pptr->pstat & HAVEKEY ? '>' : ' ');
		    else
			visichar[2] = '*';
		}
		printw("%3s", visichar);

		if (pptr->pstat & DOWNLOAD_OK)
		    statstr = "Installed";
		else if (pptr->pstat & LOAD_ERRORS)
		    statstr = "Errors";
		else if (pptr->pstat & DELIVTREE)
		    statstr = "Available";
		else
		    statstr = statustext[pptr->pstat & 0x0f];
		mvprintw(pos, 65, "%-14s", statstr);
		attrset(A_NORMAL);
		refresh();
	}
}

void	show_size(size)
int	size;
{
	extern short	minus_x;
	extern short	takedefaults;
	char	vischar;

	mvprintw(scrolltop-3, 55,"%8d blocks selected", size);
	clrtoeol();
	if (allvis || tmpallvis)
	    vischar = 'I';
	else if (justinvis)
	    vischar = 'i';
	else
	    vischar = ' ';

	mvprintw(0, 61, "%c%c%c%c", takedefaults ? 'D' : ' ',
                verbose ? 'V' : ' ', minus_x ? 'X' : ' ', vischar);
	refresh();
}

void	show_screen(h, start, cursorlimit, size)
struct prodnode	*h, *start;
int	*cursorlimit, size;
{
	register struct prodnode	*pptr;
	register int	i, j;

	show_size(size);
	for (i = scrolltop, pptr = start; i < scrollbot && pptr != h;
		    ++i, pptr = next(pptr, h))
	    show_line(pptr, i);

	for (j = i; j <= *cursorlimit; ++j) {	/* erase unused lines */ 
	    move(j, 0);
	    clrtoeol();
	}
	refresh();
	*cursorlimit = i - 1;
}

void	refresh_screen(classptr, size, freeblks)
struct prodnode	*classptr;
int	size, freeblks;
{
	extern char	*dashes;
	extern char	cdrel[16];

	/* set up screen */
	clear();

	if (!locations) {
	  if (class) {
	      mvprintw(0,0, "%s Available Products -- Classifications Menu",
			(makenode ? "Makenode" : "Newprod"));
	  }
	  else {
	    if (multimenu) 
		mvprintw(0,0, "%s Available Products -- %s Menu",
			(makenode ? "Makenode" : "Newprod"), classptr->prodclass);
	    else 
		mvprintw(0,0, "%s Available Products -- All Products Menu",
			(makenode ? "Makenode" : "Newprod"));
	    
	  }

/*
	    mvprintw(0, 0, "%s Available Products -- %s Menu",
		(makenode ? "Makenode" : "Newprod"),
		(class ? "Classifications" : (multimenu ? classptr->prodclass :
			"All Products")));
*/
	}
	else
	    mvprintw(0, 0, "%s INSTALLED LOCATIONS -- %s Menu",
		(makenode ? "Makenode" : "Newprod"),
		(class ? "Classifications" : (multimenu ? classptr->prodclass :
			"All Products")));

	if ((srcmedia == CDROM || srcmedia == NETCDROM) && cdrel[0]) {
		mvprintw(1, 0, "CD/ROM Release date: %s", cdrel);
	}
	mvprintw(scrolltop - 3, 0, "Free space on %s: %d blocks.", mountpoint, freeblks);
	show_size(size);
	if (class) {
	    mvaddstr(scrolltop - 2, 0, " Classification title                                    Status");
	} else {
	    if (locations) {
	      if (numbers)
		mvaddstr(scrolltop - 2, 0, " Name      Number          Loaded In           Loaded Version      Status");
	      else
		mvaddstr(scrolltop - 2, 0, " Name         Loaded In                        Loaded Version      Status");
	    }
	    else {
	      if (numbers)
		mvaddstr(scrolltop - 2, 0, " Name      Number          Title           Blocks   Version        Status");

	      else
		mvaddstr(scrolltop - 2, 0, " Name         Title                       Blocks   Version         Status");
	    }
	}
	mvprintw(scrolltop - 1, 0, dashes);
	mvprintw(scrollbot, 0, dashes);
	mvprintw(scrollbot + 1, 0, statusline[class]);
	move(scrolltop, 0);
	wrefresh(stdscr);
}

void	statuserr(str)
char	*str;
{
	move(scrollbot+1, 0);
	clrtobot();
	mvprintw(scrollbot+1, 0, str);
	mvprintw(scrollbot+2, 0, "Press any key to continue: ");
	refresh();
	getch();
	move(scrollbot+1, 0);
	clrtobot();
	mvprintw(scrollbot+1, 0, statusline[class]);
}

/* This routine is called to display the menu of products available on
** a given host and process the user's keyin selections.
*/
short	process_menu(header, classheader, optionlist)
struct prodnode	*header, *classheader, **optionlist;
{
    struct prodnode	*start, *cstart, *pptr, *currpptr, *currhdr, *currclass;
    int			c, i, cursor, ocursor, ccursor, cursorlimit, size;
    int			freeblks;
    int			next_opt;
    int			exit_status = 0;
    short		flg;
    char		oldfind[10], findprod[10], namecmp[10], numcmp[10];
    char		archstr[128];
    char		longinfo[160];
    extern char		cdrel[16];
    extern short	minus_x;
    extern short	takedefaults;
    extern void		terminate();
    extern void		lostpeer();
    extern int		act_on_products();
#ifdef VSUSP
# if defined(SVR3) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)
    struct termio	tio;
# endif
/* HP added here 30 Apr 1994 */
# if defined(SunOS_4) || defined(SVR4) || defined(_AIX) || defined(OSF) || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE) || defined(HP_UX)
    struct termios	tio;
# endif
#endif
#if !defined(TIOCGWINSZ) || defined(SCO)
    char		*linesval;
#else
    struct winsize	winbf;
#endif
    

#ifdef VSUSP
    /* Disable "suspend" character so we can catch ^Z ourselves... */
#  ifdef SVR3
    ioctl(0, TCGETA, &tio);
    tio.c_cc[VSUSP] = 0xff;
    ioctl(0, TCSETA, &tio);
#  endif
/* HP added in the list -- MVR 30 Apr 1994 */
#  if defined(SunOS_4) || defined(SVR4) || defined(_AIX) || defined(OSF)  || defined(HP_UX)
    if (tcgetattr(0, &tio) < 0) {
	PRINT "Couldn't get terminal attributes\n");
	sleep(5);
    }
    tio.c_cc[VSUSP] = 0x0;
    if (tcsetattr(0, TCSANOW, &tio) < 0) {
	PRINT "Couldn't set terminal attributes\n");
	sleep(5);
    }
#  endif
#endif

    initscr();
    curses_is_running = 1;
    cbreak();
    noecho();
    nonl();
    intrflush(stdscr, FALSE);
    keypad(stdscr, TRUE);
    leaveok(stdscr, FALSE);

/* curs_set not avalilabe on HP  -- MVR 30 Apr 1994 */
#ifndef HP_UX
    curs_set(0);
#endif

#if !(defined(BSD_CURSES) || defined(_AIX))
/* notimeout not available for HP. Hence not called. 
 * need to test for side effects  -- MVR 30 Apr 1994 
*/
#ifndef HP_UX
    notimeout(stdscr, TRUE);
#endif
#endif
    
    signal(SIGINT, terminate);
    signal(SIGHUP, terminate);
    signal(SIGQUIT, terminate);
    signal(SIGTERM, terminate);
    signal(SIGPIPE, lostpeer);

    size = 0;

#if !defined(TIOCGWINSZ) || defined(SCO)
    linesval = (char*)getenv("LINES");
    if (linesval == NULL)
	scrollbot = 24;
    else if (!(scrollbot = atoi(linesval)))
	scrollbot = 24;
#else
    if (isatty(1)) {
	ioctl(1, TIOCGWINSZ, &winbf);
	if (winbf.ws_row)
	    scrollbot = winbf.ws_row;
	else
	    scrollbot = 24;
    }
    else
	scrollbot = 24;
#endif

    scrollbot -= 3;
    cursorlimit = scrollbot - 2;
    scrolltop = SCROLLTOP - 1;
    if ((srcmedia == CDROM || srcmedia == NETCDROM) && cdrel[0])
	++scrolltop;
    
    freeblks = num_free_blks(mountpoint);

    if (!multimenu || classheader->blocksize == 1) {
	currhdr = header;
	class = 0;
	multimenu = 0;
    } else {
	currhdr = classheader;
	class = 1;
	multimenu = 1;
    }
    
    currclass = (struct prodnode *)0;
    cstart = classheader->flink;
    start = first(currhdr,currhdr);
    refresh_screen(currhdr, size, freeblks);
    show_screen(currhdr, start, &cursorlimit, size);
    cursor = ocursor = ccursor = scrolltop;
    
    for(;;) {
	mvaddch(ocursor, 0, ' ');
	mvaddch(cursor, 0, '>');
	ocursor = cursor;
	if (multimenu && class)
	    ccursor = cursor;

	wrefresh(stdscr);

	c = getch();
	switch (c) {
	case  033: /* this must be some escape sequence */
	case 0233: /* this must be some 8-bit sequence */
	    c = getch();
	    switch(c) {
	    case 'v': /* go back a page */
	    case 'V':
		goto pageup;
	    case '<': /* goto top */
		goto pagetotop;
	    case '>': /* goto bottom */
		goto pagetobottom;
	    case 'A': /* move up with possible page up */
		goto cursorup;
	    case 'B': /* move down with possible page down */
		goto cursordown;
	    case 'C': /* move right - go forward a page */
		goto pagedown;
	    case 'D': /* move left - go back a page */
		goto pageup;
	    }
	    
	case KEY_UP:
	case 0x85: /* cursor up a line - up arrow in black screen */
	case 0x05:
	case 020:
	case 'k':
	cursorup:
	    cursor--;
	    if (cursor < scrolltop) {
		cursor = (prev(start, currhdr) == currhdr ?
			  scrolltop : scrollbot - 1);
		goto pageup;
	    }
	    break;
	    
	case KEY_DOWN:
	case 0x83: /* cursor down a line - down arrow in black screen */
	case 0x03:
	case '\016':
	case 'j':
	cursordown:
	    ++cursor;
	    if (cursor > cursorlimit) {
		cursor = (cursorlimit != scrollbot - 1 ?
			  cursorlimit : scrolltop);
		goto pagedown;
	    }
	    break;
	    
	case KEY_LEFT:
	case 0x80: /* go up a page - left arrow in black screen */
	case 000:
	case 032: /* go up a page - emacs */
	case 025: /* go up a page - vi (ctrl-u) */
	case 002: /* go up a page - vi (ctrl-b) */
	pageup:
	    if (prev(start, currhdr) == currhdr) {
		if (cursor == scrolltop && !class)
		    break;	/* goto enter_main_class_menu; */
		else
		    cursor = scrolltop;
		break; /* if at topmost, don't do anything */
	    }
	    for (i = scrolltop; i < scrollbot && prev(start, currhdr) != currhdr;
		 ++i, start = prev(start, currhdr))
		;
	    show_screen(currhdr, start, &cursorlimit, size);
	    cursor = cursorlimit;
	    break;
	    
	case KEY_RIGHT:
	case 0x84: /* go down a page - right arrow in black screen */
	case 026: /* go down a page - emacs */
	case 004: /* go down a page - vi (ctrl-d) */
	case 006: /* go down a page - vi (ctrl-f) */
	pagedown:
	    for (i = scrolltop, pptr = start;
		 i < scrollbot && next(pptr, currhdr) != currhdr;
		 ++i, pptr = next(pptr, currhdr))
		;
	    if (start != pptr && i == scrollbot) {
		start = pptr;
		show_screen(currhdr, start, &cursorlimit, size);
		cursor = (cursor > cursorlimit ? cursorlimit : cursor);
	    } else
		cursor = cursorlimit;
	    break;
	    
	case 'T': /* go to the top of the list */
	case '1': /* go to the top of the list */
	pagetotop:
	    if (cursor != scrolltop)
		cursor = scrolltop;
	    if (prev(start, currhdr) == currhdr)
		break;	/* if at topmost, don't do anything */
	    start = first(start, currhdr);
	    show_screen(currhdr, start, &cursorlimit, size);
	    break;
	    
	case 'G': /* G = go to bottom in vi */
	case 'B': /* go to the bottom of the list */
	pagetobottom:
	    for (i = scrollbot - 1, start = last(currclass, currhdr);
		 i > scrolltop && prev(start, currhdr) != currhdr;
		 i--, start = prev(start, currhdr))
		;
	    if (i == scrolltop)
		show_screen(currhdr, start, &cursorlimit, size);
	    cursor = cursorlimit;
	    break;
	    
	case 010: /* BS - go back to class menu */
	case 0177: /* DELETE - go back to class menu */
	    if (class) {
		statuserr("Already in classification menu.");
		break;
	    }
	    tmpallvis = 0;
	    goto enter_main_class_menu;
	    
	case 'M': /* Toggle multimenu mode */
	case 'm':
	    if (class)
		cstart = start;
	    
	    if (multimenu) {	/* turn off multi-menu */
	    enter_all_products:
		multimenu = 0;
		currhdr = header;
		cursor = scrolltop;
		class = 0;
		tmpallvis = 0;
		start = first(currhdr, currhdr);
	    } else {		/* turn on multi-menu */
	    enter_main_class_menu:
		++multimenu;
		currhdr = classheader;
		cursor = ccursor;
		++class;
		tmpallvis = 0;
		start = cstart;
	    }
	    goto menu_refresh;
	    
	case ' ': /* toggle current selection */
	case 015: /* carriage return */
	case 012: /* line feed */
	    for (pptr = start, i = scrolltop; i != cursor; ++i,
		 pptr = next(pptr, currhdr))
		;
	    if (class) {
		cstart = start;
		currclass = pptr;
		currhdr = header;
		cursor = scrolltop;
		class = 0;
		start = first(currclass, header);
		goto menu_refresh;
	    }
	    if (pptr->pstat & SELECTED) {
		pptr->pstat &= ~SELECTED;
		if ((pptr->pstat & 0xf) == NEW)
		    size -= pptr->blocksize/(makenode ? 2 : 1);
		pptr->clink->pstat--;
	    } else {
		if ((pptr->pstat & 0xf) == NEW) {
		    size += pptr->blocksize/(makenode ? 2 : 1);
		    if (size > freeblks) {
			size -= pptr->blocksize/(makenode ? 2 : 1);
			statuserr("Not enough free space to load this product.");
			break;
		    }
		}
		pptr->pstat |= SELECTED;
		pptr->clink->pstat++;
	    }
	    show_line(pptr, cursor);
	    show_size(size);
	    break;
	    
	case 'l': /* Show loaded location of product */
	    if (class)
		break;
	    else {
	        locations = !locations; 
		freeblks = num_free_blks(mountpoint);
		refresh_screen(currclass, size, freeblks);
		show_screen(currhdr, start, &cursorlimit, size);
	    }
	    break;
	    
	case 'p': /* Show platforms for product */
	    if (class || !makenode)
		break;
	    for (pptr = start, i = scrolltop; i != cursor; ++i,
		 pptr = next(pptr, currhdr))
		;
	    archstr[0] = '\0';
	    for (i = 0; (i < NUM_ARCH && *cpu_types[i] != '\0'); i++) {
		if (pptr->arch & (1 << i)) {
		    if (archstr[0]) {
			strcat(archstr, ", ");
			strcat(archstr, cpu_types[i]);
		    }
		    else
			strcat(archstr, cpu_types[i]);
		}
	    }
	    sprintf(longinfo, "%s is available for: %s",
		    pptr->prodname, archstr);
	    statuserr(longinfo);
	    break;

	case 'r': /* review fixes file of current product at cursor */
	case 'h': /* help from release notes of product at cursor */
	    if (class)
		break;
	    for (pptr = start, i = scrolltop; i != cursor; ++i,
		 pptr = next(pptr, currhdr))
		;
	    next_opt = 0;
	    optionlist[next_opt++] = pptr;
	    
	    clear();
	    move(0,0);
	    refresh();
#ifndef BSD_CURSES
	    endwin();
	    putp(tgetstr("ho", NULL));
	    putp(tgetstr("cl", NULL));
	    fflush(stdout);
#else
	    resetterm();
#endif
	    curses_is_running = 0;
	    
	    switch (c) {
	    case 'r':
		c = REVIEW;
		break;
	    case 'h':
		c = HELP;
		break;
	    }
	    exit_status = act_on_products(optionlist, next_opt, c);
	    if (c == HELP) {
		PRINT "Press <Return> to return to the menu ");
		getchar();
	    }
#ifndef BSD_CURSES
	    doupdate();
#else
	    fixterm();
#endif
	    curses_is_running = 1;
	    goto menu_refresh;
	    
	case 'u': /* update selected products */
	case 'U': /* update selected products -- to base fs only */
	case 'z': /* enable questions only mode */
	case 'Z': /* enable questions only mode -- to base fs only */
	    next_opt = 0;
	    for (pptr = header->flink; pptr != header;
		 pptr = pptr->flink)
		if (pptr->pstat & SELECTED) {
		    pptr->pstat &= ~SELECTED;
		    pptr->clink->pstat--;
		    optionlist[next_opt] = pptr;
		    ++next_opt;
		}
	    clear();
	    move(0,0);
	    refresh();
#ifndef BSD_CURSES
	    endwin();
	    putp(tgetstr("ho", NULL));
	    putp(tgetstr("cl", NULL));
	    fflush(stdout);
	    fflush(stdin);
#else
	    resetterm();
#endif
	    curses_is_running = 0;
	    
	    if (c == 'u') {
	        if (makenode)
		    c = MAKENODE;
		else
		    c = INSTALL;
	    }
	    else if (c == 'U') {
		if (makenode)
		    c = MAKEBASE;
		else
		    c = INSTALLBASE;
	    }
	    else {
		if (makenode) {
		    statuserr("Option not available under \"makenode\"!");
		    break;
		}
		else {
		    if (c == 'z')
			c = PREPROCESS;
		    else
			c = PREPBASE;
	    
		}
	    }
	    exit_status = act_on_products(optionlist, next_opt, c);
	    PRINT "Press <Return> to return to the menu: ");
	    getchar();
#ifndef BSD_CURSES
	    doupdate();
#else
	    fixterm();
#endif
    	    curses_is_running = 1;
	    size = 0;
	    goto menu_refresh;
	    
	case 'e': /* exit */
	case 'q': /* quit */
	    clear();
	    move(0,0);
	    wrefresh(stdscr);
	    endwin();
#ifndef BSD_CURSES
	    putp(tgetstr("ho", NULL));
	    putp(tgetstr("cl", NULL));
	    fflush(stdout);
	    fflush(stdin);
#endif
    	    curses_is_running = 0;

	    return(exit_status);
	    
	case 'c': /* clear selected items */
	    for (pptr = header->flink; pptr != header; pptr = pptr->flink) {
		if (pptr->pstat & SELECTED) {
		    pptr->pstat &= ~SELECTED;
		    pptr->clink->pstat--;
		}
	    }
	    size = 0;
	    show_screen(currhdr, start, &cursorlimit, size);
	    break;
	    
	case 'C': /* clear selected items (only in current class) */
	    if (class)
		break;
	    
	    for (pptr = first(start, currhdr); pptr != currhdr;
		 pptr = next(pptr, currhdr)) {
		if (pptr->pstat & SELECTED) {
		    pptr->pstat &= ~SELECTED;
		    pptr->clink->pstat--;
		    if ((pptr->pstat & 0xf) == NEW)
			size -= pptr->blocksize;
		}
	    }
	    show_screen(currhdr, start, &cursorlimit, size);
	    break;
	    
	case 'a': /* select all NEEDS UPDATING items */
	    flg = 0; /* use as a temp flag */
	    /* clear class selects */
	    for (pptr = classheader->flink; pptr != classheader; pptr = pptr->flink)
		pptr->pstat = 0;
	    for (pptr = header->flink; pptr != header; pptr = pptr->flink) {
		if (((pptr->pstat & 0xf) == NEEDS_UPDATING) &&
			!(pptr->pstat & DOWNLOAD_OK)) {
		    pptr->pstat |= SELECTED;
		    pptr->clink->pstat++;
		    ++flg;
		}
	    }
	    if (flg) {
		if (class)
		    cstart = start;
		goto enter_all_products;
	    } else
		statuserr("No products need updating.");
	    break;
	    
	case 'A': /* autoselect items (only in current class) */
	    if (class)
		break;
	    
	    classheader->flink->pstat = 0;
	    flg = 0; /* use as a temp flag */
	    for (pptr = first(start, currhdr); pptr != currhdr;
		 pptr = next(pptr, currhdr)) {
		if (((pptr->pstat & 0xf) == NEEDS_UPDATING) &&
			!(pptr->pstat & DOWNLOAD_OK)) {
		    pptr->pstat |= SELECTED;
		    pptr->clink->pstat++;
		    ++flg;
		}
	    }
	    if (!flg)
		statuserr("No products need updating.");
	    show_screen(currhdr, start, &cursorlimit, size);
	    break;
	    
	case 'f': /* choose another file system */
	    clear();
	    move(0,0);
	    refresh();
#ifndef BSD_CURSES
	    endwin();
	    putp(tgetstr("ho", NULL));
	    putp(tgetstr("cl", NULL));
	    fflush(stdout);
#else
	    resetterm();
#endif
    	    curses_is_running = 0;
	    
	    fsys_choose();

#ifndef BSD_CURSES
	    doupdate();
#else
	    fixterm();
#endif
    	    curses_is_running = 1;

	    /* fall into refresh -- no break */
	    
	case 014: /* refresh */
	menu_refresh:
	    freeblks = num_free_blks(mountpoint);
	    refresh_screen(currclass, size, freeblks);
	    show_screen(currhdr, start, &cursorlimit, size);
	    break;
	    
	case 'n': /* show product numbers also */
	    numbers = !numbers; 
	    if (!class) {
		freeblks = num_free_blks(mountpoint);
		refresh_screen(currclass, size, freeblks);
		show_screen(currhdr, start, &cursorlimit, size);
	    }
	    break;

	case 'i': /* toggle invisible products */
	    justinvis = !justinvis;
	    allvis = 0;
	    show_size(size);
	    if (!class) {
		start = first(start, currhdr);
		cursor = scrolltop;
		show_screen(currhdr, start, &cursorlimit, size);
	    }
	    break;
	    
	case 'I': /* show ALL products */
	    allvis = !allvis; 
	    justinvis = 0;
	    show_size(size);
	    if (!class) {
		start = first(start, currhdr);
		cursor = scrolltop;
		show_screen(currhdr, start, &cursorlimit, size);
	    }
	    break;
	    
	case '/': /* search for a product name */
	    move(scrollbot+1, 0);
	    clrtobot();
	    mvprintw(scrollbot+1, 0, "Key in product name to search for: ");
	    refresh();
	    for (i = 0, c = getch(); i < 10 && c != '\n' && c != '\r';
		 ++i, c = getch()) {
		if ((c == '\b') || (c == 0x7f)) {
		    if (i > 0) {
			i -= 2;
			addstr("\b \b");
			continue;
		    }
		    else {
			i -= 1;
			continue;
		    }
		}
		findprod[i] = tolower(c);
		addch(c);
		refresh();
	    }
	    if (i)
		findprod[i] = '\0';
	    else
		strncpy(findprod, oldfind, 10);
	    strncpy(oldfind, findprod, 10);
	    if (!class) {
		for (pptr = start, i = scrolltop; i != cursor;
		     ++i, pptr = next(pptr, currhdr))
		    ;
		currpptr = pptr;
	    }
	    else
		currpptr = header;
	    for (pptr = currpptr->flink; pptr != currpptr; pptr = pptr->flink) {
		/* If we've hit the end, roll over */
		if (!class && pptr == header)
		    pptr = pptr->flink;
		
		if (pptr == currpptr)
		    break;
		
		for (c = 0; c < 10; ++c)
		    numcmp[c] =tolower(pptr->prodnumber[c]);
		for (c = 0; c < 10; ++c)
		    namecmp[c] = tolower(pptr->prodname[c]);

/*
		if (!strncmp(findprod,namecmp,strlen(findprod))
		    || !strncmp(findprod,numcmp,strlen(findprod))){
*/

		if (strstr(namecmp, findprod) || !strncmp(findprod,numcmp,strlen(findprod))){
		    if (class) {
			currhdr = header;
			cstart = start;
			class = 0;
		    }
		    start = pptr;
		    cursor = scrolltop;
		    currclass = pptr;
		    goto menu_refresh;
		}
	    }
	    mvprintw(scrollbot + 1, 0, statusline[class]);
	    refresh();
	    break;
	    
	case 'v': /* set verbose mode */
	case 'V':
	    verbose = !verbose;
	    show_size(size);
	    break;
	    
	case 'y': /* take defaults to intallation questions*/
	case 'Y':
	case 'D':
	case 'd':
	    if (makenode) {
		statuserr("Option not available under \"makenode\"!");
		break;
	    }
	    takedefaults = !takedefaults;		
	    show_size(size);
	    break;
	    
	case 'x': /* execute subshells with "-x"*/
	case 'X':
	    if (makenode) {
		statuserr("Option not available under \"makenode\"!");
		break;
	    }
	    minus_x = !minus_x;
	    show_size(size);
	    break;
	    
	case '!': /* shell command */
	    clear();
	    refresh();
	    endwin();
    	    curses_is_running = 0;
	    shellcmd();
	    doupdate();
    	    curses_is_running = 1;
	    goto menu_refresh;
	    
	case '?': /* help screen */
	    newprodhelp();
	    goto menu_refresh;
	    
	default: /* incorrect key */
	    statuserr("Invalid command.  Use the ? command for help.");
	    break;
	}
    }
}
