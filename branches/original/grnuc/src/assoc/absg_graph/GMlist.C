#include <stdio.h>
#include "GMlist.h"
#include "OMerrordef.h"
#include "GMerrordef.h"

#define TRUE  1
#define FALSE 0

/*
  Description : Procedures to use a list management (could be use for several
                types of elements

  Constraint  : This package must be used with a number of
                elements < GML_NULL_INDEX
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             INTERNAL Definitions                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GML_NULL_INDEX     0xfffe /* The null index                           */
#define GML_AT_BEGIN       0xffff /* The current is at the begin. of the list */
#define GML_DEF_SIZE           40 /* Default number of elements               */
#define GML_DEF_ELMT_SIZE       1 /* Default size of an element               */

#define GML_IS_AT_BEGIN(p_list)   (p_list->current_ind == GML_AT_BEGIN)

#define GML_IS_AT_END(p_list)     \
        ((p_list->current_ind == p_list->nb_elmt)||(!p_list->nb_elmt))

#define GML_CURRENT(p_list)  (!(GML_IS_AT_BEGIN(p_list)||GML_IS_AT_END(p_list)))

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMl_activate                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_activate(default_number,inc_number,elmt_size,equal_funct,p_fct_info,
              size_info,list)
  /*
  Description: Activate a list, that means allocate memory space and 
               initialize the list structure.
  Constraints: default_number > 0,
               inc_number > 0,
               elmt_size >0,
               otherwise there will be the default values
  */
  int     default_number;    /* IN       default number of elmt in the list   */
  int     inc_number;        /* IN       Increment number of elmt in the list */
  int     elmt_size;         /* IN       Size of an element                   */
  int     (*equal_funct)();  /* IN       Function to test the equality        */
  char    *p_fct_info;       /* IN       Information for the equal fct        */
  int     size_info;         /* IN       Size of this information             */
  struct  GMlist *list;      /* IN/OUT   list to activate                     */
  /*.GMl_activate*/
  {
  int status = GM_S_SUCCESS; /* Status of the function                        */
  int exception_type = NULL; /* Type of exception if degraded mode            */

  if((default_number < 1)||(default_number >= GML_NULL_INDEX))default_number = GML_DEF_SIZE;
  if((inc_number < 1)    || (inc_number >= GML_NULL_INDEX))   inc_number     = GML_DEF_SIZE;
  if((elmt_size < 0)     || (elmt_size >= GML_NULL_INDEX))    elmt_size      = GML_DEF_ELMT_SIZE;

  list->step_size   = (unsigned short)inc_number;
  list->nb_max_elmt = (unsigned short)default_number;
  list->elmt_size   = (unsigned short)elmt_size;
  list->elmt        = (char *)malloc(list->nb_max_elmt*elmt_size);
  if(!list->elmt){status=GM_E_NODYNMEM;gm$status();}

  if(list->elmt)
    {
    /*" The size of the list is : %d\n",list->nb_max_elmt */

    list->current_ind = GML_AT_BEGIN;
    list->nb_elmt     = 0;
    list->funct       = equal_funct;
    if(p_fct_info!=NULL)
      {
      if(size_info > 0) list->p_fct_info = (char *)malloc(size_info);
      if(!list->p_fct_info){status=GM_E_NODYNMEM;gm$status(type = EXCEPTION_1);}
      memcpy(list->p_fct_info,p_fct_info,size_info);
      }
    else
     list->p_fct_info = NULL;
    /* if */
  }/* if(list->elmt)*/

exception:
  if(exception_type == EXCEPTION_1) GMl_disactivate(list->elmt);
  return(status);
}/* GMl_activate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMl_disactivate                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_disactivate(list)
  /*
  Description: disactivate a list, that means free memory space and 
               initialize the list structure.
  Constraints: The list must be allocated
  */
  struct GMlist *list;       /* IN/OUT   list to disactivate                  */
  /*.GMl_disactivate*/
  {
  if(list->elmt != NULL)
    {
    /*| Free the list */

    free(list->elmt);
    list->elmt = NULL;
  }/* if(list->elmt)*/

  if(list->p_fct_info != NULL)
    {
    /*| Free the fct information */

    free(list->p_fct_info);
    list->p_fct_info = NULL;
  }/* if(list->p_fct_info)*/
  return(GM_S_SUCCESS);
}/* GMl_disactivate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMl_clear                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_clear(list)
  /*
  Description: clear a list, that means update the header
  Constraints: none
  */
  struct GMlist *list;          /* IN/OUT   list to clear                     */
  /*.GMl_clear*/
  {
  list->current_ind = GML_AT_BEGIN;
  list->nb_elmt     = 0;
  return(GM_S_SUCCESS);
}/* GMl_clear */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_insert                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_insert(p_content,in_list)
  /*
  Description: Insert an element before the current element of the list. After
               this element will be the current.
  Constraints: The list must be allocated
  */
  char          *p_content;  /* IN       element to insert in the list        */
  struct GMlist *in_list;    /* IN/OUT   list                                 */
  /*.GMl_insert*/
  {
  int status =GM_S_SUCCESS;  /* Status of the function                        */
  int index;                 /* Internal index                                */
  unsigned int  new_size;    /* New size of the array of elements             */

  GMl_first(in_list);
  if(!(in_list->funct && GMl_select(p_content,in_list)))
    {
    if(in_list->nb_elmt >= in_list->nb_max_elmt)
      {
      /*| Reallocate memory */

      new_size = (unsigned int)in_list->nb_max_elmt+in_list->step_size;
      if(new_size >= GML_NULL_INDEX)
        {
        new_size = GML_NULL_INDEX-1;
        if(new_size<=in_list->nb_max_elmt){status=GM_E_OUT_OF_RANGE;gm$status();}
      }/* if(new_size)*/
      in_list->nb_max_elmt = (unsigned short)new_size;
      in_list->elmt=(char *)realloc(in_list->elmt,(in_list->nb_max_elmt)*in_list->elmt_size);
      if(!in_list->elmt){status=GM_E_NODYNMEM;gm$status();}
    }/* if(in_list->nb_elmt) */

    if(!GML_IS_AT_END(in_list))
      {
      if(GML_IS_AT_BEGIN(in_list)) in_list->current_ind = 0;

      /*| Move all the content */

      new_size = in_list->elmt_size;
      for(index = in_list->nb_elmt; index > (int)in_list->current_ind; index--)
        memcpy((in_list->elmt)+index*new_size,(in_list->elmt)+(index-1)*new_size,new_size);

      /*| Insert the p_content in the list */
 
      memcpy((in_list->elmt)+(in_list->current_ind)*new_size,p_content,new_size);
      (in_list->nb_elmt)++;
      }
    else
      {
      /*| Add the element at the end of the list */
 
      memcpy((in_list->elmt)+(in_list->nb_elmt*in_list->elmt_size),p_content,in_list->elmt_size);
      in_list->current_ind = in_list->nb_elmt;
      (in_list->nb_elmt)++;
    }/* if(in_list)*/
    }
  else
    {
    /*| This element is already in the list or wrong current index */
    status = GM_W_ALREADY_EXISTS;
  }/* if(!GMl_select)*/
exception:
  return(status);
}/* GMl_insert */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_add                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_add(p_content,in_list)
  /*
  Description: Add an element at the end of the list. After this element will
               be the current.
  Constraints: The list must be allocated
  */

  char          *p_content;  /* IN       element to add in the list           */
  struct GMlist *in_list;    /* IN/OUT   list                                 */
  /*.GMl_add*/
  {
  int  status=GM_S_SUCCESS;  /* Status of the function                        */
  unsigned  int   new_size;  /* New size of the array of elements             */

  GMl_first(in_list);
  if(!(in_list->funct && GMl_select(p_content,in_list)))
    {
    if(in_list->nb_elmt >= in_list->nb_max_elmt)
      {
      /*| Test the maximum size of the list */

      new_size = (unsigned int)in_list->nb_max_elmt+in_list->step_size;
      if(new_size >= GML_NULL_INDEX)
        {
        new_size = GML_NULL_INDEX-1;
        if(new_size<=in_list->nb_max_elmt){status=GM_E_OUT_OF_RANGE;gm$status();}
      }/* if(new_size)*/
      in_list->nb_max_elmt = (unsigned short)new_size;
      in_list->elmt=(char *)realloc(in_list->elmt,in_list->nb_max_elmt*in_list->elmt_size);
      if(!in_list->elmt){status=GM_E_NODYNMEM;gm$status();}
    }/* if(in_list->nb_elmt)*/

    /*| Add the element in the list */
 
    memcpy((in_list->elmt)+(in_list->nb_elmt*in_list->elmt_size),p_content,in_list->elmt_size);
    in_list->current_ind = in_list->nb_elmt;
    (in_list->nb_elmt)++;
  }/* if(!in_list->funct)*/
exception:
  return(status);
}/* GMl_add */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMl_replace                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_replace(p_content,in_list)
  /*
  Description: Replace the current element of the list by the specified element.
               After this element will be the current.
  Constraints: The list must be allocated
  */
  char          *p_content;  /* IN       element to replace the current elmt  */
  struct GMlist *in_list;    /* IN/OUT   list                                 */
  /*.GMl_replace*/
  {
  int status;                /* Status of the function                        */

  if(GML_CURRENT(in_list))
    {
    /*| Replace the element in the list */
 
    memcpy((in_list->elmt)+(in_list->current_ind*in_list->elmt_size),p_content,in_list->elmt_size);
    status = GM_S_SUCCESS;
    }
  else
    {
    /*| The current index is not correct */

    status = GM_E_ELMT_NOT_DEFINED;
  }/* if(in_list->current_ind)*/
  return(status);
}/* GMl_replace */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMl_remove                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_remove(in_list)
  /*
  Description: Remove the current element of the list .
               The current element of the list becomes the previous.
  Constraints: The list must be allocated
  */
  struct GMlist   *in_list;  /* IN/OUT   list which contains the current elmt */
  /*.GMl_remove*/
  {
  int  status = GM_S_SUCCESS;/* Status of the function                        */
  int             index;     /* Internal index                                */
  unsigned int    size;      /* Size of an element                            */

  if(GML_CURRENT(in_list))
    {
    /*| Remove the current element in the list */

    size = in_list->elmt_size;
    for(index = in_list->current_ind; index < (int)in_list->nb_elmt-1; index++)
      memcpy((in_list->elmt)+index*size,(in_list->elmt)+(index+1)*size,size);
    (in_list->nb_elmt)--;
    if(in_list->current_ind != 0)
      (in_list->current_ind)--;
    else
      if(!(in_list->nb_elmt)) in_list->current_ind = GML_AT_BEGIN;
    }
  else
    {
    /*| The current index is not defined */

    status = GM_E_ELMT_NOT_DEFINED;
  }/* if(in_list->current_ind)*/

  return(status);
}/* GMl_remove */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              function GMl_first                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_first(of_list)
  /*
  Description: Set the current element to the first of the list.
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;   /* OUT      list considered                       */
  /*.GMl_first*/
  {
  int status;               /* Status of the function                         */
 
  if(of_list->nb_elmt != 0)
    {
    of_list->current_ind = 0;
    status = GM_S_SUCCESS;
    }
  else
    status = GM_E_EMPTY_LIST;
  /* if(of_list->nb_elmt)*/
  return(status);
}/* GMl_first */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_last                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_last(of_list)
  /*
  Description: Set the current element to the first of the list.
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;   /* OUT      list considered                       */
  /*.GMl_last*/
  {
  int    status;            /* Status of the function                         */

  if(GMl_count(of_list))
    {
    of_list->current_ind = of_list->nb_elmt-1;
    status = GM_S_SUCCESS;
    }
  else
    status = GM_E_EMPTY_LIST;
  /* if(!GMl_count)*/
  return(status);
}/* GMl_last*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function GMl_next                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_next(of_list)
  /*
  Description: Set the current element of the list to the next element.
               if the next element doesn't exist then returns FALSE.
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;    /* OUT      list                                 */
  /*.GMl_next*/
  {
  if(!GML_IS_AT_BEGIN(of_list))
    {
    /*| Increment the current index */

    if(!GML_IS_AT_END(of_list))(of_list->current_ind)++;
    }
  else
    if(of_list->nb_elmt) of_list->current_ind = 0;
  /* if(of_list->current_ind) */
  return(GM_S_SUCCESS);
}/* GMl_next */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMl_previous                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_previous(of_list)
  /*
  Description: Set the current element of the list to the previous element
               if the previous element doesn't exist then returns FALSE.
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;     /* OUT      list                                */
  /*.GMl_previous*/
  {
  if(!GML_IS_AT_BEGIN(of_list))
    {
    /*| Decrement the current index */

    if(of_list->current_ind) (of_list->current_ind)--;
    else  of_list->current_ind = GML_AT_BEGIN;
  }/* if */
  return(GM_S_SUCCESS);
}/* GMl_previous‚ */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_select                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_select(p_content ,list)
  /*
  Description: Set the current element of the list to the selected object.
  Constraints: The list must be allocated
  Note       : 
  */
  char          *p_content;  /* IN       element to find in the list          */
  struct GMlist *list;       /* IN       list                                 */
  /*.GMl_select*/
  {
  int      status = FALSE;   /* Default status of the function                */
  unsigned short    index;   /* Internal index                                */

  if(list->funct)
    {
    for(index = list->current_ind; index < list->nb_elmt; index++)
      {
      if(!list->funct(p_content,(list->elmt)+index*(list->elmt_size),list->p_fct_info))
        {
        /*"The current index is %d\n",index*/

        list->current_ind = index;
        status = TRUE;
        break;
      }/* if(!list->funct)*/
    }/* for */
  }/* if(list->funct)*/
  return(status);
}/* GMl_select */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_at_end                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_at_end(of_list)
  /*
  Description: Returns TRUE if the current index is at the end of the list
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;     /* IN       list                                */
  /*.GMl_at_end*/
  {
  return GML_IS_AT_END(of_list);
}/* GMl_at_end */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_at_begin                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_at_begin(of_list)
  /*
  Description: Returns TRUE if the current index is at the begining of the list
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;     /* IN       list                                */
  /*.GMl_at_begin*/
  {
  return GML_IS_AT_BEGIN(of_list);
}/* GMl_at_begin */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function current                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

