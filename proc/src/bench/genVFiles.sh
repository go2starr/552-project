#!/bin/bash

rm -f vfiles.list

find ../../ -iname "*.v" ! -iname "*bench.v" ! -iname "t_*"  ! -iname "*hier*"> vfiles.list
