#include <stdio.h>

/* #include "XFIproto_pri.h" */
#include "XFIproto_pub.h"

/****************************************************************/
/* These are functions that need to be "imported" into the	*/
/* X/Forms shared library.  They are external functions that	*/
/* the XFI shared library uses that are not in another shared	*/
/* library that the X/Forms ".sl" file has in its		*/
/*  "#objects noload" section ( libX11_s, libXFS_s ).	 	*/
/*								*/
/****************************************************************/
/* In other words, the X/Forms shared library doesn't have to	*/
/* import any symbols found in another shared library in the	*/
/* "xfi.sl"'s "#objects noload" # section.			*/
/****************************************************************/
/* However, the "-lc_s" is not in the #objects noload section	*/
/* because there are "non-relocatable addresses found before	*/
/* relocatable address" things in the libc_s library which	*/
/* just mess it up.						*/
/****************************************************************/
/*	- WE DO NOT NEED TO "IMPORT" X-windows functions	*/
/*	  that are in libX11_s					*/
/*								*/
/*	- WE DO NOT NEED TO "IMPORT" X-FontServer functions	*/
/*	  that are in libXFS_s					*/
/*								*/
/* 	- WE MUST "IMPORT" ALL OTHER FUNCTIONS.			*/
/****************************************************************/
/*								*/
/* Apparently, the shared library must also import all external	*/
/* global data symbols, regardless of their source.		*/
/*								*/
/****************************************************************/
/* Note that there are extra dummy pointers at the end, in	*/
/* case any new functions need to be imported after the initial	*/
/* creation of the shared library.				*/
/****************************************************************/


	/******************************************/
	/*** external global data symbols	***/
	/******************************************/

int		(* libxfi_errno)	= 0;
unsigned char	(* libxfi__ctype)[]	= 0;
FILE		(* libxfi__iob)[]	= 0;

	/******************************************/
	/*** functions imported from libc.a:	***/
	/******************************************/

int	(* libxfi_access)()	  	= 0;
int	(* libxfi_atoi)()	  	= 0;
double	(* libxfi_atof)()	  	= 0;
int	(* libxfi_close)()		= 0;
int	(* libxfi_fclose)()		= 0;
FILE *	(* libxfi_fopen)()		= 0;
int	(* libxfi_fprintf)()		= (int (*) ())0;
int	(* libxfi_fread)()		= (int (*) ())0;
int	(* libxfi_fscanf)()		= (int (*) ())0;
int	(* libxfi_fseek)()		= 0;
int	(* libxfi_fwrite)()		= (int (*) ())0;
char *	(* libxfi_getlogin)()		= 0;
void	(* libxfi_longjmp)()		= 0;
char *	(* libxfi_memcpy)()		= (char * (*) ())0;
char *	(* libxfi_memset)()		= (char * (*) ())0;
int	(* libxfi_open)()		= 0;
int	(* libxfi_printf)()		= 0;
int	(* libxfi_read)()		= 0;
int	(* libxfi_setjmp)()		= 0;
int	(* libxfi_sprintf)()		= 0;
int	(* libxfi_sscanf)()		= 0;
char *	(* libxfi_strcat)()		= 0;
char *	(* libxfi_strchr)()		= 0;
int	(* libxfi_strcmp)()		= 0;
char *	(* libxfi_strcpy)()		= 0;
int	(* libxfi_strlen)()		= 0;
int	(* libxfi_strncmp)()		= 0;
char *	(* libxfi_strncpy)()		= 0;
char *	(* libxfi_strrchr)()		= 0;
long	(* libxfi_time)()		= 0;
int	(* libxfi_tolower)()		= 0;
int	(* libxfi_toupper)()		= 0;
int	(* libxfi_uname)()		= 0;

	/******************************************/
	/*** functions imported from libm.a:	***/
	/******************************************/

