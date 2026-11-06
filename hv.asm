[bits 64]
[org 0x5000]           

; ============================================================================
; THERMAL AND TEMPERATURE SENSORS
; ============================================================================

IA32_THERM_STATUS           equ 0x19C   ; Core-level digital thermal sensor
                                        ; Bits 22:16 = Temperature delta below TjMax
                                        ; Bit 31     = Valid bit (Must be 1 to trust read)

IA32_PACKAGE_THERM_STATUS   equ 0x1B1   ; Package-level digital thermal sensor
                                        ; Reports the hottest temperature on the whole die
                                        ; Bits 22:16 = Package temperature delta below TjMax

MSR_TEMPERATURE_TARGET      equ 0x1A2   ; Factory absolute reference values
                                        ; Bits 23:16 = TjMax (Maximum allowable temperature)
                                        ; Use formula: True_Temp = TjMax - Delta

; ============================================================================
; HARDWARE THROTTLING AND CRISIS INDICATORS
; ============================================================================

IA32_THERM_INTERRUPT        equ 0x19B   ; Controls hardware thermal thresholds
                                        ; Bit 0  = High-temperature interrupt enable
                                        ; Bit 2  = Critical temperature interrupt enable

MSR_THERM2_CTL              equ 0x19D   ; Hardware Clock Modulation Control
                                        ; If a rootkit tries to bypass your scheduler by forcing 
                                        ; clock modulation to hide its cycles, reading this reveals it.
; ============================================================================
; EXTENDED POWER AND ELECTRICAL LIMITS
; ============================================================================

MSR_PKG_POWER_LIMIT         equ 0x610   ; Controls average sustainable power levels (PL1 and PL2)
                                        ; Bit 63 = Clamp lock (Flipping this to 1 makes the limits 
                                        ; unchangeable until a cold motherboard reset!)

MSR_PP0_ENERGY_STATUS       equ 0x639   ; Energy consumption specifically for the CPU Cores
                                        ; (Combine this with MSR_PKG_ENERGY_STATUS [0x611] to isolate 
                                        ; exactly how much power the uncore vs the cores are draining).
; ============================================================================
; SILICON-LEVEL SECURITY AND MITIGATION STATUS
; ============================================================================

IA32_ARCH_CAPABILITIES      equ 0x10A   ; Enumerates hardware-level vulnerabilities (Read-Only)
                                        ; Bit 0  = RDCL_NO (If 1, the CPU is immune to Rogue Data Cache Load)
                                        ; Bit 2  = RSBA_NO (Immune to speculative branch exploits)

IA32_SPEC_CTRL              equ 0x48    ; Speculative Execution Controls (Indirect Branch Controls)
                                        ; Bit 0  = IBRS (Indirect Branch Restricted Speculation)
                                        ; Bit 1  = STIBP (Single Thread Indirect Branch Predictor)
                                        ; Your Hypervisor will lock this to prevent cross-core leakage!

IA32_THERM_CONTROL          equ 0x19A   ; Software clock modulation control
                                        ; If a malicious driver tries to intentionally stall or 
                                        ; simulate an hardware choke to manipulate your AI's timeline,
                                        ; checking this register exposes if duty cycling is being forced.

IA32_MISC_ENABLE            equ 0x1A0   ; Master processor feature toggles
                                        ; Bit 16 = Enhanced Intel SpeedStep technology enable.
                                        ; Bit 38 = Turbo Mode Disable.
                                        ; If a rootkit tries to over-clock the CPU to intentionally 
                                        ; step past your temperature threshold tracking, it will modify this.

IA32_TSC_DEADLINE           equ 0x6E0   ; Local APIC high-precision timer deadline
                                        ; Your scheduler can use this to guarantee your AI core 
                                        ; wakes up exactly when it needs to, independent of the 
                                        ; main core's instruction pipeline.
; ============================================================================
; INTEL CORE TELEMETRY DEFINITIONS
; ============================================================================

IA32_PERF_STATUS            equ 0x198   ; Performance and Voltage Status Register (Read-Only)
                                        ; Bits 15:0  = Current Frequency Multiplier (P-State)
                                        ; Bits 47:32 = Voltage Identification (VID) target

MSR_VR_CURRENT_CONFIG       equ 0x601   ; Voltage Regulator Current Configuration (PL4)
                                        ; Bits 12:0  = Current Limit (IccMax) in 1/8 A steps
                                        ; Bit 31     = LOCK BIT (If 1, register is write-locked)

; ============================================================================
; FIXED-FUNCTION ARCHITECTURAL PERFORMANCE COUNTERS
; ============================================================================

IA32_FIXED_CTR_CTRL         equ 0x38D   ; Controls Fixed Counter operating rings
                                        ; Your Hypervisor will use this to enable counting 
                                        ; specifically for Ring 1, 2, and 3 code execution.

IA32_FIXED_CTR0             equ 0x309   ; Counts: INSTR_RETIRED.ANY
                                        ; Increments every single time an instruction finishes 
                                        ; executing completely and safely.

IA32_FIXED_CTR1             equ 0x30A   ; Counts: CPU_CLK_UNHALTED.CORE
                                        ; Tracks actual core clock cycles spent processing.
                                        ; Form: CTR0 / CTR1 = Exact real-time IPC (Instructions Per Cycle).

; ============================================================================
; UNCORE AND COMPONENT ENERGY DOMAINS
; ============================================================================

MSR_DRAM_ENERGY_STATUS      equ 0x619   ; Continuous energy consumption ticker for RAM
                                        ; Measures electrical draw of the memory chips in Joules.
                                        ; If an attacker rapidly charges rows to flip bits, 
                                        ; this counter spikes immediately.

; ============================================================================
; MACHINE CHECK ARCHITECTURE (MCA) TELEMETRY
; ============================================================================

IA32_MCG_STATUS             equ 0x17A   ; Global Machine Check Status Register
                                        ; Bit 1 = EIPV (Error IP Valid: holds the exact instruction 
                                        ;         address that caused the physical panic).
                                        ; Bit 2 = MCIP (Machine Check In Progress status marker).

; ==============================================================================
; INTEL VMCS COMPONENT ENCODING DEFINITIONS (x86_64)
; ==============================================================================

; ------------------------------------------------------------------------------
; 16-Bit Control Fields
; ------------------------------------------------------------------------------
VMCS_CTRL_VIRTUAL_PROCESSOR_IDENTIFIER  EQU 0x00000000
VMCS_CTRL_POSTED_INTERRUPT_NOTI_VECTOR  EQU 0x00000002
VMCS_CTRL_EPTP_INDEX                    EQU 0x00000004

; ------------------------------------------------------------------------------
; 16-Bit Guest State Fields
; ------------------------------------------------------------------------------
VMCS_GUEST_ES_SELECTOR                  EQU 0x00000800
VMCS_GUEST_CS_SELECTOR                  EQU 0x00000802
VMCS_GUEST_SS_SELECTOR                  EQU 0x00000804
VMCS_GUEST_DS_SELECTOR                  EQU 0x00000806
VMCS_GUEST_FS_SELECTOR                  EQU 0x00000808
VMCS_GUEST_GS_SELECTOR                  EQU 0x0000080A
VMCS_GUEST_LDTR_SELECTOR                EQU 0x0000080C
VMCS_GUEST_TR_SELECTOR                  EQU 0x0000080E
VMCS_GUEST_PML_INDEX                    EQU 0x00000812

; ------------------------------------------------------------------------------
; 16-Bit Host State Fields
; ------------------------------------------------------------------------------
VMCS_HOST_ES_SELECTOR                   EQU 0x00000C00
VMCS_HOST_CS_SELECTOR                   EQU 0x00000C02
VMCS_HOST_SS_SELECTOR                   EQU 0x00000C04
VMCS_HOST_DS_SELECTOR                   EQU 0x00000C06
VMCS_HOST_FS_SELECTOR                   EQU 0x00000C08
VMCS_HOST_GS_SELECTOR                   EQU 0x00000C0A
VMCS_HOST_TR_SELECTOR                   EQU 0x00000C0C

; ------------------------------------------------------------------------------
; 64-Bit Control Fields
; ------------------------------------------------------------------------------
VMCS_CTRL_IO_BITMAP_A_ADDRESS           EQU 0x00002000
VMCS_CTRL_IO_BITMAP_B_ADDRESS           EQU 0x00002002
VMCS_CTRL_MSR_BITMAP_ADDRESS            EQU 0x00002004
VMCS_CTRL_VMEXIT_MSR_STORE_ADDRESS      EQU 0x00002006
VMCS_CTRL_VMEXIT_MSR_LOAD_ADDRESS       EQU 0x00002008
VMCS_CTRL_VMENTRY_MSR_LOAD_ADDRESS      EQU 0x0000200A

; ==============================================================================
; INTEL VMCS COMPONENT ENCODING DEFINITIONS (PART 2)
; ==============================================================================

