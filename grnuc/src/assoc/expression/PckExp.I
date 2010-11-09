/*

Name
  PckExp.I

Description
  The routines in this file get and display the
  list of expressions from the directory command
  form.

Notes


 */

class implementation FIdirform;


#ifdef ENABLE_MATH_H
%safe
#include <math.h>
%endsafe
#endif

#include "coimport.h"
#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ODE.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
#include <string.h>
#include "msmacros.h"
#include "drawparam.h"
#include "dp.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"


%safe
static Form PickExpressionForm = NULL;
static int  Accept = 0, LastOperator = 0;
static char string [DI_PATH_MAX], *pString = NULL, *LastPosition = NULL, 
            Operators [] = { '+', '-', '*', '/', '(', ')', '=' };
%endsafe

/*

Name
  EXPUpdateGadgets

Abstract
  Enable/disable gadgets based on the current state of the form.
  
Synopsis
  static void EXPUpdateGadgets ()
  
Description
  Fairly trivial.
  
Return Value
  NONE

Notes

Index

Keywords
  associative,directory,equation,form

History
  05/07/93 : Henry G. Bequet : created
 */
static void EXPUpdateGadgets ()
{
  char Text [DI_PATH_MAX];
  int  GadgetIndex;

  if (PickExpressionForm)
  {  
    /*
     * The BS button is disable if we have nowhere to go
     */
    if (LastPosition)
      FIg_enable ( PickExpressionForm, 13 );
    else
      FIg_disable ( PickExpressionForm, 13 );

    /*
     * Always make sure the syntax is up-to-date
     */
    FIg_get_text ( PickExpressionForm, 24, Text );
    if (strcmp ( Text, string ))
      FIg_set_text ( PickExpressionForm, 24, string );
    
    /*
     * After an operator, one can only have an expression
     */
    if (LastOperator)
      for (GadgetIndex = 16; GadgetIndex <= 21; GadgetIndex++)
        FIg_disable ( PickExpressionForm, GadgetIndex );
    else
      for (GadgetIndex = 16; GadgetIndex <= 21; GadgetIndex++)
        FIg_enable ( PickExpressionForm, GadgetIndex );
  }
}


void EXPUpdateExpressionList ()
/*
 * This routine updates the list of expression that is displayed by the form.
 * If only the expressions of one file are listed then the relative pathname
 * is displayed.
 */
{
  char   FileName [DI_PATH_MAX], **ExpressionNames, StartDirectory [DI_PATH_MAX];
  int    Count = 0, Star, RowIndex, ExpressionIndex;
  DIgrid *Grids;
  
  if (PickExpressionForm)
  {
    FIg_get_text ( PickExpressionForm, 15, FileName );
    if (!strcmp ( FileName, "*" ))
    {
      strcpy ( StartDirectory, ":" );
      Star = 1;
    }
    else
    {
      DIConvertToLongPath ( FileName );
      strcpy ( StartDirectory, FileName );
      Star = 0;
    }
    
    di$find ( start_dir = StartDirectory, ptr = &Count, lines = &ExpressionNames,
      grids = &Grids, options = NULL );

    if (Count)
    {
      for (RowIndex = 0, ExpressionIndex = 0; ExpressionIndex < Count; ExpressionIndex++)
      {
        GRclassid        ClassId;
        extern GRclassid OPP_expression_class_id;
        
        if (om$get_classid ( osnum = Grids [ExpressionIndex].osnum,
                objid = Grids [ExpressionIndex].objid, p_classid = &ClassId ) == OM_S_SUCCESS)
          if (om$is_ancestry_valid ( superclassid = OPP_expression_class_id,
                  subclassid = ClassId ) == OM_S_SUCCESS)
          {
            char *EXPlocate ( char *, char *);
            
            /*
             * We only show the expressions that are in the usr directory or
             * any of its sub-directories.
             */
            if (EXPlocate ( "usr", ExpressionNames [ExpressionIndex] ))
            {
              if (!Star)
                di$split ( pathname = ExpressionNames [ExpressionIndex],
                    name = ExpressionNames [ExpressionIndex] );
              else
                DIConvertToShortPath ( ExpressionNames [ExpressionIndex] );

              FIfld_set_text ( PickExpressionForm, 14, RowIndex++, 0, 
                  ExpressionNames [ExpressionIndex], 0 );
            }
          }
      }

      di$free ( lines = ExpressionNames, count = Count );
      free ( Grids );
    }
    else
      RowIndex = 0;

    FIfld_set_num_rows ( PickExpressionForm, 14, RowIndex );
  }
}


