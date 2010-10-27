/* $Id: VDSdbpath.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbpath.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbpath.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1996/05/20  03:49:34  pinnacle
 * Replaced: vddb/source/VDSdbpath.c for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:32  pinnacle
 * Replaced: vddb/source/VDSdbpath.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbpath.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/18/96   tlb		Add prototypes
 *	04/22/96     tlb	Fix log comment problem 
 *	05/09/96     tlb	Fix prototype file name
 *				Use OS-dependent product_data directory
 *
 * -------------------------------------------------------------------*/

#include  	<stdio.h>
#include 	<string.h>
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

#define  MAX_CHAR_WORD  20
#define  MAX_CHAR_LINE  81

/***************************************************************************
 * int echopath( product_name, product_path) - Function to get product directory
 * path from file /usr/ip32/product_data.
 * 
 * This function inputs product name (uppercase) e.g. EXNUC,GRNUC,BSPMATH,EMS,
 * VDS,STRUCT,ROUTE,. and searches for a line in file /usr/ip32/product_data
 * that has got the given product name in word 2. When found, the last word 
 * in the line is transferred to product_path.
 * 
 *         Returns 1 if successful
 *                 0 if failure ( product not found or /usr/ip32/product_data 
 *						not readable)
 */

int VDBproductpath ( product_name, product_path )
char product_name[];		/* Product Name 	(I) */
char product_path[];		/* Product path		(O) */
{
   short	found,get_next,i1,i2;
   char		s_prod[MAX_CHAR_WORD],f_prod[MAX_CHAR_WORD];
   FILE 	*pd;
   char		line[MAX_CHAR_LINE];

   strcpy(product_path,"");
   found = 0;
   sprintf(s_prod,"I/%s",product_name);

#ifdef X11
   pd= fopen ("/opt/ingr/product_data", "r");
#else
   pd= fopen ("/usr/ip32/product_data", "r");
#endif
   if (pd == NULL) return 0;

   while (fgets( line, MAX_CHAR_LINE-1, pd) != NULL)
     {
      line[MAX_CHAR_LINE-1] = NULL;
      get_next = 0;

        /* Get pos of first blank */
      for (i1=0; i1 < MAX_CHAR_LINE; i1=i1+1)
        {
         if (line[i1] == ' ') break;
           /* Check if NEWLINE or end of string found */
         if (line[i1] == '\n' || line[i1] == NULL)
           {
            get_next = 1;
            break;
           }
        }
      if (get_next || i1 >= MAX_CHAR_LINE) continue;
      i1=i1+1;

        /* Get pos of second blank */
      for (i2=i1; i2 < MAX_CHAR_LINE; i2=i2+1)
        {
         if (line[i2] == ' ') break;
           /* Check if NEWLINE or end of string found */
         if (line[i2] == '\n' || line[i2] == NULL)
           {
            get_next = 1;
            break;
           }
        }
      if (get_next || i2 >= MAX_CHAR_LINE) continue;

      strncpy( f_prod, &line[i1], i2-i1);
      f_prod[i2-i1] = NULL;

      if (!strcmp(s_prod,f_prod))
        {
           /* Get dir path from last word excluding NEWLINE char */
         i2 = strlen(line);
         for (i1=i2; i1 >= 0; i1=i1-1)
           {
            if (line[i1] == '\n') i2 = i1;
            if (line[i1] == ' ') break;
           }
         if (i1 < 0) continue;
         i1 = i1 + 1;

         strncpy(product_path, &line[i1],i2-i1);
         product_path[i2-i1] = NULL;
         found = 1;
         break;
        }                           
     }
   fclose  (pd);
   if (!found) return 0;
   return 1;
}
