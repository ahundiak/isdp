/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *     This file consists all the functions which operates on attrib data
 *     structure. They can be divided into three categories.
 *      a. Creation 
 *      b. Manipulation
 *      c. Deletion 
 *     Functions in this file are also arranged in the same order.
 * 
 * NOTES 
 *
 */

/* Includes */

#include <stdio.h>
#include <alloca.h>
#include <malloc.h>
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWattrib.h"
#include "PWattribid.h"

/* ------------------------------------------------------------------------- */
/*                           TYPE  : CREATION                                */
/* ------------------------------------------------------------------------- */

/*
 * NAME
 *    pwCreateIntAttrib
 *
 * ABSTRACT
 *    Creates a new integer attribute, appends it to the given attrib list and
 *    returns it.
 *
 * SYNOPSIS
 *    struct PWattrib  **p_attrib_list   I  Attribute List , Could be NULL.
 *    unsigned int     ident             I  Identity of the attribute.
 *    int              attrib_val        I  Value of the attribute.
 *
 * DESCRIPTION
 *    Creates a new integer attribute with the given ident and appends it to 
 *    the incoming attribute list. If there is not sufficient memory it ret-
 *    urns NULL otherwise pointer to the newly created attribute.
 *
 * NOTES
 * 
 * RETURN VALUES
 *    Address of the Newly created Integer Attribute.
 *
 * EXAMPLES 
 *    PWobjid         loopid;
 *    struct PWcvpt   *cvpt;
 *    struct PWattrib *p_attrib=NULL;
 *  
 *    p_attrib = pwCreateIntAttrib (&cvpt->p_attrib,
 *                       PW_AttribIdent (PW_K_Trimming, PW_K_LoopId, LEFT),
 *                       loopid);
 */

struct PWattrib *pwCreateIntAttrib 
(
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  int              attrib_val
)
{
  struct PWattrib  *p_attrib=NULL;

  /* 
   * Allocate the memory and any overflow return NULL
   */
  p_attrib = (struct PWattrib *) malloc (sizeof(struct PWattrib));
  if (!p_attrib)
    return (struct PWattrib *) NULL;

  /*
   * initialize the fields and post the 'ident' and 'value'
   */
  p_attrib->ident = ident;
  p_attrib->attribtype = PWattrib_integer;
  p_attrib->attrib.int_attrib = attrib_val;
  p_attrib->p_next = NULL;

  /*
   * Append this newly created node to the end of the list
   */
  if (p_attrib_list)
  {
    if (*p_attrib_list)
    {
      struct PWattrib *p_node=NULL;
  
      p_node = *p_attrib_list;

      while (p_node->p_next) 
        p_node = p_node->p_next;

      p_node->p_next = p_attrib;
    }
    else
      *p_attrib_list = p_attrib;
  }

  return p_attrib;
}

/*
 * NAME
 *    pwCreateDoubleAttrib
 *
 * ABSTRACT
 *    Creates a new double attribute, appends it to the given attrib list and
 *    returns it.
 *
 * SYNOPSIS
 *    struct PWattrib  **p_attrib_list   I  Attribute List , Could be NULL.
 *    unsigned int     ident             I  Identity of the attribute.
 *    double           attrib_val        I  Value of the attribute.
 *
 * DESCRIPTION
 *    Creates a new double attribute with the given ident and appends it to
 *    the incoming attribute list. If there is not sufficient memory it ret-
 *    urns NULL otherwise pointer to the newly created attribute.
 *
 * NOTES
 *
 * RETURN VALUES
 *    Address of the Newly created double Attribute.
 *
 * EXAMPLES
 *    Same as Above.
 */

struct PWattrib *pwCreateDoubleAttrib 
(
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  double           attrib_val
)
{
  struct PWattrib  *p_attrib=NULL;

  /* 
   * Allocate the memory and any overflow return NULL
   */
  p_attrib = (struct PWattrib *) malloc (sizeof(struct PWattrib));
  if (!p_attrib)
    return (struct PWattrib *) NULL;

  /*
   * initialize the fields and post the 'ident' and 'value'
   */
  p_attrib->ident = ident;
  p_attrib->attribtype = PWattrib_double;
  p_attrib->attrib.double_attrib = attrib_val;
  p_attrib->p_next = NULL;

  /*
   * Append this newly created node to the end of the list
   */
  if (p_attrib_list)
  {
    if (*p_attrib_list)
    {
      struct PWattrib *p_node=NULL;
  
      p_node = *p_attrib_list;

      while (p_node->p_next) 
        p_node = p_node->p_next;

      p_node->p_next = p_attrib;
    }
    else
      *p_attrib_list = p_attrib;
  }

  return p_attrib;
}

