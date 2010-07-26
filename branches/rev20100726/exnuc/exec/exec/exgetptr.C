#include <malloc.h>
#include <stdio.h>
#include <string.h>
#include <expriv.h>
#include <exproto.h>

#define EX_chunk_size  500


static struct EX_cmd_instring *EXlist = 0;


int EX_cmdgetptr( instring, outstring)
char *instring, **outstring;
{
  int len, status;
  struct EX_cmd_instring *curr_chunk;
  struct EX_cmd_instring *temp_chunk;
  char *position ;
  int not_done;

  status = TRUE;
  *outstring = NULL;

  if ( EXlist == NULL )
  {
     EXlist =(struct EX_cmd_instring *)
                           malloc( sizeof( struct EX_cmd_instring));

     if( EXlist == NULL )
     {
        printf("IN EX_cmdgetptr EXlist error\n");
        status = FALSE; 
     }
     else
     {
        EXlist->next = NULL;
       	EXlist->instring = malloc( EX_chunk_size );
        if( EXlist->instring == NULL) status = FALSE;
	EXlist->size_avail = EX_chunk_size;
     }
  }

  curr_chunk =  EXlist;  
  not_done = TRUE;
  len = strlen( instring ) + 1;
  
  while( not_done & status == TRUE)
  {
     while ( len > curr_chunk->size_avail )
     {
	if( curr_chunk->next == NULL)
	{
	    temp_chunk =(struct EX_cmd_instring *) 
	                       malloc( sizeof( struct EX_cmd_instring));

	    if( temp_chunk == NULL )
	    {
	       printf("IN EX_cmdgetptr temp_chunk error\n");
               status = FALSE;
	    }
	    else
	    {
	       temp_chunk->next = NULL;
	       temp_chunk->instring =  malloc( EX_chunk_size );
               if( temp_chunk->instring == NULL) status = FALSE;
	       temp_chunk->size_avail = EX_chunk_size;
	    }
	    curr_chunk->next = temp_chunk;
            curr_chunk = temp_chunk;
	}
	else
	{
	   curr_chunk = curr_chunk->next;
	}
     }	 
     position = curr_chunk->instring;
     position += (EX_chunk_size - curr_chunk->size_avail );
     *outstring = position;
     strncpy( position, instring,len);
     curr_chunk->size_avail -= len;
     not_done = FALSE;
  }
  return(status);
}


int EX_cmdfreeptr()
{
  struct EX_cmd_instring *temp_chunk;    
  struct EX_cmd_instring *curr_chunk;
  
  curr_chunk = EXlist;
  while(curr_chunk !=NULL)
  {
     free( curr_chunk->instring);
     temp_chunk = curr_chunk;
     curr_chunk = curr_chunk->next;
     printf("free %x\n",temp_chunk);
     free(temp_chunk);
  }
  return(TRUE);
}



/*
main()
{
   int i;
   char text[80],c;
   char *outstr;
   int not_done ;
   
   not_done = 1;
   while( not_done  )
   {
       printf("INPUT string >\n ");
       scanf("%s",text);
       EX_cmdgetptr( text, &outstr);
       printf("in  string = %s\n",text);
       printf("out string = %s\n",outstr);       
       if( !strcmp( text, "end") ) not_done = FALSE;
   }
   EX_cmdfreeptr();
}
*/
