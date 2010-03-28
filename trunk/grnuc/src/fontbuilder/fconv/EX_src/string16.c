/*
$Log: string16.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:07  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:19  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:22  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:50:09  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:28:41  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:41:50  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <string.h>
#include <varargs.h>
#include <sys/types.h>

#define TRUE 1
#define FALSE 0
/* convert a char string with \dddd to a short string.
   MALLOC is used to allocate space for the returned string
*/
short *cvt8to16( in )
unsigned char *in;
{
    int		num_let,
		num;
    short	*nstr,
		*save_out;
    unsigned char	*save_in;

    num_let = 1;
    save_in = in;
    while( *in )
    {
	/* \dddd */
        if( *in == '\\' )
	{
	    in++;
	    num = 0;
	    while( num < 4 && ( *in >= '0' && *in <= '9' ) )
	    {
		num++;
		in++;
	    }
	    if( num != 4 )
	    {
		printf("cvt8to16: \\dddd invalid %s\n",in-num);
		return(NULL);
	    }
	}
	else
	    in++;

	num_let++;
    }

    save_out = nstr = (short *) malloc( num_let * 2 );
    if( !nstr )
    {
	printf("cvt8to16: nstr malloc %d bytes\n", num_let * 2);
	return(nstr);
    }

    in = save_in;
    while( *in )
    {
	/* \dddd */
        if( *in == '\\' )
	{
	    in++;
	    sscanf((char *)in,"%4d",&num);
	    *nstr++ = num;
	    in += 4;
	}
	else
	    *nstr++ = *in++;
    }
    *nstr = NULL;
    return( save_out );
}
/* 
    duplicate vsprintf16 EXCEPT for the %s, "%s" is permitted but only in
    the simplest form i.e. "%s", the justifications are not honored
*/
int vsprintf16 (va_alist)
va_dcl
{
    va_list	parg,
		lparg;
    int         dummyi;
    double      dummyd;
    short	*result,
		*format,
		*save_format,
		*in_string,
		*start_result;
    
    unsigned char	reg_fmt[20],
		*ptr_reg_fmt,
		reg_result[40],
		*ptr_reg_result;


    va_start(parg);

    start_result = result = va_arg (parg, short *);
    format = va_arg (parg, short *);
    lparg = va_arg( parg, va_list );

    while (*format)
    {
	if (*format == '%')
	{
	    save_format = format;
	    format++;
	    while (*format && !is_conv_char(*format) )
		format++;

	    if (*format)
	    {
		switch (*format)
		{
		    case 'c':
			*result++ = va_arg (lparg, char);
		    break;

		    case '%':
			*result++ = '%';
		    break;

		    case 's':
			in_string = va_arg (lparg, short *);
			while (*in_string)
			    *result++ = *in_string++;
		    break;

		    default:
		        ptr_reg_fmt = reg_fmt;
			while (save_format <= format)
			    *ptr_reg_fmt++ = *save_format++;

			*ptr_reg_fmt = NULL;
			vsprintf ((char *)reg_result, (char *)reg_fmt, lparg);
			ptr_reg_result = reg_result;
			while (*ptr_reg_result)
			    *result++ = *ptr_reg_result++;
			switch (*format)
			{
			    case 'd':
			    case 'i':
			    case 'x':
			    case 'o':
			    case 'u':
			    case 'X':
				dummyi = va_arg (lparg, int);
			    break;

			    case 'f':
			    case 'F':
			    case 'g':
			    case 'G':
			    case 'e':
			    case 'E':
				dummyd = va_arg (lparg, double);
			    break;

			}
		    break;
		}
		format++;
	    }
	    else
	    {
		printf("No conversion character in vsprintf16\n");
		return (0);
	    }
	}
	else
	{
	    *result++ = *format++;
	}
    }
    
    *result = NULL;
    va_end (parg);
    return (result - start_result);
}

/* 
    duplicate sprintf16 EXCEPT for the %s, "%s" is permitted but only in
    the simplest form i.e. "%s", the justifications are not honored
*/
int sprintf16 (va_alist)
va_dcl

