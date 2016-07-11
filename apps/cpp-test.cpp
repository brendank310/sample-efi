extern "C" {
#include <efi.h>
#include <efilib.h>
#include <common.h>
}

class test {
	public:
		test() : data(5), stringy(L"Blah blah blah\n")
		{

		}
		~test() {}
		const wchar_t *dump()
		{
			return stringy;	
		}	
	private:
		uint32_t data;
		const wchar_t *stringy;
};


extern "C" EFI_STATUS
efi_main (EFI_HANDLE image, EFI_SYSTEM_TABLE *systab)
{
	test cppobj;
  EFI_STATUS status = uefi_call_wrapper((void*)(systab->ConOut->OutputString),
                                        2,
                                        systab->ConOut,
                                        cppobj.dump());
	return status;
}
