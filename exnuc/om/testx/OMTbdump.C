/* ================================================
 * This is a common function
 * No main routine
 * seems to duplicate a routine already in exnuc
 *
 * Needed to add intproms to get it to work
 */
#include <stdio.h>

#include  "OMobjectcomm.h"
#include  "OMrelation.h"
#include  "OMintprims.h"
#include  "OMDB.h"
#include  "OMindex.h"
#include  "OMbtreedef.h"

#ifndef TIME_TEST
#define NUMKEYS 800
#else
#define NUMKEYS 8000
#endif

#define  NL_KEY_LENGTH    (8)


/******************************** DB_dump_btree ***************************/
DB_dump_btreex( child_ptr, nl_key_length)


  long *child_ptr;
  KEY_LENGTH nl_key_length;
 
{
  int       end;
  B_LF_PAGE *lfpage_ptr;
  B_NL_PAGE *nlpage_ptr;
  int i, j, k, s;
  char *status; 
  char   *key1_p, *key2_p, *key3_p, *key4_p;
  KEY_LENGTH  key1_len, key2_len, key3_len, key4_len;
  REC_PTR_COUNT *count1_p, *count2_p, *count3_p, *count4_p;
  long       *rid_array1_p, *rid_array2_p, *rid_array3_p, *rid_array4_p;
  OM_S_OBJID *child_array1_p, *child_array2_p, *child_array3_p, *child_array4_p;
  unsigned short x;
  OM_S_RIP   rip;
  OM_S_OBJID tobj;
  int *temp_p;
  
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
  printf("Next page:      \t%x\n", lfpage_ptr->Next_p);
  printf("Prior page:     \t%x\n", lfpage_ptr->Prior_p);
printf("\n**************************************************************************");

for (i = 0; i < lfpage_ptr->Offset_entry_count; i += 4)
   {
     printf("\n\n\n");
     for ( j = i; j < i + 4 && j < lfpage_ptr->Offset_entry_count; j++)
      {
         printf("entry:  %u",  j);
	 if (j < i + 3)
	   printf("\t");  
      }
     printf("\n");
     for ( k = i; k < j; k++)
      {
       printf
     ("offset: %u", *(OFFSET_ENTRY *)(&lfpage_ptr->Offset_key_area[2*k]));
       if (k < i + 3)
	 printf("\t");  
      }
     printf("\n");

     x = 0;
     count1_p = count2_p = count3_p = count4_p = &x;
     
     k = i;
     GET_LF_KEY_ENTRY(lfpage_ptr,  k, key1_len, count1_p, key1_p,rid_array1_p);
     if (++k < j)
     GET_LF_KEY_ENTRY(lfpage_ptr,  k, key2_len, count2_p, key2_p,rid_array2_p);
     if (++k < j)
     GET_LF_KEY_ENTRY(lfpage_ptr,  k, key3_len, count3_p, key3_p,rid_array3_p);
     if (++k < j)
     GET_LF_KEY_ENTRY(lfpage_ptr,  k, key4_len, count4_p, key4_p,rid_array4_p);
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
     
     k = i;
     key1_len = strlen( key1_p );
     key2_len = strlen( key2_p );
     key3_len = strlen( key3_p );
     key4_len = strlen( key4_p );

     printf("key:    ");
     for (s = 0; s < key1_len; s++, key1_p++)
         printf("%c", *key1_p);
     for (; s < 7; s++)
         printf(" ");
     printf("\t");
     
     if (++k < j)
     {
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
     printf("key:    ");
     for (s = 0; s < key4_len; s++, key4_p++)
         printf("%c", *key4_p);
     for (; s < 7; s++)
         printf(" ");
     printf("\n");
     }
     else
     printf("        \t\n");

     end = MAX( *count1_p, *count2_p );
     end = MAX( *count3_p, end);
     end = MAX( *count4_p, end);     

     for (k = 0; k < end; ++k, rid_array1_p++, rid_array2_p++, rid_array3_p++, rid_array4_p++)
       {
        if ( k < *count1_p )
          printf("\nobj_id: %u\t", *rid_array1_p);
        else
          printf("\n        \t");

        if ( k < *count2_p )
          printf("obj_id: %u\t", *rid_array2_p);
        else
          printf("        \t");


        if ( k < *count3_p )
          printf("obj_id: %u\t", *rid_array3_p);
        else
          printf("        \t");

        if ( k < *count4_p )
          printf("obj_id: %u\n", *rid_array4_p);
        else
          printf("        \n");

       } 
      }  
    } 
