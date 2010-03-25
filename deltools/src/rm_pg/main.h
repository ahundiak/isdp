#define MAXLINE 256
#define MAXPAGE 512
#define MAXSPAGE 128

#define MAXSECTIONS	200
#define MAXSECTION_LEN	80

/*in the absence of ACS_ definitions,they are defined for HP- MVR 30 Apr 1994*/
#ifdef HP_UX
#  define ACS_DARROW 'v'
#  define ACS_UARROW '^'
#  define ACS_HLINE (A_ALTCHARSET | 'q')
#endif
#ifdef MY_OWN_BOX
#  define ACS_DARROW 'v'
#  define ACS_UARROW '^'
#  define ACS_HLINE (A_ALTCHARSET | 'q')
#  define ACS_VLINE (A_ALTCHARSET | 'x')
#  define ACS_ULCORNER	(A_ALTCHARSET | 'l')
#  define ACS_LLCORNER	(A_ALTCHARSET | 'm')
#  define ACS_URCORNER	(A_ALTCHARSET | 'k')
#  define ACS_LRCORNER	(A_ALTCHARSET | 'j')
#  ifdef MACRO
#    define my_box(win, v, h) { \
	int curx, cury; \
	getyx((win), cury, curx); \
	/*box((win), (v), (h));*/ \
	wattron((win), A_ALTCHARSET); \
	mvwaddch((win), (win)->_begy, (win)->_begx, 'l'); \
	mvwaddch((win), (win)->_maxy, (win)->_begx, 'm'); \
	mvwaddch((win), (win)->_begy, (win)->_maxx, 'k'); \
	mvwaddch((win), (win)->_maxy, (win)->_maxx, 'j'); \
	wattroff((win), A_ALTCHARSET); \
	move(cury, curx); \
}
#  endif
#endif
