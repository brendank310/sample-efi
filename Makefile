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

KS_BS_OBJS            = ks/entry-bs.o 
KS_BS_TARGET          = bootservices-ks.efi

KS_RT_OBJS	= ks/entry-rt.o
KS_RT_TARGET	= runtime-ks.efi

US_OBJS		= us/main.o
US_TARGET	= us.efi

COMMON_IINCS    = -Iinclude 
EFI_INC         = /usr/local/include/efi
EFI_IINCS        = -I$(EFI_INC) -I$(EFI_INC)/$(ARCH) -I$(EFI_INC)/protocol
EFI_LIB         = /usr/local/lib
GNU_EFI_LIB     = $(EFI_LIB)/gnuefi
EFI_CRT_OBJS    = $(EFI_LIB)/crt0-efi-$(ARCH).o
EFI_LDS         = $(EFI_LIB)/elf_$(ARCH)_efi.lds
SUBSYS		= app
CFLAGS          = $(COMMON_IINCS) $(EFI_IINCS) -fno-stack-protector -fpic \
		  -fshort-wchar -mno-red-zone -Wall
ifeq ($(ARCH),x86_64)
  CFLAGS += -DEFI_FUNCTION_WRAPPER
endif

LDFLAGS         = -nostdlib -znocombreloc -T $(EFI_LDS) -shared \
		  -Bsymbolic -L $(EFI_LIB) -L $(GNU_EFI_LIB) $(EFI_CRT_OBJS)

all: bootservicesdrv.efi runtimedrv.efi app.efi

clean:
	rm *.so
	rm *.efi
	rm ks/*.o
	rm us/*.o

bootservicesdrv.so: $(KS_BS_OBJS)
	SUBSYS=bsdrv
	ld $(LDFLAGS) $(KS_BS_OBJS) -o $@ -lefi -lgnuefi

runtimedrv.so: $(KS_RT_OBJS)
	SUBSYS=rtdrv
	ld $(LDFLAGS) $(KS_RT_OBJS) -o $@ -lefi -lgnuefi

app.so: $(US_OBJS)
	SUBSYS=app
	ld $(LDFLAGS) $(US_OBJS) -o $@ -lefi -lgnuefi

bootservicesdrv.efi: bootservicesdrv.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-bsdrv-$(ARCH) $^ $@

runtimedrv.efi: runtimedrv.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-rtdrv-$(ARCH) $^ $@

app.efi: app.so
	objcopy -j .text -j .sdata -j .data -j .dynamic \
		-j .dynsym  -j .rel -j .rela -j .reloc \
		--target=efi-app-$(ARCH) $^ $@
