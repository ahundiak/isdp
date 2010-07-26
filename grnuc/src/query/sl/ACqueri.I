/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a directory
  mechanism for the objects with a query capability.
*/

class implementation ACncpx;

#define NOT_SHARABLE
#define NOT_COSHARABLE

#include <ctype.h>


#include "coimport.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "lcdef.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "DIquery.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

static OM_S_OBJID query_dir;
static OMuword    query_os;
static int        QYblank;
       int        QYstatus;

DIprocess_query ( query, my_os, my_id, syntax )
                  char       *query	/* the query to be processed	IN  */;
                  OM_S_OBJID my_id      /* the dir for the query on 	IN  */;
                  OMuword    my_os	/* the os of that dir		IN  */;
                  int        syntax	/* check the syntax only	IN  */;
/*
   This function returns OM_S_SUCCESS or OM_E_ABORT depending on the outcome
   of the query.
*/
{
  query_dir = my_id;
  query_os = my_os;
  QYstatus = FALSE;
  QYblank = syntax;
  set_buffer ( query );

  return query_yyparse () ? QY_E_SYNTAX : QYstatus;
}


query ( op1, oper, op2 )
        char *op1, *op2;
        int  oper;
{
  OM_S_OBJID objid = NULL_OBJID;
  struct     ret_struct str;
  int        status;

  if (QYblank)
    return NULL;

  /* find the expression */
  om$send ( msg = message ACncpx.translate ( &status, op1, NULL, NULL, &objid ),
            senderid = query_dir,
            targetos = query_os,
            targetid = query_dir );

#if 0
  if (oper == EXIST)
    return status == OM_S_SUCCESS;
#endif

  str.type = NULL;
  om$send ( msg = message NDnode.NDgive_structure ( (IGRlong *)&status, &str, NULL ),
            senderid = query_dir,
            targetos = query_os,
            targetid = objid );
  if (str.type == double_type)
    /* scanf will die if we cannot get a double */
    if (isdigit ( *op2 ))
    {
      double val;

      sscanf ( op2, "%lf", &val );
      switch (oper)
      {
        case GT: status = str.var.root_pm_st.value > val;
                 break;
        case LT: status = str.var.root_pm_st.value < val;
                 break;
        case GE: status = str.var.root_pm_st.value >= val;
                 break;
        case LE: status = str.var.root_pm_st.value <= val;
                 break;
        case EQ: status = str.var.root_pm_st.value == val;
                 break;
        case NE: status = str.var.root_pm_st.value != val;
                 break;
        default: status = OM_E_ABORT;
      }
    }
    else
      status = OM_E_ABORT;
  else
    if (str.type == text_type)
    {
      switch (oper)
      {
        case GT: status = strcmp ( str.var.text_st.text_string, op2 ) > 0;
                 break;
        case LT: status = strcmp ( str.var.text_st.text_string, op2 ) < 0;
                 break;
        case GE: status = strcmp ( str.var.text_st.text_string, op2 ) >= 0;
                 break;
        case LE: status = strcmp ( str.var.text_st.text_string, op2 ) <= 0;
                 break;
        case EQ: 
        case NE: if (di$is_regexp ( regexp = op2 ))
                 {
                   char **reg_buffer;
                   int  i, reg_count;

                   /* compile the regular expression 	*/
                   DImulti_parse ( op2, &reg_buffer, &reg_count );

                   /* check if we match it or not	*/
                   if (oper == EQ)
                     status = DImulti_step ( str.var.text_st.text_string, reg_buffer, reg_count );
                   else
                     status = !DImulti_step ( str.var.text_st.text_string, reg_buffer, reg_count );

                   for (i = 0; i < reg_count; i++)
                     DIfree ( reg_buffer [i] );
                   DIfree ( reg_buffer );
                 }
                 else
                   if (oper == EQ)
                     status = strcmp ( str.var.text_st.text_string, op2 ) == 0;
                   else
                     status = strcmp ( str.var.text_st.text_string, op2 ) != 0;

                 break;
        default: status = OM_E_ABORT;
      }
    }
    else
      status = OM_E_ABORT;
  
  return status;
}

end implementation ACncpx;



