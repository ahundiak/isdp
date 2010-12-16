#include <glib.h>
#include <gio/gio.h>
#include <string.h>

typedef enum
{
  SQL_TOKEN_SELECT = G_TOKEN_LAST + 1,
  SQL_TOKEN_FROM,
  SQL_TOKEN_WHERE,
  SQL_TOKEN_AND,
  SQL_TOKEN_OR,
  SQL_TOKEN_BY,
  SQL_TOKEN_ORDER,
  SQL_TOKEN_ORDER_BY
} SqlToken;

void test_parser_sql()
{
  GScanner  *lex;
  GTokenType token;
  gchar cset_identifier_nth[] = G_CSET_A_2_Z G_CSET_a_2_z G_CSET_DIGITS "_.";

  struct
  {
    gchar *name;
    gint   value;
  } symbol_defs[] = {
    { "SELECT",   SQL_TOKEN_SELECT },
    { "FROM",     SQL_TOKEN_FROM },
    { "WHERE",    SQL_TOKEN_WHERE },
    { "AND",      SQL_TOKEN_AND},
    { "OR",       SQL_TOKEN_OR },
    { "BY",       SQL_TOKEN_BY },
    { "ORDER",    SQL_TOKEN_ORDER },
    { NULL,0}};
  gint i;

  gchar sql[] = 
    "SELECT column1, tab2.col2 "
    "FROM table1 t1, table2 tab2 "
    "WHERE column2 = 'ahun''di\"a\"k' AND "
    "t1.col1 = \"Something\" "
    "ORDER BY col3 "
    ";";

  gchar *identifier;
  gint   symbol;
  gchar  charx;
  gchar  string[256],*p;

  // Setup scanner
  lex = g_scanner_new(NULL);

  lex->input_name = "SQL";
  lex->config->cset_identifier_nth = cset_identifier_nth;

  // Returns token value for symbols
  lex->config->symbol_2_token = TRUE;

  g_scanner_set_scope(lex,1);
  for(i = 0; symbol_defs[i].value; i++)
  {
    g_scanner_scope_add_symbol(lex,1,symbol_defs[i].name,GINT_TO_POINTER(symbol_defs[i].value));
  }

  g_scanner_input_text(lex,sql,strlen(sql));
  
  // Scan through
  while(!g_scanner_eof(lex))
  {
    token = g_scanner_get_next_token(lex);
    switch(token)
    {
      case G_TOKEN_EOF:
        g_message("EOF");
        break;
#if 0
      case G_TOKEN_SYMBOL:
        symbol = GPOINTER_TO_INT(lex->value.v_symbol);
        switch(symbol)
        {
#endif
          case SQL_TOKEN_SELECT:   g_message("SYMBOL SELECT");   break;
          case SQL_TOKEN_FROM:     g_message("SYMBOL FROM");     break;
          case SQL_TOKEN_WHERE:    g_message("SYMBOL WHERE");    break;
          case SQL_TOKEN_AND:      g_message("SYMBOL AND");      break;
          case SQL_TOKEN_OR:       g_message("SYMBOL OR");       break;
          case SQL_TOKEN_BY:       g_message("SYMBOL BY");       break;

          case SQL_TOKEN_ORDER:
            if (g_scanner_peek_next_token(lex) == SQL_TOKEN_BY)
            {
              g_scanner_get_next_token(lex);
            }
            symbol = SQL_TOKEN_ORDER_BY;
            g_message("SYMBOL ORDER BY");
            break;
#if 0
          default:
            g_message("SYMBOL %d",symbol);
       }
       break;
#endif
       
      case G_TOKEN_IDENTIFIER:
        identifier = lex->value.v_identifier;
        g_message("IDENTIFIER: %s",identifier);
        break;

      case ';':
        g_message("SEMI_COLON");
        break;

      case G_TOKEN_COMMA:
        g_message("COMMA");
        break;

      case G_TOKEN_EQUAL_SIGN:
        g_message("EQUALS");
        break;
        
      case G_TOKEN_CHAR:
        charx = lex->value.v_char;
        g_message("CHAR: %c",charx);
        break;

      case G_TOKEN_STRING:
        strcpy(string,lex->value.v_string);
        while(g_scanner_peek_next_token(lex) == G_TOKEN_STRING)
        {
          g_scanner_get_next_token(lex);
          p = strchr(string,0);
          *p++ = '\'';
          strcpy(p,lex->value.v_string);
        }
        g_message("STRING: [%s]",string);
        break;
        
      default:
        g_message("default %d",token);
    }
  }
  // Done
  g_scanner_destroy(lex);

}

int main(int argc, char** argv)
{
  g_type_init();
  
  g_test_init (&argc, &argv, NULL);

  g_test_add_func("/base/parser sql", test_parser_sql);

  return g_test_run();
}

