/*  file: parddp.c
**
**  This file is the parser for ddp output files.
**  Its purpose is to build a data structure which
**  will represent the instance data for a given
**  conponent of a class.  All data structures that
**  are needed are in trans.h
*/

/*============*/
/*  includes  */
/*============*/

#include "stdio.h"
#include "trans.h"
extern char *getname(), *getnode();

/*===========*/
/*  globals  */
/*===========*/

char *dros_codenames[] = {"NULL", "CHAR", "UCHAR", "SHORT", "USHORT", "INT",
                          "UINT", "LONG", "ULONG", "FLOAT", "DOUBLE", "STRING",
                          "CHANNEL", "POINTER", "ARRAY", "VARARRAY",
                          "BITFIELD", "FUNCTION", "STRUCT", "UNION", 
                          "ENUMERATION", "ENUM_FIELD", "CLASS" };


short          **pp_next_node;
DROS_p_PARENT  *pp_next_parent;
DROS_p_REJECT  *pp_next_reject;
DROS_p_CTYPE   *pp_next_ctype;
DROS_p_CHTYPE  *pp_next_chtype;
DROS_p_REST    *pp_next_rest;


/*=========================*/
/*  function: dros_parddp  */
/*=========================*/

int dros_parddp ( file_name, p_class, class_ndx )
char         *file_name;
DROS_p_CLASS  p_class;
int           class_ndx;
{
   int            i;
   FILE          *f;
   char           key[24], msg[80];
   char           ch1[24], ch2[24], ch3[24];
   int            n1, n2, n3, n4;
   DROS_p_PARENT  p_parent;
   DROS_p_REJECT  p_reject;
   DROS_p_FIELD   p_field, p_field2, p_field3;
   DROS_p_CTYPE   p_ctype;
   DROS_p_CHTYPE  p_chtype;
   DROS_p_REST    p_rest;
   DROS_p_ATTR    p_attr;
   DROS_p_CHANNEL p_chan;


   /*=========================*/
   /*  open file as readonly  */
   /*=========================*/

   f = fopen ( file_name, "r" );
   if (!f) { 
      sprintf(msg,"Error opening file %s :",file_name);
      perror (msg);
      return(0);
   }

   /*============================*/
   /*  initialize next pointers  */
   /*============================*/

   pp_next_node   = &p_class->p_node;
   pp_next_parent = &p_class->p_parent;
   pp_next_reject = &p_class->p_reject;
   pp_next_ctype  = &p_class->p_ctype;   
   pp_next_chtype = &p_class->p_chtype;   

   /*===================================================================*/
   /*  loop to read until EOF                                           */
   /*  loop internals are simply test for major keyword and then parse  */
   /*  the file based on the semantics of the appropriate keyword       */
   /*===================================================================*/

   while (1) {
      if (EOF == fscanf(f,"%s",key)) break;

      if (!strcmp(key,"CLASSNAME")) {
         fscanf(f,"%s %d %d %d %d",ch1,&n1,&n2,&n3,&n4);
      }
      else if (!strcmp(key,"PARENT")) {
         fscanf(f,"%s %d %d",ch1,&n1,&n2);
         p_parent = (DROS_p_PARENT)getnode(1, parent_struct);
         if (!p_parent) {
		fprintf(stderr, "dros_parddp: getnode failure for parent\n");
		break;
         }

         p_parent->class  = getname(ch1);
         p_parent->major  = n1;
         p_parent->minor  = n2;
         p_parent->p_next = 0;
         *pp_next_parent  = p_parent;
         pp_next_parent   = &p_parent->p_next;
      }
      else if (!strcmp(key,"CTYPE")) {
         fscanf(f,"%s %s %d",ch1,ch2,&n1);
         p_ctype = (DROS_p_CTYPE)getnode(1, ctype_struct);
         if (!p_ctype) {
		fprintf(stderr, "dros_parddp: getnode failure for ctype\n");
		break;
         }
         p_ctype->name    = getname(ch1);
         p_ctype->code    = dros_cvt_code(ch2);
         p_ctype->size    = n1;
         p_ctype->p_field = 0;
         *pp_next_ctype   = p_ctype;
         p_ctype->p_next  = 0;
         pp_next_ctype    = &p_ctype->p_next;
      }
      else if (!strcmp(key,"TYPEFIELD")) {
         fscanf(f,"%s %s %d",ch1,ch2,&n1);
         p_field = (DROS_p_FIELD)getnode(1, field_struct);
         if (!p_field) {
		fprintf(stderr, "dros_parddp: getnode failure for type_field\n");
		break;
         }
         p_field->name = getname(ch2);
         p_field->list_size = n1;
         get_ctype_list(f, n1, &p_field->p_list);
         fscanf(f,"%d %d %s",&n2,&n3,ch3);
         p_field->offset = n2;
         p_field->size   = n3;
         p_field->p_next = 0;
         if (strcmp(ch3,"|||"))
	 {
            if (!find_ctype(p_class,class_ndx,ch3,&p_field->p_ctype))
			p_field->p_ctype = 0;
	 }
         else p_field->p_ctype = 0;

         p_ctype = p_class->p_ctype;
         while (p_ctype) {
            if (!strcmp(p_ctype->name,ch1)) {
               if (p_ctype->p_field) {
		  p_field3 = NULL;
                  p_field2 = p_ctype->p_field;
                  while (p_field2 && (p_field2->offset < p_field->offset))
		  {
			p_field3 = p_field2;
			p_field2 = p_field2->p_next;
		  }
                  if (p_field3) p_field3->p_next = p_field;
		  else		p_ctype->p_field = p_field;
		  p_field->p_next = p_field2;
               }
               else {
                  p_ctype->p_field = p_field;
               }
               break;
            }
            p_ctype = p_ctype->p_next;
	 }
      }
      else if (!strcmp(key,"CHANTYPE")) {
         fscanf(f,"%s %d %d %d %d",ch1,&n1,&n2,&n3,&n4);
         p_chtype = (DROS_p_CHTYPE)getnode(1, chtype_struct);
         if (!p_chtype) {
		fprintf(stderr, "dros_parddp: getnode failure for chtype\n");
		break;
         }
         p_chtype->name   = getname(ch1);
         p_chtype->type   = n1;
         p_chtype->init   = n2;
         p_chtype->incr   = n3;
         p_chtype->p_rest = 0;
         p_chtype->p_next = 0;
         *pp_next_chtype  = p_chtype;
         pp_next_chtype   = &p_chtype->p_next;
         pp_next_rest     = &p_chtype->p_rest;
      }
      else if (!strcmp(key,"CHANNEL")) {
         fscanf(f,"%s %s %d %d",ch1,ch2,&n1,&n2);
         p_chan = (DROS_p_CHANNEL)getnode(1, channel_struct);
         if (!p_chan) {
		fprintf(stderr, "dros_parddp: getnode failure for channel\n");
		break;
         }
         p_chan->node_type = DROS_CHAN_TYPE;
         p_chan->name = getname(ch1);
         p_chan->offset = n1;
         p_chan->p_next = 0;
         p_chtype = p_class->p_chtype;
         while (p_chtype) {
            if (!strcmp(p_chtype->name,ch2)) {
               p_chan->p_chtype = p_chtype;
               break;
            }
            p_chtype = p_chtype->p_next;
         }
         *pp_next_node  = (short *)p_chan;
         pp_next_node   = &p_chan->p_next;
      }
      else if (!strcmp(key,"ATTRIBUTE")) {
         fscanf(f,"%s %d %d",ch1,&n1,&n2);
         p_attr = (DROS_p_ATTR)getnode(1, attr_struct);
         if (!p_attr) {
		fprintf(stderr, "dros_parddp: getnode failure for attr\n");
		break;
         }
         p_attr->node_type = DROS_ATTR_TYPE;
         p_attr->name = getname(ch1);
         p_attr->list_size = n2;
         get_ctype_list(f, n2, &p_attr->p_list);
         fscanf(f,"%d %d %s",&n3,&n4,ch2);
         p_attr->offset = n3;
         p_attr->size   = n4;
         if (strcmp("|||",ch2)) {
            if (!find_ctype(p_class,class_ndx,ch2,&p_attr->p_ctype))
	    {
		p_attr->p_ctype = 0;
	    }
         }
         else {
            p_attr->p_ctype = 0;
         }
         p_attr->p_next = 0;
         *pp_next_node = (short *)p_attr;
         pp_next_node  = &p_attr->p_next;
      }
      else if (!strcmp(key,"MESSAGE")) {
         fscanf(f,"%s %d",ch1,&n1);
      }
      else if (!strcmp(key,"MSGPARM")) {
         fscanf(f,"%s %s %d",ch1,ch2,&n1);
         for (i=0; i<n1; ++i) fscanf(f,"%s",ch1);
         fscanf(f,"%d %d %s",&n2,&n3,ch3);
      }
      else if (!strcmp(key,"OMREST")) {
         fscanf(f,"%s %s %d %d %s",ch1,ch2,&n1,&n2,ch3);
         p_rest = (DROS_p_REST)getnode(1, rest_struct);
         if (!p_rest) {
		fprintf(stderr, "dros_parddp: getnode failure for rest\n");
		break;
         }
         p_rest->class = getname(ch2);
         if (strcmp(ch3,"|||"))
              p_rest->chan = getname(ch3);
         else p_rest->chan = NULL;
         p_rest->p_next = 0;
         *pp_next_rest  = p_rest;
         pp_next_rest   = &p_rest->p_next;
      }
      else if (!strcmp(key,"REJECTED_INSTANCE")) {
         fscanf(f,"%s %d %d",ch1,&n1,&n2);
         p_reject = (DROS_p_REJECT)getnode(1, reject_struct);
         if (!p_reject) {
		fprintf(stderr, "dros_parddp: getnode failure for reject\n");
		break;
         }
         p_reject->class  = getname(ch1);
         p_reject->major  = n1;
         p_reject->minor  = n2;
         p_reject->p_next = 0;
         *pp_next_reject  = p_reject;
         pp_next_reject   = &p_reject->p_next;
      }
      else {
         printf ("Unknown keyword detected <%s>\n", key);
         return(0);
      }
   }
   fclose(f);
   return(1);
}


