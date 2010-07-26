#include <malloc.h>
#include "cpperr.h"
#include "cpp.h"
#include "omdef.h"
#include "fio.h"
#include "luther.h"

#define ACTIVE_TOK &(active_stream->tok)
#define STRUCT_MALLOC(A) (struct A *)malloc(sizeof(struct A))

char	*string_malloc();

/*
struct om_macro
 {
  struct symbol symb;
  int parametric;
  struct para_symbol *para_link;
  symtab_ptr para_table;
  struct cpp_token *def_link;
 };
struct para_symbol
 {
  struct symbol symb;
  int has_default;
  struct cpp_token *defaults;
  int para_id;
  struct para_symbol *next;
  struct para_symbol *splink;
 };
*/


static void free_omdef_para (ta)
 struct para_symbol *ta;
 {/* P. L. H. Dec. 5, 1986 */
  struct cpp_token *t1, *t2;

  t1 = ta->defaults;
  while (t1) { t2 = t1->flink; free (t1); t1 = t2; }
  free (ta->symb.name);
  free (ta);
 } /* free_omdef_para */

void free_omdef(tt)
struct om_macro *tt;
 {
  struct cpp_token *t1,*t2;

#if 1
  delete_symbol_table (tt->para_table, free_omdef_para);
#else
  struct para_symbol *ta, *tb;
  ta = tt->para_link;
  while (ta)
   {
    tb = ta->next;
    t1 = ta->defaults;
    while (t1) { t2 = t1->flink; free (t1); t1 = t2; }
    free (ta->symb.name);
    free (ta);
    ta = tb;
   }
#endif
  t1 = tt->def_link;
  while (t1) { t2 = t1->flink; free (t1); t1 = t2; }
  free (tt->symb.name);
  free (tt);
 }


#define next_token()\
 {\
  luther_get_tok();\
  while (active_stream->tok.typ==TOK_NULL) luther_get_tok();\
 }


#define next_good_token()\
 {\
  next_token();\
  while (active_stream->tok.typ==TOK_NEW_LINE) next_token();\
 }


static char msg[300];


static struct para_symbol *gobble_para()
 {
  struct para_symbol *pp;
  struct cpp_token *tail=0;
  int pardepth=0;

  if (active_stream->tok.typ!=TOK_ID)
   {
    CPPERROR(ACTIVE_TOK,"identifier expected");
    return (0);
   }
  pp = STRUCT_MALLOC(para_symbol);
  pp->defaults=0;
  pp->has_default=0;
  pp->symb.name = (char *)string_malloc(active_stream->yytext);
  next_good_token();
  switch (active_stream->tok.typ)
   {
    case '^':
    case ',':
    case ')':
     return (pp);
    case '=':
     next_good_token();
     break;
    case TOK_EOF:
     CPPERROR(ACTIVE_TOK,"unexpected end of file");
     return (pp);
    default:
     CPPERROR(ACTIVE_TOK,"'^' ',' ')' or '=' expected.  '=' assumed");
     break;
   }
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case TOK_EOF:
       CPPERROR(ACTIVE_TOK,"unexpected end of file");
       if (tail) tail->flink = 0;
       return (pp);
      case '^':
      case ',':
      case ')':
       if (pardepth==0)
        { if (tail) tail->flink = 0; return (pp); }
       pardepth-=1;
       if (active_stream->tok.typ == ')') pardepth-=1;
      case '(':
       pardepth+=1;
      default:
       if (tail) { tail->flink = token_malloc(); tail = tail->flink; }
       else { pp->has_default=1; tail = pp->defaults = token_malloc(); }
       break;
     }
    next_good_token();
   }
 }


static struct para_symbol *omdef_read_para()
 {
  int par_id = 0;
  struct para_symbol *cp=0,*np;
  next_good_token();
  /*  expecting a TOK_ID or TOK_RIGHT_ROUND  */
  if (active_stream->tok.typ==TOK_RIGHT_ROUND) return (0);
  if (active_stream->tok.typ!=TOK_ID)
   {
    CPPERROR (ACTIVE_TOK,"identifier, or ) expected");
    return (0);
   }
  while (1)
   {
    np = gobble_para();
    if (!np) return (cp);
    np->para_id = par_id;
    np->next = cp;
    cp = np;
    switch (active_stream->tok.typ)
     {
      case ',':
       par_id++;
       next_good_token();
       break;
      case '^':
       next_good_token();
       break;
      case ')':
       return (cp);
      default:
       CPPERROR(ACTIVE_TOK,"',' '^' or ')' expected");
       return (cp);
     }
   }
 }


