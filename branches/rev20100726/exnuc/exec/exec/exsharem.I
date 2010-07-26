 class implementation exec;
#define testing 0
#include <stdio.h>
#include <string.h>

struct EX_memnode
{
    struct EX_memnode *next;
    struct EX_memnode *prev;
    unsigned long int    mem_val;
    char                 mem_name[80];
};


extern struct EX_memnode  *EXmem ;



int EX_mem_exist()
{
   return( ( EXmem == NULL ) ? 0 : 1 );
}


int EX_add_mem(   mem_name ,mem_val)
char      *mem_name;
unsigned long int mem_val;
{
   struct EX_memnode *t, *tp  /* previous t */;
   int found, sm_size;
   found = 0;
   t = EXmem;
   tp = NULL;
   while( t != NULL && found == 0 )
   {
       if( !strcmp(t->mem_name,mem_name) ) 
       {
           t->mem_val = mem_val;
           found = 1;
       }
       else
       {
          tp = t;
	  t = t->next;
       }
   }

   if ( t == NULL )
   {
        sm_size = sizeof(struct EX_memnode);
 	t = (struct EX_memnode *) om$sm_malloc(size = sm_size);
	t -> mem_val = mem_val;
        strncpy(t -> mem_name, mem_name, 80 );
	t -> next = NULL;
	t -> prev = tp;
        if ( tp == NULL ) EXmem = t;
	else tp -> next = t;

   }

   return(1);
}

int EX_get_mem( mem_name, mem_val )
char      *mem_name;
unsigned long int *mem_val;
{
      struct EX_memnode *t;
         int found;
	 found = 0;


	  t = EXmem;
	  while( t !=NULL )
  	  {

             if( !strcmp( t->mem_name, mem_name) )
             {
	        *mem_val = t->mem_val;
                 found = 1;
		t = NULL;
	     }
	     else
	     {
           	t = t -> next;
	     }
	  }
   return(found);
}


int EX_del_mem( mem_name )
char      *mem_name;
{
      struct EX_memnode *t;
         int found;
	 found = 0;

	  t = EXmem;
	  while( t !=NULL )
  	  {
             if( !strcmp( t->mem_name, mem_name) )
             {
                 if ( t->next == NULL ) t->prev->next = NULL;
		 else
		 {
		    t->next->prev = t->prev;
		    if(t->prev != NULL)t->prev->next = t->next;
                    om$sm_dealloc(ptr = (char *)t);
		 }  
                 found = 1;
		 t = NULL;
	     }
	     else
	     {
           	t = t -> next;
	     }
	  }
   return(found);
}



void EX_print_mem( )
{
   struct EX_memnode *t;

   t = EXmem;

   while (  t!= NULL )
   {
       printf("mem_name=<%s> mam_val=<%x>\n",t->mem_name, t->mem_val);
       t= t->next;
   }
}

void EX_free_mem( )
{
   struct EX_memnode *t, *t1;
   t = EXmem;
   while (  t!= NULL )
   {
       t1 = t;
       t= t->next;
       om$sm_dealloc(ptr = (char *)t1);
   }
}


end implementation exec;
