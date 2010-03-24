
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* kgti.c - ??????							*/
/*									*/
/* Object PreProcessor - opp						*/
/* Cameron Stubbs							*/
/* September 1986							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <symtab.h>
#include <cpp.h>
#include <cpperr.h>
#include "typeinfo.h"
#include "carriers.h"
#include "../opp/y.tab.h"
#include "../opp/kptype.h"
#include "kutil.h"
#include "dcltrs.h"
#include "lexinput.h"
#include "oppydefs.h"
#include "ptoken.h" /* for struct pnode_token */
#include "fio.h"

int evaluate_ptree_exp(struct pnode *pe);
void distribute_type_info(struct Type_Info ti, identifier_ptr dl);

extern struct Type_Info gen_typeinfo ();	/* forward */
static char msg[YYTEXT_SIZE];


static identifier_ptr get_dcltr (pd)
struct pnode *pd;
 {
  identifier_ptr d_id;
  switch (pd->typ)
   {
    case VAR_NAME :
    case CLASS_NAME :
    case MESSAGE_NAME :
    case CHANNEL_NAME :
    case STRUCT_NAME :
    case UNION_NAME :
    case ENUM_NAME :
    case ENUM_TAG :
    case FIELD_NAME :
    case IDENTIFIER :
     {
      struct pnode_token *dcl;
      dcl = (struct pnode_token *)pd;
      d_id = new_identifier (dcl->constr);
      d_id->type_info.dcltr_link = 0;
      return (d_id);
     }
    case CONST:
    case VOLATILE:
      d_id = (identifier_ptr)lookup_local_symbol (sym_table,"");
      if (!d_id)
       d_id = new_identifier ("");
      return d_id;
    case pointer_dcltr :
     d_id = get_dcltr (((struct pnode_pointer_dcltr *)(pd))->dcl);
     return (d_id);
    case array_dcltr :
     {
      int i=0;
      d_id = get_dcltr (((struct pnode_array_dcltr *)(pd))->dcl);
      if (((struct pnode_array_dcltr *)(pd))->expr != 0)
       i = evaluate_ptree_exp (((struct pnode_array_dcltr *)(pd))->expr);
      return (d_id);
     }
    case function_dcltr :
     d_id = get_dcltr (((struct pnode_function_dcltr *)(pd))->dcl);
     return (d_id);
    case p1_dcltr :
     return (get_dcltr(((struct pnode_p1_dcltr *)(pd))->dcl));
    default:
     fprintf (stderr,"OPP ptree traversal error <%d>\n",pd->typ); 
     d_id = new_identifier ("");
     return (d_id);
   }
 }


static identifier_ptr get_struct_dcltr (psd)
struct pnode_struct_dcltr *psd;
 {
  identifier_ptr dl;
  int i;

  dl = get_dcltr (psd->pd);
  if (psd->expr)
    i = evaluate_ptree_exp (psd->expr);
/*
  dl->type_info.dcltr_link =
    append_bitfield_dcltr (dl->type_info.dcltr_link,i);
*/
  return (dl);
 }


static identifier_ptr get_l_struct_dcltr(plsd)
struct pnode_list_struct_dcltr *plsd;
 {
  identifier_ptr dl1,dl2,dl3;

  if (plsd == 0) return (0);
  if (plsd->typ == struct_dcltr)
   {
    dl1 = 0;
    dl2 = get_struct_dcltr ((struct pnode_struct_dcltr *)plsd);
   }
  else
   {
    dl1 = get_l_struct_dcltr (plsd->plsd);
    dl2 = get_struct_dcltr (plsd->psd);
   }
  dl2->link = 0;
  if (dl1)
   {
    dl3 = dl1;
    while (dl3->link) dl3 = dl3->link;
    dl3->link = dl2;
    return (dl1);
   }
  return (dl2);
 }


static identifier_ptr get_struct_decl (psd)
struct pnode_struct_declaration *psd;
 {
  struct Type_Info ti;
  identifier_ptr dl;

  ti = gen_typeinfo (psd->pds);
  dl = get_l_struct_dcltr (psd->plsdcltr);
  distribute_type_info (ti,dl);
  return (dl);
 }


static identifier_ptr get_struct_fields (plsd)
struct pnode_list_struct_declaration *plsd;
 {
  identifier_ptr dl1,dl2,dl3;

  if (plsd == 0) return (0);
  dl1 = get_struct_fields (plsd->plsd);
  dl2 = get_struct_decl (plsd->struct_decl);
  if (dl1)
   {
    dl3 = dl1;
    while (dl3->link) dl3 = dl3->link;
    dl3->link = dl2;
    return (dl1);
   }
  return (dl2);
 }