/*

Name
  EXPAddExpression

Abstract
  Add an expression name to the equation we are building.

Synopsis
  static void EXPAddExpression ( char *ExpressionName )

Description
  Add the name to the expression and reset the pointers

Return Value
  None.
  
Notes

Index

Keywords
  associative,equation,form

History
  05/10/93 : Henry G. Bequet : created

 */
static void EXPAddExpression ( char *ExpressionName )
{
  LastPosition = pString;

  /*
   * If the string doesn't terminate with an operator then we default
   * to a '+'.
   */
  if (pString != string)
  {
    char C = *(pString - 1);
   
    if (C != '+' && C != '-' && C != '=' && C != '*' && C != '/' &&
        C != '?' && C != ')' && C != '(' && C != ':' && C != '=')
    {
      strcat ( string, "+" );
      *++pString = '\0';
    }
  }

  strcpy ( pString, ExpressionName );
  pString = strchr ( string, '\0' );
  LastOperator = 0;
}


#argsused
void EXPNotifyPick (
  int    form_label,
  int    GadgetLabel,
  double value,
  Form   form)
{
  int  response = TERMINATE, Flag, position, Space;
  long msg;
  char FileName [DI_PATH_MAX], ExpressionName [DI_PATH_MAX], *pStart;
  
  switch (GadgetLabel)
  {
    case 1: Accept = 1;
    case 4: FIf_delete ( form );
            PickExpressionForm = NULL;
            ex$putque ( msg = &msg, response = &response );
            break;
    case 15: EXPUpdateExpressionList ();
             break;
    case 14: FIg_get_text ( form, 15, FileName );
             if (strcmp ( FileName, "*" ))
             {
               strcat ( strcpy ( ExpressionName, FileName ), ":" );
               pStart = strchr ( ExpressionName, '\0' );
               Space = DI_PATH_MAX - strlen ( ExpressionName );
             }
             else
             {
               pStart = ExpressionName;
               Space = DI_PATH_MAX;
             }
               
             FIfld_get_text ( form, GadgetLabel, (int)value, 0, Space, 
               pStart, &Flag, &position );
             FIfld_set_text ( form, GadgetLabel, (int)value, 0, pStart, 0 );
             DIConvertToShortPath ( ExpressionName );
             EXPAddExpression ( ExpressionName );
             break;

    case 16: 
    case 17: 
    case 18: 
    case 19: 
    case 20: 
    case 21: 
    case 22: 
             LastPosition = pString;
             *pString++ = Operators [GadgetLabel - 16];
             *pString = '\0';
             LastOperator = 1;
             break;
    case 13: /* This is a Back Space */
             pString = LastPosition;
             LastPosition = NULL;
             *pString = '\0';
             LastOperator = 0;
             break;
    case 24: FIg_get_text ( PickExpressionForm, GadgetLabel, string );
             pString = strchr ( string, '\0' );
             LastOperator = 0;
             LastPosition = NULL;
  }
  
  EXPUpdateGadgets ();
}


EXPPickExpression ( x, y, ExpressionSyntax )
int x, y;
char ExpressionSyntax [DI_PATH_MAX] /* The syntax of the expression	OUT */;

