
/* - special conversion routine GRtext$GRtext - */

#include "OMport.h"
#define ESC	27

struct IGRestx {
short font;
short just;
double width;
double height;
short flag;
short num_char;
double line_spac;
double char_spac;
short text_length;
};

struct GRtext_instance {
struct IGRestx attr;
struct OM_sd_varlenarr_descr text_string;
};


#if defined(__STDC__) || defined(__cplusplus)
GRtext_OMPORT_GRtext(short classid, char *ME, struct GRtext_instance *me)
#else
GRtext$GRtext(classid, ME, me)
short classid;
char *ME;
struct GRtext_instance *me;
#endif
{

	int sts, i, text_length;
	char *string;

#if defined(__STDC__) || defined(__cplusplus)
	text_length = OMPORT_INTEGER_VALUE ( &me->text_string.i_count );

	string = (char *)((unsigned int) (&me->text_string) +
	    		OMPORT_INTEGER_VALUE (&me->text_string.i_offset));
#else
	text_length = om$integer_value ( &me->text_string.i_count );

	string = (char *)((unsigned int) (&me->text_string) +
			om$integer_value (&me->text_string.i_offset));
#endif

	if( text_length ) {
		for( i = 0 ; i< text_length;) {
			if( string[i] == ESC ) {
				switch(string[i+1]) {
				case 'H':
				case 'J':
				case 'j':
				case 'y':
				case 's':
				case 'v':
				case 'x':
				case 'h':
				case 'C':
#if defined(__STDC__) || defined(__cplusplus)
					sts = OMPORT_CONV_DOUBLE(&string[i+2], 1);
#else
					sts = om$conv_double(&string[i+2], 1);
#endif
			   		i += 10 ;
			   		break;

				case 'w':
				case 'p':
			   		i += 3;
			   		break;

				case 'E':
				case ESC:
				case '\n':          /* linefeed */
				   	i += 2 ;
			   		break;

				case 'F':
			   		i += 4 ;
			   		break;

				case 'M':
#if defined(__STDC__) || defined(__cplusplus)
					sts = OMPORT_CONV_DOUBLE(&string[i+4],2);
#else
					sts = om$conv_double(&string[i+4],2);
#endif
			   		i += 20 ;
			   		break;

				case 'm':
#if defined(__STDC__) || defined(__cplusplus)
					sts = OMPORT_CONV_DOUBLE(&string[i+3],2);
#else
					sts = om$conv_double(&string[i+3],2);
#endif
			   		i += 19 ;
			   		break;

				case 'f':
				case 'c':
#if defined(__STDC__) || defined(__cplusplus)
			   		sts = OMPORT_CONV_SHORT( &string[i+2], 1);
#else
			   		sts = om$conv_short( &string[i+2], 1);
#endif
			   		i += 4 ;
			   		break;

				default: 
					i++;
				}
	    		}
	    		else {
				/*	printf("%c\n", string[i] ); */
					i++;
	    		}
		}
	}

	return(1);
}