; ------------------------------------------------------------------------------
; 64-Bit Control Fields
; ------------------------------------------------------------------------------
VMCS_CTRL_EOI_EXIT_BITMAP_0             EQU 0x0000201C
VMCS_CTRL_EOI_EXIT_BITMAP_1             EQU 0x0000201E
VMCS_CTRL_EOI_EXIT_BITMAP_2             EQU 0x00002020
VMCS_CTRL_EOI_EXIT_BITMAP_3             EQU 0x00002022
VMCS_CTRL_EPT_POINTER_LIST_ADDRESS      EQU 0x00002024
VMCS_CTRL_VMREAD_BITMAP_ADDRESS         EQU 0x00002026
VMCS_CTRL_VMWRITE_BITMAP_ADDRESS        EQU 0x00002028
VMCS_CTRL_VIRT_EXCEPTION_INFO_ADDRESS   EQU 0x0000202A
VMCS_CTRL_XSS_EXITING_BITMAP            EQU 0x0000202C
VMCS_CTRL_ENCLS_EXITING_BITMAP          EQU 0x0000202E
VMCS_CTRL_TSC_MULTIPLIER                EQU 0x00002032

; ------------------------------------------------------------------------------
; 64-Bit Read-Only Data Fields (VM-Exit Information)
; ------------------------------------------------------------------------------
VMCS_GUEST_PHYSICAL_ADDRESS             EQU 0x00002400

; ------------------------------------------------------------------------------
; 64-Bit Guest State Fields
; ------------------------------------------------------------------------------
VMCS_GUEST_VMCS_LINK_POINTER            EQU 0x00002800
VMCS_GUEST_DEBUGCTL                     EQU 0x00002802
VMCS_GUEST_PAT                          EQU 0x00002804
VMCS_GUEST_EFER                         EQU 0x00002806
VMCS_GUEST_PERF_GLOBAL_CTRL             EQU 0x00002808
VMCS_GUEST_PDPTE0                       EQU 0x0000280A
VMCS_GUEST_PDPTE1                       EQU 0x0000280C
VMCS_GUEST_PDPTE2                       EQU 0x0000280E
VMCS_GUEST_PDPTE3                       EQU 0x00002810

; ------------------------------------------------------------------------------
; 64-Bit Host State Fields
; ------------------------------------------------------------------------------
VMCS_HOST_PAT                           EQU 0x00002C00

; ==============================================================================
; INTEL VMCS COMPONENT ENCODING DEFINITIONS (PART 3)
; ==============================================================================

; ------------------------------------------------------------------------------
; 32-Bit Control Fields
; ------------------------------------------------------------------------------
VMCS_CTRL_PIN_BASED_VM_EXECUTION_CONTROLS       EQU 0x00004000
VMCS_CTRL_PROCESSOR_BASED_VM_EXECUTION_CONTROLS EQU 0x00004002
VMCS_CTRL_EXCEPTION_BITMAP                      EQU 0x00004004
VMCS_CTRL_PAGEFAULT_ERROR_CODE_MASK             EQU 0x00004006
VMCS_CTRL_PAGEFAULT_ERROR_CODE_MATCH            EQU 0x00004008
VMCS_CTRL_CR3_TARGET_COUNT                      EQU 0x0000400A
VMCS_CTRL_VMEXIT_CONTROLS                       EQU 0x0000400C
VMCS_CTRL_VMEXIT_MSR_STORE_COUNT                EQU 0x0000400E
VMCS_CTRL_VMEXIT_MSR_LOAD_COUNT                 EQU 0x00004010
VMCS_CTRL_VMENTRY_CONTROLS                      EQU 0x00004012
VMCS_CTRL_VMENTRY_MSR_LOAD_COUNT                EQU 0x00004014
VMCS_CTRL_VMENTRY_INTERRUPTION_INFO_FIELD       EQU 0x00004016
VMCS_CTRL_VMENTRY_EXCEPTION_ERROR_CODE          EQU 0x00004018
VMCS_CTRL_VMENTRY_INSTRUCTION_LENGTH            EQU 0x0000401A
VMCS_CTRL_TPR_THRESHOLD                         EQU 0x0000401C
VMCS_CTRL_SECONDARY_PROC_BASED_VM_EXEC_CONTROLS EQU 0x0000401E
VMCS_CTRL_PLE_GAP                               EQU 0x00004020
VMCS_CTRL_PLE_WINDOW                            EQU 0x00004022

; ------------------------------------------------------------------------------
; 32-Bit Read-Only Data Fields (VM-Exit Information)
; ------------------------------------------------------------------------------
VMCS_VM_INSTRUCTION_ERROR                       EQU 0x00004400
VMCS_EXIT_REASON                                EQU 0x00004402
VMCS_VMEXIT_INTERRUPTION_INFORMATION            EQU 0x00004404
VMCS_VMEXIT_INTERRUPTION_ERROR_CODE             EQU 0x00004406
VMCS_IDT_VECTORING_INFORMATION                  EQU 0x00004408
VMCS_IDT_VECTORING_ERROR_CODE                   EQU 0x0000440A
VMCS_VMEXIT_INSTRUCTION_LENGTH                  EQU 0x0000440C
VMCS_VMEXIT_INSTRUCTION_INFO                    EQU 0x0000440E

; ------------------------------------------------------------------------------
; 32-Bit Guest State Fields (Segment Limits)
; ------------------------------------------------------------------------------
VMCS_GUEST_ES_LIMIT                             EQU 0x00004800
VMCS_GUEST_CS_LIMIT                             EQU 0x00004802
VMCS_GUEST_SS_LIMIT                             EQU 0x00004804
VMCS_GUEST_DS_LIMIT                             EQU 0x00004806
VMCS_GUEST_FS_LIMIT                             EQU 0x00004808


; ==============================================================================
; INTEL VMCS COMPONENT ENCODING DEFINITIONS (PART 4)
; ==============================================================================

; ------------------------------------------------------------------------------
; 32-Bit Guest & Host State Fields
; ------------------------------------------------------------------------------
VMCS_GUEST_LDTR_ACCESS_RIGHTS           EQU 0x00004820
VMCS_GUEST_TR_ACCESS_RIGHTS             EQU 0x00004822
VMCS_GUEST_INTERRUPTIBILITY_STATE       EQU 0x00004824
VMCS_GUEST_ACTIVITY_STATE               EQU 0x00004826
VMCS_GUEST_SMBASE                       EQU 0x00004828
VMCS_GUEST_SYSENTER_CS                  EQU 0x0000482A
VMCS_GUEST_VMX_PREEMPTION_TIMER_VALUE   EQU 0x0000482E
VMCS_HOST_SYSENTER_CS                   EQU 0x00004C00

; ------------------------------------------------------------------------------
; Natural Width Control Fields
; ------------------------------------------------------------------------------
VMCS_CTRL_CR0_GUEST_HOST_MASK           EQU 0x00006000
VMCS_CTRL_CR4_GUEST_HOST_MASK           EQU 0x00006002
VMCS_CTRL_CR0_READ_SHADOW               EQU 0x00006004
VMCS_CTRL_CR4_READ_SHADOW               EQU 0x00006006
VMCS_CTRL_CR3_TARGET_VALUE_0            EQU 0x00006008
VMCS_CTRL_CR3_TARGET_VALUE_1            EQU 0x0000600A
VMCS_CTRL_CR3_TARGET_VALUE_2            EQU 0x0000600C
VMCS_CTRL_CR3_TARGET_VALUE_3            EQU 0x0000600E

; ------------------------------------------------------------------------------
; Natural Width Read-Only Data Fields (VM-Exit Information)
; ------------------------------------------------------------------------------
VMCS_EXIT_QUALIFICATION                 EQU 0x00006400
VMCS_VMEXIT_IO_RCX                      EQU 0x00006402
VMCS_VMEXIT_IO_RSX                      EQU 0x00006404
VMCS_VMEXIT_IO_RDI                      EQU 0x00006406
VMCS_VMEXIT_IO_RIP                      EQU 0x00006408
VMCS_EXIT_GUEST_LINEAR_ADDRESS          EQU 0x0000640A

