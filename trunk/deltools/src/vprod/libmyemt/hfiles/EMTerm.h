#ifndef _EMTERM
#define _EMTERM		0


/* Maximum number of rows and columns supported */
#define	VTROW		96
#define	VTCOL		132


/************************************************************************/
/*									*/
/*	Latest version of Terminal Settings Type Definition		*/
/*									*/
/************************************************************************/

typedef struct
{
	unsigned online			: 1;	/* 1 => online		*/ 
						/* 0 => local		*/

	unsigned vt200			: 1;	/* 1 => vt200		*/
						/* 0 => vt100		*/

	unsigned numericKeypad		: 1;	/* 1 => numeric		*/
						/* 0 => application	*/

	unsigned normalCursorKeys	: 1; 	/* 1 => normal		*/
						/* 0 => applications	*/

	unsigned newLine		: 1;	/* 1 => CR and LF	*/
						/* 0 => CR only		*/

	unsigned keyClick		: 1;	/* 1 => keyclick	*/
						/* 0 => no keyclick	*/

	unsigned warningBell		: 1;	/* 1 => ^G rings bell	*/
						/* 0 => no bell		*/

	unsigned answerbackConcealed	: 1;	/* 1 => concealed	*/
						/* 0 => not concealed	*/

	unsigned tabMovement		: 1;	/* 1 => spaces		*/
						/* 0 => direct 		*/

	unsigned eighty			: 1;	/* 1 => 80 columns	*/
						/* 0 => 132 columns	*/

	unsigned autoWrap		: 1;	/* 1 => auto wrap	*/
						/* 0 => no auto wrap	*/

	unsigned noScroll		: 1;	/* 1 => no scroll	*/
						/* 0 => scroll 		*/

	unsigned screenReverse		: 1;	/* 1 => reverse video	*/
						/* 0 => normal 		*/

	unsigned cursorVisible		: 1;	/* 1 => visible cursor	*/ 
						/* 0 => invisible	*/

	unsigned cursorBlock		: 1;	/* 1 => block cursor	*/
						/* 0 => underline	*/
 
	unsigned formFeed		: 1;	/* 1 => clear and home	*/
						/* 0 => line feed	*/

	unsigned chngWdErase		: 1;	/* After column change: */
						/* 0 => preserve screen */
						/* 1 => erase screen	*/

	unsigned cursorOrigin		: 1;	/* 1 => within defined	*/
						/*	scroll region	*/
						/* 0 => at upper left	*/

	unsigned eraseExtent		: 1;	/* 1 => scroll region	*/
						/* 0 => entire screen	*/

	unsigned localEcho		: 1;	/* 1 => half duplex	*/
						/* 0 => full duplex	*/

	unsigned displayControls	: 1;	/* 1 => display control */
						/*	characters	*/
						/* 0 => interpret	*/
						/*	control chars.	*/

	unsigned autoRepeat		: 1;	/* 1 => auto repeat on	*/
						/* 0 => auto repeat off	*/
						
	unsigned logFlag		: 1;	/* 1 => log session to	*/
						/*	file		*/
						/* 0 => don't log	*/

	unsigned cursorBlinking		: 1;	/* 1 => blinking cursor	*/
						/* 0 => static cursor	*/
						
	unsigned bit8			: 1;	/* 1 => 8 bit data	*/
						/* 0 => 7 bit data	*/

	unsigned printerMode		: 2;	/* printer mode (below)	*/

	unsigned printTerminator	: 1;	/* 1 => Form feed	*/
						/* 0 => None		*/
						
	unsigned udkLock		: 2;	/* 0 = unlocked,	*/
						/* 1 = lock after UDKs	*/
						/*     are defined	*/
						/* 2 = UDKs are locked	*/

	char pad[5];				/* pad for extending	*/
						/* bit flags (above)	*/

	char answerback[30];			/* answerback message	*/

	unsigned char tabMap[VTCOL];		/* 1 => tab set		*/
						/* 0 => tab not set	*/
						
	int bufScreens;				/* number of scrolling	*/
						/* buffered screens	*/
						
	char logFile[32];			/* log file name	*/

} EMTermSettings;


/* Printer modes (for EMTermSettings.printerMode) */
#define	NO_PRINTER			0
#define	NORMAL_MODE			1
#define	AUTO_MODE			2
#define	PRINTER_CONTROLLER_MODE		3


#endif
