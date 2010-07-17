/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/str.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: str.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:34  pinnacle
 * Created: vrrt/str.C by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

/* Miscellaneous string routines. */

#include <common.h>

/* strend() returns a pointer to the null character '\0' at 
the end of the string.  str0end() does the same, but shortens
the string by one character -- useful for stripping off an
unwanted newline character from strings returned by routines
like fgets().  strlastc() returns the last character of the
string, or a null character '\0' if the string is empty. */

charp strend(str) charp str; { return str + strlen(str); }
charp str0end(str) charp str; { charp end = strend(str);
	if (end > str) *--end = '\0'; return end; }
int strlastc(str) charp str; { charp end = strend(str);
	return end > str ? *--end : '\0'; }

/* Concatenate s2 onto the end of s1.  Return the new end of s1. */

charp strcate(s1,s2) charp s1, s2; { while (*s1++ = *s2++) ; return --s1; }

charp strncate(s1,s2,n) charp s1, s2; int n; { int copied;
	copied = 0; while (n-- > 0 && (*s1++ = *s2++)) copied++; --s1;
	ifnot (copied>0 && *s1=='\0') *++s1 = '\0'; return s1; }

/* basename() returns a pointer to the last component of a
UNIX pathname.  basename("/usr/lib") points to "lib"; 
basename("/") points to the null character '\0' at the end of "/". */

charp basename(str) charp str; { charp str0 = str; str = strend(str);
	while (--str >= str0 && *str != '/') ; return ++str; }

/* unsp_str() deletes leading and trailing space from str, copying
up as necessary.  Returns its argument so that it can be called inline. */

charp lunsp_str(str) charp str; { charp str0 = str;
	while (isspace(*str)) ++str; if (str > str0) strcpy(str0,str);
	return str0; }
charp runsp_str(str) charp str; { charp str0 = str;
	str = strend(str0); while (str > str0 && isspace(*--str)) *str = '\0';
	return str0; }
charp unsp_str(str) charp str; { lunsp_str(str); runsp_str(str); return str; }

/* strcopy() and strncopy() act like strcpy() and strncpy(), but
take only one string argument.  They allocate new permanent storage
for a copy of the source string.  str_copy() acts like strcopy(),
but is robust against NULL pointers. */

charp strcopy( str )
charp str;
{
  charp copy; 
  int len = strlen( str );

  copy = diag_malloc( DIAG_FATAL, len+1 );
  strcpy( copy, str );

  return copy;
}

charp strncopy(str,n) charp str; int n; { charp copy;
	int len = strlen(str); MIN_(n,len);
	copy = diag_malloc(DIAG_FATAL,n+1);
	strncpy(copy,str,n); *(copy+n) = '\0'; return copy; }

charp str_copy(str) charp str; { return str ? strcopy(str) : NULL; }

/* strconvert() passes all the characters in the argument string
through a converter function, overwriting the string with the new
values.  Returns its argument so that it can be called inline.
The converter function must be defined to take a single integer
argument and return an integer. */

charp strconvert(str,func) charp str; funcp func; { charp str0 = str;
	while (*str) { *str = (*func)(*str); str++; } return str0; }

/* strcheck() invokes a checker function on each character in
the argument string.  Returns OKAY or ERROR depending on whether
the checker returned the expected value every time.  The checker
function must be defined to take a single integer argument and
return an integer reflecting the status. */

int strcheck(str,func,mustequal) charp str; funcp func; int mustequal; {
	int c; while (c = *str++) if ((*func)(c) != mustequal) return ERROR;
	return OKAY; }

/* strreverse reverses a string in situ.  Returns its argument so that
it can be called inline. */

charp strreverse(sl) charp sl; { charp s0; charp sr; int len; int cl, cr;
	s0 = sl; sr = sl + (len = strlen(sl)) - 1;
	len /= 2; while (len-- > 0) cl = *sl, cr = *sr, *sl++ = cr, *sr-- = cl;
	return s0; }

/* strnimatch() returns the number of initial characters that are the
same in s1 and s2.  strimatch() returns TRUE or FALSE depending on whether
s2 is entirely present in the initial characters of s1.  Reversing the
arguments won't affect strnimatch(), but will affect strimatch().

Similarly with strnematch() and strematch(), except they work backward
from the ends of the strings. */

int strnimatch(s1,s2) charp s1, s2; { int c1, c2, n = 0;
	while (c1 = *s1++, c2 = *s2++, c1 && c2 && c1==c2) ++n; return n; }