static struct cpp_token *omdef_read_body(omdef_token)
struct cpp_token *omdef_token;
 {
  struct cpp_token *head=0,*tp=0,*ta;
  int nest_depth=1;

  next_token();
  while (1)
   {
    if (active_stream->tok.typ==TOK_EOF)
     {
      CPPERROR(omdef_token,"missing #endomdef");
      if (head)
       { tp->flink=0; return (head); }
      return (0);
     }
    if (active_stream->tok.typ==TOK_POUND)
     {
      ta=token_malloc();
      next_token();
      if (active_stream->tok.typ==TOK_ID)
       {
        if (!strcmp(active_stream->yytext,"endomdef"))
         {
          nest_depth--;
          if (nest_depth == 0)
           {
            free (ta);
            if (head)
             { tp->flink=0; return (head); }
            return (0);
           }
         }
        else if (!strcmp(active_stream->yytext,"omdef"))
         {
          nest_depth++;
         }
        if (!head)
         { head = ta; tp = ta; }
        else
         { tp->flink = ta; tp = ta; }
        ta = token_malloc();
        tp->flink = ta;
        tp = ta;
        next_token();
       }
      else
       {
        ta = token_malloc();
        if (!head)
         { head = ta; tp = ta; }
        else
         { tp->flink = ta; tp = ta; }
        next_token();
       }
     }
    else
     { 
      ta = token_malloc();
      if (!head)
       { head = ta; tp = ta; }
      else
       { tp->flink = ta; tp = ta; }
      next_token();
     }
   }
 }

extern void proc_omdef();

void process_omdef()
 {
  if (active_stream->ifstack)
   {
    if (active_stream->ifstack->a)
     {
      return;
     }
   }
  proc_omdef();
 }


void process_endomdef()
 {
  if (active_stream->ifstack)
   {
    if (active_stream->ifstack->a)
     {
      return;
     }
   }
  CPPERROR (ACTIVE_TOK,"#omdef-#endomdef inconsistency detected");
 }


void proc_omdef()
 {
  struct om_macro *new_mac;
  struct cpp_token *omdef_token;

  omdef_token = token_malloc();
  next_good_token();
  if (active_stream->tok.typ==TOK_ID)
   {
    new_mac = STRUCT_MALLOC(om_macro);
    new_mac->symb.name = (char *)string_malloc(active_stream->yytext);
    new_mac->para_table = new_basictab(3,0);
    next_good_token();
    new_mac->para_link = 0;
    if (new_mac->parametric = ((active_stream->tok.typ==TOK_LEFT_ROUND)))
     {
      struct para_symbol *tp;
      tp = new_mac->para_link = omdef_read_para();
      while (tp)
       {
        if (lookup_symbol(new_mac->para_table,tp->symb.name))
         {
          sprintf (msg,"argument <%s> multiply declared",tp->symb.name);
          CPPERROR (ACTIVE_TOK,msg);
         }
        else
         {
          enter_symbol(new_mac->para_table,tp);
         }
        tp = tp->next;
       }
     }
    new_mac->def_link=omdef_read_body(omdef_token);
    free (omdef_token);
    enter_symbol(active_stream->omdef_table,new_mac);
   }
  else /* name of macro expected, got garbage */
   {
    CPPERROR (ACTIVE_TOK,"identifier expected");
    while (1)
     {
      if (active_stream->tok.typ == TOK_POUND)
       {
        next_token();
        if (active_stream->tok.typ == TOK_ID)
         {
          if (!(strcmp(active_stream->yytext,"endomdef")))
           { free (omdef_token); return; }
         }
       }
      else if (active_stream->tok.typ == TOK_EOF)
       {
        CPPERROR(ACTIVE_TOK,"unexpected end of file");
        free (omdef_token);
        return;
       }
     }
   }
 }