; ------------------------------------------------------------------------------
; Natural Width Guest State Fields (Bases & Registers)
; ------------------------------------------------------------------------------
VMCS_GUEST_CR0                          EQU 0x00006800
VMCS_GUEST_CR3                          EQU 0x00006802
VMCS_GUEST_CR4                          EQU 0x00006804
VMCS_GUEST_ES_BASE                      EQU 0x00006806
VMCS_GUEST_CS_BASE                      EQU 0x00006808
VMCS_GUEST_SS_BASE                      EQU 0x0000680A
VMCS_GUEST_DS_BASE                      EQU 0x0000680C
VMCS_GUEST_FS_BASE                      EQU 0x0000680E
VMCS_GUEST_GS_BASE                      EQU 0x00006810
VMCS_GUEST_LDTR_BASE                    EQU 0x00006812
VMCS_GUEST_IA32_BNDCFGS                 EQU 0x0000682C ; Natural-Width Guest MPX Bounds Configuration
VMCS_GUEST_IA32_RTIT_CTL                EQU 0x0000682E ; Natural-Width Guest Processor Trace Control
VMCS_GUEST_IA32_LBR_CTL                 EQU 0x00006830 ; Natural-Width Guest Last Branch Record Control
VMCS_GUEST_IA32_SPEC_CTRL               EQU 0x00006844 ; Natural-Width Guest Speculation Mitigation Control
VMCS_CTRL_VMX_PREEMPTION_TIMER_VALUE    EQU 0x00004832 ; 32-Bit VMX Preemption Timer Boundary Count

; ==============================================================================
; INTEL VMCS COMPONENT ENCODING DEFINITIONS (PART 5)
; ==============================================================================

; ------------------------------------------------------------------------------
; Natural Width Guest State Fields (Remaining Bases & Registers)
; ------------------------------------------------------------------------------
VMCS_GUEST_TR_BASE                      EQU 0x00006814
VMCS_GUEST_GDTR_BASE                    EQU 0x00006816
VMCS_GUEST_IDTR_BASE                    EQU 0x00006818
VMCS_GUEST_DR7                          EQU 0x0000681A
VMCS_GUEST_RSP                          EQU 0x0000681C
VMCS_GUEST_RIP                          EQU 0x0000681E
VMCS_GUEST_RFLAGS                       EQU 0x00006820
VMCS_GUEST_PENDING_DEBUG_EXCEPTIONS     EQU 0x00006822
VMCS_GUEST_SYSENTER_ESP                 EQU 0x00006824
VMCS_GUEST_SYSENTER_EIP                 EQU 0x00006826

; ------------------------------------------------------------------------------
; Natural Width Host State Fields (Registers & Stack)
; ------------------------------------------------------------------------------
VMCS_HOST_CR0                           EQU 0x00006C00
VMCS_HOST_CR3                           EQU 0x00006C02
VMCS_HOST_CR4                           EQU 0x00006C04
VMCS_HOST_FS_BASE                       EQU 0x00006C06
VMCS_HOST_GS_BASE                       EQU 0x00006C08
VMCS_HOST_TR_BASE                       EQU 0x00006C0A
VMCS_HOST_GDTR_BASE                     EQU 0x00006C0C
VMCS_HOST_IDTR_BASE                     EQU 0x00006C0E
VMCS_HOST_SYSENTER_ESP                  EQU 0x00006C10
VMCS_HOST_SYSENTER_EIP                  EQU 0x00006C12
VMCS_HOST_RSP                           EQU 0x00006C14
VMCS_HOST_RIP                           EQU 0x00006C16

; ==============================================================================
; INTEL VMX GUEST CET (CONTROL-FLOW ENFORCEMENT TECHNOLOGY) FIELD ENCODINGS
; ==============================================================================
VMCS_GUEST_S_CET                                EQU 0x0000686C ; Natural-Width Guest Supervisor CET Control Register
VMCS_GUEST_SSP                                  EQU 0x0000686E ; Natural-Width Guest Shadow Stack Pointer
VMCS_GUEST_INTR_SSP_TABLE                       EQU 0x00006870 ; Natural-Width Guest Interrupt Shadow Stack Table Pointer


; ==============================================================================
; INTEL VMCS ADVANCED COMPONENT ENCODINGS (SUPPLEMENTAL MASTER LIST)
; ==============================================================================

; ------------------------------------------------------------------------------
; 16-Bit Control Fields (Advanced Virtualization)
; ------------------------------------------------------------------------------
VMCS_CTRL_GUEST_CORE_ID                 EQU 0x00000006 ; Guest Core Tracking Index

; ------------------------------------------------------------------------------
; 64-Bit Control Fields (Tertiary Controls & Extended Paging)
; ------------------------------------------------------------------------------
VMCS_CTRL_TERTIARY_VM_EXEC_CONTROLS     EQU 0x00002034 ; CRITICAL: Tertiary Execution Bitmask pointer
VMCS_CTRL_HLAT_POINTER                  EQU 0x00002040 ; Hypervisor-Managed Linear Address Translation Pointer
VMCS_CTRL_PASID_TRANSLATION_TABLE       EQU 0x00002042 ; Linear address space tracking association table

; ------------------------------------------------------------------------------
; 64-Bit Guest State Fields (Advanced Security / Protection Keys)
; ------------------------------------------------------------------------------
VMCS_GUEST_IA32_PKRU                    EQU 0x00002812 ; Guest Protection Key Register for User Pages
VMCS_GUEST_IA32_PASID                   EQU 0x00002814 ; Guest Process Address Space ID MSR tracking
VMCS_GUEST_SHARED_VIRT_MEM_POINTER      EQU 0x00002816 ; Shared Virtual Memory Pointer block

; ------------------------------------------------------------------------------
; 64-Bit Host State Fields (Advanced Security / Protection Keys)
; ------------------------------------------------------------------------------
VMCS_HOST_IA32_PKRS                    EQU 0x00002C06 ; Host Supervisor Protection Key tracking register

; ------------------------------------------------------------------------------
; 32-Bit Control Fields (Tertiary, Virtual Interrupts & Exceptions)
; ------------------------------------------------------------------------------
VMCS_CTRL_TERTIARY_PROC_BASED_CONTROLS  EQU 0x0000402A ; Tertiary Processor-Based Execution Controls Bitmask
VMCS_CTRL_NOTIFY_WINDOW                 EQU 0x0000402C ; Notification window for VM-Exits
VMCS_CTRL_VIRTUAL_INTERRUPT_DELIVERY    EQU 0x0000401E ; Advanced APIC virtualization control bit
VMCS_CTRL_SPECULATION_CTRL_BITMAP       EQU 0x00004030 ; Hard intercepts for guest mitigation commands

; ------------------------------------------------------------------------------
; 32-Bit VM-Exit Information Fields (Extended Logging Telemetry)
; ------------------------------------------------------------------------------
VMCS_VMEXIT_MTF_QUALIFICATION           EQU 0x00004410 ; Monitor Trap Flag debug status detail
VMCS_VMEXIT_TERTIARY_EXIT_REASON        EQU 0x00004412 ; Detailed classification for tertiary exit conditions

; ------------------------------------------------------------------------------
; Natural Width Control & State Fields (Advanced Shadow Pages)
; ------------------------------------------------------------------------------
VMCS_CTRL_HLAT_RESERVED_SHADOW          EQU 0x00006010 ; Shadow verification vector for secure paging layers
VMCS_GUEST_IA32_S_CET_BASE              EQU 0x00006828 ; Guest Supervisor Mode CET Shadow Stack base pointer
VMCS_HOST_IA32_S_CET_BASE               EQU 0x00006C18 ; Host Supervisor Mode CET Shadow Stack base pointer

; ==============================================================================
; INTEL VMCS FINAL ARCHITECTURAL COMPONENTS (100% EXHAUSTIVE COMPLETION)
; ==============================================================================

; --- 16-Bit Control Fields (Advanced APIC & Virtualization Tracking) ---
VMCS_CTRL_POSTED_INTERRUPT_STATUS_VECTOR        EQU 0x00000002 ; Overlapped interrupt notification vector
VMCS_GUEST_INTERRUPT_STATUS                     EQU 0x00000810 ; Tracking virtual execution interrupt requests
VMCS_GUEST_PML_INDEX                            EQU 0x00000812 ; Page Modification Log tracker index

; --- 64-Bit Control Fields (Advanced Hardware Monitoring Acceleration) ---
VMCS_CTRL_VIRTUAL_APIC_ADDRESS                  EQU 0x00002012 ; Direct hardware page for Virtual APIC tracking
VMCS_CTRL_APIC_ACCESS_ADDRESS                   EQU 0x00002014 ; Memory-mapped layout for APIC access acceleration
VMCS_CTRL_POSTED_INTERRUPT_DESC_ADDRESS         EQU 0x00002016 ; Physical pointer to posted descriptor structure
VMCS_CTRL_VMFUNC_CONTROLS                       EQU 0x00002018 ; Allowed VMFUNC instruction parameters
VMCS_CTRL_PML_ADDRESS                           EQU 0x0000200E ; Base physical address for Page Modification Logging

