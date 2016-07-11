# A sample UEFI driver/application pair that communicate
# with each other. 
#
# Copyright (C) 2015 Brendan Kerrigan
# Author: Rian Quinn        <quinnr@ainfosec.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

ARCH            = $(shell uname -m | sed s,i[3456789]86,ia32,)

BSD_OBJS            = drivers/entry-bs.o 
BSD_TARGET          = bootservices-driver.efi

RTD_OBJS	= drivers/entry-rt.o
RTD_TARGET	= runtimeservices-driver.efi

APP_CPP_OBJS	= apps/cpp-test.o
APP_CPP_TARGET	= cpp-test.efi

APP_C_OBJS	= apps/main.o
APP_C_TARGET	= c-app.efi

COMMON_IINCS    = -Iinclude 
EFI_INC         = /usr/local/include/efi
EFI_IINCS        = -I$(EFI_INC) -I$(EFI_INC)/$(ARCH) -I$(EFI_INC)/protocol
EFI_LIB         = /usr/local/lib
GNU_EFI_LIB     = $(EFI_LIB)/gnuefi
EFI_CRT_OBJS    = $(EFI_LIB)/crt0-efi-$(ARCH).o
EFI_LDS         = $(EFI_LIB)/elf_$(ARCH)_efi.lds
CFLAGS          = $(COMMON_IINCS) $(EFI_IINCS) -fno-stack-protector -fpic \
		  -fshort-wchar -mno-red-zone -Wall

ifeq ($(ARCH),x86_64)
  CFLAGS += -DEFI_FUNCTION_WRAPPER
endif
CPPFLAGS	= $(CFLAGS) -fPIC

LDFLAGS         = -nostdlib -znocombreloc -T $(EFI_LDS) -shared \
		  -Bsymbolic -L $(EFI_LIB) -L $(GNU_EFI_LIB) $(EFI_CRT_OBJS)

all: bootservices-driver.efi runtimeservices-driver.efi c-app.efi cpp-test.efi

clean:
	rm *.so
	rm *.efi
	rm ks/*.o
	rm us/*.o

bootservices-driver.so: $(BSD_OBJS)
	ld $(LDFLAGS) $(BSD_OBJS) -o $@ -lefi -lgnuefi

runtimeservices-driver.so: $(RTD_OBJS)
	ld $(LDFLAGS) $(RTD_OBJS) -o $@ -lefi -lgnuefi

cpp-test.so: $(APP_CPP_OBJS)
	ld $(LDFLAGS) $(APP_CPP_OBJS) -o $@ -lefi -lgnuefi

c-app.so: $(APP_C_OBJS)
	ld $(LDFLAGS) $(APP_C_OBJS) -o $@ -lefi -lgnuefi

bootservices-driver.efi: bootservices-driver.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-bsdrv-$(ARCH) $^ $@

runtimeservices-driver.efi: runtimeservices-driver.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-rtdrv-$(ARCH) $^ $@

cpp-test.efi: cpp-test.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-app-$(ARCH) $^ $@

c-app.efi: c-app.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-app-$(ARCH) $^ $@
