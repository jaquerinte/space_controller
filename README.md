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

![GDS](docs/space_controller_gds.png)

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


## **Block Description**
In the following image we can see a simple block diagram of how the controller interfaces with the caravel harness.

![Block_diagram](docs/simple_diagram.png)

In  simple terms the controller have two major parts, the triplicated logic and the PMU. 

### **Triplicated logic**

Inside of each of the instances of the triplicated logic we have tree distinct modules each one takes care of different functions of the controllers, and more or less, are independent between each of them.

The first module is the **UART Handler** that takes care of the communication throw the UART interface, reading each of the ASCII characters send and processing each of the characters to create one instruction. This module also is able to send data back throw the UART when other modules want to report a value or a state.

The second module is the **Logic Control**, this modules is the central brain of the desing, takes care of decoding the instruction, send commands to the IO module and responses to the UART Handler.  

The last module is the **IO MOdule** that takes the instruction of the logic control, to generate the counter for the times, as well to with I/O needs to be read or write, for one bit operations or 8 bit operations

The following diagram contains more information of how the modules are connected and the internal parts of each one.

![Detailed_diagram](docs/complex_diagram.png)


### **PMU Complex**

The PMU complex is similar to the one that is implemented in the [Space Shuttle](https://github.com/jaquerinte/caravel_radiation_harden/) project. In similar trends, is a replicated PMU that monitors the total errors of the IO  and TX wires per instance or the triplicated logic, as well two counters to count any value that does not match a one corrected error on the logic.

These 8 counters are 32 bit counters that can be access throw the wishbone  interface. The primary PMU starts in address 0x3000_0000 and the secondary address starts 0x3001_0000.




## **Triple Redundancy Implementation**
As mention previously this deign is targeted for a safety critical systems, with radiations environments. There are two possible routes to take for ensuring that a result is correct in this scenarios, first is to add parity checkers in order to verify that a bit flip has not happen, we explore that solution ECC, in  [Space Shuttle](https://github.com/jaquerinte/caravel_radiation_harden/). This solution can detect and correct a single bit flip or detect a double bit flip, but this could cause to need to re-do a computation, or some extra operation that could cause that we miss a critical deadline.

Another solution is the triplication of a module. This allows us to guaranty that and error happening in one unit will not change the output, and there fiscally different circuits doing the operation. The main drawback of this approach is the extra space  and power that is needed in order to two more replication of the system.

For this project all of the computation is triplicated, so the UART handler, logic control and IO module have separate instances. So how this implemented in verilog can be seen in the file [main_module.v](https://github.com/jaquerinte/space_controller/blob/main/verilog/rtl/controller/main_module.v), in this file we generate three instances of the [control_module.v](https://github.com/jaquerinte/space_controller/blob/main/verilog/rtl/controller/control_module.v). For the input is simple in verilog we only need to feed each of the modules with the require inputs, for example the "rx" wire from the UART, and the input signals from the GPIO.

With that each module will process a request and produce and output to the "tx" and/or in the GPIO signals. In order to detect if an error happen we need to implement a majority vote, this means that if two signals agree in one value, that value will be the correct one, independent that the third agrees or not. In order to implement this we use a series of **NAND** gates to create the majority vote as shown  in the following figure.

![](docs/majority_vote.drawio.png)

Another option if using the SkyWater 130 nm PDK is to the [maj3](https://antmicro-skywater-pdk-docs.readthedocs.io/en/test-submodules-in-rtd/contents/libraries/sky130_fd_sc_hd/cells/maj3/README.html) to reduce the number of cells use.

With that we implemented the majority vote, but also in our project is require to monitor when an error is detected, meaning that one of the three modules disagrees or the three have a complete different value ( in the case of more than one bit ). For that we use a combination of **XOR** of each par of outputs and then are pass to and **AND** gate to identify in a module has different output from the other two.
