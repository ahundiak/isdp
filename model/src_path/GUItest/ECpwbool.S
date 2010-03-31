/*
  DESCRIPTION

  This command locates 2 solids (or surface-entities) and invokes the 
  Pathway Boolean API. In addition, the status of the operation is written 
  to a file: $(PWD)/log/filename.log, where filename is the name of the EMS
  datafile.
*/

class specification ECpwbool (3:2) of ECpathway;

override
  execute,
  get_locate_criteria;

end specification ECpwbool;
