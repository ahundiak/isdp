#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <EXproduct.h>
#include <OMprimitives.h>
#include <exproto.h>

#ifndef TRUE
#define TRUE	1
#endif
#ifndef FALSE
#define FALSE	0
#endif

extern struct EX_prod_def  *EX_product_list;

int get_modtype_data(run_name, logo_ptr, module_class, srch_path,
                     config_path, product_path)
char  *run_name,
      *logo_ptr,
      *module_class,
      *srch_path,
      *config_path,
      *product_path;
{
   int                  name_found = FALSE;
   struct EX_prod_def   *prodDef = EX_product_list;

   while (prodDef)
   {
      if (!strcmp(prodDef->run_name, run_name))
      {
         name_found = TRUE;
         if (logo_ptr)
            strcpy(logo_ptr, prodDef->logo);
         if (module_class)
            strcpy(module_class, prodDef->module);
         if (srch_path)
            strcpy(srch_path, prodDef->srch_path);
         if (config_path)
            strcpy(config_path, prodDef->config_path);
         if (product_path)
            strcpy(product_path, prodDef->product_path);
         break;
      }
      prodDef = prodDef->next;
   }
   return(name_found ? 1 : 0);
}  /* get_modtype_data */



struct EX_nl 
{
   char name[15];
   struct EX_nl *next;
   struct EX_nl *prev;
};

int EX_get_dependency( srch_path,  na)
char *srch_path; struct EX_nl *na;
{
  struct EX_nl *tt, *t1;
  struct EX_nl *start, *ende, *n1;
  char *temp, *colon;
  int status;

  start = NULL; 
   
     /* expand dep list */
   
     if( srch_path[strlen(srch_path)-1] != ':') strcat(srch_path,":");
     temp = strchr(srch_path,':');
     start = NULL;
     ende = NULL;
     t1 = na;
     while (t1->next != NULL) t1 = t1->next;
     
     while( (temp != NULL) && (*temp != '\0') )
     {
	 if( *temp == ':') temp++;
	 if( (colon = strchr( temp,':')) != NULL)
	 {
	     tt = (struct EX_nl *) om$malloc(size=sizeof(struct EX_nl));
	     tt->next = NULL;
             tt->prev = NULL;
	     if( start == NULL ) start = tt;
	     ende = tt;
	     *colon = '\0';  
	     strcpy(tt->name,temp);
	     t1->next = tt;
	     tt->prev = t1;
             t1 = tt;
	     temp = colon + 1; 
	 }
     }	
     n1 = start;
     while( n1 != ende  && n1 != NULL)
     {
          status=  get_modtype_data(n1->name, (char *) NULL, (char *) NULL,
            srch_path, (char *) NULL, (char *) NULL);
          if( status==TRUE)
          {
	      EX_get_dependency(srch_path, na);
          }
          else
	  {
             /* no error msg jusr ignore the entry, pdu problem */ 
            /*  printf("In EX_get_dependency can not find %s entry in product data\n", n1->name); */
	  }
          n1 = n1->next;
     }
     if( ende != NULL )
     {
	status=  get_modtype_data(ende->name, (char *) NULL, (char *) NULL,
	   srch_path, (char *) NULL, (char *) NULL);
	if( status==TRUE)
	{
	     EX_get_dependency(srch_path, na);
	}
/*
        else
	{
          printf("In EX_get_dependency can not find %s entry in product data\n", n1->name);
	}
*/
     }
    return(1);
}

int EX_rm_dup_dep( srch_path1, name)
char *srch_path1; struct EX_nl *name;
{
   int i; 
   int num;
   char *temp, *colon;
   struct EX_nl *n1, *t1, *t2, *ende = NULL;

 /* get number of initial entry */
    num = 0;
    temp = srch_path1;
    while( (colon=strchr(temp,':')) != NULL)
    {
       num++;
       temp = colon + 1;
    }

 /* get the end dep of srch path */
    n1 = name;
    for ( i=num; i >0 ; --i)
    {
       ende = n1;
       n1=n1->next; 
    }

 /* go to the end */
    t1 = name;
    while (t1->next != NULL) t1 = t1->next;

 /* process from back */
    while( t1 != ende )
    {
       t2 = t1; 
       while( (t2->prev != NULL ) && t2->prev != ende)
       {
	   n1= t2->prev;
	   if ( ! strcmp( n1->name, t1->name) )   /* same name */
	   {
		n1->prev->next = n1-> next;
		n1->next->prev = n1->prev;
		om$dealloc(ptr=n1);
	   }
	   else
	   {
		t2 = n1;
	   }
       }
       t1=t1->prev;
    }

 /* process from front */
   t1 = name;
   while( (t1 != ende ->next) && (ende->next != NULL) )
   {
       t2 = ende; 
       while( t2->next != NULL ) 
       {
	   n1= t2->next;
	   if ( ! strcmp( n1->name, t1->name) )   /* same name */
	   {
		n1->prev->next = n1-> next;
		n1->next->prev = n1->prev;
		om$dealloc(ptr=n1);
	   }
	   else
	   {
		t2 = n1;
	   }
       }
       t1=t1->next;
   }   
   return(1);
}

