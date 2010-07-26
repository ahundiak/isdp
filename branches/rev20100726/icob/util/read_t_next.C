/* read_t_next.C */
#include <stdio.h> 
#define _store_c if (ii<_max_data_union_str) \
		 { token_string [ii++]=ch; token_string [ii]=0; }

#argsused
int COB_read_t_next ( fp , token , token_string , attr_num , attr_name )

    /* function value = RETURN_RPAREN				      */
    /* 			   for token == _tok_attr && separator == ')' */
    /* 		      = RETURN_RPAREN_QUOTE  for '<string>'	      */
    /* 			   for token == _tok_attr && separator == ')' */
    /* 		      = RETURN_RPAREN_DQUOTE  for "<string>"	      */
    /* 			   for token == _tok_attr && separator == ')' */
    /* 		      = RETURN_QUOTE  for '<string>'		      */
    /*		      = RETURN_DQUOTE for "<string>"		      */
    /*		      = RETURN_OK otherwise.			      */

  FILE  * fp;			/* file to read from */
  char	* token;		/* token for thing encountered */
  char	  token_string [];	/* the chars read */
  int	* attr_num;		/* the number of attributes */
  char    attr_name [];         /* the attr name from xx= */

{
  int ch, ii, status;
  static int paren_depth = 0;

  _verbose(fprintf(stderr,"+COB_read_t_next: paren_depth=%d\n",paren_depth);)
  status = RETURN_OK;
  ii = 0;
  token_string [ 0 ] = 0;
  * token = _tok_none;
  while ( * token == _tok_none )
    {
      ch = getc ( fp );
      switch ( ch )
	{
/* _class */
	  case '(' :
            _store_c;
            if ( ++ paren_depth == 1 ) * token = _tok_class;
	    break;

/* white space */
	  case '\t' :
	  case ' ' :
	    break;

	  case '\n' :
            ii = 0;
	    break;

/* 'string' */
	  case '\'' :

 while ( ( ch = getc ( fp ) ) != '\'' )
	      {
                _store_c;
	      }
            status = RETURN_QUOTE;
	    break;

/* "string" */
	  case '"' :
	    while ( ( ch = getc ( fp ) ) != '"' )
	      {
                _store_c;
	      }
            status = RETURN_DQUOTE;
	    break;

/* _attr_number */
	  case ')' :
	    _verbose(fprintf(stderr," COB_read_t_next: ')': p_d=%d, status=%d\n",paren_depth,status);)
            if ( paren_depth > 1 )
              {
                -- paren_depth;
                _store_c;
                break;
              }
            paren_depth = 0;
	    if ( status == RETURN_QUOTE )
	      {
                status = RETURN_RPAREN_QUOTE;
	      }
	    else if ( status == RETURN_DQUOTE )
	      {
                status = RETURN_RPAREN_DQUOTE;
	      }
	    else
	      {
                status = RETURN_RPAREN;
	      }
            /* _no_break; */
	  case ',' :
  	    ( * attr_num ) ++;
	    * token = _tok_attr;
	    break;

	  /*** This is leftover from OM-based form ASCII files ********
          case '=' :
            strcpy ( attr_name, token_string );
            ii = 0;
            break;
	  ********************************** JAJ:05/21/91 *************/

	  case '{' :
	    * token = _tok_start;
	    break;

	  case '}' :
	    * token = _tok_stop;
	    break;

/* end of ini file */
	  case EOF :
	    * token = EOF;
	    break;

	  default :
            _store_c;
	    break;

	} /* switch on ch */

    } /* while */

  _verbose(fprintf(stderr,"-COB_read_t_next: *tok=%d,tok_str='%s',p_d=%d,status=%d\n",*token,token_string,paren_depth,status);)

  return status;

} /* COB_read_t_next */

#undef _store_c
