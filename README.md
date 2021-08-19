# Asynchronous-FIFO

In this repo, I have uploaded the implementation of an asynchronous FIFO. The DEPTH of the FIFO is 16 blocks and each block is of 8 bits wide i.e., it is a 16 x 8 async_fifo.

Asynchronous FIFO is used when the transmitter and reciever are in different clock domains. When the reciever is operating at low frequency compared to transmitter, then we need to store the blocks that was sent by the transmitter, otherwise, they will be lost. Hence, we use FIFO in between them so that the RECIEVER can take blocks from FIFO whenver it needs.

We have used a memory block which can hold 256 blocks from which the transmitter takes the blocks and provide to the async fifo. The transmitter should STOP writing to the FIFO whenver the FULL flag is HIGH. It indicates that FIFO is full and it is unable to accept anymore blocks from the transmitter. Similarly if EMPTY flag is HIGH, it indicates that the FIFO is completely EMPTY hence the reciever cannot access the FIFO. 

To point the depth of 16 blocks we need 4 bits for the WRITE and READ pointers but we used 5 bits. Because, if all the locations have been written except the top location, write pointer will point out to 4’b0111. Now if the top location has also been written, the write pointer will be 4'b0000 which makes the FIFO seems like EMPTY. So, if we sue 5 bits it can be avoided and it can be observed that that the full flag will be set when MSB’s of both write and read pointers are compliment of each other and the rest of the bits are equal to each other. 

Similarly, empty flag will be set when both write and read pointers (i.e., all the 5 bits) are exactly the same.

Further more as read and write pointers are in different clock domains we used synchronizers to make them synchronize.

The functionality was verified in MODELSIM by writing a testbench. The memory was stored with 10, 11, 12, ...... so the data_out that is fifo output will start from 10, 11, 12 ....which can be observed in the output graph waveforms.
