/*
  DESCRIPTION

  This command locates a solid (or surface-entities) and sets the post-310
  behaviour property bit on all DPR objects within the solid. This will
  mean that when the DPR recomputes, it will recompute in the context of
  3.2 s/ware (Pathway). This command should be used with caution, since a 
  3.2 behaviour may change the topology and thus accentuate recompute failures 
  when entities are dependent on topological entities.
*/

class specification ECpost31 (3:2) of ECelements;

override
  execute,
  get_locate_criteria;

end specification ECpost31;