/*
 * This routine is used to pick an expression.
 */
{
  int ret;
  
  ret = FIf_new ( 1, "GRExpList", EXPNotifyPick, &PickExpressionForm );
  if (ret)
    return OM_E_ABORT;

  FIf_set_location(PickExpressionForm, x, y);    

  Accept = 0;
  strcpy ( string, ExpressionSyntax );
  pString = strchr ( string, '\0' );
  LastPosition = NULL;
  LastOperator = 0;
  FIf_display ( PickExpressionForm );
  
  /*
   * Initialize the list of valid files
   */
  DIInitShortFileList ( &PickExpressionForm, 15, 1 );
  EXPUpdateExpressionList ();
  EXPUpdateGadgets ();
  
  /*
   * We loop until we get accept/reject. Accept will be set to 1 if
   * the guy accepts the form.
   */
  while (PickExpressionForm)
  {
    long               msg, EventSize = sizeof ( struct GRevent ), mask;
    double             response_data [128];
    int                response;
    struct GRevent     event, event1, event2;
    struct GRlc_stack  Stack;
    struct GRlc_locate Attributes;
    
    LCdef_cursor();
    co$getevent ( msg = &msg, event_mask = GRm_SPECIFIED_OBJ | GRm_DATA, 
      response = &response, response_data = (char *)response_data, event = &event );
    LCrestore_cursor();

    if(response == DATA || response == SPECIFIED_OBJ)
    {
      int         Tokens [] = { D_RESET, STRING, DATA };
      long        display_flag = ELEM_HILIGHT | ALL_WINDOWS;
      struct GRid LocatedGrid;
      double      Value;

      /*
       * We put the locate and the accept events. We also put an
       * EX_RESTART event to get out of locate even if nothing is located.
       */      
      EXputq_front ( &msg, &response, &EventSize, (char *)&event.event );
      EXputq_front ( &msg, &response, &EventSize, (char *)&event.event );
      response = EX_RESTART;
      EXputq_back ( &msg, &response, &EventSize, (char *)&event.event );
      mask = GRm_SPECIFIED_OBJ | GRm_DATA;
      Attributes.properties =  LC_DP_ONLY | LC_RW | LC_LC_ONLY;
      Attributes.owner_action = LC_HANDLES | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED |
        LC_FLEX_OWNER | LC_FLEX_COMP | LC_RIGID_OWNER | LC_REF_OBJECTS |
        LC_REF_HEADER;
      Attributes.classes [0] = '\0';

      LocatedGrid.objid = NULL_OBJID;
      Stack.num_entries = 0;
      ASget_param ( &msg, Tokens, &event1, &event2, &mask, &mask, &EventSize, 
        &display_flag, &response, response_data, "", "", "", &Attributes, 
        &Stack, &LocatedGrid, &Value );
      {
        GRclassid        ClassId;
        char             ExpressionName [DI_PATH_MAX];
        extern GRclassid OPP_expression_class_id;
        
        if (om$get_classid ( osnum = LocatedGrid.osnum,
              objid = LocatedGrid.objid, p_classid = &ClassId ) == OM_S_SUCCESS)
          if (om$is_ancestry_valid ( superclassid = OPP_expression_class_id,
                  subclassid = ClassId ) == OM_S_SUCCESS)
          {
            if (di$untranslate ( osnum = LocatedGrid.osnum,
                  objid = LocatedGrid.objid, objname = ExpressionName ) == OM_S_SUCCESS)
            {
              /*
               * If the expression is in a reference file, we need to build the
               * path.
               */
              DIConvertToShortPath ( ExpressionName );
              EXPAddExpression ( ExpressionName );
              EXPUpdateGadgets ();
            }
          }
      }
      
      /*
       * Make sure our EX_RESTART event is gone...
       */
      if (EX_peek_event_queue ( NULL ))
      {
        co$getevent ( msg = &msg, event_mask = 0x0, response = &response, 
          response_data = (char *)response_data, event = &event );
      }
    }
  }

  if (Accept)
    strcpy ( ExpressionSyntax, string );

  return Accept;  
}


end implementation FIdirform;

