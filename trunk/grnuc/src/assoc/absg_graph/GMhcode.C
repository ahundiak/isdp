#include <sys/types.h>
#include <stdio.h>
#include "GMhcode.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "igrtypedef.h"

/*
  Description : Procedures to use a hcode list (could be use for all types
                of elements and all types of keys)

  Constraint  : This package must be used with a number of elements < 65535
                This limitation is a parameter fixed in the file GMhcode.h
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                               INTERNAL Macros                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GMH_KEY(p_hcode, index)        \
        ((p_hcode->l_key)+(index*p_hcode->key_size))

#define GMH_CONTENT(p_hcode, index)    \
        ((p_hcode->l_content)+(index*p_hcode->content_size))

#define GMH_HEAD_INDEX(p_key, p_hcode) \
        ((p_hcode->f_hash(p_key)) % (int)p_hcode->modulo)

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMh_activate                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_activate(modulo, nb_elmt, step_size, content_size, key_size, f_cmp_key,
           p_fct_info, f_hash, p_hcode)
  /*
  Description : Activate a hcode header : allocate the table of elements :
                p_hcode->l_next, the list header  p_hcode->a_head, the
                contain p_hcode->l_content, the key list p_hcode->l_key and
                initialize all the fields of the structure

  Constraint  : modulo    > 0
                nb_elmt   > 1
                step_size > 1
                content_size > 0
  */ 
  IGRushort         modulo;        /* IN       Modulo de la selection du h_code  */
  IGRushort         nb_elmt;       /* IN       Default number of elements        */
  IGRushort         step_size;     /* IN       Increment number of elements      */
  IGRushort         content_size;  /* IN       Size of an element                */
  IGRushort         key_size;      /* IN       Size of a key                     */
  int            (*f_cmp_key)();/* IN       Function to compare the keys      */
  char           *p_fct_info;   /* IN       Information for the previous fct  */
  int            (*f_hash)();   /* IN       Function to compute the hash index*/
  struct GMhcode *p_hcode;      /* OUT      Hcode table to activate           */
  /*.GMh_activate */
  {
  IGRushort         index;         /* Index for a loop                           */
  int status;                   /* Status of the function                     */
  int exception_type = NULL;    /* Type of exception if degraded mode         */

  /*| Initialize all the fields */

  if(f_cmp_key == NULL) return(GM_F_BAD_FUNCT_ARG);
  if((modulo  <  1) ||(modulo >= GMH_NULL_INDEX)) modulo = GMH_DEF_MODULO;
  if((nb_elmt  <  1)||(nb_elmt >= GMH_NULL_INDEX)) nb_elmt = GMH_DEF_SIZE;
  if((step_size < 1)||(step_size >= GMH_NULL_INDEX)) step_size = GMH_DEF_SIZE;
  if((key_size < 1) ||(key_size >= GMH_NULL_INDEX)) key_size = GMH_DEF_KEY_SIZE;
    
  p_hcode->modulo       = modulo;
  p_hcode->nb_max_elmt  = nb_elmt;
  p_hcode->step_size    = step_size;
  p_hcode->content_size = content_size;
  p_hcode->key_size     = key_size;
  p_hcode->prev_elmt    = GMH_NULL_INDEX;
  p_hcode->cur_elmt     = 0;
  p_hcode->f_cmp_key    = f_cmp_key;
  p_hcode->f_hash       = f_hash;
  p_hcode->p_fct_info   = p_fct_info;

  /*| Allocate the hcode table */

  p_hcode->a_head = (IGRushort *)malloc((p_hcode->modulo)*sizeof(IGRushort));
  if(!p_hcode->a_head){status=GM_E_NODYNMEM;gm$status();}
  for(index = 0; index < p_hcode->modulo; index++)
    p_hcode->a_head[index] = GMH_NULL_INDEX;
            
  /*| Allocate the link list */

  p_hcode->l_next = (IGRushort *)malloc((p_hcode->nb_max_elmt)*sizeof(IGRushort));
  if(!p_hcode->l_next){status =GM_E_NODYNMEM;gm$status(type = EXCEPTION_1);}
  for(index = 0; index < p_hcode->nb_max_elmt; index++)
    p_hcode->l_next[index] = index+1;

  /*| Allocate the key list */

  p_hcode->l_key = (char *)malloc((p_hcode->nb_max_elmt)*p_hcode->key_size);
  if(!p_hcode->l_key){status =GM_E_NODYNMEM;gm$status(type = EXCEPTION_2);}

  if(content_size)
    {
    /*" Allocate the content list of size %d\n",(p_hcode->nb_max_elmt)*content_size*/

    p_hcode->l_content = (char *)malloc((p_hcode->nb_max_elmt)*content_size);
    if(!p_hcode->l_content){status =GM_E_NODYNMEM;gm$status(type = EXCEPTION_3);}
    }
  else
    {
    /*| The content list is not requested */

    p_hcode->l_content = NULL;
  }/* if(content_size)*/
  status = GM_S_SUCCESS;

exception:
  switch(exception_type)
    {
    case EXCEPTION_3:
    free(p_hcode->l_key);

    case EXCEPTION_2:
    free(p_hcode->l_next);

    case EXCEPTION_1:
    free(p_hcode->a_head);
  }/* switch */
  return(status);
}/* GMh_activate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMh_disactivate                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_disactivate(p_hcode)
  /*
  Description : disactivate a hcode header : free the table of links :
                 p_hcode->l_next, the list header p_hcode->a_head, the 
                list of keys and the list p_hcode->l_content
  */                
  struct GMhcode *p_hcode;    /* OUT      hcode table to disactivate          */

  /*.GMh_disactivate */
  {
  /*| Free hcode table */

  free(p_hcode->a_head);
  p_hcode->a_head = NULL;

  /*| Free the link list */

  free(p_hcode->l_next);
  p_hcode->l_next = NULL;

  /*| Free the key list */

  free(p_hcode->l_key);
  p_hcode->l_key = NULL;

  if(p_hcode->l_content)
    {
    /*| Free the content */
    
    free(p_hcode->l_content);
    p_hcode->l_content = NULL;
  }/* if(p_hcode->l_content)*/
  return(GM_S_SUCCESS);
}/* GMh_disactivate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMh_clear                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_clear(p_hcode)
  /*
  Description : Clear a hcode header : update all the free index of the
                hcode table

  */                
  struct GMhcode *p_hcode;    /* OUT      Hcode table to clear                */
  /*.GMh_clear */
  {
  IGRushort          index;      /* Index for a loop                             */
  
  /*| Free the index of the head table */

  for(index = 0; index < p_hcode->modulo; index++)
    p_hcode->a_head[index] = GMH_NULL_INDEX;
            
  /*| Update the link of the free elements */

  for(index = 0; index < p_hcode->nb_max_elmt; index++)
    p_hcode->l_next[index] = index+1;

  /*| Update the current indexes */
  
  p_hcode->prev_elmt = GMH_NULL_INDEX;
  p_hcode->cur_elmt  = 0;
  return(GM_S_SUCCESS);
}/* GMh_clear */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMh_add                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_add(p_key, p_content, p_hcode)
  /*
  Description : Add an element in the hcode table if this element is not in it
  */
  char           *p_key;      /* IN       Pointer to the Key of the element   */
  char           *p_content;  /* IN       Content of the element to add       */
  struct GMhcode *p_hcode;    /* OUT      Hcode table                         */
  /*.GMh_add */
  {
  IGRushort    index_h;          /* Index of the element in the hcode table      */
  IGRushort    index_l;          /* Index of the element in the list : index_h   */
  IGRushort    index;            /* Index for a loop                             */
  unsigned  int   new_size;   /* New size of the array of elements            */
  int  status = GM_S_SUCCESS; /* Status of the function                       */
  
  /*| Compute the index of this new elmt */
  
  index_h = GMH_HEAD_INDEX(p_key,p_hcode);
 
  /*" Test if the element is in the list %d\n",index_h*/

  if(!GMh_in_list(p_key,index_h,p_hcode,&index_l))
    {
    /*| Test the maximum size of the List */

    if (p_hcode->cur_elmt >= p_hcode->nb_max_elmt)
      {
      /*| Reallocate memory */
      
      new_size = (int)p_hcode->nb_max_elmt+p_hcode->step_size;
      if (new_size >= GMH_NULL_INDEX)
        {
        new_size = GMH_NULL_INDEX-1;
        if(new_size <= p_hcode->nb_max_elmt){status=GM_E_OUT_OF_RANGE;gm$status();}
      }/* if (new_size*/

      p_hcode->l_key = (char *)realloc(p_hcode->l_key,new_size*p_hcode->key_size);
      if(!p_hcode->l_key){status =GM_E_NODYNMEM;gm$status();}

      p_hcode->l_next = (IGRushort *)realloc(p_hcode->l_next,new_size*sizeof(IGRushort));
      if(!p_hcode->l_next){status =GM_E_NODYNMEM;gm$status();}
      for(index = p_hcode->nb_max_elmt; index<(IGRushort)new_size; index++)
 	p_hcode->l_next[index] = index+1;

      if(p_hcode->l_content != NULL)
        {
        p_hcode->l_content = (char *)realloc(p_hcode->l_content,new_size*(p_hcode->content_size));
        if(!p_hcode->l_content){status =GM_E_NODYNMEM;gm$status();}
      }/* if(p_hcode->l_content)*/
      
      p_hcode->nb_max_elmt=(IGRushort)new_size;
    }/* if (p_hcode->cur_elmt) */

    /*| Insert the element in the hcode */
 
    status = GMh_insert_in_list(p_key,p_content,index_h,p_hcode);
    }
  else
    {
    /*| Modify the element */
    
    memcpy((p_hcode->l_content)+(index_l*(p_hcode->content_size)),p_content,p_hcode->content_size);
  }/* if (!GMh_in_list) */
exception:
  return(status);
}/* GMh_add */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMh_remove                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_remove(p_key, p_hcode)
  /*
  Description : Remove an element in the hcode table , if this element does
                not exist, return (FALSE)
  */
  char           *p_key;      /* IN       Pointer to the Key of the element   */
  struct GMhcode *p_hcode;    /* OUT      Hcode table                         */
  /*.GMh_remove */
  {
  int  status = GM_S_SUCCESS; /* Status of the function                       */
  IGRushort    index_h;          /* Index of the element in the hcode table      */
  IGRushort    index_l;          /* Index of the element in the list : index_h   */
  
  /*| Compute the index of this new elmt */
  
  index_h = GMH_HEAD_INDEX(p_key,p_hcode);

  /*" Test if the element is in the list %d\n",index_h*/

  if(GMh_in_list(p_key,index_h,p_hcode,&index_l))
    {
    /*| Remove it from the List */

    if(p_hcode->prev_elmt != GMH_NULL_INDEX) 
      p_hcode->l_next[p_hcode->prev_elmt] = p_hcode->l_next[index_l];
    else
      p_hcode->a_head[index_h] = p_hcode->l_next[index_l];
    
    /*| Update the new current element */

    p_hcode->l_next[index_l] = p_hcode->cur_elmt;
    p_hcode->cur_elmt = index_l;
    }
  else
    {
    /*| The element is not in the list */

    status =  GM_W_ELMT_NOT_FOUND;
  }/* if (GMh_in_list)*/
  return(status);
}/* GMh_remove */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function GMh_give_content                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_give_content(p_key, p_hcode, pp_content, p_index)
  /*
  Description : Given the field p_content->key, fill the pointer to the content
                (*pp_content). If this element does not exist, return FALSE.
                the returned value p_index can be used by the function
                "GMh_content" to modify the content of this element.

  Constraint :  if pp_content == NULL the value p_index is not fiiled
  */
  char            *p_key;      /* IN       Pointer to the Key of the element  */
  struct GMhcode  *p_hcode;    /* IN       Hcode table                        */
  char            **pp_content;/* OUT      Pointer to the ptr of the content  */
  IGRushort          *p_index;    /* OUT      Index of the element in l_next     */
  /*.GMh_give_content*/
  {
  IGRushort          index_h;     /* Index of the element in the hcode table     */
  IGRushort          index_l;     /* Index of the element in the list : index_h  */
  int             status;      /* Status of the function                      */

  /*| Compute the index of the element */
  
  index_h = GMH_HEAD_INDEX(p_key,p_hcode);
  
  /*" Find this element in the list %d\n",index_h */
  
  status = GMh_in_list(p_key,index_h,p_hcode,&index_l);
  
  if(status)
    {
    /*| The element is in the list */

    if(p_index) *p_index =index_l;
    if(pp_content)
      *pp_content =(char *)((p_hcode->l_content)+(index_l*(p_hcode->content_size)));
  }/* if(status) */
  return(status);
}/* GMh_give_content */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMh_duplicate                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_duplicate(p_hcode, p_dup_hcode)
  /*
  Description : duplicate a hcode in an other
  */ 
  /*.GMh_duplicate */
                 
  struct GMhcode *p_hcode;        /* IN       hcode table to duplicate        */
  struct GMhcode *p_dup_hcode;    /* OUT      copy of the hcode table         */
  {
  int status = GM_S_SUCCESS;      /* Status of the function                   */
  int exception_type = NULL;      /* Type of exception if degraded mode       */

  /*| Initialize all the fields */
  
  *p_dup_hcode = *p_hcode;

  /*| Duplicate the hcode table */

  p_dup_hcode->a_head = (IGRushort *)malloc((p_hcode->modulo)*sizeof(IGRushort));
  if(!p_dup_hcode->a_head){status =GM_E_NODYNMEM;gm$status();}
  memcpy(p_dup_hcode->a_head,p_hcode->a_head,(p_hcode->modulo)*sizeof(IGRushort));
            
  /*| Duplicate the next list */

  p_dup_hcode->l_next = (IGRushort *)malloc((p_hcode->nb_max_elmt)*sizeof(IGRushort));
  if(!p_dup_hcode->l_next){status =GM_E_NODYNMEM;gm$status(type = EXCEPTION_1);}
  memcpy(p_dup_hcode->l_next,p_hcode->l_next,(p_hcode->nb_max_elmt)*sizeof(IGRushort));

  /*| Duplicate the key list */

  p_dup_hcode->l_key = (char *)malloc((p_hcode->nb_max_elmt)*p_hcode->key_size);
  if(!p_dup_hcode->l_key){status =GM_E_NODYNMEM;gm$status(type = EXCEPTION_2);}
  memcpy(p_dup_hcode->l_key,p_hcode->l_key,(p_hcode->nb_max_elmt)*p_hcode->key_size);

  if(p_hcode->l_content != NULL)
    {
    /*| Duplicate the content list */

    p_dup_hcode->l_content = (char *)malloc((p_hcode->nb_max_elmt)*(p_hcode->content_size));
    if(!p_dup_hcode->l_content){status =GM_E_NODYNMEM;gm$status(type = EXCEPTION_3);}
    memcpy(p_dup_hcode->l_content,p_hcode->l_content,(p_hcode->nb_max_elmt)*(p_hcode->content_size));
  }/* if(p_hcode->l_content)*/

exception:
  switch(exception_type)
    {
    case EXCEPTION_3:
    free(p_hcode->l_key);

    case EXCEPTION_2:
    free(p_hcode->l_next);

    case EXCEPTION_1:
    free(p_hcode->a_head);
  }/* switch */
  return(GM_S_SUCCESS);
}/* GMh_duplicate */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function GMh_content                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