int strimatch(s1,s2) charp s1, s2; { return strnimatch(s1,s2) == strlen(s2); }

int strnematch(s1,s2) charp s1, s2; { int len1, len2; int n;
	s1 += (len1 = strlen(s1)); s2 += (len2 = strlen(s2));
	n = 0; while (len1 && len2 && (--len1, *--s1) == (--len2, *--s2)) ++n;
	return n; }
int strematch(s1,s2) charp s1, s2; { return strnematch(s1,s2) == strlen(s2); }

/* tfstr() returns a pointer to a printable boolean string telling
whether the integer argument is non-zero.  Useful in diagnostic messages. */

charp tfstr(cond) int cond; { return cond ? "T" : "F"; }

/* strfind() scans forward in s2 looking for an embedded occurrence of s1.
Returns NULL if s1 is not found. */

charp strfind(s1,s2) charp s1, s2; { charp s; int len = strlen(s1);
	while (*(s = s2++)) if (strnequal(s,s1,len)) return s; return NULL; }

/* strbcpy() and strnbcpy() act like their standard library counterparts,
but call the Common function membcpy() to enable backward copying
between addresses close to each other in memory. */

charp strbcpy(s1,s2) charp s1, s2; { membcpy(s1,s2,strlen(s2)+1); return s1; }

charp strnbcpy(s1,s2,n) charp s1, s2; int n; { int len = strlen(s2);
	membcpy(s1,s2,MIN(n,len)); if (len < n) memset(s1+len,'\0',n-len);
	return s1; }

/* undelim_str() checks the left end and right end of the string
for the desired characters.  If they're both there, they get removed and
the string will be shortened by two characters.  Returns its argument so
that it can be called inline. */

charp undelim_str(str,lc,rc) charp str; int lc, rc; {
	if (strfirstc(str)==lc && strlastc(str)==rc) {
		strcpy(str,str+1); str0end(str); } return str; }

/* strfix() returns a copy of the left half (or right half) of the
source string, as defined by the closest occurrence of the separator
character sepc to the beginning (or the end) of the string.  The four
functions strlprefix(), strrprefix(), strlsuffix() and strrsuffix()
embody the four possible combinations of the options to strfix().
Additionally, common.h #defines strprefix() as strlprefix() and
strsuffix() as strlsuffix().  Note that all of these functions
share a single buffer for the return value which is overwritten
with each call.

An example: str "a-b-c-d", sepc '-'

	function        string returned
	--------        ---------------
	strlprefix      "a"
	strprefix       "a"
	strrprefix      "a-b-c"
	strlsuffix      "b-c-d"
	strsuffix       "b-c-d"
	strrsuffix      "d"
*/

static charp strfix(str,sepc,dosuffix,dor)
 charp str; int sepc; int dosuffix; int dor; {
	static char buffer[MAXSTR]; charp sep;
	strcpy(buffer,str);
	ifnull (sep = (*(dor?strrchr:strchr))(buffer,sepc)) return NULL;
	if (dosuffix) strcpy(buffer,sep+1); else *sep = '\0';
	return buffer; }

#define DEFINE_FIXFUNC(name,want_suffix,want_last) \
charp self(str)name(str,sepc) charp str; int sepc; { \
	return strfix(str,sepc,want_suffix,want_last); }

DEFINE_FIXFUNC(lprefix,F,F)
DEFINE_FIXFUNC(rprefix,F,T)
DEFINE_FIXFUNC(lsuffix,T,F)
DEFINE_FIXFUNC(rsuffix,T,T)

/* xdigit_char() returns the hexadecimal character for its
integer argument, using upper case.  xdigit_str() returns
the same thing as a string. */

int xdigit_char(i) int i; {
	if (inrange(i,0x0,0x9)) return '0'+i;
	if (inrange(i,0xA,0xF)) return 'A'+i;
	return '?'; }
charp xdigit_str(i) int i; { static char buf[2];
	*buf = xdigit_char(i); *(buf+1) = '\0'; return buf; }

/* ctype_str() generates a string containing all the characters
for which a specified function returns true.  The buffer used for
the return value is overwritten with each call. */

charp ctype_str(func) funcp func; {
	static char buf[(256-1)+1]; charp s; int c;
	s = buf; for (c = 1; c < 256; c++) if ((*func)(c)) *s++ = c;
	*s = '\0'; return buf; }
