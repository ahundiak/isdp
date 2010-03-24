
*** Construct new filed OS : NEWOSdyn ***

*******************************************
clse classid: 64
clsa classid: 66
clsc classid: 67
clsb classid: 68


**** Construct dynamic class - clsd ****



*** Get classid for clsd ***


*** clsd classid: 81 ***


*** Construct clsd objects ***


***** Show d_objid[0] *****

-----> SHOW OBJECT ----> (2,22)
 filed_id=81 size=48 cluster_id=1 send depth elevated=False
 Has_VLA )
 active_id=81 name="clsd"
 base=64 max=81 trans=( 64/1 66/2 67/3 68/4 81/5 )
----> channels defined by class=64 (clse)  offset=8 num_chan=1
---> channel name="echan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=64.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=66 (clsa)  offset=16 num_chan=2
---> channel name="acb" offset=4 Init=1 Extend=20 flags=( CD_m_m CD_relordered )
 ClassCount=2 Classes=( 68 (clsb) 67 (clsc))
 channel number=66.0 is  m_m relordered
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
---> channel name="any_chan" offset=8 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=66.1 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=67 (clsc)  offset=28 num_chan=1
---> channel name="cchan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=67.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=68 (clsb)  offset=36 num_chan=1
---> channel name="btoany" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=68.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0

***** Show d_objid[1] *****

-----> SHOW OBJECT ----> (2,23)
 filed_id=81 size=48 cluster_id=1 send depth elevated=False
 Has_VLA )
 active_id=81 name="clsd"
 base=64 max=81 trans=( 64/1 66/2 67/3 68/4 81/5 )
----> channels defined by class=64 (clse)  offset=8 num_chan=1
---> channel name="echan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=64.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=66 (clsa)  offset=16 num_chan=2
---> channel name="acb" offset=4 Init=1 Extend=20 flags=( CD_m_m CD_relordered )
 ClassCount=2 Classes=( 68 (clsb) 67 (clsc))
 channel number=66.0 is  m_m relordered
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
---> channel name="any_chan" offset=8 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=66.1 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=67 (clsc)  offset=28 num_chan=1
---> channel name="cchan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=67.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=68 (clsb)  offset=36 num_chan=1
---> channel name="btoany" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=68.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0

***** Show d_objid[2] *****

-----> SHOW OBJECT ----> (2,24)
 filed_id=81 size=48 cluster_id=1 send depth elevated=False
 Has_VLA )
 active_id=81 name="clsd"
 base=64 max=81 trans=( 64/1 66/2 67/3 68/4 81/5 )
----> channels defined by class=64 (clse)  offset=8 num_chan=1
---> channel name="echan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=64.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=66 (clsa)  offset=16 num_chan=2
---> channel name="acb" offset=4 Init=1 Extend=20 flags=( CD_m_m CD_relordered )
 ClassCount=2 Classes=( 68 (clsb) 67 (clsc))
 channel number=66.0 is  m_m relordered
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
---> channel name="any_chan" offset=8 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=66.1 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=67 (clsc)  offset=28 num_chan=1
---> channel name="cchan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=67.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=68 (clsb)  offset=36 num_chan=1
---> channel name="btoany" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=68.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0

*** Send to message printe1 from d_objid[0] ***
printe1

*** Send to message printb from d_objid[0] ***
clsb print


*** Connect d_objid[i] to c objid 0 ***


*** Channel send from c_objid[0] to class a's display ***

clsa num: 100
clsa num: 100
clsa num: 100

*** Disconnect the d_objids from the c_objids ***


**** Construct dynamic class - sub0_clsd ****



*** Get classid for sub0_clsd ***


*** sub0_clsd classid: 82 ***


*** Construct sub0_clsd objects ***


***** Show subd0_objid[0] *****

-----> SHOW OBJECT ----> (2,26)
 filed_id=82 size=48 cluster_id=1 send depth elevated=False
 Has_VLA )
 active_id=82 name="sub0_clsd"
 base=64 max=82 trans=( 64/1 66/2 67/3 68/4 81/5 82/6 )
