/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/backc.C
 *
 * Description:
 *      This is another copy of the vrrt/backc.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: backc.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/11/07  00:50:20  pinnacle
 * Replaced: vrrt_STEP/backc.C for:  by apazhani for route
 *
 * Revision 1.1  1998/11/06  19:31:42  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

/* This module deals with backslash'd escape sequences in strings 
("\n", "\011", "\\", etc.). */

#include <common.h>

/* First we define a structure for mapping between two-character
escape sequences and their corresponding single character, e.g.
"\n" maps to the value octal 012.  Our search routines return ERROR
when no mapping is found.  The mappings here are taken from
Kernighan & Ritchie.  */

typedef struct bci_struct { int bci_backc, bci_unbackc; }* BCINFO;
static struct bci_struct Bcinfo[] = {
	{ 'n', '\n' },
	{ 't', '\t' },
	{ 'f', '\f' },
	{ 'r', '\r' },
	{ 'b', '\b' },
	{ '\\', '\\' },
};
static int NBcinfo = sizeof(Bcinfo)/sizeof(struct bci_struct);
int ubcsearch(c) int c; { int i; BCINFO bci;
	For (i,NBcinfo) { bci = &Bcinfo[i];
		if (bci->bci_backc == c) return bci->bci_unbackc; }
	return ERROR; }
int bcsearch(c) int c; { int i; BCINFO bci;
	For (i,NBcinfo) { bci = &Bcinfo[i];
		if (bci->bci_unbackc == c) return bci->bci_backc; }
	return ERROR; }

/* unbackc_info() generalizes ubcsearch() to include escape sequences
consisting of a backslash followed by an octal sequence.
Returns two pieces of information in a single integer: the character
the sequence maps to in the low byte, and the length of the sequence
in the high byte (bits 8-15).

This function is not directly useful to most programs, but is needed
by the unback_str() routine (see below).  The more useful macro 
unbackc(str), #defined in common.h, invokes unbackc_info but returns 
just the low byte, i.e. just the character the escape sequence maps to. */

#define RETURN(c) return (len<<8)|(c);
#define isodigit(c) ((c)>='0'&&(c)<'8')
int unbackc_info(str) charp str; { int ubc; int len = 0;
	ifnot (*str=='\\') RETURN(*str) str++, len++;
	ifnot (*str) RETURN('\\')
	ifnoterror (ubc = ubcsearch(*str)) { str++, len++; RETURN(ubc) }
	if (isodigit(*str)) { int c = 0;
		do c<<=3, c|=*str++-'0', len++;
		while (len<4 && isodigit(*str));
		RETURN(c) }
	len++; RETURN(*str) }

#if 0
/* unback_str() modifies its string argument by converting all escape
sequences in the string to single characters.  This may shorten str and
make it unprintable.  Returns its argument so that it can be called inline. */

charp unback_str(str) charp str; { charp str0 = str;
	while (*str) { int info = unbackc_info(str); int len = hibyte(info);
		len && (*str = lobyte(info)); str++;
		len && --len && strcpy(str,str+len); }
	return str0; }
#endif
/* unback_str() modifies its string argument by converting all escape
sequences in the string to single characters.  This may shorten str and
make it unprintable.  Returns the number of output characters in case
there's a \000. */

int unback_str(str) charp str; { charp s1, s2; int slen; int c;
	s1 = str; slen = 0; while (c = *s1, c && c!='\\') s1++, slen++;
	s2 = s1; while (c = *s2) {
		int info = unbackc_info(s2); int len = hibyte(info);
		if (len==0) *s1++ = c,            slen++, s2++;
		else        *s1++ = lobyte(info), slen++, s2 += len; }
	*s1 = '\0'; return slen; }

/* Now for the mappings going the other way. */

/* backc_info() generates a temporary backslash'd string for characters
that need one; otherwise it returns NULL.  The buffer used for the return
value is overwritten on each call. */

charp backc_info(ubc) int ubc; { static char str[5]; int bc; ubc &= 0377;
	ifnoterror (bc = bcsearch(ubc)) { sprintf(str,"\\%c",bc); return str; }
	else ifnot (isprint(ubc)) { sprintf(str,"\\%03o",ubc); return str; }
	return NULL; }

/* backc() works like backc_info(), but provides a printable string
regardless of whether the character needs to be backslash'd. */

charp backc(ubc) int ubc; { static char str[5]; charp info;
	if (info = backc_info(ubc)) return info;
	sprintf(str,"%c",ubc); return str; }

/* back_str() makes a copy of str, replacing unprintable characters (and \)
with escape sequences.  The buffer used for the return value is overwritten
on each call. */

charp back_str(str) charp str; {
	static char buffer[KB]; charp info, bstr; int c;
	bstr = buffer; while (c = *str++) {
		ifnull (info = backc_info(c)) { *bstr++ = c; continue; }

		/* type casted the strend call. Alwin */
		strcpy(bstr,info); bstr = (char*)strend(bstr); }

	*bstr = '\0'; return buffer; }

char backbufa[NBACKBUF][MAXSTR];
charp nextbackbuf() { static int use = 0;
	++use, use %= NBACKBUF; return backbufa[use]; }

