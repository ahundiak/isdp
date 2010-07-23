#include <errno.h>
#include <malloc.h>
#include <string.h>
#include <unistd.h>


static int ondx=0;
static char *Cwd = 0;

extern char *getenv();
extern char *strdup();

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define SEPARATOR_S	"/"
#define SEPARATOR_C	'/'
#elif defined(NT)
#define SEPARATOR_S	"\\"
#define SEPARATOR_C	'\\'

#else
#error Unknown OS
#endif

static char	*my_getcwd(buf, size)
char	*buf;
int	size;
{
	if (!Cwd)
		Cwd = (char *)getcwd(0, size+2);
	return strncpy(buf, Cwd, size);
}

/* ARGSUSED */
void	convert_to_native_filename(char *path, int is_executable_name)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
	return;
#elif defined(NT)
/*
*	Turn slashes into backslashes.  Also changes .o to .obj, .a to .lib
*	Tacks a .exe extension onto executable names.
*/

	char	*dot = 0;
	char	*p = path;
	
	while(*p)
	{
		if (*p == '/')
			*p = '\\';
		++p;
	}

	dot = strrchr(path, '.');
	if (is_executable_name || dot)
	{
		if (is_executable_name)
		{
			if (!dot)
				strcat(path, ".exe");
			else if (strcmp(dot, ".exe"))
			{
				*dot = 0;
				strcat(path, ".exe");
			}
		}
		else
		{
			if (!strcmp(dot, ".o"))
			{
				*dot = 0;
				strcat(path, ".obj");
			}
			else if (!strcmp(dot, ".a"))
			{
				*dot = 0;
				strcat(path, ".lib");
			}
		}
	}

#else
#error Unknown OS
#endif
}

/************************************************************
 *      
 *  expand_macro:  expands all embedded macros.  The macros
 *                 can be of the form "$(macro)" or "$macro".
 *
 ************************************************************/

int expand_macro( in, out )
char *in, *out;
{
 register char term=0;
 register int indx;

 for( indx=0; in[ indx ] != 0; indx++ ) {
    if( in[ indx ] == '$'  &&  ( indx == 0  ||  in[ indx - 1 ] == SEPARATOR_C ) ) {
	register int sav_ndx;

	term = ( in[ ++indx ] == '(' ) ? (indx++, ')') : SEPARATOR_C;
        for( sav_ndx=indx; in[ indx ]  &&  in[ indx ] != term; indx++ );
        if( term == ')'  && ! in[ indx ] ) { 
	    errno = ENOENT;
	    return( -1 );
	}

        if( sav_ndx != indx ) {
	    register char *ptr, *macro;

	    if( ! (macro = (char *)calloc( 1, indx - sav_ndx + 1 ) ) ) {
		errno = ENOMEM;
		return( -1 );
	    }

	    strncpy( macro, &in[ sav_ndx ], indx - sav_ndx );
	    errno = ( ! ( ptr = getenv( macro ) ) ) ? ENOENT : 0;
	    free( macro );
	    if(	errno ) return( -1 );

            if( expand_macro( ptr, out ) ) return( -1 );
	
 	}
	/* If already at null teminator step back one so as to break out
	 * of top level for loop.
	 */

	if( ! in[ indx ] ) indx--;
    } else {
	out[ ondx++ ] = in[ indx ];
    }
 }
 out[ ondx ] = 0;
 return( 0 );
}

int	is_absolute_path(char *path)
{
	if (SEPARATOR_C == path[0]
#ifdef NT
		||
	((path[0] >= 'A' && path[0] <= 'Z' || path[0] >= 'a' && path[0] <= 'z') && path[1] == ':')
#endif
	)
		return 1;
	return 0;
}

/************************************************************
 *      
 *  expand_filename:  expands given filename to absolute path.
 *
 *                    No metacharacters are accepted.
 ************************************************************/

int expand_filename( in, out, size )
char *in, *out;
int size;
{
 register char *tmp=0;
 register int  indx=0;

 ondx=0;
 if( ! expand_macro( in, out ) ) {

#ifdef DEBUG
 printf("\n MACRO Expansion:\n\tBefore: %s\n\t After: %s\n", in, out );
#endif

    convert_to_native_filename(out, 0);
    if( !( tmp = strdup( out ) ) ) {
	errno = ENOMEM;
    } else {

	/*
	*	If it is a relative path name append the current
	*	working directory.
	*/
        if( !is_absolute_path(tmp) &&  my_getcwd( out, size ) ) {
	    ondx = strlen( out );
	    out[ ondx++ ] = SEPARATOR_C;
	    out[ ondx ] = 0;
        } else {
            ondx=0;
        }

        if( ondx  ||  is_absolute_path(tmp) ) {
	    for( indx=0; tmp[ indx ]; indx++ ) {

		/*  Look for embedded "." or ".." and if found modify the output string as necesary.
                 *  For ".." remove it and the previous directory specification.
                 *      "."  remove only the dot 
		 *
                 *  It should be impossible for either of the two constructs to begin the imput
                 *  string because of the code above that pre-pends the "CWD" if no beginning
                 *  "/" is found.
		 */

                if( tmp[ indx ] == '.'  &&  tmp[ indx - 1 ] == SEPARATOR_C ) {
		    register char next, backup=0;

		    if( (next=tmp[ indx + 1 ]) == SEPARATOR_C  ||  next == 0 ) backup = 1;
		    else if( next == '.'  &&  (next=tmp[ indx + 2 ]) == SEPARATOR_C  ||  next == 0 ) backup = 2;

		    if( backup ) {
			indx += backup;
                        for( ; ondx ; ondx-- ) 
			    if( out[ ondx-1 ] == SEPARATOR_C  &&  !(--backup) ) break;
                        if( backup ) { 
			    errno = ENOENT;
			    break;
		        }
			continue;
		    }
                }
		out[ ondx++ ] = tmp[ indx ];
	    }
	    out[ ondx ] = 0;
	}
	if( tmp[ indx ] == 0 ) {
		free( tmp );
		return( 0 );
        }
    }
 }    
 if( tmp ) free( tmp );    
 return( -1 );
}
