/* $Revision: 1.1 $ */
/* Predefined Values */
#ifdef DEFAULT_COLORS
#define TRANSPARENT    -1
#define BLACK		0
#define DARK_BLUE	1
#define DARK_GREEN	2
#define DARK_CYAN	3
#define DARK_RED	4
#define DARK_MAGENTA	5
#define BROWN		6
#define LIGHT_GRAY	7
#define DARK_GRAY	8
#define LIGHT_BLUE	9
#define LIGHT_GREEN	10
#define LIGHT_CYAN	11
#define LIGHT_RED	12
#define LIGHT_MAGENTA	13
#define YELLOW		14
#define WHITE		15
#endif

#define OUTLINED	0	/* Used for rects. and polys */
#define FILLED		1
#define SHOW		0	/* Used for raster cursor */
#define HIDE		1
#define RIGHT		0	/* Used for rlenfl orientation */
#define LEFT		1
#define UP		2
#define DOWN		3
#define SAVE		1
#define RESTORE		0

/* Error Codes For TKFILE */

#define ErrNone		0
#define ErrOnOpen	1
#define ErrOnClose	2
#define ErrInvalidFile	3
#define ErrFileTooBig	4
#define ErrReadingData	5
#define ErrWritingData	6
#define ErrInvalidOp	7
#define ErrInvalidData	8

/* Specify return type, depending on compiler used */
#ifdef __TURBOC__
#define RETURN_TYPE pascal
#else
#define RETURN_TYPE fortran		/* Microsoft is default */
#endif

/* Function Declarations */
void init(short );
void finit(void);
void derase(void);
void colmap(short ,short ,short ,short );
void inqmap(short ,short *,short *,short *);
void drwlog(short );
void dcolor(short );
void moveab(short ,short );
void drawab(short ,short );
void polyab(short ,short *,short );
void rectab(short ,short ,short ,short ,short );
void flood(short ,short );
void rlenfl(short ,short ,short );
void lnstyl( short );
void flstyl( char * );
void patbcl( short );
void text(char *);
void dfnfnt(short *,short ,short );
void rdpblk(short ,short ,char * );
void wrpblk(short ,short ,char * );
void rdbblk(short ,short ,char * );
void wrbblk(short ,short ,char * );
void cpyblk(short ,short ,short ,short ,short ,short );
void rdmask(short );
void wrmask(short );
void rwpage(short ,short );
void vpage(short );
void pan(short ,short );
void vwait(short );
void inqmem(short *);
void split(short );
void swidth(short );
void fonadd(short ,short ,short *);
void savreg(short ,short ,short ,short );
void litpen(short *,short *);
void setcur(short ,short ,short );
void defcur(short ,short ,short *,short ,short );
void oclip(short ,short ,short ,short );
void gensph(short, char *);
void drwsph(short ,short ,short ,short *, char *);
void rdpixl( short, short, short * );
void wrpixl( short, short, short );
void inqpos( short *, short * );
void pbfile( char *, short *, short * );
void ldfont(char *,char *);

/*--- Toolkit Declaration ---*/
void  RETURN_TYPE far EGAC16( short far *, short far * );
void  RETURN_TYPE far GETADD( char  far *, short far * );
void  RETURN_TYPE far INKEY ( short far *, short far * );
short RETURN_TYPE far TKFILE( char  far *, short far * );
void  RETURN_TYPE far XFRVDT( short far * );
void  RETURN_TYPE far TKMOUS( short far *, short far *,
			      short far *, short far * );
void  RETURN_TYPE far ST2BIN( char far *, short far *,
			      char far *, short far * );
/*================ Printer Driver Declarations =================*/
/*--- IBM Graphics Printer
*/
void RETURN_TYPE far IBMGPI( short far *, short far *, short far * );
int  RETURN_TYPE far IBMGPP( void );
/*--- Epson FX Series
*/
void RETURN_TYPE far EPSFXI( short far *, short far *, short far * );
int  RETURN_TYPE far EPSFXP( void );
/*--- IBM Color Printer
*/
void RETURN_TYPE far IBMCPI( short far *, short far *, short far * );
int  RETURN_TYPE far IBMCPP( void );
/*--- IBM Color Inkjet
*/
void RETURN_TYPE far IBMIJI( short far *, short far *, short far * );
int  RETURN_TYPE far IBMIJP( void );
/*--- HP Laserjet Printer
*/
void RETURN_TYPE far HPINIT( short far *, short far *, short far * );
int  RETURN_TYPE far HPRINT( void );