; --- 32-Bit Control Fields (Dynamic Interception & Extended Filtering) ---
VMCS_CTRL_PAGEFAULT_ERROR_CODE_MASK             EQU 0x00004006 ; Isolates precise bits during guest page fault loops
VMCS_CTRL_PAGEFAULT_ERROR_CODE_MATCH            EQU 0x00004008 ; Evaluates exception signature before exit handling
VMCS_CTRL_CR3_TARGET_COUNT                      EQU 0x0000400A ; Maximum target list boundary for valid CR3 values
VMCS_CTRL_TPR_THRESHOLD                         EQU 0x0000401C ; Task Priority Register intercept boundary limits
VMCS_CTRL_PLE_GAP                               EQU 0x00004020 ; Pause Loop Exiting parameter window
VMCS_CTRL_PLE_WINDOW                            EQU 0x00004022 ; Pause Loop Exiting execution loop duration timer

; --- 32-Bit VM-Exit Information Fields (Deep Exception Diagnostics) ---
VMCS_VMEXIT_INTERRUPTION_ERROR_CODE             EQU 0x00004406 ; Identifies underlying fault vectors on intercept
VMCS_IDT_VECTORING_INFORMATION                  EQU 0x00004408 ; Diagnostic data on vectoring history during transition
VMCS_IDT_VECTORING_ERROR_CODE                   EQU 0x0000440A ; Precise structural code log of vectoring faults




;bootloader finish! part 1 start:

;Remember free memory space: 0x1000 to 0x9FFFF 
;this is how the VMWRITE works: VMWRITE Field_Encoding, Source_Register
Hypervisor_start:
trying_vmptrld:
mov rax, 0x01B22FE4 
mov cr4, rax

mov rax, 0x01
mov dq [Hypervisr_start], rax

mov eax, 0x00B00408
mov dr7, eax

xor eax, eax 
mov rdi, 0x7C00
mov rcx, 64
stosq

mov rdi, 0x4000
mov rcx, 0x400 
rep stosq  

mov ebx, 0x10000 
mov dword [rbx], eax        
vmxon [rbx]    


mov ecx, 0x5000
mov dword [ecx], eax
vmclear [rcx]
vmptrld [rcx]

jmp $ ; DEBUGGING

; PART 2 HOST:
Host_area:    

    mov rax, VMCS_HOST_RSP          ;0x00006C14 
    mov rbx, 0x45000
    vmwrite rax, rbx          


    mov eax, VMCS_HOST_CR0          ;0x00006C00
    mov rbx, 0x80010031
    vmwrite rax, rbx 

    mov rax, VMCS_HOST_CR4          ;0x00006C04
    mov rbx, cr4
    or rbx, 0x01B22FE4              
    mov cr4, rbx
    vmwrite rax, rbx    

.continue:

    mov rax, 0x8000000000001000   
    mov cr3, rax                     ; PML4 

    mov eax, VMCS_HOST_CR3           ; 0x00006c02
    mov rbx, cr3
    vmwrite rax, rbx   

    mov eax, VMCS_HOST_RIP           ; 0x00006C16 
    mov ebx, VM_Exit_Handler                                 
    vmwrite rax, rbx

mov rbx, cs
and rbx, ~7                  
mov rax, VMCS_HOST_CS_SELECTOR          ; 0x00000C02
vmwrite rax, rbx           

mov rbx, ds
and rbx, ~7
mov rax, VMCS_HOST_DS_SELECTOR          ; 0x00000C06
vmwrite rax, rbx

mov rbx, es
and rbx, ~7
mov rax, VMCS_HOST_ES_SELECTOR          ; 0x00000C00
vmwrite rax, rbx

; ==============================================================================
; HARDWARE-ENFORCED VMX ARCHITECTURE INITIALIZATION LOOP
; ==============================================================================

setup_host_and_execution_controls:
    ; 1. Initialize Host Segment Selectors
    mov rbx, ss
    and rbx, ~7                         ; Strip Request Privilege Level (RPL) bits
    mov rax, VMCS_HOST_SS_SELECTOR      ; Encoding: 0x00000C04
    vmwrite rax, rbx

    xor rbx, rbx                        ; Clear selector for unused segment blocks
    mov rax, VMCS_HOST_FS_SELECTOR      ; Encoding: 0x00000C08
    vmwrite rax, rbx

    mov rax, VMCS_HOST_GS_SELECTOR      ; Encoding: 0x00000C0A
    vmwrite rax, rbx

    ; 2. Neutralize Legacy SysEnter Control Registers
    xor rbx, rbx                        ; Zero-out legacy execution paths
    mov rax, VMCS_HOST_SYSENTER_CS      ; Encoding: 0x00004C00
    vmwrite rax, rbx
    
    mov rax, VMCS_HOST_SYSENTER_ESP     ; Encoding: 0x00006C10
    vmwrite rax, rbx
    
    mov rax, VMCS_HOST_SYSENTER_EIP     ; Encoding: 0x00006C12
    vmwrite rax, rbx

    ; 3. Configure Active Task Register Selector
    mov rbx, 0x0008                     ; Set direct selector index pointing to Host GDT TSS descriptor
    mov rax, VMCS_HOST_TR_SELECTOR      ; Encoding: 0x00000C0C
    vmwrite rax, rbx

    ; 4. Lock Down Primary Processor Intercept Controls
    mov rbx, 0x94006172                 ; Master execution intercept bitmask profile
    mov rax, VMCS_CTRL_PROCESSOR_BASED_VM_EXECUTION_CONTROLS ; Encoding: 0x00004002
    vmwrite rax, rbx             

    ; 5. Sync Extended Feature Enable Register (IA32_EFER MSR)
    mov ecx, 0xC0000080                 ; MSR address parameter for IA32_EFER
    rdmsr                        
    shl rdx, 32
    or rdx, rax                         ; RDX now holds the full 64-bit combined MSR value
    
    mov rax, VMCS_HOST_IA32_EFER        ; Encoding: 0x00004C02
    vmwrite rax, rdx             
 
    ; 6. Commit Global VMX Transition Controls
    mov rbx, 0x00008200                 ; VM-Exit Control features configuration bitmask
    mov rax, VMCS_CTRL_VMEXIT_CONTROLS  ; Encoding: 0x0000400C (CORRECTED PARAMETER ORDER)
    vmwrite rax, rbx

    mov rbx, 0x00000200                 ; VM-Entry Control features configuration bitmask
    mov rax, VMCS_CTRL_VMENTRY_CONTROLS ; Encoding: 0x00004012
    vmwrite rax, rbx                       

    ; 1. Initialize Host Base Address Registers (FS and GS Bases)
    ; Replacing the unstable RCX-driven loop with direct, hardware-safe commits
    xor ecx, ecx                        ; Clear RCX to serve as a zero-base template
    
    mov rax, VMCS_HOST_FS_BASE          ; Encoding: 0x00006C06
    vmwrite rax, rcx            

    mov rax, VMCS_HOST_GS_BASE          ; Encoding: 0x00006C08
    vmwrite rax, rcx            

    ; 2. Configure Host Task Register Base Address
    mov rax, VMCS_HOST_TR_BASE          ; Encoding: 0x00006C0A
    vmwrite rax, rcx            

    ; 3. Extract and Commit Active Host GDTR Base Pointer
    mov rax, VMCS_HOST_GDTR_BASE        ; Encoding: 0x00006C0C 
    sub rsp, 16                         ; Enforce strict 16-byte stack alignment rules
    sgdt [rsp]                          ; Store active 80-bit GDTR descriptor block
    mov rbx, [rsp + 2]                  ; Extract the absolute 64-bit linear base address
    add rsp, 16                         ; Restore stack layout instantly
    vmwrite rax, rbx             

    ; 4. Lock Down Exception Virtualization Intercept Bitmask
    mov rax, VMCS_CTRL_EXCEPTION_BITMAP ; Encoding: 0x00004004 (Targeted diagnostic trap)
    mov rbx, 0x00227558                 ; Hard-intercept mask for internal page/debug faults
    vmwrite rax, rbx             
   
    ; 5. Deploy Extended Page Tables Root Pointer (EPTP)
    mov rax, VMCS_CTRL_EPT_POINTER      ; Encoding: 0x0000201A
    mov rbx, 0x0000601E                 ; Nested paging base allocation framework pointer
    vmwrite rax, rbx             

    ; 6. Commit Active Host Interrupt Descriptor Table Base (IDTR)
    mov rax, VMCS_HOST_IDTR_BASE        ; Encoding: 0x00006C0E
    lea rbx, [rel host_idt_table]       ; Resolve absolute address of host exception handlers
    vmwrite rax, rbx                        

    ; 7. Synchronize Host VMX Extended Feature Enable Register (IA32_EFER)
    mov ecx, 0xC0000080                 ; IA32_EFER MSR Address pointer
    rdmsr                       
    shl rdx, 32
    or  rdx, rax                        ; RDX now securely bundles the full 64-bit EFER layout
    mov rax, VMCS_HOST_IA32_EFER        ; Encoding: 0x00004C02
    vmwrite rax, rdx                    ; CORRECTED: Written from RDX context link

    ; 8. Commit Host Memory Type Range Control (IA32_PAT)
    mov ecx, 0x00000277                 ; IA32_CR_PAT MSR Address pointer
    rdmsr
    shl rdx, 32
    or  rdx, rax
    mov rax, VMCS_HOST_IA32_PAT         ; Encoding: 0x00002C00
    vmwrite rax, rdx            
      
    ; 9. Bind Host Core Architectural Performance Counter Control
    mov ecx, 0x0000038F                 ; IA32_PERF_GLOBAL_CTRL MSR Address pointer
    rdmsr                       
    shl rdx, 32                  
    or  rdx, rax               
    mov rax, VMCS_HOST_IA32_PERF_GLOBAL_CTRL ; Encoding: 0x00002C04          
    vmwrite rax, rdx             

    ; 10. Enforce Control-Flow Enforcement Technology (CET) Protection Layers
    ; Replacing loop indices with robust unrolled configurations to block stack spills
    xor rcx, rcx                        ; Zero-out validation matrix template
    
    mov rax, VMCS_HOST_IA32_S_CET       ; Encoding: 0x00006C18
    vmwrite rax, rcx          

    ; 11. Finalize MSR Lifecycle Boundaries
    mov rax, VMCS_CTRL_VMEXIT_MSR_LOAD_COUNT ; Encoding: 0x00004010
    mov rcx, 1                          ; Establish single tracking boundary slot
    vmwrite rax, rcx        

    jmp $ ;DEBUGGING HOST 

    ;----- HOST FINISH DEBUGGING ONLY -----

