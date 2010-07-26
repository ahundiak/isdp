#include <stddef.h>
#include <symtab.h>
#include <cpp.h>
#include <cppout.h>
#include "identifier.h"
#include "dcltrs.h"
#include "oppmalloc.h"
#include "carriers.h"
#include "../opp/y.tab.h"
#include "../opp/kptype.h"
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "opp.h"
#include <cpperr.h>
#include "oppydefs.h"
#include "class.h"
#include "kutil.h"
#include "lexinput.h"
#include "ptoken.h" /* for struct pnode_token */
#include "fio.h"
#include "lex3.h"
#include "dumpmessage.h"
#include "messbuf.h"

void cpp_init_stream(char *owner);
void cpp_stream_close(void);
void pster_dump_item(struct pnode *tt);
void distribute_type_info(struct Type_Info ti, identifier_ptr dl);

#define TOK(A) ((struct pnode_token *)(A))
#define XTOK(A) (TOK(A)->filename),(TOK(A)->line_no)
#define is_identifier(A) \
(((A)->typ == IDENTIFIER)   || ((A)->typ == CHANNEL_NAME) || \
 ((A)->typ == TYPEDEF_NAME) || ((A)->typ == STRUCT_NAME)  || \
 ((A)->typ == ENUM_TAG)     || ((A)->typ == ENUM_NAME)    || \
 ((A)->typ == VAR_NAME)     || ((A)->typ == UNION_NAME)   || \
 ((A)->typ == CLASS_NAME)   || ((A)->typ == FIELD_NAME)   || \
 ((A)->typ == MESSAGE_NAME))


struct lex_symbol { struct symbol symb; long typ; };
symtab_ptr lex_table=0;
int building_ptree=0;
static char msg[200];
static void typedef_traverse();
static void build_messy();

extern int emit_lines;

static void output_pnode_tok (oppout,ta)
FILE *oppout;
struct pnode_token *ta;
 {
  get_to_line (oppout, ta->line_no, ta->filename);
  PITS (oppout,ta->constr);
  putc (' ',oppout);
 } /* output_pnode_tok */

int new_pnode(int typer, ...)
 {
  va_list args;
  struct pnode *links[20];
  int n_l;
  struct pnode *pn;

  va_start(args, typer);
  n_l=0;
  while ((int)(links[n_l++]=va_arg(args,struct pnode *)) != -1) /* no_op */ ;
  n_l--;
  pn = (struct pnode *)
    malloc (sizeof(struct pnode)+ (n_l * sizeof(struct pnode *)));
  n_l = 0;
  do
   pn->l[n_l] = links[n_l];
  while ((int)links[n_l++] != -1);
  pn->typ = typer;
  return ((int)pn);
 } /* new_pnode */

struct pnode_token *pnode_token_malloc()
 {
  struct pnode_token *tt;

  tt = (struct pnode_token *)
    malloc((int)offsetof(struct pnode_token, constr) + active_stream->yylen + 1);
  tt->typ = active_stream->tok.typ;
  tt->filename = active_stream->tok.filename;
  tt->line_no = active_stream->tok.line_no;
  tt->pol = active_stream->tok.pol;
  strcpy(tt->constr,active_stream->yytext);
  return (tt);
 }


static void free_ident(t)
 identifier_ptr t;
 {
  dcltr_ptr d = t->type_info.dcltr_link;

  while (d && d->index == -1)
   {
    dcltr_ptr p = d->next;
    freedcltr (d);
    d = p;
   }
  free (t);
 } /* free_ident */

static void free_symbol(t)
struct lex_symbol *t;
 {
  /*if (t->typ==TYPEDEF_NAME)*/
   {
    free (t);
   }
 }


void ptree_end()
 {
  delete_symbol_table(lex_table,free_symbol);
 }


void ptree_init()
 {
  lex_table = new_basictab (71,0);
  building_ptree=0;
 }


void ptree_push()
 {
  increment_symbol_level(lex_table);
 }


