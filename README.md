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

    mov dword [0x1000], 0x2003     ; PML4 (0x1000) 
    mov dword [0x2000], 0x3003     ; PDPT (0x2000) 
    mov dword [0x3000], 0x4003     ; PD (0x3000) 

    ;PD -> PT we creating the pages of PT not 2MB
    mov edx, 0x4000
    mov eax, 0x5003
    mov ecx, 8

loop_Start_Mapping:
    mov dword [edx], eax
    add edx, 4
    add eax, 0x1000
    dec ecx 
    cmp ecx, 0
    je switch_to_long_mode
    jmp loop_Start_Mapping

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