;----------------- GUEST INITIALIZATION AND VMCS CONFIGURATION -------------

; ==============================================================================
; INTEL VMX GUEST-STATE ARCHITECTURE INITIALIZATION (PART 1)
; ==============================================================================

Guest_area:
    ; -------------------------------------------------------------------------
    ; Part 1: Intercepting and Storing the Guest IDTR Base Address & Core Masks
    ; -------------------------------------------------------------------------
    sub rsp, 16                         ; Enforce strict 16-byte stack alignment rules
    sidt [rsp]                          ; Store active IDTR descriptor block
    mov rbx, [rsp + 2]                  ; Extract the absolute 64-bit linear base address
    add rsp, 16                         ; Restore temporary stack layout instantly

    mov rax, VMCS_GUEST_IDTR_BASE       ; Encoding: 0x00006818 
    vmwrite rax, rbx                                   

    ; Capturing raw encodings 0x2000 and 0x2002 (Physical I/O Intercept Bitmaps)
    mov rbx, 0xFFFFFFFFFFFFFFFF         ; Hard-intercept all primary and secondary I/O ports
    mov rax, VMCS_CTRL_IO_BITMAP_A_ADDRESS ; Encoding: 0x00002000 
    vmwrite rax, rbx             

    mov rax, VMCS_CTRL_IO_BITMAP_B_ADDRESS ; Encoding: 0x00002002 
    vmwrite rax, rbx             

    ; Read-Modify-Write sequence for CPU-Based Execution Intercept Controls
    mov rcx, VMCS_CTRL_PROCESSOR_BASED_VM_EXECUTION_CONTROLS ; Encoding: 0x00004002
    vmread rbx, rcx                     ; CORRECTED: Read field encoding from RCX into RBX
    or ebx, (1 << 15) | (1 << 16)       ; Activate CR3-load and CR3-store hardware intercepts
    vmwrite rcx, rbx                    ; Commit updated intercept profile back to silicon

    mov rax, VMCS_CTRL_CR3_TARGET_COUNT ; Encoding: 0x0000400A 
    xor rbx, rbx                        ; Zero-out target count to force exits on unmapped CR3 switches
    vmwrite rax, rbx            

    ; -------------------------------------------------------------------------
    ; Part 2: Enforcing Instruction Pointer (RIP), Stack Pointer (RSP), and RFLAGS
    ; -------------------------------------------------------------------------
    lea rbx, [rel Guest_Code_Entry]     ; Enforce RIP-Relative addressing to prevent memory shifting
    mov rax, VMCS_GUEST_RIP             ; Encoding: 0x0000681E 
    vmwrite rax, rbx            

    xor rbx, rbx                        ; Clear Guest initial stack pointer context
    mov rax, VMCS_GUEST_RSP             ; Encoding: 0x0000681C 
    vmwrite rax, rbx           

    mov rbx, 0x00000002                 ; Enforce mandatory Intel bit alignment rules for RFLAGS
    mov rax, VMCS_GUEST_RFLAGS          ; Encoding: 0x00006820 
    vmwrite rax, rbx           

    ; -------------------------------------------------------------------------
    ; Part 3: Architecting Segment Isolation & Access Rights Protection Rules
    ; -------------------------------------------------------------------------
    
    ; 1. Configure active protected mode execution segments (Unlocking Long Mode)
    mov rbx, 0x0000209B                 ; Code Segment (CS) AR: Present + Ring 0 + Code + Long Mode
    mov rax, VMCS_GUEST_CS_ACCESS_RIGHTS ; Encoding: 0x00004816
    vmwrite rax, rbx            

    mov rbx, 0x00004093                 ; Stack Segment (SS) AR: Present + Ring 0 + Data + Read/Write
    mov rax, VMCS_GUEST_SS_ACCESS_RIGHTS ; Encoding: 0x00004818
    vmwrite rax, rbx

    ; 2. Enforce absolute isolation on remaining data segments (Unusable State)
    ; Replacing the unstable loop sequence with direct, hardware-safe unrolled commits
    mov rbx, 0x00010000                 ; Set Bit 16 (Segment Unusable Attribute Flag)
    
    mov rax, VMCS_GUEST_ES_ACCESS_RIGHTS ; Encoding: 0x00004814
    vmwrite rax, rbx            

    mov rax, VMCS_GUEST_DS_ACCESS_RIGHTS ; Encoding: 0x0000481A
    vmwrite rax, rbx            

    mov rax, VMCS_GUEST_FS_ACCESS_RIGHTS ; Encoding: 0x0000481C
    vmwrite rax, rbx            

    mov rax, VMCS_GUEST_GS_ACCESS_RIGHTS ; Encoding: 0x0000481E
    vmwrite rax, rbx            

    ; ==============================================================================
; INTEL VMX GUEST-STATE ARCHITECTURE INITIALIZATION (PART 2)
; ==============================================================================

Guest_state_segments_and_registers:
    ; -------------------------------------------------------------------------
    ; Part 4: Forcing Hardware Segment Selector Constraints via Silicon Register Mapping
    ; -------------------------------------------------------------------------
    xor rcx, rcx                        ; Enforce absolute zero context for data selectors
    
    mov rbx, cs
    and rbx, ~3                         ; Sanitize CPL/RPL Privilege Bits (Force Ring 0 baseline)
    
    mov rax, VMCS_GUEST_CS_SELECTOR     ; Encoding: 0x00000802
    vmwrite rax, rbx

    mov rax, VMCS_GUEST_SS_SELECTOR     ; Encoding: 0x00000804
    vmwrite rax, rbx

    mov rax, VMCS_GUEST_ES_SELECTOR     ; Encoding: 0x00000800
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_DS_SELECTOR     ; Encoding: 0x00000806
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_FS_SELECTOR     ; Encoding: 0x00000808
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_GS_SELECTOR     ; Encoding: 0x0000080A
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_LDTR_SELECTOR   ; Encoding: 0x0000080C
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_TR_SELECTOR     ; Encoding: 0x0000080E
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_INTERRUPT_STATUS ; Encoding: 0x00000810
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_PML_INDEX       ; Encoding: 0x00000812
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Part 5: Establishing Hardwired Secondary 64-Bit System Registers (Hex Dumps)
    ; -------------------------------------------------------------------------
    mov rbx, 0xFFFFFFFFFFFFFFFF         ; Non-functional shadow reference mapping pointer
    mov rax, VMCS_GUEST_VMCS_LINK_POINTER ; Encoding: 0x00002800
    vmwrite rax, rbx             

    mov rax, VMCS_GUEST_DEBUGCTL        ; Encoding: 0x00002802
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_PAT             ; Encoding: 0x00002804
    vmwrite rax, rcx             

    mov rbx, 0x0000000000000D01         ; Enforce Long Mode Active (LME=1, LMA=1, SCE=1 flags combined)
    mov rax, VMCS_GUEST_EFER            ; Encoding: 0x00002806
    vmwrite rax, rbx             

    mov rax, VMCS_GUEST_PERF_GLOBAL_CTRL ; Encoding: 0x00002808
    vmwrite rax, rcx             

    ; Note: PDPTE fields are omitted by the CPU in 64-bit mode, initialized to zero for security
    mov rax, VMCS_GUEST_PDPTE0          ; Encoding: 0x0000280A
    vmwrite rax, r改善xc             

    mov rax, VMCS_GUEST_PDPTE1          ; Encoding: 0x0000280C
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_PDPTE2          ; Encoding: 0x0000280E
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_PDPTE3          ; Encoding: 0x00002810
    vmwrite rax, rcx

   ; ==============================================================================