{
    va_list	parg;
    int         dummyi;
    double      dummyd;
    short	*result,
		*format,
		*save_format,
		*in_string,
		*start_result;
    
    unsigned char	reg_fmt[20],
		*ptr_reg_fmt,
		reg_result[40],
		*ptr_reg_result;


    va_start(parg);

    start_result = result = va_arg (parg, short *);
    format = va_arg (parg, short *);

    while (*format)
    {
	if (*format == '%')
	{
	    save_format = format;
	    format++;
	    while (*format && !is_conv_char(*format) )
		format++;

	    if (*format)
	    {
		switch (*format)
		{
		    case 'c':
			*result++ = va_arg (parg, char);
		    break;

		    case '%':
			*result++ = '%';
		    break;

		    case 's':
			in_string = va_arg (parg, short *);
			while (*in_string)
			    *result++ = *in_string++;
		    break;

		    default:
		        ptr_reg_fmt = reg_fmt;
			while (save_format <= format)
			    *ptr_reg_fmt++ = *save_format++;

			*ptr_reg_fmt = NULL;
			vsprintf ((char *)reg_result, (char *)reg_fmt, parg);
			ptr_reg_result = reg_result;
			while (*ptr_reg_result)
			    *result++ = *ptr_reg_result++;
			switch (*format)
			{
			    case 'd':
			    case 'i':
			    case 'x':
			    case 'o':
			    case 'u':
			    case 'X':
				dummyi = va_arg (parg, int);
			    break;

			    case 'f':
			    case 'F':
			    case 'g':
			    case 'G':
			    case 'e':
			    case 'E':
				dummyd = va_arg (parg, double);
			    break;

			}
		    break;
		}
		format++;
	    }
	    else
	    {
		printf("No conversion character in sprintf16\n");
		return (0);
	    }
	}
	else
	{
	    *result++ = *format++;
	}
    }
    
    *result = NULL;
    va_end (parg);
    return (result - start_result);
}

/* is character a valid format specifier */
int is_conv_char( character )
	short character;
{
    if( character >= '%' && character <= 'x' )
    {
	switch( character )
	{
	    case 'd':
	    case 'c':
	    case 'X':
	    case 'G':
	    case 'E':
	    case 'e':
	    case 'f':
	    case 'g':
	    case 'i':
	    case 'o':
	    case 's':
	    case 'u':
	    case 'x':
	    case '%':
		return(TRUE);
	    /*break;*/

	    default:
		return(FALSE);
	    /*break;*/
	}
    }
    else
	return(FALSE);

}
/* return pointer to char data which was short. This should be used 
   to replace calls like sscanf(response_data,"%lf %[,] %lf",&d1,&d2) with
   sscanf(CX16to8(response_data),"%lf ..... ); OR like
   sscanf(CX16to8(buffer.value.str ),"%d",&temp );
*/

unsigned char *CX16to8( short_ptr )
    short *short_ptr;
{
    static unsigned char result[256];
    unsigned char	*ptr_result;

    ptr_result = result;
    while (*ptr_result++ = *short_ptr++);

    return (result);
}
/* 
   return pointer to short where characters have moved to. This should be used
   instead of malloc. WARNING the same data area is returned so intermediate
   results are NOT any good. If there any questions ask.
*/
short *CX8to16 (char_ptr)
unsigned char *char_ptr;

{
    static short result[256];
    short	*ptr_result;

    ptr_result = result;
    while (*ptr_result++ = *char_ptr++);
    return (result);
}

short *strcpy16(short1_ptr, short2_ptr)
short	*short1_ptr,
	*short2_ptr;
{
    short	*save_ptr;

    save_ptr = short1_ptr;
    while (*short1_ptr++ = *short2_ptr++);
    return (save_ptr);
}

int strlen16( ptr_short )
short    *ptr_short;
{
    short    *save_ptr;

    save_ptr = ptr_short;
    while( *ptr_short++ );
    return(ptr_short - save_ptr - 1);
}

int strcmp16( s1, s2 )
short    *s1,
	 *s2;
{
    for( ; *s1 == *s2 ; s1++, s2++ )
	if( ! *s1 )
	    return(0);

    return( *s1 - *s2 );
}

int strncmp16( s1, s2, cnt )
short    *s1,
	 *s2;
size_t	cnt;
{
    size_t	i;

    for( i=0 ; *s1 == *s2 && i < cnt ; s1++, s2++, i++ )
	if( ! *s1 )
	    return(0);

    return( i == cnt ? 0 : *s1 - *s2 );
}

short *strncpy16(short1_ptr, short2_ptr, cnt )
short	*short1_ptr,
	*short2_ptr;
size_t	cnt;
{
    size_t	i;
    short	*save_ptr;

    save_ptr = short1_ptr;
    for( i= 0 ; i < cnt ; i++ )
	*short1_ptr++ = *short2_ptr ? *short2_ptr++ : NULL;
    return (save_ptr);
}

short *strcat16(short1_ptr, short2_ptr)
short	*short1_ptr,
	*short2_ptr;
{
    short	*save_ptr;

    save_ptr = short1_ptr;
    /* get to end of string */
    while( *short1_ptr ) short1_ptr++;
    while( *short1_ptr++ = *short2_ptr++ );
    return (save_ptr);
}

short *strncat16(short1_ptr, short2_ptr, cnt)
short	*short1_ptr,
	*short2_ptr;
size_t  cnt;
{
    size_t	i;
    short	*save_ptr;

    save_ptr = short1_ptr;
    /* get to end of string */
    while( *short1_ptr ) short1_ptr++;
    for( i=0; (i < cnt) && *short2_ptr; i++, short1_ptr++, short2_ptr++ )
	*short1_ptr = *short2_ptr;

    *short1_ptr = NULL;
    return (save_ptr);
}