/*============================================================*/
/*  function: get_ctype_list                                  */
/*  parses and returns representation for generic ctype list  */
/*============================================================*/

get_ctype_list ( f, num, pp_list )
FILE  *f;
int    num;
int  **pp_list;
{
   int  i;
   char ch[24];

   /*=================*/
   /*  allocate list  */
   /*=================*/

   *pp_list = (int *)getnode(num, integer);
   if (!*pp_list) {
      printf ("Could not allocate memory for ctype list\n");
      return (0);
   }

   /*======================*/
   /*  loop via list size  */
   /*======================*/

   for ( i=0; i<num; ++i ) {
      fscanf(f,"%s",ch);

      /*===========================================*/
      /*  check if numeric (e.g. array dimension)  */
      /*===========================================*/

      if ( ch[0] > 47 && ch[0] < 58 ) {
         (*pp_list)[i] = (unsigned int)atoi(ch);
         (*pp_list)[i] |= 0x80000000;       /* flag as numeric value */
      }
      else {
         (*pp_list)[i] = dros_cvt_code(ch);
      }
   }
   return(1);
}


/*================================================================*/
/*  function: dros_cvt_code                                       */
/*  convert ascii code name to internal representation (integer)  */
/*================================================================*/

int dros_cvt_code ( str )
char *str;
{
   int i;

   for (i=0; i<DROS_NUM_CODES; ++i) {
      if (!strcmp(str,dros_codenames[i])) return(i);
   }
   return(0);   /* if not found return null code */
}


