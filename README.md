# **Space Controller**

[![License](https://img.shields.io/badge/license-MIT-blue)](https://opensource.org/licenses/MIT) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

## **Authors**
- Ivan Rodriguez-Ferrandez (UPC¹-BSC²)
- Alvaro Jover-Alvarez (UPC¹-BSC²)
- Leonidas Kosmidis (BSC²-UPC¹)
- David Steenari (ESA³)
<br/>
¹ Universitat Politècnica de Catalunya (UPC) <br/>
² Barcelona Supercomputing Center (BSC) <br/>
³ European Space Agency (ESA)


<!-- ![](readme_data/space_shuttle_patch_crop.png) -->



### **Main Version of the chip: 1.0V**  

<br/>

## **Change Log**

- Version 1.0V:
  - TODO 

## **Chip Layout**
<!--![](readme_data/Selection_005.png)-->

## **Description**
This design is a radiation tolerant UART server that can be used for low level control of multiple input/output ports during a radiation testing campaign. The system features triple redundancy in order to ensure that the commands are properly executed. </br>

In addition to simulation, the RTL design of the user project is verified also on a Xilinx Zybo Z7-20 FPGA using Vivado.
The UART communication protocol is based on [https://github.com/alexforencich/verilog-uart](https://github.com/alexforencich/verilog-uart) and its [files](https://github.com/jaquerinte/space_controller/tree/main/verilog/rtl/controller/UART_SERVER) are covered with the same open source license as the rest of the project (MIT).

## **How To Use The Chip**
This chip uses the UART port for main communication. This communication port is used to send instructions and receive the requested output. 
The input is a 52 bit word for communication. In order to fill up the word, the values are sent one by one via the UART port.
The 52 bit are divided in this well defined sections:
- [51:49] 3 bit operation code.
- [48:44] 5 bit primary register operation. 
- [43:0]  44 bit auxiliary values.

As commented, the communication is through the UART port, and each 4 bits are encoded in hex. Since UART uses the ASCII table for the characters, the following list shows the mapping between the ASCII characters and the hex value interpreted by the chip:


- 1 ➜ 1
- 2 ➜ 2
- 3 ➜ 3
- 4 ➜ 4
- 5 ➜ 5
- 6 ➜ 6
- 7 ➜ 7
- 8 ➜ 8
- 9 ➜ 9
- : ➜ A
- ; ➜ B
- < ➜ C
- = ➜ D
- \> ➜ E  
- ? ➜ F

The sent data is buffered in a shift register, so in order to denote the end of the command, the ASCII character **0D** (New line) needs to be sent. If you want to clear the buffered instruction, you can send the ASCII character **20** (Space), which clears the shift register. 
### **Instruction Set**


#### **IWrite instructions**
| Type  | Description | OP Code [51:49] | Primary Register [48:44] | Auxillary [43:0] |
|--|---|---|---|---|
| IWrite | Writes a logic 1 in the selected register <br>and is maintains it for the number of cycles denoted by the value of the **Auxillary** field. | 000 | register | cycles |
| IWrite | Waits 1 Second and writes a logic 1 in <br>the selected selected register. The value is <br>maintained for a number of cycles denoted by the **Auxillary** field. | 001 | register | cycles |

<br><br>

#### **IRead instructions**
| Type  | Description | OP Code [51:49] | Primary Register [48:44] | Auxillary [43:0] |
|---|---|---|---|---|
| IRead | Reads the logic value in the selected register <br>and the read is delayed by **Auxiliary** number of cycles. | 100 | register | cycles |

<br><br>

#### **BWrite instructions**
| Type  | Description | OP Code [51:49] | Primary Register [48:44] | Auxillary [43:0] |
|---|---|---|---|---|
| BWrite | Writes 8 bit value during one clock cycle. <br>The register and value are specified in the **Auxiliary** field. | 011 | sel register 7 | [43:39] sel register 6 <br> [38:34] sel register 5 <br> [33:29] sel register 4 <br> [28:24] sel register 3 <br> [23:19] sel register 2 <br> [18:13] sel register 1 <br> [13:9] sel register 0 <br> [8] not used<br> [7:0] value for the registers|
| BWrite | Waits 1 second and writes 8 bit value during one second. <br>The register and value are specified in the **Auxiliary** field. | 111 | sel register 7 | [43:39] sel register 6 <br> [38:34] sel register 5 <br> [33:29] sel register 4 <br> [28:24] sel register 3 <br> [23:19] sel register 2 <br> [18:13] sel register 1 <br> [13:9] sel register 0 <br> [8] not used<br> [7:0] value for the registers|

<br><br>

#### **BRead instructions**
| Type  | Description | OP Code [51:49] | Primary Register [48:44] | Auxillary [43:0] |
|---|---|---|---|---|
| BRrite | Reads  8 bit value during one clock cycle. <br>The register and value are specified in the **Auxiliary** field. | 011 | sel register 7 | [43:39] sel register 6 <br> [38:34] sel register 5 <br> [33:29] sel register 4 <br> [28:24] sel register 3 <br> [23:19] sel register 2 <br> [18:13] sel register 1 <br> [13:9] sel register 0 <br> [8:0] not used|
## **Triple Redundancy Implementation**

## **Block Description**

## **Module Ports**:
- **Input Ports**
- **Output Ports**

## **Caravel Connections**

### **GPIO Connections**

### **Logic Analyzer Probes**
- Input probes: 
  
- Output probes:

### **Wishbone Connection**


### **User Maskable Interrupt Signals**



## **Description of the Modules**

### **Module List**


## **Wishbone Description**

 ### **Memory Map**

 ### **Software Example**

## **Available Tests**
