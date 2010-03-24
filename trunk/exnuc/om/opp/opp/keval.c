
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* keval.c - ???							*/
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
#include "lexinput.h"
#include "ptoken.h" /* import struct pnode_token */
#include "fio.h"

static char msg[YYTEXT_SIZE];
static int ev_sizeof_fun();
static int ev_paren_exp();
static int ev_type_cast();
static int ev_unary_exp();
static int ev_postfix_exp();
static int ev_bin_exp();
static int ev_cond_exp();
static int ev_struct_pointer_access();
static int ev_struct_access();
static int ev_function_call();
static int ev_array_access();
static int ev_inst_access_exp();

int evaluate_ptree_exp (pe)
struct pnode *pe;
 {
  switch (pe->typ)
   {
    case DEC_INT :
     {
      int intconst;
      sscanf (((struct pnode_token *)(pe))->constr, "%d", &intconst);
      return intconst;
     }
    case CHAR_CONST : return ((int)((struct pnode_token *)(pe))->constr[0]);
    case FLOAT_CONST :
     {
      double flconst;
      sscanf (((struct pnode_token *)(pe))->constr, "%lf", &flconst);
      return (int)flconst;
     }

    case STR_CONST :
     OPPERROR (((struct pnode_token *)(pe)),
        "String constants are not allowed in constant expression.");
     return (0);
    case IDENTIFIER :
     OPPERROR (((struct pnode_token *)(pe)),
        "Identifiers are not allowed in constant expression.");
     return (0);

    case struct_pointer_access : return (ev_struct_pointer_access(pe));
    case struct_access : return (ev_struct_access(pe));
    case function_call : return (ev_function_call(pe));
    case array_access : return (ev_array_access(pe));
    case inst_access_exp : return (ev_inst_access_exp(pe));

    case sizeof_fun : return (ev_sizeof_fun(pe));
    case paren_exp : return (ev_paren_exp(pe));
    case type_cast : return (ev_type_cast(pe));
    case unary_exp : return (ev_unary_exp(pe));
    case postfix_exp : return (ev_postfix_exp(pe));
    case bin_exp : return (ev_bin_exp(pe));
    case cond_exp : return (ev_cond_exp(pe));
   }
  return 0;
 }


static int ev_sizeof_fun(psf)
struct pnode_sizeof_fun *psf;
 {
  OPPERROR (psf->size_of,
   "Sizeof operator not supported in constant expression.");
  return (0);
 }


static int ev_paren_exp(ppe)
struct pnode_paren_exp *ppe;
 {
  return (evaluate_ptree_exp(ppe->expr));
 }


static int ev_type_cast(ptc)
struct pnode_type_cast *ptc;
 {
  OPPERROR (ptc->open_paren,
   "Type cast operator ignored in constant expression.");
  return (evaluate_ptree_exp(ptc->expr));
 }

static int ev_unary_exp(pue)
struct pnode_unary_exp *pue;
 {
  switch (pue->operator->typ)
   {
    case '!': return (!evaluate_ptree_exp(pue->expr));
    case '~': return (~evaluate_ptree_exp(pue->expr));
    case '-': return (-evaluate_ptree_exp(pue->expr));

    case PLUS_PLUS:
    case MINUS_MINUS:
    case '*':
    case '&':
     sprintf (msg, "Illegal unary operator '%s' for constant expression.",
       pue->operator->constr);
     OPPERROR (pue->operator,msg);
     return (0);

    case SIZEOF:
     OPPERROR (pue->operator,"'sizeof' operator not supported.");
     return (0);
   }
  return 0;
 }

static int ev_postfix_exp(ppe)
struct pnode_postfix_exp *ppe;
 {
  sprintf (msg,
    "Illegal operator '%s' for a constant expression.",ppe->operator);
  OPPERROR (ppe->operator,msg);
  return (0);
 }

static int ev_bin_exp(pbe)
struct pnode_bin_exp *pbe;
 {
  int i,j;

  i = evaluate_ptree_exp (pbe->expr1);
  j = evaluate_ptree_exp (pbe->expr2);
  switch (pbe->operator->typ)
   {
    case '/':
     if (j==0)
      {
       OPPERROR (pbe->operator,"Division by zero in a constant expression.");
       return (0);
      }
     return (i/j);
    case '%': if (j==0) return (0); return (i%j);
    case '*': return (i*j);
    case '+': return (i+j);
    case '-': return (i-j);
    case LEFT_SHIFT: return (i<<j);
    case RIGHT_SHIFT: return (i>>j);
    case '<': return (i<j);
    case '>': return (i>j);
    case LEQ: return (i<=j);
    case GEQ: return (i>=j);
    case EQ: return (i==j);
    case NOT_EQ: return (i!=j);
    case '&': return (i&j);
    case '^': return (i^j);
    case '|': return (i|j);
    case AND_AND: return (i&&j);
    case OR_OR: return (i||j);

    case '=':
    case PLUS_EQUAL:
    case MINUS_EQUAL:
    case TIMES_EQUAL:
    case DIV_EQUAL:
    case MOD_EQUAL:
    case RSHIFT_EQUAL:
    case LSHIFT_EQUAL:
    case AND_EQUAL:
    case XOR_EQUAL:
    case OR_EQUAL:
     sprintf (msg,"Illegal operator '%s' in constant expression.",
      pbe->operator->constr);
     OPPERROR (pbe->operator,msg);
     return (0);
   }
  return 0;
 }

static int ev_cond_exp(pce)
struct pnode_cond_exp *pce;
 {
  if (evaluate_ptree_exp (pce->expr1))
   return (evaluate_ptree_exp (pce->expr2));
  else
   return (evaluate_ptree_exp (pce->expr3));
 }

static int ev_struct_pointer_access(pspa)
struct pnode_struct_pointer_access *pspa;
 {
  OPPERROR (pspa->pointer,"Illegal operation inside constant expression.");
  return (0);
 }

static int ev_struct_access(psa)
struct pnode_struct_access *psa;
 {
  OPPERROR (psa->dot,"Illegal operation inside constant expression.");
  return (0);
 }

static int ev_function_call(pfc)
struct pnode_function_call *pfc;
 {
  OPPERROR (pfc->open_paren,"Illegal operation inside constant expression.");
  return (0);
 }

static int ev_array_access(paa)
struct pnode_array_access *paa;
 {
  OPPERROR (paa->open_bracket,"Illegal operation inside constant expression.");
  return (0);
 }

static int ev_inst_access_exp(piae)
struct pnode_inst_access_exp *piae;
 {
  OPPERROR (piae->me_tok,"Illegal operation inside constant expression.");
  return (0);
 }