/*===================================================================*/
/*  function: find_ctype                                             */
/*  provide lookup for ctype in current and ancestor classes         */
/*===================================================================*/

int find_ctype ( p_class, class_ndx, str, pp_ctype )
DROS_p_CLASS  p_class;
int           class_ndx;
char         *str;
DROS_p_CTYPE *pp_ctype;
{
   int           i;
   DROS_p_CTYPE  p_ctype;
   extern int class_count;

   for (i=0; i<=class_ndx; ++i) {
      p_ctype = (p_class-i)->p_ctype;
      while (p_ctype) {
         if (!strcmp(str,p_ctype->name)) {
            *pp_ctype = p_ctype;
            return (1);
         }
         p_ctype = p_ctype->p_next;
      }
   }

   return(0);
}


/*===================================================================*/
/*  function: dros_parddp_free                                       */
/*  free memory allocated to store instance data representation      */
/*===================================================================*/

int dros_parddp_free (p_class)
DROS_p_CLASS p_class;
{
   short          *p_node;
   DROS_p_ATTR     p_attr;
   DROS_p_CHANNEL  p_chan;
   DROS_p_REST     p_rest;
   DROS_p_CTYPE    p_ctype;
   DROS_p_FIELD    p_field;
   DROS_p_CHTYPE   p_chtype;
   DROS_p_PARENT   p_parent;

   p_node = p_class->p_node;
   while (p_node) {
      if (*p_node == DROS_ATTR_TYPE) {
         p_attr = (DROS_p_ATTR)p_node;
         if (p_attr->p_list) free (p_attr->p_list);
         p_node = p_attr->p_next;
         free(p_attr);
      }
      else {
         p_chan = (DROS_p_CHANNEL)p_node;
         p_node = p_chan->p_next;
         free(p_chan);
      }
   }

   p_ctype = p_class->p_ctype;
   while (p_ctype) {
      p_field = p_ctype->p_field;
      while (p_field) {
         if (p_ctype->p_field->p_list) free (p_ctype->p_field->p_list);
         p_node = (short *)p_field->p_next;
         free (p_ctype->p_field);
         p_field = (DROS_p_FIELD)p_node;
      }
      p_node = (short *)p_ctype->p_next;
      free(p_ctype);
      p_ctype = (DROS_p_CTYPE)p_node;
   }

   p_parent = p_class->p_parent;
   while (p_parent) {
      p_node = (short *)p_parent->p_next;
      free(p_parent);
      p_parent = (DROS_p_PARENT)p_node;
   }

   p_chtype = p_class->p_chtype;
   while (p_chtype) {
      p_rest = p_chtype->p_rest;
      while (p_rest) {
         p_node = (short *)p_rest->p_next;
         free (p_rest);
         p_rest = (DROS_p_REST)p_node;
      }
      p_node = (short *)p_chtype->p_next;
      free(p_chtype);
      p_chtype = (DROS_p_CHTYPE)p_node;
   }
     
   return(1);
}

