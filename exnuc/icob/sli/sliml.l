%{
#define YYLMAX	515
#include <sli.h>
%}
%%

\$CLASS_NAME	{
		  macro ( _sli_class_name );
		}
\$SUPER_NAME	{
		  macro ( _sli_super_name );
		}
\$VERSION	{
		  macro ( _sli_version );
		}
\$DOT_S_DECLS	{
		  macro ( _sli_dot_s_decls );
		  ignore = 1;
		}
\$INSTANCE_DATA	{
		  macro ( _sli_instance_data );
		  ignore = 1;
		}
\$OVERRIDE_DECL {
		  macro ( _sli_override_decl );
		}
\$MESSAGES	{
		  macro ( _sli_msgs );
		  ignore = 1;
		}
\$DOT_I_DECLS	{
		  macro ( _sli_dot_i_decls );
		  ignore = 1;
		}
\$STATE_NAME	{
		  macro ( _sli_state_name );
		}
\$MESSAGE_DEFAULT {
		  macro ( _sli_message_default );
		}
\$ARGS_DEFAULT {
		  macro ( _sli_args_default );
		}
\$MESSAGE_DECL	{
		  macro ( _sli_message_decl );
		}
\$METHOD_DEFAULT {
		  macro ( _sli_method_default );
		}
\$METHOD_DECL	{
		  macro ( _sli_method_decl );
		}
\$METHOD_TOP	{
		  macro ( _sli_method_top );
		}
\$METHOD_BOTTOM	{
		  macro ( _sli_method_bottom );
		}
\$METHODS	{
		  macro ( _sli_methods );
		  ignore = 1;
		}
\$DOT_S		{
		  macro ( _sli_dots );
		  ignore = 1;
		}
\$DOT_I		{
		  macro ( _sli_doti );
		  ignore = 1;
		}
.		{
		  sli_put ( yytext [0] );
		}
\n		{
		  if ( ! ignore ) sli_put ( yytext [0] );
		  ignore = 0;
		}