; INTEL VMX GUEST-STATE ARCHITECTURE INITIALIZATION (PART 3)
; ==============================================================================

Guest_Memory_Limits_Bases_And_Execution_Controls:
    ; -------------------------------------------------------------------------
    ; Part 6: Defining Flat Memory Addressing Boundaries (Limits and Bases)
    ; -------------------------------------------------------------------------
    mov rbx, 0xFFFFFFFF                 ; Max 32-bit limit value for flat memory segments
    
    mov rax, VMCS_GUEST_CS_LIMIT        ; Encoding: 0x00004802 (CORRECTED from 0x4402)
    vmwrite rax, rbx             

    mov rax, VMCS_GUEST_DS_LIMIT        ; Encoding: 0x00004806 (CORRECTED from 0x4406)
    vmwrite rax, rbx             

    mov rax, VMCS_GUEST_SS_LIMIT        ; Encoding: 0x00004804 (CORRECTED from 0x4408)
    vmwrite rax, rbx             

    ; Restoring strict zero context for unusable data segments limits
    xor rcx, rcx                        
    
    mov rax, VMCS_GUEST_ES_LIMIT        ; Encoding: 0x00004800
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_FS_LIMIT        ; Encoding: 0x00004808
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_GS_LIMIT        ; Encoding: 0x0000480A
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_LDTR_LIMIT      ; Encoding: 0x0000480C
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_TR_LIMIT        ; Encoding: 0x0000480E
    vmwrite rax, rcx             

    ; Enforcing zero-base linear execution space for flat 64-bit mode layout
    mov rax, VMCS_GUEST_ES_BASE         ; Encoding: 0x00006806 
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_CS_BASE         ; Encoding: 0x00006808
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_SS_BASE         ; Encoding: 0x0000680A
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_DS_BASE         ; Encoding: 0x0000680C
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_FS_BASE         ; Encoding: 0x0000680E
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_GS_BASE         ; Encoding: 0x00006810
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_LDTR_BASE       ; Encoding: 0x00006812
    vmwrite rax, rcx             

    mov rax, VMCS_GUEST_TR_BASE         ; Encoding: 0x00006814
    vmwrite rax, rcx             

    ; Neutralizing execution sub-registers and hardware trace components
    mov rax, VMCS_GUEST_DEBUGCTL        ; Encoding: 0x00002802 (CORRECTED architectural MSR link)
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_SYSENTER_CS     ; Encoding: 0x0000482A
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_PENDING_DEBUG_EXCEPTIONS ; Encoding: 0x00006822
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_SYSENTER_ESP    ; Encoding: 0x00006824
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_SYSENTER_EIP    ; Encoding: 0x00006826
    vmwrite rax, rcx             

    ; -------------------------------------------------------------------------
    ; Part 7: Extracting and Mirroring Descriptor Tables (GDTR/IDTR)
    ; -------------------------------------------------------------------------
    sub rsp, 16                         ; Maintain strict 16-byte stack frame alignment
    sgdt [rsp]                          ; Capture host GDT layout as base template for the guest
    mov rbx, [rsp + 2]                  ; Extract absolute 64-bit linear base address
    movzx rdx, word [rsp]               ; Extract 16-bit GDT structural limit size boundary
    add rsp, 16                         ; Clean temporary stack space instantly

    mov rax, VMCS_GUEST_GDTR_BASE       ; Encoding: 0x00006816
    vmwrite rax, rbx

    mov rax, VMCS_GUEST_GDTR_LIMIT      ; Encoding: 0x00004810 (CORRECTED from 0x4410)
    vmwrite rax, rdx

    mov rax, VMCS_GUEST_IDTR_BASE       ; Encoding: 0x00006818
    vmwrite rax, rcx
 
    mov rax, VMCS_GUEST_IDTR_LIMIT      ; Encoding: 0x00004812 (CORRECTED from 0x4412)
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Part 8: Silicon Core Infrastructure Controls & Security Enclaves
    ; -------------------------------------------------------------------------
    mov rbx, 0x00000400                 ; Enforce default standard hardware bit state for DR7
    mov rax, VMCS_GUEST_DR7             ; Encoding: 0x0000681A (CORRECTED from 0x4828)
    vmwrite rax, rbx            

    mov rax, VMCS_GUEST_INTERRUPTIBILITY_STATE ; Encoding: 0x00004824
    vmwrite rax, rcx             

    ; Note: Link pointer field is a 64-bit component initialized to zero for compliance
    mov rax, VMCS_CTRL_VMCS_LINK_POINTER ; Encoding: 0x00002800 (CORRECTED from 0x400E)
    mov rbx, 0xFFFFFFFFFFFFFFFF  
    vmwrite rax, rbx             
 
    mov rax, VMCS_GUEST_PERF_GLOBAL_CTRL ; Encoding: 0x00002808 (CORRECTED from 0x482E)
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_PAT             ; Encoding: 0x00002804 (CORRECTED from 0x6828)
    vmwrite rax, rcx

    mov rbx, 0x0000000000000D01         ; Enforce Long Mode Active context stability inside guest cage
    mov rax, VMCS_GUEST_EFER            ; Encoding: 0x00002806 (CORRECTED from 0x682A)
    vmwrite rax, rbx

    ; Zero-out modern hardware tracking mitigation layers to enforce raw sandbox baseline
    ; (Addresses: 0x682C, 0x682E, 0x6830 matching Intel architectural specifications)
    mov rax, VMCS_GUEST_IA32_BNDCFGS                  ; Encoding: 0x0000682C
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_IA32_RTIT_CTL                 ; Encoding: 0x0000682E
    vmwrite rax, rcx             
 
    mov rax, VMCS_GUEST_IA32_LBR_CTL                 ; Encoding: 0x00006830
    vmwrite rax, rcx             

; ==============================================================================
; ADVANCED GUEST SYSTEM REGISTERS & SHADOW TRACKING DEFINITIONS (EQU SUPPLEMENT)
; ==============================================================================

; ==============================================================================
; INTEL VMX GUEST-STATE ARCHITECTURE INITIALIZATION (PART 4)
; ==============================================================================

Guest_Execution_Context_And_Speculation_Controls:
    xor ecx, ecx                        ; Establish absolute sterile zero context for security blocks

    ; -------------------------------------------------------------------------
    ; Part 9: Locking Down Guest Control-Flow Enforcement Technology (CET)
    ; -------------------------------------------------------------------------
    ; Unrolling the loops to fix the critical argument inversion bug (Field vs Value)
    mov rax, VMCS_GUEST_S_CET           ; Encoding: 0x0000686C
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_SSP             ; Encoding: 0x0000686E
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_INTR_SSP_TABLE  ; Encoding: 0x00006870
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Part 10: Enforcing Guest Activity States & SMBASE Mitigation
    ; -------------------------------------------------------------------------
    mov rax, VMCS_GUEST_ACTIVITY_STATE  ; Encoding: 0x00004826
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_SMBASE          ; Encoding: 0x00004828 (Safe isolation allocation)
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Part 11: Speculation Defenses & VMX Architectural Timers
    ; -------------------------------------------------------------------------
    mov rax, VMCS_GUEST_IA32_SPEC_CTRL  ; Encoding: 0x00006844 (VERIFIED AUTHENTIC SILICON VALUE)
    vmwrite rax, rcx

    mov rax, VMCS_CTRL_VMX_PREEMPTION_TIMER_VALUE ; Encoding: 0x00004832
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Part 12: Neutralizing Virtual Interrupt and Extended Tracking Arrays
    ; -------------------------------------------------------------------------
    mov rax, VMCS_GUEST_PML_INDEX       ; Encoding: 0x00000812
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Part 13: Initializing Guest Page Directory Pointer Table Entries (PDPTE)
    ; -------------------------------------------------------------------------
    ; Enforcing proper sequential silicon order mapped to explicit master definitions
    mov rax, VMCS_GUEST_PDPTE0          ; Encoding: 0x0000280A
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_PDPTE1          ; Encoding: 0x0000280C
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_PDPTE2          ; Encoding: 0x0000280E
    vmwrite rax, rcx

    mov rax, VMCS_GUEST_PDPTE3          ; Encoding: 0x00002810
    vmwrite rax, rcx

    ; -------------------------------------------------------------------------
    ; Debug Boundary Checkpoint
    ; -------------------------------------------------------------------------
    jmp $                               ; Localized infinite loop for runtime verification

        
    
;GUEST FINISH! 

