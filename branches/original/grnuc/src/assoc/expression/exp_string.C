/*

Name
  exp_string.C

Description
  This file has the new methods and new routines for 
  equational constraints.
Notes


*/


#include <string.h> 
#include "expression.h"
#include "igrtypedef.h"

extern  char *EXPlocate ();

/*

Name
 skip_ifcomp_function() 

Abstract
 This function is used to test for the occurence of a ifinf(), or 
 ifsup() functions within a equation and then to skip over them

Synopsis
 ppeqn_string - ptr to ptr to current position in equation string

Description

Return Value
 EXP_S_SUCCESS

Notes

Index

Keywords
  equation,matching

History
  02/16/93 : Kapil Singh : created

 */


int skip_ifcomp_function(ppeqn_string) 
char **ppeqn_string;      /* equation string to search and reset */
{
  int r_paren;

  /*
   * if the remaining length is less then or equal to 5 then
   * the equation simply cannot contain a ifcomp
   */
  if (strlen(*ppeqn_string) <= 5)
    return(EXP_S_SUCCESS);
      
  /*
   * the present postion within the equation is a ifinf
   */
  if ((strncmp(*ppeqn_string, "ifinf", 5) == 0) || 
      (strncmp(*ppeqn_string, "ifsup", 5) == 0))
  {
    /*
     * skip over the ifinf keyword
     */
    (*ppeqn_string) = (*ppeqn_string) + 5;

    /*
     * look for the left paren
     */
    while ((**ppeqn_string) == ' ') ++ (*ppeqn_string);
    if ((**ppeqn_string) == '(')
    {
      r_paren = 1;
      ++ (*ppeqn_string);
      /*
       * look for the enclosing right paren
       */
      while ((r_paren != 0) && ((**ppeqn_string) != '\0'))
      {
        if ((**ppeqn_string) == '(')
          ++r_paren;
        else if ((**ppeqn_string) == ')')
          --r_paren;
        ++ (*ppeqn_string);          
      }
      /*
       * if the matching right paren not found, there is a problem
       */
      if (r_paren != 0)
      {
        Error_Text( EXP_INV_INPUT, "" );
        return( EXP_SYNTAX_ERROR);    
      }
    }
    else /* if the left paren not found after ifinf, input is invalid */
    {
      Error_Text( EXP_INV_INPUT, "" );
      return( EXP_SYNTAX_ERROR);    
    }
  }
  return (EXP_S_SUCCESS);
}



/*

Name
  skip_C_conditional

Abstract

 This function is used to test for the occurence of a 
 "C" conditional of the form (cond)?():() within a equation 
 and then to skip over it

Synopsis
 ppeqn_string - ptr to ptr to current position in equation string
 
Description

Return Value

Notes

Index

Keywords
  equation,matching

History
  02/16/93 : Kapil Singh : created

 */