int dros_free_node (p_class)
DROS_p_CLASS p_class;
{
   short          *p_node;
   DROS_p_ATTR     p_attr;
   DROS_p_CHANNEL  p_chan;
   DROS_p_REST     p_rest;
   DROS_p_CTYPE    p_ctype;
   DROS_p_FIELD    p_field;
   DROS_p_CHTYPE   p_chtype;
   DROS_p_PARENT   p_parent;

   p_node = p_class->p_node;
   while (p_node) {
      if (*p_node == DROS_ATTR_TYPE) {
         p_attr = (DROS_p_ATTR)p_node;
         if (p_attr->p_list) free (p_attr->p_list);
         p_node = p_attr->p_next;
         free(p_attr);
      }
      else {
         p_chan = (DROS_p_CHANNEL)p_node;
         p_node = p_chan->p_next;
         free(p_chan);
      }
   }

   return(1);
}


/*===================================================================*/
/*  function: dros_dmpddp                                            */
/*  debug utility to dump contents of the resultant data structures  */
/*===================================================================*/

int dros_dmpddp ( p_class )
DROS_p_CLASS p_class;
{
   short          *p_node;
   unsigned short  i;
   DROS_p_ATTR     p_attr;
   DROS_p_REST     p_rest;
   DROS_p_CHANNEL  p_chan;

   /*===============================================*/
   /*  loop on the generic nodes (attr or channel)  */
   /*===============================================*/

   p_node = p_class->p_node;
   while (p_node) {
  
      /*==================*/
      /*  attribute case  */
      /*==================*/

      if (*p_node == DROS_ATTR_TYPE) {
         p_attr = (DROS_p_ATTR)p_node;
         printf ("--- Attribute : %s\n",p_attr->name);
         printf ("      Offset  : %d\n",p_attr->offset);
         printf ("      Size    : %d\n",p_attr->size);
         for (i=0; i<p_attr->list_size; ++i) {
            if (i==0)
               printf ("      Field   : %s\n",
                                      dros_codenames[p_attr->p_list[i]]);
            else {
               if (p_attr->p_list[i] &  0x80000000)
                  printf ("              : dimension %d\n",
                                         p_attr->p_list[i] & 0x7fffffff);
               else
                  printf ("              : %s\n",
                                         dros_codenames[p_attr->p_list[i]]);
            }
         }
         if (p_attr->p_ctype)
            printf ("              : %s\n",p_attr->p_ctype->name);
         p_node = p_attr->p_next;
      }

      /*================*/
      /*  channel case  */
      /*================*/

      else if (*p_node == DROS_CHAN_TYPE) {
         p_chan = (DROS_p_CHANNEL)p_node;
         printf ("--- Channel   : %s\n",p_chan->name);
         printf ("      Offset  : %d\n",p_chan->offset);
         printf ("      Type    : ");
         if (p_chan->p_chtype->type & DROS_1_1) printf ("1_1 ");
         if (p_chan->p_chtype->type & DROS_m_1) printf ("m_1 ");
         if (p_chan->p_chtype->type & DROS_1_m) printf ("1_m ");
         if (p_chan->p_chtype->type & DROS_m_m) printf ("m_m ");
         if (p_chan->p_chtype->type & DROS_abs) printf ("absordered ");
         if (p_chan->p_chtype->type & DROS_rel) printf ("relordered ");
         if (p_chan->p_chtype->type & DROS_res) printf ("restricted ");
         printf ("\n");
         printf ("      Initial : %d\n",p_chan->p_chtype->init);
         printf ("      Extend  : %d\n",p_chan->p_chtype->incr);
         if (p_rest = p_chan->p_chtype->p_rest) {
            printf ("      Restrict: ");
            while (p_rest) {
               printf ("%s",p_rest->class);
               if (p_rest->chan[0])
                  printf (".%s",p_rest->chan);
               printf (" ");
               p_rest = p_rest->p_next;
            }
            printf ("\n");
         }         
         p_node = p_chan->p_next;
      }
      else {
         printf ("**** Unrecognized node type ****\n");
         break;
      }
   }
   return (1);
}
