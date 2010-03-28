class specification COcidgnop (1:0) of super_cmd ;

/* --
   The purpose in life of this command object is to get informed that a design
   file is being opened. It will figure in the command table with the flag
   "EX_FINIT", and will not be invoked by the user form the command line.
   -- */

override init, execute ;

end specification COcidgnop ;
