#!/bin/php
<?php
error_reporting(E_ALL);

/*
 *
 * Too much of a pain for now
 *
  0 - No Error
  1 - Error

  target: depends
     commands

depends is 0 or more

file.o: file.c
  cc -o file.o -c file.c

.o.c:
  cc -o name.o -c name.c

install: no depends
  cp
  ln

*/
class MakeFile
{
  protected $targets = array();

  function __construct()
  {
    $this->init();
  }
  function addTarget($target)
  {
    $name = $target->name;
    if (isset($this->targets[$name]))
    {
      echo "Target already exists $name\n";
      return 1;
    }
    $this->targets[$name] = $target;

    return 0;
  }
  function process($name)
  {
    if (!isset($this->targets[$name]))
    {
      echo "Tried to process unknown target: $name\n";
      return 1;
    }
    $target = $this->targets[$name];
    return $target->process();
  }
}
class MakeFileTest extends MakeFile
{
  public $objs = array('file1.o','file2.o');
  public $srcs = array('file1.c','file2.c');

  function init()
  {
    $this->addTarget(new MakeTargetAll ($this));
    $this->addTarget(new MakeTargetExec($this));

    return 0;
  }
}
class MakeTarget
{
  public $name = 'undefined';
  protected $make;

  function __construct($make)
  {
    $this->make = $make;
    $this->init();
  }
  function process()
  {
    echo "MakeTarget base class process\n";
    return 1;
  }
}
class MakeTargetAll extends MakeTarget
{
  public $name = 'all';

  function init()
  {
  }
  function process()
  {
    echo "MakeTargetAll process\n";
    return 0;
  }
}
class MakeTargetExec extends MakeTarget
{
  public $name = 'exec';

  function init()
  {
  }
  function process()
  {
    echo "MakeTargetExec process\n";
    return 0;
  }
}
class MakeTargetMkDir
{
  function __construct($make,$name)

class Main
{
  function run()
  {
    echo "Main Execute\n";
    $make = new MakeFileTest();
    $make->process('all');
  }
}
$main = new Main();
$main->run();
?>