static struct para_symbol *gobble_arg()
 {
  struct para_symbol *tp;
  struct cpp_token *tail=0;
  int par_count=0;
  int inside_tik=0;

  if (active_stream->tok.typ == TOK_RIGHT_ROUND)
   {
    return (0);
   }
  if (active_stream->tok.typ != TOK_ID)
   {
    CPPERROR (ACTIVE_TOK,"identifier expected");
    return (0);
   }
  tp = STRUCT_MALLOC (para_symbol);
  tp->symb.name = (char *)string_malloc(active_stream->yytext);
  tp->has_default = 0;
  tp->defaults = 0;
  tp->para_id = 0;
  tp->next = 0;
  next_good_token();
  if (active_stream->tok.typ == TOK_EQUAL)
   {
    next_good_token()
   }
  else
   {
    CPPERROR (ACTIVE_TOK,"'=' missing, assumed present");
   }
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case '`':
       inside_tik = !inside_tik;
       break;
      case ',':
       if ((par_count)||(inside_tik))
        {
         if (tail) { tail->flink = token_malloc(); tail = tail->flink; }
         else { tp->defaults = tail = token_malloc(); }
         break;
        }
       else
        { if (tail) tail->flink = 0; return (tp); }
      case ')':
       if ((par_count)||(inside_tik))
        {
         if (tail) { tail->flink = token_malloc(); tail = tail->flink; }
         else { tp->defaults = tail = token_malloc(); }
         par_count--;
         break;
        }
       else
        { if (tail) tail->flink = 0; return (tp); }
      case '(':
       par_count++;
      default:
       if (tail) { tail->flink = token_malloc(); tail = tail->flink; }
       else { tp->defaults = tail = token_malloc(); }
       break;
      case TOK_EOF:
       CPPERROR(ACTIVE_TOK,"unexpected end of file");
       if (tail) tail->flink = 0;
       return (tp);
     }
    next_good_token();
   }
 }



static struct para_symbol *omdef_read_args()
 {
  struct para_symbol *arg_next=0,*arg_list=0;

  next_good_token();
  if (active_stream->tok.typ != TOK_LEFT_ROUND)
   {
    CPPERROR(ACTIVE_TOK,"'(' expected");
    return (0);
   }
  next_good_token();
  while (1)
   {
    arg_next = gobble_arg();
    if (arg_next)
     {
      arg_next->next = arg_list;
      arg_list = arg_next;
     }
    switch (active_stream->tok.typ)
     {
      case ',':
       next_good_token();
       break;
      case ')':
       return (arg_list);
      case TOK_EOF:
       return (arg_list);
      default:
       CPPERROR (ACTIVE_TOK,"',' or ')' expected");
       return (arg_list);
     }
   }
 }