static struct Type_Info get_struct_typeinfo (pss)
struct pnode_struct_specifier *pss;
 {
  identifier_ptr tag_id;
  struct Type_Info rv;

  rv = empty_type;
  if (pss->open_squirly)
   {
    if (pss->tag)
     {
      tag_id = (identifier_ptr)lookup_local_symbol (tag_table,pss->tag->constr);
      if (tag_id)
       {
        sprintf (msg,"redeclaration of %s-tag %s",
         pss->struct_tok->constr,pss->tag->constr);
        OPPERROR (pss->tag,msg);
       }
      tag_id = new_identifier (pss->tag->constr);
      enter_symbol (tag_table,tag_id);
     }
    else
     {
      tag_id = new_phantom_identifier (active_class);
      enter_symbol (tag_table,tag_id);
     }
    tag_id->field_link = get_struct_fields ((struct pnode_list_struct_declaration *)pss->field_list);
    tag_id->s.tok = (pss->struct_tok->typ == UNION) ? UNION_NAME : STRUCT_NAME;
    rv.type_link = tag_id;
    return (rv);
   }
  else
   {
    if (pss->tag)
     {
      tag_id = (identifier_ptr)lookup_symbol (tag_table,pss->tag->constr);
      if (tag_id)
       {
        if (((tag_id->s.tok==STRUCT_NAME)&&(pss->struct_tok->typ!=STRUCT))
          ||((tag_id->s.tok==UNION_NAME)&&(pss->struct_tok->typ!=UNION)))
         {
          sprintf (msg,"struct/union tag missmatch on '%s'",
            pss->tag->constr);
          printf ("%d,%d\n",tag_id->s.tok,pss->struct_tok->typ);
          OPPERROR (pss->tag,msg);
         }
        rv.type_link = tag_id;
        return (rv);
       }
      sprintf (msg,"Declaration of %s tag %s with no field list",
        pss->struct_tok->constr,pss->tag->constr);
      OPPWARN (pss->tag,msg);
      tag_id = new_identifier (pss->tag->constr);
      enter_symbol (tag_table,tag_id);
     }
    else
     {
      OPPERROR (pss->struct_tok,
       "Struct declaration without tag or field list");
      tag_id = new_phantom_identifier (active_class);
      enter_symbol (tag_table,tag_id);
     }
    tag_id->field_link = 0;
    tag_id->s.tok = ((pss->struct_tok->typ == UNION) ?UNION_NAME :STRUCT_NAME);
    rv.type_link = tag_id;
    return (rv);
   }
 }


static identifier_ptr get_enum_dcltr (ped,not_set)
struct pnode_enum_dcltr *ped;
int *not_set;
 {
  identifier_ptr e_id;

  *not_set = 1;
  e_id = (identifier_ptr)lookup_local_symbol (sym_table,ped->id->constr);
  if (e_id)
   {
    sprintf (msg,"redeclaration of %s as an enumeration name.",
     ped->id->constr);
    OPPERROR (ped->id,msg);
   }
  e_id = new_identifier (ped->id->constr);
  e_id->index = 0;
  e_id->type_info = empty_type;
  e_id->s.tok = ENUM_NAME;
  if (ped->expr) 
   {
    *not_set = 0;
    e_id->index = evaluate_ptree_exp (ped->expr);
   }
  enter_symbol (sym_table,e_id);
  return (e_id);
 }


static identifier_ptr generate_enum_list (pedl)
struct pnode_enum_dcltr_list *pedl;
 {
  identifier_ptr edl_end,edl;
  identifier_ptr next;
  int not_set;

  if (pedl == 0) return (0);
  if (pedl->typ == enum_dcltr)
   { return (get_enum_dcltr ((struct pnode_enum_dcltr *)pedl,&not_set)); }
  edl_end = edl = generate_enum_list (pedl->pedl);
  if (edl)
   { while (edl_end->link) edl_end = edl_end->link; }
  next = get_enum_dcltr (pedl->ped,&not_set);
  if (next == 0) return (edl);
  if (not_set)
   {
    if (edl_end) next->index = edl_end->index + 1;
    else next->index = 0;
   }
  if (edl_end)
   {
    edl_end->link = next;
    return (edl);
   }
  return (next);
 }


static struct Type_Info get_enum_typeinfo (pes)
struct pnode_enum_specifier *pes;
 {
  struct Type_Info rv;
  identifier_ptr e_id;

  rv = empty_type;
  if (pes->bod)
   {
    if (pes->tag)
     {
      e_id = (identifier_ptr)lookup_local_symbol (tag_table,pes->tag->constr);
      if (e_id)
       {
        sprintf (msg,"redeclaration of %s as enumeration tag.",
          pes->tag->constr);
        OPPERROR (pes->tag,msg);
       }
      e_id = new_identifier (pes->tag->constr);
      enter_symbol (tag_table,e_id);
     }
    else
     {
      e_id = new_phantom_identifier (active_class);
      enter_symbol (tag_table,e_id);
     }
    e_id->field_link = generate_enum_list (pes->bod->pedl);
    e_id->s.tok = ENUM_TAG;
    setlisttype (e_id->field_link,empty_type,ENUM_NAME);
    rv.type_link = e_id;
    return (rv);
   }
  if (!(pes->tag))
   {
    OPPERROR (pes->Enum,"enumeration tag missing.");
    return (rv);
   }
  e_id = (identifier_ptr)lookup_symbol (tag_table,pes->tag->constr);
  if (!e_id)
   {
    sprintf (msg,"undeclared tag %s.",pes->tag->constr);
    OPPERROR (pes->Enum,msg);
    return (rv);
   }
  rv.type_link = e_id;
  return (rv);
 }