char *GMh_content(p_hcode, index)
  /*
  Description : Given the index of an element, return the pointer to the
                content of this one
  Constraint  : 
  */

  struct GMhcode  *p_hcode;    /* IN       Hcode table                        */
  IGRushort          index;       /* OUT      Index of the element to inquire    */
  /*.GMh_content*/
  {
  return GMH_CONTENT(p_hcode, index);
}/* GMh_content */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                function GMh_key                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

char *GMh_key(p_hcode, index)
  /*
  Description : Given the index of an element, return the pointer to the
                key of this one
  Constraint  : This function must be used very carefully, it returns a pointer
                to the key, but the user must use this value in READ ONLY MODE
                otherwise the hcode table is destroyed.
  */

  IGRushort          index;       /* OUT      Index of the element to inquire    */
  struct GMhcode *p_hcode;     /* IN       Hcode table                        */
  /*.GMh_key*/
  {
  return GMH_KEY(p_hcode, index);
}/* GMh_key */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function GMh_getlist                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_getlist(p_hcode, select_fctu, p_sel_argu, pp_index, p_nb_elmt)
  /*
  Description : Given the hcode and a selection function, returns the indexes
                of the selected elements
                This function has been created to query the hcode elements
   Note       : These indexes represent a snapshot of the hcode, so if you add
                or remove an element from the hcode you must take an other list
  */
  struct GMhcode  *p_hcode;     /* IN       Hcode table                       */
  int          (*select_fctu)();/* IN       User function to select an index  */
  char            *p_sel_argu;  /* IN       Arguments of the slect function   */
  IGRushort          **pp_index;   /* OUT      Pointer to array of indexes       */
  int             *p_nb_elmt;   /* OUT      Number of elements returned       */
  /*.GMh_getlist*/
  {
  int             index_head;   /* Index for a loop                           */
  int    status = GM_S_SUCCESS; /* Default status of the function             */
  IGRushort          pointer;      /* Internal pointer                           */
  int             index_size;   /* Internal pointer                           */
  static IGRushort *l_index = NULL;/* Array of all the hcode's keys              */

  index_size = sizeof(pointer);

  if(pp_index)
    {
    /*" Allocate the index list of size %d\n",(p_hcode->nb_max_elmt)*sizeof(pointer)*/

    if(l_index) free(l_index);
    l_index = (IGRushort *)malloc(p_hcode->nb_max_elmt*index_size);
    if(!l_index){status =GM_E_NODYNMEM;gm$status();}
    *pp_index = l_index;
  }/* if(pp_key)*/

  for(index_head=0, *p_nb_elmt=0; index_head<(int)p_hcode->modulo; index_head++)
    {
    pointer = p_hcode->a_head[index_head];

    while(pointer != GMH_NULL_INDEX)
      {
      if((!select_fctu) 
      ||select_fctu(GMH_KEY(p_hcode,pointer),GMH_CONTENT(p_hcode,pointer),p_sel_argu))
        {
        /*" Add the index %d\n",pointer*/

        if(pp_index) memcpy(&l_index[*p_nb_elmt],&pointer,index_size);
        (*p_nb_elmt)++;
      }/* if (!select_fctu)*/
      pointer = p_hcode->l_next[pointer];
    }/* while */
  }/* for(index_head)*/

exception:
  return(status);
}/* GMh_getlist */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function GMh_in_list                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_in_list(p_key, index_head, p_hcode, p_index_list)
  /*
  Description : Given the index (index_head) of element in the head table,
                fill the field p_hcode->prev_elmt = index of the previous
                element in the list 
                
                - if element is in the table, (*p_index_list) = index of the
                  element in the table,
  */
  char            *p_key;       /* IN       Pointer to the Key of the element */
  IGRushort          index_head;   /* IN       Index in the array of header      */
  struct GMhcode  *p_hcode;     /* OUT      Hcode table                       */
  IGRushort          *p_index_list;/* OUT      Index of the element in the list  */
  /*.GMh_in_list*/
  {
  int   status =  FALSE;        /* Default status of the function             */
  IGRushort          pointer;      /* Internal pointer                           */
  int             compare;      /* Lexicographic comparison                   */

  pointer = p_hcode->a_head[index_head];
  p_hcode->prev_elmt = GMH_NULL_INDEX;
    
  while(pointer != GMH_NULL_INDEX)
    {
    compare = p_hcode->f_cmp_key(p_key,GMH_KEY(p_hcode,pointer),p_hcode->p_fct_info);

    if(compare > 0)
      {
      /* The element is not found */
      
      p_hcode->prev_elmt = pointer;
      pointer = p_hcode->l_next[pointer];
      }
    else if(compare < 0)
      {
      /*| The element is not in the list */

      break;
      }
    else
      {
      /*| The element is in the list */
        
      status = TRUE;
      (*p_index_list) = pointer;
      break;
    }/* if(compare) */
  }/* while */
  return(status);
}/* GMh_in_list */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     INTERNAL function GMh_insert_in_list                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMh_insert_in_list(p_key, p_content, index_head, p_hcode)
  /*
  Description : Insert the element in the list p_hcode->a_head[index_head]
  */
  char            *p_key;     /* IN       Key to select the element           */
  char            *p_content; /* IN       Content of the element              */
  IGRushort          index_head; /* IN       Index in the array of header        */
  struct GMhcode  *p_hcode;   /* OUT      Hcode table                         */
  /*.GMh_insert_in_list*/
  {
  IGRushort          next_index; /* Index of the next current element            */
            
  next_index = p_hcode->l_next[p_hcode->cur_elmt];
  p_hcode->l_next[p_hcode->cur_elmt] = GMH_NULL_INDEX;

  if (p_hcode->a_head[index_head] == GMH_NULL_INDEX)
    {
    /*| The element is the first of the list*/

    p_hcode->a_head[index_head] = p_hcode->cur_elmt;
    }
  else
    {
    /*| Insert the element in the List */
 
    if(p_hcode->prev_elmt==GMH_NULL_INDEX)
      {
      /*| The element is the first of the list*/
      
      p_hcode->l_next[p_hcode->cur_elmt] = p_hcode->a_head[index_head];
      p_hcode->a_head[index_head] = p_hcode->cur_elmt;
      }
    else
      {
      p_hcode->l_next[p_hcode->cur_elmt] = p_hcode->l_next[p_hcode->prev_elmt];
      p_hcode->l_next[p_hcode->prev_elmt] = p_hcode->cur_elmt;
    }/* if(p_hcode->prev_elmt) */
  }/* if (p_hcode->a_head)*/
  
  memcpy((p_hcode->l_content)+((p_hcode->cur_elmt)*(p_hcode->content_size)),
  p_content,p_hcode->content_size);
  memcpy((p_hcode->l_key)+((p_hcode->cur_elmt)*(p_hcode->key_size)),p_key,
  p_hcode->key_size);
  p_hcode->cur_elmt = next_index;
  return(GM_S_SUCCESS);
}/* GMh_insert_in_list */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
