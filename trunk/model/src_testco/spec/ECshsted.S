/* ###################   APOGEE COMPILED   ################## */
class specification ECshsted (1:0) of ECelement;

/*
HISTORY

15 May 1989 jBk Removed overrides of init, wakeup and sleep.
*/

instance ECshsted
   {
   struct GRmd_env mod_info;
   };

override execute;

end specification ECshsted;