else
{
printf("\n**************************************************************************");

for (i = 0; i < nlpage_ptr->Offset_entry_count; i += 4)
   {
     printf("\n\n\n");
     for ( j = i; j < i + 4 && j < nlpage_ptr->Offset_entry_count; j++)
      {
         printf("entry:  %u",  j);
	 if (j < i + 3)
	   printf("\t");  
      }
     printf("\n");
     for ( k = i; k < j; k++)
      {
       printf
     ("offset: %u", *(OFFSET_ENTRY *)(&nlpage_ptr->Offset_key_area[2*k]));
       if (k < i + 3)
	 printf("\t");  
      }
     printf("\n");

     x = 0;
     count1_p = count2_p = count3_p = count4_p = &x;
     
     k = i;
     GET_NL_KEY_ENTRY(nlpage_ptr,  k, NL_KEY_LENGTH, key1_len, count1_p, key1_p,child_array1_p);

#ifdef DEBUG
     printf("\n*** GET_NL_KEY_ENTRY in DUMP_BTREE ***\n");
     printf("Got page: %x\n", nlpage_ptr);
     printf("offset_entry_num: %d\n", k);
     printf("key1_len: %d\n", key1_len);
     printf(" count1_p: %x\n", count1_p);
     printf("*count1_p: %d\n", *count1_p);
     printf("key1_p: %x\n", key1_p);
     printf(" child_array1_p: %x\n\n", child_array1_p);
     printf("*child_array1_p: %x\n\n", *child_array1_p);
#endif

     if (++k < j)
     GET_NL_KEY_ENTRY(nlpage_ptr,  k, NL_KEY_LENGTH,  key2_len, count2_p, key2_p,child_array2_p);
     if (++k < j)
     GET_NL_KEY_ENTRY(nlpage_ptr,  k, NL_KEY_LENGTH, key3_len, count3_p, key3_p,child_array3_p);
     if (++k < j)
     GET_NL_KEY_ENTRY(nlpage_ptr,  k, NL_KEY_LENGTH, key4_len, count4_p, key4_p,child_array4_p);
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

     end = MAX( *count1_p, *count2_p );
     end = MAX( *count3_p, end);
     end = MAX( *count4_p, end);     

     for (k = 0; k < end; ++k, child_array1_p++, child_array2_p++, child_array3_p++, child_array4_p++)
       {
	

        if ( k < *count1_p )
	   {
             printf("child_ptr: %x\t",  *child_array1_p);
	   }
        else
           printf("        \t");

        if ( k < *count2_p )
	   {
             printf("child_ptr: %x\t", *child_array2_p);
	   }
        else
            printf("        \t");

        if ( k < *count3_p )
	   {
             printf("child_ptr: %x\t", *child_array3_p);
	   }
        else
            printf("        \t");

        if ( k < *count4_p )
	   {
             printf("child_ptr: %x\t", *child_array4_p);
	   }
        else
            printf("       \n");

        } 
      }  

for (i = 0; i < nlpage_ptr->Offset_entry_count; i++)
    {

    GET_NL_KEY_ENTRY(nlpage_ptr,  i, NL_KEY_LENGTH, key1_len, count1_p, key1_p,child_array1_p);
    for (k = 0; k < *count1_p; ++k, child_array1_p++) 

	{
#ifdef DMPDEBUG
	printf("\n*** Recursive call to DB_dump_btree ***\n");
	printf("*child_array1_p: %x\n", *child_array1_p);
	temp_p = DEREF(int, *child_array1_p, rip);
	printf("temp_p: %x\n", temp_p);
	DB_dump_btree(temp_p, NL_KEY_LENGTH);
#else
 	DB_dump_btree( DEREF(int, *child_array1_p, rip), NL_KEY_LENGTH);
#endif
	}
   }
  } 
 }

/* user comparison routine for testing btree. */
int user_compare(key1_ptr, key2_ptr, length1, length2)

  char *key1_ptr, *key2_ptr;
  int length1, length2;

  {
  int result;
  int strncmp();

  if (length1 < length2)
    if ((result = strncmp(key1_ptr, key2_ptr, length1)) == 0)
      return(-1);
    else
      return(result);
  else if (length2 < length1)
    if ((result = strncmp(key1_ptr, key2_ptr, length2)) == 0)
      return(1);
    else
      return(result);
  else
    return(strncmp(key1_ptr, key2_ptr, length1));
  }

