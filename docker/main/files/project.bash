#!/bin/bash

# script for SpinalDev project creation, and other 

usage="$(basename "$0") (create | run) -n name [-t type] [-a action] [-h] [-y] 

-- script to support SpinalHDL user projects

where:

    create:  create projects
    run:     run projects (compile fw hdl, run fw testbench, compile sw, synthesise fw impl)
    no args: interactive mode

    -h  show this help text
    -n  project name    : name of the project
    -t  type of project : standalone, soc, workshop                 
    -a  project action  : fwbuild, fwtest, impl, swbuild, intellijhdl, eclipsesw, openocdsim, fwtest_initram
                 (needs to be specified for $(basename "$0") run)
    -y  user does not need to confirm action"

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

type=""
name=""
confirm=""

# extract first argument
mainaction="$1"

#echo "main action " "$mainaction" $#
if [  "$#" != "0" ] && [ "$mainaction" != "-h" ]
then
  shift 1 
  if [ "$mainaction" != "create" ]
  then
      echo "main action" "$mainaction" "not yet supported"
      exit 1
  fi
fi

# extract next arguments
while getopts ':h:t:n:y:a:' option; do

  case "$option" in
    h) echo "$usage"
       exit
       ;;
    t) type=$OPTARG
       ;;
    n) name=$OPTARG
       ;;
    a) action=$OPTARG
       ;;  
    :)
       if [ "$OPTARG" == "y" ]
       then
         confirm="y"       
       elif [ "$OPTARG" != "h" ]
       then
	   printf "missing argument for -%s\n" "$OPTARG" >&2	   
	   exit 1
       else
	   echo "$usage" >&2; exit	   
       fi
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

#interactive mode if no arguments are provided
if [ "$type" == "" ] || [ "$name" == "" ]
then
    echo "$usage" >&2
    echo "entering interactive mode ..."
    read -p "Continue [y/n]: " continue
    case $continue in
	[Yy]*)  ;;  
	*) echo "Aborted"; exit ;;
    esac
    read -p "Create project [c] or run project [r]: " cr
    case $cr in
	[c]*)
	    mainaction="create"
	    read -p "Project name: " name
	    read -p "Project type: " type
	    ;;
	[r]*)
	    mainaction="run"
	    # todo: list directories or get current directory (has hdl, has sw folder, has src folder, build.sbt put in function)
	    read -p "Project name  : " name
	    # automatically detect type
	    if [ -d "$directory/$name/hdl" ]
	    then
		type="standalone" 
	    else
		type="soc" 
	    fi
	    read -p "Project action: " action
	    ;;
	*) echo "Aborted"; exit ;;
    esac
    
fi
   
echo "type: $type, name: $name"

# get action command
if [ "$mainaction" == "create" ]
then

    case "$type" in
	("standalone")	
	    echo "creating standalone project named $name ..."	
	    command="cd $directory; git clone https://github.com/plex1/SpinalDevTemplateStandalone.git $name"
	    ;;
	("soc")
	    echo "creating SoC project named $name ..."
	    command="cd $directory; git clone https://github.com/plex1/SpinalDevTemplateSoc.git $name"
	    ;;
	
	("workshop")
	    echo "creating SoC project named $name ..."
	    command="cd $directory; git clone https://github.com/SpinalHDL/SpinalWorkshop.git $name"
	    ;;

	*)
	    echo "project type"  "$type" "not found! Aborted ..."
	    exit
	    ;;
	
    esac
    
elif [ "$mainaction" == "run" ]
then
    
     if [ "$type" == "standalone" ]
     then
	dirpart="hdl" 
     else
	dirpart="fw/hdl/" 
     fi
    case "$action" in
	
	("swbuild")
	    echo "building sw for project named $name ..."
	    if [ "$type" == "muraxsoc" ]
	    then
		command="cd $directory/$name/sw; make"
	    else
		echo "not possible to build sw for this project type"
		exit 1
	    fi
	    ;;
	("fwbuild")
	    echo "compile the spinal HDL firmware for project named $name ..."	    
	    command="cd $directory/$name/$dirpart; sbt run"
	    ;;
	("fwtest")
	    echo "run the spinal HDL test bench for project named $name ..." 
	    command="cd $directory/$name/$dirpart;sbt test:run"
	    ;;
	("impl")
	    echo "implement design for project named $name ..." 
	    command="cd $directory/$name/$dirpart/impl/iCE40HX8K-EVB; make compile"
	    ;;
	    
	*)
	    echo "action "  "$action" "not found! Aborted ..."
	    exit
	    ;;
	
    esac    
fi

# action
echo "Action: " "\"$command\""
if [ "$confirm" != "y" ]
then
   read -p "Confirm action [y/n]: " confirm
fi
case $confirm in
    [Yy]*) eval "$command"; ret_code=$? ;;  
    *) echo "Aborted"; exit ;;
esac

# describe result
if [ $ret_code == 0 ] && [ "$mainaction" == "create" ]
then
    echo "You'll now find your project template in the folder: " "$directory/$name"
fi
