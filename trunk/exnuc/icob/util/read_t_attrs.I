
#line 2  "d:\\ingr\\exnuc\\icob\\util\\read_t_attrs.C"
 static void COB_surround_str ( buffer , qu )
  char * buffer ;
  char * qu ;
 {
  char  temp_str [ _max_data_union_str ] ;

  strcpy ( temp_str , buffer ) ;

  strcpy ( buffer , qu ) ;
  strcat ( buffer , temp_str ) ;
  strcat ( buffer , qu ) ;

 }



 int read_t_attrs ( fp , class_name , val , n_val )

  FILE  * fp ;
  int    class_name ;

  _attr_type   val [ ] ;
  int  * n_val ;
 {
  int  status ;
  int  ii ;
  int  a_num = - 1 ;
  char  buff [ _max_data_union_str ] ;
  char  attr_name [ _max_data_union_str ] ;
  char  tok ;

  status = RETURN_OK ;
  * n_val = 0 ;

  if ( class_name == _trans )
    {
      setup_t_attrs ( _trans_next , val , n_val ) ;
    }
  else if ( class_name == _actions )
    {
      setup_t_attrs ( _actions_class_name , val , n_val ) ;
    }

  status = setup_t_attrs ( class_name , val , n_val ) ;


  for ( ii = 0 ; ii < * n_val ; ii ++ )
    {
      val [ ii ] . val . i = 0 ;
    }

  for ( ii = 0 ; ; ii ++ )
    {
      if ( ii == * n_val )
 {
   if ( class_name == _trans || class_name == _actions )
     {



       if ( status != RETURN_RPAREN  &&
     status != RETURN_RPAREN_QUOTE  &&
      status != RETURN_RPAREN_DQUOTE  )
         {

           setup_t_attrs ( class_name , val , n_val ) ;
         }
       else
         {
    break ;
         }
     }
   else
     {
       break ;
     }
 }

      status = COB_read_t_next ( fp , & tok , buff , & a_num , attr_name ) ;
      _verbose ( fprintf ( stderr , "  read_t_attrs:  status=%d, tok=%d, buff='%s', a_num=%d, attr_name='%s'\n" , status , tok , buff , a_num , attr_name ) ; )
      if ( class_name == _actions )
 {
   if ( status == RETURN_QUOTE || status == RETURN_RPAREN_QUOTE )
     {
       COB_surround_str ( buff , "'" ) ;
       _verbose ( fprintf ( stderr , "  read_t_attrs:  COB_sur_str:  buff='%s'\n" , buff ) ; )
     }
   else if ( status == RETURN_DQUOTE ||
   status == RETURN_RPAREN_DQUOTE )
     {
       COB_surround_str ( buff , "\"" ) ;
       _verbose ( fprintf ( stderr , "  read_t_attrs:  COB_sur_str:  buff='%s'\n" , buff ) ; )
     }
 }

      if ( tok != _tok_attr )
 {
   goto not_attr_exit ;
 }

      switch ( val [ ii ] . fmt )
        {
          case _ascii :
            strcpy ( val [ ii ] . val . str , buff ) ;
            break ;

          case _int :
            val [ ii ] . val . i = eval_str ( buff ) ;
            _verbose ( fprintf ( stderr , "  read_t_attrs:  eval_str '%s' = %d\n" , buff , val [ a ] . val . i ) ; )
            break ;









          default :
            _debug ( fprintf ( stderr , "val[%d].fmt=%d\n" , i , val [ i ] . fmt ) ; )
            _debug ( fprintf ( stderr , "class_name =%d\n" , class_name ) ; )
            goto not_attr_exit ;


        }

      if ( status == RETURN_OK )
           ;
      else if ( ( status == RETURN_RPAREN ||
    status == RETURN_RPAREN_QUOTE ||
    status == RETURN_RPAREN_DQUOTE   ) &&
  class_name != _trans  &&  class_name != _actions )
 {
   break ;
 }
    }

  return status ;

 not_attr_exit :
  _debug ( fprintf ( stderr , "tok =%d\n" , tok ) ; )
  return 2 ;
 }