/*
 * NAME
 *    pwCreateGenAttrib
 *
 * ABSTRACT
 *    Creates a Generic attribute and appends it to the in-coming attrib list.
 *
 * SYNOPSIS
 *    struct PWattrib  **p_attrib_list        I/O  Attribute List, could be NULL
 *    unsigned int     ident                   I   Identity of the attribute 
 *    char             *p_gen_val              I   Generic Info. of attribute
 *    void             (*free_func)(char *)    I   A free function to free the
 *                                                 info.
 *    char             *(*copy_func)(char *)   I   A copy function to copy the 
 *                                                 attribute info.
 *
 * DESCRIPTION
 *    Given generic info 'p_gen_val' will be copied into the newly created 
 *    attribute, so one can free 'p_gen_val' after a call is being made to 
 *    this function. The copy function is resposible for allocating requi-
 *    red memory and copying the info. and returning back the allocated 
 *    memory.
 *
 * NOTES
 *    If there is no seperate free function required for this attribute, one
 *    should call this system free function.
 *
 * RETURN VALUES
 *    Address of the Newly created Generic Attribute.
 *
 * EXAMPLES
 *    PWattrib     *p_list, *p_attrib=NULL;
 *    struct PWid  coinc_edge; 
 *    char         *copy_coinc_edge(char *);
 *    void         free_coinc_edge();
 *
 *    p_attrib = pwCreateGenAttrib (&p_list,
 *                    PW_AttribIdent (PW_K_Trimming, PW_K_CoincEdge, 0),
 *                    (char *) &coinc_edge, free_coinc_edge, copy_coinc_edge);
 *    
 *    char *copy_coinc_edge (char *p_ptr)
 *    {
 *      char        *p_optr=NULL;
 *      p_optr = (struct PWid *) malloc (sizeof(struct PWid));
 *      memcpy (p_optr, p_ptr, sizeof (struct PWid)); 
 *      return p_optr;
 *    }
 */

struct PWattrib *pwCreateGenAttrib 
(
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  char             *p_gen_val,
  void             (*free_func)(char *),
  char             *(*copy_func)(char *)
)
{
  struct PWattrib  *p_attrib=NULL;

  /* 
   * Allocate the memory and any overflow return NULL
   */
  p_attrib = (struct PWattrib *) malloc (sizeof(struct PWattrib));
  if (!p_attrib)
    return (struct PWattrib *) NULL;

  /*
   * initialize the fields and post the 'ident' and 'value'
   */
  p_attrib->ident = ident;
  p_attrib->attribtype = PWattrib_pointer;
  p_attrib->attrib.gen_attrib.p_attrib = (*copy_func)(p_gen_val);
  p_attrib->attrib.gen_attrib.free_attrib = free_func;
  p_attrib->attrib.gen_attrib.copy_attrib = copy_func;
  p_attrib->p_next = NULL;

  /*
   * Append this newly created node to the end of the list
   */
  if (p_attrib_list)
  {
    if (*p_attrib_list)
    {
      struct PWattrib *p_node=NULL;
  
      p_node = *p_attrib_list;

      while (p_node->p_next) 
        p_node = p_node->p_next;

      p_node->p_next = p_attrib;
    }
    else
      *p_attrib_list = p_attrib;
  }

  return p_attrib;
}

/*
 * QUERY
 */
/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */


PWboolean pwGetIntAttrib
(
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  int              *attrib_val
)
{
  struct PWattrib  *p_node;

  /*
   * validate the incoming arguments
   */
  if (!p_attrib)
    return (PWboolean) FALSE;

  p_node = p_attrib;

  do
  {
    if ((p_node->attribtype == PWattrib_integer) && (p_node->ident == ident)) 
    {
      *attrib_val = p_node->attrib.int_attrib;
      return (PWboolean) TRUE;
    }

    p_node = p_node->p_next;

  } while(p_node);

  return (PWboolean) FALSE;
}

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */

