#include <stdio.h>

/*ARGSUSED*/
int RAP_get_keyboard_data( buffer, count )
char *buffer;
int *count;
{
   return(1);
}

/*ARGSUSED*/
int RAP_get_button_data(window, x, y, btype, state, timetag)
int *window;
int *x;
int *y;
int *btype;
int *state;
int *timetag;
{
   return(1);
}
/*ARGSUSED*/
int RAP_record_string (a,b)
char *a, *b;
{
  return(1);
}


RAPFormListener ()
{
   return(1);
}

DLinitialize()
{
   printf ("STUB hit for DLinitialize\n");
   return (0);
}

DLexit()
{
   printf ("STUB hit for DLexit\n");
   return(0);
}

DPdlist_initialize()
{
   printf ("STUB hit for DPdlist_initialize\n");
   return (1);
}

/*ARGSUSED*/
GRsetinqcolcal(pmsg, val, pflag)
int *pmsg, val, *pflag;
{
   *pflag = 0;
   return (1);
}
