#include <stdio.h>
#include <malloc.h>
#include <exdef.h>
#include <expriv.h>
#include <exproto.h>



static struct EX_funnode  *EXend_fun = NULL;
static struct EX_funnode  *EXstart_fun = NULL;
static struct EX_funnode  *EXcmdserver_fun = NULL;
static EX_end_func_called = 0;

void EX_add_fun(struct EX_funnode **phead, int isfunc, void *f )
{
   struct EX_funnode *t;

   t = *phead;
   while( t != 0 )
   {
     if ( t->isfun && t->entry.fun == (int (*)()) (unsigned long) f )
       break;  /* if fun already added, stop */
     if ( ! t->isfun && t->entry.cmdkey == (char *) f )
       break;  /* if cmdkey already added, stop */
     t = t->next;
   }

   if ( t == NULL )
   {
     t = (struct EX_funnode *) malloc(sizeof(struct EX_funnode));
     t -> isfun = isfunc;
     if ( isfunc )
       t->entry.fun = (int (*)()) (unsigned long) f;
     else
       t->entry.cmdkey = (char *) f;
     t -> next = *phead;
     t -> prev = NULL;
     if( *phead != NULL ) (*phead) -> prev = t;
     (*phead) = t;
   }
}

void EX_cmdserver_fun( phead, f )
struct EX_funnode **phead;
void *f;
{
   EX_add_fun( phead, 1, f );
}

void EX_del_fun( phead, f )
struct EX_funnode **phead;
int (*f)(); 
{
   struct EX_funnode *t, *temp;
   
   if( (*phead) != NULL)
   {
      if( (*phead)->entry.fun == f )
      {
          temp = *phead;
	  *phead = (*phead)->next;
	  if( *phead != NULL )  (*phead)->prev = NULL;
	  free( (char *) temp );    
      }
      else
      {
	  t = *phead;
	  while( t->next !=NULL && t->next->entry.fun != f)
	  {
		t = t -> next;
	  }
	  if( t-> next != NULL )
	  {
	      temp = t -> next;
	      t->next = (t->next) -> next;
	      if( (t->next) != NULL ) (t->next) -> prev = t;
	      free( (char *) temp);
	  }
      }
   }
}


void EX_empty_fun (phead)
struct EX_funnode **phead;
{
    struct EX_funnode  *t;

    while ( *phead != NULL )
    {
       t = *phead;
       *phead = (*phead)->next;
       free( (char *) t);        
    }

}

void EX_print_fun(phead )
   struct EX_funnode **phead;
{
   struct EX_funnode *t, *t1;

   t = *phead;
   t1 = NULL;

   printf( "list forward\n" );
   while (  t!= NULL )
   {
       printf( "isfun = %d\n", t->isfun );
       if ( t->isfun )
         printf( "fun = 0x%x\n", t->entry.fun );
       else
         printf( "cmdkey = 0x%x\n", t->entry.cmdkey );
       t1 = t;
       t= t->next;
   }

   printf( "\nlist backward\n" );
   while (  t1 != NULL )
   {
       printf( "isfun = %d\n", t1->isfun );
       if ( t->isfun )
         printf( "fun = 0x%x\n", t1->entry.fun );
       else
         printf( "cmdkey = 0x%x\n", t1->entry.cmdkey );
       t1 = t1->prev;
   }
}

/* This function was used by macro */
int EX_add_function( fun, mode)
int (*fun)();
int mode;
{
	if ( mode == EX_START_FUNC )
	{
	  EX_add_fun( &EXstart_fun, 1, (void *) (unsigned long) fun );
	}
	if ( mode == EX_END_FUNC   )
	{
	  EX_add_fun( &EXend_fun, 1, (void *) (unsigned long) fun );
	}

	return(1);
}

int EX_del_function( fun, mode)
int (*fun)();
int mode;
{
	if ( mode == EX_START_FUNC )
	{
	  EX_del_fun( &EXstart_fun, fun );
	}
	if ( mode == EX_END_FUNC   )
	{
	  EX_del_fun( &EXend_fun, fun );
	}

	return(1);
}

/* this function was called in wfi */
int EX_call_start_func()
{
   struct EX_funnode *t;

   if( EX_end_func_called )
   {
     EX_end_func_called = 0; 
     t = EXstart_fun;
     while( t != NULL)
     {
        if ( t->isfun )
          (*(t->entry.fun))();
	t=t->next;
     }
   }
return(1);   
}


/* this function was called in wfi */
EX_call_end_func()
{
   struct EX_funnode *t;


     t = EXend_fun;
     while( t != NULL)
     {
        if ( t->isfun )
          (*(t->entry.fun))();
	t=t->next;
     }
     EX_end_func_called = 1;
return(1);     
}



int EX_add_cmdserver_function( fun )
int (*fun)();
{
  EX_add_fun( &EXcmdserver_fun, 1, (void *) (unsigned long) fun );
  return(1);
}

int EX_del_cmdserver_function( fun )
int (*fun)();
{
  EX_del_fun( &EXcmdserver_fun, fun );
  return(1);
}

int EX_call_cmdserver_func(mode)
int mode;
{
   struct EX_funnode *t;

    t = EXcmdserver_fun;
    while( t != 0)
    {
        if ( t->isfun )
          (*(t->entry.fun))(mode);
	t=t->next;
    }
    return(1);    
}


char  *EX_get_and_del_first_fun (phead)
struct EX_funnode **phead;
{
  char *ptr;
  /* this function used by cmdserver to manipulate initialization commands */
  struct EX_funnode  *t;

   if( *phead != 0 )
   {
     t = *phead;
     ptr = t->entry.cmdkey;
     *phead = (*phead)->next;
     free( (char *) t);
     return(ptr);
  }
  return( 0 );
}
