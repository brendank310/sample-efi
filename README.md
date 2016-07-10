Sample EFI Project
=====

The goal of this project is to explore the interaction between the different
types of EFI subsystem images, and the UEFI environment in general. Initially,
it builds to a "Hello, World!" example for each subsystem, but I'd like to add
the functionality to have apps interact with Boot Service and Runtime Service
drivers (the latter may be outside the scope of the project, that remains to be
seen).

UEFI Subsystems
=====
Application (EFI\_APPLICATION)
-----
A UEFI application is one that is run before ExitBootServices() is called,
and is resident in memory only for the duration of the application run. Once
it returns its status code, it can no longer be relied upon to be resident in 
memory.

Boot Service Driver (EFI\_BSDRV)
-----
A UEFI Boot Service Driver remains resident in memory until ExitBootServices()
is called, allowing it interact with other UEFI images while the firmware
retains control of the system. When ExitBootServices() is called, the image
can no longer be relied upon to be resident in memory.

Runtime Service Driver (EFI\_RTDRV)
-----
A UEFI Runtime Service Driver remains resident in memory even after the call
to ExitBootServices() is made. This allows for operating systems to interact
with the driver after the firmware environment has relinquished control.

 