;----------------- PART: 4  VM-Execution Control Fields -----------------
VM_Execution_Control_Fields:
    mov ecx, 0x48D                  ; IA32_VMX_TRUE_PINBASED_CTLS MSR   0x48D
    rdmsr                       
    
    or  eax, 0x000000A9       
    and eax, edx               

    mov ecx, 0x00004000             ; PIN_BASED_VM_EXEC_CONTROLS    0x4000
    vmwrite rcx, rax         
          
    mov ecx, 0x48E                  ; IA32_VMX_TRUE_PROCBASED_CTLS  0x48E
    rdmsr                           

    and eax, edx                
    or  eax, 0x11016280             ;HLT, INVLPG, CR3, DR, I/O, MSR Bitmaps
    and eax, edx            

    mov ecx, 0x00004002             ; VMCS Encode Primary Processor Controls    0x4002
    vmwrite rcx, rax           

    mov ecx, 0x48B                  ; IA32_VMX_PROCBASED_CTLS2  0x48B
    rdmsr                          

    and eax, edx                
    or  eax, 0x00000846             ;  EPT(1), Descriptor Tables(2), WBINVD(6), RDRAND(11) 0x0846
    and eax, edx            

    mov ecx, 0x0000401E             ; VMCS Encode Secondary Controls    0x401E
    vmwrite rcx, rax              

    mov ecx, 0x49F                  ; IA32_VMX_PROCBASED_CTLS3     0x49F
    rdmsr                           

    and eax, edx                
    or  eax, 0x00000000             
    and eax, edx            

    mov ecx, 0x00004022             ; VMCS Encode Tertiary Controls    0x4022
    vmwrite rcx, rax                

Suffocate_APIC_Interrupts:
    mov rbx, 0xFFFFFFFFFFFFFFFF    
    mov eax, 0x0000201E             ; EOI_EXIT0 0x201E
    vmwrite rax, rbx                

    add eax, 2                      ; EOI_EXIT1 0x00002020
    xor ecx, ecx
    vmwrite rax, rcx               

    add eax, 2                      ; EOI_EXIT2 0x00002022
    vmwrite rax, rcx               

    add eax, 2                      ; EOI_EXIT3 0x00002024
    vmwrite rax, rcx         

Suffocate_Exceptions_And_Registers:
    mov ebx, 0xFFFFFFFF           
    mov eax, 0x00004004             ;  Exception Bitmap 
    vmwrite rax, rbx                

Setup_EPT_Pointer_Hardware:
    mov rbx, rdi                            
    or  rbx, 0x7E            
    mov eax, 0x0000201A             ;  EPT Pointer (EPTP) 
    vmwrite rax, rbx                                     

Suffocate_VM_Functions:
    xor edx, edx               
    
    mov eax, 0x00002018             ; VM-Function Controls 
    vmwrite rax, rdx               

Suffocate_SGX_And_Encryption:
    mov rbx, 0xFFFFFFFFFFFFFFFF     

    mov eax, 0x0000202E             ; ENCLS-Exiting Bitmap 0x0000202E   AI said: 0x00002030 
    vmwrite rax, rbx                

    add eax, 16                     ; PCONFIG-Exiting Bitmap 0x0000203E AI said: 0x0000203E
    vmwrite rax, rbx               

    mov eax, 0x00002034             ; XSS-Exiting Bitmap 0x00002034
    vmwrite rax, rbx                

Suffocate_SPP_And_HLAT:
    xor ebx, ebx                    

    mov eax, 0x00002030             ; Sub-Page-Permission-Table Pointer 
    vmwrite rax, rbx               

    mov eax, 0x00002040             ; HLAT Pointer 
    vmwrite rax, rbx               

Suffocate_PASID_Timeout_And_SEAM:
    mov eax, 0x00004020             ; Instruction-Timeout Control 
    vmwrite rax, rbx              

    mov eax, 0x00002042             ; SEAM Shared EPTP 0x2042
    vmwrite rax, rbx                

Suffocate_APIC_Timer:
    mov eax, 0x0000203A             ; Guest Deadline Shadow   0x203A
    vmwrite rax, rbx                           

;----------------- PART 5: VM-Exit Control Fields -----------------
init_secondary_and_msr_controls:
    ; IA32_VMX_EXIT_CTLS2 MSR
    mov ecx, 0x493                  
    rdmsr                                           
    and edx, eax                    

    ; SECONDARY_VM_EXIT_CONTROLS
    mov eax, 0x2044                         ;CHECK THE MSRS            
    vmwrite rax, rbx 

    ; VM-Exit MSR-Store Count
    mov eax, 0x400E                  
    vmwrite rax, rbx                

    ; VM-Exit MSR-Store Address
    mov eax, 0x4010             
    vmwrite rax, rbx                

    ; VM-Exit MSR-Load Count
    mov eax, 0x2006            
    vmwrite rax, rbx                

    ; VM-Exit MSR-Load Address
    mov eax, 0x2008             
    vmwrite rax, rbx

configure_vmcs_raw:
    ; --- Notification Vector ---
    mov eax, 0x0002                     
    mov ebx, 0x0002         
    vmwrite rax, rbx        

    ; --- EPTP  ---
    mov eax, 0x0004        
    mov ebx, 0x0000        
    vmwrite rax, rbx       

;----------------- PART 6: VM-ENTRY CONTROL FIELDS -----------------

  mov ecx, 0x48C                  ; IA32_VMX_TRUE_ENTRY_CTLS MSR
    rdmsr                          

    mov ebx, 0x204                    
    and ebx, edx                  
    or  ebx, eax           

    mov eax, 0x4012                 ; VM_ENTRY_CONTROLS
    vmwrite rax, rbx               

    mov ebx, 0x80000B0D                            

.write_event:
    mov eax, 0x00004016             ; VM_ENTRY_INTR_INFO_FIELD
    vmwrite rax, rbx 
; ---------------- The fields I forgot to do -----------------------

; Check it after the optimization because there can be some things you didnt consider

configure_vmcs_64bit_controls_raw:
    ; --- IO-A 
    mov eax, 0x2000                     ; 0x2000                      
    mov ebx, 0x00081000     
    vmwrite rax, rbx

    ; --- IO-B 
    add eax, 2                          ; 0x2002                           
    mov ebx, 0x00082000             
    vmwrite rax, rbx

    ; --- MSR   
    add eax, 2                          ; 0x2004
    mov ebx, 0x00083000     
    vmwrite rax, rbx

    ; --- MSR 
    add eax, 2                          ; 0x2006
    mov ebx, 0x00084000     
    vmwrite rax, rbx

    ; --- MSR
    add eax, 2                          ; 0x2008
    xor ebx, ebx    
    vmwrite rax, rbx

    ; --- MSR
    add eax, 2                          ; 0x200a                                                     
    vmwrite rax, rbx    

    ; --- VMCS 
    add eax, 2                          ; 0x200c                                                  
    mov rbx, 0xffffffffffffffff 
    vmwrite rax, rbx

    ; EPT
    add eax, 14                         ; 0x201a
    mov ebx, 0x0008001e     
    vmwrite rax, rbx

    ; --- PML 
    add eax, 12                         ; 0x200e
    xor ebx, ebx
    vmwrite rax, rbx

    ; --- 0x2010 ---
    add eax, 2                          ; 0x2010
    vmwrite rax, rbx

    ; --- PIC 
    add eax, 2                          ; 0x2012
    vmwrite rax, rbx

    ; --- PIC 
    add eax, 2                          ; 0x2014
    vmwrite rax, rbx

    ; --- Posted Interrupt Descriptor 
    add eax, 2                          ; 0x2016
    vmwrite rax, rbx

    ; --- 0x2018
    add eax, 2                          ; 0x2018
    vmwrite rax, rbx

configure_vmcs_64bit_controls_extended_raw:
    ; VMCS_CTRL_EOI_EXIT_BITMAP_0
    add eax, 4                          ; 0x201c     
    vmwrite rax, rbx

    ; VMCS_CTRL_EOI_EXIT_BITMAP_1
    add eax, 2                          ; 0x201e
    vmwrite rax, rbx

    ; VMCS_CTRL_EOI_EXIT_BITMAP_2
    add eax, 2                          ; 0x2020
    vmwrite rax, rbx

    ; VMCS_CTRL_EOI_EXIT_BITMAP_3
    add eax, 2                          ; 0x2022
    vmwrite rax, rbx

    ; VMCS_CTRL_EPT_POINTER_LIST_ADDRESS
    add eax, 2                          ; 0x2024
    vmwrite rax, rbx

    ; VMCS_CTRL_VMREAD_BITMAP_ADDRESS
    add eax, 2                          ; 0x2026
    vmwrite rax, rbx

    ; VMCS_CTRL_VMWRITE_BITMAP_ADDRESS
    add eax, 2                          ; 0x2028
    vmwrite rax, rbx

    ; VMCS_CTRL_VIRTUALIZATION_EXCEPTION_INFORMATION_ADDRESS
    add eax, 2                          ; 0x202a
    vmwrite rax, rbx

    ; VMCS_CTRL_XSS_EXITING_BITMAP
    add eax, 2                          ; 0x202c
    vmwrite rax, rbx

    ; VMCS_CTRL_ENCLS_EXITING_BITMAP
    add eax, 2                          ; 0x202e
    vmwrite rax, rbx

    ; VMCS_CTRL_TSC_MULTIPLIER
    add eax, 3                          ; 0x2032
    vmwrite rax, rbx