short *strdup16( s )
short    *s;
{
    short    *new_s;

    if( new_s = (short*) malloc(strlen16(s)+1) )
	strcpy16(new_s,s);
    return(new_s);
}

short *strchr16( s, find_let )
short *s;
int	find_let;
{

    while( (find_let != *s) && *s )
	s++;

    return( find_let == *s ? s : NULL );
}

short *strrchr16( s, find_let )
short *s;
int	find_let;
{
    short	*end_s;

    end_s = s;
    while( *end_s )
	end_s++;

    while( (find_let != *end_s) && end_s >= s )
	end_s--;

    return( find_let == *end_s ? end_s : NULL );
}

short *strpbrk16( s1, s2 )
short    *s1,
	 *s2;
{
    short    *find_s;

    while( *s1 )
    {
	find_s = s2;
	while( *find_s  && ( *find_s != *s1) )
	    find_s++;
	
	if( *find_s )
	    return(s1);

	s1++;
    }
    return(NULL);
}

int strspn16( s1, s2 )
short    *s1,
	 *s2;
{
    short    *find_s,
	     *save_ptr;

    save_ptr = s1;
    while( *s1 )
    {
	find_s = s2;
	while( *find_s  && ( *find_s != *s1) )
	    find_s++;
	
	if( !*find_s )
	   break; 

	s1++;
    }
    return( s1 - save_ptr );
}

int strcspn16( s1, s2 )
short    *s1,
	 *s2;
{
    short    *find_s,
	     *save_ptr;

    save_ptr = s1;
    while( *s1 )
    {
	find_s = s2;
	while( *find_s  && ( *find_s != *s1) )
	    find_s++;
	
	if( *find_s )
	   break; 

	s1++;
    }
    return( s1 - save_ptr );
}

short *strtok16( s1, s2 )
short    *s1,
	 *s2;
{
    short   *ret_s,
	    *find_s,
	    *save_s,
	    *cur_s;
    static short *last_s;

    save_s = cur_s = s1 ? s1 : last_s;
    while( *cur_s )
    {
	find_s = s2;
	while( *find_s  && ( *find_s != *cur_s) )
	    find_s++;
	
	if( !*find_s )
	   break; 

	cur_s++;
    }

    if( *cur_s )
	ret_s = cur_s;
    else
	return(NULL);

    while( *cur_s )
    {
	find_s = s2;
	while( *find_s  && ( *find_s != *cur_s) )
	    find_s++;
	
	if( *find_s )
	   break; 

	cur_s++;
    }

    *cur_s++ = NULL;
    last_s = cur_s;
    return( ret_s );
}

/* write a short "character string to output file with
   option to write " and \ as decimal equivalents
   Return 0 if success and 1 if write failed 
*/

int fwritestr16( str, out, special )
short    *str;
FILE     *out;
int	 special;    /* if non zero write \ and " as \nnn equal */
{
    int	    status;
    char    expand_char;

    while( *str )
    {
	expand_char = FALSE;
	if( *str >= ' ' && *str <= '~' )
	{
	    if( special  && ( *str == '"' || *str == '\\' ) )
		expand_char = TRUE;
	}
	else
	    expand_char = TRUE;

	/* print normal ?? */
	if( !expand_char )
	    status = fputc((unsigned char) *str, out );
	else
	    status = fprintf(out,"\\%04d", (unsigned char)*str);
	
	if( status < 0 )
	{
	    printf("fwritestr16: write error\n");
	    return(1);
	}

        str++;
    }
    return(0);
}

/* function to read a configure file and return the value of a configuration 
	parameter
*/
get_configuration_data( config_file, config_param , param_value )
char	*config_file,
	*config_param,
	*param_value;
{
    FILE    *in;
    char    line[512],
	    *ptr_line;
    int	    count,
	    param_len;

    in = fopen(config_file,"r");
    if( !in )
    {
	printf("get_config_data: error opening file %s\n",config_file);
	return(-1);
    }

    param_len = strlen( config_param );
    do
    {
	ptr_line = fgets( line, sizeof(line), in );
	if( !ptr_line )
	{
	    printf("get_config_data: can't find %s\n",config_param);
	    fclose(in);
	    return(-2);
	}
        count = strlen( ptr_line );
	/* remove newline char */
	if( count > 0 )
	    ptr_line[count-1] = NULL;

	if( !strncmp(ptr_line, config_param, param_len ) )
	{
	    strcpy( param_value, &line[param_len+1]);
	    fclose(in);
	    return(0);
	}
    } while ( !feof(in) );

    fclose(in);
    /* param not found */
    printf("get_config_data: can't find %s\n",config_param);
    return(-2);
}