static struct Type_Info get_inst_typeinfo (ps)
struct pnode_instance_specifier *ps;
 {
  identifier_ptr i_id;
  struct Type_Info rv;

  rv = empty_type;
  i_id = (identifier_ptr)lookup_symbol (sym_table,ps->tag->constr);
  if (!i_id)
   {
    sprintf (msg,"Undeclared symbol: %s;  expected class name."
        ,ps->tag->constr);
    OPPERROR (ps->tag,msg);
    return (rv);
   }
  if (i_id->s.tok != CLASS_NAME)
   {
    sprintf (msg,"Unknown class %s.",ps->tag->constr);
    OPPERROR (ps->tag,msg);
    return (rv);
   }
  rv.type_link = i_id;
  return (rv);
 }


struct Type_Info gen_typeinfo (pds)
struct pnode_decl_specifier *pds;
 {
  struct Type_Info rv;

  rv = empty_type;
  if (!pds) return (empty_type);
  switch (pds->typ)
   {
    case decl_specifier:
     return (merge_type_info(gen_typeinfo(pds->decl_spec),
                             gen_typeinfo((struct pnode_decl_specifier *)pds->tc_spec), 1));
    case AUTO: rv.std_class = auto_class; return (rv);
    case STATIC: rv.std_class = static_class; return (rv);
    case EXTERN: rv.std_class = extern_class; return (rv);
    case REGISTER: rv.std_class = register_class; return (rv);
    case TYPEDEF: rv.std_class = typedef_class; return (rv);
    case CHAR: rv.std_type = char_type; return (rv);
    case INT: rv.std_type = int_type; return (rv);
    case VOID: rv.std_type = void_type; return (rv);
    case FLOAT: rv.std_type = float_type; return (rv);
    case DOUBLE: rv.std_size = long_size; rv.std_type = char_type; return (rv);
    case LONG: rv.std_size = long_size; return (rv);
    case SHORT: rv.std_size = short_size; return (rv);
    case UNSIGNED: rv.unsigned_attribute = 1; return (rv);
    case SIGNED: rv.signed_attribute = 1; return (rv);
    case CONST: rv.const_attribute = 1; return (rv);
    case VOLATILE: rv.volatile_attribute = 1; return (rv);
    case TYPEDEF_NAME:
     {
      identifier_ptr d_id;
      d_id = (identifier_ptr)lookup_symbol (sym_table,((struct pnode_token *)pds)->constr);
      rv = d_id->type_info;
      rv.std_class = noclass;
      return (rv);
     }

    case struct_specifier:
    case union_specifier:
     return (get_struct_typeinfo((struct pnode_struct_specifier *)pds));

    case enum_specifier:
     return (get_enum_typeinfo((struct pnode_enum_specifier *)pds));

    case instance_specifier:
     return(get_inst_typeinfo((struct pnode_instance_specifier *)pds));

    default:
     fprintf (stderr,"Illegal parse tree node <%d>\n",pds->typ);
     return(rv);
   }
 }


static identifier_ptr get_init_dcltr (pid)
struct pnode_init_dcltr *pid;
 {
  return (get_dcltr(pid->dcl));
 }


identifier_ptr gen_dcltr_list (plid)
struct pnode_list_init_dcltr *plid;
 {
  identifier_ptr dl1,dl2,dl3;

  if (plid == 0) return (0);
  if (plid->typ == list_init_dcltr)
   {
    dl1 = gen_dcltr_list (plid->plid);
    dl2 = get_init_dcltr (plid->pid);
    if (dl1)
     {
      dl3 = dl1;
      while (dl3->link) dl3 = dl3->link;
      dl3->link = dl2;
      return (dl1);
     }
    return (dl2);
   }
  if (plid->typ == init_dcltr)
   return (get_init_dcltr((struct pnode_init_dcltr *)plid));
  fprintf (stderr,"PARSE_TREE gen_dcltr_list error\n");
  return 0;
 }

/* The following function is incorrect.  The dcltr lists that are on each
   item in the list must be appended to that which is provided by ti.
   The calls to the "append_dcltr" functions have been commented out
   since the result they produce is lost and is not used anyway.

   PLH April 9, 1987
 */

void distribute_type_info (ti,dl)
struct Type_Info ti;
identifier_ptr dl;
 {
  while (dl)
   {
    dl->type_info = ti;
    dl = dl->link;
   }
 }