int skip_C_conditional(ppeqn_string) 
char **ppeqn_string;      /* equation string to search and reset */
{
  char *pstr, *start_pos, *p_qmark;
  int r_paren, l_paren;
  /*
   * store the start position of the string to be searched
   */
  start_pos = *ppeqn_string;
  
  /*
   * if the start position, is not a "(", has to be before conditional
   */
  if (*start_pos != '(')
    return(EXP_S_SUCCESS);
  /*
   * if no "?", there cannot be a conditional 
   */
  p_qmark = strchr (*ppeqn_string, '?');
  if (p_qmark == NULL) 
    return (EXP_S_SUCCESS);
  
  /*
   * move to the left of all blanks from the "?"
   */  
  pstr = p_qmark;
  --pstr;
     
  while ((*pstr) == ' ')
    --pstr;     

  /*
   * Look for the boolean condtion (..) before "?"
   */
  if ((*pstr) == ')')
  {
    l_paren = 1;
    while ((l_paren != 0) && (pstr > start_pos))
    {
      --pstr;
      if ((*pstr) == '(')
        --l_paren;
      else if ((*pstr) == ')')
        ++l_paren;
    }
    if (l_paren != 0)
    {
      Error_Text( EXP_INV_INPUT, "" );
      return( EXP_SYNTAX_ERROR);    
    }
    /*
     * while starting from the question mark, while going left and
     * hitting the ( .. ), we did not come to the start position,
     * implies that some more characters are left before the conditional
     */      
    
    if (pstr != start_pos)
      return(EXP_S_SUCCESS);
      
    else /* we have to skip the conditional starting from */
         /* the question mark */

    {
      pstr = p_qmark;
      ++pstr;
      
      while ((*pstr) == ' ') 
        ++ (pstr);
        
      if ((*pstr) == '(') /* start of the first of (..) after question mark */
      {
        r_paren = 1;
        ++ (pstr);
        while ((r_paren != 0) && ((*pstr) != '\0'))
        {
          if ((*pstr) == '(')
            ++r_paren;
          else if ((*pstr) == ')')
            --r_paren;
          ++ (pstr);          
        }
        
        if (r_paren != 0) /* the closing paren of first (..) not found */
        {
          Error_Text( EXP_INV_INPUT, "" );
          return( EXP_SYNTAX_ERROR);    
        }
      }
      else /* the first (..) not found after question mark */
        return( EXP_S_SUCCESS);    

      /*
       * Now look for ":" after first (..) after question mark
       */
      while ((*pstr) == ' ') 
        ++ (pstr);
        
      if ((*pstr) == ':')
      {
        ++pstr;
        while ((*pstr) == ' ') 
          ++ (pstr);
        
          
        if ((*pstr) == '(')
        {
          r_paren = 1;
          ++ (pstr);
          while ((r_paren != 0) && ((*pstr) != '\0'))
          {
            if ((*pstr) == '(')
              ++r_paren;
            else if ((*pstr) == ')')
              --r_paren;
            ++ (pstr);          
          }
          if (r_paren != 0) /* the closing paren of second (..) not found */
          {
            Error_Text( EXP_INV_INPUT, "" );
            return( EXP_SYNTAX_ERROR);    
          }
          else /* advance the ptr arg to after the conditional */
            *ppeqn_string = pstr;
        }
        else /* the second (..) not found after ":" */
        {
          Error_Text( EXP_INV_INPUT, "" );
          return( EXP_SYNTAX_ERROR);    
        }
      }
      else /* ":" not found after first (..) after question mark */
        return( EXP_S_SUCCESS);    
    }
  }
  else /* the boolean condition (..) before "?" not found */
    return( EXP_S_SUCCESS);    

  return (EXP_S_SUCCESS);
}



/*

Name
  skip_if_then_else

Abstract
While matching of var and eqns, skip over if then else stat

Synopsis
cha **ppeqn_string; current pos in string IN/OUT 

Description
Uses EXPlocate to test for occurence of if then else keywords.

Return Value
EXP_S_SUCCESS

Notes

Index

Keywords
  equation,matching

History
  02/12/93 : Kapil Singh : created

 */

int skip_if_then_else(ppeqn_string) 
char **ppeqn_string;      /* equation string to search and reset */
{
  char *pif, *pthen, *pelse, *p_l_curly, *p_assign;
  IGRboolean  is_ifstat;
  
  is_ifstat = FALSE;
  
  p_assign = strchr (*ppeqn_string, '=');
  if (p_assign)
    return(EXP_S_SUCCESS);

  pif = EXPlocate("if", *ppeqn_string);

  if (pif)
  {
    pthen = EXPlocate("then", pif);
    if (pthen)
    {
      pelse = EXPlocate("else", pthen);
      if (pelse)
        is_ifstat = TRUE;
    }
    else
    {
      p_l_curly = strchr(pif, '{'); 
      if (p_l_curly)
      {
        pelse = EXPlocate("else", p_l_curly);
        if (pelse)
          is_ifstat = TRUE;        
      }
    }
  }
  
  if (is_ifstat)
  {
    while (**ppeqn_string != '\0')
        ++(*ppeqn_string);
  }
  return(EXP_S_SUCCESS);
}  