void ptree_pop()
 {
  decrement_symbol_level(lex_table,free_symbol);
 }


void ptree_work_typedef (pn)
struct pnode *pn;
 {
  typedef_traverse (pn,pn);
 }


static void typedef_traverse(pn,hn)
struct pnode *pn;
struct pnode *hn;
 {
  struct pnode_token *pt;
  struct lex_symbol *ts;
  int index; /* to keep compiler quiet about out of range subscripts */

  if (pn)
   {
    switch (pn->typ)
     {
      case IDENTIFIER :
       pt = (struct pnode_token *) pn;
       ts = (struct lex_symbol *)
	    malloc (sizeof(struct lex_symbol) + strlen(pt->constr) + 1);
       ts->symb.name = strcpy ((char *)(ts+1), pt->constr);
       ts->typ = TYPEDEF_NAME;
       enter_symbol(lex_table,ts);
       break;
      case local_data_declaration :
       {
        struct pnode_local_data_declaration *ldd;
        ldd = (struct pnode_local_data_declaration *)pn;
        typedef_traverse(ldd->dcltr,hn);
        break;
       }
      case typename_declaration :
       {
        struct pnode_typename_declaration *td;
        td = (struct pnode_typename_declaration *)pn;
        typedef_traverse(td->dcltr,hn);
        break;
       }
      case formal_declaration:
       {
        struct pnode_formal_declaration *fd;
        fd = (struct pnode_formal_declaration *)pn;
        typedef_traverse(fd->dcltr,hn);
        break;
       }
      case struct_declaration :
       typedef_traverse(pn->l[index=1],hn);
       break;
      case list_struct_dcltr :
       typedef_traverse(pn->l[0],hn);
       typedef_traverse(pn->l[index=2],hn);
       break;
      case struct_dcltr :
       typedef_traverse(pn->l[0],hn);
       break;
      case p1_dcltr :
       typedef_traverse(pn->l[index=1],hn);
       break;
      case function_dcltr :
       typedef_traverse(pn->l[0],hn);
       break;
      case array_dcltr :
       typedef_traverse(pn->l[0],hn);
       break;
      case pointer_dcltr :
       typedef_traverse(pn->l[index=1],hn);
       break;
      case init_dcltr :
       typedef_traverse(pn->l[0],hn);
       break;
      case list_init_dcltr :
       typedef_traverse(pn->l[0],hn);
       typedef_traverse(pn->l[index=2],hn);
       break;

/* beginning of absolute declarator stuff */

      case p1_abs_dcltr :
       typedef_traverse(pn->l[index=1],hn);
       break;
      case abs_fun_dcltr :
       typedef_traverse(pn->l[0],hn);
       break;
      case abs_array_dcltr :
       typedef_traverse(pn->l[0],hn);
       break;
      case abs_pointer_dcltr :
       typedef_traverse(pn->l[index=1],hn);
       break;

/* end of absolute declarator stuff */

      default :
       fprintf (stderr,"Unknown ptree node :\n");
       pster_dump_item(pn);
       break;
     }
   }
 }


extern void build_messy();

static identifier_ptr message_search (cn,mn)
identifier_ptr cn;
char *mn;
 {
  int i;
  identifier_ptr pmn;

  for(pmn=cn->classdef->messages,i=cn->classdef->message_count;
      i;
      i--,pmn=pmn->link)
    if (!strcmp(pmn->s.s.name,mn)) return (pmn);
  return (0);
 }

