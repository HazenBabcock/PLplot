#!/bin/sh
# Test suite for java examples.
#
# Copyright (C) 2004  Alan W. Irwin
#
# This file is part of PLplot.
#
# PLplot is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Library Public License as published
# by the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# PLplot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public License
# along with PLplot; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# This is called from plplot-test.sh with $device, $dsuffix,
# and $options defined.
# N.B. $CLASSPATH must be defined properly and the path must point
# to the java and javac commands for this to work.

# The java examples were automatically built in the make install step
# by cd $prefix/lib
# javac -d java java/plplot/examples/*.java.
# This is equivalent to
# javac -d $CLASSPATH $CLASSPATH/plplot/examples/*.java
# but means that $CLASSPATH does not have to be set at build
# or install time like it does to execute these pre-compiled examples.

# Do the standard non-interactive examples.
# skip 14 because it requires two output files.
# skip 19 because it is not implemented
# skip 17, and 20 because they are interactive and not implemented.
# skip 21 because it delivers variable results depending on computer timing
# and load and is not implemented.
for index in 01 02 03 04 05 06 07 08 09 10 11 12 13 15 16 18; do
  java plplot.examples.x${index} -dev $device -o x${index}j.$dsuffix $options
done
