/*
 *
 *  File     :          exudata.c
 *  Author   :          Srikanth S
 *  Date     :          Mar 1995
 *
 *
 *  Change  History :
 *
 */


#include "exudata.h"

/*  query types */

#define UDATA_QUERY_INIT		0x1
#define UDATA_QUERY_GET			0x2

/* return codes for exQueryUData */

#define UDATA_QUERY_OUTOFMEM			0x1
#define UDATA_QUERY_NOTSUPPORTED		0x2
#define UDATA_QUERY_SUCCESS			0x3

char ** exQueryUData(query, status)
unsigned int query;
unsigned int *status;
{
   static char *udata[32];
   static int  first = 0;
   int         i;

   if (status == NULL)
      return((char **) NULL);

   if (!first)
   {
      for (i=0; i<32; i++)
         udata[i] = NULL;
      first = 1;
   }
   switch(query)
   {
      case UDATA_QUERY_INIT  :  if (udata[EX_UDATA_ACTREF])
                                {
				   *status = UDATA_QUERY_SUCCESS;
				   return (udata);
                                }

                                udata[EX_UDATA_ACTREF] = (char *) malloc 
                                    ( sizeof(exUDataActref) );
      			        if ( udata[EX_UDATA_ACTREF] == NULL )
                                {
			           *status = UDATA_QUERY_OUTOFMEM;
                                   return ((char **) NULL);
                                }
                                memset(udata[EX_UDATA_ACTREF],0,
                                            sizeof(exUDataActref) );

			        *status = UDATA_QUERY_SUCCESS;
			        return (udata);

      case UDATA_QUERY_GET   :  *status = UDATA_QUERY_SUCCESS;
		 	        return (udata);

      default                :  *status = UDATA_QUERY_NOTSUPPORTED;
    			        return ((char **) NULL);
   }
}

int exInitUData()
{
   unsigned int status = 0;
   char         ** udata = NULL;
   
   udata = exQueryUData(UDATA_QUERY_INIT, &status); 
   if (udata)
      return (UDATA_SUCCESS);

   return (status);  /* not enough memory */
}

int exExitUData()
{
   unsigned int status = 0;
   char         ** udata = NULL;
   int          i;
   
   udata = exQueryUData(UDATA_QUERY_GET, &status);

   for (i=0; i<32; i++)
      if ( udata[i] )
      {
         free( udata[i] );
         udata [i] = NULL;
      }
   return (UDATA_SUCCESS);
}

int exPostUData(int type, char *input)
{
   unsigned int status = 0;
   char         **udata = NULL;

   udata = exQueryUData(UDATA_QUERY_GET, &status);
   switch(type)
   {
      case EX_UDATA_ACTREF :  memcpy ( udata[EX_UDATA_ACTREF], input,
        				sizeof(exUDataActref) );
			      break;

      default              :  return ( UDATA_TYPE_NOTSUPPORTED );
   }
   return (UDATA_SUCCESS);
}

int exRecvUData(type, output)
unsigned int type;
char         *output;
{
   unsigned int status = 0;
   char         **udata = NULL;

   udata = exQueryUData(UDATA_QUERY_GET, &status);
   switch(type)
   {
      case EX_UDATA_ACTREF :  memcpy ( output, udata[EX_UDATA_ACTREF], 
				        sizeof(exUDataActref) );
			      break;

      default              :  return ( UDATA_TYPE_NOTSUPPORTED );
   }
   return (UDATA_SUCCESS);
}