double	(* libxfi_atan2)()		= 0;
double	(* libxfi_cos)()		= 0;
double	(* libxfi_pow)()		= 0;
double	(* libxfi_sin)()		= 0;
double	(* libxfi_sqrt)()		= 0;

	/**************************************************/
	/*** functions imported from lib[xc|d]malloc.a:	***/
	/**************************************************/

char *	(* libxfi_calloc)()		= 0;
void	(* libxfi_free)()		= 0;
char *	(* libxfi_malloc)()		= 0;
char *	(* libxfi_realloc)()		= 0;

	/******************************************/
	/*** functions imported from libbsd.a:	***/
	/******************************************/

int	(* libxfi_select)()		= 0;



/*******************************************************************/
/*** Use these dummy pointers for future import variables.	 ***/
/*** REPLACE A DUMMY POINTER WITH A NEW IMPORTED VARIABLE	 ***/
/*** SO THAT THE TOTAL SIZE and ORDER OF THEM REMAINS CONSTANT	 ***/
/*** (else the shared library will be incompatible with previous ***/
/*** ones ).							 ***/
/*******************************************************************/

char *	(* libxfi_getenv)()		= 0;   /* GMD 2/4/92 */

#if (defined(sun) || defined(i386) || defined(sparc)) && defined(SYSV)
char *	(* libxfi_cuserid)()	= 0;	/* sml:01-24-94 */
#else
char   (* libxfi_dummy1)()         = 0;
#endif

