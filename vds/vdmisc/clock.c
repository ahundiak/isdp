/* $Id: clock.c,v 1.1 2001/01/18 16:31:32 art Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / clock.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: clock.c,v $
 *	Revision 1.1  2001/01/18 16:31:32  art
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

static int ClockIndex;
static int ClockTime[16];


/******************************************************************************/
void ClockInit ()
  {
   ClockIndex= 0;
  }
/******************************************************************************/
void ClockIn (Message)

char *Message;
  {
int  i;
   if (ClockIndex >= 0 
   &&  ClockIndex < 16)
     {
      for (i=0;i<ClockIndex;i++) printf("\t");
      printf ("clock in  %s\n", Message);
      ClockTime [ClockIndex]= clock ();
      ClockIndex++;
     }
   else
      printf ("ClockIn : invalid ClockIndex= %d\n", ClockIndex);
  }
/******************************************************************************/
void ClockOut (Message)

char *Message;
  {
int  i;
   if (ClockIndex > 0)
     {
      ClockIndex--;
      for (i=0;i<ClockIndex;i++) printf("\t");
      printf ("clock out %s, time= %d ms\n\n", Message, 
 	      (clock () - ClockTime [ClockIndex])/1000);
     }
   else
      printf ("ClockOut : invalid ClockIndex= %d\n", ClockIndex);
  }
/******************************************************************************/
