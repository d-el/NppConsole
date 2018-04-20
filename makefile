# 
# This file is part of Notepad++ console plugin.
# Copyright ©2011 Mykhajlo Pobojnyj <mpoboyny@web.de>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# 

BINNAME=NppConsole.dll
OUTDIR=bin
OBJDIR=obj
INCDIR=NppConsole/include
SRCDIR=NppConsole/source
RCDIR=NppConsole/resources
TARGETDIR="D:/"

# Cross compiling and selecting different set of gcc/bin-utils
# ---------------------------------------------------------------------------
#
# CROSS_COMPILE specify the prefix used for all executables used
# during compilation. Only gcc and related bin-utils executables
# are prefixed with $(CROSS_COMPILE).
# CROSS_COMPILE can be set on the command line
# make CROSS_COMPILE=ia64-linux-
# Alternatively CROSS_COMPILE can be set in the environment.
# Default value for CROSS_COMPILE is arm-none-eabi-
CROSS_COMPILE_BIN ?= "C:/ProgramFiles/mingw-w64/x86_64-7.3.0-win32-seh-rt_v5-rev0/mingw64/bin/"
CROSS_COMPILE ?= $(CROSS_COMPILE_BIN)x86_64-w64-mingw32-

AS		= $(CROSS_COMPILE)gcc
LD		= $(CROSS_COMPILE)gcc
CC		= $(CROSS_COMPILE)g++
CPP		= $(CC)g++
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY	= $(CROSS_COMPILE)objcopy
OBJDUMP	= $(CROSS_COMPILE)objdump
SIZE	= $(CROSS_COMPILE)size
RC		= $(CROSS_COMPILE_BIN)windres

CFLAGS=-Wall -Wno-missing-braces -Wno-conversion-null -m64
LDFLAGS=-s -lstdc++ -lcomctl32 -lgdi32 -static -shared -Wl,--subsystem,windows

DEFINES=-DUNICODE -D_UNICODE
#DEFINES+= -D_DEBUG -DDEBUG
#DEFINES+= -D_SYSLOG

INCLUDES= -I./NppConsole/include -I./NppConsole/NppCommon -I./Common

ifeq ($(debug),yes)
  CFLAGS+= -g -O
  DEFINES+= -D_DEBUG -DDEBUG
endif

ifeq ($(log),yes)
  DEFINES+= -D_SYSLOG
endif

HEADERS:=$(wildcard $(INCDIR)/*)
SOURCES:=$(wildcard $(SRCDIR)/*)
OBJECTS:=$(patsubst $(SRCDIR)/%.cxx, $(OBJDIR)/%.o,$(SOURCES))

RCFILES:=$(wildcard $(RCDIR)/*)
RCSOURCE:=$(RCDIR)/resources.rc
RCOBJECT:=$(OBJDIR)/resources.o


all : $(OUTDIR) $(BINNAME)

test:
	@echo $(HEADERS)
	@echo $(SOURCES)
	@echo $(OBJECTS)
	@echo $(RCFILES)
	@echo $(RCSOURCE)
	@echo $(RCOBJECT)

$(OUTDIR):
	mkdir $(OUTDIR)
	mkdir $(OBJDIR)

$(BINNAME): $(OBJECTS) $(RCOBJECT)
	@echo [LD] $<
	$(LD) -o $(OUTDIR)/$(BINNAME) $(OBJECTS) $(RCOBJECT) $(LDFLAGS)
	cp $(OUTDIR)/$(BINNAME) $(TARGETDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.cxx $(HEADERS)
	@echo [CC] $<
	$(CC) $(CFLAGS) $(DEFINES) $(INCLUDES) -c $< -o $@

$(RCOBJECT): $(RCFILES)
	@echo [RC] $<
	$(RC) $(INCLUDES) -i $(RCSOURCE) -o $(RCOBJECT)

clean:
	@rm -rf $(OBJDIR)
	@rm -rf $(OUTDIR)

.PHONY: clean
