#ifdef SYSV
#include <string.h>
#endif

blkmv(n, s, d)
 int  n;
 char *s, *d;
{
 register char *p_s, *p_d;
 register double *dp_s, *dp_d;
 register int    cnt;
 
 if (n == 0)
   return(0);
 cnt = n;

 if ( ((int)s & 7) == ( (int)d & 7) ) { 
   if (s < d) {
     p_s = s + cnt;
     p_d = d + cnt;

     while ((int)p_s & 7 && cnt > 0) {
       *(--p_d) = *(--p_s);                 
       --cnt;
     }
     
     dp_s = (double *)p_s;
     dp_d = (double *)p_d;

     while (cnt >= 8) {
       *(--dp_d) = *(--dp_s);
       cnt -= 8;
     }
     
     p_s = (char *)dp_s;
     p_d = (char *)dp_d;

     while (cnt > 0) {
       *(--p_d) = *(--p_s);                 
       --cnt;
     }     
      
   }
   else {
     p_s = s;
     p_d = d;

     while ((int)p_s & 7 && cnt > 0) {
       *p_d++ = *p_s++;                 
       --cnt;
     }
     
     dp_s = (double *)p_s;
     dp_d = (double *)p_d;

     while (cnt >= 8) {
       *dp_d++ = *dp_s++;
       cnt -= 8;
     }

     p_s = (char *)dp_s;
     p_d = (char *)dp_d;

     while (cnt > 0) {
       *p_d++ = *p_s++;
       --cnt;
     }     
   }
 }
 else
#if defined (SUNOS) && defined (BSD)
   bcopy(s, d, n);
#else
   memmove(d, s, n);
#endif
 return(1); 
}