char *GMl_current(of_list)
  /*
  Description: Return the current element of the list.
  Constraints: The list must be allocated
  */
  struct GMlist *of_list;    /* IN       list                                 */
  /*.GMl_current*/
  {
  if(GML_CURRENT(of_list))
    return((of_list->elmt)+(of_list->current_ind*of_list->elmt_size));
  else
    return(NULL);
}/* GMl_current */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        function GMl_count                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_count(list)
  /*
  Description: Return The number of elements in the list
  Constraints: none
  */
  struct GMlist *list;       /* IN       list to test                         */
  {
  return(list->nb_elmt);
}/* GMl_count */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMl_ptr                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

char *GMl_ptr(list)
  /*
  Description: Return the pointer to the array
  Constraints: none
  */
  struct GMlist *list;       /* IN       list to inquire                      */
  {
  return(list->elmt);
}/* GMl_ptr */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMl_duplicate                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_duplicate(list, l_dup)
  /*
  Description: duplicate a list in an other one
  Constraints: the list l_dup must be allocated before using GMl_activate.
  */
  struct GMlist *list;        /* IN     list to duplicate                     */
  struct GMlist *l_dup;       /* OUT    Duplicate list                        */
  /*.GMl_duplicate*/
  {
  int status = GM_S_SUCCESS; /* Status of the function                        */

  if(l_dup->nb_max_elmt < list->nb_elmt)
    {
    free(l_dup->elmt);
    l_dup->elmt=(char *)malloc(list->nb_max_elmt*list->elmt_size);
    if(!l_dup->elmt){status=GM_E_NODYNMEM;gm$status();}
  }/* if */

  /*| Duplicate the header */
 
  memcpy(l_dup,list,sizeof(struct GMlist));

  /*| Duplicate the list */

  memcpy(l_dup->elmt, list->elmt, list->nb_elmt*list->elmt_size);

exception:
  return(status);
}/* GMl_duplicate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMl_in                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMl_in(p_content ,list, usr_fct, usr_arg)
  /*
  Description: Set the current element of the list to the selected object. This
               object can be selected using external selectors : usr_fct,
               usr_arg or the internal definitions : list->func,
               list->p_fct_info.
  Constraints: The list must be allocated
  Note       : If the caller specify NULL for the "usr_fct" argument, the
               default function is used
  */
  char          *p_content;  /* IN       element to find in the list          */
  struct GMlist *list;       /* IN       list                                 */
  int           (*usr_fct)();/* IN       User function to compare the elements*/
  char          *usr_arg;    /* IN       User arguments for this function     */
  /*.GMl_in*/
  {
  int      status = FALSE;   /* Default status of the function                */
  unsigned short    index;   /* Internal index                                */
  int      (*cmp_fct)();     /* Function to compare the elements              */
  char     *cmp_arg;         /* Arguments for the compare function            */
   
  if(usr_fct)
    {
    /*| Load the user compare function */
    cmp_fct = usr_fct;
    cmp_arg = usr_arg;
    }
  else
    {
    /*| Load the default compare function */
    cmp_fct = list->funct;
    cmp_arg = list->p_fct_info;
  }/* if(usr_fct)*/
   
  if(cmp_fct)
    {
    for(index = list->current_ind; index < list->nb_elmt; index++)
      {
      if(!cmp_fct(p_content,(list->elmt)+index*(list->elmt_size),cmp_arg))
        {
        /*"The current index is %d\n",index*/

        list->current_ind = index;
        status = TRUE;
        break;
      }/* if(!cmp_fct)*/
    }/* for */
  }/* if(cmp_fct)*/
  return(status);
}/* GMl_in */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
