#include	<stdio.h>
#include        <MEMerrordef.h>
#include        <MEMstruct.h>
#include        <PDUproto.h>


extern int	PDM_debug_on;
extern char PDU_DEBUG_FILE[80];

void _pdm_debug(message,variable)
  char     *message;
  char     *variable;
  {
  FILE  *pdu_debug_file, *fopen();

  if ( PDM_debug_on )
     {
        if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
           {
           printf("Could not open debug file\n");
           }
        else
           {
           fprintf(pdu_debug_file, "PDU -- ");
           if (variable)
              fprintf(pdu_debug_file, message, variable);
           else
              fprintf(pdu_debug_file, message, "");
           fprintf(pdu_debug_file, "\n");
           fclose (pdu_debug_file);
           }
     }
  }

void _pdm_rstatus(meth,sts1)
        char   *meth;
        int    sts1;
	{
        FILE  *pdu_debug_file, *fopen();

	if ( PDM_debug_on )
	   {
	   if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
              printf("Could not open debug file\n");
           else
              {
	      fprintf(pdu_debug_file, "PDU -- %s returns, status = <0x%.8x>\n", meth, sts1);
              fclose (pdu_debug_file);
              }
/*
	   if (sts1 != 1)
	      {
	      om$report_error (sts=sts1);
	      }
*/
	   }
	}

void _pdm_rstatus2(meth,sts1,sts2)
        char     *meth;
        int      sts1;
        int      sts2;
	{
        FILE  *pdu_debug_file, *fopen();

	if ( PDM_debug_on )
	   {
	   if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
              printf("Could not open debug file\n");
           else
              {
	      fprintf(pdu_debug_file,"PDU -- %s returns: <0x%.8x>, status = <0x%.8x>\n", meth, sts2, sts1);
              fclose (pdu_debug_file);
              }
/*
	   if (sts1 != 1)
	      {
	      om$report_error (sts=sts1);
	      }
*/
	   }
	}

void _pdm_status(meth,sts1)
        char     *meth;
        int      sts1;
	{
        FILE  *pdu_debug_file, *fopen();

	if ( PDM_debug_on )
	 {
	   if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
              printf("Could not open debug file\n");
           else
              {
	      fprintf(pdu_debug_file, "PDU -- %s returns, status = <0x%.8x>\n", meth, sts1);
              fclose (pdu_debug_file);
              }
	 }
	}

void _pdm_status2(meth,sts1,sts2)
        char     *meth;
        int      sts1;
        int      sts2;
	{
        FILE  *pdu_debug_file, *fopen();

	if ( PDM_debug_on )
	   {
	   if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
              printf("Could not open debug file\n");
           else
              {
	      fprintf(pdu_debug_file,"PDU -- %s returns: <0x%.8x>, status = <0x%.8x>\n", meth, sts2, sts1);
              fclose (pdu_debug_file);
              }
	   }
	}

void _pdm_debug_list(name, list, rows, cols)
        char     *name;
        char     **list;
        int      rows;
        int      cols;
        {
        FILE  *pdu_debug_file, *fopen();
        int   i,j;

        if ( PDM_debug_on )
         {
           if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
              printf("Could not open pdu debug file\n");
           else
              {
               fprintf(pdu_debug_file,
                "\nList %s has %d items, %d columns: \n", name, rows, cols);

               for ( i = 0; i < rows; ++i )
                   {
                    for ( j = 0; j < cols; ++j )
                        fprintf (pdu_debug_file,
                          " %s [%d,%d] = %s\n",name, i, j, list[(cols*i)+j]);
                    fprintf(pdu_debug_file,"\n");
                   }
              fclose (pdu_debug_file);
              }
         }
        }

char * _pdm_colptr(buffptr, row, col)
        MEMptr   buffptr;
        int      row;
        int      col;
        {
        return(
         (char *)(((char **) buffptr->data_ptr)[(row * buffptr->columns)+col])
              );

        }

short PDUnullstr(x)
        char    *x;
        {
         if ((x == 0) || (strcmp(x, "") == 0))
            return(1); 

         else
            return(0);
        }