static void add_mess_buff(pmb,level)
struct pnode_message_buff *pmb;
int level;
 {
  identifier_ptr cn;
  identifier_ptr mn;
  identifier_ptr dc;
  int buf_index;
  int mn_count=0;
  carrier_ptr comp;

  cn = (identifier_ptr)lookup_symbol (sym_table,pmb->classname->constr);
  if (!cn)
   {
    sprintf (msg,"undeclared class name \"%s\".",pmb->classname->constr);
    OPPERROR (pmb->method,msg);
    return;
   }
  if (cn->s.tok != CLASS_NAME)
   {
    sprintf (msg,"class name required.  \"%s\" is declared otherwise.",
	     pmb->classname->constr);
    OPPERROR (pmb->method,msg);
    return;
   }
#if WEIRD
  increment_symbol_level (sym_table);
#endif
  if (!(cn->classdef))
   {
    sprintf(msg,"symbol \"%s\" is not the name of a class.",
      pmb->classname->constr);
    OPPERROR (pmb->classname,msg);
    return;
   }

  comp = cn->classdef->component_list;
  if (mn = message_search (cn,pmb->method->constr))
   mn_count = 1;
  else
   {
    mn_count = 0;
    while (comp)
     {
      if (!mn_count)
       {
        mn = message_search (comp->cargo,pmb->method->constr);
        if (mn) mn_count++;
       }
      else
       {
        if (message_search (comp->cargo,pmb->method->constr)) mn_count++;
       }
      comp = comp->next;
     }
   }

  if (!(mn))
   {
    sprintf (msg,"undeclared message name \"%s\".",pmb->method->constr);
    OPPERROR (pmb->method,msg);
    return;
   }
  if (!(dc = (identifier_ptr)lookup_symbol (mn->classdef->sym_tab, mn->classdef->name)))
   {
    sprintf (msg,"message \"%s\" not found in class \"%s\".",
      pmb->method->constr,pmb->classname->constr);
    OPPERROR (pmb->method,msg);
    return;
   }
  if (mn_count > 1) 
   {
    sprintf (msg,
     "message %s declared %d times.\n - defaulting to message %s.%s",
     mn->s.s.name,
     mn_count,
     dc->s.s.name,
     mn->s.s.name);
    OPPERROR (pmb->method,msg);
   }
  buf_index = new_message_buffer (level,dc,mn,0);
  pmb->bag = (struct message_bag *) malloc (sizeof(struct message_bag));
  pmb->bag->typ = NULL_TOKEN;
  pmb->bag->buf_i = buf_index;
  pmb->bag->bdc = dc;
  pmb->bag->bmn = mn;
  pmb->bag->bcn = cn;
 }


identifier_ptr field_search(class,field)
identifier_ptr class;
struct pnode_token *field;
/*
 *   field_search searches a particular class for a field.
 *   If its there it returns a pointer to the field symbol.
 *   Otherwize it returns a null pointer.
 */
 {
  identifier_ptr t;

  for (t = class->classdef->instance_fields; t; t = t->link)
   if (!strcmp(t->s.s.name,field->constr))
    {
     if (t->type_info.private_attribute &&
	 strcmp (t->classdef->name, active_class->name))
      {
       char msg[80];
       sprintf (msg,"instance field \"%s.%s\" is private.",
                t->classdef->name, t->s.s.name);
       OPPWARN (field, msg);
      }
     return t;
    }
  return 0;
 } /* field_search */

static fs_retval class_field_search_recurse (class, field)
 carrier_ptr class;
 struct pnode_token *field;
 { /* this function insures that the most recent declaration of the
      instance field will be found. */
  fs_retval retval;

  retval.id_ptr = 0;
  retval.fld_ptr = 0;

  if (!class) return retval;

  retval = class_field_search_recurse (class->next, field);
  if (retval.fld_ptr) return retval;

  if (retval.fld_ptr = field_search(class->cargo,field))
   {
    retval.id_ptr = class->cargo;
    return retval;
   }

  return retval;
 } /* class_field_search_recurse */

static fs_retval class_field_search(class,field)
struct opp_class_def *class;
struct pnode_token *field;
/*
 *   given a base class and a field,  class_field_search searches
 *   through the parentage of a class for the matching field.  Upon
 *   completion the field symbol and cooresponding class are returned.
 */
 {
  return class_field_search_recurse (class->component_list, field);
 } /* class_field_search */


