/* $Id: VDreadjnl.c,v 1.4 2001/03/05 16:59:04 hans Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcppl/VDreadjnl.c
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDreadjnl.c,v $
 * Revision 1.4  2001/03/05 16:59:04  hans
 * *** empty log message ***
 *
 * Revision 1.3  2001/03/03 17:36:47  hans
 * Print Header Section
 *
 * Revision 1.2  2001/03/03 17:05:57  hans
 * Enable/Disable Verbose Journalling
 *
 * Revision 1.1  2001/03/02 22:14:00  hans
 * Added VDreadjnl.c
 *
 *
 * History:
 * MM/DD/YYYY	AUTHOR  DESCRIPTION
 * 03/02/2001	HF	Creation Date
 *
 ***************************************************************************/

#include "stdio.h"
#include "string.h"

extern int VDcomment;

#ifdef MAIN
main( int argc, char **argv )
{
  if ( argc > 1 )
  {
    read_journal(argv[1]);
  }
  else
  {
    read_journal(".isdp_journal.u");
  }
}
#endif

read_journal(char *jnl_msg)
{
  FILE *fp, *fout;
  char flnm[80], str0[80], str1[120], *ptr = NULL, *atsg = NULL, *nwln = NULL, *lstq = NULL;
  int  i0  = 0;
  long tim = 0, len = 0;

  if (jnl_msg == NULL)
    return 0;

  memset(str0, 0, sizeof(str0));
  /*
   *  Find sub-string: .u
   */
  ptr = strstr (jnl_msg, ".u");
  if (ptr)
  {
    strncpy(str0, &jnl_msg[1], (int)(ptr - &jnl_msg[1]));
    strcpy(flnm, str0);
    /*
     * printf("<%s>\n", str0);
     */
  }
  fp   = fopen(jnl_msg, "r");
  if (fp)
  {
    fout = fopen(str0, "w");
    if (fout)
    {
      /*
       * Print Header Section...
       */
      for (i0=0; i0 < 5; i0++)
      {
        if(fgets(str0, sizeof(str0), fp))
        {
          if (i0 == 4)
            strcat(str0, "\n");
          printf("%s", str0);
          fprintf(fout, "%s", str0);
        }
      }
      while(fgets(str0, sizeof(str0), fp))
      {
        /*
         * Remove \n at end of string
         */
        nwln = strrchr (str0, '\n');
        if (nwln) str0[(int)(nwln - str0)] = '\0';
        /*
         * Find sub-string: //"
         */
        ptr = strstr (str0, "//\"");
        if (ptr)
        {
          /*
           * Find sub-string: " "
           */
          ptr = strstr (str0, "\" \"");
          if (ptr)
          {
            strcpy (str0, ptr);
            /*
             * Find last: "
             */
            lstq = strrchr (str0, '"') + 1;
            /*
             * Find last: @
             */
            atsg = strrchr (str0, '@');

            if (atsg)
            {
              /*
               * Get the timestamp...
               */
              tim  = atoi(atsg+1);
              sscanf(atsg, "%d", &tim);
            }
            else
            {
              continue;
            }
            /*
             * Blank out the string after the last: "
             */
            len  = (int)(lstq - str0);
            memset(&str0[len], ' ', 80 - len);
            memset(&str0[78], 0, 2);

            /*
             * Decode the timestamp...
             */
            sprintf(str1, "%s %s", &str0[2], asctime(localtime(&tim)));
            printf("%s", str1);
            fprintf(fout, "%s", str1);
          }
        }
      }
      fclose(fp);
      fclose(fout);
      printf("\nCreated file <%s>\n\n", flnm);
    }
    else
    {
      printf("\nVDreadjnl: Cannot open file <%s>\n\n", str0);
    }
  }
  else
  {
    printf("\nVDreadjnl: Cannot open file <%s>\n\n", jnl_msg);
  }
}