char	(* libxfi_dummy2)()		= 0;
char	(* libxfi_dummy3)()		= 0;
char	(* libxfi_dummy4)()		= 0;
char	(* libxfi_dummy5)()		= 0;
char	(* libxfi_dummy6)()		= 0;
char	(* libxfi_dummy7)()		= 0;
char	(* libxfi_dummy8)()		= 0;
char	(* libxfi_dummy9)()		= 0;
char	(* libxfi_dummy10)()		= 0;
char	(* libxfi_dummy11)()		= 0;
char	(* libxfi_dummy12)()		= 0;
char	(* libxfi_dummy13)()		= 0;
char	(* libxfi_dummy14)()		= 0;
char	(* libxfi_dummy15)()		= 0;
char	(* libxfi_dummy16)()		= 0;
char	(* libxfi_dummy17)()		= 0;
char	(* libxfi_dummy18)()		= 0;
char	(* libxfi_dummy19)()		= 0;
char	(* libxfi_dummy20)()		= 0;
char	(* libxfi_dummy21)()		= 0;
char	(* libxfi_dummy22)()		= 0;
char	(* libxfi_dummy23)()		= 0;
char	(* libxfi_dummy24)()		= 0;
char	(* libxfi_dummy25)()		= 0;
char	(* libxfi_dummy26)()		= 0;
char	(* libxfi_dummy27)()		= 0;
char	(* libxfi_dummy28)()		= 0;
char	(* libxfi_dummy29)()		= 0;
char	(* libxfi_dummy30)()		= 0;
char	(* libxfi_dummy31)()		= 0;
char	(* libxfi_dummy32)()		= 0;
char	(* libxfi_dummy33)()		= 0;
char	(* libxfi_dummy34)()		= 0;
char	(* libxfi_dummy35)()		= 0;
char	(* libxfi_dummy36)()		= 0;
char	(* libxfi_dummy37)()		= 0;
char	(* libxfi_dummy38)()		= 0;
char	(* libxfi_dummy39)()		= 0;
char	(* libxfi_dummy40)()		= 0;
char	(* libxfi_dummy41)()		= 0;
char	(* libxfi_dummy42)()		= 0;
char	(* libxfi_dummy43)()		= 0;
char	(* libxfi_dummy44)()		= 0;
char	(* libxfi_dummy45)()		= 0;
char	(* libxfi_dummy46)()		= 0;
char	(* libxfi_dummy47)()		= 0;
char	(* libxfi_dummy48)()		= 0;
char	(* libxfi_dummy49)()		= 0;
char	(* libxfi_dummy50)()		= 0;
char	(* libxfi_dummy51)()		= 0;
char	(* libxfi_dummy52)()		= 0;
char	(* libxfi_dummy53)()		= 0;
char	(* libxfi_dummy54)()		= 0;
char	(* libxfi_dummy55)()		= 0;
char	(* libxfi_dummy56)()		= 0;
char	(* libxfi_dummy57)()		= 0;
char	(* libxfi_dummy58)()		= 0;
char	(* libxfi_dummy59)()		= 0;
char	(* libxfi_dummy60)()		= 0;
char	(* libxfi_dummy61)()		= 0;
char	(* libxfi_dummy62)()		= 0;
char	(* libxfi_dummy63)()		= 0;
char	(* libxfi_dummy64)()		= 0;
char	(* libxfi_dummy65)()		= 0;
char	(* libxfi_dummy66)()		= 0;
char	(* libxfi_dummy67)()		= 0;
char	(* libxfi_dummy68)()		= 0;
char	(* libxfi_dummy69)()		= 0;
char	(* libxfi_dummy70)()		= 0;
char	(* libxfi_dummy71)()		= 0;
char	(* libxfi_dummy72)()		= 0;
char	(* libxfi_dummy73)()		= 0;
char	(* libxfi_dummy74)()		= 0;
char	(* libxfi_dummy75)()		= 0;
char	(* libxfi_dummy76)()		= 0;
char	(* libxfi_dummy77)()		= 0;
char	(* libxfi_dummy78)()		= 0;
char	(* libxfi_dummy79)()		= 0;
char	(* libxfi_dummy80)()		= 0;
char	(* libxfi_dummy81)()		= 0;
char	(* libxfi_dummy82)()		= 0;
char	(* libxfi_dummy83)()		= 0;
char	(* libxfi_dummy84)()		= 0;
char	(* libxfi_dummy85)()		= 0;
char	(* libxfi_dummy86)()		= 0;
char	(* libxfi_dummy87)()		= 0;
char	(* libxfi_dummy88)()		= 0;
char	(* libxfi_dummy89)()		= 0;
char	(* libxfi_dummy90)()		= 0;
char	(* libxfi_dummy91)()		= 0;
char	(* libxfi_dummy92)()		= 0;
char	(* libxfi_dummy93)()		= 0;
char	(* libxfi_dummy94)()		= 0;
char	(* libxfi_dummy95)()		= 0;
char	(* libxfi_dummy96)()		= 0;
char	(* libxfi_dummy97)()		= 0;
char	(* libxfi_dummy98)()		= 0;
char	(* libxfi_dummy99)()		= 0;
char	(* libxfi_dummy100)()		= 0;
char	(* libxfi_dummy101)()		= 0;
char	(* libxfi_dummy102)()		= 0;
char	(* libxfi_dummy103)()		= 0;
char	(* libxfi_dummy104)()		= 0;
char	(* libxfi_dummy105)()		= 0;
char	(* libxfi_dummy106)()		= 0;
char	(* libxfi_dummy107)()		= 0;
char	(* libxfi_dummy108)()		= 0;
char	(* libxfi_dummy109)()		= 0;
char	(* libxfi_dummy110)()		= 0;
char	(* libxfi_dummy111)()		= 0;
char	(* libxfi_dummy112)()		= 0;
char	(* libxfi_dummy113)()		= 0;
char	(* libxfi_dummy114)()		= 0;
char	(* libxfi_dummy115)()		= 0;
char	(* libxfi_dummy116)()		= 0;
char	(* libxfi_dummy117)()		= 0;
char	(* libxfi_dummy118)()		= 0;
char	(* libxfi_dummy119)()		= 0;
char	(* libxfi_dummy120)()		= 0;
char	(* libxfi_dummy121)()		= 0;
char	(* libxfi_dummy122)()		= 0;
char	(* libxfi_dummy123)()		= 0;
char	(* libxfi_dummy124)()		= 0;
char	(* libxfi_dummy125)()		= 0;
char	(* libxfi_dummy126)()		= 0;
char	(* libxfi_dummy127)()		= 0;
char	(* libxfi_dummy128)()		= 0;
char	(* libxfi_dummy129)()		= 0;
char	(* libxfi_dummy130)()		= 0;
char	(* libxfi_dummy131)()		= 0;
char	(* libxfi_dummy132)()		= 0;
char	(* libxfi_dummy133)()		= 0;
char	(* libxfi_dummy134)()		= 0;
char	(* libxfi_dummy135)()		= 0;
char	(* libxfi_dummy136)()		= 0;
char	(* libxfi_dummy137)()		= 0;
char	(* libxfi_dummy138)()		= 0;
char	(* libxfi_dummy139)()		= 0;
char	(* libxfi_dummy140)()		= 0;
char	(* libxfi_dummy141)()		= 0;
char	(* libxfi_dummy142)()		= 0;
char	(* libxfi_dummy143)()		= 0;
char	(* libxfi_dummy144)()		= 0;
char	(* libxfi_dummy145)()		= 0;
char	(* libxfi_dummy146)()		= 0;
char	(* libxfi_dummy147)()		= 0;
char	(* libxfi_dummy148)()		= 0;
char	(* libxfi_dummy149)()		= 0;
char	(* libxfi_dummy150)()		= 0;
char	(* libxfi_dummy151)()		= 0;
char	(* libxfi_dummy152)()		= 0;
char	(* libxfi_dummy153)()		= 0;
char	(* libxfi_dummy154)()		= 0;
char	(* libxfi_dummy155)()		= 0;
char	(* libxfi_dummy156)()		= 0;
char	(* libxfi_dummy157)()		= 0;
char	(* libxfi_dummy158)()		= 0;
char	(* libxfi_dummy159)()		= 0;
char	(* libxfi_dummy160)()		= 0;
char	(* libxfi_dummy161)()		= 0;
char	(* libxfi_dummy162)()		= 0;
char	(* libxfi_dummy163)()		= 0;
char	(* libxfi_dummy164)()		= 0;
char	(* libxfi_dummy165)()		= 0;
char	(* libxfi_dummy166)()		= 0;
char	(* libxfi_dummy167)()		= 0;
char	(* libxfi_dummy168)()		= 0;
char	(* libxfi_dummy169)()		= 0;
char	(* libxfi_dummy170)()		= 0;
char	(* libxfi_dummy171)()		= 0;
char	(* libxfi_dummy172)()		= 0;
char	(* libxfi_dummy173)()		= 0;
char	(* libxfi_dummy174)()		= 0;
char	(* libxfi_dummy175)()		= 0;
char	(* libxfi_dummy176)()		= 0;
char	(* libxfi_dummy177)()		= 0;
char	(* libxfi_dummy178)()		= 0;
char	(* libxfi_dummy179)()		= 0;
char	(* libxfi_dummy180)()		= 0;
char	(* libxfi_dummy181)()		= 0;
char	(* libxfi_dummy182)()		= 0;
char	(* libxfi_dummy183)()		= 0;
char	(* libxfi_dummy184)()		= 0;
char	(* libxfi_dummy185)()		= 0;
char	(* libxfi_dummy186)()		= 0;
char	(* libxfi_dummy187)()		= 0;
char	(* libxfi_dummy188)()		= 0;
char	(* libxfi_dummy189)()		= 0;
char	(* libxfi_dummy190)()		= 0;
char	(* libxfi_dummy191)()		= 0;
char	(* libxfi_dummy192)()		= 0;
char	(* libxfi_dummy193)()		= 0;
char	(* libxfi_dummy194)()		= 0;
char	(* libxfi_dummy195)()		= 0;
char	(* libxfi_dummy196)()		= 0;
char	(* libxfi_dummy197)()		= 0;
char	(* libxfi_dummy198)()		= 0;
char	(* libxfi_dummy199)()		= 0;
char	(* libxfi_dummy200)()		= 0;
char	(* libxfi_dummy201)()		= 0;
char	(* libxfi_dummy202)()		= 0;
char	(* libxfi_dummy203)()		= 0;
char	(* libxfi_dummy204)()		= 0;
char	(* libxfi_dummy205)()		= 0;
char	(* libxfi_dummy206)()		= 0;
char	(* libxfi_dummy207)()		= 0;
char	(* libxfi_dummy208)()		= 0;
char	(* libxfi_dummy209)()		= 0;
char	(* libxfi_dummy210)()		= 0;
char	(* libxfi_dummy211)()		= 0;
char	(* libxfi_dummy212)()		= 0;
char	(* libxfi_dummy213)()		= 0;
char	(* libxfi_dummy214)()		= 0;
char	(* libxfi_dummy215)()		= 0;
char	(* libxfi_dummy216)()		= 0;
char	(* libxfi_dummy217)()		= 0;
char	(* libxfi_dummy218)()		= 0;
char	(* libxfi_dummy219)()		= 0;
char	(* libxfi_dummy220)()		= 0;
char	(* libxfi_dummy221)()		= 0;
char	(* libxfi_dummy222)()		= 0;
char	(* libxfi_dummy223)()		= 0;
char	(* libxfi_dummy224)()		= 0;
char	(* libxfi_dummy225)()		= 0;
char	(* libxfi_dummy226)()		= 0;
char	(* libxfi_dummy227)()		= 0;
char	(* libxfi_dummy228)()		= 0;
char	(* libxfi_dummy229)()		= 0;
char	(* libxfi_dummy230)()		= 0;
char	(* libxfi_dummy231)()		= 0;
char	(* libxfi_dummy232)()		= 0;
char	(* libxfi_dummy233)()		= 0;
char	(* libxfi_dummy234)()		= 0;
char	(* libxfi_dummy235)()		= 0;
char	(* libxfi_dummy236)()		= 0;
char	(* libxfi_dummy237)()		= 0;
char	(* libxfi_dummy238)()		= 0;
char	(* libxfi_dummy239)()		= 0;
char	(* libxfi_dummy240)()		= 0;
char	(* libxfi_dummy241)()		= 0;
char	(* libxfi_dummy242)()		= 0;
char	(* libxfi_dummy243)()		= 0;
char	(* libxfi_dummy244)()		= 0;
char	(* libxfi_dummy245)()		= 0;
char	(* libxfi_dummy246)()		= 0;
char	(* libxfi_dummy247)()		= 0;
char	(* libxfi_dummy248)()		= 0;
char	(* libxfi_dummy249)()		= 0;
char	(* libxfi_dummy250)()		= 0;
char	(* libxfi_dummy251)()		= 0;
char	(* libxfi_dummy252)()		= 0;
char	(* libxfi_dummy253)()		= 0;
char	(* libxfi_dummy254)()		= 0;
char	(* libxfi_dummy255)()		= 0;
char	(* libxfi_dummy256)()		= 0;
char	(* libxfi_dummy257)()		= 0;
char	(* libxfi_dummy258)()		= 0;
char	(* libxfi_dummy259)()		= 0;
char	(* libxfi_dummy260)()		= 0;
char	(* libxfi_dummy261)()		= 0;
char	(* libxfi_dummy262)()		= 0;
char	(* libxfi_dummy263)()		= 0;
char	(* libxfi_dummy264)()		= 0;
char	(* libxfi_dummy265)()		= 0;
char	(* libxfi_dummy266)()		= 0;
char	(* libxfi_dummy267)()		= 0;
char	(* libxfi_dummy268)()		= 0;
char	(* libxfi_dummy269)()		= 0;
char	(* libxfi_dummy270)()		= 0;
char	(* libxfi_dummy271)()		= 0;
char	(* libxfi_dummy272)()		= 0;
char	(* libxfi_dummy273)()		= 0;
char	(* libxfi_dummy274)()		= 0;
char	(* libxfi_dummy275)()		= 0;
char	(* libxfi_dummy276)()		= 0;
char	(* libxfi_dummy277)()		= 0;
char	(* libxfi_dummy278)()		= 0;
char	(* libxfi_dummy279)()		= 0;
char	(* libxfi_dummy280)()		= 0;
char	(* libxfi_dummy281)()		= 0;
char	(* libxfi_dummy282)()		= 0;
char	(* libxfi_dummy283)()		= 0;
char	(* libxfi_dummy284)()		= 0;
char	(* libxfi_dummy285)()		= 0;
char	(* libxfi_dummy286)()		= 0;
char	(* libxfi_dummy287)()		= 0;
char	(* libxfi_dummy288)()		= 0;
char	(* libxfi_dummy289)()		= 0;
char	(* libxfi_dummy290)()		= 0;
char	(* libxfi_dummy291)()		= 0;
char	(* libxfi_dummy292)()		= 0;
char	(* libxfi_dummy293)()		= 0;
char	(* libxfi_dummy294)()		= 0;
char	(* libxfi_dummy295)()		= 0;
char	(* libxfi_dummy296)()		= 0;
char	(* libxfi_dummy297)()		= 0;
char	(* libxfi_dummy298)()		= 0;
char	(* libxfi_dummy299)()		= 0;
char	(* libxfi_dummy300)()		= 0;
char	(* libxfi_dummy301)()		= 0;
char	(* libxfi_dummy302)()		= 0;
char	(* libxfi_dummy303)()		= 0;
char	(* libxfi_dummy304)()		= 0;
char	(* libxfi_dummy305)()		= 0;
char	(* libxfi_dummy306)()		= 0;
char	(* libxfi_dummy307)()		= 0;
char	(* libxfi_dummy308)()		= 0;
char	(* libxfi_dummy309)()		= 0;
char	(* libxfi_dummy310)()		= 0;
char	(* libxfi_dummy311)()		= 0;
char	(* libxfi_dummy312)()		= 0;
char	(* libxfi_dummy313)()		= 0;
char	(* libxfi_dummy314)()		= 0;
char	(* libxfi_dummy315)()		= 0;
char	(* libxfi_dummy316)()		= 0;
char	(* libxfi_dummy317)()		= 0;
char	(* libxfi_dummy318)()		= 0;
char	(* libxfi_dummy319)()		= 0;
char	(* libxfi_dummy320)()		= 0;
char	(* libxfi_dummy321)()		= 0;
char	(* libxfi_dummy322)()		= 0;
char	(* libxfi_dummy323)()		= 0;
char	(* libxfi_dummy324)()		= 0;
char	(* libxfi_dummy325)()		= 0;
char	(* libxfi_dummy326)()		= 0;
char	(* libxfi_dummy327)()		= 0;
char	(* libxfi_dummy328)()		= 0;
char	(* libxfi_dummy329)()		= 0;
char	(* libxfi_dummy330)()		= 0;
char	(* libxfi_dummy331)()		= 0;
char	(* libxfi_dummy332)()		= 0;
char	(* libxfi_dummy333)()		= 0;
char	(* libxfi_dummy334)()		= 0;
char	(* libxfi_dummy335)()		= 0;
char	(* libxfi_dummy336)()		= 0;
char	(* libxfi_dummy337)()		= 0;
char	(* libxfi_dummy338)()		= 0;
char	(* libxfi_dummy339)()		= 0;
char	(* libxfi_dummy340)()		= 0;
char	(* libxfi_dummy341)()		= 0;
char	(* libxfi_dummy342)()		= 0;
char	(* libxfi_dummy343)()		= 0;
char	(* libxfi_dummy344)()		= 0;
char	(* libxfi_dummy345)()		= 0;
char	(* libxfi_dummy346)()		= 0;
char	(* libxfi_dummy347)()		= 0;
char	(* libxfi_dummy348)()		= 0;
char	(* libxfi_dummy349)()		= 0;
char	(* libxfi_dummy350)()		= 0;
char	(* libxfi_dummy351)()		= 0;
char	(* libxfi_dummy352)()		= 0;
char	(* libxfi_dummy353)()		= 0;
char	(* libxfi_dummy354)()		= 0;
char	(* libxfi_dummy355)()		= 0;
char	(* libxfi_dummy356)()		= 0;
char	(* libxfi_dummy357)()		= 0;
char	(* libxfi_dummy358)()		= 0;
char	(* libxfi_dummy359)()		= 0;
char	(* libxfi_dummy360)()		= 0;
char	(* libxfi_dummy361)()		= 0;
char	(* libxfi_dummy362)()		= 0;
char	(* libxfi_dummy363)()		= 0;
char	(* libxfi_dummy364)()		= 0;
char	(* libxfi_dummy365)()		= 0;
char	(* libxfi_dummy366)()		= 0;
char	(* libxfi_dummy367)()		= 0;
char	(* libxfi_dummy368)()		= 0;
char	(* libxfi_dummy369)()		= 0;
char	(* libxfi_dummy370)()		= 0;
char	(* libxfi_dummy371)()		= 0;
char	(* libxfi_dummy372)()		= 0;
char	(* libxfi_dummy373)()		= 0;
char	(* libxfi_dummy374)()		= 0;
char	(* libxfi_dummy375)()		= 0;
char	(* libxfi_dummy376)()		= 0;
char	(* libxfi_dummy377)()		= 0;
char	(* libxfi_dummy378)()		= 0;
char	(* libxfi_dummy379)()		= 0;
char	(* libxfi_dummy380)()		= 0;
char	(* libxfi_dummy381)()		= 0;
char	(* libxfi_dummy382)()		= 0;
char	(* libxfi_dummy383)()		= 0;
char	(* libxfi_dummy384)()		= 0;
char	(* libxfi_dummy385)()		= 0;
char	(* libxfi_dummy386)()		= 0;
char	(* libxfi_dummy387)()		= 0;
char	(* libxfi_dummy388)()		= 0;
char	(* libxfi_dummy389)()		= 0;
char	(* libxfi_dummy390)()		= 0;
char	(* libxfi_dummy391)()		= 0;
char	(* libxfi_dummy392)()		= 0;
char	(* libxfi_dummy393)()		= 0;
char	(* libxfi_dummy394)()		= 0;
char	(* libxfi_dummy395)()		= 0;
char	(* libxfi_dummy396)()		= 0;
char	(* libxfi_dummy397)()		= 0;
char	(* libxfi_dummy398)()		= 0;
char	(* libxfi_dummy399)()		= 0;
char	(* libxfi_dummy400)()		= 0;
char	(* libxfi_dummy401)()		= 0;
char	(* libxfi_dummy402)()		= 0;
char	(* libxfi_dummy403)()		= 0;
char	(* libxfi_dummy404)()		= 0;
char	(* libxfi_dummy405)()		= 0;
char	(* libxfi_dummy406)()		= 0;
char	(* libxfi_dummy407)()		= 0;
char	(* libxfi_dummy408)()		= 0;
char	(* libxfi_dummy409)()		= 0;
char	(* libxfi_dummy410)()		= 0;
char	(* libxfi_dummy411)()		= 0;
char	(* libxfi_dummy412)()		= 0;
char	(* libxfi_dummy413)()		= 0;
char	(* libxfi_dummy414)()		= 0;
char	(* libxfi_dummy415)()		= 0;
char	(* libxfi_dummy416)()		= 0;
char	(* libxfi_dummy417)()		= 0;
char	(* libxfi_dummy418)()		= 0;
char	(* libxfi_dummy419)()		= 0;
char	(* libxfi_dummy420)()		= 0;
char	(* libxfi_dummy421)()		= 0;
char	(* libxfi_dummy422)()		= 0;
char	(* libxfi_dummy423)()		= 0;
char	(* libxfi_dummy424)()		= 0;
char	(* libxfi_dummy425)()		= 0;
char	(* libxfi_dummy426)()		= 0;
char	(* libxfi_dummy427)()		= 0;
char	(* libxfi_dummy428)()		= 0;
char	(* libxfi_dummy429)()		= 0;
char	(* libxfi_dummy430)()		= 0;
char	(* libxfi_dummy431)()		= 0;
char	(* libxfi_dummy432)()		= 0;
char	(* libxfi_dummy433)()		= 0;
char	(* libxfi_dummy434)()		= 0;
char	(* libxfi_dummy435)()		= 0;
char	(* libxfi_dummy436)()		= 0;
char	(* libxfi_dummy437)()		= 0;
char	(* libxfi_dummy438)()		= 0;
char	(* libxfi_dummy439)()		= 0;
char	(* libxfi_dummy440)()		= 0;
char	(* libxfi_dummy441)()		= 0;
char	(* libxfi_dummy442)()		= 0;
char	(* libxfi_dummy443)()		= 0;
char	(* libxfi_dummy444)()		= 0;
char	(* libxfi_dummy445)()		= 0;
char	(* libxfi_dummy446)()		= 0;
char	(* libxfi_dummy447)()		= 0;
char	(* libxfi_dummy448)()		= 0;
char	(* libxfi_dummy449)()		= 0;
char	(* libxfi_dummy450)()		= 0;
char	(* libxfi_dummy451)()		= 0;
char	(* libxfi_dummy452)()		= 0;
char	(* libxfi_dummy453)()		= 0;
char	(* libxfi_dummy454)()		= 0;
char	(* libxfi_dummy455)()		= 0;
char	(* libxfi_dummy456)()		= 0;
char	(* libxfi_dummy457)()		= 0;
char	(* libxfi_dummy458)()		= 0;
char	(* libxfi_dummy459)()		= 0;
char	(* libxfi_dummy460)()		= 0;
char	(* libxfi_dummy461)()		= 0;
char	(* libxfi_dummy462)()		= 0;
char	(* libxfi_dummy463)()		= 0;
char	(* libxfi_dummy464)()		= 0;
char	(* libxfi_dummy465)()		= 0;
char	(* libxfi_dummy466)()		= 0;
char	(* libxfi_dummy467)()		= 0;
char	(* libxfi_dummy468)()		= 0;
char	(* libxfi_dummy469)()		= 0;
char	(* libxfi_dummy470)()		= 0;
char	(* libxfi_dummy471)()		= 0;
char	(* libxfi_dummy472)()		= 0;
char	(* libxfi_dummy473)()		= 0;
char	(* libxfi_dummy474)()		= 0;
char	(* libxfi_dummy475)()		= 0;
char	(* libxfi_dummy476)()		= 0;
char	(* libxfi_dummy477)()		= 0;
char	(* libxfi_dummy478)()		= 0;
char	(* libxfi_dummy479)()		= 0;
char	(* libxfi_dummy480)()		= 0;
char	(* libxfi_dummy481)()		= 0;
char	(* libxfi_dummy482)()		= 0;
char	(* libxfi_dummy483)()		= 0;
char	(* libxfi_dummy484)()		= 0;
char	(* libxfi_dummy485)()		= 0;
char	(* libxfi_dummy486)()		= 0;
char	(* libxfi_dummy487)()		= 0;
char	(* libxfi_dummy488)()		= 0;
char	(* libxfi_dummy489)()		= 0;
char	(* libxfi_dummy490)()		= 0;
char	(* libxfi_dummy491)()		= 0;
char	(* libxfi_dummy492)()		= 0;
char	(* libxfi_dummy493)()		= 0;
char	(* libxfi_dummy494)()		= 0;
char	(* libxfi_dummy495)()		= 0;
char	(* libxfi_dummy496)()		= 0;
char	(* libxfi_dummy497)()		= 0;
char	(* libxfi_dummy498)()		= 0;
char	(* libxfi_dummy499)()		= 0;

