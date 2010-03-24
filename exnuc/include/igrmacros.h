/*----------------------------------------
 *    debug tools
 *----------------------------------------
 */
#ifndef debugh
#define debugh



#ifdef DEBUG

#define _m_debug(x) x

#define _m_debug_str(xyx) printf( "%s\n", xyx );

#define _m_check_print_bool(stt) \
{ \
    printf( "boolean status %s\n", (stt?"true":"false") );\
}


#define _m_check_print(stt) \
  om$report_error( sts=stt );

#define _m_check(stt,xyx) if (!((stt)&1)) {_m_check_print(stt);xyx;}
#define _m_checkb(stt) if (!((stt)&1)) {_m_check_print(stt); break;}
#define _m_checkq(stt) if (!((stt)&1)) {_m_check_print(stt); goto quit;}
#define _m_checkp(stt,xyx) if (!((stt)&1)) \
{printf( "%s\n", xyx );_m_check_print(stt);}

#define _m_check_bool(stt,xyx) if (!(stt)) {_m_check_print_bool(stt);xyx;}
#define _m_check_boolb(stt) if (!(stt)) {_m_check_print_bool(stt); break;}
#define _m_check_boolq(stt) if (!(stt)) {_m_check_print_bool(stt); goto quit;}
#define _m_check_boolp(stt,xyx) if (!(stt)) \
{printf( "%s\n", xyx );_m_check_print_bool(stt);}

/*----------------------------------------
 *    sts1 is an om status, sts2 is not
 *----------------------------------------
 */
#define _m_check2(sts1,sts2,xyx) if (!((sts1)&(sts2)&1)) \
  {printf( "status 2 0x%x\n", sts2); _m_check_print(sts1); xyx; }

#define _m_check2p(sts1,sts2,xyx) if (!((sts1)&(sts2)&1)) \
  {printf( "%s\n", xyx ); printf( "status 2 0x%x\n", sts2); _m_check_print(sts1); }

#define _m_check2b(sts1,sts2) if (!((sts1)&(sts2)&1)) \
  {printf( "status 2 0x%x\n", sts2); _m_check_print(sts1); break; }

#define _m_check2q(sts1,sts2) if (!((sts1)&(sts2)&1)) \
  {printf( "status 2 0x%x\n", sts2); _m_check_print(sts1); goto quit; }

/*
 *  print_grid takes a pointer to a GRid and a string
 */
#define _m_print_grid( xyx, sxz ) \
  printf( "%s (%d,%d)\n", (xyx), (sxz)->objid, (sxz)->osnum );


#ifdef VERBOSE
#define _m_verbose(x) x
#else
#define _m_verbose(x)
#endif

#else
#define _m_debug(x)
#define _m_debug_str(xyx) 
#define _m_check(stt,xyx) if (!((stt)&1)) {xyx;}
#define _m_checkp(stt,xyx) ;
#define _m_checkb(stt) if (!((stt)&1)) break;
#define _m_checkq(stt) if (!((stt)&1)) goto quit;
#define _m_check2(sts1,sts2,xyx) if (!((sts1)&(sts2)&1)) {xyx;}
#define _m_check2p(sts1,sts2,xyx) ;
#define _m_check2b(sts1,sts2) if (!((sts1)&(sts2)&1)) break;
#define _m_check2q(sts1,sts2) if (!((sts1)&(sts2)&1)) goto quit;
#define _m_check_bool(stt,xyx) if (!(stt)) {xyx;}
#define _m_check_boolb(stt) if (!(stt)) break;
#define _m_check_boolq(stt) if (!(stt)) goto quit;
#define _m_check_boolp(stt,xyx) ;
#define _m_print_grid( xyx, sxz ) ;


#define _m_verbose(x)
#endif


#endif 
