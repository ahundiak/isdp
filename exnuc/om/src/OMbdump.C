#include <stdio.h>
#include <string.h>
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMDB.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"
#include "OMbtreedef.h"


DB_dump_btree( child_ptr, nl_key_length, type)
long           *child_ptr;
KEY_LENGTH     nl_key_length;
unsigned char  type;
 
{
   long           *rid_array1_p, *rid_array2_p=NULL;
   long           *rid_array3_p=NULL;
   long           *rid_array4_p=NULL;
   int            end, i, j, k;
   B_LF_PAGE      *lfpage_ptr;
   B_NL_PAGE      *nlpage_ptr;
   char           *status,
                  *key1_p,
                  *key2_p=NULL;
   char           *key3_p=NULL;
   char           *key4_p=NULL;
   KEY_LENGTH     key1_len=0;
   KEY_LENGTH     key2_len=0;
   KEY_LENGTH     key3_len=0;
   KEY_LENGTH     key4_len=0;
   REC_PTR_COUNT  *count1_p,
                  *count2_p,
                  *count3_p,
                  *count4_p;
   OM_S_OBJID     tobj;
   OM_S_OBJID     *child_array1_p=NULL;
   OM_S_OBJID     *child_array2_p=NULL;
   OM_S_OBJID     *child_array3_p=NULL;
   OM_S_OBJID     *child_array4_p=NULL;
   OM_S_RIP       rip;
   unsigned short x, s;

   nlpage_ptr = (B_NL_PAGE *)child_ptr;
  
   printf("\n\n\n\n**************************************************************************");
   tobj = REF( OM_S_OBJID, nlpage_ptr );
   printf("\n\nCONTENTS PAGE %x\n\n", tobj );
   status = (nlpage_ptr->Page_type == B_LF_RT_PAGE ? "B_LF_RT_PAGE" :
            (nlpage_ptr->Page_type == B_NL_RT_PAGE ? "B_NL_RT_PAGE" :
            (nlpage_ptr->Page_type == B_LF_NR_PAGE ? "B_LF_NR_PAGE" :
            (nlpage_ptr->Page_type == B_NL_NR_PAGE ? "B_NL_NR_PAGE" :
                                                     "other" ))));

   printf("Page type:         \t%s\n", status);
   printf("Nonleaf key length:\t%u\n",nlpage_ptr->Nl_key_length);
   printf("Offset entry count:\t%u\n",nlpage_ptr->Offset_entry_count);
   printf("Space used:        \t%u\n",nlpage_ptr->Space_used);
   printf("Key start:         \t%u\n",nlpage_ptr->Key_start);
   if ( (nlpage_ptr->Page_type == B_LF_RT_PAGE) ||
      (nlpage_ptr->Page_type == B_LF_NR_PAGE))
   {
      lfpage_ptr = (B_LF_PAGE *)nlpage_ptr;
      printf("Next page:      \t%x\n", lfpage_ptr->Next_p );
      printf("Prior page:     \t%x\n", lfpage_ptr->Prior_p );
      printf("\n**************************************************************************");

      for (i = 0; i < (int) lfpage_ptr->Offset_entry_count; i += 4)
      {
         printf("\n\n\n");
         for ( j = i; j < i + 4 && j < (int) lfpage_ptr->Offset_entry_count;
              j++)
         {
            printf("entry:  %u",  j);
            if (j < i + 3)
            printf("\t");  
         }
         printf("\n");
         for ( k = i; k < j; k++)
         {
            printf("offset: %u",
               *(OFFSET_ENTRY *)(&lfpage_ptr->Offset_key_area[2*k]));
            if (k < i + 3)
               printf("\t");  
         }
         printf("\n");

         x = 0;
         count1_p = count2_p = count3_p = count4_p = &x;
     
         k = i;
         GET_LF_KEY_ENTRY(lfpage_ptr, k, key1_len, count1_p, key1_p,
            rid_array1_p);
         if (++k < j)
            GET_LF_KEY_ENTRY(lfpage_ptr, k, key2_len, count2_p, key2_p,
               rid_array2_p);
         if (++k < j)
            GET_LF_KEY_ENTRY(lfpage_ptr, k, key3_len, count3_p, key3_p,
               rid_array3_p);
         if (++k < j)
            GET_LF_KEY_ENTRY(lfpage_ptr, k, key4_len, count4_p, key4_p,
               rid_array4_p);
         k = i;
         printf("keylen: %u\t",  key1_len);
         if (++k < j)
            printf("keylen: %u\t",  key2_len);
         else
            printf("            \t\t");
         if (++k < j)
            printf("keylen: %u\t",  key3_len);
         else
            printf("            \t\t");
         if (++k < j)
            printf("keylen: %u\n",  key4_len);
         else
            printf("            \t\n");
     
         k = i;
         printf("# rids: %u\t",  *count1_p);
         if (++k < j)
            printf("# rids: %u\t",  *count2_p);
         else
            printf("            \t\t");
         if (++k < j)
            printf("# rids: %u\t",  *count3_p);
         else
            printf("            \t\t");
         if (++k < j)
            printf("# rids: %u\n",  *count4_p);
         else
            printf("            \t\n");
     
         if (type == BTREE_INTEGER)
         {
             k = i;
             printf("key:    ");
             printf("%d", *((int *)key1_p));
             printf("\t");
     
             if (++k < j)
             {
                printf("key:    ");
                printf("%d", *((int *)key2_p));
                printf("\t");
             }
             else
                printf("        \t\t");

             if (++k < j)
             {
                printf("key:    ");
                printf("%d", *((int *)key3_p));
                printf("\t");
             }
             else
                printf("        \t\t");

             if (++k < j)
             {
                printf("key:    ");
                printf("%d", *((int *)key4_p));
                printf("\n");
             }
             else
                printf("        \t\n");

         }
         else if (type == BTREE_STRING)
         {
            key1_len = strlen(key1_p);
            k = i;
            printf("key:    ");
            for (s = 0; s < key1_len; s++, key1_p++)
               printf("%c", *key1_p);
            for (; s < 7; s++)
               printf(" ");
            printf("\t");
     
            if (++k < j)
            {
                key2_len = strlen(key2_p);
                printf("key:    ");
                for (s = 0; s < key2_len; s++, key2_p++)
                   printf("%c", *key2_p);
                for (; s < 7; s++)
                   printf(" ");
                printf("\t");
            }
            else
               printf("        \t\t");

            if (++k < j)
            {
               key3_len = strlen(key3_p);
               printf("key:    ");
               for (s = 0; s < key3_len; s++, key3_p++)
                  printf("%c", *key3_p);
               for (; s < 7; s++)
                  printf(" ");
               printf("\t");
            }
            else
               printf("        \t\t");

            if (++k < j)
            {
               key4_len = strlen(key4_p);
               printf("key:    ");
               for (s = 0; s < key4_len; s++, key4_p++)
                  printf("%c", *key4_p);
               for (; s < 7; s++)
                  printf(" ");
               printf("\n");
            }
            else
               printf("        \t\n");
         }

         end = (int) MAX( *count1_p, *count2_p );
         end = MAX( (int) *count3_p, end);
         end = MAX( (int) *count4_p, end);     

         for (k = 0;  k < end; ++k, rid_array1_p++, rid_array2_p++,
            rid_array3_p++, rid_array4_p++)
         {
            if ( k < (int) *count1_p )
               printf("\nobj_id: %u\t", *rid_array1_p);
            else
               printf("\n        \t");

            if ( k < (int) *count2_p )
               printf("obj_id: %u\t", *rid_array2_p);
            else
               printf("        \t");

            if ( k < (int) *count3_p )
               printf("obj_id: %u\t", *rid_array3_p);
            else
               printf("        \t");

            if ( k < (int) *count4_p )
               printf("obj_id: %u\n", *rid_array4_p);
            else
               printf("        \n");
         } 
      }  
   } 
   else
   {
      printf("\n**************************************************************************");

      for (i = 0; i < (int) nlpage_ptr->Offset_entry_count; i += 4)
      {
         printf("\n\n\n");
         for ( j = i; j < i + 4 && j < (int) nlpage_ptr->Offset_entry_count; j++)
         {
            printf("entry:  %u",  j);
            if (j < i + 3)
               printf("\t");  
         }
         printf("\n");
         for ( k = i; k < j; k++)
         {
            printf("offset: %u",
               *(OFFSET_ENTRY *)(&nlpage_ptr->Offset_key_area[2*k]));
            if (k < i + 3)
               printf("\t");  
         }
         printf("\n");

         x = 0;
         count1_p = count2_p = count3_p = count4_p = &x;
     
         k = i;
         GET_NL_KEY_ENTRY(nlpage_ptr, k, nl_key_length, key1_len,
            count1_p, key1_p, child_array1_p);
         if (++k < j)
            GET_NL_KEY_ENTRY(nlpage_ptr, k, nl_key_length,  key2_len,
               count2_p, key2_p, child_array2_p);
         if (++k < j)
            GET_NL_KEY_ENTRY(nlpage_ptr, k, nl_key_length, key3_len,
               count3_p, key3_p, child_array3_p);
         if (++k < j)
            GET_NL_KEY_ENTRY(nlpage_ptr, k, nl_key_length, key4_len,
               count4_p, key4_p, child_array4_p);
         k = i;
         printf("keylen: %u\t",  key1_len);
         if (++k < j)
            printf("keylen: %u\t",  key2_len);
         else
             printf("            \t\t");
         if (++k < j)
            printf("keylen: %u\t",  key3_len);
         else
            printf("            \t\t");
         if (++k < j)
            printf("keylen: %u\n",  key4_len);
         else
            printf("            \t\n");
     
         k = i;
         printf("# rids: %u\t",  *count1_p);
         if (++k < j)
            printf("# rids: %u\t",  *count2_p);
         else
            printf("            \t\t");
         if (++k < j)
            printf("# rids: %u\t",  *count3_p);
         else
            printf("            \t\t");
         if (++k < j)
            printf("# rids: %u\n",  *count4_p);
         else
            printf("            \t\n");

         if (type == BTREE_INTEGER)
         {
            k = i;
            printf("key:    ");
            printf("%d", *((int *)key1_p));
            printf("\t");
     
            if (++k < j)
            {
               printf("key:    ");
               printf("%d", *((int *)key2_p));
               printf("\t");
            }
            else
               printf("        \t\t");

            if (++k < j)
            {
               printf("key:    ");
               printf("%d", *((int *)key3_p));
               printf("\t");
            }
            else
               printf("        \t\t");

            if (++k < j)
            {
               printf("key:    ");
               printf("%d", *((int *)key4_p));
               printf("\n");
            }
            else
               printf("        \t\n");
         }
         else if (type == BTREE_STRING)
         {
            k = i;
            printf("key:    ");
            for (s = 0; s < key1_len; s++, key1_p++)
            {
               if ( *key1_p == '\0' ) break;
                  printf("%c", *key1_p);
            }
            for (; s < 7; s++)
               printf(" ");
            printf("\t");
     
            if (++k < j)
            {
               printf("key:    ");
               for (s = 0; s < key2_len; s++, key2_p++)
               {
                  if ( *key2_p == '\0' ) break;
                     printf("%c", *key2_p);
               }
               for (; s < 7; s++)
                  printf(" ");
               printf("\t");
            }
            else
               printf("        \t\t");

            if (++k < j)
            {
               printf("key:    ");
               for (s = 0; s < key3_len; s++, key3_p++)
               {
                  if ( *key3_p == '\0' ) break;
                     printf("%c", *key3_p);
               }
               for (; s < 7; s++)
                  printf(" ");
               printf("\t");
            }
            else
               printf("        \t\t");

            if (++k < j)
            {
               printf("key:    ");
               for (s = 0; s < key4_len; s++, key4_p++)
               {
                  if ( *key4_p == '\0' ) break;
                     printf("%c", *key4_p);
               }
               for (; s < 7; s++)
                  printf(" ");
               printf("\n");
            }
            else
               printf("        \t\n");
         }

         end = (int) MAX( *count1_p, *count2_p );
         end = MAX( (int) *count3_p, end);
         end = MAX( (int) *count4_p, end);     

         for (k = 0; k < end; ++k, child_array1_p++, child_array2_p++,
            child_array3_p++, child_array4_p++)
         {
            if ( k < (int) *count1_p )
               printf("child_ptr: %x\t",  *child_array1_p);
            else
               printf("        \t");

            if ( k < (int) *count2_p )
               printf("child_ptr: %x\t", *child_array2_p);
            else
               printf("        \t");

            if ( k < (int) *count3_p )
               printf("child_ptr: %x\t", *child_array3_p);
            else
               printf("        \t");

            if ( k < (int) *count4_p )
               printf("child_ptr: %x\t", *child_array4_p);
            else
               printf("       \n");
         } 
      }

      for (i = 0; i < (int) nlpage_ptr->Offset_entry_count; i++)
      {
         GET_NL_KEY_ENTRY(nlpage_ptr, i, nl_key_length, key1_len,
            count1_p, key1_p, child_array1_p);
         for (k = 0; k < (int) *count1_p; ++k, child_array1_p++) 
            DB_dump_btree( (long *) DEREF(int, *child_array1_p, rip),
               nl_key_length, type);
      }
   } 
   return(1);
}
