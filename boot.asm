[bits 16]               
[org 0x7C00]

boot_start: 
    cli 
    xor ax, ax
    mov ss, ax
    mov ds, ax 
    mov gs, ax 
    mov fs, ax 
    mov sp, 0x7C00                 

    mov di, 0x4000            
    mov cx, 256                
    xor al, al                  
    rep stosb      

load_kernel:                    
    mov ax, 0x0600              
    mov es, ax
    xor bx, bx                  

    mov ah, 0x02                
    mov al, 127                  
    mov ch, 0                   
    mov dh, 0                   
    mov cl, 2                   
    int 0x13                    

    xor ax, ax
    mov es, ax

    lgdt [gdt_descriptor]       

    mov eax, cr0
    or eax, 1                    
    mov cr0, eax 

    jmp 0x08:boot_middle      

[bits 32]               
boot_middle:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    in al, 0x92                    ; A20 activated
    or al, 2           
    out 0x92, al

    mov edi, 0x1000         
    mov ecx, 3072               
    xor eax, eax
    rep stosd

setup_identity_paging:
    ; 1. Map the root architectural layers (PML4 -> PDPT -> PD)
    ; All entries are configured as Present + Read/Write + Executable (Bits 0 and 1 set)
    mov dword [0x1000], 0x00002003     ; PML4 (0x1000) points to PDPT at 0x2000
    mov dword [0x1004], 0x00000000     ; Clear the upper 32 bits of the entry
    
    mov dword [0x2000], 0x00003003     ; PDPT (0x2000) points to PD at 0x3000
    mov dword [0x2004], 0x00000000
    
    mov dword [0x3000], 0x00004003     ; PD (0x3000) points to the first Page Table at 0x4000
    mov dword [0x3004], 0x00000000

    ; 2. Initialize loop parameters for the Page Table (PT) mapping cycle
    mov edx, 0x4000                    ; EDX = Physical destination memory inside the PT (0x4000)
    mov eax, 0x00000003                ; EAX = Physical base address of target RAM (0x00000000 + 0x03 for R,W,X permissions)
    mov ecx, 50                        ; ECX = Loop counter; mapping 50 continuous 4KB pages (80KB total memory allocation)

loop_Start_Mapping:
    ; Write the 64-bit Page Table Entry (PTE) structurally into memory
    mov dword [edx], eax               ; Write lower 32 bits (Base physical address + flags)
    mov dword [edx + 4], 0             ; Clear upper 32 bits (Ensures NX policy remains disabled)
    
    add edx, 8                         ; Advance PT table pointer by 8 bytes (Enforcing strict QWORD alignment)
    add eax, 0x1000                    ; Advance next physical frame target by 4KB (Next physical page row)
    
    dec ecx                            ; Decrement the tracking loop counter
    jnz loop_Start_Mapping             ; If counter has not reached 0, map the next sequential page frame

switch_to_long_mode:
    mov eax, 0x1000             
    mov cr3, eax                

    mov eax, cr4
    or eax, 1 << 5              
    mov cr4, eax

    mov ecx, 0xc0000080         
    rdmsr
    or eax, 1 << 8              
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    jmp 0x18:init_lm            

[bits 64]
init_lm:
    xor rax, rax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov rsp, 0x1FFFF0            
    mov rbp, rsp                

    mov rax, 0x6000
    jmp rax  

; Working 100% on Qemu
align 8                         
gdt_start:
    dq 0x0                      

gdt_code_32:                    
    dw 0xffff, 0x0     
    db 0x0, 0x9a, 0xcf, 0x0     

gdt_data_32:                    
    dw 0xffff, 0x0     
    db 0x0, 0x92, 0xcf, 0x0     

gdt_code_64:                    
    dw 0xffff, 0x0000
    db 0x00, 0x9a, 0xaf, 0x00   
gdt_end:

align 8                         
gdt_descriptor:
    dw gdt_end - gdt_start - 1   
    dd gdt_start                

times 510-($-$$) db 0
dw 0xAA55