static identifier_ptr class_search (class,b)
struct opp_class_def *class;
identifier_ptr b;
/*
 *  class search searches through the parent hirarchy to see
 *  if b is a component of class.
 */
 {
  carrier_ptr t;

  for (t = class->component_list; t; t=t->next)
   {
    if (!strcmp(t->cargo->s.s.name,b->s.s.name))
     {
      return (t->cargo);
     }
   }
  return (0);
 }

/* ARGSUSED */
static void messy_instance (p,level)
struct pnode_inst_access_exp *p;
int level;
 {
  fs_retval cc;
#ifdef DEBUG
  printf ("messy_instance - active_class = %s %x\n",
	  active_class->name, active_class);
#endif

  if (!(p->classname))
   {
    cc = class_field_search (active_class,p->fieldname);
    if (!(cc.id_ptr))
     {
      sprintf (msg,"invalid instance field \"%s\".",p->fieldname->constr);
      OPPERROR (p->fieldname,msg);
      return;
     }
   }
  else
   {
    identifier_ptr b = (identifier_ptr)lookup_symbol (sym_table,p->classname->constr);
    if (!b)
     {
      OPPERROR (p->classname,"invalid class name");
      return;
     }
    cc.id_ptr = class_search (active_class,b);
    if (!(cc.id_ptr))
     {
      sprintf (msg,"class \"%s\" is not is not a component of class \"%s\".",
        b->s.s.name,active_class->name);
      OPPERROR (p->classname,msg);
      return;
     }
    if (p->fieldname)
     {
      cc.fld_ptr = field_search (cc.id_ptr, p->fieldname);
      if (!(cc.fld_ptr))
       {
        sprintf (msg,"field \"%s\" is not a field in class \"%s\".",
          p->fieldname->constr,p->classname->constr);
        OPPERROR (p->fieldname,msg);
        return;
       }
     }
    else
     cc.fld_ptr = 0;
   }
  p->bag = (struct iae_bag *)malloc(sizeof(struct iae_bag));
  p->bag->typ = NULL_TOKEN;
  p->bag->data = cc;
  cc.id_ptr->flags |= F_IDENTIFIER_MARKED;
#ifdef DEBUG
  printf (" marking %s %x\n", cc.id_ptr->s.s.name, cc.id_ptr);
#endif

#ifdef SFAN
   sfan_add_instance_access(cc.id_ptr->s.s.name);
#endif

 } /* messy_instance */


static void messy_buffer (pmb,level)
struct pnode_message_buff *pmb;
int level;
 {
  add_mess_buff (pmb,level);
  build_messy(pmb->list_express,level+1);
 }


static void build_messy(p,level)
struct pnode *p;
int level;
 {
  if (!p) return;
  if (p->typ <= 512) return;

  switch (p->typ)
   {
    case message_buff : messy_buffer((struct pnode_message_buff *)p,level); break;
    case inst_access_exp : messy_instance((struct pnode_inst_access_exp *)p,level); break;
    default :
     {
      int i=0;
      while ((int)(p->l[i]) != (-1))
       {
        build_messy(p->l[i],level);
        i++;
       }
     }
     break;
   }
  return;
 }


extern struct Type_Info gen_typeinfo ();
extern identifier_ptr gen_dcltr_list ();
extern void output_node(); 			/* forward */


static void add_to_symtab (dl)
identifier_ptr dl;
 {
  identifier_ptr next;

  while (dl)
   {
    next = dl->link; dl->link = NULL;
    if (dl->type_info.std_class == typedef_class)
     dl->s.tok = TYPEDEF_NAME;
    else
     dl->s.tok = VAR_NAME;
    enter_symbol (sym_table,dl);
    dl = next;
   }
 }


static void preout_ldd (pldd)
struct pnode_local_data_declaration *pldd;
 {
  struct Type_Info ti;
  identifier_ptr dl;

  ti = gen_typeinfo((struct pnode_decl_specifier *)pldd->specifier);
  dl = gen_dcltr_list((struct pnode_list_init_dcltr *)pldd->dcltr);
  distribute_type_info (ti,dl);
  add_to_symtab (dl);
 }


static void preout_declarations (podl)
struct pnode_opt_decl_list *podl;
 {
  if (!podl) return;
  preout_declarations (podl->podl);
  if (podl->pldd && SAFEBLOCK != podl->pldd->typ)
   preout_ldd (podl->pldd);
 }


static void output_generic_node (p)
struct pnode *p;
 {
  int i=0;
  if (p->typ < 512) /* p is a token */
   {
    if (p->typ != NULL_TOKEN) output_pnode_tok (oppout,(struct pnode_token *)p);
   }
  else /* p is a parse tree node */
   while (((int)(p->l[i])) != (-1)) output_node (p->l[i++]);
 }

static void free_tag (p)
 identifier_ptr p;
 {
  if (p->s.tok == STRUCT_NAME || p->s.tok == UNION_NAME)
   while (p->field_link)
    {
     identifier_ptr q = p->field_link->link;
     free_ident (p->field_link);
     p->field_link = q;
    }
  free (p);
 } /* free_tag */

static void output_compound(pcs)
struct pnode_compound_stmt *pcs;
 {
#ifdef DEBUG
  pster_dump_ptree(pcs);
  return;
#endif
  output_node ((struct pnode *)pcs->open_squirly);
  increment_symbol_level (sym_table);
  increment_symbol_level (tag_table);
  preout_declarations ((struct pnode_opt_decl_list *)pcs->declarations); /* entering stuff in the symtab */
  output_node (pcs->declarations);
  output_node (pcs->stmts);
  decrement_symbol_level (sym_table,free_ident);
  decrement_symbol_level (tag_table,free_tag);
  output_node ((struct pnode *)pcs->close_squirly);
 }


static void traverse_arglist (prefix,mess,p,m)
char * prefix;
struct pnode_token *mess;
struct pnode **p;
identifier_ptr m;
 {
  struct pnode *lp;

   { /* reverse the fields in the expression */
    struct pnode *t1=0;
    struct pnode *t2=0;
    while (*p)
     {
      t2 = (*p)->l[0];
      (*p)->l[0] = t1;
      t1 = *p;
      *p = t2;
     }
    lp = *p = t1;
   }
  while (1)
   {
    if (m==0) break;
    if (lp==0) break;
    if (lp->typ == list_exp)
     {
      int index; /* to keep compiler quiet about out of range subscript */

      fdumpitf (oppout," %s%s = ",prefix, m->s.s.name);
      output_node (lp->l[index=2]);
      fdumpitf (oppout,",\n");
     }
    lp = lp->l[0];
    m = m->link;
   }
  if (lp)
   {
    OPPERROR (mess,"too many parameters for this message");
   }
  if (m)
   {
    OPPERROR (mess,"not enough parameters for this message");
   }
  return;
 }

void pp_string (string)
 char *string;
 {
  int tok;
  fio_open_string (string);
  while ((tok = yylex()) != END)
   fprintf (oppout, "%s ", active_stream->yytext);
 } /* pp_string */

void pp_fprintf (FILE *oppout, char *format, ...)
 {
  va_list args;
  int tok;
  char string[4096];
  void *created_stream = 0;

  va_start(args, format);
  vsprintf(string, format, args);
  strcat(string, " end");
  if (!active_stream)
   {
    cpp_init_stream(NULL);
    created_stream = active_stream->define_table; /* save to restore later */
    active_stream->define_table = active_class->define_tab;
   }
  fio_open_string (string);
  while ((tok = yylex()) != END)
   fprintf (oppout, "%s ", active_stream->yytext);
  if (created_stream)
   {
    /* need to restore old symbol table because stream close will delete it */
    active_stream->define_table = created_stream;
    created_stream = 0;
    cpp_stream_close();
   }
 } /* pp_fprintf */

static void output_message_buff(p)
struct pnode_message_buff *p;
 {
  identifier_ptr mclass;
  int buf_index;
  identifier_ptr dclass;
  identifier_ptr msg;
  char prefix[80];

  if (!p->bag) return;
  buf_index = p->bag->buf_i;
  dclass = p->bag->bdc;
  mclass = p->bag->bcn;
  msg = p->bag->bmn;

  rdumpitf (XTOK(p->message),oppout,"(");
  
  sprintf (prefix,"OPPsb%d.",buf_index);
  traverse_arglist (prefix,p->message,&p->list_express,msg->field_link);
  if (msg->field_link)
   {
    fdumpitf (oppout," OPPmsg%d.size = sizeof(struct %s_%s_Msg),\n",
        buf_index, dclass->s.s.name, msg->s.s.name);
    fdumpitf (oppout," OPPmsg%d.p_arglist = (char *) &OPPsb%d,\n", buf_index,
        buf_index);
   }
  else
   {
    fdumpitf (oppout," OPPmsg%d.size = 0,\n OPPmsg%d.p_arglist = 0,\n",
        buf_index, buf_index);
   }

  {
   char string[128];
   fdumpitf (oppout, " OPPmsg%d.select.FuncIndex=", buf_index);
   sprintf (string, "%s_OPP_%s_method_index end", dclass->s.s.name,msg->s.s.name);
   pp_string (string); fdumpitf (oppout, ",\n");
  }

  if (!strcmp (dclass->s.s.name, mclass->s.s.name))
   {
    char string[128];
    fdumpitf (oppout, " OPPmsg%d.select.DefClassid=OPPmsg%d.select.ReqClassid = ", 
              buf_index, buf_index);
    sprintf (string, "OPP_%s_class_id end", dclass->s.s.name);
    pp_string (string); fdumpitf (oppout, ",\n");
   }
  else
   {
    char string[128];
    fdumpitf (oppout," OPPmsg%d.select.DefClassid=", buf_index);
    sprintf (string, "OPP_%s_class_id end", dclass->s.s.name);
    pp_string (string); fdumpitf (oppout, ",\n");

    fdumpitf (oppout," OPPmsg%d.select.ReqClassid=", buf_index);
    sprintf (string, "OPP_%s_class_id end", mclass->s.s.name);
    pp_string (string); fdumpitf (oppout, ",\n");
   }
  fdumpitf (oppout," &OPPmsg%d)\n", buf_index);
 }

static void output_inst_access_exp(iae)
struct pnode_inst_access_exp *iae;
 {
/* if the bag is missing then this was an invalid expression so do nothing */
  if (!(iae->bag))
   {
    rdumpitf (XTOK(iae->me_tok),oppout," hiccup ");
    return;
   }
  if (!iae->bag->data.id_ptr)
   {
    rdumpitf (XTOK(iae->me_tok),oppout," sputter ");
    return;
   }
  if (!iae->bag->data.fld_ptr)
   {
    output_generic_node ((struct pnode *)iae->me_tok);
    output_generic_node ((struct pnode *)iae->dot_tok);
    output_generic_node ((struct pnode *)iae->classname);
    return;
   }

  if (iae->bag->data.fld_ptr->type_info.dcltr_link)
   {
    if (iae->bag->data.fld_ptr->type_info.dcltr_link->type == dt_varray)
     {
      /* variable length array */
      struct identifier_symbol tid;
      rdumpitf (XTOK(iae->me_tok),oppout," ((");
      tid = *(iae->bag->data.fld_ptr);
      tid.type_info.std_class = noclass;
      tid.type_info.dcltr_link = tid.type_info.dcltr_link->next;
      tid.s.s.name = "(*)";
      cur_out_line += dump_arg (oppout,&tid);
      rdumpitf (XTOK(iae->me_tok),oppout, ")((ME.%s->%s_descr.i_offset)))",
        iae->bag->data.id_ptr->s.s.name, iae->bag->data.fld_ptr->s.s.name);
      return;
     }
   }

  rdumpitf (XTOK(iae->me_tok),oppout,"ME.%s->%s",
   iae->bag->data.id_ptr->s.s.name,
   iae->bag->data.fld_ptr->s.s.name);
  return;
 } /* output_inst_access_exp */