static void omdef_validate(args,ods,tmp_tok)
struct para_symbol *args;
struct om_macro *ods;
struct cpp_token *tmp_tok;
 {
  struct para_symbol *tp,*ta;
  struct para_symbol *f_group;
  int p_id,g_c;

/* if not parametric, take else to easy part */
  if (ods->parametric)
   {

/* initialize specified link or splink */
    tp = ods->para_link;
    while (tp)
     {
      tp->splink = 0;
      tp = tp->next;
     }

/* loop to set up splink pointers in parameters */
    tp = args;
    while (tp)
     {
      ta = (struct para_symbol *)lookup_symbol(ods->para_table,tp->symb.name);
      if (ta)
       {
        if (ta->splink)
         {
          sprintf (msg,"parameter %s specified multiple times",
            tp->symb.name);
          CPPERROR (tmp_tok,msg);
         }
        else
         ta->splink = tp;
       }
      else
       {
        sprintf (msg,"%s is not a parameter of macro %s",
          tp->symb.name,tmp_tok->constr);
        CPPERROR (tmp_tok,msg);
       }
      tp = tp->next;
     }

/* check default/specified parity */
    p_id = -1;
    tp = ods->para_link;
    while (tp)
     {
      if ((tp->para_id != p_id) &&
          ((tp->next == 0)||(tp->next->para_id!=tp->para_id))&&
          (tp->defaults==0)&&
          (tp->splink==0))
       {
        sprintf (msg,"parameter <%s> has neither default or specified value",
           tp->symb.name);
        CPPERROR(tmp_tok,msg);
       }
      p_id = tp->para_id;
      tp = tp->next;
     }

/* check for overdetermination of exclusive or set */
    p_id = -1;
    f_group = 0;
    g_c = 0;
    tp = ods->para_link;
    while (1)
     {
      if ((tp==0)||(tp->para_id != p_id))
       {
        if (p_id != -1)
         {
          if (g_c > 1)
           {
            int first=0;
            strcpy (msg,"parameters ");
            while (1)
             {
              if (f_group->splink)
               {
                first++;
                if (first==g_c) strcat (msg,"and ");
                strcat (msg,"'");
                strcat (msg,f_group->symb.name);
                strcat (msg,"'");
                if (first!=g_c) strcat (msg,", ");
               }
              f_group = f_group->next;
              if (f_group == tp) break;
              if (!f_group) break;
             }
            strcat (msg," cannot ");
            if (g_c > 2) strcat (msg,"all ");
            else strcat (msg,"both ");
            strcat (msg,"be specified.");
            CPPERROR(tmp_tok,msg);
           }
          else if (g_c == 0)
           {
            if (tp!=f_group->next)
             {
              strcpy (msg,ods->symb.name);
              strcat (msg," must have ");
              while (1)
               {
                if (f_group->next == tp) strcat (msg,"or ");
                strcat (msg,"'");
                strcat (msg,f_group->symb.name);
                strcat (msg,"'");
                if (f_group->next != tp) strcat (msg,", ");
                f_group = f_group->next;
                if (f_group == tp) break;
                if (!f_group) break;
               }
              strcat (msg," specified. ");
              CPPERROR(tmp_tok,msg);
             }
           }
         }
        f_group = tp;
        if (tp) p_id = tp->para_id;
        g_c = 0;
       }
      if (tp==0) break;
      if (tp->splink) g_c++;
      tp = tp->next;
     }
   }
  else
   {
    if (args)
     {
      CPPERROR (tmp_tok,"parameters given to a parameter-less macro");
      return;
     }
   }
 }


static struct cpp_token *the_list=0;
static int nest_flag=0;
static struct cpp_token *tp;
#define CPP_DUPE_TOK(A,B) (nest_flag?cpp_dupe_tok(A,A):cpp_dupe_tok(A,B))


static int exe_next_good()
 {
  if (tp) tp = tp->flink;
  while ((tp) && ((tp->typ == TOK_NEW_LINE) || (tp->typ == TOK_NULL)))
   tp = tp->flink;
  if (tp==0)
   {
    CPPERROR((tp),"unexpected end of macro");
    return (1);
   }
  return (0);
 }


static int exe_next()
 {
  if (tp) tp = tp->flink;
  if (tp==0)
   {
    CPPERROR((tp),"unexpected end of macro");
    return (1);
   }
  return (0);
 }


static int compare_token_list (ta,tb)
struct cpp_token *ta,*tb;
 {
  while ((ta)&&(tb))
   {
    if (strcmp(ta->constr,tb->constr)) return (0);
    ta = ta->flink;
    tb = tb->flink;
   }
  return ((!ta)&&(!tb));
 }


static struct cpp_token *read_defstr(tmp_tok)
struct cpp_token *tmp_tok;
 {
  int par_depth=1;
  struct cpp_token *ta=0,*tb=0;

  while (1)
   {
    switch (tp->typ)
     {
      case ')':
       par_depth--;
       if (par_depth) par_depth--;
       else
        {
         tb->flink = 0;
         return (ta);
        }
      case '(':
       par_depth++;
      default :
       if (tb)
        {
         tb->flink = CPP_DUPE_TOK (tp,tmp_tok);
         tb = tb->flink;
        }
       else
        ta = tb = CPP_DUPE_TOK (tp,tmp_tok);
       break;
     }
    if (exe_next()) return (ta);
   }
 }


