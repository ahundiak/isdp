create table std_pcmk
(
  std_key    char(40),
  pcmk       integer
);

create index std_pcmk_i1 on std_pcmk(std_key);
create index std_pcmk_i2 on std_pcmk(pcmk);


