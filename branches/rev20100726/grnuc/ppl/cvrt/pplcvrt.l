%{
/*
# Changes include files in PPL source file.
# Result output to stdout.
#	cipredef.h	---> ciminimum.h
#	ci_igedef.h	---> igetypedef.h
#	ci_igrdef.h	---> igrdef.h
#	ci_igr.h	---> igrtypedef.h + igr.h
#	ci_go.h		---> godef.h + go.h
#	ciparametric.h	---> parametric.h
#
#	changes to messages
  OLD					NEW
  ci.set_value( a1, a2, a3 )		ci.set_value( 0, a1, a2, a3 )
  ci.get_value( a1, a2, a3 )		ci.get_value( 0, a1, a2, a3 )
  ci.f_execute( a1, a2 )		ci.f_execute( a1, a2, 0, 0 )
  ci.exec_fun( a1, a2, a3, a4, a5 )	ci.exec_fun( a1, a2, a3, a4, a5, 0, 0 )

# Usage pplcvrt < oldfile.u > newfile.u
*/
#define princ( F ) printf( "#include \"%s\"\n", (F) )
%}
SPC	[ \t]+
OPT_SPC	[ \t]*
%%
^"#include"{SPC}"\"cipredef.h\""	princ( "ciminimum.h"	) ;
^"#include"{SPC}"\"ci_igedef.h\""	princ( "igetypedef.h"	) ;
^"#include"{SPC}"\"ci_igrdef.h\""	princ( "igrdef.h"	) ;
^"#include"{SPC}"\"ci_igr.h\""		{	princ( "igrtypedef.h"	) ;
						princ( "igr.h"		) ;
					}
^"#include"{SPC}"\"ci_go.h\""		{	princ( "godef.h"	) ;
						princ( "go.h"		) ;
					}
^"#include"{SPC}"\"ciparametric.h\""	princ( "parametric.h"	) ;
^"struct junk_data rst[40];"		{
	printf( "struct junk_data { int type, typex, junk[44] ; } ;\n" ) ;
	ECHO ;
					}
^"#include"{SPC}"\"ci_OM.h\""		princ( "OMminimum.h"	) ;
^"#include"{SPC}"\"ci_dp.h\""		princ( "dp.h"		) ;
^"#include"{SPC}"\"ci_dpstruct.h\""	princ( "dpstruct.h"	) ;
^"#include"{SPC}"\"ci_gr.h\""		princ( "gr.h"		) ;
^"#include"{SPC}"\"ci_grdpbdef.h\""	princ( "grdpbdef.h"	) ;
^"#include"{SPC}"\"ci_grdpbmacros\""	princ( "grdpbmacros.h"	) ;
^"#include"{SPC}"\"ci_grio.h\""		{	princ( "griodef.h"	) ;
						princ( "grio.h"		) ;
					}
^"#include"{SPC}"\"ci_igrdp.h\""	princ( "igrdp.h"	) ;
^"#include"{SPC}"\"cimacros.h\""	{	princ( "ciminimum.h"	) ;
						princ( "cimacros.h"	) ;
					}
"ci"{OPT_SPC}"."{OPT_SPC}"set_value"{OPT_SPC}\(		printf("ci.set_value(0,");

"ci"{OPT_SPC}"."{OPT_SPC}"get_value"{OPT_SPC}\(		printf("ci.get_value(0,");

"ci"{OPT_SPC}"."{OPT_SPC}"f_execute"{OPT_SPC}\(		{
				char c;
				int count = 1;
				printf("ci.f_execute(");
				while ( count > 0 ){
					if((c = input() ) == ')' )
						count--;
					else if( c == EOF )
						break;
					else if( c == '(' )
						count++;
					if( count > 0 )
						output(c);
				}
				printf(", 0, 0)");
			}

"ci"{OPT_SPC}"."{OPT_SPC}"exec_fun"{OPT_SPC}\(		{
				char c;
				int count = 1;
				printf("ci.exec_fun(");
				while ( count > 0 ){
					if((c = input() ) == ')' )
						count--;
					else if( c == EOF )
						break;
					else if( c == '(' )
						count++;
					if( count > 0 )
						output(c);
				}
				printf(", 0, 0)");
			}
%%

