; ==============================================================================
;          MASTER BARE-METAL TYPE-1 HYPERVISOR BOOTLOADER ARCHITECTURE
; ==============================================================================
; Standardized 512-Byte MBR. Optimized alignment for Intel Real Silicon & QEMU.
; Enforces sterile paging zones and prepares stable entry to 64-Bit Long Mode.
; ==============================================================================

[bits 16]               
[org 0x7C00]

boot_start: 
    cli                                 ; Disable all interrupts during early bootstrap
    xor ax, ax                          ; Establish sterile segment layout base
    mov ss, ax
    mov ds, ax 
    mov gs, ax 
    mov fs, ax 
    mov sp, 0x7C00                      ; Baseline stack setup below bootloader zone

    ; Clear low memory buffer zone for early parameters (0x4000)
    mov di, 0x4000            
    mov cx, 256                
    xor al, al                  
    rep stosb      

load_kernel:                    
    mov ax, 0x0600                      ; Target segment address: 0x0600 * 16 = 0x6000
    mov es, ax
    xor bx, bx                          ; Offset = 0 (Destination physical RAM: 0x6000)

    ; Load exactly 127 sectors from disk (approx 63.5KB capacity for Hypervisor Core)
    mov ah, 0x02                        ; Command: Read Sectors
    mov al, 127                         ; Read 127 continuous sectors into 0x6000
    mov ch, 0                           ; Cylinder 0
    mov dh, 0                           ; Head 0
    mov cl, 2                           ; Sector 2 (Sector 1 is this MBR)
    int 0x13                    

    xor ax, ax                          ; Reset ES selector back to sterile zero context
    mov es, ax

    lgdt [gdt_descriptor]               ; Load 32-bit transition descriptor framework

    ; Enter Protected Mode (Activate PE Bit in CR0)
    mov eax, cr0
    or  eax, 1                    
    mov cr0, eax 

    jmp 0x08:boot_middle                ; Flush prefetch queue and jump to 32-bit Code Segment

; ==============================================================================
; 32-BIT PROTECTED MODE PHASE
; ==============================================================================
[bits 32]               
boot_middle:
    mov ax, 0x10                        ; Selector 0x10 points to gdt_data_32
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; Force dynamic hardware A20 Gate activation via Fast A20 port
    in  al, 0x92                    
    or  al, 2           
    out 0x92, al

    ; Clear full operational page table block footprint (0x1000 to 0x4000)
    ; Ensures zero collision with the loaded hypervisor payload at 0x6000
    mov edi, 0x1000         
    mov ecx, 3072                       ; Zero out exactly 12KB of sequential RAM memory
    xor eax, eax
    rep stosd

setup_identity_paging:
    ; 1. Map the root architectural layers (PML4 -> PDPT -> PD)
    ; Attributes: Present (Bit 0) + Read/Write (Bit 1) = 0x03
    mov dword [0x1000], 0x00002003      ; PML4 (0x1000) points to PDPT at 0x2000
    mov dword [0x1004], 0x00000000     
    
    mov dword [0x2000], 0x00003003      ; PDPT (0x2000) points to PD at 0x3000
    mov dword [0x2004], 0x00000000
    
    mov dword [0x3000], 0x00004003      ; PD (0x3000) points to Page Table Array at 0x4000
    mov dword [0x3004], 0x00000000

    ; 2. Execute loop mapping cycle for continuous 4KB frames inside Page Table
    mov edx, 0x4000                     ; EDX = Write pointer inside Page Table Array
    mov eax, 0x00000003                 ; EAX = Physical RAM base address (0x0 + flags)
    mov ecx, 50                         ; Map exactly 50 continuous pages (80KB isolation block)

loop_Start_Mapping:
    mov dword [edx], eax                ; Write lower 32 bits (Base RAM address + privilege flags)
    mov dword [edx + 4], 0              ; Clear upper 32 bits (Enforces disabled NX policy)
    
    add edx, 8                          ; Shift array pointer to next QWORD entry slot
    add eax, 0x1000                     ; Stride next target frame address by exactly 4KB
    
    dec ecx                             
    jnz loop_Start_Mapping             

switch_to_long_mode:
    mov eax, 0x1000                     ; Point CR3 directly to the PML4 page table root
    mov cr3, eax                

    mov eax, cr4
    or  eax, 1 << 5                     ; Activate Physical Address Extension (PAE Bit)
    mov cr4, eax

    mov ecx, 0xc0000080                 ; Target MSR: IA32_EFER
    rdmsr
    or  eax, 1 << 8                     ; Assert Long Mode Enable (LME Bit)
    wrmsr

    mov eax, cr0
    or  eax, 1 << 31                    ; Engage Paging Subsystem (PG Bit)
    mov cr0, eax

    jmp 0x18:init_lm                    ; Long jump into pure 64-bit Long Mode Segment

; ==============================================================================
; 64-BIT LONG MODE INITIALIZATION BRIDGE
; ==============================================================================
[bits 64]
init_lm:
    xor rax, rax                        ; Dissolve and serialize unprotected legacy selectors
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov rsp, 0x001FFFF0                 ; Secure High temporary stack assignment footprint
    mov rbp, rsp                

    ; Handover control seamlessly to hypervisor setup block at 0x6000
    mov rax, 0x0000000000006000         ; Location of the first active 64-bit sector payload
    jmp rax                             

; ==============================================================================
; BOOTLOADER TRANSITION DESCRIPTOR TABLE (GDT - INITIAL TRANSITION ONLY)
; ==============================================================================
align 8                         
gdt_start:
    dq 0x0000000000000000               ; Entry 0: Base Null Descriptor

gdt_code_32:                    
    dw 0xffff, 0x0000     
    db 0x00, 0x9a, 0xcf, 0x00           ; Entry 1: 32-Bit Protected Mode Code Selector (0x08)

gdt_data_32:                    
    dw 0xffff, 0x0000     
    db 0x00, 0x92, 0xcf, 0x00           ; Entry 2: 32-Bit Protected Mode Data Selector (0x10)

gdt_code_64:                    
    dw 0x0000, 0x0000
    db 0x00, 0x98, 0x20, 0x00           ; Entry 3: Pure 64-Bit Long Mode Code Selector (0x18) [Clean L-Bit Only]
gdt_end:

align 8                         
gdt_descriptor:
    dw gdt_end - gdt_start - 1          ; GDT Size tracking limit metric
    dd gdt_start                        ; Static 32-Bit Address base pointer for transition

; MBR Architecture Padding Constraint
times 510-($-$$) db 0
dw 0xAA55