static void add_to_the_list (t,tmp_tok)
struct cpp_token *t;
struct cpp_token *tmp_tok;
 {
  struct cpp_token *ta;
  if (tmp_tok)
   ta = CPP_DUPE_TOK(t,tmp_tok);
  else
   ta = t;
  ta->flink = the_list;
  the_list = ta;
 }


static void omdef_ex_para(tb,tmp_tok)
struct para_symbol *tb;
struct cpp_token *tmp_tok;
 {
  struct cpp_token *tc;

  if (tb->splink)
   tc = tb->splink->defaults;
  else
   tc = tb->defaults;
  while (tc)
   {
    add_to_the_list (tc,tmp_tok);
    tc = tc->flink;
   }
  tp = tp->flink;
 }


static void omdef_ex_specified (tmp_tok,ods)
struct om_macro *ods;
struct cpp_token *tmp_tok;
 {
  struct cpp_token *l1=0,*l2=0;
  struct para_symbol *tb;
  struct cpp_token *ta;

  l1 = CPP_DUPE_TOK(tp,tmp_tok);
  if (exe_next())
   { free (l1); return; }
  if (tp->typ != TOK_LEFT_ROUND)
   {
    CPPERROR(tp,"'(' expected following om$specified");
   }
  else
   {
    l2 = CPP_DUPE_TOK(tp,tmp_tok);
    if (exe_next())
     { free (l1); free (l2); return; }
   }
  if (tp->typ != TOK_ID)
   {
    CPPERROR(tp,"identifier parameter expected for om$specified");
   }
  else
   {
    tb = (struct para_symbol *)lookup_symbol(ods->para_table,tp->constr);
    if (tb)
     {
      if (tb->splink)
       {
        strcpy (active_stream->yytext,"1");
        active_stream->tok.body.intconst = 1;
       }
      else
       {
        strcpy (active_stream->yytext,"0");
        active_stream->tok.body.intconst = 0;
       }
      active_stream->yylen = strlen(active_stream->yytext);
      active_stream->tok.typ = TOK_INT_CONSTANT;
      active_stream->tok.filename = tmp_tok->filename;
      active_stream->tok.line_no = tmp_tok->line_no;
      active_stream->tok.pol = tmp_tok->pol;
      ta = token_malloc();
      add_to_the_list (ta,(struct cpp_token *)0);
      free (l1);
      free (l2);
     }
    else
     {
      if (nest_flag)
       {
        add_to_the_list (l1,(struct cpp_token *)0);
        add_to_the_list (l2,(struct cpp_token *)0);
        add_to_the_list (tp,tmp_tok);
        if (exe_next()) return;
       }
      else
       {
        free (l1);
        free (l2);
        strcpy (active_stream->yytext,"0");
        active_stream->tok.body.intconst = 0;
        active_stream->yylen = strlen(active_stream->yytext);
        active_stream->tok.typ = TOK_INT_CONSTANT;
        active_stream->tok.filename = tmp_tok->filename;
        active_stream->tok.line_no = tmp_tok->line_no;
        active_stream->tok.pol = tmp_tok->pol;
        ta = token_malloc();
        add_to_the_list (ta,(struct cpp_token *)0);
        sprintf(msg,"%s is not a parameter of an active OM macro",
        tp->constr);
        CPPERROR(tp,msg);
       }
     }
   }
  exe_next();
  if (tp)
   {
    if (tp->typ != ')')
     {
      CPPERROR (tp,"')' missing for om$specified");
     }
    else
     tp = tp->flink;
   }
 }


static void omdef_ex_equal(tmp_tok,ods)
struct cpp_token *tmp_tok;
struct om_macro *ods;
 {
  int i;
  struct cpp_token *omequal=0;
  struct cpp_token *open_paren=0;
  struct cpp_token *eqid=0;
  struct cpp_token *comma=0;
  struct cpp_token *defstr=0;
  struct cpp_token *close_paren=0;
  struct para_symbol *tb;
  struct cpp_token *ta;

  omequal = CPP_DUPE_TOK(tp,tmp_tok);
  if (exe_next())
   {
    free (omequal);
    return;
   }
  if (tp->typ != '(')
   {
    CPPERROR (tp,"'(' missing for om$equal");
   }
  else
   {
    open_paren = CPP_DUPE_TOK(tp,tmp_tok);
    if (exe_next())
     {
      free (omequal);
      free (open_paren);
      return;
     }
   }
  if (tp->typ != TOK_ID)
   {
    CPPERROR (tp,"identifier for om$equal expected");
   }
  else
   {
    eqid = CPP_DUPE_TOK (tp,tmp_tok);
    if (exe_next())
     {
      free (omequal);
      if (open_paren) free(open_paren);
      free(eqid);
      return;
     }
   }
  if (tp->typ != ',')
   {
    CPPERROR (tp,"',' expected for om$equal");
   }
  else
   {
    comma = CPP_DUPE_TOK (tp,tmp_tok);
    if (exe_next())
     {
      free (omequal);
      if (open_paren) free(open_paren);
      if (eqid) free(eqid);
      free (comma);
      return;
     }
   }
  defstr = read_defstr(tmp_tok);
  if (!tp)
   {
    free (omequal);
    if (open_paren) free(open_paren);
    if (eqid) free(eqid);
    if (comma) free (comma);
    while (defstr)
     {
      struct cpp_token *next;
      next = defstr->flink;
      free (defstr);
      defstr = next;
     }
    return;
   }
  if (tp->typ != ')')
   {
    CPPERROR (tp,"')' expected for om$equal");
   }
  else
   {
    close_paren = CPP_DUPE_TOK (tp,tmp_tok);
    tp = tp->flink;
   }

  if (eqid)
   {
    if (!(tb = (struct para_symbol *)lookup_symbol
            (ods->para_table,eqid->constr)))
     {
      if (nest_flag)
       {
        add_to_the_list (omequal,(struct cpp_token *)0);
        if (open_paren) add_to_the_list (open_paren,(struct cpp_token *)0);
        if (eqid) add_to_the_list (eqid,(struct cpp_token *)0);
        if (comma) add_to_the_list (comma,(struct cpp_token *)0);
        while (defstr)
         {
          struct cpp_token *next = defstr->flink;
          add_to_the_list (defstr,(struct cpp_token *)0);
          defstr = next;
         }
        if (close_paren) add_to_the_list (close_paren,(struct cpp_token *)0);
        return;
       }
      else
       {
        free (omequal);
        if (open_paren) free (open_paren);
        if (comma) free (comma);
        while (defstr)
         {
          struct cpp_token *next = defstr->flink;
          free (defstr);
          defstr = next;
         }
        if (close_paren) free (close_paren);
        sprintf (msg,"%s is not a parameter of an active macro",
         eqid->constr);
         CPPERROR (eqid,msg);
        if (eqid) free (eqid);
         return;
       }
     }

    if (tb->splink)
     i = compare_token_list (tb->splink->defaults,defstr);
    else
     i = compare_token_list (tb->defaults,defstr);
    if (i)
     {
      strcpy (active_stream->yytext,"1");
      active_stream->tok.body.intconst = 1;
     }
    else
     {
      strcpy (active_stream->yytext,"0");
      active_stream->tok.body.intconst = 0;
     }
    active_stream->yylen = strlen(active_stream->yytext);
    active_stream->tok.typ = TOK_INT_CONSTANT;
    active_stream->tok.filename = tmp_tok->filename;
    active_stream->tok.line_no = tmp_tok->line_no;
    active_stream->tok.pol = tmp_tok->pol;
    ta = token_malloc();
    add_to_the_list (ta,(struct cpp_token *)0);
   }
  free (omequal);
  if (open_paren) free (open_paren);
  if (eqid) free (eqid);
  if (comma) free (comma);
  while (defstr)
   {
    struct cpp_token *next = defstr->flink;
    free (defstr);
    defstr = next;
   }
  if (close_paren) free (close_paren);
 }
  