----> channels defined by class=64 (clse)  offset=8 num_chan=1
---> channel name="echan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=64.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=66 (clsa)  offset=16 num_chan=2
---> channel name="acb" offset=4 Init=1 Extend=20 flags=( CD_m_m CD_relordered )
 ClassCount=2 Classes=( 68 (clsb) 67 (clsc))
 channel number=66.0 is  m_m relordered
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
---> channel name="any_chan" offset=8 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=66.1 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=67 (clsc)  offset=28 num_chan=1
---> channel name="cchan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=67.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=68 (clsb)  offset=36 num_chan=1
---> channel name="btoany" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=68.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0

*** Send to message printe1 from subd0_objid[0] ***
printe1

*** Send to message printb from subd0_objid[0] ***
clsb print


**** Construct dynamic class - sub1_clsd ****



*** Get classid for sub1_clsd ***


*** sub1_clsd classid: 83 ***


*** Construct sub1_clsd objects ***


***** Show subd1_objid[0] *****

-----> SHOW OBJECT ----> (2,28)
 filed_id=83 size=48 cluster_id=1 send depth elevated=False
 Has_VLA )
 active_id=83 name="sub1_clsd"
 base=64 max=83 trans=( 64/1 66/2 67/3 68/4 81/5 83/6 )
----> channels defined by class=64 (clse)  offset=8 num_chan=1
---> channel name="echan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=64.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=66 (clsa)  offset=16 num_chan=2
---> channel name="acb" offset=4 Init=1 Extend=20 flags=( CD_m_m CD_relordered )
 ClassCount=2 Classes=( 68 (clsb) 67 (clsc))
 channel number=66.0 is  m_m relordered
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
---> channel name="any_chan" offset=8 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=66.1 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=67 (clsc)  offset=28 num_chan=1
---> channel name="cchan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=67.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=68 (clsb)  offset=36 num_chan=1
---> channel name="btoany" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=68.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0

*** Send to message printe1 from subd1_objid[0] ***
printe1

*** Send to message printb from subd1_objid[0] ***
clsb print


**** Construct dynamic class - ssub_clsd ****



*** Get classid for ssub_clsd ***


*** ssub_clsd classid: 84 ***


*** Construct ssub_clsd objects ***


***** Show ssubd_objid[0] *****

-----> SHOW OBJECT ----> (2,30)
 filed_id=84 size=48 cluster_id=1 send depth elevated=False
 Has_VLA )
 active_id=84 name="ssub_clsd"
 base=64 max=84 trans=( 64/1 66/2 67/3 68/4 81/5 82/7 83/6 84/8 )
----> channels defined by class=64 (clse)  offset=8 num_chan=1
---> channel name="echan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=64.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=66 (clsa)  offset=16 num_chan=2
---> channel name="acb" offset=4 Init=1 Extend=20 flags=( CD_m_m CD_relordered )
 ClassCount=2 Classes=( 68 (clsb) 67 (clsc))
 channel number=66.0 is  m_m relordered
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
---> channel name="any_chan" offset=8 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=66.1 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=67 (clsc)  offset=28 num_chan=1
---> channel name="cchan" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=67.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0
----> channels defined by class=68 (clsb)  offset=36 num_chan=1
---> channel name="btoany" offset=4 Init=-1 Extend=-1 flags=( CD_m_m )
 channel number=68.0 is  m_m
 collapse_count=0 last_index=0 depth=0 VLA_sz=0

*** Send to message printe1 from ssubd_objid[0] ***
printe1

*** Send to message printb from ssubd_objid[0] ***
clsb print

*** Read filed OS : OSdyn ***


*** Get classid for clsd ***


*** clsd classid: 81 ***


*** Get classid for sub0_clsd ***


*** sub0_clsd classid: 82 ***


*** Get classid for sub1_clsd ***


*** sub1_clsd classid: 83 ***


*** Get classid for ssub_clsd ***


*** ssub_clsd classid: 84 ***