static void output_inst_specifier (ps)
struct pnode_instance_specifier *ps;
 {
  rdumpitf (XTOK(ps->Instance),
   oppout,"struct %s_total_instance ",ps->tag->constr);
 }


static void dump_vla_access (t,instance_name,class_name,field_name)
struct pnode_token *t;
identifier_ptr instance_name,class_name,field_name;
 {
  struct identifier_symbol tid;
  rdumpitf (XTOK(t),oppout," ((");
  tid = *field_name;
  tid.type_info.std_class = noclass;
  tid.type_info.dcltr_link = tid.type_info.dcltr_link->next;
  tid.s.s.name="(*)";
  cur_out_line += dump_arg (oppout,&tid);
  rdumpitf (XTOK(t),oppout, ")(%s->%s.%s_descr.i_offset))",
   instance_name->s.s.name, class_name->s.s.name, field_name->s.s.name);
  return;
 }


static void output_struct_pointer_access (pspa)
struct pnode_struct_pointer_access *pspa;
 {
  struct pnode_token *ltok;
  identifier_ptr linst,cls1;
  fs_retval info;

  if (!is_identifier(pspa->p2))
   { output_generic_node ((struct pnode *)pspa); return; }
  ltok = (struct pnode_token *)pspa->p2;
  linst = (identifier_ptr)lookup_symbol (sym_table,ltok->constr);
  if (!linst)
   { output_generic_node ((struct pnode *)pspa); return; }
  if (!(linst->type_info.type_link))
   { output_generic_node ((struct pnode *)pspa); return; }
  cls1 = linst->type_info.type_link;
  if (cls1->s.tok != CLASS_NAME)
   { output_generic_node ((struct pnode *)pspa); return; }
  info = class_field_search (cls1->classdef,pspa->field_name);
  if (!(info.id_ptr))
   {
    sprintf (msg,"field %s not found in instance %s.",
      pspa->field_name->constr, ltok->constr);
    OPPERROR (pspa->field_name,msg);
    output_generic_node ((struct pnode *)pspa);
    return;
   }
  if ((info.fld_ptr->type_info.dcltr_link) &&
      (info.fld_ptr->type_info.dcltr_link->type == dt_varray))
   {
    dump_vla_access (pspa->pointer,linst,info.id_ptr,info.fld_ptr);
    return;
   }
  output_generic_node (pspa->p2);
  output_generic_node ((struct pnode *)pspa->pointer);
  rdumpitf (XTOK(pspa->field_name),oppout,"%s.",info.id_ptr->s.s.name);
  output_generic_node ((struct pnode *)pspa->field_name);
  return;
 }


static void verify_instance_access (pspa,inst,cls_nm)
struct pnode_struct_pointer_access *pspa;
identifier_ptr *inst;
identifier_ptr *cls_nm;
 {
  struct pnode_token *ltok;
  identifier_ptr linst,cls1,cls2,cls3;

  *inst = 0;
  *cls_nm = 0;
  if (!pspa) return;
  if (pspa->typ != struct_pointer_access) return;
  if (!is_identifier(pspa->p2)) return;
  ltok = (struct pnode_token *)pspa->p2;
  linst = (identifier_ptr)lookup_symbol (sym_table,ltok->constr);
  if (!linst) return;
  if (!(linst->type_info.type_link)) return;
  cls1 = linst->type_info.type_link;
  if (cls1->s.tok != CLASS_NAME) return;
  cls2 = (identifier_ptr)lookup_symbol (sym_table,pspa->field_name->constr);
  if (!cls2) return;
  cls3 = class_search (cls1->classdef,cls2);
  if (!cls3) return;
  *inst = linst;
  *cls_nm = cls3;
  return;
 }


