
/* 

   jkdraw.h     by J.H.Kidd I(uk) oct 89

   include file to declare data structure for fastener programs

 */



struct  mfdata       /* structure for metric fastener data  */
{
   double dia;       /* nominal diameter  */
   char   part[17];  // partnumber - second part
   double ht;        /* head thickness    */
   double waf;       /* width across flats */
   double wac;       /* width across corners  */
   double wfd;       /* washer face dia       */
   double wft;       /* washer face thickness */
   double ruh;       /* radius under head     */
   double ptch;      /* thread pitch          */
   double nht;       /* nut head thickness    */
   double nhtt;      /* nut head thickness - thin */
   double thro;      /* thread run out        */
   double thl1;      /* bolt thread length len<125 */
   double thl2;      /* bolt thread length 125<len<200 */
   double thl3;      /* bolt thread length l>200   */
   double bsa;       /* bolt size available     */
   double chd;       /* cap head diameter     */
   double chaf;      /* cap head width across flats */
   double chs;       /* cap head hex recess   */
   double cshd;      /* countersunk head dia  */
   double csaf;      /* countersunk across flats */
   double css;       /* countersunk hex recess */
   double csht;      /* countersunk head thickness */
   double wd;	     // nominal washer diameter
   double wth;	     // nominal washer thickness
   double sclen[11]; /* nominal screw lengths  */
   double blen[27];  /* nominal bolt lengths & screws */
   double slen[16];  // nominal stud lengths
   double sthl1;     // fixed end thread lengths fo studs
   double sthl2[15]; // free end thread lengths for studs
   double holed;     // hole diameter
   double holecf;    // hole chamfer
   double holecbd;   // hole counterbore diameter
   struct mfdata *next;	// pointer to next structure of data
   struct mfdata *last; // pointer to last structure of data
};

