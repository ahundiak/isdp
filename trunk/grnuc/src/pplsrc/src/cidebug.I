class implementation ci ;

/*----------------------------------------------------------------------------*/
method debug() {

	int i, al ;

#define _M( u ) ( (u) ? "ON" : "OFF" )
#define DATA	me^^ci.data
#define PARMS	me^^ci.runparms
#define OPT	me^^ci.runparms.options
#define ME_IGE  ((ci_IGE *) me^^ci.data->info)

  printf( "---------- CI debug method ----------\n" ) ;
  printf( "\tClassname: ci\n"					) ;
  printf( "\tObject id: %u\n"		, my_id			) ;
  printf( "\tObject space number: %u\n"	, OM_Gw_current_OS	) ;
  printf( "\n\tINSTANCE DATA\n" ) ;
  printf( "\t- loaded: <%s>\n", me^^super_cmd.state & CI_LOADED_WITH_PPL ?
							      "YES" : "NO" ) ;

  if( me^^super_cmd.state & CI_LOADED_WITH_PPL ) {
    printf( "\t- file name: \"%s\"\n"   , DATA->ficcmd			     ) ;
    printf( "\t- user prompt: \"%s\"\n" , me^^ci.runparms.msgsys.Prompt	     ) ;
    printf( "\t- user message: \"%s\"\n", me^^ci.runparms.msgsys.Message     ) ;
    printf( "\t- command message mode: %s\n"      ,
			 _M( PARMS.EX_cmd_mode & EX_MSG_QUIET )	     ) ;
    printf( "\t- command display mode: %s\n"      ,
			 _M( PARMS.EX_cmd_mode & EX_DISP_QUIET )	     ) ;
    printf( "\t- command help    mode: %s\n"      ,
			 _M( PARMS.EX_cmd_mode & EX_HELP_QUIET )	     ) ;
    printf( "\t- executing: %s\n"       ,
	    _M( me^^super_cmd.state & CI_EXECUTING_PPL  ) ) ;
    printf( "\t- clone(s): %d\n"        , DATA->nb_clone		     ) ;
    printf( "\t- quiet mode: %s\n"      , _M( OPT & CI_QUIET_MODE ) ) ;
    printf( "\t- no msg mode: %s\n"     , _M( OPT & CI_NOMSG_MODE ) ) ;
    printf( "\t- keep mode: %s\n"       , _M( OPT & CI_KEEP_MODE  ) ) ;

/* -- Check addresses.
   -- */
    for( i = 0 ; i < me^^ci.data->nbvar ; i++ ) {
	if( me^^ci.data->varflagtable[i] & CI_XTRN ) continue ;
	switch( me^^ci.data->vartypetable[i] ) {
		case CI_VOID	: al = 4 ; break ;
		case CI_CHAR	: al = 1 ; break ;
		case CI_SHORT	: al = 2 ; break ;
		case CI_INT	: al = 4 ; break ;
		case CI_DOUBLE	: al = 8 ; break ;
		case CI_STRUCT	: al = 0 ; break ;
		default		: al = 4 ; break ;
	}
	if( al ) {
	  if( ( (unsigned) me^^ci.my_varvaltable[i] ) % al != 0 ) {
		printf( "*** <%s> has bad address, addr %u, alignment %u\n",
			me^^ci.data->vartable[i],
			me^^ci.my_varvaltable[i], al ) ;
	  }
	}
    }
  }
  printf( "-------------------------------------\n" ) ;

  return OM_S_SUCCESS ;
	
} /* debug */
/*----------------------------------------------------------------------------*/
end implementation  ci ;