configure_vmcs_32bit_controls_raw:
    ; VMCS_CTRL_PIN_BASED_VM_EXECUTION_CONTROLS
    mov eax, 0x4000                     ; 0x4000
    mov ebx, 0x0000001f
    vmwrite rax, rbx

    ; VMCS_CTRL_PROCESSOR_BASED_VM_EXECUTION_CONTROLS
    add eax, 2                          ; 0x4002
    mov ebx, 0x04006172
    vmwrite rax, rbx

    ; VMCS_CTRL_EXCEPTION_BITMAP
    add eax, 2                          ; 0x4004
    mov ebx, 0x00040000
    vmwrite rax, rbx

    ; VMCS_CTRL_PAGEFAULT_ERROR_CODE_MASK
    add eax, 2                          ; 0x4006
    mov ebx, 0x00000000
    vmwrite rax, rbx

    ; VMCS_CTRL_CR3_TARGET_COUNT
    add eax, 4                          ; 0x400a
    mov ebx, 0x00000004
    vmwrite rax, rbx

    ; VMCS_CTRL_VMEXIT_CONTROLS
    add eax, 2                          ; 0x400c
    mov ebx, 0x0036efff
    vmwrite rax, rbx

    ; VMCS_CTRL_VMEXIT_MSR_STORE_COUNT
    add eax, 2                          ; 0x400e
    mov ebx, 0x00000001     
    vmwrite rax, rbx

    ; VMCS_CTRL_VMEXIT_MSR_LOAD_COUNT
    add eax, 2                          ; 0x4010
    xor ebx, ebx
    vmwrite rax, rbx

    ; VMCS_CTRL_PAGEFAULT_ERROR_CODE_MATCH
    sub eax, 2                          ; 0x4008
    vmwrite rax, rbx    

    ; VMCS_CTRL_VMENTRY_CONTROLS
    add eax, 4                          ; 0x4012
    mov ebx, 0x000011ff
    vmwrite rax, rbx
   
    ; VMCS_CTRL_VMENTRY_MSR_LOAD_COUNT
    add eax, 2                          ; 0x4014
    vmwrite rax, rbx

    ; VMCS_CTRL_VMENTRY_INTERRUPTION_INFORMATION_FIELD
    add eax, 2                          ; 0x4016
    vmwrite rax, rbx

    ; VMCS_CTRL_VMENTRY_EXCEPTION_ERROR_CODE
    add eax, 2                          ; 0x4018
    vmwrite rax, rbx

    ; VMCS_CTRL_VMENTRY_INSTRUCTION_LENGTH
    add eax, 2                          ; 0x401a
    vmwrite rax, rbx

    ; VMCS_CTRL_TPR_THRESHOLD
    add eax, 2                          ; 0x401c
    vmwrite rax, rbx

    ; VMCS_CTRL_PLE_GAP
    add eax, 4                          ; 0x4020
    vmwrite rax, rbx

    ; VMCS_CTRL_PLE_WINDOW
    add eax, 2                          ; 0x4022
    vmwrite rax, rbx

    ; VMCS_CTRL_SECONDARY_PROCESSOR_BASED_VM_EXECUTION_CONTROLS
    mov eax, 0x401e
    mov ebx, 0x000000a0
    vmwrite rax, rbx

    mov rdi, 0x7000
    
    mov dword [rdi], 0xC0000080  
    mov dword [rdi + 4], 0
    mov qword [rdi + 8], 0x500
      
    mov eax, 0x0000200A          ; HOST_IA32_MSR_LOAD_ADDR 
    mov ebx, 0x00007000      
    vmwrite rax, rbx

;----------------- PART 7: Defender IN OUT and EPT, TSS, CONFIRM FRAGMENT AND MORE! -----------------

    ; --------------------------------------------------------------------------
    ;  Speculative Execution Mitigations (Spectre/Meltdown)
    ; --------------------------------------------------------------------------
    mov ecx, 0x00000048         
    rdmsr                        
    or eax, 0x00000003          
    xor edx, edx               
    wrmsr                        

    ; --------------------------------------------------------------------------
    ;  VT-d IOMMU Page Table Initialization & Hardware Synchronization
    ; --------------------------------------------------------------------------
    xor rax, rax
    mov rcx, 1024                
    mov rdi, 0x00095000          
    rep stosq                    

    mov rax, 0x00096001          
    mov [0x00095000], rax        

    mov rax, 0x00080015          
    mov [0x00096000], rax        

    mov rbx, 0xFED90000          
    mov rax, 0x00095000          
    mov [rbx + 0x20], rax        

    mov eax, [rbx + 0x18]        
    or eax, 0x80000000           
    mov [rbx + 0x18], eax        

.vtd_sync_loop:
    mov eax, [rbx + 0x1C]        
    and eax, 0x80000000          
    jz .vtd_sync_loop  

    ; --------------------------------------------------------------------------
    ;  Block 3: Constructing Sterile EPT Partition for Sandbox Isolation
    ; --------------------------------------------------------------------------
    xor rax, rax
    mov rcx, 0x600
    mov rdi, 0x00080000        
    rep stosq

    mov rax, 0x00081007 
    mov [0x00080000], rax

    mov rax, 0x00082007
    mov [0x00081000], rax

    xor rdx, rdx
    xor rcx, rcx              

Predator_loop:
    mov rax, rdx  
    or rax, 0x9C
    mov [0x00082000 + rcx * 8], rax
    add rdx, 0x00200000            
    inc rcx
    cmp rcx, 512
    jne Predator_loop 

    mov eax, 0x0000201A                 ; 0x201A
    mov edx, 0x0008001E                 
    vmwrite rax, rdx 
    
    ; Advanced EPT Setup
    ; 1. Enable hardware capabilities via MSR (Includes Secondary Controls & RDTSC)
    mov ecx, 0x0000048B      
    rdmsr
    or eax, 0x00641040          
    wrmsr

    ; 2. Read, Modify, and Write Secondary Execution Controls (Activate EPT)
    mov rdx, 0x00002012     
    vmread rax, rdx          
    or rax, 0x01940008      
    vmwrite rdx, rax         

    ; 3. Configure Extended Page Table Pointer (EPTP) Address
    mov rax, 0x00002040      
    mov rbx, 0x0008001E     
    vmwrite rax, rbx                

    ; 4. Configure MSRs for optimization and global intercept policy
    mov ecx, 0x00000982          
    rdmsr
    or eax, 0x00000003         
    xor edx, edx
    wrmsr

; --------------------------------------------------------------------------
;  Block 4: TSS Verification and Fragment Validation Engine inside VM-Exit
; --------------------------------------------------------------------------
align 16
_tss_fragment_confirm:
    str cx                       
    sgdt [rsp - 10]             
    
    mov rbx, [rsp - 8]           
    movzx rcx, cx
    add rbx, rcx              
    
    movzx edx, word [rbx + 2]  
    mov eax, [rbx + 4]          
    and eax, 0xFF000000       
    or edx, eax                 
    mov eax, [rbx + 7]          
    and eax, 0x00FF0000        
    or edx, eax                 
    
    mov rsi, [rbx + 8]       
    shl rsi, 32
    or rdx, rsi              

    mov rsi, [rdx + 4]          
    mov rdi, 0x0000681C          ;0x681C
    vmread rax, rdi           
    
    cmp rax, rsi
    jae _hardware_trap_triggered 
    

_hardware_trap_triggered:
    mov rdx, 0x00006C16          
    xor rax, rax                 
    vmwrite rdx, rax
    vmcall                  

    ; Intercept and Block CPUID Modifications
    mov ecx, 0x000001A0          ; MSR Register: IA32_MISC_ENABLE
    rdmsr
    
    or edx, 0x00000001          
    wrmsr

    or rax, 0x00001000          
    vmwrite rdx, rax
    jmp vmlaunch_starting              

;----------------- PART 8: LAUNCHING -----------------

vmlaunch_starting:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor ebp, ebp 
    xor edi, edi
    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor r11, r11
    vmlaunch     
    
HyperVisor_end:

VM_Exit_Handler:
push rax 
push rbx
push rcx 
push rdx



pop rdx
pop rcx
pop rbx 
pop rax
xor rbp, rbp

section .data
    align 4096

vmxon_region: 
    times 4096 db 0     

    vmxon_pointer: dq 0
    guest_stack_top: dq 0 

    align 16
host_idt_table: times 256 dq 0 

    Guest_Code_Entry:
    mov eax, 0xABCDEF  
    
section .bss
    align 16
guest_stack_bottom:
    resb 1024           
guest_stack_limit:
