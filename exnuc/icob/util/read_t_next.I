
#line 53  "c:\\mstools\\h\\stdio.h"
 typedef unsigned int size_t ;




 typedef unsigned short wchar_t ;




 typedef char * va_list ;
#line 87  "c:\\mstools\\h\\stdio.h"
 struct _iobuf {
 char * _ptr ;
 int   _cnt ;
 char * _base ;
 int   _flag ;
 int   _file ;
 int   _charbuf ;
 int   _bufsiz ;
 char * _tmpfname ;
 } ;
 typedef struct _iobuf FILE ;
#line 145  "c:\\mstools\\h\\stdio.h"
 extern FILE _iob [ ] ;







 typedef long fpos_t ;
#line 182  "c:\\mstools\\h\\stdio.h"
 int          _filbuf ( FILE * ) ;
 int          _flsbuf ( int , FILE * ) ;




 FILE *          _fsopen ( const char * , const char * , int ) ;


 void          clearerr ( FILE * ) ;
 int          fclose ( FILE * ) ;
 int          _fcloseall ( void ) ;



 FILE *          _fdopen ( int , const char * ) ;

 int          feof ( FILE * ) ;
 int          ferror ( FILE * ) ;
 int          fflush ( FILE * ) ;
 int          fgetc ( FILE * ) ;
 int          _fgetchar ( void ) ;
 int          fgetpos ( FILE * , fpos_t * ) ;
 char *          fgets ( char * , int , FILE * ) ;



 int          _fileno ( FILE * ) ;

 int          _flushall ( void ) ;
 FILE *          fopen ( const char * , const char * ) ;
 int          fprintf ( FILE * , const char * , ... ) ;
 int          fputc ( int , FILE * ) ;
 int          _fputchar ( int ) ;
 int          fputs ( const char * , FILE * ) ;
 size_t          fread ( void * , size_t , size_t , FILE * ) ;
 FILE *          freopen ( const char * , const char * , FILE * ) ;
 int          fscanf ( FILE * , const char * , ... ) ;
 int          fsetpos ( FILE * , const fpos_t * ) ;
 int          fseek ( FILE * , long , int ) ;
 long          ftell ( FILE * ) ;
 size_t          fwrite ( const void * , size_t , size_t , FILE * ) ;
 int          getc ( FILE * ) ;
 int          getchar ( void ) ;
 char *          gets ( char * ) ;
 int          _getw ( FILE * ) ;
 void          perror ( const char * ) ;
 int          _pclose ( FILE * ) ;
 FILE *          _popen ( const char * , const char * ) ;
 int          printf ( const char * , ... ) ;
 int          putc ( int , FILE * ) ;
 int          putchar ( int ) ;
 int          puts ( const char * ) ;
 int          _putw ( int , FILE * ) ;
 int          remove ( const char * ) ;
 int          rename ( const char * , const char * ) ;
 void          rewind ( FILE * ) ;
 int          _rmtmp ( void ) ;
 int          scanf ( const char * , ... ) ;
 void          setbuf ( FILE * , char * ) ;
 int          setvbuf ( FILE * , char * , int , size_t ) ;
 int          _snprintf ( char * , size_t , const char * , ... ) ;
 int          sprintf ( char * , const char * , ... ) ;
 int          sscanf ( const char * , const char * , ... ) ;
 char *          _tempnam ( char * , char * ) ;
 FILE *          tmpfile ( void ) ;
 char *          tmpnam ( char * ) ;
 int          ungetc ( int , FILE * ) ;
 int          _unlink ( const char * ) ;
 int          vfprintf ( FILE * , const char * , va_list ) ;
 int          vprintf ( const char * , va_list ) ;
 int          _vsnprintf ( char * , size_t , const char * , va_list ) ;
 int          vsprintf ( char * , const char * , va_list ) ;
#line 6  "d:\\ingr\\exnuc\\icob\\util\\read_t_next.C"
 /* ARGSUSED */
 int COB_read_t_next ( fp , token , token_string , attr_num , attr_name )
#line 19  "d:\\ingr\\exnuc\\icob\\util\\read_t_next.C"
  FILE  * fp ;
  char * token ;
  char   token_string [ ] ;
  int * attr_num ;
  char    attr_name [ ] ;

 {
  int ch , ii , status ;
  static int paren_depth = 0 ;

  _verbose ( fprintf ( ( & _iob [ 2 ] )     , "+COB_read_t_next: paren_depth=%d\n" , paren_depth ) ; )
  status = RETURN_OK ;
  ii = 0 ;
  token_string [ 0 ] = 0 ;
  * token = _tok_none ;
  while ( * token == _tok_none )
    {
      ch = ( -- ( fp ) -> _cnt >= 0 ? 0xff & * ( fp ) -> _ptr ++ : _filbuf ( fp ) )          ;
      switch ( ch )
 {

   case '(' :
            if ( ii < _max_data_union_str ) { token_string [ ii ++ ] = ch ; token_string [ ii ] = 0 ; }       ;
            if ( ++ paren_depth == 1 ) * token = _tok_class ;
     break ;


   case '\t' :
   case ' ' :
     break ;

   case '\n' :
            ii = 0 ;
     break ;


   case '\'' :

 while ( ( ch = ( -- ( fp ) -> _cnt >= 0 ? 0xff & * ( fp ) -> _ptr ++ : _filbuf ( fp ) )           ) != '\'' )
       {
                if ( ii < _max_data_union_str ) { token_string [ ii ++ ] = ch ; token_string [ ii ] = 0 ; }       ;
       }
            status = RETURN_QUOTE ;
     break ;


   case '"' :
     while ( ( ch = ( -- ( fp ) -> _cnt >= 0 ? 0xff & * ( fp ) -> _ptr ++ : _filbuf ( fp ) )           ) != '"' )
       {
                if ( ii < _max_data_union_str ) { token_string [ ii ++ ] = ch ; token_string [ ii ] = 0 ; }       ;
       }
            status = RETURN_DQUOTE ;
     break ;


   case ')' :
     _verbose ( fprintf ( ( & _iob [ 2 ] )     , " COB_read_t_next: ')': p_d=%d, status=%d\n" , paren_depth , status ) ; )
            if ( paren_depth > 1 )
              {
                -- paren_depth ;
                if ( ii < _max_data_union_str ) { token_string [ ii ++ ] = ch ; token_string [ ii ] = 0 ; }       ;
                break ;
              }
            paren_depth = 0 ;
     if ( status == RETURN_QUOTE )
       {
                status = RETURN_RPAREN_QUOTE ;
       }
     else if ( status == RETURN_DQUOTE )
       {
                status = RETURN_RPAREN_DQUOTE ;
       }
     else
       {
                status = RETURN_RPAREN ;
       }

   case ',' :
       ( * attr_num ) ++ ;
     * token = _tok_attr ;
     break ;








   case '{' :
     * token = _tok_start ;
     break ;

   case '}' :
     * token = _tok_stop ;
     break ;


   case ( - 1 )   :
     * token = ( - 1 )  ;
     break ;

   default :
            if ( ii < _max_data_union_str ) { token_string [ ii ++ ] = ch ; token_string [ ii ] = 0 ; }       ;
     break ;

 }

    }

  _verbose ( fprintf ( ( & _iob [ 2 ] )     , "-COB_read_t_next: *tok=%d,tok_str='%s',p_d=%d,status=%d\n" , * token , token_string , paren_depth , status ) ; )

  return status ;

 }