static void output_struct_access (psa)
struct pnode_struct_access *psa;
 {
  identifier_ptr instance_name=0,class_name=0,field_name=0;

  verify_instance_access ((struct pnode_struct_pointer_access *)psa->p2,&instance_name,&class_name);
  if (!instance_name)
   { output_generic_node ((struct pnode *)psa); return; }
  field_name = field_search(class_name,psa->field_name);
  if (!field_name)
   {
    sprintf (msg,"field %s not found in class %s.",
      psa->field_name->constr, class_name->s.s.name);
    OPPERROR (psa->field_name,msg);
    output_generic_node ((struct pnode *)psa);
    return;
   }
  if ((field_name->type_info.dcltr_link) &&
      (field_name->type_info.dcltr_link->type == dt_varray))
   {
    dump_vla_access (psa->dot,instance_name,class_name,field_name);
    return;
   }
   {
    struct pnode_struct_pointer_access *pspa;
    pspa = (struct pnode_struct_pointer_access *)(psa->p2);
    output_generic_node (pspa->p2);
    output_generic_node ((struct pnode *)pspa->pointer);
    output_generic_node ((struct pnode *)pspa->field_name);
    output_generic_node ((struct pnode *)psa->dot);
    output_generic_node ((struct pnode *)psa->field_name);
   }
  return;
 }


void output_node(p)
struct pnode *p;
 {
  /* p can be null, a token, or a parse tree node at this point. */
  if (!p) return;
  switch (p->typ)
   {
    default:
     output_generic_node (p);
     return;
    case message_buff :
     output_message_buff((struct pnode_message_buff *)p);
     return;
    case inst_access_exp :
     output_inst_access_exp((struct pnode_inst_access_exp *)p);
     return;
    case instance_specifier :
     output_inst_specifier ((struct pnode_instance_specifier *)p);
     return;
    case struct_access :
     output_struct_access ((struct pnode_struct_access *)p);
     return;
    case struct_pointer_access :
     output_struct_pointer_access ((struct pnode_struct_pointer_access *)p);
     return;
    case compound_stmt :
     output_compound ((struct pnode_compound_stmt *)p);
     return;
   }
 }


void free_tree(p)
struct pnode *p;
 {
  /* p can be null, a token, or a parse tree node at this point. */
  if (!p) return;
  if (p->typ >= 512) /* p is a parse tree node */
   {
    int i=0;
    while (((int)(p->l[i])) != (-1))
     free_tree (p->l[i++]);
   }
  free (p);
 }

int	find_inline_send(p)
struct pnode_bin_exp	*p;
{
	int	ret = 0;
	int	index; /* to keep compiler quiet about out of range subscripts */

   	if ('=' == p->operator->typ && IDENTIFIER == p->expr1->typ)
	{
		struct pnode_token	*id = (struct pnode_token *)p->expr1;

		if (	id->constr[0] && 'O' == id->constr[0] &&
			id->constr[index=1] && 'P' == id->constr[index=1] &&
			id->constr[index=2] && 'P' == id->constr[index=2] &&
			id->constr[index=3] && 'p' == id->constr[index=3] &&
			id->constr[index=4] && '_' == id->constr[index=4] &&
			id->constr[index=5] && 'm' == id->constr[index=5] &&
			id->constr[index=6] && 's' == id->constr[index=6] &&
			id->constr[index=7] && 'g' == id->constr[index=7] &&
			!id->constr[index=8])
		{
			ret = 1;
		}
	}
	return ret;
}

void ptree_meth_body(p,msg,methargs,inline_send)
struct pnode *p;
identifier_ptr *msg,*methargs;
int inline_send;
 {
  build_messy (p,0);
  if (msg)
   {
    write_method_header (*msg,*methargs,inline_send);
    fdumpitf (oppout,"  {\n");
   }
  cur_out_line += generate_message_buffers (oppout);
  output_node(p);
  cur_out_line += remove_message_buffers(oppout);
  if (msg)
   {
    fdumpitf (oppout,"  }\n");
    fdumpitf (oppout,"}\n");
   }
  free_tree(p);
  fflush(oppout);
 }


struct pnode *sdb_pnode;
struct pnode_token *sdb_tok;
identifier_ptr sdb_id;
struct opp_class_def *sdb_cd;