static void omdef_ex_omdef_call (ods,tmp_tok)
struct om_macro *ods;
struct cpp_token *tmp_tok;
 {
  int pardepth;
  add_to_the_list (tp,tmp_tok);

  tp = tp->flink;
  while ((tp) && ((tp->typ == TOK_NEW_LINE) || (tp->typ == TOK_NULL)))
   tp = tp->flink;
  if (!tp) return;

  if (tp->typ != '(') return;
  add_to_the_list (tp,tmp_tok);
  if (exe_next_good()) return;
  if (tp->typ == ')')
   {
    add_to_the_list (tp,tmp_tok);
    tp = tp->flink;
    return;
   }
  while (1)
   {
    if (tp->typ == TOK_ID)
     {
      add_to_the_list (tp,tmp_tok);
      if (exe_next_good()) return;
     }
    else
     {
      CPPERROR (tp,"identifier expected");
     }
    if (tp->typ == '=')
     {
      add_to_the_list (tp,tmp_tok);
      if (exe_next()) return;
     }
    else
     {
      CPPERROR (tp,"token '=' expected");
     }
    pardepth = 1;
    while (1)
     {
      if (tp->typ == '(')
       {
        add_to_the_list (tp,tmp_tok);
        if (exe_next()) return;
        pardepth++;
       }
      else if (tp->typ == ')')
       {
        add_to_the_list (tp,tmp_tok);
        pardepth--;
        if (pardepth == 0)
         {
          tp = tp->flink;
          return;
         }
        else
         if (exe_next()) return;
       }
      else if ((tp->typ == ',') && (pardepth == 1))
       {
        add_to_the_list (tp,tmp_tok);
        if (exe_next_good()) return;
        break;
       }
      else if (tp->typ == TOK_ID)
       {
        struct para_symbol *tb;
        if (tb = (struct para_symbol *)lookup_symbol (ods->para_table,tp->constr))
         omdef_ex_para (tb,tmp_tok);
        else
         {
          add_to_the_list (tp,tmp_tok);
          if (exe_next()) return;
         }
       }
      else
       {
        add_to_the_list (tp,tmp_tok);
        if (exe_next()) return;
       }
     }
   }
 }

  
static void omdef_execute (args,ods,tmp_tok)
struct para_symbol *args;
struct om_macro *ods;
struct cpp_token *tmp_tok;
 {
  struct cpp_token *ta;
  struct para_symbol *tb;

  the_list = 0;
  nest_flag = 0;
  tp = ods->def_link;

  while (tp)
   {
    switch (tp->typ)
     {
      case '#':
       add_to_the_list (tp,tmp_tok);
       if (exe_next()) break;
       if (!strcmp(tp->constr,"omdef")) nest_flag++;
       else if (!strcmp(tp->constr,"endomdef")) nest_flag--;
       add_to_the_list (tp,tmp_tok);
       tp = tp->flink;
       break;
      case TOK_ID:
       if (!strcmp(tp->constr,"om$specified"))
        omdef_ex_specified (tmp_tok,ods);
       else if (!strcmp(tp->constr,"om$equal"))
        omdef_ex_equal (tmp_tok,ods);
       else if (tb = (struct para_symbol *)lookup_symbol (ods->para_table,tp->constr))
        omdef_ex_para (tb,tmp_tok);
       else if (tb = (struct para_symbol *)lookup_symbol (active_stream->omdef_table,tp->constr))
        omdef_ex_omdef_call (ods,tmp_tok);
       else
        {
         add_to_the_list (tp,tmp_tok);
         tp = tp->flink;
        }
       break;
      default :
       add_to_the_list (tp,tmp_tok);
       tp = tp->flink;
       break;
     }
   }


  while (tp = the_list)
   {
    the_list = tp->flink;
    luther_unget_tok(tp);
   }

/* freedom */
  while (tb = args)
   {
    args = tb->next;
    free (tb->symb.name);
    while (ta = tb->defaults)
     {
      tb->defaults = ta->flink;
      free (ta);
     }
    free (tb); 
   }
 }
#undef CPP_DUPE_TOK


void cpp_handle_omdef(ods)
struct om_macro *ods;
 {
  struct para_symbol *args;
  struct cpp_token *tmp_tok;

  tmp_tok = token_malloc();

  args = omdef_read_args();
  omdef_validate (args,ods,tmp_tok);
  omdef_execute (args,ods,tmp_tok);

  free (tmp_tok);
 }