PWboolean pwGetDoubleAttrib
(
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  double           *attrib_val
)
{
  struct PWattrib  *p_node;

  /*
   * validate the incoming arguments
   */
  if (!p_attrib)
    return (PWboolean) FALSE;

  p_node = p_attrib;

  do
  {
    if ((p_node->attribtype == PWattrib_double) && (p_node->ident == ident)) 
    {
      *attrib_val = p_node->attrib.double_attrib;
      return (PWboolean) TRUE;
    }

    p_node = p_node->p_next;

  } while(p_node);

  return (PWboolean) FALSE;
}

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */


PWboolean pwGetGenAttrib
(
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  char             **attrib_val
)
{
  struct PWattrib  *p_node;

  /*
   * validate the incoming arguments
   */
  if (!p_attrib)
    return (PWboolean) FALSE;

  p_node = p_attrib;

  do
  {
    if ((p_node->attribtype == PWattrib_pointer) && (p_node->ident == ident)) 
    {
      *attrib_val = (*(p_node->attrib.gen_attrib.copy_attrib))(p_node->attrib.gen_attrib.p_attrib);
      return (PWboolean) TRUE;
    }

    p_node = p_node->p_next;

  } while(p_node);

  return (PWboolean) FALSE;
}


/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */


struct PWattrib *pwGetAttribPtr
(
  struct PWattrib    *p_attrib, 
  unsigned int       ident,
  enum PWattribtype  attribtype
)
{
  struct PWattrib  *p_node;

  /*
   * validate the incoming arguments
   */
  if (!p_attrib)
    return (struct PWattrib *) NULL;

  p_node = p_attrib;

  do
  {
    if ((p_node->attribtype == attribtype) && (p_node->ident == ident)) 
      return p_node;

    p_node = p_node->p_next;

  } while(p_node);

  return (struct PWattrib *) NULL;
}

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */


void pwFreeAttribList
( 
  struct PWattrib *p_attrib
)
{
  struct PWattrib  *p_node=NULL, *p_next_node=NULL;

  p_node = p_attrib;

  while (p_node)
  {
    p_next_node = p_node->p_next;

    if (p_node->attribtype == PWattrib_pointer)
    {
      (*(p_node->attrib.gen_attrib.free_attrib))(p_node->attrib.gen_attrib.p_attrib);
    }

    free (p_node);
 
    p_node = p_next_node;
  }
 
  return;
}

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */

void pwRemoveAttrib
(
  struct PWattrib **p_attrib,
  struct PWattrib *p_remove_attrib
)
{
  struct PWattrib  *p_node=NULL, *p_prev_node=NULL;

  /*
   * validate the incoming arguments
   */
  if (!p_attrib || !*p_attrib || !p_remove_attrib) 
    return;

  /*
   * get the node from the list, disconnect it and restore the integrity
   * of the list.
   */
  p_node = *p_attrib;
  p_prev_node = NULL;

  while (p_node && p_node != p_remove_attrib)
  {
    p_prev_node = p_node;
    p_node = p_node->p_next;
  }

  if (p_node)
  {
    if (p_prev_node)  /* other than the header */
    {
      p_prev_node->p_next = p_node->p_next;
      p_node->p_next = NULL;
    }
    else /* trying to remove the header, so modify it */
    {
      *p_attrib = p_node->p_next;
      p_node->p_next = NULL;
    }
  }
  
  return;
}

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * DESCRIPTION
 *
 * NOTES
 *
 * RETURN VALUES
 *
 */

struct PWattrib *pwCopyAttribList
(
  struct PWattrib *p_attrib
)
{
  struct PWattrib  *p_list=NULL, *p_node=NULL;  

  p_node = p_attrib;

  while (p_node)
  {
    if (p_node->attribtype == PWattrib_integer)
      pwCreateIntAttrib (&p_list, p_node->ident, p_node->attrib.int_attrib);
    else if (p_node->attribtype == PWattrib_double)
      pwCreateDoubleAttrib (&p_list, p_node->ident, 
                            p_node->attrib.double_attrib);
    else if (p_node->attribtype == PWattrib_pointer)
      pwCreateGenAttrib (&p_list, p_node->ident, 
                         p_node->attrib.gen_attrib.p_attrib,
                         p_node->attrib.gen_attrib.free_attrib,
                         p_node->attrib.gen_attrib.copy_attrib );

    p_node = p_node->p_next;
  }

  return p_list;  
}
